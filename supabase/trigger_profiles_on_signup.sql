-- =============================================================================
-- 회원가입 직후 public.profiles 에 행 자동 생성 (groos.user_id → profiles.id FK 충족)
-- Supabase Dashboard → SQL Editor 에 붙여넣어 실행
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

-- =============================================================================
-- (선택) 이미 가입만 되어 있고 profiles 가 없는 계정 백필 — FK 오류가 난 뒤 한 번 실행
-- =============================================================================
-- INSERT INTO public.profiles (id, username)
-- SELECT u.id,
--        COALESCE(
--          NULLIF(TRIM(u.raw_user_meta_data ->> 'username'), ''),
--          SPLIT_PART(u.email, '@', 1)
--        )
-- FROM auth.users u
-- WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = u.id)
-- ON CONFLICT (id) DO NOTHING;
