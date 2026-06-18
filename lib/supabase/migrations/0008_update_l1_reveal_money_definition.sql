-- Update Lesson L1 "THE REVEAL" screen copy (keep **term** markup for definitions)

UPDATE public.lesson_screens
SET
  heading = 'Money is a tool for storing and transferring value across time and distance.',
  body_text = 'It hasn\'t always looked the same.\n\nIt has taken many forms – physical things like gold, silver, shells, and salt.\nIt has taken agreed forms like coins, paper notes, and bank balances.\nAnd today, it often exists as digital entries moving between systems.\n\nDifferent forms. Same purpose.\n\nWhat matters is not what money is made of, but what it allows people to do.\n\nThree things define good money:\n**Store of value** – it holds purchasing power over time.\n**Medium of exchange** – other people accept it in trade.\n**Unit of account** – it lets us measure and compare value.\n\nWhen something does all three well, it becomes widely used.\nWhen it only does some, it works in limited ways or for limited periods.\n\nThis is why forms of money change over time – not because the old ones were “wrong”, but because societies, trust, and technology evolve.'
WHERE lesson_code = 'L1'
  AND lower(screen_type) = 'reveal'
;
