-- Update L0 complete screen copy.
-- Run in Supabase SQL editor (or apply as a migration).

UPDATE public.lesson_screens
SET heading = 'This is for you.',
    body_text = 'Now that you know this space is yours — let''s check in. Before any lesson begins, we want to know your starting point. Not where you think you should be. Where you actually are. That''s what the next step is for.'
WHERE lesson_code = 'L0' AND screen_index = 4 AND screen_type = 'complete';
