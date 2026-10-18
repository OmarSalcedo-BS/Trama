# TRAMA · Kit de Presentación y Convocatoria de Alpha

> **"Word fue hecho para oficinas. Scrivener se quedó en 2010. Trama es la arquitectura donde nacen las grandes historias."**

Este documento contiene la presentación oficial del proyecto, su arquitectura, explicación técnica y las plantillas listas para publicar en redes sociales para reclutar evaluadores (*beta testers*).

---

## 1. ¿Qué es Trama? (Elevator Pitch)

**Trama** es un entorno editorial moderno diseñado específicamente para novelistas y creadores de mundos (*worldbuilders*).

A diferencia de un procesador de textos convencional que solo almacena párrafos lineales, Trama conecta el manuscrito en prosa con la **arquitectura viva de la historia**: personajes, dinastías, criaturas, diccionario de términos y cronología temporal.

### El problema que resuelve:
* **El caos de notas dispersas**: Los escritores suelen tener su manuscrito en Word/Docs, sus fichas en Notion/Obsidian, y árboles genealógicos en libretas o imágenes.
* **Inconsistencias narrativas**: Olvidar el color de ojos de un secundario, la fecha de una batalla o cómo se relacionan dos familias.
* **Detección contextual**: Trama subraya y detecta automáticamente cuándo un personaje o criatura de tu enciclopedia aparece en el capítulo que estás escribiendo.

---

## 2. Esqueleto de la Aplicación (Módulos y Funcionamiento)

Puedes usar esta estructura como guion para las capturas de pantalla o videos de demostración:

### 1. El Editor de Manuscrito
* **Diseño tipográfico editorial**: Fondo marfil cálido, serifas diseñadas para largas sesiones de lectura y sin distracciones.
* **Guardado automático en la nube**: Cero miedo a perder cambios o cortes de energía.
* **Métricas en tiempo real**: Contador de palabras por capítulo y total de la obra.
* **Detección inteligente de entidades**: El editor reconoce en vivo los nombres de tus personajes, criaturas y facciones dentro de la prosa.

### 2. Fichas de Personajes y Mapa de Relaciones
* **Identidad completa**: Nombres, apellidos, casas, familias y notas de linaje.
* **Grafo visual de relaciones**: Un mapa interactivo estilo constelación que conecta personajes con vínculos de parentesco, rivalidad, lealtad o romance.

### 3. Worldbuilding, Bestiario y Glosario
* **Enciclopedia viva**: Categorías personalizables (reinos, magias, facciones, tecnología).
* **Vínculos cruzados**: Fichas vinculadas bidireccionalmente entre sí y con los personajes que intervienen en ellas.
* **Bestiario dinámico**: Catálogo de criaturas y razas fantásticas.

### 4. Cronología Temporal
* **Línea de tiempo**: Visualización ordenada de sucesos históricos, nacimientos y giros argumentales para no perder la coherencia temporal.

### 5. Importador Inteligente `.docx`
* Permite traer novelas ya comenzadas en Word; detecta los estilos de título (*Título 1, Heading 1, Chapter*) y estructura los capítulos automáticamente en orden.

### 6. Canal de Retroalimentación y Reporte de Errores
* Los evaluadores cuentan con un módulo directo en la sección *Publicar e importar* para reportar cualquier bug o enviar sugerencias que llegan directamente al creador (`salcedosolarteomar@gmail.com`) con el ID del proyecto para trazabilidad inmediata.

---

## 3. Stack Tecnológico

Trama está construida con arquitectura moderna de alto rendimiento:

* **Frontend**: **Flutter Web (Dart)** compilado con soporte CanvasKit/WebAssembly para transiciones fluidas a 60 fps y renderizado tipográfico de precisión editorial.
* **Gestión de Estado y Rutas**: **Riverpod 2.0** (reactividad pura y desacoplada) + **GoRouter** para navegación SPA protegida.
* **Backend y Base de Datos**: **Supabase (PostgreSQL)**:
  * **Row Level Security (RLS)** estricto: Las historias y datos pertenecen única y exclusivamente al autor; ni siquiera otros testers pueden interceptar datos ajenos.
  * Autenticación tokenizada persistente.
* **Infraestructura y CDN**: **Firebase Hosting (Google Cloud)** para distribución estática global ultrarrápida, SSL automático y soporte de reescritura de rutas.
* **Herramientas de Control Alpha**: Scripts en Python nativo para generación y aprovisionamiento criptográfico de claves de acceso.

---

## 4. ¿Cómo Funciona la Invitación y el Acceso Alpha?

Para mantener el control estricto de la prueba y garantizar la seguridad de los evaluadores:

