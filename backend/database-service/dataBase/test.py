
from dotenv import load_dotenv
import os
import psycopg2
from psycopg2.errors import Error

load_dotenv()
db_config = {
    "database": "companies",
    "user": "user",
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("HOST"),
    "port": os.getenv("PORT"),
}
try:
    with psycopg2.connect(**db_config) as conn:
        with conn.cursor() as cur:    
            cur.execute("SELECT * FROM company_performance")
            print("query executed successfully")
            rows = cur.fetchall()
            for row in rows:
                print(rows)
    
except Exception as error:
    print(f"Database error occured {error}")
    print(error)