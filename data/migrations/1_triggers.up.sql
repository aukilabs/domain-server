BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE OR REPLACE FUNCTION update_check_time() RETURNS trigger LANGUAGE plpgsql AS $func$
BEGIN
    SELECT current_timestamp INTO NEW.updated_at;
    RETURN NEW;
END;
$func$;

COMMIT;
