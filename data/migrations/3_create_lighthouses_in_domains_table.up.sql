BEGIN;
CREATE TABLE IF NOT EXISTS lighthouses_in_domains (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    lighthouse_id uuid NOT NULL,
    domain_id uuid NOT NULL,
    short_id CHAR(11) NOT NULL,
    reported_size DOUBLE PRECISION,
    px DOUBLE PRECISION,
    py DOUBLE PRECISION,
    pz DOUBLE PRECISION,
    rx DOUBLE PRECISION,
    ry DOUBLE PRECISION,
    rz DOUBLE PRECISION,
    rw DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    altitude DOUBLE PRECISION,
    vertical_accuracy DOUBLE PRECISION,
    horizontal_accuracy DOUBLE PRECISION,
    gps_timestamp DOUBLE PRECISION,
    scanner_device_id VARCHAR(256),
    scanner_device_name VARCHAR(256),
    scanner_device_model VARCHAR(256),
    placed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp,
    UNIQUE (lighthouse_id, domain_id),
    UNIQUE (short_id, domain_id)
);

CREATE TRIGGER lighthouses_in_domains_update_tg BEFORE UPDATE ON lighthouses_in_domains FOR EACH ROW EXECUTE FUNCTION update_check_time();
COMMIT;
