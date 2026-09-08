import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/network/supabase_client.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client}) : _client = client ?? supabase;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signInWithGoogle({
    String redirectTo = 'io.supabase.flutterquickstart://login-callback',
  }) async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
