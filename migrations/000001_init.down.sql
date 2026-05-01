ALTER TABLE IF EXISTS payment_gateway.history 
    DROP CONSTRAINT IF EXISTS check_status_change,
    DROP CONSTRAINT IF EXISTS check_status_from_nullable;

ALTER TABLE IF EXISTS payment_gateway.payment 
    DROP CONSTRAINT IF EXISTS check_amount_positive,
    DROP CONSTRAINT IF EXISTS check_currency_length,
    DROP CONSTRAINT IF EXISTS check_currency_uppercase,
    DROP CONSTRAINT IF EXISTS check_dates,
    DROP CONSTRAINT IF EXISTS check_provider_payment_id_format;

ALTER TABLE IF EXISTS payment_gateway.provider 
    DROP CONSTRAINT IF EXISTS check_provider_name_length;

DROP INDEX IF EXISTS payment_gateway.idx_history_payment_id;
DROP INDEX IF EXISTS payment_gateway.idx_payment_status;
DROP INDEX IF EXISTS payment_gateway.idx_payment_provider_id;
DROP INDEX IF EXISTS payment_gateway.idx_payment_order_id;

DROP TABLE IF EXISTS payment_gateway.history;
DROP TABLE IF EXISTS payment_gateway.payment;
DROP TABLE IF EXISTS payment_gateway.provider;

DROP TYPE IF EXISTS payment_gateway.payment_status;

DROP SCHEMA IF EXISTS payment_gateway CASCADE;