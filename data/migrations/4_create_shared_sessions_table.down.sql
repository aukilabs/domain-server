BEGIN;

DROP TRIGGER IF EXISTS shared_sessions_update_tg ON shared_sessions;
DROP INDEX IF EXISTS shared_sessions_app_id_index;
DROP INDEX IF EXISTS shared_sessions_domain_id_index;
DROP INDEX IF EXISTS shared_sessions_session_id_index;
DROP TABLE IF EXISTS shared_sessions;

COMMIT;
