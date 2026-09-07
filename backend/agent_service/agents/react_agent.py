from langchain_core.prompts import ChatPromptTemplate
from agents.state import AgentState
from services.llm_service import llm_with_tools
from langgraph.graph import StateGraph, START, END
from tools.tavily_search_tool import TavilySearchTool
from tools.db_query_tool import SqlQueryTool
from langchain_core.messages import ToolMessage, HumanMessage

def llm_node(state : AgentState) -> AgentState:

    message = state['messages']

    prompt = ChatPromptTemplate.from_messages(
        [ 
            ("system","You are an expert analyst with access to Tavily Search tool to browse the internet and a SQL Query tool to query a Postgresql db for information, your task is to use these resources to return actionalbe insighs on company's financial report"),
            ("human","{input}")
        ]
    )

    chain = prompt | llm_with_tools
    response = chain.invoke({"input": message})

    state['messages'] = message + [response]

    return state

def tool_node(state : AgentState) -> AgentState:
    messages = state['messages']

    tools = [SqlQueryTool, TavilySearchTool]
    tool_by_name = {tool.name : tool for tool in tools}

    tool_results = []

    for tool_call in messages[-1].tool_calls:
        tool = tool_by_name[tool_call["name"]]
        observation = tool.invoke(tool_call["args"])

        tool_results.append(ToolMessage(content = observation, tool_call_id = tool_call["id"]))

    state["messages"] = messages + tool_results

    return state

def if_tool_call(state : AgentState) -> str:
    last_message = state["messages"][-1]
    if last_message.tool_calls:
        return "tool_node"
    else:
        return "end"

graph = StateGraph(AgentState)

graph.add_node("llm_node",llm_node)
graph.add_node("tool_node",tool_node)

graph.add_edge(START,"llm_node")
graph.add_conditional_edges("llm_node",if_tool_call,{"tool_node": "tool_node", "end" : END})
graph.add_edge("tool_node","llm_node")
graph.add_edge("llm_node",END)

ReactAgent = graph.compile()

if __name__ == "__main__":
    response = ReactAgent.invoke({"messages":HumanMessage(content = ["who is the current CEO of Apple ?"])})
    messages = response["messages"]
    print(messages[-1].content)