# Vie - Plan de Trabajo y Roadmap del Módulo de Entrenamiento (Exercise)

> Documento de diagnóstico, prioridades y especificación funcional para la optimización y evolución del módulo de entrenamiento.

---

## 1. Diagnóstico Actual del Sistema

### Puntos Fuertes
- **Arquitectura Limpia y Modular:** Estricta separación por capas (Clean Architecture con capas de Dominio puro, Datos con Drift SQLite y Presentación con Riverpod).
- **Offline-First:** Almacenamiento local SQLite como Fuente Única de Verdad (SSOT) con latencia cero.
- **Segundo Plano Robusto:** Integración con `flutter_foreground_task` y canal nativo de notificaciones con barra de progreso interactiva y alarmas exactas.

### Problemas Identificados
1. **Apilamiento de sesiones activas (Stacking Bug):**
   - Falta de `PopScope` en `ActiveWorkoutScreen`. Al dar atrás, se hace `Navigator.pop()` pero la sesión permanece `'active'` en SQLite.
   - En `WorkoutHomeScreen`, el botón principal sigue permitiendo *"Iniciar Entrenamiento"*, creando múltiples sesiones activas huérfanas.
   - `watchActiveSession()` une mediante `JOIN` todas las filas activas sin discriminar por `sessionId`, mezclando sets de diferentes entrenamientos en un único objeto visual.
   - Al desmontar la pantalla, `dispose()` detiene el servicio en segundo plano aunque la sesión siga viva en base de datos.
2. **Falta de límites y validaciones numéricas:**
   - `MetricStepperInput` y los formularios de ejercicio permiten entradas arbitrarias de peso y reps (ej. `99999999`), provocando desbordes visuales y cálculos erróneos de volumen acumulado.
3. **Fricción cognitiva de UX (Grupo muscular manual):**
   - Se fuerza al usuario a clasificar la anatomía de cada ejercicio mediante un dropdown obligatorio.
4. **Tiempos de descanso rígidos:**
   - La creación de ejercicios impone un dropdown cerrado (`[45, 60, 90, 120, 180]`), impidiendo descansos personalizados o descansos de 0s (clave para circuitos y super series).
5. **Comportamiento en la última serie:**
   - Al terminar el último set de la rutina, se activa un descanso de 90s hacia un ejercicio nulo, en lugar de ofrecer finalizar la sesión.
6. **Ausencia de pantalla de resultados (Summary / Reward Loop):**
   - Al finalizar, la app simplemente redirige a la pantalla de inicio sin mostrar estadísticas, volumen total, récords ni felicitación al usuario.
7. **Falta de soporte para Super Series y Bloques de Ejercicios:**
   - El modelo actual sólo contempla series lineales consecutivas por ejercicio ($A_1 \to A_2 \to A_3 \to B_1 \to \dots$), sin soporte para rondas ($A_1 \to B_1 \to \text{Descanso} \to A_2 \to B_2$).
8. **Falta de reordenamiento en el editor:**
   - Los ejercicios se muestran en una lista estática sin soporte drag-and-drop (`ReorderableListView`).

---

## 2. Fases de Implementación y Prioridades

### Fase 1: Estabilidad Core & Integridad de Datos (Prioridad Crítica)
- [x] **1.1 Resolver Bug de Sesiones Apiladas:**
  - Agregar `PopScope` en `ActiveWorkoutScreen` para gestionar la salida del usuario (Minimizar vs Cancelar).
  * En `WorkoutRepositoryImpl`, asegurar que sólo exista **una** sesión activa en la base de datos (cancelar/cerrar automáticamente sesiones activas previas o huérfanas al iniciar una nueva).
  * Corregir la consulta reactiva `watchActiveSession()` para filtrar estrictamente los sets pertenecientes a la sesión activa más reciente.
  * Actualizar `WorkoutHomeScreen` y `RoutineOverviewCard`: si hay una sesión activa, el botón principal debe cambiar dinámicamente a *"Reanudar Entrenamiento"* con redirección a la sesión en curso.
  * Ajustar el ciclo de vida de `WorkoutForegroundService` para que no se apague accidentalmente al minimizar la pantalla si la sesión sigue en curso.
- [x] **1.2 Límites y Validación de Entradas Numéricas:**
  * Añadir `maxValue`, `minValue` y `maxLength` a `MetricStepperInput` (máx. 999.0 kg en peso, máx. 99 en reps).
  * Validar entradas en `AddExerciseSheet`.
- [ ] **1.3 Flujo de la Última Serie:**
  * Al completar la última serie de la sesión, no iniciar temporizador de descanso; desplegar diálogo de finalización directa.

### Fase 2: Pantalla de Resultados y Descansos Flexibles
- [ ] **2.1 Pantalla de Resultados (`WorkoutSummaryScreen`):**
  * Pantalla de celebración post-entreno con estadísticas:
    * Duración total formateada.
    * Volumen total movido (kg).
    * Cantidad de series y ejercicios completados.
    * Desglose por ejercicio con pesos y reps logrados.
    * Botón de cierre que limpia la navegación hacia la pantalla de inicio.
- [ ] **2.2 Descansos Flexibles:**
  * Permitir descansos de 0s y tiempos libres utilizando el selector de duración `RestTimePickerSheet`.

### Fase 3: Catálogo Inteligente y Reducción de Fricción de UX
- [ ] **3.1 Catálogo Base de Ejercicios:**
  * Lista predefinida de ~50 ejercicios estándar agrupados por músculo.
  * Autocompletado en el nombre del ejercicio que asigna automáticamente el grupo muscular.
  * Opción de "General / Otro" para ejercicios personalizados desconocidos.

### Fase 4: Super Series y Bloques de Ejercicios
- [ ] **4.1 Extensión del Modelo de Datos:**
  * Atributos de bloque/grupo en `RoutineExercises` y `SetRecords` (`groupId`, `groupOrder`, `roundNumber`).
- [ ] **4.2 Generador de Series por Rondas:**
  * Intercalar las series de los ejercicios agrupados ($A_1 \to B_1 \to \text{Descanso} \to A_2 \to B_2 \to \dots$).
- [ ] **4.3 UI de Super Series:**
  * Visualización clara del bloque, número de ronda y transición sin descanso entre ejercicios del mismo bloque.

### Fase 5: Reordenamiento y Pulido de Interfaz
- [ ] **5.1 Reordenamiento Drag & Drop:**
  * Implementación de `ReorderableListView` en `RoutineEditorScreen`.
- [ ] **5.2 Micro-animaciones y Estética:**
  * Pulido visual, transiciones y alertas sonoras/hápticas.
