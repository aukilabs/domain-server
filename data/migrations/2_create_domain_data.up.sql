BEGIN;

CREATE TABLE IF NOT EXISTS domain_data (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    domain_id uuid NOT NULL,
    name VARCHAR NOT NULL,
    data_type VARCHAR NOT NULL,
    data BYTEA NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

ALTER TABLE domain_data ADD CONSTRAINT domain_data_unique_domain_id_name UNIQUE (domain_id, name);

CREATE TRIGGER domain_data_update_tg BEFORE UPDATE ON domain_data FOR EACH ROW EXECUTE FUNCTION update_check_time();

CREATE INDEX idx_domain_data_domain_id ON domain_data(domain_id);

COMMIT;
