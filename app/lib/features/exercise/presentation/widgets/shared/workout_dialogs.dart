import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

abstract final class WorkoutDialogs {
  static void confirmFinish({
    required BuildContext context,
    required VoidCallback onConfirm,
    bool isAllCompleted = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAllCompleted ? '¡Entrenamiento Completado!' : '¿Finalizar Entrenamiento?'),
        content: Text(
          isAllCompleted
              ? 'Has completado todas las series. ¿Listo para guardar y terminar?'
              : 'Se guardará el volumen y tiempos de tu sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAllCompleted ? 'Revisar' : 'Continuar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  static void confirmCancel({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar Entrenamiento?'),
        content: const Text('La sesión quedará registrada como cancelada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancelar sesión'),
          ),
        ],
      ),
    );
  }

  static void confirmCancelRest({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar Descanso?'),
        content: const Text(
          'La serie volverá a quedar pendiente y no se guardará ningún dato.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar descanso'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Deshacer serie'),
          ),
        ],
      ),
    );
  }

  static void confirmExitWorkout({
    required BuildContext context,
    required VoidCallback onMinimize,
    required VoidCallback onCancelWorkout,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir del Entrenamiento?'),
        content: const Text(
          'Puedes minimizar la sesión para continuar en segundo plano o cancelarla definitivamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onMinimize();
            },
            child: const Text('Minimizar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onCancelWorkout();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancelar sesión'),
          ),
        ],
      ),
    );
  }
}
