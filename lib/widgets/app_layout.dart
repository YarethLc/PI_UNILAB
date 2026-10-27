import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/constants/app_colors.dart';
import '../services/auth_session_service.dart';
import 'app_page_scroll_view.dart';
import 'custom_footer.dart';

class NavItem {
  final String title;
  final IconData icon;
  final String route;
  final List<String> allowedRoles; // 'ADMINISTRADOR', 'LABORATORIO', 'USUARIO'
  final String? section;

  const NavItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.allowedRoles,
    this.section,
  });
}

class AppLayout extends StatefulWidget {
  final String currentRoute;
  final String title;
  final String? subtitle;
  final Widget child;
  final bool mobilePageOwnsScroll;

  const AppLayout({
    super.key,
    required this.currentRoute,
    required this.title,
    this.subtitle,
    required this.child,
    this.mobilePageOwnsScroll = false,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  static const List<NavItem> allNavItems = [
    // --- INICIO COMPARTIDO ---
    NavItem(
      title: 'Inicio',
      icon: Icons.home_outlined,
      route: '/home',
      allowedRoles: [
        'USUARIO',
        'ESTUDIANTE',
        'EGRESADO',
        'ADMINISTRADOR',
        'LABORATORIO',
      ],
    ),

    // --- ESTUDIANTE / EGRESADO / USUARIO ---
    NavItem(
      title: 'Espacios',
      icon: Icons.meeting_room_outlined,
      route: '/user/spaces',
      allowedRoles: ['USUARIO', 'ESTUDIANTE', 'EGRESADO'],
    ),
    NavItem(
      title: 'Solicitar reserva',
      icon: Icons.add_circle_outline,
      route: '/user/wizard',
      allowedRoles: ['USUARIO', 'ESTUDIANTE', 'EGRESADO'],
    ),
    NavItem(
      title: 'Mis reservas',
      icon: Icons.calendar_today_outlined,
      route: '/user/my-reservations',
      allowedRoles: ['USUARIO', 'ESTUDIANTE', 'EGRESADO'],
    ),
    NavItem(
      title: 'Historial reservas',
      icon: Icons.history,
      route: '/user/history',
      allowedRoles: ['USUARIO', 'ESTUDIANTE', 'EGRESADO'],
      section: 'Actividades',
    ),
    NavItem(
      title: 'Registrar asistencia',
      icon: Icons.qr_code_scanner,
      route: '/user/attendance',
      allowedRoles: ['ESTUDIANTE'],
      section: 'Actividades',
    ),

    // --- ADMINISTRADOR ---
    NavItem(
      title: 'Gestionar reservas',
      icon: Icons.assignment_turned_in_outlined,
      route: '/admin/reservations',
      allowedRoles: ['ADMINISTRADOR'],
      section: 'Administración',
    ),
    NavItem(
      title: 'Gestionar espacios',
      icon: Icons.room_preferences_outlined,
      route: '/admin/spaces',
      allowedRoles: ['ADMINISTRADOR', 'LABORATORIO'],
      section: 'Administración',
    ),
    NavItem(
      title: 'Gestionar horarios',
      icon: Icons.schedule_outlined,
      route: '/admin/schedules',
      allowedRoles: ['ADMINISTRADOR'],
      section: 'Administración',
    ),
    NavItem(
      title: 'Estadísticas y reportes',
      icon: Icons.bar_chart_outlined,
      route: '/admin/reports',
      allowedRoles: ['ADMINISTRADOR'],
      section: 'Administración',
    ),
    NavItem(
      title: 'Usuarios',
      icon: Icons.people_outline,
      route: '/admin/users',
      allowedRoles: ['ADMINISTRADOR'],
      section: 'Administración',
    ),

    // --- LABORATORIO ---
    NavItem(
      title: 'Reservas asignadas',
      icon: Icons.biotech_outlined,
      route: '/lab/reservations',
      allowedRoles: ['LABORATORIO'],
      section: 'Laboratorio',
    ),

    // --- PERFIL (COMÚN) ---
    NavItem(
      title: 'Perfil',
      icon: Icons.person_outline,
      route: '/user/profile',
      allowedRoles: [
        'USUARIO',
        'ESTUDIANTE',
        'EGRESADO',
        'ADMINISTRADOR',
        'LABORATORIO'
      ],
      section: 'Cuenta',
    ),
  ];

  String _formatUserRole(String rol, String tipo) {
    final r = rol.toUpperCase();
    final t = tipo.toUpperCase();
    if (r == 'ADMINISTRADOR') return 'Administrador del Sistema';
    if (r == 'LABORATORIO') return 'Encargado de Laboratorio';
    if (t == 'EGRESADO') return 'Egresado UCEVA';
    return 'Estudiante UCEVA';
  }

  bool _isNavItemAllowed(NavItem item, String role, String type) {
    final allowed = item.allowedRoles.map((value) => value.toUpperCase());

    if (item.route == '/home' || item.route == '/user/profile') {
      return true;
    }

    if (role == 'ADMINISTRADOR' || role == 'LABORATORIO') {
      return allowed.contains(role);
    }

    if (role == 'USUARIO') {
      return allowed.contains(role) || allowed.contains(type);
    }

    return allowed.contains(role) || allowed.contains(type);
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthSessionService();
    final user = session.currentUser;
    final userRole = session.currentRole;
    final userTipo = session.currentTipo;

    // Filtrar únicamente los ítems permitidos para este usuario
    final allowedNavItems = allNavItems
        .where((item) => _isNavItemAllowed(item, userRole, userTipo))
        .toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final isWebDesktop = kIsWeb && isDesktop;
    final roleDescription =
        user != null ? _formatUserRole(userRole, userTipo) : 'Sesión activa';

    if (!isDesktop) {
      // Móvil / Tablet
      return Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.subtitle ??
                    (user != null
                        ? '${user.nombres} · $roleDescription'
                        : roleDescription),
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreenSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    userRole.isNotEmpty ? userRole : 'USUARIO',
                    style: const TextStyle(
                        color: AppColors.accentGreenText,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: AppColors.primaryGreen,
          child: _buildSidebarContent(
              context, allowedNavItems, user, roleDescription),
        ),
        body: SafeArea(
          child: widget.mobilePageOwnsScroll
              ? widget.child
              : CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: AppBanner()),
                    SliverToBoxAdapter(child: widget.child),
                    const SliverToBoxAdapter(child: CustomFooter()),
                  ],
                ),
        ),
      );
    }

    // Escritorio con Marco Fluido y Sidebar
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: Container(
          constraints:
              isWebDesktop ? null : const BoxConstraints(maxWidth: 1240),
          width: double.infinity,
          margin: isWebDesktop
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.frameBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.frameOutline, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sidebar
              Container(
                width: 240,
                color: AppColors.primaryGreen,
                child: _buildSidebarContent(
                    context, allowedNavItems, user, roleDescription),
              ),
              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    const AppBanner(),
                    // Topbar
                    _buildDesktopTopbar(
                        user?.fullName ?? 'Usuario', roleDescription, userRole),
                    // Content
                    Expanded(
                      child: Container(
                        color: AppColors.frameBg,
                        child: widget.child,
                      ),
                    ),
                    // Pie de página
                    const CustomFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTopbar(
      String userName, String roleDescription, String roleName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.topbarBorder, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.topbarTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle ?? '$userName · $roleDescription',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.topbarSubtitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentGreenSoft,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: AppColors.accentGreenText.withValues(alpha: 0.2)),
            ),
            child: Text(
              roleName.isNotEmpty ? 'ROL: $roleName' : 'SESIÓN ACTIVA',
              style: const TextStyle(
                color: AppColors.accentGreenText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(
    BuildContext context,
    List<NavItem> allowedItems,
    dynamic user,
    String roleDescription,
  ) {
    String? currentHeading;

    return Column(
      children: [
        // Brand Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/uceva-imagotipo.png',
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Row(
                  children: [
                    Icon(Icons.account_balance, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'UCEVA',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'LabAcces',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                roleDescription,
                style: const TextStyle(
                  color: AppColors.sidebarTagline,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        // Nav Links estrictamente filtrados por rol
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            children: [
              for (final item in allowedItems) ...[
                if (item.section != null && item.section != currentHeading) ...[
                  Builder(builder: (_) {
                    currentHeading = item.section;
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 12, top: 16, bottom: 6),
                      child: Text(
                        item.section!.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.sidebarHeading,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    );
                  }),
                ],
                _buildNavItem(context, item),
              ],
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        // Logout Button
        Padding(
          padding: const EdgeInsets.all(12),
          child: InkWell(
            onTap: () async {
              await AuthSessionService().clearSession();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.white70, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Cerrar sesión',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, NavItem item) {
    final isActive = item.route == '/home'
        ? const {'/user/home', '/admin/dashboard', '/lab/dashboard'}
            .contains(widget.currentRoute)
        : widget.currentRoute == item.route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.currentRoute != item.route) {
              Navigator.pushReplacementNamed(context, item.route);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: isActive
                      ? Colors.white
                      : AppColors.sidebarText.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.sidebarText,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
