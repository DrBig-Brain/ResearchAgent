import os
from dotenv import load_dotenv
from langchain_groq import ChatGroq

from tools.db_query_tool import SqlQueryTool
from tools.tavily_search_tool import TavilySearchTool

load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
llm = ChatGroq(model = "qwen/qwen3.6-27b",api_key=GROQ_API_KEY)

tools = [SqlQueryTool, TavilySearchTool]

llm_with_tools = llm.bind_tools(tools)

if __name__ == "__main__":
    print(llm_with_tools.invoke("How did amazon perform in q2 of 2026 against microsoft").tool_calls)