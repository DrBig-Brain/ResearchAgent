# 🧠 Autonomous Multi-Source Research Agent

An intelligent, self-correcting research agent that fuses structured database queries with live web search to produce schema-validated, Markdown-formatted research reports — all driven by natural language.

---

## 📌 Problem Statement

Modern knowledge work requires synthesizing information from radically different data sources — structured databases, live web content, and conversational context — and presenting it in a clean, reliable format.

A query like:

> *"Compare the Q3 2024 financial performance of Apple and Microsoft, cross-reference it with recent tech news, and return a ranked Markdown summary table"*

…used to require manual database querying, multi-source browsing, data reconciliation, and hand-formatting. This agent does all of that autonomously.

---

## 🎯 What It Does

| Capability | Description |
|---|---|
| 🤖 Thinks before acting | Uses a ReAct loop to plan which tools to call and in what order |
| 🗄️ Reads structured data | Queries a PostgreSQL database using natural language → SQL |
| 🌐 Reads unstructured data | Fetches live web search results via Tavily Search API |
| 🔗 Fuses both sources | Synthesizes SQL rows + web snippets into a single coherent response |
| 📐 Guarantees output shape | Enforces a strict Pydantic schema so output is always predictable |
| 🧠 Remembers context | Maintains conversational memory across multi-turn queries |
| 🔁 Self-corrects | Detects tool failures and retries or falls back gracefully |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                           │
│              (Streamlit Web App / Terminal CLI)                  │
└─────────────────────────┬───────────────────────────────────────┘
                          │  Natural Language Query
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                     LANGGRAPH ORCHESTRATOR                       │
│                                                                  │
│   ┌──────────┐    ┌──────────────┐    ┌──────────────────────┐  │
│   │  PLAN    │───▶│  TOOL CALL   │───▶│  EVALUATE / REFLECT  │  │
│   │  Node    │    │  Node        │    │  Node                │  │
│   └──────────┘    └──────────────┘    └──────────┬───────────┘  │
│        ▲                                          │              │
│        └──────────── Retry Loop ─────────────────┘              │
│                                                  │              │
│                                                  ▼              │
│                                        ┌─────────────────┐      │
│                                        │  FINALIZE Node  │      │
│                                        └─────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
   ┌─────────────┐ ┌────────────┐ ┌─────────────────┐
   │ PostgreSQL  │ │ Tavily Web │ │  Chat Memory    │
   │  Database   │ │  Search    │ │  (Checkpointer) │
   └─────────────┘ └────────────┘ └─────────────────┘
          │               │
          └───────┬───────┘
                  ▼
        ┌──────────────────┐
        │  Pydantic Output │
        │  Parser / Schema │
        └──────────────────┘
                  │
                  ▼
        ┌──────────────────┐
        │  Final Response  │
        │  (JSON/Markdown) │
        └──────────────────┘
```

---

## ⚙️ Tech Stack

| Layer | Technology |
|---|---|
| Orchestration | LangGraph |
| LLM | OpenAI GPT-4o / Anthropic Claude |
| Agent Pattern | ReAct (Reasoning + Acting) |
| Structured DB | **PostgreSQL** + SQLDatabaseChain |
| Live Search | Tavily Search API |
| Output Parsing | Pydantic v2 + `.with_structured_output()` |
| Memory | LangGraph SqliteSaver |
| UI | Streamlit / Rich CLI |
| Testing | pytest |

---

## 📁 Project Structure

```
research-agent/
│
├── main.py                    # Entry point (CLI or Streamlit launcher)
│
├── agent/
│   ├── graph.py               # LangGraph state machine definition
│   ├── state.py               # AgentState TypedDict schema
│   ├── nodes.py               # plan_node, tool_node, evaluate_node, finalize_node
│   └── prompts.py             # System prompt + ReAct template
│
├── tools/
│   ├── sql_tool.py            # PostgreSQL query wrapper + @tool
│   ├── web_search_tool.py     # Tavily API wrapper + @tool
│   └── calculator_tool.py     # Safe math evaluator + @tool
│
├── database/
│   ├── schema.sql             # PostgreSQL table definitions
│   └── seed_data.py           # Script to populate DB with sample data
│
├── schemas/
│   └── output_schema.py       # Pydantic ResearchReport + CompanyMetric
│
├── memory/
│   └── checkpointer.py        # SqliteSaver or MemorySaver setup
│
├── ui/
│   ├── streamlit_app.py       # Streamlit web interface
│   └── cli_app.py             # Rich terminal interface
│
├── tests/
│   ├── test_tools.py          # Unit tests for each tool
│   ├── test_graph.py          # Integration tests for graph flow
│   └── test_output_schema.py  # Pydantic validation tests
│
├── .env                       # API keys (never commit this)
├── .env.example               # Template for required env vars
├── requirements.txt           # All dependencies
└── README.md
```

---

## 🚀 Getting Started

### 1. Prerequisites

- Python 3.11+
- PostgreSQL 15+ (running locally or via a managed service)
- A [Tavily API key](https://tavily.com)
- An OpenAI or Anthropic API key

### 2. Clone the Repository

```bash
git clone https://github.com/DrBig-Brain/research-agent.git
cd research-agent
```

### 3. Set Up a Virtual Environment

```bash
python -m venv venv
source venv/bin/activate        # On Windows: venv\Scripts\activate
```

### 4. Install Dependencies

```bash
pip install -r requirements.txt
```

### 5. Configure Environment Variables

Copy the example env file and fill in your credentials:

```bash
cp .env.example .env
```

```env
# .env

