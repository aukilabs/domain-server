BEGIN;

CREATE TABLE IF NOT EXISTS domain_access_token_validity (
    domain_id uuid UNIQUE NOT NULL,
    nbf TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

COMMIT;
