-- 1. Create the table first
CREATE TABLE IF NOT EXISTS company_performance (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    fiscal_year INT NOT NULL,
    fiscal_quarter VARCHAR(10) NOT NULL,
    report_date DATE NOT NULL,
    revenue NUMERIC(15, 2) NOT NULL,
    net_income NUMERIC(15, 2) NOT NULL,
    cash_flow NUMERIC(15, 2) NOT NULL,
    yoy_growth_percentage NUMERIC(5, 2) NOT NULL,
    customer_satisfaction_score NUMERIC(4, 1) NOT NULL,
    CONSTRAINT unique_company_quarter UNIQUE (company_name, fiscal_year, fiscal_quarter)
);

-- 2. Then seed the data
INSERT INTO company_performance (
    company_name, fiscal_year, fiscal_quarter, report_date,
    revenue, net_income, cash_flow,
    yoy_growth_percentage, customer_satisfaction_score
)
SELECT
    CASE (floor(random() * 3)::int)
        WHEN 0 THEN 'Apple'
        WHEN 1 THEN 'Microsoft'
        ELSE 'Google'
    END,
    (2022 + floor(random() * 5))::int,
    CASE (floor(random() * 4)::int)
        WHEN 0 THEN 'Q1' WHEN 1 THEN 'Q2' WHEN 2 THEN 'Q3' ELSE 'Q4'
    END,
    CURRENT_DATE - (random() * 1500)::int,
    rev.val,
    round((rev.val * (0.10 + random() * 0.15))::numeric, 2),  
    round((rev.val * (0.05 + random() * 0.20))::numeric, 2),  
    round((random() * 30.0)::numeric, 2),                     
    round((75.0 + random() * 24.0)::numeric, 1)               
FROM
    generate_series(1, 100) AS g(i),
    LATERAL (SELECT round((500000 + random() * 4500000)::numeric, 2) AS val) rev
ON CONFLICT (company_name, fiscal_year, fiscal_quarter) DO NOTHING;
