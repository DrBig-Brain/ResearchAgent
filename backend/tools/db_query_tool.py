import os
from dotenv import load_dotenv
from langchain.tools import tool
from langchain_groq import ChatGroq
import psycopg2
from psycopg2.errors import Error

@tool
def SqlQueryTool(query : str):
    """SQL QUERY TOOL
        Use This tool to fetch the data about comapnies performance from a local postgresql database
        from the table company_performance with columns as given below:

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
                    
        Args:
            query : SQL query to select relevant data from the database.
        Return:
            a list of rows fetched from the database
        Raises:
            A psycopg2 error
    """
    load_dotenv()
    db_config = {
        "db_name": "company_performance",
        "user": "user",
        "password": os.getenv("DB_PASSWORD"),
        "host": os.getenv("HOST"),
        "port": os.getenv("PORT"),
    }
    try:
        with psycopg2.connect(**db_config) as conn:
            with conn.cursor as cur:    
                cur.execute(query)
                print("query executed successfully")
                rows = cur.fetchall()
                return rows
    
    except Exception as error:
        print(f"Database error occured {error}")
        return error

if __name__ == "__main__":
    load_dotenv()
    GROK_API_KEY = os.getenv("GROK_API_KEY")
    llm = ChatGroq(model = "qwen/qwen3.6-27b",api_key=GROK_API_KEY)
    llm_t = llm.bind_tools([sql_query_tool])
    print(llm_t.invoke("How did apple perform in January 2026 ?").tool_calls)