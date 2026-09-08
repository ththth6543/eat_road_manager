import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized access to the initialized Supabase client instance.
SupabaseClient get supabase => Supabase.instance.client;
