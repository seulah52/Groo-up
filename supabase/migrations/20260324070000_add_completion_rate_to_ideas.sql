-- 이유: 성장 로직을 대화 수가 아닌 completion_rate(0~100) 기반으로 통일
ALTER TABLE public.ideas
ADD COLUMN IF NOT EXISTS completion_rate INTEGER NOT NULL DEFAULT 0
CHECK (completion_rate >= 0 AND completion_rate <= 100);

-- 기존 데이터 보정: health_score가 있으면 completion_rate로 동기화
UPDATE public.ideas
SET completion_rate = GREATEST(0, LEAST(100, COALESCE(health_score, 0)))
WHERE completion_rate IS NULL OR completion_rate = 0;
