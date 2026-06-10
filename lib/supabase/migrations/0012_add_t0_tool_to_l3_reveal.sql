-- Add Bubble O Bill as a bonus tool on L3 reveal screen
UPDATE public.lesson_screens
SET tool_code = 'T0'
WHERE lesson_code = 'L3' AND screen_type = 'reveal';
