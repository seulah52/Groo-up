-- =============================================================================
-- public.ideas RLS (앱은 SupabaseTables.ideas = 'ideas' 만 사용)
-- RLS 를 다시 켤 때 Supabase SQL Editor 에서 실행
-- =============================================================================

DROP POLICY IF EXISTS "users can select own ideas" ON public.ideas;
CREATE POLICY "users can select own ideas"
  ON public.ideas
  FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "users can insert own ideas" ON public.ideas;
CREATE POLICY "users can insert own ideas"
  ON public.ideas
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "users can update own ideas" ON public.ideas;
CREATE POLICY "users can update own ideas"
  ON public.ideas
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "users can delete own ideas" ON public.ideas;
CREATE POLICY "users can delete own ideas"
  ON public.ideas
  FOR DELETE
  USING (auth.uid() = user_id);
