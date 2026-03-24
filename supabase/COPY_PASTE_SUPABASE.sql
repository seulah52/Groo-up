-- =============================================================================
-- Groo-up — Supabase SQL Editor 복사·붙여넣기용 (두 블록 순서대로 실행)
--
-- [1] initial Schema Migration  → 빈 DB(또는 아직 테이블 없음)일 때만 전체 실행
-- [2] Row-level policies for user-owned profiles and groos  → [1] 적용 후,
--     또는 이미 [1]로 테이블이 있는 경우 [2]만 실행해도 됨 (정책·트리거 재적용)
-- =============================================================================


-- =============================================================================
-- [1] initial Schema Migration
-- =============================================================================

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


-- =============================================================================
-- [2] Row-level policies for user-owned profiles and groos
--     (+ 회원가입 시 profiles 자동 생성 트리거)
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_username TEXT;
BEGIN
  v_username := COALESCE(
    NULLIF(TRIM(NEW.raw_user_meta_data ->> 'username'), ''),
    SPLIT_PART(NEW.email, '@', 1)
  );
  INSERT INTO public.profiles (id, username)
  VALUES (NEW.id, v_username)
  ON CONFLICT (id) DO UPDATE
  SET username = EXCLUDED.username,
      updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_new_user();

DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_delete_own" ON public.profiles;

DROP POLICY IF EXISTS "users can insert own profile" ON public.profiles;
CREATE POLICY "users can insert own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "users can update own profile" ON public.profiles;
CREATE POLICY "users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "users can insert own groos" ON public.groos;
CREATE POLICY "users can insert own groos"
  ON public.groos
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "users can update own groos" ON public.groos;
CREATE POLICY "users can update own groos"
  ON public.groos
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "users can delete own groos" ON public.groos;
CREATE POLICY "users can delete own groos"
  ON public.groos
  FOR DELETE
  USING (auth.uid() = user_id);
