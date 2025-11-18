import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api/core/auth.dart';
import 'api/core/user_session_provider.dart';
import 'widgets/custom_header.dart';
import 'utils/responsive_utils.dart';

class AppColors {
  static const universityBlue = Color.fromARGB(255, 36, 118, 212);
  static const universityPurple = Color.fromARGB(255, 137, 99, 207);
  static const universityLightBlue = Color.fromARGB(255, 72, 136, 165);
  static const backgroundLight = Color(0xFFF3F4F6);
}

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConfiguracionPageContent();
  }
}

class ConfiguracionPageContent extends StatefulWidget {
  const ConfiguracionPageContent({super.key});

  @override
  State<ConfiguracionPageContent> createState() => _ConfiguracionPageContentState();
}

class _ConfiguracionPageContentState extends State<ConfiguracionPageContent> {
  @override
  Widget build(BuildContext context) {
    final userSession = Provider.of<UserSessionProvider>(context).session;
    final auth = Provider.of<AuthService>(context, listen: false);
    
    final hPadding = context.horizontalPadding;
    final vPadding = context.verticalPadding;
    final spacing = ResponsiveUtils.getSpacing(context, 16);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const ProfessorHeader(title: "Configuración"),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: hPadding,
                  right: hPadding,
                  top: vPadding,
                  bottom: MediaQuery.of(context).padding.bottom + vPadding + 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del usuario
                    _buildUserInfoCard(context, userSession),
                    
                    SizedBox(height: spacing * 1.5),
                    
                    // Sección de cuenta
                    _buildSectionTitle(context, 'Cuenta'),
                    SizedBox(height: spacing * 0.5),
                    _buildSettingsCard(
                      context,
                      [
                        _buildSettingItem(
                          context,
                          icon: Icons.person_outline,
                          title: 'Perfil',
                          subtitle: userSession?.email ?? 'Sin correo',
                          color: AppColors.universityBlue,
                          onTap: () {
                            // TODO: Navegar a perfil
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingItem(
                          context,
                          icon: Icons.badge_outlined,
                          title: 'Tipo de usuario',
                          subtitle: userSession?.isFacilitador == true ? 'Profesor' : 'Estudiante',
                          color: AppColors.universityPurple,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: spacing * 1.5),
                    
                    // Sección de aplicación
                    _buildSectionTitle(context, 'Aplicación'),
                    SizedBox(height: spacing * 0.5),
                    _buildSettingsCard(
                      context,
                      [
                        _buildSettingItem(
                          context,
                          icon: Icons.info_outline,
                          title: 'Acerca de',
                          subtitle: 'Versión 1.0.0',
                          color: AppColors.universityLightBlue,
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                      ],
                    ),
                    
                    SizedBox(height: spacing * 2),
                    
                    // Botón de cerrar sesión
                    _buildLogoutButton(context, auth),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, dynamic userSession) {
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
    final iconSize = ResponsiveUtils.getIconSize(context, 40);
    final nameSize = ResponsiveUtils.getFontSize(context, 20);
    final emailSize = ResponsiveUtils.getFontSize(context, 14);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.universityBlue,
            AppColors.universityPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.universityBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 16),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userSession?.name ?? 'Usuario',
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userSession?.email ?? 'Sin correo',
                  style: TextStyle(
                    fontSize: emailSize,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 16);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final iconSize = ResponsiveUtils.getIconSize(context, 24);
    final titleSize = ResponsiveUtils.getFontSize(context, 15);
    final subtitleSize = ResponsiveUtils.getFontSize(context, 13);
    
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.grey.shade600,
              ),
            )
          : null,
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: Colors.grey.shade400)
          : null,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthService auth) {
    final buttonFontSize = ResponsiveUtils.getFontSize(context, 16);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Mostrar diálogo de confirmación
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cerrar Sesión'),
              content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
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
                  ),
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            // Cerrar sesión
            await auth.logout();
            
            // Limpiar provider
            if (context.mounted) {
              context.read<UserSessionProvider>().clearSession();
              
              // Regresar al login
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            'Cerrar Sesión',
            style: TextStyle(
              fontSize: buttonFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade200),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.school, color: AppColors.universityBlue),
            SizedBox(width: 12),
            Text('UTB Assists'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistema de Asistencias',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('Versión 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Desarrollado para la Universidad Tecnológica de Bolívar',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
