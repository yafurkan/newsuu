-- Temporarily disable RLS for testing
-- WARNING: Only for development/testing!

-- Disable RLS on all tables for testing
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE water_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE daily_stats DISABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_stats DISABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_stats DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges DISABLE ROW LEVEL SECURITY;

-- Note: Re-enable RLS after testing with:
-- ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
