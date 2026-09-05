# Módulo 1: Fitness & Entrenamiento (Ejercicio)

## 1. Descripción General

Módulo encargado de la planificación, ejecución en tiempo real y análisis progresivo del entrenamiento físico, con soporte offline-first, control en segundo plano y asistencia mediante IA.

---

## 2. Especificación de Pantallas y Flujos

### 2.1 Pantalla Principal: Menú de Rutinas (`WorkoutHomeScreen`)

- **Detección Automática:** Identifica el día en curso y despliega la rutina programada. Si no hay rutina asignada, ofrece iniciar un entrenamiento libre o seleccionar una plantilla guardada.
- **Reorganización Dinámica:** Reordenamiento de ejercicios mediante `ReorderableListView` (drag-and-drop).
- **Card de Ejercicio:** Muestra nombre, grupo muscular principal, tipo de métrica (reps/peso o tiempo) y series objetivo.
- **Acciones Rápidas:** Selector de rutinas guardadas, acceso a historial rápido y botón destacado para **Iniciar Entrenamiento**.

### 2.2 Pantalla Secundaria: Gestión y Configuración (`WorkoutSettingsScreen`)

- **CRUD de Rutinas:** Creación, edición y eliminación de plantillas y asignación a días específicos del microciclo semanal.
- **Plantillas Huérfanas:** Banco de rutinas no asignadas a días fijos (ej. entrenamientos rápidos de viaje o rutinas accesorias).
- **Gestión de Planes Completos:** Guardado y alternancia entre programas semanales (ej. _Hipertrofia 4 días_ vs. _Calistenia 3 días_).
- **Metas de Frecuencia:** Configuración del objetivo de días activos por semana.
- **AI Routine Assistant:** Interfaz integrada con Gemini para generar, balancear o incrementar la sobrecarga progresiva según el rendimiento histórico registrado.

### 2.3 Pantalla de Ejecución: Modo Entrenamiento (`ActiveWorkoutScreen`)

- **Flujo Guiado de Series:** Visualización de ejercicio actual, serie en curso, carga previa y checkboxes de completado.
- **Manejo Dual de Temporizadores:**
  - Modo Intervalo/Isométrico: Cuenta regresiva de ejecución activa.
  - Modo Descanso: Temporizador post-serie con ajuste dinámico (+30s, omitir, pausar).
- **Telemetría de Sesión:** Registro automático de marcas de tiempo por serie, tiempo real de descanso y volumen total acumulado en base de datos local.
- **Persistencia de Sesión Activa:** Recuperación de estado ante cierres inesperados de la aplicación.

---

## 3. Requisitos Técnicos y Sistema

- **Foreground Service & Notificación Interactiva:**
  - Servicio en primer plano persistente durante toda la sesión de entrenamiento.
  - Notificación con botones de acción directa: `Pausar`, `+30s Descanso`, `Siguiente Serie`.
- **Alarmas Exactas:**
  - Uso de APIs de alarma nativa (`SCHEDULE_EXACT_ALARM` en Android) para garantizar la finalización exacta del descanso incluso bajo Doze Mode.
- **Integración con Gemini (AI Trainer):**
  - Generación y refinamiento de rutinas basadas en prompts con salida forzada a `JSON Schema`.
  - Parámetros de entrada: disciplina (Gym, Calistenia, Casa), equipo disponible, tiempo límite y métricas de dificultad reportadas por el usuario.
