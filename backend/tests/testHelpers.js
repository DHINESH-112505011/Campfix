const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseAnon = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
      detectSessionInUrl: false,
    },
  }
);

async function getAuthToken(email, password) {
  const { data, error } = await supabaseAnon.auth.signInWithPassword({ email, password });
  if (error) {
    throw new Error(`Failed to log in test user ${email}: ${error.message}`);
  }
  if (!data?.session?.access_token) {
    throw new Error(`Login succeeded but no access token was returned for ${email}`);
  }
  return data.session.access_token;
}

module.exports = { getAuthToken };