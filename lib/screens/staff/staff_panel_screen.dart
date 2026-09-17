import 'package:flutter/material.dart';

import '../../data/menu_data.dart';
import '../../services/kiosk_mode.dart';
import '../../state/kiosk_state.dart';
import '../../theme/app_theme.dart';

class StaffPanelScreen extends StatelessWidget {
  const StaffPanelScreen({super.key});

  Future<void> _confirmExit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Fermer le kiosque ?'),
        content: const Text(
          'Le terminal quittera le mode caisse. À ne faire qu\'en fin de service.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await exitKioskMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final kioskState = KioskStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final tickets = kioskState.todaysTickets;
    final dayTotal = tickets.fold(0.0, (sum, t) => sum + t.total);
    final dineIn = tickets.where((t) => t.mode == OrderMode.dineIn).length;
    final takeaway = tickets.where((t) => t.mode == OrderMode.takeaway).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace équipe'),
        actions: [
          TextButton.icon(
            onPressed: () => _confirmExit(context),
            icon: const Icon(Icons.power_settings_new, color: AppColors.red),
            label: const Text(
              'Fermer le kiosque',
              style: TextStyle(color: AppColors.red),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aujourd\'hui', style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatTile(label: 'Commandes', value: '${tickets.length}'),
                  const SizedBox(width: 12),
                  _StatTile(
                    label: 'Chiffre d\'affaires',
                    value: formatPrice(dayTotal),
                  ),
                  const SizedBox(width: 12),
                  _StatTile(
                    label: 'Sur place / à emporter',
                    value: '$dineIn / $takeaway',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Commandes du jour', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              tickets.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Aucune commande enregistrée pour le moment',
                        style: textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tickets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final t = tickets[i];
                        final hh = t.date.hour.toString().padLeft(2, '0');
                        final mm = t.date.minute.toString().padLeft(2, '0');
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.charcoalSoft,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${t.number}',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.orange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${t.mode.label} · $hh:$mm',
                                      style: textTheme.titleMedium,
                                    ),
                                    Text(
                                      '${t.itemCount} article${t.itemCount > 1 ? 's' : ''}',
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatPrice(t.total),
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.orange,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
