import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

/// Un client fidélité connecté sur la borne, le temps d'une commande.
class LoyaltyMember {
  const LoyaltyMember({required this.uid, required this.username, required this.points});

  final String uid;
  final String username;
  final int points;

  LoyaltyMember copyWith({int? points}) => LoyaltyMember(uid: uid, username: username, points: points ?? this.points);
}

class LoyaltyException implements Exception {
  const LoyaltyException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Un palier de récompense — mêmes documents `rewardTiers` que l'application.
class RewardTier {
  const RewardTier({required this.points, required this.label, required this.iconKey});

  final int points;
  final String label;
  final String iconKey;

  IconData get icon => switch (iconKey) {
        'dessert' => Icons.cake_rounded,
        'bowl' => Icons.ramen_dining_rounded,
        _ => Icons.set_meal_rounded,
      };

  factory RewardTier.fromMap(Map<String, dynamic> map) => RewardTier(
        points: (map['points'] as num).toInt(),
        label: map['label'] as String,
        iconKey: map['icon'] as String? ?? 'meal',
      );
}

/// Les MÊMES comptes que l'application mobile (pseudo + mot de passe, voir
/// `pseudoEmailFor` dans click_collect_app/lib/state/app_state.dart — les
/// deux fonctions doivent rester identiques).
String pseudoEmailFor(String username) {
  final normalized = username.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '-');
  return '$normalized@pseudo.no-reply.invalid';
}

String _authErrorMessage(FirebaseAuthException e) => switch (e.code) {
      'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Pseudo ou mot de passe incorrect.',
      'email-already-in-use' => 'Ce pseudo est déjà pris.',
      'weak-password' => 'Mot de passe trop faible.',
      'invalid-email' => 'Pseudo invalide — au moins 3 caractères (lettres, chiffres).',
      'too-many-requests' => 'Trop de tentatives — réessayez dans quelques minutes.',
      'network-request-failed' => 'Pas de connexion internet.',
      _ => e.message ?? 'Une erreur est survenue.',
    };

/// Connexion d'un client fidélité sur la borne.
///
/// La borne garde SA session anonyme (celle qui écrit les commandes) sur
/// l'app Firebase par défaut. Le client, lui, se connecte sur une SECONDE
/// instance Firebase nommée "loyalty" : on lit et met à jour son profil
/// `users/{uid}` exactement comme le fait l'application (les règles
/// Firestore ne l'autorisent qu'au propriétaire du compte), sans jamais
/// toucher à la session de la borne. [signOut] est appelé à la fin de
/// chaque commande et quand la borne revient à l'accueil.
class LoyaltyService {
  const LoyaltyService._();

  static FirebaseApp? _app;

  static Future<FirebaseApp> _loyaltyApp() async {
    if (_app != null) return _app!;
    try {
      _app = Firebase.app('loyalty');
    } catch (_) {
      _app = await Firebase.initializeApp(name: 'loyalty', options: DefaultFirebaseOptions.currentPlatform);
    }
    return _app!;
  }

  static Future<FirebaseAuth> _auth() async => FirebaseAuth.instanceFor(app: await _loyaltyApp());
  static Future<FirebaseFirestore> _db() async => FirebaseFirestore.instanceFor(app: await _loyaltyApp());

  static Future<LoyaltyMember> signIn({required String username, required String password}) async {
    try {
      final credential = await (await _auth()).signInWithEmailAndPassword(
        email: pseudoEmailFor(username),
        password: password,
      );
      final uid = credential.user!.uid;
      final data = (await (await _db()).collection('users').doc(uid).get()).data();
      return LoyaltyMember(
        uid: uid,
        username: data?['username'] as String? ?? username.trim(),
        points: (data?['points'] as num?)?.toInt() ?? 0,
      );
    } on FirebaseAuthException catch (e) {
      throw LoyaltyException(_authErrorMessage(e));
    } on FirebaseException catch (_) {
      throw const LoyaltyException('Connexion au serveur impossible — réessayez.');
    }
  }

  /// Crée un compte (le même que dans l'application) directement sur la borne.
  static Future<LoyaltyMember> signUp({required String username, required String password}) async {
    try {
      final credential = await (await _auth()).createUserWithEmailAndPassword(
        email: pseudoEmailFor(username),
        password: password,
      );
      final uid = credential.user!.uid;
      await (await _db()).collection('users').doc(uid).set({'username': username.trim(), 'points': 0});
      return LoyaltyMember(uid: uid, username: username.trim(), points: 0);
    } on FirebaseAuthException catch (e) {
      throw LoyaltyException(_authErrorMessage(e));
    } on FirebaseException catch (_) {
      throw const LoyaltyException('Connexion au serveur impossible — réessayez.');
    }
  }

  /// Ajoute [delta] points (négatif pour dépenser), atomiquement, et renvoie
  /// le nouveau solde — même transaction que UserRepository.adjustPoints
  /// côté application.
  static Future<int> adjustPoints(String uid, int delta) async {
    final db = await _db();
    final ref = db.collection('users').doc(uid);
    return db.runTransaction<int>((tx) async {
      final snapshot = await tx.get(ref);
      final next = ((snapshot.data()?['points'] as num?)?.toInt() ?? 0) + delta;
      tx.update(ref, {'points': next});
      return next;
    });
  }

  static Future<void> signOut() async {
    if (_app == null) return;
    try {
      await FirebaseAuth.instanceFor(app: _app!).signOut();
    } catch (_) {}
  }

  /// Paliers de récompense (lecture publique, via l'app Firebase par défaut).
  static Future<List<RewardTier>> fetchRewardTiers() async {
    final snapshot = await FirebaseFirestore.instance.collection('rewardTiers').orderBy('order').get();
    return snapshot.docs.map((d) => RewardTier.fromMap(d.data())).toList();
  }
}
