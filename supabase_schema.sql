-- Supabase Database Schema for Su Takip App
-- Firebase Auth + Supabase Data hybrid system

-- 1. Users tablosu (Firebase auth ile senkronize)
CREATE TABLE users (
  firebase_uid TEXT PRIMARY KEY, -- Firebase User ID
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  photo_url TEXT,
  dail:Çt FLOAT,
  weight FLOAT,
  age INTEGER,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  activity_level TEXT CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Water entries tablosu
CREATE TABLE water_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT REFERENCES users(firebase_uid) ON DELETE CASCADE,
  amount FLOAT NOT NULL CHECK (amount > 0 AND amount <= 5000),
  source TEXT DEFAULT 'manual' CHECK (source IN ('manual', 'quick_add', 'reminder')),
  note TEXT,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  client_tag TEXT -- Offline sync için
);

-- 3. Daily statistics tablosu
CREATE TABLE daily_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT REFERENCES users(firebase_uid) ON DELETE CASCADE,
  date DATE NOT NULL,
  total_amount FLOAT DEFAULT 0,
  entry_count INTEGER DEFAULT 0,
  goal_amount FLOAT NOT NULL,
  goal_reached BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- 4. Weekly statistics tablosu
CREATE TABLE weekly_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT REFERENCES users(firebase_uid) ON DELETE CASCADE,
  week_start DATE NOT NULL,
  total_amount FLOAT DEFAULT 0,
  entry_count INTEGER DEFAULT 0,
  days_count INTEGER DEFAULT 0,
  average_daily FLOAT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, week_start)
);

-- 5. Monthly statistics tablosu
CREATE TABLE monthly_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT REFERENCES users(firebase_uid) ON DELETE CASCADE,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
  total_amount FLOAT DEFAULT 0,
  entry_count INTEGER DEFAULT 0,
  days_count INTEGER DEFAULT 0,
  average_daily FLOAT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, year, month)
);

-- 6. User badges tablosu
CREATE TABLE user_badges (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT REFERENCES users(firebase_uid) ON DELETE CASCADE,
  badge_id TEXT NOT NULL,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  progress INTEGER DEFAULT 0,
  UNIQUE(user_id, badge_id)
);

-- Indexes for performance
CREATE INDEX idx_water_entries_user_timestamp ON water_entries(user_id, timestamp DESC);
CREATE INDEX idx_daily_stats_user_date ON daily_stats(user_id, date DESC);
CREATE INDEX idx_weekly_stats_user_week ON weekly_stats(user_id, week_start DESC);
CREATE INDEX idx_monthly_stats_user_period ON monthly_stats(user_id, year DESC, month DESC);

-- Row Level Security (RLS) políticas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

-- RLS Políticas - Firebase Auth ile çalışacak şekilde düzenli
-- Firebase JWT token'ı Supabase'e custom header ile gönderilecek

-- Geçici olarak RLS'i basit tut, Firebase Auth yapısını sonra entegre ederiz
CREATE POLICY "Enable all access for authenticated users" ON users
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for authenticated users" ON water_entries
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for authenticated users" ON daily_stats
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for authenticated users" ON weekly_stats
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for authenticated users" ON monthly_stats
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for authenticated users" ON user_badges
  FOR ALL USING (true) WITH CHECK (true);
