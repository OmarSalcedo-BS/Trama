# Trama

Editor editorial para construir historias: personajes, worldbuilding,
relaciones, diccionario, cronología, bestiario y manuscrito por capítulos.

## Estado del MVP alpha

Trama está preparada para una alpha privada/demo con usuarios controlados.
Las funcionalidades principales implementadas son:

- Autenticación y proyectos con Supabase.
- Capítulos con guardado, conteo de palabras, búsqueda y detección de
  personajes/criaturas.
- Fichas de personajes con apellidos, familias y linajes.
- Relaciones entre personajes y mapa visual.
- Worldbuilding con categorías reutilizables y vínculos a personajes,
  criaturas y otras fichas.
- Bestiario y glosario con categorías dinámicas.
- Cronología visual, notas y herramientas editoriales.
- Importación local de manuscritos `.docx` por títulos de capítulo.
- Exportación desde la sección de publicación/importación.

### Qué falta antes de llamarlo MVP alpha completo

Estas tareas son recomendables antes de invitar usuarios externos:

1. **Aplicar y verificar el esquema en Supabase.** Ejecuta el SQL completo
   indicado abajo y prueba con una cuenta demo que RLS impida acceder a otro
   proyecto.
2. **Configurar autenticación de producción.** Define URL de producción,
   redirects permitidos y recuperación de contraseña en Supabase Auth.
3. **Prueba de aceptación.** Recorre registro, inicio de sesión, creación,
   edición y eliminación de cada entidad; importa un DOCX real y comprueba
   caracteres, capítulos y contenido.
4. **Observabilidad.** Añade un canal para reportar errores de usuarios y
   conserva una copia del esquema/migraciones aplicadas.
5. **Política de datos.** Define retención, exportación y borrado de cuentas
   antes de usar datos de escritores reales.
6. **Hardening posterior a la alpha.** Añade tests automatizados de
   repositorios/RLS, sincronización en tiempo real y control de conflictos de
   edición. No son bloqueantes para una demo pequeña, pero sí para producción.

El corrector ortográfico avanzado depende del navegador y del sistema
operativo; todavía no debe anunciarse como un corrector propio de nivel Word.

## Distribución web y Firebase Hosting

Firebase Hosting solo sirve los archivos estáticos de Flutter. Trama sigue
usando Supabase para autenticación, datos y políticas RLS; Firebase no
reemplaza a Supabase en esta arquitectura.

El paquete listo para publicar se genera en `dist/`:

```powershell
flutter pub get
flutter analyze
flutter build web --release --base-href /
Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue
Copy-Item -Recurse build\web dist
```

El archivo `firebase.json` configura `dist` como carpeta pública y la
reescritura necesaria para que las rutas de Flutter funcionen.

Después de instalar y autenticar Firebase CLI:

```powershell
firebase login
firebase use <ID_DEL_PROYECTO_FIREBASE>
firebase deploy --only hosting
```

Para una demo, usa un proyecto Firebase separado del proyecto de producción y
limita el acceso mediante las reglas de registro/invitación de Supabase. No
incluyas nunca una `service_role` key en `.env`, en el código Flutter ni en
`dist`; la clave publicable/anónima sí puede estar en el cliente porque RLS
debe ser la barrera de seguridad.

## Desarrollo local

Las credenciales locales se cargan desde `.env` mediante `SUPABASE_URL` y
`SUPABASE_ANON_KEY`:

```text
SUPABASE_URL=https://<tu-proyecto>.supabase.co
SUPABASE_ANON_KEY=<tu-clave-publishable-o-anon>
```

Después ejecuta:

```powershell
flutter pub get
flutter run -d chrome
```

No guardes claves de servicio, contraseñas ni tokens privados en el
repositorio. La URL y la clave publicable son configuración de cliente; la
protección real debe mantenerse en RLS.

## Supabase

Ejecuta [supabase/story_tools_schema.sql](supabase/story_tools_schema.sql) en
el SQL Editor del proyecto antes de usar capítulos, notas, diccionario,
cronología, relaciones o worldbuilding. La migración es idempotente, añade
`surname`, `family_name` y `lineage_notes` a `characters`, y normaliza
instalaciones antiguas que usaban `colors` o `event:date`.

Las fichas de worldbuilding pueden vincular personajes existentes mediante
`world_entry_characters`, criaturas mediante `world_entry_bestiary` y otras
fichas mediante `world_entry_links`. Las claves, restricciones y políticas RLS
impiden duplicados, autorrelaciones y vínculos entre proyectos distintos.

## Editor e importación

La sección **Capítulos** guarda automáticamente el manuscrito, muestra
palabras del capítulo y de la obra, busca palabras completas y detecta
personajes, relaciones y criaturas a partir del contenido. La corrección
ortográfica depende del soporte nativo del navegador/sistema.

La sección **Publicar e importar** permite seleccionar un `.docx`, detectar
capítulos por estilos `Título 1`, `Heading 1`, `Title` o `Chapter`, mostrar una
vista previa y crear los capítulos en orden ascendente conservando el
contenido. No crea personajes ni fichas automáticamente.

## Datos que aún conviene probar en alpha

- Login, logout, registro y recuperación de contraseña.
- Guardado y edición repetida de capítulos sin perder contenido.
- Importación DOCX con acentos, diálogos, tabulaciones y saltos de línea.
- Creación, edición, duplicado y eliminación de personajes y criaturas.
- Vínculos de worldbuilding después de recargar la aplicación.
- RLS con dos usuarios y proyectos distintos.
- Carga de la aplicación en una ventana privada del navegador.
