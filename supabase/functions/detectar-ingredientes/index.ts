const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

async function llamarGemini(body: Record<string, unknown>, intentos = 1) {
  const key = Deno.env.get("GEMINI_API_KEY");
  const modelo = Deno.env.get("GEMINI_MODEL") ?? "gemini-3.8-flash";
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelo}:generateContent?key=${key}`;

  let res!: Response;
  let data: any;
  for (let i = 0; i < intentos; i++) {
    try {
      res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(40000),
      });
      data = await res.json();
    } catch (e) {
      data = { error: String(e) };
      res = new Response(null, { status: 504 });
    }
    if (res.status !== 503 && res.status !== 429 && res.status !== 504) break;
    await new Promise((r) => setTimeout(r, 1000));
  }
  return { res, data };
}
function clasificarError(status: number, data: any) {
  const msg = JSON.stringify(data ?? "");
  if (status === 503) return { tipo: "saturado", mensaje: "La IA está ocupada. Probá de nuevo en unos segundos." };
  if (status === 429) return { tipo: "cuota", mensaje: "Se alcanzó el límite de uso de la IA. Probá en un rato." };
  if (status === 504 || msg.includes("TimeoutError")) return { tipo: "timeout", mensaje: "La IA tardó demasiado en responder. Intentá de nuevo." };
  if (status === 404) return { tipo: "modelo", mensaje: "El modelo de IA no está disponible. Avisá al administrador." };
  if (status === 400 && msg.includes("API key")) return { tipo: "clave", mensaje: "La clave de la IA no es válida. Avisá al administrador." };
  if (status === 401 || status === 403) return { tipo: "permiso", mensaje: "La IA rechazó la solicitud por permisos." };
  return { tipo: "desconocido", mensaje: "Ocurrió un error inesperado con la IA." };
}
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  const { image, mimeType } = await req.json();

  const { res, data } = await llamarGemini({
    contents: [{
      parts: [
        { text: "Identifica los ingredientes comestibles visibles en la foto. Responde en español con nombres simples y sin repetir." },
        { inline_data: { mime_type: mimeType ?? "image/jpeg", data: image } },
      ],
    }],
    generationConfig: {
      responseMimeType: "application/json",
      maxOutputTokens: 1024,
      responseSchema: {
        type: "OBJECT",
        properties: {
          ingredientes: { type: "ARRAY", items: { type: "STRING" } },
        },
        required: ["ingredientes"],
      },
    },
  });

  if (!res.ok) {
  console.error("Error de Gemini:", res.status, JSON.stringify(data));
  const info = clasificarError(res.status, data);
  return new Response(JSON.stringify({ error: info, status: res.status }), {
    status: 500,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
  

  const texto = data.candidates?.[0]?.content?.parts?.[0]?.text;
 if (!texto) {
  return new Response(JSON.stringify({
    error: { tipo: "vacio", mensaje: "La IA no devolvió resultados. Intentá de nuevo." },
  }), { status: 500, headers: { ...cors, "Content-Type": "application/json" } });
}

  return new Response(texto, { headers: { ...cors, "Content-Type": "application/json" } });
});