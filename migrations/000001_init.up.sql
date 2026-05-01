CREATE SCHEMA IF NOT EXISTS payment_gateway;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
        CREATE TYPE payment_gateway.payment_status AS ENUM (
            'pending',           
            'waiting_for_capture', 
            'succeeded',         
            'canceled',         
            'expired'            
        );
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS payment_gateway.provider (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    shop_id VARCHAR(100),               
    secret_key TEXT,                    
    is_active BOOLEAN DEFAULT true,

    CONSTRAINT check_provider_name_length CHECK (LENGTH(name) >= 2)
);

CREATE TABLE IF NOT EXISTS payment_gateway.payment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,           
    provider_id INTEGER NOT NULL REFERENCES payment_gateway.provider(id) ON DELETE RESTRICT,
    provider_payment_id VARCHAR(255),    
    status payment_gateway.payment_status NOT NULL DEFAULT 'pending',
    amount_cents INTEGER NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
    description TEXT,
    payment_method_type VARCHAR(50),     
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_amount_positive CHECK (amount_cents > 0),
    CONSTRAINT check_currency_length CHECK (LENGTH(currency) = 3),
    CONSTRAINT check_currency_uppercase CHECK (currency = UPPER(currency)),
    CONSTRAINT check_dates CHECK (created_at <= updated_at),
    CONSTRAINT check_provider_payment_id_format CHECK (
        provider_payment_id IS NULL OR LENGTH(provider_payment_id) >= 5
    )
);

CREATE TABLE IF NOT EXISTS payment_gateway.history (
    id SERIAL PRIMARY KEY,
    payment_id UUID NOT NULL REFERENCES payment_gateway.payment(id) ON DELETE CASCADE,
    status_from payment_gateway.payment_status,
    status_to payment_gateway.payment_status NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_status_change CHECK (status_from IS DISTINCT FROM status_to),
    CONSTRAINT check_status_from_nullable CHECK (
        (status_from IS NOT NULL AND status_to IS NOT NULL) OR
        (status_from IS NULL AND status_to IS NOT NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_payment_order_id ON payment_gateway.payment(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_provider_id ON payment_gateway.payment(provider_id);
CREATE INDEX IF NOT EXISTS idx_payment_status ON payment_gateway.payment(status);
CREATE INDEX IF NOT EXISTS idx_history_payment_id ON payment_gateway.history(payment_id);