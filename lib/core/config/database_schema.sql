-- ResumeAI Database Schema for Supabase
-- Run this in the SQL Editor in Supabase Dashboard

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends Supabase Auth users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL DEFAULT '',
  phone_number TEXT DEFAULT '',
  ai_credits INTEGER NOT NULL DEFAULT 10,
  subscription_tier TEXT NOT NULL DEFAULT 'free',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Resumes table
CREATE TABLE IF NOT EXISTS resumes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL DEFAULT 'Untitled Resume',
  personal_info JSONB DEFAULT '{"fullName":"","email":"","phoneNumber":"","address":"","linkedIn":"","portfolioUrl":""}'::jsonb,
  summary TEXT DEFAULT '',
  education JSONB DEFAULT '[]'::jsonb,
  experience JSONB DEFAULT '[]'::jsonb,
  skills JSONB DEFAULT '[]'::jsonb,
  projects JSONB DEFAULT '[]'::jsonb,
  certificates JSONB DEFAULT '[]'::jsonb,
  languages JSONB DEFAULT '[]'::jsonb,
  template_id TEXT DEFAULT '',
  ats_score DOUBLE PRECISION DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Cover letters table
CREATE TABLE IF NOT EXISTS cover_letters (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  resume_id UUID REFERENCES resumes(id) ON DELETE SET NULL,
  company_name TEXT NOT NULL DEFAULT '',
  position TEXT NOT NULL DEFAULT '',
  content TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Templates table
CREATE TABLE IF NOT EXISTS templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  category TEXT NOT NULL,
  preview_url TEXT DEFAULT '',
  is_premium BOOLEAN NOT NULL DEFAULT false
);

-- Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE resumes ENABLE ROW LEVEL SECURITY;
ALTER TABLE cover_letters ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to recreate
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view own resumes" ON resumes;
DROP POLICY IF EXISTS "Users can create own resumes" ON resumes;
DROP POLICY IF EXISTS "Users can update own resumes" ON resumes;
DROP POLICY IF EXISTS "Users can delete own resumes" ON resumes;
DROP POLICY IF EXISTS "Users can view own cover letters" ON cover_letters;
DROP POLICY IF EXISTS "Users can create own cover letters" ON cover_letters;
DROP POLICY IF EXISTS "Users can update own cover letters" ON cover_letters;
DROP POLICY IF EXISTS "Users can delete own cover letters" ON cover_letters;
DROP POLICY IF EXISTS "Anyone can view templates" ON templates;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Resumes policies
CREATE POLICY "Users can view own resumes" ON resumes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own resumes" ON resumes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own resumes" ON resumes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own resumes" ON resumes
  FOR DELETE USING (auth.uid() = user_id);

-- Cover letters policies
CREATE POLICY "Users can view own cover letters" ON cover_letters
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own cover letters" ON cover_letters
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cover letters" ON cover_letters
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cover letters" ON cover_letters
  FOR DELETE USING (auth.uid() = user_id);

-- Templates are public (read-only for users)
CREATE POLICY "Anyone can view templates" ON templates
  FOR SELECT USING (true);

-- Add description column to templates if not exists
ALTER TABLE templates ADD COLUMN IF NOT EXISTS description TEXT DEFAULT '';

-- Seed default templates
INSERT INTO templates (id, name, description, category, preview_url, is_premium) VALUES
  ('tmpl-001', 'Modern', 'Two-column layout with dark sidebar and yellow accent', 'modern', '', false),
  ('tmpl-002', 'ATS Friendly', 'Simple single-column optimized for ATS scanners', 'ats', '', false)
ON CONFLICT (id) DO NOTHING;

-- Function to auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, phone_number)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'phone_number', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
