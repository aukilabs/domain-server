BEGIN;

DROP INDEX idx_domain_data_domain_id;

DROP TRIGGER IF EXISTS domain_data_update_tg ON domain_data;

ALTER TABLE domain_data DROP CONSTRAINT domain_data_unique_domain_id_name;

DROP TABLE IF EXISTS domain_data;

COMMIT;
