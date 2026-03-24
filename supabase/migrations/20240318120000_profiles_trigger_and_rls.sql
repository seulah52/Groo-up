-- =============================================
-- Row-level policies (profiles INSERT/UPDATE, groos INSERT/UPDATE/DELETE)
-- + auth.users → profiles 트리거 (이메일 확인 등 세션 없는 가입 대비)
-- Supabase 대시보드의 "Row-level policies for user-owned profiles and groos" 와 동기
-- =============================================

-- 신규 auth 사용자마다 public.profiles 행 생성 (RLS·세션과 무관)
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

-- 레포 구버전 마이그레이션에서 쓰던 정책명 제거 (이름 통일)
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_delete_own" ON public.profiles;

-- 초기 스키마의 "own profile"은 유지(조회 등). 아래는 INSERT/UPDATE 명시 보강
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

-- groos: "own groos"에 더해 쓰기 작업 명시 (앱에서 seed 심기 등)
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
