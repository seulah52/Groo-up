-- 앱이 호출하는 ensure_my_profile (RLS 우회). 초기 스키마+정책과 병행 사용
-- 클라이언트에서 profiles 직접 INSERT/UPSERT 시 RLS(42501)에 자주 걸림
-- 인증된 사용자만 호출 가능한 SECURITY DEFINER RPC로 동일 작업 수행 (RLS 우회)
CREATE OR REPLACE FUNCTION public.ensure_my_profile(p_username text DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  v_email text;
  v_meta_username text;
  v_final text;
BEGIN
  IF uid IS NULL THEN
    RETURN;
  END IF;

  SELECT u.email, u.raw_user_meta_data ->> 'username'
  INTO v_email, v_meta_username
  FROM auth.users AS u
  WHERE u.id = uid;

  v_final := COALESCE(
    NULLIF(TRIM(p_username), ''),
    NULLIF(TRIM(v_meta_username), ''),
    NULLIF(TRIM(SPLIT_PART(COALESCE(v_email, ''), '@', 1)), '')
  );

  IF v_final IS NULL OR v_final = '' THEN
    v_final := 'user_' || LEFT(REPLACE(uid::text, '-', ''), 8);
  END IF;

  INSERT INTO public.profiles (id, username)
  VALUES (uid, v_final)
  ON CONFLICT (id) DO UPDATE
  SET
    username = COALESCE(
      NULLIF(TRIM(p_username), ''),
      public.profiles.username
    ),
    updated_at = NOW();
END;
$$;

REVOKE ALL ON FUNCTION public.ensure_my_profile(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ensure_my_profile(text) TO authenticated;
