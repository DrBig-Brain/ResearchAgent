# 🧠 ResearchAgent

ResearchAgent is a multi-service research assistant that turns natural-language questions into structured research workflows. The system combines a user-data management service, a backend service for database connection intake, and an agent service that performs reasoning, planning, tool calling, and response synthesis.

The project is designed around a clear separation of responsibilities:

- The TypeScript user-service manages user profiles and user-level data.
- The backend-service collects the PostgreSQL address, password, and database name from the user and forwards that configuration to the agent layer.
- The agent-service remains the execution brain of the system: it reasons, chooses tools, runs database queries, calls the web search tool, and shapes the final research output.
- PostgreSQL is not provisioned by the platform. The user provides their own cloud PostgreSQL instance, and the backend service receives the connection information from that instance.

---

## 📌 Problem Statement

Research teams often need to answer questions that require more than one type of evidence:

- Structured information from a database
- Fresh public information from the web
- Conversation context and user preferences

Manual research is slow and error-prone. ResearchAgent coordinates these sources through a service-oriented architecture and gives the user a natural-language research experience.

---

## 🎯 What the System Does

| Capability | Description |
|---|---|
| 🧠 Reasoning loop | Uses a ReAct-style agent loop to decide which tools to call and in what order |
| 🗄️ Structured research | Queries PostgreSQL using natural language through the agent service |
| 🌐 Live research | Uses Tavily search for current web evidence |
| 👤 User data | Stores and manages user data through the user-service in TypeScript |
| 🧾 Database configuration | Backend-service accepts PostgreSQL address, password, and database name from the user |
| 📄 Output synthesis | Returns a clean, schema-shaped research answer |

---

## 🏗️ Architecture Overview

```text
┌──────────────────────────────────────────────────────────────┐
│                         APP / CLIENT                          │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                    USER-SERVICE (TypeScript)                  │
│      Stores and manages user profile and user-level data     │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                 BACKEND-SERVICE (TypeScript)                  │
│ Collects PostgreSQL details from the user:                   │
│   - database host / address                                   │
│   - password                                                  │
│   - database name                                              │
│ It does not host PostgreSQL for the user.                    │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                    AGENT-SERVICE (Python)                     │
│ Executes the reasoning workflow and calls tools              │
│ - ReAct agent planning                                       │
│ - DB query tool                                               │
│ - Tavily web search tool                                      │
│ - Output formatting and synthesis                             │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                   USER-PROVIDED CLOUD POSTGRES                 │
│      The user supplies the address, password, and db name     │
│      from their own PostgreSQL cloud instance                 │
└──────────────────────────────────────────────────────────────┘
```

---

## ⚙️ Service Responsibilities

### 1. User Service

The user-service is a TypeScript service responsible for creating and managing user records, authentication-related profile information, and any user-centered metadata required by the application.

### 2. Backend Service

The backend-service is responsible for collecting the PostgreSQL connection information from the user:

- PostgreSQL database address / host
- Password
- Database name

This backend layer should never create or host a PostgreSQL instance for the user. It is only the intake and configuration surface that receives the user’s own cloud database credentials.

### 3. Agent Service

The agent-service is the orchestration and intelligence layer. It should be used for what it is best fitted for:

- receiving user queries
- reasoning over the request
- deciding which tools to call
- calling the database query tool against the user-provided PostgreSQL endpoint
- calling the Tavily web search tool
- composing the final research answer

The agent-service should not be repurposed to manage user data or to host the database experience for the end user.

---

## 📁 Repository Structure

```text
research-agent/
├── app/                      # User-facing application surface
├── backend/
│   ├── user-service/         # TypeScript user-data management service
│   ├── backend-service/      # TypeScript service that collects PostgreSQL credentials
│   ├── agent_service/         # Python agent engine, ReAct loop, tools, and server
│   └── database-service/     # Optional database-related support service or artifacts
└── README.md
```

---

## 🔧 Environment and Runtime Contract

The platform expects the following runtime contract:

1. A user registers or signs in through the TypeScript user-service.
2. The user provides a PostgreSQL cloud instance address, password, and database name through the backend-service.
3. The backend-service passes that configuration into the agent-service workflow.
4. The agent-service uses the configured database connection and Tavily API access to produce research output.

The PostgreSQL instance is external and must be supplied by the user or an infrastructure owner. ResearchAgent does not host or provision PostgreSQL for the end user.

---

## 🚀 Local Development

### Prerequisites

- Node.js for the TS services
- Python 3.11+ for the agent service
- Access to a cloud PostgreSQL instance
- A Tavily API key
- An LLM provider API key

### Service Startup

The TypeScript services should be started from their respective folders:

```bash
cd backend/user-service
npm install
npm run dev
```

```bash
cd backend/backend-service
npm install
npm run dev
```

The Python agent service should remain the execution service:

```bash
cd backend/agent_service
pip install -r requirements.txt
python server.py
```

---

## 🧪 Testing

The testing strategy should validate the separation of responsibilities:

- User-service tests verify user data persistence and profile management
- Backend-service tests verify credential intake and validation behavior
- Agent-service tests verify tool calling, the reasoning loop, database query execution, and final response composition

---

## 🤝 Contributing

Contributions are welcome. Please keep the architecture boundaries clear:

- Do not move user-data management into the agent service
- Do not let the agent service become a credentials intake or database provisioning layer
- Keep the backend-service focused on asking the user for PostgreSQL connection details
- Make the agent-service remain the reasoning and execution engine

---

## 📄 License

MIT License. See the license file in the repository for details.
