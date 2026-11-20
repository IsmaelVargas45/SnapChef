# SnapChef

Aplicación móvil hecha con **Flutter** que te ayuda a decidir qué cocinar con lo que tenés en casa. Cargás tus ingredientes a mano o sacándole una foto a tu heladera o alacena, y una IA (**Google Gemini**) te sugiere recetas completas con ingredientes, preparación y tiempos.

> Trabajo integrador de Flutter.

---

## Funcionalidades

- **Carga de ingredientes manual:** agregás y quitás ingredientes de tu lista. No se permiten duplicados.
- **Detección por foto:** sacás una foto y la IA reconoce los ingredientes y los agrega a la misma lista.
- **Generación de recetas con IA:** a partir de tu lista se generan varias recetas sugeridas.
- **Receta completa:** al tocar una receta ves ingredientes, preparación y tiempo estimado. Los ingredientes básicos (sal, aceite y agua) se marcan como "se asume que los tenés".
- **Te falta:** cada receta indica qué ingredientes extra necesitarías.
- **Historial:** guardás las recetas que cocinaste, las volvés a abrir completas y las borrás (una por una o todo el historial).
- **Mensajes de error claros:** distingue sin internet, IA saturada, límite de uso, timeout, etc.
- **Sin registro:** usa sesión anónima de Supabase, así que no hace falta crear una cuenta.

---

## Cómo funciona

```
Flutter (app)  ──►  Supabase Edge Function  ──►  Gemini API
     ▲                      │                        │
     └──────── JSON ◄───────┴────────────────────────┘
```

La app **nunca** tiene la API key de Gemini. Las llamadas a la IA pasan por dos Edge Functions de Supabase que guardan la clave como secreto, arman el prompt, llaman a Gemini y devuelven un JSON estructurado.

| Edge Function | Entrada | Salida |
|---|---|---|
| `detectar-ingredientes` | Foto en base64 | `{ "ingredientes": [...] }` |
| `generar-receta` | Lista de ingredientes | `{ "recetas": [{ titulo, tiempo_minutos, ingredientes, faltantes, pasos }] }` |

Los datos del usuario (ingredientes e historial) se guardan en tablas de Supabase, asociados a su usuario anónimo.

---

## Tecnologías

