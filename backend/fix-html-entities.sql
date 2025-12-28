-- Fix HTML entities in listings table
-- This script replaces HTML-encoded characters with their actual characters

BEGIN;

-- Fix &amp; (ampersand) - most common
UPDATE listings
SET 
  name = REPLACE(name, '&amp;', '&'),
  description = REPLACE(description, '&amp;', '&')
WHERE name LIKE '%&amp;%' OR description LIKE '%&amp;%';

-- Fix &quot; (double quote)
UPDATE listings
SET 
  name = REPLACE(name, '&quot;', '"'),
  description = REPLACE(description, '&quot;', '"')
WHERE name LIKE '%&quot;%' OR description LIKE '%&quot;%';

-- Fix &lt; (less than)
UPDATE listings
SET 
  name = REPLACE(name, '&lt;', '<'),
  description = REPLACE(description, '&lt;', '<')
WHERE name LIKE '%&lt;%' OR description LIKE '%&lt;%';

-- Fix &gt; (greater than)
UPDATE listings
SET 
  name = REPLACE(name, '&gt;', '>'),
  description = REPLACE(description, '&gt;', '>')
WHERE name LIKE '%&gt;%' OR description LIKE '%&gt;%';

-- Fix &#39; (apostrophe - numeric)
UPDATE listings
SET 
  name = REPLACE(name, '&#39;', '''),
  description = REPLACE(description, '&#39;', '''')
WHERE name LIKE '%&#39;%' OR description LIKE '%&#39;%';

-- Fix &apos; (apostrophe - named)
UPDATE listings
SET 
  name = REPLACE(name, '&apos;', '''),
  description = REPLACE(description, '&apos;', '''')
WHERE name LIKE '%&apos;%' OR description LIKE '%&apos;%';

-- Fix &nbsp; (non-breaking space) - replace with regular space
UPDATE listings
SET 
  name = REPLACE(name, '&nbsp;', ' '),
  description = REPLACE(description, '&nbsp;', ' ')
WHERE name LIKE '%&nbsp;%' OR description LIKE '%&nbsp;%';

-- Fix &mdash; (em dash)
UPDATE listings
SET 
  name = REPLACE(name, '&mdash;', '—'),
  description = REPLACE(description, '&mdash;', '—')
WHERE name LIKE '%&mdash;%' OR description LIKE '%&mdash;%';

-- Fix &ndash; (en dash)
UPDATE listings
SET 
  name = REPLACE(name, '&ndash;', '–'),
  description = REPLACE(description, '&ndash;', '–')
WHERE name LIKE '%&ndash;%' OR description LIKE '%&ndash;%';

-- Fix &hellip; (ellipsis)
UPDATE listings
SET 
  name = REPLACE(name, '&hellip;', '…'),
  description = REPLACE(description, '&hellip;', '…')
WHERE name LIKE '%&hellip;%' OR description LIKE '%&hellip;%';

-- Show summary of fixes
SELECT 
  'After Fix' as status,
  COUNT(*) as total_listings,
  COUNT(CASE WHEN name LIKE '%&amp;%' OR description LIKE '%&amp;%' THEN 1 END) as remaining_amp,
  COUNT(CASE WHEN name LIKE '%&quot;%' OR description LIKE '%&quot;%' THEN 1 END) as remaining_quot,
  COUNT(CASE WHEN name LIKE '%&lt;%' OR description LIKE '%&lt;%' THEN 1 END) as remaining_lt,
  COUNT(CASE WHEN name LIKE '%&gt;%' OR description LIKE '%&gt;%' THEN 1 END) as remaining_gt
FROM listings;

COMMIT;

