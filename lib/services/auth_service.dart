import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connexion
  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // succès
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Aucun utilisateur trouvé avec cet email';
      } else if (e.code == 'wrong-password') {
        return 'Mot de passe incorrect';
      }
      return 'Erreur de connexion';
    }
  }

  // Déconnexion
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Vérifier si connecté
  static bool get isLoggedIn => _auth.currentUser != null;
}