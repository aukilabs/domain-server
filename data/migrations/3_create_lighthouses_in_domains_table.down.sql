BEGIN;
DROP TRIGGER IF EXISTS lighthouses_in_domains_update_tg ON lighthouses_in_domains;
DROP TABLE IF EXISTS lighthouses_in_domains;
COMMIT;