# LLM Provider (use one)
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here

# Tavily Web Search
TAVILY_API_KEY=your_tavily_key_here

# PostgreSQL Connection
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=research_agent
POSTGRES_USER=your_pg_user
POSTGRES_PASSWORD=your_pg_password
```

### 6. Set Up the PostgreSQL Database

Make sure your PostgreSQL server is running, then create the database and seed it:

```bash
# Create the database
psql -U your_pg_user -c "CREATE DATABASE research_agent;"

# Apply the schema
psql -U your_pg_user -d research_agent -f database/schema.sql

# Seed with sample data
python database/seed_data.py
```

The `earnings` table schema looks like this:

```sql
CREATE TABLE earnings (
    id           SERIAL PRIMARY KEY,
    company      TEXT NOT NULL,
    quarter      TEXT NOT NULL,
    revenue_bn   NUMERIC(10, 2),
    net_income_bn NUMERIC(10, 2),
    eps          NUMERIC(6, 2),
    yoy_growth   NUMERIC(6, 2)
);
```

---

## ▶️ Running the Agent

### Streamlit Web UI

```bash
streamlit run ui/streamlit_app.py
```

Then open [http://localhost:8501](http://localhost:8501) in your browser.

### Terminal CLI

```bash
python main.py
```

---

## 💡 Example Query

```
> Compare Q3 2024 earnings of Apple vs Microsoft with recent analyst news
```

**What happens under the hood:**

1. `plan_node` — LLM decides to call both `sql_query_tool` and `web_search_tool` in parallel
2. `sql_query_tool` — translates the query to SQL, hits PostgreSQL, returns revenue/EPS rows
3. `web_search_tool` — fetches top 5 Tavily results with analyst commentary
4. `evaluate_node` — confirms data is sufficient, no retry needed
5. `finalize_node` — calls `.with_structured_output(ResearchReport)` to enforce the Pydantic schema

**Sample output:**

```markdown
| Company   | Revenue  | Net Income | EPS  | YoY Growth | Sentiment |
|-----------|----------|------------|------|------------|-----------|
| Apple     | $94.9B   | $21.7B     | 1.46 | +5.8%      | Positive  |
| Microsoft | $65.6B   | $22.3B     | 3.30 | +16.0%     | Positive  |

**Summary:** Microsoft outpaced Apple in net income and YoY growth in Q3 2024...

**Recommendation:** Microsoft shows stronger earnings momentum heading into Q4.

**Sources:** [reuters.com/...], [bloomberg.com/...]
```

---

## 🧩 Output Schema

Every response is validated against a strict Pydantic schema — no hallucinated fields, no missing data.

```python
class CompanyMetric(BaseModel):
    company: str
    revenue_bn: float
    net_income_bn: float
    eps: float
    yoy_growth_pct: float
    news_summary: str
    analyst_sentiment: str  # "Positive" | "Neutral" | "Negative"

class ResearchReport(BaseModel):
    query: str
    companies: List[CompanyMetric]
    comparison_summary: str
    recommendation: str
    sources: List[str]
    generated_at: str       # ISO 8601 timestamp
```

---

## 🔄 Multi-Turn Memory

The agent remembers context across turns within a session:

```
Turn 1: "Compare Apple and Microsoft Q3 earnings"
         → Agent fetches both, stores result in checkpointer

Turn 2: "Now add Google to that comparison"
         → Agent recalls previous context, fetches only Google,
           merges — no redundant API calls
```

---

## 🧪 Running Tests

```bash
pytest tests/ -v
```

| Test File | What It Covers |
|---|---|
| `test_tools.py` | Unit tests for each tool in isolation |
| `test_graph.py` | Integration tests for the full LangGraph flow |
| `test_output_schema.py` | Pydantic schema validation edge cases |

---

## 🚧 Key Engineering Challenges

| Challenge | Solution |
|---|---|
| Unstructured + structured data fusion | Agent merges PostgreSQL rows and web snippets via synthesis prompt |
| Hallucinated output format | `.with_structured_output(ResearchReport)` enforces strict schema |
| Tool failures / API timeouts | `evaluate_node` detects failures, retry loop (max 3 attempts) |
| Redundant API calls across turns | LangGraph `SqliteSaver` checkpointer persists state across turns |
| Natural language → valid SQL | `SQLDatabaseChain` with PostgreSQL dialect awareness |

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">Built with LangGraph · PostgreSQL · Tavily · Pydantic</p>