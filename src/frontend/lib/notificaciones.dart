import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api/notificacion_service.dart';
import 'api/core/user_session_provider.dart';
import 'models/notificacion.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  @override
  Widget build(BuildContext context) {
    final userEmail = context.watch<UserSessionProvider>().email;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.universityBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Consumer<NotificacionService>(
            builder: (context, service, _) {
              if (service.notificaciones.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => _showSettingsMenu(context, service, userEmail),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificacionService>(
        builder: (context, service, _) {
          if (service.notificaciones.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: service.notificaciones.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notificacion = service.notificaciones[index];
              return _buildNotificacionCard(notificacion, userEmail);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFED7D7).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Personaje durmiendo (emoji grande)
                  const Text(
                    '😴',
                    style: TextStyle(fontSize: 80),
                  ),
                  // Z's flotando
                  Positioned(
                    right: 30,
                    top: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildZLetter(12, 0),
                        const SizedBox(height: 4),
                        _buildZLetter(16, 100),
                        const SizedBox(height: 4),
                        _buildZLetter(20, 200),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "¡Todo al día!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Vuelve más tarde para ver recordatorios,\nsesiones asignadas y actualizaciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZLetter(double size, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000 + delayMs),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, -10 * value),
            child: Text(
              'z',
              style: TextStyle(
                fontSize: size,
                color: const Color(0xFF64748B).withOpacity(0.5),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingsMenu(BuildContext context, NotificacionService service, String email) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.done_all, color: AppColors.universityBlue),
              title: const Text('Marcar todas como leídas'),
              onTap: () async {
                Navigator.pop(context);
                await service.marcarTodasComoLeidas(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todas las notificaciones marcadas como leídas'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Limpiar todas', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Limpiar notificaciones'),
                    content: const Text('¿Estás seguro de que deseas eliminar todas las notificaciones?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );
                
                if (confirmar == true && mounted) {
                  await service.limpiarTodas(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificaciones eliminadas'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificacionCard(Notificacion notificacion, String email) {
    final notifConfig = _getNotificationConfig(notificacion.tipo);

    return Dismissible(
      key: Key(notificacion.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        context.read<NotificacionService>().eliminarNotificacion(email, notificacion.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notificación eliminada'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleNotificationTap(notificacion, email),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono con badge de punto si no está leída
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: notifConfig.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          notifConfig.icon,
                          color: notifConfig.color,
                          size: 24,
                        ),
                      ),
                      if (!notificacion.leida)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Contenido
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notificacion.titulo,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: notificacion.leida ? FontWeight.w500 : FontWeight.w700,
                                  color: const Color(0xFF1A202C),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            Text(
                              _formatearTiempoRelativo(notificacion.fecha),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notificacion.mensaje,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        if (notifConfig.hasActions) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildActionButton(
                                label: notifConfig.primaryAction ?? 'View',
                                isPrimary: true,
                                onTap: () => _handlePrimaryAction(notificacion, email),
                              ),
                              if (notifConfig.secondaryAction != null) ...[
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  label: notifConfig.secondaryAction!,
                                  isPrimary: false,
                                  onTap: () => _handleSecondaryAction(notificacion, email),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary 
              ? AppColors.universityBlue 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isPrimary 
              ? null 
              : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isPrimary 
                ? Colors.white 
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  NotificationConfig _getNotificationConfig(String tipo) {
    switch (tipo) {
      case 'sesion_cancelada':
        return NotificationConfig(
          icon: Icons.event_busy_rounded,
          color: const Color(0xFFEF4444),
          hasActions: false,
        );
      case 'sesion_asignada':
        return NotificationConfig(
          icon: Icons.event_available_rounded,
          color: const Color(0xFF10B981),
          hasActions: true,
          primaryAction: 'Ver',
          secondaryAction: 'Actualizar',
        );
      case 'recordatorio':
        return NotificationConfig(
          icon: Icons.notifications_active_rounded,
          color: const Color(0xFFF59E0B),
          hasActions: true,
          primaryAction: 'Abrir',
        );
      default:
        return NotificationConfig(
          icon: Icons.info_rounded,
          color: AppColors.universityBlue,
          hasActions: false,
        );
    }
  }

  String _formatearTiempoRelativo(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inSeconds < 60) {
      return 'ahora';
    } else if (diferencia.inMinutes < 60) {
      final mins = diferencia.inMinutes;
      return 'hace ${mins}m';
    } else if (diferencia.inHours < 24) {
      final hrs = diferencia.inHours;
      return 'hace ${hrs}h';
    } else if (diferencia.inDays == 1) {
      return 'ayer';
    } else if (diferencia.inDays < 7) {
      return 'hace ${diferencia.inDays}d';
    } else if (diferencia.inDays < 14) {
      return 'hace 1sem';
    } else {
      return '${fecha.day}/${fecha.month}';
    }
  }

  void _handleNotificationTap(Notificacion notificacion, String email) async {
    if (!notificacion.leida) {
      await context.read<NotificacionService>()
          .marcarComoLeida(email, notificacion.id);
    }
    
    // TODO: Navegar a la sesión si tiene datos
    if (notificacion.datos != null && notificacion.datos!['id_sesion'] != null) {
      // Navegar al detalle de la sesión
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abriendo sesión ${notificacion.datos!['id_sesion']}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _handlePrimaryAction(Notificacion notificacion, String email) {
    _handleNotificationTap(notificacion, email);
  }

  void _handleSecondaryAction(Notificacion notificacion, String email) async {
    if (!notificacion.leida) {
      await context.read<NotificacionService>()
          .marcarComoLeida(email, notificacion.id);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acción de actualización ejecutada'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class NotificationConfig {
  final IconData icon;
  final Color color;
  final bool hasActions;
  final String? primaryAction;
  final String? secondaryAction;

  NotificationConfig({
    required this.icon,
    required this.color,
    this.hasActions = false,
    this.primaryAction,
    this.secondaryAction,
  });
}
