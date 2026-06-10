-- Seed lesson_screens: L0 (This Is For You)
-- Idempotent: safe to re-run.

insert into public.lesson_screens (lesson_code, screen_index, screen_type, heading, body_text, options)
values
  (
    'L0',
    0,
    'reminder',
    'Reminder',
    'You found this app. Maybe someone sent it to you. Maybe you''ve been meaning to sort out your finances for a while and kept not doing it. Whatever brought you here: you''re in the right place.\n\nFirst, we''ll meet you where you are. We''ll look at what you think you know, what you actually do with money, how you feel about it, how it''s affecting you, and how much agency you believe you have.\n\nNobody handed you a manual. It turns out there wasn''t one.',
    null
  ),
  (
    'L0',
    1,
    'story',
    'Her Long Game is for women who were never taught.',
    'Not women who failed to learn. Women who were never taught. There is a difference. A big one. 70% of women report never receiving formal financial education. Not a class, not a book, not a conversation. Nothing. If you''ve ever felt like everyone else just knows this stuff — you didn''t miss it. The memo was never sent.',
    null
  ),
  (
    'L0',
    2,
    'reframe',
    'This app will not make you feel stupid.',
    'No jargon without explanation. No judgment about where you are starting from. No assumption that you already have confidence. This app will start from exactly where you are, explain the system you''ve been operating inside without a manual, and treat you like the capable adult you already are.',
    null
  ),
  (
    'L0',
    3,
    'feeling',
    'How do you feel about money, right now?',
    'Not what you know about it, how you feel about it. We''ll come back to this question throughout the course.',
    '["Anxious — there''s never quite enough", "Avoidant — I''d rather not think about it", "Confused — I don''t know where to start", "Curious — I want to understand it better", "Frustrated — I work hard and it doesn''t seem to add up"]'::jsonb
  ),
  (
    'L0',
    4,
    'complete',
    'You''ve started.',
    'That''s the hardest part. And you just did it. The first lesson is waiting.',
    null
  )
on conflict (lesson_code, screen_index)
do update set
  screen_type = excluded.screen_type,
  heading = excluded.heading,
  body_text = excluded.body_text,
  options = excluded.options;
