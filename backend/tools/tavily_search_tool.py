import os
from dotenv import load_dotenv
from langchain.tools import tool
from langchain_tavily import TavilySearch
from langchain_groq import ChatGroq

@tool
def TavilySearchTool(query : str):
    """This is tool is to be used when the llm or you need to access the internet for context regarding the research and provide the user with the proper structured and complete response"""
    load_dotenv()
    search = TavilySearch(
        max_result = 3,
        search_depth = 'basic',
        include_answer = True
    )

    return search.invoke({"query" : query})

if __name__ == "__main__":
    load_dotenv()
    GROK_API_KEY = os.getenv("GROK_API_KEY")
    llm = ChatGroq(model = "qwen/qwen3.6-27b",api_key=GROK_API_KEY)
    llm_t = llm.bind_tools([TavilySearchTool])
    print(llm_t.invoke("Who is the current president of the United Kingdom").tool_calls)