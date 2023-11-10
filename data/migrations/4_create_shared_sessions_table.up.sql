BEGIN;

CREATE TABLE IF NOT EXISTS shared_sessions (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    app_id uuid NOT NULL,
    domain_id uuid NOT NULL,
    session_id VARCHAR NOT NULL,
    threshold INTEGER NOT NULL,
    last_active_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

CREATE INDEX IF NOT EXISTS shared_sessions_app_id_index ON shared_sessions (app_id);
CREATE INDEX IF NOT EXISTS shared_sessions_domain_id_index ON shared_sessions (domain_id);
CREATE INDEX IF NOT EXISTS shared_sessions_session_id_index ON shared_sessions (session_id);

CREATE TRIGGER shared_sessions_update_tg BEFORE UPDATE ON shared_sessions FOR EACH ROW EXECUTE FUNCTION update_check_time();

COMMIT;
