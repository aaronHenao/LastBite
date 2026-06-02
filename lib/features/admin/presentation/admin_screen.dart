import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';

// ── Modelos ───────────────────────────────────────────────────────────────────

class _UsuarioPerfil {
  final String uid;
  final String nombre;
  final String email;
  final String status;
  final String role;

  _UsuarioPerfil({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.status,
    required this.role,
  });

  factory _UsuarioPerfil.fromMap(String uid, Map<String, dynamic> data) {
    return _UsuarioPerfil(
      uid: uid,
      nombre: data['name'] as String? ?? 'Sin nombre',
      email: data['email'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      role: data['role'] as String? ?? 'active',
    );
  }
}

class _EstadisticasGlobales {
  final int totalUsuarios;
  final int totalProductos;
  final int totalSalvados;
  final int totalUrgentes;

  _EstadisticasGlobales({
    required this.totalUsuarios,
    required this.totalProductos,
    required this.totalSalvados,
    required this.totalUrgentes,
  });
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _usuariosProvider = FutureProvider<List<_UsuarioPerfil>>((ref) async {
  final snapshot =
      await FirebaseFirestore.instance.collection('users').get();
  return snapshot.docs
      .map((doc) => _UsuarioPerfil.fromMap(doc.id, doc.data()))
      .toList();
});

final _estadisticasGlobalesProvider =
    FutureProvider<_EstadisticasGlobales>((ref) async {
  final usuarios = await ref.watch(_usuariosProvider.future);
  int totalProductos = 0;
  int totalSalvados = 0;
  int totalUrgentes = 0;

  final db = FirebaseFirestore.instance;

  for (final usuario in usuarios) {
    try {
      final productos =
          await db.collection('users').doc(usuario.uid).collection('productos').get();
      totalProductos += productos.docs.length;

      final ahora = DateTime.now();
      for (final doc in productos.docs) {
        final fechaStr = doc.data()['fechaCaducidad'] as String?;
        if (fechaStr != null) {
          final fecha = DateTime.tryParse(fechaStr);
          if (fecha != null) {
            final dias = fecha.difference(ahora).inDays;
            if (dias >= 0 && dias <= 3) totalUrgentes++;
          }
        }
      }

      final stats = await db
          .collection('users')
          .doc(usuario.uid)
          .collection('estadisticas')
          .doc('resumen')
          .get();
      if (stats.exists) {
        totalSalvados += (stats.data()?['salvados'] as int?) ?? 0;
      }
    } catch (_) {}
  }

  return _EstadisticasGlobales(
    totalUsuarios: usuarios.length,
    totalProductos: totalProductos,
    totalSalvados: totalSalvados,
    totalUrgentes: totalUrgentes,
  );
});

// ── Pantalla principal ────────────────────────────────────────────────────────

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PANEL ADMIN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.4,
                          color: AppColors.textMuted,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await ref.read(authServiceProvider).cerrarSesion();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, size: 14, color: AppColors.danger),
                              const SizedBox(width: 4),
                              Text(
                                'Salir',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Administración 🛠️',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textMuted,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Estadísticas'),
                        Tab(text: 'Usuarios'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Contenido
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _EstadisticasTab(),
                  _UsuariosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Estadísticas ──────────────────────────────────────────────────────────

class _EstadisticasTab extends ConsumerWidget {
  const _EstadisticasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(_estadisticasGlobalesProvider);

    return stats.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 12),
            Text('Error al cargar estadísticas',
                style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(_estadisticasGlobalesProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (s) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cards de estadísticas
            Row(
              children: [
                _StatCard(
                  icon: Icons.people_rounded,
                  value: '${s.totalUsuarios}',
                  label: 'Usuarios',
                  color: AppColors.green,
                  bg: AppColors.green.withValues(alpha: 0.12),
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: CupertinoIcons.archivebox,
                  value: '${s.totalProductos}',
                  label: 'Productos',
                  color: AppColors.textMain,
                  bg: AppColors.surface,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatCard(
                  icon: CupertinoIcons.check_mark_circled,
                  value: '${s.totalSalvados}',
                  label: 'Salvados',
                  color: AppColors.green,
                  bg: AppColors.green.withValues(alpha: 0.12),
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: CupertinoIcons.clock,
                  value: '${s.totalUrgentes}',
                  label: 'Urgentes',
                  color: AppColors.accent,
                  bg: AppColors.accent.withValues(alpha: 0.12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Impacto ambiental estimado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌍', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        'Impacto global',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ImpactoRow(
                    label: 'CO₂ evitado (est.)',
                    value: '${(s.totalSalvados * 2.5).toStringAsFixed(1)} kg',
                  ),
                  const SizedBox(height: 6),
                  _ImpactoRow(
                    label: 'Agua ahorrada (est.)',
                    value: '${(s.totalSalvados * 1.8).toStringAsFixed(1)} L',
                  ),
                  const SizedBox(height: 6),
                  _ImpactoRow(
                    label: 'Alimentos aprovechados',
                    value: '${s.totalSalvados} productos',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Botón refrescar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.invalidate(_estadisticasGlobalesProvider);
                  ref.invalidate(_usuariosProvider);
                },
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.textMuted),
                label: const Text(
                  'Actualizar datos',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactoRow extends StatelessWidget {
  final String label;
  final String value;
  const _ImpactoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.green)),
      ],
    );
  }
}

// ── Tab Usuarios ──────────────────────────────────────────────────────────────

class _UsuariosTab extends ConsumerWidget {
  const _UsuariosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarios = ref.watch(_usuariosProvider);

    return usuarios.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 12),
            const Text('Error al cargar usuarios'),
            TextButton(
              onPressed: () => ref.invalidate(_usuariosProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (lista) {
        if (lista.isEmpty) {
          return const Center(
            child: Text('No hay usuarios registrados.',
                style: TextStyle(color: AppColors.textMuted)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          itemCount: lista.length,
          itemBuilder: (context, i) => _UsuarioCard(
            usuario: lista[i],
            onCambiarStatus: (nuevoStatus) async {
              await _cambiarStatus(context, ref, lista[i], nuevoStatus);
            },
          ),
        );
      },
    );
  }

  Future<void> _cambiarStatus(
    BuildContext context,
    WidgetRef ref,
    _UsuarioPerfil usuario,
    String nuevoStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .update({'status': nuevoStatus});
      ref.invalidate(_usuariosProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${usuario.nombre} → $nuevoStatus'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar usuario'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

class _UsuarioCard extends StatefulWidget {
  final _UsuarioPerfil usuario;
  final ValueChanged<String> onCambiarStatus;

  const _UsuarioCard({
    required this.usuario,
    required this.onCambiarStatus,
  });

  @override
  State<_UsuarioCard> createState() => _UsuarioCardState();
}

class _UsuarioCardState extends State<_UsuarioCard> {
  bool _procesando = false;

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;
    final onCambiarStatus = (String nuevoStatus) async {
      if (_procesando) return;
      setState(() => _procesando = true);
      try {
        widget.onCambiarStatus(nuevoStatus);
      } finally {
        if (mounted) setState(() => _procesando = false);
      }
    };
    final statusColor = _statusColor(usuario.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surface,
                child: Text(
                  usuario.nombre.isNotEmpty
                      ? usuario.nombre[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      usuario.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge status
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  usuario.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Badge rol
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rol: ${usuario.role}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              // Botones de acción
              if (usuario.status != 'active')
                _ActionButton(
                  label: 'Activar',
                  color: AppColors.green,
                  disabled: _procesando,
                  onTap: () => onCambiarStatus('active'),
                ),
              if (usuario.status != 'blocked') ...[
                const SizedBox(width: 6),
                _ActionButton(
                  label: 'Bloquear',
                  color: AppColors.danger,
                  disabled: _procesando,
                  onTap: () => onCambiarStatus('blocked'),
                ),
              ],
              if (usuario.status != 'pendingApproval') ...[
                const SizedBox(width: 6),
                _ActionButton(
                  label: 'Pendiente',
                  color: AppColors.yellow,
                  disabled: _procesando,
                  onTap: () => onCambiarStatus('pendingApproval'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.green;
      case 'blocked':
        return AppColors.danger;
      case 'pendingApproval':
        return AppColors.yellow;
      default:
        return AppColors.textMuted;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
      ),
    );
  }
}

// ── Widgets compartidos ───────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
