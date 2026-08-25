CREATE TABLE company_performance (

    record_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    fiscal_year INT NOT NULL,
    fiscal_quarter VARCHAR(2) NOT NULL, -- Q1, Q2, Q3, Q4
    report_date DATE NOT NULL,

    revenue NUMERIC(15, 2) NOT NULL,
    gross_profit NUMERIC(15, 2) NOT NULL,
    net_income NUMERIC(15, 2) NOT NULL,
    operating_expenses NUMERIC(15, 2) NOT NULL,
    cash_flow NUMERIC(15, 2),

    customer_acquisition_cost NUMERIC(10, 2),
    customer_lifetime_value NUMERIC(10, 2),
    monthly_recurring_revenue NUMERIC(15, 2),
    yoy_growth_percentage NUMERIC(5, 2), -- e.g., 15.50 for 15.5%

    employee_headcount INT,
    employee_turnover_rate NUMERIC(5, 2),
    customer_satisfaction_score NUMERIC(4, 1), -- e.g., 85.5

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT unique_company_quarter UNIQUE (company_name, fiscal_year, fiscal_quarter)
);

INSERT INTO company_performance (
    company_name, fiscal_year, fiscal_quarter, report_date, 
    revenue, gross_profit, net_income, operating_expenses, cash_flow,
    customer_acquisition_cost, customer_lifetime_value, monthly_recurring_revenue, 
    yoy_growth_percentage, employee_headcount, employee_turnover_rate, customer_satisfaction_score
)
SELECT 
    -- Alternates between 3 dummy companies
    CASE (floor(random() * 3)::int)
        WHEN 0 THEN 'Apple'
        WHEN 1 THEN 'Microsoft'
        ELSE 'Google'
    END as company_name,
    
    -- Generates years between 2022 and 2026
    (2022 + floor(random() * 5))::int as fiscal_year,
    
    -- Randomizes quarters
    CASE (floor(random() * 4)::int)
        WHEN 0 THEN 'Q1' WHEN 1 THEN 'Q2' WHEN 2 THEN 'Q3' ELSE 'Q4'
    END as fiscal_quarter,
    
    -- Random date in the last few years
    CURRENT_DATE - (random() * 1500)::int as report_date,
    
    -- Interdependent Financial Calculations
    rev.val as revenue,
    round(rev.val * (0.60 + random() * 0.15), 2) as gross_profit,          -- GP is 60-75% of revenue
    round(rev.val * (0.10 + random() * 0.15), 2) as net_income,            -- Net is 10-25% of revenue
    round(rev.val * (0.35 + random() * 0.10), 2) as operating_expenses,    -- OpEx is 35-45% of revenue
    round(rev.val * (0.05 + random() * 0.20), 2) as cash_flow,
    
    -- Marketing & Growth Metrics
    round(100 + (random() * 400), 2) as customer_acquisition_cost,        -- $100 to $500
    round(500 + (random() * 2000), 2) as customer_lifetime_value,         -- $500 to $2500
    round(50000 + (random() * 250000), 2) as monthly_recurring_revenue,
    round((random() * 30.0)::numeric, 2) as yoy_growth_percentage,         -- 0% to 30%
    
    -- Operations
    floor(50 + random() * 450)::int as employee_headcount,                 -- 50 to 500 employees
    round((random() * 15.0)::numeric, 2) as employee_turnover_rate,        -- 0% to 15%
    round((75.0 + random() * 24.0)::numeric, 1) as customer_satisfaction_score -- 75 to 99 CSAT
FROM 
    -- Change '300' to any number to generate more or fewer rows
    generate_series(1, 300) as g(i),
    LATERAL (SELECT round((500000 + random() * 4500000)::numeric, 2) as val) rev
ON CONFLICT (company_name, fiscal_year, fiscal_quarter) DO NOTHING;
