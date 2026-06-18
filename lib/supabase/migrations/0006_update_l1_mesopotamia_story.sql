-- Update Lesson L1 story copy (Mesopotamia screen)
-- This migration is safe to run multiple times.

UPDATE public.lesson_screens
SET
  heading = 'Mesopotamia, 8,000 BCE.',
  body_text =
    'Amara keeps grain. Leila weaves cloth.\n\n'
    'Between them, they have everything they need – except for one problem.\n\n'
    'For trade to work, both people need to want what the other has, at the same time, in the same amount.\n\n'
    'In a small village, that''s awkward.\n'
    'Across a civilisation, it doesn''t scale.\n\n'
    'So something simple happens.\n\n'
    'Not a law. Not a rule. Not even a system at first.\n\n'
    'Just a practical agreement between neighbours:\n'
    '“If you have what I need, and I have what you need – we swap.”\n\n'
    'It starts small.\n'
    'Then it repeats.\n'
    'Then it spreads.\n\n'
    'Until one day, it becomes something bigger than anyone intended:\n\n'
    'the foundation of every economy that follows.',
  updated_at = now()
WHERE lesson_code = 'L1'
  AND heading = 'Mesopotamia, 8,000 BCE.';