1. **Sin contraseñas tediosas**: Los testers no necesitan pasar por un proceso de registro largo con confirmaciones de email complejas.
2. **Código único personal (`TRAMA-XXXX-XXXX`)**: Tú generas un código (con el script de Python o el SQL proporcionado) y se lo entregas por mensaje directo o correo.
3. **Vinculación automática en el primer acceso**:
   * El tester entra a `https://trama-f1d01.web.app`.
   * En la pantalla Alpha introduce su **correo personal** y su **código**.
   * El sistema valida el código en Supabase, lo bloquea contra reuso y crea su cuenta privada al instante.
   * En visitas posteriores, su sesión se mantiene abierta en su navegador.

---

## 5. Plantillas Listas para Publicar en Redes Sociales

---

### Opción A: Hilo para X (Twitter) / Threads

**Tweet 1 (Gancho):**
> Word fue creado para redactar contratos. Scrivener se diseñó hace casi 20 años.
> 
> Llevo meses construyendo un editor pensado exclusivamente para la arquitectura de una novela: capítulos, personajes, linajes, cronología y lore conectados en un solo lugar.
> 
> Se llama **Trama** 🧵 y hoy abro la Alpha privada para 10 escritores: 👇

**Tweet 2 (El problema):**
> Si escribes novelas o fantasía/sci-fi, conoces este infierno:
> - El manuscrito en Word.
> - Las fichas de personajes en Notion.
> - La cronología en una libreta.
> 
> Y cuando escribes el capítulo 14, ya no recuerdas cómo se llamaba el tío del protagonista ni en qué año ocurrió la batalla.

**Tweet 3 (La solución / Características):**
> Trama une ambas mitades:
> ✍️ Editor limpio con guardado automático y métricas de palabras.
> 👥 Fichas de personajes con familias y mapa visual de relaciones.
> 🌍 Enciclopedia de worldbuilding y bestiario integrado.
> ⏱️ Cronología para no romper la línea temporal.
> 📄 Importador directo de archivos .docx.

**Tweet 4 (Llamada a la acción):**
> Está desplegado en web (no hay que instalar nada) con sincronización en tiempo real y privacidad total en la nube.
> 
> Tengo **10 códigos de acceso** para evaluadores que quieran probarlo y darme feedback directo.
> 
> Si estás escribiendo un libro y quieres un código, responde con un 📖 o envíame un DM y te paso tu acceso.

---

### Opción B: Post para Instagram / TikTok (con video o carrusel de capturas)

**Texto para el post:**
> Si escribes historias largas, sabes que el mayor reto no es escribir... es mantener el orden. 📚✨
> 
> Les presento **TRAMA**, un software web diseñado para arquitectos de historias:
> 
> 🔹 Manuscrito por capítulos con tipografía editorial.
> 🔹 Mapa de relaciones entre personajes y dinastías.
> 🔹 Worldbuilding y cronología viva conectada a tu texto.
> 🔹 Importación de tus borradores de Word (.docx) con un clic.
> 
> Hoy lanzamos la **Alpha privada** con accesos limitados para autores que quieran probar la plataforma antes de su lanzamiento público.
> 
> 🎟️ **¿Cómo entrar?**
> Tenemos solo 10 códigos de prueba disponibles. Deja un comentario diciendo qué género escribes o escríbeme por DM con la palabra **"TRAMA"** y te comparto tu código personal.
> 
> #escritores #escribirunanovela #worldbuilding #autoresindie #literatura #scrivener #libros

---

### Opción C: Post para Comunidades (Reddit r/escritores, Discord de escritura)

**Título:** *Construí un editor web para novelistas y busco 10 autores para probar la Alpha privada*

**Cuerpo:**
> Hola a todos.
> 
> Como muchos aquí, siempre sentí frustración saltando entre Word, hojas de cálculo y Notion para mantener la coherencia de una historia larga (especialmente con tramas complejas, personajes secundarios y cronologías).
> 
> Decidí crear **Trama** (https://trama-f1d01.web.app): un editor editorial web que integra el manuscrito con el mapa de relaciones, fichas de personajes, bestiario y línea temporal.
> 
> **Características principales en esta versión:**
> - Editor minimalista con guardado automático y conteo de palabras.
> - Mapa visual de vínculos entre personajes.
> - Enciclopedia de worldbuilding vinculada a la prosa.
> - Importación de archivos `.docx` detectando capítulos automáticamente.
> - Privacidad completa (base de datos PostgreSQL con RLS donde cada proyecto está aislado).
> 
> Acabo de desplegar la versión Alpha y tengo **10 códigos de acceso** para autores que quieran trastear con él y darme su opinión honesta sobre qué herramientas les facilitan la vida y cuáles mejorarían.
> 
> Si estás escribiendo una historia y te apetece probarlo, déjame un comentario o mándame un mensaje y te envío tu código de invitación.
