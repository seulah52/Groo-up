-- =============================================
-- Groo-up Initial Schema (= Supabase "initial Schema Migration")
-- 이후 RLS 보완·트리거·RPC는 20240318*.sql 을 순서대로 적용
-- =============================================

CREATE TABLE public.profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username   TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  gru_name   TEXT DEFAULT 'Gru',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.groos (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title            TEXT NOT NULL,
  description      TEXT,
  category         TEXT,
  growth_stage     TEXT NOT NULL DEFAULT 'seed'
                   CHECK (growth_stage IN ('seed','sprout','tree','fruit')),
  health_status    TEXT NOT NULL DEFAULT 'green'
                   CHECK (health_status IN ('red','orange','green')),
  health_score     INTEGER DEFAULT 100 CHECK (health_score BETWEEN 0 AND 100),
  last_activity_at TIMESTAMPTZ DEFAULT NOW(),
  is_archived      BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_groos_user_id ON public.groos(user_id);
CREATE INDEX idx_groos_health  ON public.groos(health_status);

CREATE TABLE public.interview_sessions (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  groo_id    UUID NOT NULL REFERENCES public.groos(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status     TEXT DEFAULT 'active' CHECK (status IN ('active','completed','paused')),
  summary    TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at   TIMESTAMPTZ
);

CREATE TABLE public.messages (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES public.interview_sessions(id) ON DELETE CASCADE,
  role       TEXT NOT NULL CHECK (role IN ('user','assistant')),
  content    TEXT NOT NULL,
  metadata   JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_messages_session ON public.messages(session_id);

CREATE TABLE public.steps (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  groo_id      UUID NOT NULL REFERENCES public.groos(id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  from_stage   TEXT NOT NULL,
  to_stage     TEXT NOT NULL,
  trigger_type TEXT NOT NULL CHECK (trigger_type IN ('interview','manual','time_based')),
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.trend_logs (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category       TEXT NOT NULL CHECK (category IN ('news','stock','paper')),
  title          TEXT NOT NULL,
  summary        TEXT,
  source_url     TEXT,
  source_name    TEXT,
  relevance_tags TEXT[],
  raw_data       JSONB,
  published_at   TIMESTAMPTZ,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_trend_category  ON public.trend_logs(category);
CREATE INDEX idx_trend_published ON public.trend_logs(published_at DESC);

CREATE TABLE public.bookmarks (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  trend_log_id UUID NOT NULL REFERENCES public.trend_logs(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, trend_log_id)
);

-- RLS
ALTER TABLE public.profiles           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groos              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interview_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.steps              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trend_logs         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmarks          ENABLE ROW LEVEL SECURITY;

CREATE POLICY "own profile"   ON public.profiles           USING (auth.uid() = id);
CREATE POLICY "own groos"     ON public.groos              USING (auth.uid() = user_id);
CREATE POLICY "own sessions"  ON public.interview_sessions USING (auth.uid() = user_id);
CREATE POLICY "own messages"  ON public.messages
  USING (session_id IN (SELECT id FROM public.interview_sessions WHERE user_id = auth.uid()));
CREATE POLICY "own steps"     ON public.steps              USING (auth.uid() = user_id);
CREATE POLICY "read trends"   ON public.trend_logs         FOR SELECT TO authenticated USING (true);
CREATE POLICY "own bookmarks" ON public.bookmarks          USING (auth.uid() = user_id);
