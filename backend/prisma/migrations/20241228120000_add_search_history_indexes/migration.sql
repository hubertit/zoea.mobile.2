-- Add indexes to search_history table for better query performance

-- Index on userId for faster user-specific queries (getSearchHistory)
CREATE INDEX IF NOT EXISTS idx_search_history_user ON search_history(user_id);

-- Index on createdAt for faster date-based queries (trending searches, recent searches)
CREATE INDEX IF NOT EXISTS idx_search_history_created ON search_history(created_at DESC);

-- Index on query for faster search term lookups and grouping (getTrending)
CREATE INDEX IF NOT EXISTS idx_search_history_query ON search_history(query);
