
-- ============================================================
-- 1. CRIAÇÃO DE TABELAS
-- ============================================================

CREATE TABLE IF NOT EXISTS customers (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    email       VARCHAR(255) UNIQUE NOT NULL,
    segment     VARCHAR(50)  DEFAULT 'standard',
    city        VARCHAR(100),
    created_at  TIMESTAMPTZ  DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sales (
    id          SERIAL PRIMARY KEY,
    date        DATE          NOT NULL,
    customer_id INTEGER       REFERENCES customers(id),
    amount      NUMERIC(10,2) NOT NULL,
    product     VARCHAR(100)  NOT NULL,
    status      VARCHAR(50)   DEFAULT 'completed',
    created_at  TIMESTAMPTZ   DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS kpis (
    id              SERIAL PRIMARY KEY,
    date            DATE          NOT NULL UNIQUE,
    total_sales     NUMERIC(12,2),
    avg_ticket      NUMERIC(10,2),
    conversion_rate NUMERIC(5,2),
    customers       INTEGER,
    created_at      TIMESTAMPTZ   DEFAULT NOW()
);

-- ============================================================
-- 2. VIEWS PARA POWER BI
-- ============================================================

CREATE OR REPLACE VIEW daily_sales AS
SELECT
    date,
    SUM(amount)                 AS total_sales,
    COUNT(*)                    AS transaction_count,
    AVG(amount)                 AS avg_amount,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM sales
WHERE status = 'completed'
GROUP BY date
ORDER BY date DESC;

CREATE OR REPLACE VIEW product_performance AS
SELECT
    product,
    COUNT(*)    AS transactions,
    SUM(amount) AS total_revenue,
    AVG(amount) AS avg_price,
    MIN(amount) AS min_price,
    MAX(amount) AS max_price
FROM sales
WHERE status = 'completed'
GROUP BY product
ORDER BY total_revenue DESC;

CREATE OR REPLACE VIEW customer_performance AS
SELECT
    c.id, c.name, c.segment, c.city,
    COUNT(s.id)   AS total_orders,
    SUM(s.amount) AS total_spent,
    AVG(s.amount) AS avg_order_value,
    MAX(s.date)   AS last_purchase
FROM customers c
LEFT JOIN sales s ON c.id = s.customer_id AND s.status = 'completed'
GROUP BY c.id, c.name, c.segment, c.city
ORDER BY total_spent DESC;

CREATE OR REPLACE VIEW monthly_sales AS
SELECT
    DATE_TRUNC('month', date)   AS month,
    SUM(amount)                 AS total_sales,
    COUNT(*)                    AS transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    AVG(amount)                 AS avg_ticket
FROM sales
WHERE status = 'completed'
GROUP BY DATE_TRUNC('month', date)
ORDER BY month DESC;

CREATE OR REPLACE VIEW kpis_moving_avg AS
SELECT
    date, total_sales, avg_ticket, conversion_rate, customers,
    AVG(total_sales) OVER (
        ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS sales_7d_avg,
    AVG(conversion_rate) OVER (
        ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS conversion_7d_avg
FROM kpis
ORDER BY date DESC;

-- ============================================================
-- 3. QUERIES PRONTAS PARA POWER BI
-- ============================================================

-- Resumo Geral
SELECT
    SUM(amount)                 AS total_revenue,
    COUNT(*)                    AS total_transactions,
    COUNT(DISTINCT customer_id) AS total_customers,
    AVG(amount)                 AS avg_ticket
FROM sales WHERE status = 'completed';

-- Últimos 30 Dias
SELECT date, SUM(amount) AS daily_revenue, COUNT(*) AS orders
FROM sales
WHERE status = 'completed' AND date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY date ORDER BY date;

-- Top 10 Produtos
SELECT product, SUM(amount) AS total_revenue, COUNT(*) AS total_orders
FROM sales WHERE status = 'completed'
GROUP BY product ORDER BY total_revenue DESC LIMIT 10;

-- Crescimento MoM
WITH monthly AS (
    SELECT DATE_TRUNC('month', date) AS month, SUM(amount) AS revenue
    FROM sales WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', date)
)
SELECT
    month, revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 2
    ) AS mom_growth_pct
FROM monthly ORDER BY month DESC;

-- Retenção Mensal
WITH mc AS (
    SELECT DATE_TRUNC('month', date) AS month, customer_id
    FROM sales WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', date), customer_id
)
SELECT
    curr.month,
    COUNT(DISTINCT curr.customer_id) AS active_customers,
    COUNT(DISTINCT prev.customer_id) AS retained_customers,
    ROUND(
        COUNT(DISTINCT prev.customer_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT curr.customer_id), 0) * 100, 2
    ) AS retention_rate_pct
FROM mc curr
LEFT JOIN mc prev ON curr.customer_id = prev.customer_id
    AND curr.month = prev.month + INTERVAL '1 month'
GROUP BY curr.month ORDER BY curr.month DESC;

-- ============================================================
-- 4. ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE sales     ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE kpis      ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leitura de vendas"    ON sales     FOR SELECT USING (true);
CREATE POLICY "Leitura de clientes"  ON customers FOR SELECT USING (true);
CREATE POLICY "Leitura de KPIs"      ON kpis      FOR SELECT USING (true);

-- ============================================================
-- 5. ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_sales_date     ON sales(date);
CREATE INDEX IF NOT EXISTS idx_sales_customer ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_product  ON sales(product);
CREATE INDEX IF NOT EXISTS idx_sales_status   ON sales(status);
CREATE INDEX IF NOT EXISTS idx_kpis_date      ON kpis(date);