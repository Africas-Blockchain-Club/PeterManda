# Building AI Agents from Scratch: Complete Educational Guide

**Author's Note:** This guide uses British English standards and is designed for education leaders and technical curriculum developers. Built on Google Gemini 3 Pro's "AI Mentor" architecture.

---

## Table of Contents

1. [What is an AI Agent?](#what-is-an-ai-agent)
2. [Core Concepts Every Agent Needs](#core-concepts-every-agent-needs)
3. [How Agents Actually Work: The Loop](#how-agents-actually-work-the-loop)
4. [Agent Frameworks & Tools Comparison](#agent-frameworks--tools-comparison)
5. [Step-by-Step: Building Your Mentor Agent](#step-by-step-building-your-mentor-agent)
6. [Understanding the Mentor Agent Code](#understanding-the-mentor-agent-code)
7. [Common Patterns & When to Use Them](#common-patterns--when-to-use-them)
8. [Next Steps: Extending Your Agent](#next-steps-extending-your-agent)

---

## What is an AI Agent?

### Simple Definition

An **AI Agent** is a software system that:
- **Perceives** the environment (receives a task/question)
- **Reasons** about what to do (using an LLM)
- **Takes action** (calls tools/functions to solve the problem)
- **Repeats** until the goal is achieved

### Key Distinction: Assistant vs Agent

| Aspect | Chat Assistant | AI Agent |
|--------|----------------|----------|
| **Capability** | Responds to questions | Completes tasks |
| **Interaction** | Single query → Response | Multi-step reasoning loop |
| **Action** | Generates text | Executes tools/functions |
| **Example** | ChatGPT | Mentor Agent auditing your repo |

### Why Agents Matter

**Traditional workflow:**
```
User: "Audit my GitHub repository"
ChatGPT: "Here are suggestions..."
User: Must manually check files, read docs, etc.
```

**Agentic workflow:**
```
User: "Audit my GitHub repository"
Agent: Automatically clones repo → reads files → analyses → produces report
Result: Actionable strategic plan
```

---

## Core Concepts Every Agent Needs

### 1. **The LLM (Large Language Model)**

The "brain" of your agent. Decides *what* to do, not *how* to do it.

**Options:**
- OpenAI (GPT-4, GPT-4o) — most capable
- Anthropic (Claude 3.5 Sonnet) — great reasoning
- Google (Gemini Pro) — multimodal
- Open-source (Llama, Mistral) — free, self-hosted
- DeepSeek — low cost

**Your agent code:** Uses **LiteLLM** to switch between any of these seamlessly.

### 2. **Tools (Functions)**

External actions your agent can invoke. Tools are *not* decisions—they're capabilities.

**Examples in Mentor Agent:**
- `get_file_tree()` — List repository structure
- `read_file()` — Read file contents

**Tool Definition (Schema):**
```python
{
    "type": "function",
    "function": {
        "name": "get_file_tree",
        "description": "Get the file structure to understand project layout.",
        "parameters": {"type": "object", "properties": {}}
    }
}
```

The LLM *decides* to use a tool. Your code *executes* it.

### 3. **The System Prompt**

Instructions that shape the agent's behaviour. Think of it as the agent's "constitution."

**Mentor Agent's prompt includes:**
- Primary objective (audit code, produce prioritised action plan)
- Specific audit process (check docs first, then code)
- Output format (Markdown structure)
- Priorities (docs before code analysis)

### 4. **The Agent Loop (Agentic Reasoning)**

The repeating cycle that makes agents work:

```
1. Agent receives task
   ↓
2. LLM analyzes task + tools available + context
   ↓
3. LLM decides: "I should call tool X with parameters Y"
   ↓
4. System executes tool X
   ↓
5. Result added back to conversation
   ↓
6. LLM decides: Continue loop or return final answer?
   ↓
7. If continue → Go to step 2
   If complete → Return response
```

**Code pattern (from your Mentor Agent):**
```python
while len(self.messages) < self.max_iterations:
    # Get LLM decision
    response = completion(model=..., messages=..., tools=...)
    
    # If no tools called, we're done
    if not response.tool_calls:
        return response.content
    
    # Otherwise, execute tools and loop again
    for tool in response.tool_calls:
        result = execute_tool(tool)
        messages.append(result)
```

### 5. **Message History (Conversation Memory)**

The agent maintains a conversation thread. Each turn adds to it:

```
[
  {"role": "system", "content": "You are a mentor..."},
  {"role": "user", "content": "Audit this repo"},
  {"role": "assistant", "tool_calls": [{"name": "get_file_tree"}]},
  {"role": "tool", "content": "[file structure]"},
  ...
]
```

This allows the LLM to:
- Remember previous findings
- Build context for decisions
- Avoid redundant calls

---

## How Agents Actually Work: The Loop

### Visual: The Agentic Decision Flow

```
┌─────────────────────────────────┐
│     User Query / Task           │
│  "Audit my GitHub repository"   │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  LLM Receives:                  │
│  • Task description             │
│  • Tools available              │
│  • Previous context (if any)    │
└──────────────┬──────────────────┘
               │
               ▼
        ┌──────────────┐
        │ LLM Decides  │
        │ Next Action  │
        └──────┬───────┘
               │
        ┌──────┴────────┐
        │               │
    ✓ Call Tool?    ✗ Final Answer?
        │               │
        ▼               ▼
   Execute Tool    Return Response
   (Python code)   (End agent)
        │
        ▼
   Add Result to
   Message History
        │
        ▼
   ┌──────────────┐
   │ Loop Again?  │
   └──────┬───────┘
          │
    ┌─────┴──────┐
    │            │
   Yes          No
    │            │
    ▼            ▼
(Continue)   (End agent)
```

### Real Example: Mentor Agent Execution

**Step 1: Initial Request**
```
User: "Start the audit."
System Prompt: "Check README first, then code..."
Available Tools: get_file_tree, read_file
```

**Step 2: LLM Decides**
```
"I need to understand the project structure first.
I should call get_file_tree."
```

**Step 3: System Executes**
```python
result = get_file_tree(repo_path)
# Returns: "/ | setup.py | requirements.txt | README.md | src/ | tests/..."
```

**Step 4: Add to History & Loop**
```
messages.append({
    "role": "tool",
    "content": "[file structure]"
})
# Loop continues, LLM now says:
# "I see a README. Let me read it to check documentation."
```

**Step 5: LLM Calls read_file**
```
"I should call read_file with path='README.md'"
```

**Step 6: Continue Until Done**
```
After several iterations:
LLM: "I have enough information. Here is the audit report..."
(No tool_calls returned)
Agent returns: The audit markdown report
```

---

## Agent Frameworks & Tools Comparison

### Quick Comparison Table

| Tool/Framework | Type | Best For | Learning Curve | Cost |
|---|---|---|---|---|
| **LiteLLM** (bare) | Library | Control + multi-model flexibility | Medium | Free (API costs) |
| **n8n** | No-code/Low-code | Visual workflows, automations | Easy | Free (self-host) or paid |
| **Zapier** | No-code | Quick integrations, non-technical teams | Very Easy | Expensive |
| **OpenAI Agents SDK** | Framework | Lightweight agent apps | Medium | Free (API costs) |
| **LangChain** | Framework | Complex agent logic, RAG | Hard | Free (API costs) |
| **LangGraph** | Framework | Multi-step workflows with visualization | Hard | Free (API costs) |
| **CrewAI** | Framework | Multi-agent teams, role-based tasks | Medium | Free (API costs) |
| **Semantic Kernel** | Framework | Enterprise, .NET/Python/Java | Hard | Free (API costs) |
| **Letta (MemGPT)** | Framework | Stateful agents with memory | Hard | Free (API costs) |
| **Flowise** | Visual | Low-code agent builder | Easy | Free (self-host) |
| **VectorShift** | No-code | AI workflows with data | Easy | Freemium |
| **Make.com** | No-code | Moderate complexity workflows | Medium | Moderate cost |
| **Buildship** | Low-code | Backend workflows + APIs | Medium | Freemium |

### Your Options Beyond n8n & Zapier

#### 1. **LiteLLM (What Your Mentor Agent Uses)**
```python
# One line switches between any model
completion(model="gpt-4o", messages=...)
completion(model="claude-3-5-sonnet", messages=...)
completion(model="gemini/gemini-1.5-pro", messages=...)
```
- ✅ Maximum control
- ✅ Multi-model flexibility
- ✅ Production-grade
- ❌ Requires Python coding

#### 2. **OpenAI Agents SDK**
```python
from openai_agents import Agent
agent = Agent(instructions="...", tools=[...])
```
- ✅ Simple, lightweight
- ✅ Official OpenAI
- ❌ OpenAI-only models
- ❌ Less mature than LangChain

#### 3. **LangChain**
```python
from langchain.agents import initialize_agent
agent = initialize_agent(tools, llm, agent="zero-shot-react-description")
```
- ✅ Mature ecosystem
- ✅ Excellent documentation
- ✅ RAG integration built-in
- ❌ Steep learning curve
- ❌ Heavy dependencies

#### 4. **CrewAI (Multi-Agent)**
```python
crew = Crew(agents=[agent1, agent2], tasks=[task1, task2])
result = crew.kickoff()
```
- ✅ Role-based agents
- ✅ Emergent behaviour between agents
- ✅ Intuitive API
- ❌ Less flexible than LangChain
- ❌ Newer framework

#### 5. **Flowise (Visual No-Code)**
- ✅ Drag-and-drop UI
- ✅ Self-hosted
- ✅ No coding required
- ❌ Less powerful than code-based solutions
- ❌ Smaller community

#### 6. **Semantic Kernel (Enterprise)**
```python
kernel = Kernel()
kernel.add_function(my_python_func)
result = kernel.invoke(my_prompt)
```
- ✅ Multi-language (.NET, Python, Java)
- ✅ Enterprise-grade
- ✅ Azure integration
- ❌ Verbose syntax
- ❌ Steeper learning curve

### Decision Matrix: Choose Your Framework

**Choose LiteLLM (Your Mentor Agent) if:**
- ✅ You need maximum control
- ✅ You want to switch LLM providers easily
- ✅ You're building custom agent logic
- ✅ You understand Python

**Choose OpenAI Agents SDK if:**
- ✅ You only use OpenAI models
- ✅ You want simplicity
- ✅ You don't need multi-model flexibility

**Choose LangChain if:**
- ✅ You need RAG (document retrieval)
- ✅ You want a mature ecosystem
- ✅ You're building complex agent chains
- ⚠️ Be prepared for complexity

**Choose CrewAI if:**
- ✅ You need multiple agents working together
- ✅ You want role-based task distribution
- ✅ You prioritise intuitive syntax

**Choose n8n if:**
- ✅ You want visual workflows
- ✅ You're not coding heavy
- ✅ You need to connect 100+ apps
- ✅ You want to self-host

**Choose Zapier if:**
- ✅ You're non-technical
- ✅ You need quick integrations
- ⚠️ Budget for monthly costs

**Choose Flowise if:**
- ✅ You want no-code agent building
- ✅ You're comfortable with UI builders
- ✅ You want to self-host

---

## Step-by-Step: Building Your Mentor Agent

### Phase 1: Environment Setup

#### Step 1.1: Create a Project Directory

```bash
mkdir mentor-agent
cd mentor-agent
```

#### Step 1.2: Create requirements.txt

Create file: `requirements.txt`

```
litellm>=1.35.0
gitpython>=3.1.40
colorama>=0.4.6
openai>=1.0.0
```

**Why each dependency:**
- **litellm** — Universal LLM interface (switch models with one line)
- **gitpython** — Clone GitHub repos programmatically
- **colorama** — Coloured console output (visual feedback)
- **openai** — For when using OpenAI models directly (fallback)

#### Step 1.3: Install Dependencies

```bash
pip install -r requirements.txt
```

#### Step 1.4: Set API Key

**Option A: Linux/Mac (Recommended)**
```bash
export API_KEY="sk-your-api-key-here"
```

**Option B: Windows (PowerShell)**
```powershell
$env:API_KEY="sk-your-api-key-here"
```

**Option C: Create .env file (for development)**
```bash
# .env
API_KEY=sk-your-api-key-here
```

Then load in Python:
```python
from dotenv import load_dotenv
load_dotenv()
api_key = os.getenv("API_KEY")
```

---

### Phase 2: Understanding the Agent Structure

Your Mentor Agent consists of **4 core components**:

#### Component 1: MentorAgent Class
The container that manages the entire agent.

```python
class MentorAgent:
    def __init__(self, model_name, api_key, repo_url, token=None):
        # Store configuration
        self.model_name = model_name      # Which LLM to use
        self.api_key = api_key            # Authentication
        self.repo_url = repo_url          # Target repository
        self.token = token                # GitHub token (optional)
        self.messages = []                # Conversation history
        self.max_iterations = 20          # Safety limit
```

#### Component 2: Tools (What the Agent Can Do)

```python
def get_file_tree(self, local_path):
    """Returns visual tree of repo structure"""
    
def read_file(self, local_path, relative_path):
    """Reads and returns file contents"""
```

These are the agent's "hands and eyes"—what it can actually do.

#### Component 3: System Prompt (The Agent's Instructions)

```python
system_prompt = """
You are a Senior Technical Project Manager...
1. Discovery: Call get_file_tree
2. Documentation Check: Read README.md
3. Code Quality Check: Pick 3 crucial files
...
"""
```

This shapes the agent's behaviour and decision-making priorities.

#### Component 4: The Agent Loop

```python
while len(self.messages) < self.max_iterations:
    # Call LLM
    response = completion(model=..., messages=..., tools=...)
    
    # If no tools, we're done
    if not response.tool_calls:
        return response.content
    
    # Execute tools and continue
    for tool in response.tool_calls:
        result = execute_tool(tool)
        messages.append(result)
```

---

### Phase 3: Creating Your First Agent

#### Create File: `review_agent.py`

Copy the Mentor Agent code from Google Gemini 3 Pro (provided in your query). I'll walk through each section below.

#### Section A: Imports & Initialisation

```python
import os
import json
import tempfile
import git
import fnmatch
from pathlib import Path
from colorama import Fore, Style, init
from litellm import completion

# Coloured console output
init(autoreset=True)
```

**What each import does:**
- `os` — Environment variables, file operations
- `json` — Parse LLM tool call responses
- `tempfile` — Create temporary directories (clone repo safely)
- `git` — Clone repositories
- `fnmatch` — Pattern matching (ignore files like `.git`, `node_modules`)
- `pathlib.Path` — Modern file path handling
- `colorama` — Coloured terminal output
- `litellm.completion` — Call any LLM uniformly

#### Section B: Environment Setup

```python
def _setup_env_keys(self):
    """Map generic API key to provider-specific environment variables"""
    if "gpt" in self.model_name:
        os.environ["OPENAI_API_KEY"] = self.api_key
    elif "claude" in self.model_name:
        os.environ["ANTHROPIC_API_KEY"] = self.api_key
    elif "gemini" in self.model_name:
        os.environ["GEMINI_API_KEY"] = self.api_key
```

**Why this matters:**
- Different providers expect different environment variable names
- LiteLLM reads these automatically
- This method abstracts that complexity

#### Section C: Clone Repository

```python
def clone_repo(self, local_path):
    """Clone target repository securely"""
    url = self.repo_url
    
    # If GitHub token provided, embed it (for private repos)
    if self.token:
        if "https://" in url and "@" not in url:
            url = url.replace("https://", f"https://oauth2:{self.token}@")
    
    print(f"{Fore.CYAN}⬇️  Cloning repository...{Style.RESET_ALL}")
    try:
        git.Repo.clone_from(url, local_path)
        return True
    except Exception as e:
        print(f"{Fore.RED}❌ Clone failed: {e}{Style.RESET_ALL}")
        return False
```

**Key points:**
- Uses `tempfile` to keep repo isolated (cleaned up automatically)
- Supports both public and private repos
- Returns boolean for error handling

#### Section D: Tools (The Agent's Capabilities)

##### Tool 1: Get File Tree

```python
def get_file_tree(self, local_path):
    """
    Returns a visual tree of the repo structure.
    The agent uses this to understand the project layout.
    """
    ignore_patterns = {'.git', 'node_modules', '__pycache__', 'venv'}
    tree_str = ""
    
    for root, dirs, files in os.walk(local_path):
        # Filter ignored directories
        dirs[:] = [d for d in dirs if d not in ignore_patterns]
        
        # Calculate indentation based on depth
        level = root.replace(str(local_path), '').count(os.sep)
        indent = ' ' * 4 * level
        
        # Add directory to tree
        rel_path = os.path.basename(root)
        tree_str += f"{indent}{rel_path}/\n"
        
        # Add files
        for f in files:
            tree_str += f"{' ' * 4 * (level + 1)}{f}\n"
    
    return tree_str
```

**Output example:**
```
/
    setup.py
    requirements.txt
    README.md
    src/
        app.py
        utils.py
    tests/
        test_app.py
```

##### Tool 2: Read File

```python
def read_file(self, local_path, relative_path):
    """
    Reads file content with line numbers.
    The agent uses this to examine specific files.
    """
    full_path = Path(local_path) / relative_path
    
    try:
        # Security: ensure path is within repo
        full_path.resolve().relative_to(Path(local_path).resolve())
        
        # Safety: don't read huge files
        if full_path.stat().st_size > 50000:
            return "File too large to read directly."
        
        with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read(15000)  # First 15k chars
            lines = content.splitlines()
            
            # Add line numbers for reference
            return "\n".join([f"{i+1} | {line}" for i, line in enumerate(lines)])
    
    except Exception as e:
        return f"Error reading file: {e}"
```

**Key features:**
- **Security check** — Prevents reading files outside repo
- **Size limit** — Avoids overloading LLM with huge files
- **Line numbers** — Helps LLM reference specific lines
- **Encoding tolerance** — Handles binary-like text gracefully

---

#### Section E: The System Prompt (Agent's Instructions)

```python
system_prompt = """
You are a Senior Technical Project Manager and Lead Architect.

OBJECTIVE:
Conduct a strategic review of the codebase. Do NOT rewrite code.
Instead, produce a "Prioritised Action Plan" for the developer.

YOUR AUDIT PROCESS:
1. **Discovery:** Call `get_file_tree`. Analyse the structure.
2. **Documentation Check (CRITICAL):** Read README.md
   - Is it concise? Does it explain how to run the app?
   - Are dependencies clear?
3. **Code Quality Check:** Pick 3 crucial files. Look for:
   - Spaghetti code
   - Lack of comments
   - Security risks

OUTPUT FORMAT (Markdown):
# 📋 Strategic Codebase Audit

## 1. 🚨 Immediate Priorities
(Top 2-3 blocking issues)

## 2. 📚 Documentation Health
(README quality, onboarding ease)

## 3. 🏗 Architecture & Code Hygiene
(Structure feedback)

## 4. 🧭 Guided Next Steps
(Exactly what to do first)
"""
```

**Why this prompt matters:**
- **Prioritisation** — Documentation before code (catches onboarding issues)
- **Non-destructive** — Agent suggests, doesn't rewrite
- **Output format** — Structured Markdown for easy reading
- **Emoji markers** — Visual organisation for humans

---

#### Section F: The Main Agent Loop

```python
def run(self):
    """Execute the audit"""
    with tempfile.TemporaryDirectory() as tmp_dir:
        repo_path = Path(tmp_dir) / "repo"
        
        # Clone repo
        if not self.clone_repo(repo_path):
            return
        
        # Define tools for LLM
        tools = [
            {
                "type": "function",
                "function": {
                    "name": "get_file_tree",
                    "description": "Get file structure to understand project layout",
                    "parameters": {"type": "object", "properties": {}}
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "read_file",
                    "description": "Read file content",
                    "parameters": {
                        "type": "object",
                        "properties": {"path": {"type": "string"}},
                        "required": ["path"]
                    }
                }
            }
        ]
        
        # Initialise conversation
        self.messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": "Start the audit."}
        ]
        
        # Agent loop
        while len(self.messages) < self.max_iterations:
            print(f"{Fore.YELLOW}🤔 Analysing...{Style.RESET_ALL}")
            
            try:
                # Call LLM with tools available
                response = completion(
                    model=self.model_name,
                    messages=self.messages,
                    tools=tools,
                    tool_choice="auto"
                )
            except Exception as e:
                print(f"{Fore.RED}API Error: {e}{Style.RESET_ALL}")
                break
            
            msg = response.choices[0].message
            
            # If no tool calls, agent is done
            if not msg.tool_calls:
                print(f"{Fore.GREEN}✅ Audit Complete!{Style.RESET_ALL}")
                return msg.content
            
            # Add agent's decision to history
            self.messages.append(msg)
            
            # Execute each tool call
            for tool in msg.tool_calls:
                func_name = tool.function.name
                args = json.loads(tool.function.arguments)
                print(f"   🔎 Checking: {func_name}")
                
                # Execute the tool
                if func_name == "get_file_tree":
                    result = self.get_file_tree(repo_path)
                elif func_name == "read_file":
                    result = self.read_file(repo_path, args.get("path"))
                else:
                    result = "Unknown tool"
                
                # Add result back to conversation
                self.messages.append({
                    "role": "tool",
                    "tool_call_id": tool.id,
                    "content": result
                })
```

**The loop explained step-by-step:**

1. **Call LLM** — Pass messages + tools available
2. **LLM responds** — Either with tool calls or final answer
3. **Check if done** — If no tool_calls, return final answer
4. **Execute tools** — Run Python functions based on LLM's decision
5. **Add to history** — Tool results become part of conversation
6. **Loop** — LLM sees results, makes new decisions

---

### Phase 4: Running Your Agent

#### Step 4.1: Configure the Agent

At the bottom of `review_agent.py`:

```python
if __name__ == "__main__":
    # Choose your LLM provider
    MODEL = "gpt-4o"  # or "claude-3-5-sonnet-20240620", "gemini/gemini-1.5-pro"
    
    # Your API key
    API_KEY = os.getenv("API_KEY")
    
    # Repository to audit
    REPO = "https://github.com/your-username/your-target-repo.git"
    
    if not API_KEY:
        print("Please set API_KEY environment variable")
        exit(1)
    
    # Create and run agent
    agent = MentorAgent(model_name=MODEL, api_key=API_KEY, repo_url=REPO)
    report = agent.run()
    
    # Save report
    if report:
        with open("strategic_audit.md", "w", encoding="utf-8") as f:
            f.write(report)
        print(f"Report saved to: strategic_audit.md")
```

#### Step 4.2: Run the Agent

```bash
export API_KEY="your-actual-api-key"
python review_agent.py
```

#### Expected Output

```
⬇️  Cloning repository...
🧠 Mentor Agent initialised. Analysing project health...
🤔 Analysing...
   🔎 Checking: get_file_tree (root)
🤔 Analysing...
   🔎 Checking: read_file (README.md)
🤔 Analysing...
   🔎 Checking: read_file (requirements.txt)
...
✅ Audit Complete!

📄 Report saved to: strategic_audit.md
```

#### Step 4.3: View the Report

```bash
cat strategic_audit.md
# or open in editor
code strategic_audit.md
```

---

## Understanding the Mentor Agent Code

### Key Design Principles

#### 1. **The Conversation Pattern**

Agents maintain a conversation thread (like ChatGPT):

```
[System Prompt] ← Instructions for the agent
[User Query] ← Initial task
[Assistant Decision] ← "I'll call get_file_tree"
[Tool Result] ← "[file structure]"
[Assistant Decision] ← "Now I'll read README.md"
[Tool Result] ← "[readme content]"
[Assistant Final Answer] ← "Here's the audit report"
```

Each turn, the LLM sees *everything* before it. This allows:
- **Context awareness** — Agent remembers previous findings
- **Reasoning chains** — Decisions based on accumulated data
- **Graceful exits** — Agent stops when it has enough info

#### 2. **Tool Calling (Function Calling)**

The LLM doesn't execute tools—it *decides* to use them.

**Flow:**
```
LLM: "I need the file structure. Call get_file_tree."
↓
System: Executes get_file_tree()
↓
System: "Here's the result: [file tree]"
↓
LLM: "Now I'll read the README..."
```

**Why this matters:**
- LLM stays in its domain (reasoning)
- Your code stays in its domain (execution)
- Safe boundary between AI and real actions

#### 3. **Error Boundaries & Safety**

```python
# Security: prevent path traversal attacks
full_path.resolve().relative_to(Path(local_path).resolve())

# Safety: don't read huge files
if full_path.stat().st_size > 50000:
    return "File too large..."

# Safety: don't loop forever
while len(self.messages) < self.max_iterations:
    ...
```

#### 4. **Provider Abstraction with LiteLLM**

```python
# Same code, different providers
completion(model="gpt-4o", messages=..., tools=...)
completion(model="claude-3-5-sonnet", messages=..., tools=...)
completion(model="gemini/gemini-1.5-pro", messages=..., tools=...)
```

This is why LiteLLM is powerful—one codebase, unlimited model choices.

---

## Common Patterns & When to Use Them

### Pattern 1: Tool-Calling Agent (Your Mentor Agent)

**When to use:**
- Agent needs to execute functions/APIs
- You want control over execution
- Task requires multiple steps with decision-making

**Code structure:**
```python
# Define tools
tools = [{"name": "tool_name", "description": "...", "parameters": {...}}]

# Loop
while True:
    response = llm(tools=tools)
    if not response.tool_calls:
        return response.text
    
    for tool_call in response.tool_calls:
        result = execute_tool(tool_call)
        add_to_history(result)
```

**Real-world examples:**
- Repository auditor (your case)
- Financial calculators
- Customer support routing
- Data analysis systems

---

### Pattern 2: Agentic Reasoning Loop

**When to use:**
- Agent needs to "think through" problems
- Internal reasoning, not just tool-calling

**Code structure:**
```python
messages = [{"role": "user", "content": "Solve this problem"}]

for _ in range(max_iterations):
    response = llm(messages)
    
    # Agent writes internal reasoning
    reasoning = response.content
    messages.append({"role": "assistant", "content": reasoning})
    
    # User provides feedback or constraint
    messages.append({"role": "user", "content": "Continue..."})

return messages[-1].content
```

**Real-world examples:**
- Chain-of-thought problem solving
- Debugging assistants
- Research summarisers

---

### Pattern 3: Multi-Agent Orchestration

**When to use:**
- Multiple specialised agents needed
- Agents work together on complex tasks

**Code structure:**
```python
agent1 = Agent(role="Code Reviewer", ...)
agent2 = Agent(role="Security Analyst", ...)
agent3 = Agent(role="Documentation Checker", ...)

coordinator = Coordinator([agent1, agent2, agent3])
result = coordinator.run(task)
```

**Frameworks:**
- **CrewAI** — Best for this pattern
- **LangGraph** — Visual workflow orchestration
- **Custom Python** — Maximum control

**Real-world examples:**
- Comprehensive code audits (multiple agents)
- Sales teams (different roles collaborating)
- Research teams (each agent focuses on one aspect)

---

### Pattern 4: Retrieval-Augmented Generation (RAG)

**When to use:**
- Agent needs to answer from custom documents
- You have knowledge base to search

**Code structure:**
```python
# 1. Index documents
index = create_index(documents)

# 2. Agent retrieves relevant docs
def retrieve_docs(query):
    return index.search(query)

# 3. Agent reasons over retrieved docs
response = llm(
    prompt=f"Answer based on these docs: {docs}",
    user_query=user_query
)
```

**Frameworks:**
- **LlamaIndex** — Purpose-built for RAG
- **LangChain** — RAG + agents combined
- **Custom with embeddings** — Full control

**Real-world examples:**
- Enterprise documentation assistants
- Codebase Q&A systems
- Knowledge base chatbots

---

## Next Steps: Extending Your Agent

### Extension 1: Add More Tools

**Example: Add "run_tests" Tool**

```python
def run_tests(self, repo_path):
    """Execute test suite and report results"""
    try:
        # Look for test runner
        if (repo_path / "pytest.ini").exists():
            result = subprocess.run(
                ["pytest", "--tb=short"],
                cwd=repo_path,
                capture_output=True,
                text=True,
                timeout=30
            )
            return result.stdout + result.stderr
        
        return "No test configuration found."
    
    except Exception as e:
        return f"Error running tests: {e}"
```

Add to tools list:
```python
tools = [
    ...,
    {
        "type": "function",
        "function": {
            "name": "run_tests",
            "description": "Run test suite and report coverage",
            "parameters": {"type": "object", "properties": {}}
        }
    }
]
```

### Extension 2: Customise the Audit Focus

**For blockchain projects:**
```python
system_prompt = """
...
SPECIALISATION: Blockchain Smart Contracts
Focus on:
- Security vulnerabilities (reentrancy, overflow, etc.)
- Gas optimisation opportunities
- Standards compliance (ERC-20, ERC-721, etc.)
...
"""
```

**For Python curricula:**
```python
system_prompt = """
...
SPECIALISATION: Educational Code Quality
Focus on:
- Code clarity for learning
- Comments and documentation
- Best practices for teaching
- Common pitfalls to address
...
"""
```

### Extension 3: Multi-Repo Analysis

```python
class MultiRepoAuditor:
    def __init__(self, api_key, repos):
        self.api_key = api_key
        self.repos = repos  # List of GitHub URLs
    
    def audit_all(self):
        reports = {}
        for repo_url in self.repos:
            agent = MentorAgent(..., repo_url=repo_url)
            reports[repo_url] = agent.run()
        return reports
```

### Extension 4: Integration with Your LMS

```python
# Send audit reports to WeThinkCode student portal
def send_to_portal(report, student_id, cohort):
    """Post audit report to student's dashboard"""
    api_url = f"https://wtc-portal.local/api/feedback/{student_id}"
    
    response = requests.post(
        api_url,
        json={
            "report": report,
            "cohort": cohort,
            "timestamp": datetime.now().isoformat()
        },
        headers={"Authorization": f"Bearer {PORTAL_TOKEN}"}
    )
    return response.json()
```

### Extension 5: Continuous Auditing

```python
def schedule_audits(repos, schedule="weekly"):
    """Audit repos on schedule (e.g., weekly)"""
    import schedule
    import time
    
    def job():
        for repo_url in repos:
            print(f"Auditing {repo_url}...")
            agent = MentorAgent(..., repo_url=repo_url)
            report = agent.run()
            save_report(report)
    
    if schedule == "weekly":
        schedule.every().monday.at("09:00").do(job)
    
    while True:
        schedule.run_pending()
        time.sleep(60)

# Usage
repos_to_audit = [
    "https://github.com/wtc-student-1/project.git",
    "https://github.com/wtc-student-2/project.git",
    ...
]
schedule_audits(repos_to_audit, schedule="weekly")
```

---

## Resources for Further Learning

### Official Documentation
- **LiteLLM:** https://docs.litellm.ai
- **OpenAI Function Calling:** https://platform.openai.com/docs/guides/function-calling
- **LangChain:** https://python.langchain.com/docs/agents
- **CrewAI:** https://docs.crewai.com

### Conceptual Resources
- AWS Prescriptive Guidance: Tool-based agents
- Anthropic: Building reliable AI agents
- OpenAI: Agent design patterns

### Communities
- GitHub Discussions (agent repositories)
- Reddit: r/LLMDevs, r/ChatGPT
- Discord: LangChain Community

---

## Quick Reference: Agent Workflow Checklist

- [ ] Define clear **objective** for your agent
- [ ] Identify **tools** agent needs (external functions)
- [ ] Write **system prompt** with instructions & priorities
- [ ] Implement **tool functions** with error handling
- [ ] Create **tool definitions** (schema for LLM)
- [ ] Implement **agent loop** (request → decide → execute → repeat)
- [ ] Add **safety limits** (iteration count, file sizes)
- [ ] Test with **sample data** before production
- [ ] Monitor **LLM costs** (track API calls)
- [ ] Collect **feedback** for prompt refinement

---

## Conclusion

You've now learned:
1. ✅ What AI agents are (and how they differ from chatbots)
2. ✅ The core agentic loop (reasoning → action → repeat)
3. ✅ Alternatives to n8n & Zapier
4. ✅ How to build a production-grade agent from scratch
5. ✅ How your Mentor Agent works (step by step)
6. ✅ Common patterns and when to use them
7. ✅ Extensions for your specific use cases

**Your Mentor Agent is a production-ready example of the Tool-Calling Agent pattern**, optimised for code review and strategic guidance rather than just problem-solving.

As an education leader at WeThinkCode, you can now:
- Audit student repositories automatically
- Provide strategic feedback at scale
- Track project health over time
- Extend the agent for blockchain, AI, or curriculum-specific analysis

Start with the basic agent, test it on a real student project, then extend it with custom tools for your specific needs.

---
