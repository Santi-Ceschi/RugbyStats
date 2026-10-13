# RugbyStats - Sistema de Seguimiento y Análisis Estadístico en Tiempo Real

> **Club:** Alma Juniors Rugby  
> **Proyecto:** Práctica Profesional / Proyecto Final de Carrera  
> **Arquitectura:** Offline-First, Persistencia SQLite Local, Generación Vectorial de Reportes PDF

---

## 🏉 Descripción del Proyecto

**RugbyStats** es una aplicación móvil diseñada específicamente para el cuerpo técnico y analistas de **Club Alma Juniors Rugby**. Permite la captura de acciones de juego en vivo, el control de tiempos de partido mediante un cronómetro híbrido resiliente y la generación inmediata de informes estadísticos avanzados y reportes en PDF compartibles.

El modelo estadístico implementa la semántica oficial de la planilla de análisis post-partido del club:
- **Obtención Propia:** Mide la efectividad en formaciones fijas propias (*Scrum*, *Lineout*, *Maul*, *Salida*).
- **Recuperación / Robadas al Rival:** Cuantifica balones robados o pescados en lanzamientos del oponente.
- **Rendimiento Completo del Rival:** Registra tackles, efectividad en patadas, tries, errores forzados/no forzados, penales por motivo y tarjetas.

---

## 🛠️ Tecnologías Utilizadas

- **Framework:** [Flutter](https://flutter.dev/) (Channel Stable, SDK >= 3.7.0)
- **Lenguaje:** [Dart](https://dart.dev/) (SDK >= 3.0.0)
- **Base de Datos Local:** SQLite a través de [`sqflite`](https://pub.dev/packages/sqflite) (Versión 3 del esquema relacional)
- **Seguridad y Criptografía:** Algoritmo SHA-256 mediante [`crypto`](https://pub.dev/packages/crypto) para hashing de contraseñas
- **Reportes Vectoriales:** [`pdf`](https://pub.dev/packages/pdf) y [`printing`](https://pub.dev/packages/printing) (diseño multipágina optimizado A4)
- **Interoperabilidad:** [`share_plus`](https://pub.dev/packages/share_plus) para exportar reportes y copias de seguridad
- **Manejo de Archivos:** [`file_picker`](https://pub.dev/packages/file_picker) y [`path_provider`](https://pub.dev/packages/path_provider)

---

## 📋 Requisitos Previos

Asegúrate de contar con las siguientes herramientas instaladas en tu entorno:
1. **Flutter SDK:** Versión `>= 3.7.0` (recomendado Flutter 3.19.x o superior).
2. **Dart SDK:** Incluido automáticamente con Flutter.
3. **Entorno de Ejecución:**
   - **Android:** Android Studio con Android SDK configurado y emulador AVD (o dispositivo físico con depuración USB activada).
   - **iOS:** macOS con Xcode y CocoaPods instalados (`pod --version`).
4. **Git:** Para clonar el repositorio.

---

## 🚀 Instrucciones de Instalación y Ejecución

Sigue estos pasos para clonar, preparar y ejecutar la aplicación:

```bash
# 1. Clonar el repositorio
git clone <URL_DEL_REPOSITORIO>

# 2. Entrar al directorio del proyecto Flutter
cd RugbyStats/rugby_stats

# 3. Descargar todas las dependencias
flutter pub get

# 4. Verificar configuración del entorno (opcional)
flutter doctor

# 5. Ejecutar la aplicación en tu emulador o dispositivo conectado
flutter run
```

---

## 👤 Credenciales de Acceso y Datos de Prueba

La aplicación funciona de forma **100% offline-first**:

### Opción A: Registrar un Nuevo Usuario
1. En la pantalla inicial, presiona **"¿No tienes cuenta? Regístrate"**.
2. Completa tu Nombre, Email, Teléfono y Contraseña.
3. Inicia sesión con las credenciales registradas.

### Opción B: Importar Base de Datos con Partidos de Prueba (Backup JSON)
En la pantalla de inicio de sesión existe un botón directo para **"IMPORTAR BACKUP (JSON)"**:
1. Selecciona el archivo de respaldo provisto en el repositorio: `backup_rugby.json`.
2. El sistema restaurará automáticamente usuarios de prueba, tipos de acciones, partidos históricos y todas las acciones registradas.

---

## 📂 Estructura del Proyecto

El código fuente dentro de `rugby_stats/lib/` sigue una separación de responsabilidades limpia y modular:

```text
lib/
├── models/                     # Entidades de dominio y mapeos SQLite
│   ├── accion.dart             # Eventos del partido (Try, Scrum, Penal, etc.)
│   ├── partido.dart            # Datos del partido, marcador y metadatos
│   ├── tipo_accion.dart        # Catálogo de tipos de eventos
│   └── usuario.dart            # Modelo de usuario autenticado
├── services/                   # Lógica de negocio y persistencia
│   ├── calculadora_estadisticas.dart  # Motor matemático único para métricas en vivo y PDF
│   ├── database_helper.dart           # Capa de acceso a SQLite (CRUD, migraciones, export/import)
│   └── pdf_generator.dart             # Generación de reportes PDF vectoriales
├── utils/                      # Reglas deportivas y constantes globales
│   ├── app_constants.dart      # Nombre del club, valores por defecto
│   └── reglas_rugby.dart       # Puntuaciones reglamentarias de la UAR/World Rugby
├── widgets/                    # Componentes visuales desacoplados
│   ├── dialog_estadisticas_en_vivo.dart
│   ├── dialog_nuevo_partido.dart
│   ├── panel_filtrado.dart
│   └── partido_card.dart
├── home_page.dart              # Pantalla principal con lista y filtros de partidos
├── login_page.dart             # Autenticación y acceso a importación de backups
├── register_page.dart          # Registro de nuevos analistas/usuarios
├── match_page.dart             # Consola de toma de estadísticas en vivo y cronómetro
├── match_edit_page.dart        # Editor y corrector de acciones de partidos finalizados
└── reporte_final_page.dart     # Pantalla visual de estadísticas post-partido y descarga PDF
```

---

## 🧪 Ejecución de Pruebas Automatizadas

Para ejecutar la suite de pruebas unitarias y de widgets:

```bash
cd rugby_stats
flutter test
```

Todas las pruebas se ejecutan sobre el motor de cálculo matemático [`CalculadoraEstadisticas`], validando efectividad de formaciones, patadas, disciplina y métricas del rival.