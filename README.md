# Trama

Editor editorial para construir historias: personajes, worldbuilding,
relaciones, diccionario, cronología, bestiario y manuscrito por capítulos.

Trama es un estudio de escritura personal, diseñado para novelistas que necesitan organizar su universo narrativo sin perder el foco en la prosa. Es una herramienta integral que centraliza el manuscrito, las fichas de personajes, el worldbuilding, el bestiario y la cronología en un solo lugar.

Sin inteligencia artificial generativa, sin límites arbitrarios y con la soberanía de tus datos como principio irrenunciable.

# Filosofía
Núcleo libre: Las funciones esenciales para escribir y organizar tu novela son gratuitas y sin restricciones de palabras o proyectos.

Cero I.A.: Tus textos no entrenan algoritmos ajenos. No hay asistentes de reescritura ni autocompletado artificial.

Soberanía de datos: Tu obra es tuya. Puedes exportarla en formatos abiertos cuando quieras.

Cualquier género: Diseñado para adaptarse a la fantasía épica, el thriller psicológico o la novela intimista por igual.

# Funcionalidades
Editor de prosa: Un espacio limpio con tipografía literaria, conteo de palabras en tiempo real y autoguardado.

Fichas de personajes: Dossiers completos con psicología, arcos narrativos, apariencia y relaciones.

Worldbuilding flexible: Crea tus propias categorías (lugares, facciones, magia, tecnología) y organízalas con iconos y colores.

Bestiario y Glosario: Registra criaturas y términos inventados con sus definiciones.

Cronología: Líneas de tiempo para ordenar los eventos de tu historia sin agujeros de guion.

Mapa de relaciones: Visualiza las tensiones y alianzas entre tus personajes.

Inspector de escena: Mientras escribes, el sistema detecta qué personajes y criaturas aparecen en el capítulo para tenerlos a mano.

Exportación completa: Genera tu manuscrito en PDF, Word, Markdown o texto plano.

## Primeros pasos (Desarrollo local)
Para contribuir o ejecutar tu propia instancia de Trama, necesitarás configurar tu entorno.

### Requisitos previos
Flutter (versión estable)

Una cuenta en Supabase (para la base de datos y autenticación)

### Instalación
Clona el repositorio:

```bash
git clone https://github.com/TU_USUARIO/Trama.git
cd Trama
Instala las dependencias:

bash
flutter pub get
Configura tus credenciales (Importante):
Crea un archivo .env en la raíz del proyecto. Trama no incluye credenciales por defecto; debes usar tu propio proyecto de Supabase.

env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui
Ejecuta la aplicación:

bash
flutter run -d chrome
🧱 Stack Tecnológico
Frontend: Flutter (Dart) con Riverpod para la gestión de estado.

Backend: Supabase (PostgreSQL, Autenticación, Row Level Security).

Arquitectura: Feature-First, con separación estricta de responsabilidades (Domain, Data, Presentation).

```

# Licencia
Este proyecto está bajo la licencia MIT (o la que decidas usar). Eres libre de usarlo, modificarlo y adaptarlo a tus necesidades.
