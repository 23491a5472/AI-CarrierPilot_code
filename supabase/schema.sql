-- CareerPilot AI - Supabase Database Schema

-- ==========================================
-- CUSTOM TYPES (ENUMS)
-- ==========================================
CREATE TYPE plan_type_enum AS ENUM ('free', 'premium_monthly', 'premium_yearly', 'lifetime');
CREATE TYPE job_application_status AS ENUM ('saved', 'applied', 'interview', 'offer', 'rejected');
CREATE TYPE cover_letter_status AS ENUM ('active', 'archived', 'deleted');
CREATE TYPE ad_event_type AS ENUM ('banner_impression', 'native_impression', 'interstitial_shown', 'rewarded_completed');
CREATE TYPE analysis_status_enum AS ENUM ('pending', 'processing', 'completed', 'failed');

-- ==========================================
-- TABLES
-- ==========================================

-- Profiles
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT NOT NULL,
    full_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Preferences
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    push_notifications BOOLEAN DEFAULT TRUE,
    email_notifications BOOLEAN DEFAULT TRUE,
    theme_mode TEXT DEFAULT 'system',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscription Status
CREATE TABLE subscription_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    plan_type plan_type_enum DEFAULT 'free',
    start_date TIMESTAMPTZ DEFAULT NOW(),
    expiry_date TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- User Usage Limits
CREATE TABLE user_usage_limits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    ats_scans_used_today INT DEFAULT 0,
    cover_letters_used_today INT DEFAULT 0,
    resume_improvements_used_today INT DEFAULT 0,
    last_reset_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Resumes
CREATE TABLE resumes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    original_file_name TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    file_size INT NOT NULL, -- Stored in bytes
    upload_date TIMESTAMPTZ DEFAULT NOW(),
    version_number INT DEFAULT 1,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Resume Versions (For History)
CREATE TABLE resume_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resume_id UUID REFERENCES resumes(id) ON DELETE CASCADE,
    version_number INT NOT NULL,
    content_text TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Job Descriptions
CREATE TABLE job_descriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    company TEXT,
    description_text TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ATS Analyses
CREATE TABLE ats_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    resume_version_id UUID REFERENCES resume_versions(id) ON DELETE CASCADE,
    job_description_id UUID REFERENCES job_descriptions(id) ON DELETE CASCADE,
    status analysis_status_enum DEFAULT 'pending',
    ats_score INT,
    resume_hash TEXT,
    job_description_hash TEXT,
    analysis_json JSONB, 
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cover Letters
CREATE TABLE cover_letters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    resume_version_id UUID REFERENCES resume_versions(id) ON DELETE SET NULL,
    job_description_id UUID REFERENCES job_descriptions(id) ON DELETE SET NULL,
    tone TEXT NOT NULL,
    content TEXT NOT NULL,
    status cover_letter_status DEFAULT 'active',
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Interview Questions
CREATE TABLE interview_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    job_description_id UUID REFERENCES job_descriptions(id) ON DELETE CASCADE,
    category TEXT NOT NULL, 
    questions_json JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Skill Gap Reports
CREATE TABLE skill_gap_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    ats_analysis_id UUID REFERENCES ats_analyses(id) ON DELETE CASCADE,
    gap_json JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Job Applications (Tracker)
CREATE TABLE job_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    job_description_id UUID REFERENCES job_descriptions(id) ON DELETE SET NULL,
    company TEXT,
    role TEXT,
    status job_application_status DEFAULT 'saved',
    applied_date TIMESTAMPTZ,
    notes TEXT,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Saved Jobs
CREATE TABLE saved_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    company TEXT,
    location TEXT,
    salary_range TEXT,
    match_percentage INT,
    job_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Career Health Snapshots
CREATE TABLE career_health_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    ats_score INT NOT NULL,
    resume_strength INT NOT NULL,
    skill_completeness INT NOT NULL,
    snapshot_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ad Events (Analytics)
CREATE TABLE ad_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    event_type ad_event_type NOT NULL,
    revenue NUMERIC(10,4),
    platform TEXT,
    ad_unit_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- INDEX STRATEGY
-- ==========================================
CREATE INDEX idx_user_usage_limits_user_id ON user_usage_limits(user_id);
CREATE INDEX idx_subscription_user_id ON subscription_status(user_id);
CREATE INDEX idx_resumes_user_id ON resumes(user_id) WHERE is_deleted = false;
CREATE INDEX idx_ats_analyses_user_id ON ats_analyses(user_id) WHERE is_deleted = false;
CREATE INDEX idx_cover_letters_user_id ON cover_letters(user_id) WHERE is_deleted = false;
CREATE INDEX idx_job_applications_user_id ON job_applications(user_id) WHERE is_deleted = false;
CREATE INDEX idx_ad_events_user_type ON ad_events(user_id, event_type);
CREATE INDEX idx_ats_hashes ON ats_analyses(resume_hash, job_description_hash);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_usage_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE resumes ENABLE ROW LEVEL SECURITY;
ALTER TABLE resume_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_descriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ats_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE cover_letters ENABLE ROW LEVEL SECURITY;
ALTER TABLE interview_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_gap_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_health_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE ad_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own profiles" ON profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users can manage their preferences" ON user_preferences FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view their subscription" ON subscription_status FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their usage limits" ON user_usage_limits FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own resumes" ON resumes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view their own resumes" ON resumes FOR SELECT USING (auth.uid() = user_id AND is_deleted = false);
CREATE POLICY "Users can update their own resumes" ON resumes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own resumes" ON resumes FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own resume_versions" ON resume_versions FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Users can manage their own job_descriptions" ON job_descriptions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own ats_analyses" ON ats_analyses FOR ALL USING (auth.uid() = user_id AND is_deleted = false);
CREATE POLICY "Users can manage their own cover_letters" ON cover_letters FOR ALL USING (auth.uid() = user_id AND is_deleted = false);
CREATE POLICY "Users can manage their own interview_questions" ON interview_questions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own skill_gap_reports" ON skill_gap_reports FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own job_applications" ON job_applications FOR ALL USING (auth.uid() = user_id AND is_deleted = false);
CREATE POLICY "Users can manage their own saved_jobs" ON saved_jobs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own notifications" ON notifications FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their career health" ON career_health_snapshots FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own ad events" ON ad_events FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- STORAGE POLICIES
-- ==========================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('resumes', 'resumes', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Users can upload their own resumes" 
ON storage.objects FOR INSERT 
WITH CHECK (
   bucket_id = 'resumes' 
   AND auth.uid()::text = (storage.foldername(name))[1] 
   AND (LOWER(storage.extension(name)) IN ('pdf', 'docx', 'doc', 'txt')) 
   AND (storage.objects.metadata->>'size')::int <= 10485760 -- 10 MB limit
);

CREATE POLICY "Users can view their own resumes" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own resumes" 
ON storage.objects FOR UPDATE 
USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own resumes" 
ON storage.objects FOR DELETE 
USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
