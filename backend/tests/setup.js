require('dotenv').config();

// Basic sanity check so tests fail fast with a clear message if .env
// isn't configured, rather than failing confusingly deep in a test.
if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error(
    'Tests require SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in backend/.env'
  );
}

jest.setTimeout(15000); // Supabase calls can be slow on free tier