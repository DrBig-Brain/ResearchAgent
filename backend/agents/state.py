from langchain_core.messages import BaseMessage
from typing import TypedDict, List

class AgentState(TypedDict):
    messages : List[BaseMessage]