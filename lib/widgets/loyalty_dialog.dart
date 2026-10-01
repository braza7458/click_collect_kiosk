import 'package:flutter/material.dart';

import '../services/loyalty_service.dart';
import '../state/kiosk_state.dart';
import '../theme/app_theme.dart';
import 'ui.dart';

/// Connexion (ou création) du compte fidélité sur la borne — le même compte
/// que dans l'application mobile : un pseudo et un mot de passe.
Future<void> showLoyaltyDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: const _LoyaltyForm(),
      ),
    ),
  );
}

class _LoyaltyForm extends StatefulWidget {
  const _LoyaltyForm();

  @override
  State<_LoyaltyForm> createState() => _LoyaltyFormState();
}

class _LoyaltyFormState extends State<_LoyaltyForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _creating = false;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Mêmes exigences qu'à l'inscription dans l'application.
  String? _validate() {
    final u = _username.text.trim();
    final p = _password.text;
    if (u.length < 3) return 'Pseudo : au moins 3 caractères.';
    if (p.isEmpty) return 'Entrez votre mot de passe.';
    if (_creating) {
      if (p.length < 8) return 'Mot de passe : au moins 8 caractères.';
      if (!RegExp(r'\d').hasMatch(p)) return 'Mot de passe : au moins un chiffre.';
      if (!RegExp(r'[A-Z]').hasMatch(p)) return 'Mot de passe : au moins une majuscule.';
    }
    return null;
  }

  Future<void> _submit() async {
    final invalid = _validate();
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final member = _creating
          ? await LoyaltyService.signUp(username: _username.text, password: _password.text)
          : await LoyaltyService.signIn(username: _username.text, password: _password.text);
      if (!mounted) return;
      KioskStateScope.of(context).setMember(member);
      Navigator.of(context).pop();
    } on LoyaltyException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Connexion impossible — réessayez.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final earn = KioskStateScope.of(context).cartTotal.floor();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconBadge(Icons.workspace_premium_rounded, color: AppColors.honey),
              const SizedBox(width: 14),
              Expanded(child: Text('Mon compte fidélité', style: textTheme.headlineSmall)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            earn > 0
                ? 'Le même compte que sur l\'application. Cette commande vous rapporte $earn points.'
                : 'Le même compte que sur l\'application : 1 € dépensé = 1 point.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('J\'ai un compte'), icon: Icon(Icons.login_rounded)),
              ButtonSegment(value: true, label: Text('Créer un compte'), icon: Icon(Icons.person_add_rounded)),
            ],
            selected: {_creating},
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.orange,
              selectedForegroundColor: AppColors.charcoal,
              foregroundColor: AppColors.cream,
              minimumSize: const Size(0, 52),
            ),
            onSelectionChanged: (v) => setState(() {
              _creating = v.first;
              _error = null;
            }),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _username,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            style: textTheme.titleMedium,
            decoration: const InputDecoration(labelText: 'Pseudo', prefixIcon: Icon(Icons.person_outline_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure,
            onSubmitted: (_) => _submit(),
            style: textTheme.titleMedium,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
          ),
          if (_creating) ...[
            const SizedBox(height: 8),
            Text(
              '8 caractères minimum, avec un chiffre et une majuscule. Ni e-mail ni téléphone demandés.',
              style: textTheme.bodySmall,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: textTheme.bodyMedium?.copyWith(color: AppColors.red)),
          ],
          const SizedBox(height: 20),
          GlowButton(
            label: _creating ? 'Créer mon compte' : 'Me connecter',
            icon: _creating ? Icons.person_add_rounded : Icons.login_rounded,
            busy: _busy,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
          Text(
            'Vous serez déconnecté automatiquement à la fin de la commande.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Encadré fidélité du récapitulatif : invitation à se connecter, ou solde,
/// points gagnés et choix d'une récompense.
class LoyaltyPanel extends StatelessWidget {
  const LoyaltyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final kiosk = KioskStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final member = kiosk.member;

    if (member == null) {
      return GlassCard(
        radius: AppRadius.xl,
        padding: const EdgeInsets.all(22),
        borderColor: AppColors.honey.withValues(alpha: 0.4),
        child: Row(
          children: [
            const IconBadge(Icons.workspace_premium_rounded, color: AppColors.honey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gagnez ${kiosk.cartTotal.floor()} points fidélité', style: textTheme.titleMedium),
                  Text('Avec votre compte de l\'application (ou créez-le ici).', style: textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: () => showLoyaltyDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.honey,
                foregroundColor: AppColors.charcoal,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: const Text('Me connecter'),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(22),
      borderColor: AppColors.honey.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(Icons.workspace_premium_rounded, color: AppColors.honey),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bonjour ${member.username} !', style: textTheme.titleMedium),
                    Text(
                      '${member.points} points · +${kiosk.pointsToEarn} avec cette commande',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.honey),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: kiosk.logoutMember,
                style: TextButton.styleFrom(foregroundColor: AppColors.creamMuted),
                child: const Text('Ce n\'est pas moi'),
              ),
            ],
          ),
          if (kiosk.rewardTiers.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Eyebrow('Utiliser une récompense (facultatif)', color: AppColors.honey),
            const SizedBox(height: 8),
            for (final tier in kiosk.rewardTiers)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RewardOption(
                  tier: tier,
                  unlocked: member.points >= tier.points,
                  missing: tier.points - member.points,
                  selected: kiosk.selectedReward == tier,
                  onTap: () => kiosk.toggleReward(tier),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _RewardOption extends StatelessWidget {
  const _RewardOption({
    required this.tier,
    required this.unlocked,
    required this.missing,
    required this.selected,
    required this.onTap,
  });

  final RewardTier tier;
  final bool unlocked;
  final int missing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: selected ? AppColors.honey.withValues(alpha: 0.16) : AppColors.charcoal.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: selected ? AppColors.honey : AppColors.glassBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: unlocked ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : (unlocked ? Icons.radio_button_unchecked : Icons.lock_outline_rounded),
                color: unlocked ? AppColors.honey : AppColors.creamMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 12),
              Icon(tier.icon, color: unlocked ? AppColors.cream : AppColors.creamMuted.withValues(alpha: 0.5), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tier.label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: unlocked ? AppColors.cream : AppColors.creamMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Text(unlocked ? '${tier.points} pts' : 'encore $missing pts', style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
