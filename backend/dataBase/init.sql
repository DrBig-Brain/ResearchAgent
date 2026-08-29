CREATE TABLE company_performance (
    record_id     SERIAL PRIMARY KEY,
    company_name  VARCHAR(100) NOT NULL,
    fiscal_year   INT          NOT NULL,
    fiscal_quarter VARCHAR(2)  NOT NULL,  -- Q1, Q2, Q3, Q4
    report_date   DATE         NOT NULL,

    -- Core financials only
    revenue            NUMERIC(15, 2) NOT NULL,
    net_income         NUMERIC(15, 2) NOT NULL,
    cash_flow          NUMERIC(15, 2),

    -- Growth signal
    yoy_growth_percentage NUMERIC(5, 2),  -- e.g., 15.50 for 15.5%

    -- One customer health signal
    customer_satisfaction_score NUMERIC(4, 1),  -- e.g., 85.5

    CONSTRAINT unique_company_quarter UNIQUE (company_name, fiscal_year, fiscal_quarter)
);

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
    round(rev.val * (0.10 + random() * 0.15), 2),  -- net income: 10–25% of revenue
    round(rev.val * (0.05 + random() * 0.20), 2),  -- cash flow: 5–25% of revenue

    round((random() * 30.0)::numeric, 2),           -- yoy growth: 0–30%
    round((75.0 + random() * 24.0)::numeric, 1)     -- CSAT: 75–99

FROM
    generate_series(1, 100) AS g(i),  -- reduced from 300
    LATERAL (SELECT round((500000 + random() * 4500000)::numeric, 2) AS val) rev
ON CONFLICT (company_name, fiscal_year, fiscal_quarter) DO NOTHING;

