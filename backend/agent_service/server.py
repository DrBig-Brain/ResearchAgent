from fastapi import FastAPI
from agents.react_agent import ReactAgent
from pydantic import BaseModel
from langchain_core.messages import HumanMessage

class Input(BaseModel):
    user_input : str

app = FastAPI()

@app.get("/health")
def health():
    return {
        "status" : 201,
        "message" : "server seems to be working"
    }

@app.get("/request")
def request(user_input : Input):
    user_input = user_input.model_dump()["user_input"]
    response = ReactAgent.invoke({"messages":HumanMessage(content = [user_input])})
    messages = response["messages"]
    final_ans = messages[-1].content
    return {
        "user_input" : user_input,
        "response" : final_ans
    }