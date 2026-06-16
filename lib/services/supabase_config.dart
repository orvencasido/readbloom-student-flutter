class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jpfytoltibefseqwrtsw.supabase.co',
  );
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_EN5QospkPzsO42E6UR4_wA_DDvOsIW4',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