- [Flutter](https://flutter.dev) / Dart
- [Supabase](https://supabase.com): base de datos, autenticación anónima y Edge Functions (Deno / TypeScript)
- [Google Gemini API](https://aistudio.google.com)
- Paquetes principales: `supabase_flutter`, `provider`, `image_picker`, `permission_handler`, `flutter_dotenv`, `intl`

---

## Estructura del proyecto

```
lib/
├── main.dart
└── src/
    ├── app.dart
    ├── models/        historial_model.dart
    ├── pages/         my_home_page, inicio_page, scan_page,
    │                  lista_recetas_ia_page, receta_ia_page,
    │                  historial_page, welcome_page
    ├── provider/      menu_provider.dart        (historial)
    ├── routes/        routes.dart
    ├── service/       ia_service.dart           (llama a las Edge Functions)
    ├── state/         ingredientes_controller.dart
    ├── utils/         app_colours, error_ia, icon_string_util
    └── widgets/       barra_navegacion, lista_ingredientes,
                       boton_generar_receta
supabase/
└── functions/
    ├── generar-receta/index.ts
    └── detectar-ingredientes/index.ts
```

**Flujo de pantallas:**
`Inicio` (agregar ingredientes) → `Generar recetas` → `Lista de recetas` → `Receta completa` → `Guardar en historial`.
La pestaña **Escanear** permite sumar ingredientes con la cámara, y **Historial** muestra las recetas guardadas.

---

## Requisitos

- Flutter SDK instalado (`flutter doctor` sin errores)
- Node.js (para usar la CLI de Supabase con `npx`)
- Un proyecto de [Supabase](https://supabase.com)
- Una API key de Gemini desde [Google AI Studio](https://aistudio.google.com)
- Un celular Android con depuración USB (recomendado, por la cámara)

---

## Configuración

### 1. Clonar e instalar dependencias

```bash
git clone <url-del-repositorio>
cd trabajo_integrador_flutter
flutter pub get
```

### 2. Variables de entorno de la app

Creá un archivo `.env` en la raíz del proyecto (junto a `pubspec.yaml`):

```
SUPABASE_URL=https://TU_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=tu_anon_key
```

Debe estar declarado como asset en `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

> ⚠️ `.env` está en `.gitignore`. Solo va la **anon key** (pública por diseño). **Nunca** pongas ahí la `service_role` key ni la API key de Gemini.

### 3. Permisos de Android

En `android/app/src/main/AndroidManifest.xml`, antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

Sin `INTERNET` la versión release no puede conectarse a Supabase.

### 4. Autenticación anónima

En el panel de Supabase: **Authentication → Sign In / Providers → Anonymous sign-ins** debe estar **habilitado**.

### 5. Base de datos

Estructura de referencia (ajustala a tu proyecto):

```sql
create table ingredientes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  user_id uuid not null default auth.uid(),
  created_at timestamptz default now()
);

create table historial (
  id uuid primary key default gen_random_uuid(),
  titulo_receta text not null,
  ingredientes_usados jsonb default '[]'::jsonb,
  pasos jsonb default '[]'::jsonb,
  tiempo_minutos integer,
  fecha timestamptz default now(),
  user_id uuid not null default auth.uid()
);

alter table ingredientes enable row level security;
alter table historial enable row level security;

create policy "ingredientes propios" on ingredientes
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "historial propio" on historial
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
```

Las políticas RLS hacen que cada usuario vea y modifique **solo sus propios datos**.

### 6. Edge Functions y secretos

```bash
npx supabase login
npx supabase link --project-ref TU_PROJECT_REF

npx supabase secrets set GEMINI_API_KEY=tu_clave_de_gemini
npx supabase secrets set GEMINI_MODEL=id-del-modelo

npx supabase functions deploy generar-receta
npx supabase functions deploy detectar-ingredientes
```

- `GEMINI_MODEL` permite cambiar de modelo sin tocar el código. Consultá el ID vigente en AI Studio, porque los nombres cambian con el tiempo.
- Cada vez que modifiques un `index.ts` (por ejemplo el prompt) hay que volver a ejecutar `deploy`.

---

## Ejecutar la app

Listá los dispositivos y ejecutá usando el ID del celular:

```bash
flutter devices
flutter run -d ID_DEL_DISPOSITIVO
```

> La cámara y los permisos no son confiables en el navegador ni en escritorio. Para probar el escaneo usá un celular real.

---

## Generar el APK

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`. Para instalarlo conservando los datos de la app:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

> `flutter install` desinstala la versión anterior, y eso borra la sesión anónima local: la app arranca como un usuario nuevo, sin ingredientes ni historial.

---

## Sesiones anónimas: qué tener en cuenta

Cada instalación de la app crea un usuario anónimo en Supabase. La sesión se guarda en el dispositivo, por lo que:

- Si desinstalás la app o borrás sus datos, se pierde la sesión y se crea un usuario nuevo.
- En el navegador, cada ejecución en modo debug puede parecer un dispositivo nuevo.
- Los datos viejos quedan en Supabase pero ya no son accesibles.

---

## Solución de problemas

| Problema | Causa probable | Qué hacer |
|---|---|---|
| `La IA está ocupada` (503) | Gemini saturado | Esperar unos segundos y reintentar, o cambiar `GEMINI_MODEL` |
| `Se alcanzó el límite de uso` (429) | Cuota del plan gratuito | Esperar y reintentar |
| `La IA tardó demasiado` | Timeout | Reintentar; usar un modelo más liviano (tipo *flash-lite*) |
| `Sin conexión a internet` | Sin red en el dispositivo | Revisar Wi-Fi o datos, y DNS privado en Android |
| Modelo no encontrado (404) | ID de modelo desactualizado | Actualizar el secreto `GEMINI_MODEL` y redesplegar |
| En release no conecta a Supabase | Falta permiso `INTERNET` | Agregarlo al `AndroidManifest.xml` |
| La app se cierra al iniciar | `.env` no declarado en `assets` | Revisar `pubspec.yaml` |
| El borrado del historial no hace nada | Falta política RLS de borrado | Crear la política `for delete` |
| La lista de recetas sale vacía | Función desplegada con el formato viejo | Redesplegar `generar-receta` |

Para ver el error real de una función: panel de Supabase → **Edge Functions → (función) → Logs**.

---

## Seguridad

- La API key de Gemini vive solo como **secreto de Supabase**, nunca dentro de la app.
- El `.env` de la app contiene únicamente la **anon key**, que es pública; la protección real la dan las políticas **RLS**.
- No subas `.env` ni claves al repositorio. Si alguna se expuso, regenerala.

---

## Posibles mejoras

- Login con email para conservar los datos entre dispositivos (convertir el usuario anónimo en permanente).
- Conservar la lista de recetas generadas al cambiar de pestaña.
- Preguntar si quitar de la lista los ingredientes usados al cocinar una receta.
- Reintentos automáticos ante errores 503 en las Edge Functions.

---

## Autor

Ismael Vargas