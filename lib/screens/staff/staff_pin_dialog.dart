import 'package:flutter/material.dart';

import '../../data/kiosk_config.dart';
import '../../theme/app_theme.dart';

/// Shows a numeric-keypad PIN prompt. Resolves `true` once the staff PIN is
/// entered correctly, `null`/`false` if cancelled.
Future<bool?> showStaffPinDialog(BuildContext context, {String title = 'Code équipe'}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _StaffPinDialog(title: title),
  );
}

class _StaffPinDialog extends StatefulWidget {
  const _StaffPinDialog({required this.title});

  final String title;

  @override
  State<_StaffPinDialog> createState() => _StaffPinDialogState();
}

class _StaffPinDialogState extends State<_StaffPinDialog> {
  String _entered = '';
  bool _error = false;

  void _press(String digit) {
    if (_entered.length >= KioskConfig.staffPin.length) return;
    setState(() {
      _error = false;
      _entered += digit;
    });
    if (_entered.length == KioskConfig.staffPin.length) {
      final ok = _entered == KioskConfig.staffPin;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _error = true);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _entered = '');
        });
      }
    }
  }

  void _backspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: AppColors.surfaceAlt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('Réservé à l\'équipe', style: textTheme.bodyMedium),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(KioskConfig.staffPin.length, (i) {
                final filled = i < _entered.length;
                return Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _error ? AppColors.red : (filled ? AppColors.orange : Colors.transparent),
                    border: Border.all(color: _error ? AppColors.red : AppColors.creamMuted.withValues(alpha: 0.5)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              child: Column(
                children: [
                  for (final row in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: row.map((d) => _KeypadButton(label: d, onTap: () => _press(d))).toList(),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 72, height: 72),
                      _KeypadButton(label: '0', onTap: () => _press('0')),
                      _KeypadButton(icon: Icons.backspace_outlined, onTap: _backspace),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.charcoalSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(
            child: label != null
                ? Text(label!, style: Theme.of(context).textTheme.headlineSmall)
                : Icon(icon, color: AppColors.cream),
          ),
        ),
      ),
    );
  }
}
