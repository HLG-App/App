-- Update Lesson L1 story screen to use a local asset image.

UPDATE public.lesson_screens
SET image_url = 'assets/images/2a1a8707-1624-4b26-bda5-4188e85397ff.jpg',
    updated_at = now()
WHERE lesson_code = 'L1'
  AND screen_type = 'story'
  AND heading = 'Mesopotamia, 8,000 BCE.';
