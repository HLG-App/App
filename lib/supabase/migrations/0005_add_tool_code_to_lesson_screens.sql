-- Add tool_code to lesson_screens (idempotent)
ALTER TABLE public.lesson_screens
ADD COLUMN IF NOT EXISTS tool_code text;

-- Seed: link tools to Action screens (idempotent updates)
UPDATE public.lesson_screens SET tool_code = 'T1' WHERE lesson_code = 'L3' AND screen_type = 'action';
UPDATE public.lesson_screens SET tool_code = 'T2' WHERE lesson_code = 'L2' AND screen_type = 'action';
UPDATE public.lesson_screens SET tool_code = 'T5' WHERE lesson_code = 'L6' AND screen_type = 'action';
UPDATE public.lesson_screens SET tool_code = 'T6' WHERE lesson_code = 'LC' AND screen_type = 'action';
UPDATE public.lesson_screens SET tool_code = 'T4' WHERE lesson_code = 'L7' AND screen_type = 'action';
UPDATE public.lesson_screens SET tool_code = 'T4b' WHERE lesson_code = 'L7b' AND screen_type = 'action';
UPDATE public.lesson_screens SET tool_code = 'T3' WHERE lesson_code = 'L8' AND screen_type = 'action';
UPDATE public.lesson_screens SET tool_code = 'T3b' WHERE lesson_code = 'L8a' AND screen_type = 'action';
UPDATE public.lesson_screens SET tool_code = 'T7' WHERE lesson_code = 'L4' AND screen_type = 'action';
