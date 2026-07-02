# Quick Start: Your First AI Agent (15-Minute Setup)

**Goal:** Run your Mentor Agent on a real GitHub repo within 15 minutes  
**Prerequisites:** Python 3.10+, GitHub account, API key  
**Time:** ~15 minutes

---

## The 3-Minute Overview

**What you're building:** An AI agent that audits your code and gives strategic feedback.

```
┌─────────────────────────────────────────┐
│ Your GitHub Repo                        │
│ (Cloned automatically)                  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│ AI Agent (LiteLLM + GPT-4o)             │
│ • Reads files                            │
│ • Analyses structure                     │
│ • Reasons about quality                  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│ Strategic Audit Report (Markdown)       │
│ • Immediate priorities                   │
│ • Documentation health                   │
│ • Architecture feedback                  │
│ • Next steps (specific actions)          │
└──────────────────────────────────────────┘
```

---

## Step 1: Get Your API Key (2 minutes)

### Option A: OpenAI (GPT-4o)

1. Go to https://platform.openai.com/api/keys
2. Click "Create new secret key"
3. Copy the key (starts with `sk-proj-`)
4. Store safely (never commit to Git)

**Cost:** ~ZAR2.35-7.05 per audit

### Option B: Anthropic (Claude 3.5 Sonnet)

1. Go to https://console.anthropic.com
2. Create API key in "Account Settings"
3. Copy the key (starts with `sk-ant-`)

**Cost:** ~ZAR2.35-5.88 per audit

### Option C: Google (Gemini)

1. Go to https://ai.google.dev
2. Get free API key (requires Google account)
3. Copy the key

**Cost:** ~ZAR1.18-3.53 per audit

---

## Step 2: Setup Project (3 minutes)

```bash
# 1. Create project directory
mkdir my-agent
cd my-agent

# 2. Create Python virtual environment
python -m venv venv

# 3. Activate it
source venv/bin/activate  # Mac/Linux
# OR
venv\Scripts\activate  # Windows
```bash
# 4. Create requirements.txt
cat > requirements.txt << 'EOF'
litellm>=1.35.0
gitpython>=3.1.40
colorama>=0.4.6
openai>=1.0.0
python-dotenv>=1.0.0
psycopg2-binary>=2.9.9
EOF
```
# 5. Install dependencies
pip install -r requirements.txt
```

---

## Database Configuration

### Option A: SQLite (Default)
- No setup required
- Reports saved to `audits.db` automatically

### Option B: PostgreSQL
1. Install PostgreSQL:
```bash
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
```
2. Create database and user:
```bash
sudo -u postgres psql
CREATE DATABASE audits;
CREATE USER mentor WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE audits TO mentor;
```
3. Set environment variable:
```bash
export POSTGRES_PASSWORD='your_password'
```
4. In `review_agent.py`, set `use_postgres=True` when calling `save_report_to_db()`

---

## Step 3: Create the Agent Code (2 minutes)

**Copy the complete code below and save as `review_agent.py`:**

(Use the code from "AI-Agent-Practical-Guide.md" - the full `review_agent.py` file)

Or use this shorter version:

```python
import os
from pathlib import Path
from colorama import Fore, Style, init
from litellm import completion
import tempfile, git, json

init(autoreset=True)

class InteractiveMentorAgent:
    def __init__(self, model, api_key, repo_url):
        self.model = model
        self.api_key = api_key
        self.repo_url = repo_url
        self.messages = []
        
        if "gpt" in model:
            os.environ["OPENAI_API_KEY"] = api_key
        elif "claude" in model:
            os.environ["ANTHROPIC_API_KEY"] = api_key
        elif "gemini" in model:
            os.environ["GEMINI_API_KEY"] = api_key
    
    def clone_repo(self, path):
        print(f"{Fore.CYAN}⬇️  Cloning...{Style.RESET_ALL}")
        try:
            git.Repo.clone_from(self.repo_url, path)
            return True
        except Exception as e:
            print(f"{Fore.RED}Failed: {e}{Style.RESET_ALL}")
            return False
    
    def get_file_tree(self, repo_path):
        tree = ""
        for root, dirs, files in os.walk(repo_path):
            dirs[:] = [d for d in dirs if not d.startswith('.')]
            level = root.replace(str(repo_path), '').count(os.sep)
            indent = '  ' * level
            tree += f"{indent}{os.path.basename(root)}/\n"
            for f in files:
                tree += f"{indent}  {f}\n"
        return tree
    
    def read_file(self, repo_path, rel_path):
        try:
            path = Path(repo_path) / rel_path
            if path.stat().st_size > 50000:
                return "File too large"
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                return f.read(10000)
        except:
            return "Could not read file"
    
    def interactive_session(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo_path = Path(tmp) / "repo"
            if not self.clone_repo(repo_path):
                return "Clone failed"
            
            tools = [
                {
                    "type": "function",
                    "function": {
                        "name": "get_file_tree",
                        "description": "Get project structure",
                        "parameters": {"type": "object", "properties": {}}
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "read_file",
                        "description": "Read a file",
                        "parameters": {
                            "type": "object",
                            "properties": {"path": {"type": "string"}},
                            "required": ["path"]
                        }
                    }
                }
            ]
            
            system_prompt = """
You are an interactive code mentor. Guide the user through improving their repository.
1. Start by understanding their goals
2. Provide step-by-step guidance
3. Ask clarifying questions
4. Adapt to their responses

Format responses clearly with:
- Questions (marked with ❓)
- Suggestions (marked with 💡)
- Code examples (in markdown blocks)
"""
            
            self.messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": "Let's begin improving this repository"}
            ]
            
            print(f"{Fore.GREEN}🤖 Interactive Mentor Session Started{Style.RESET_ALL}")
            print(f"Type 'exit' to end the session\n")
            
            while True:
                try:
                    response = completion(
                        model=self.model,
                        messages=self.messages,
                        tools=tools,
                        tool_choice="auto"
                    )
                except Exception as e:
                    return f"Error: {e}"
                
                msg = response.choices[0].message
                
                if not msg.tool_calls:
                    print(f"\n{Fore.CYAN}Mentor:{Style.RESET_ALL} {msg.content}")
                    
                    user_input = input(f"{Fore.YELLOW}You:{Style.RESET_ALL} ")
                    if user_input.lower() == 'exit':
                        print(f"{Fore.GREEN}✅ Session ended{Style.RESET_ALL}")
                        return "Session saved to mentor_logs.json"
                    
                    self.messages.append({"role": "user", "content": user_input})
                else:
                    self.messages.append(msg)
                    
                    for tool in msg.tool_calls:
                        name = tool.function.name
                        args = json.loads(tool.function.arguments)
                        
                        print(f"  🔎 {name}")
                        
                        if name == "get_file_tree":
                            result = self.get_file_tree(repo_path)
                        elif name == "read_file":
                            result = self.read_file(repo_path, args.get("path"))
                        else:
                            result = "Unknown tool"
                        
                        self.messages.append({
                            "role": "tool",
                            "tool_call_id": tool.id,
                            "content": result
                        })

# CONFIGURATION
MODEL = "gpt-4o"
API_KEY = os.getenv("API_KEY")
REPO = "https://github.com/your-username/your-repo.git"

if not API_KEY:
    print("Set API key: export API_KEY='sk-...'")
    exit(1)

print("Interactive AI Mentor Agent")
agent = InteractiveMentorAgent(MODEL, API_KEY, REPO)
agent.interactive_session()
```))
                    else:
                        result = "Unknown tool"
                    
                    self.messages.append({
                        "role": "tool",
                        "tool_call_id": tool.id,
                        "content": result
                    })

# CONFIGURATION
MODEL = "gpt-4o"
API_KEY = os.getenv("API_KEY")
REPO = "https://github.com/your-username/your-repo.git"

if not API_KEY:
    print("Set API key: export API_KEY='sk-...'")
    exit(1)

print("AI Mentor Agent")
agent = MentorAgent(MODEL, API_KEY, REPO)
report = agent.run()

if report:
    with open("audit_report.md", "w") as f:
        f.write(report)
    print(f"\n📄 Saved: audit_report.md")
    print("\n" + report[:300] + "...")
```

---

## Step 4: Two-Phase Implementation (3 minutes)

### Phase 1: Automated Code Review
1. Set up your API keys in `.env`
2. Run the assessment agent on student repositories
3. Review generated audit reports
4. Provide feedback based on automated findings

### Phase 2: Interactive Mentoring
1. Install interactive dependencies (`pip install -r requirements.txt`)
2. Launch the interactive mentor (`python review_agent.py --interactive`)
3. Engage in back-and-forth sessions with students
4. Focus on logic improvement rather than direct solutions

### 4.1: Set Your API Key

**Linux/Mac:**
```bash
export API_KEY="sk-your-api-key-here"
```

**Windows PowerShell:**
```powershell
$env:API_KEY="sk-your-api-key-here"
```

**Or create `.env` file:**
```bash
cat > .env << 'EOF'
API_KEY=sk-your-api-key-here
EOF
```

### 4.2: Update Repository URL

Edit `review_agent.py` and change:
```python
REPO = "https://github.com/your-username/your-repo.git"
```

**Use examples:**
- Public repo: `https://github.com/facebook/react.git`
- Your own: `https://github.com/yourusername/yourproject.git`

### 4.3: Run It!

```bash
python review_agent.py
```

### Expected Output

```
🚀 AI Mentor Agent
⬇️  Cloning...
🧠 Agent started
  🔎 get_file_tree
  🔎 read_file
  🔎 read_file
✅ Done!

📄 Saved: audit_report.md

# Strategic Code Audit

## 1. Immediate Priorities
- Create requirements.txt
- Add proper error handling

## 2. Documentation
README exists but incomplete (6/10)

... (full report)
```

### 4.4: View the Report

```bash
cat audit_report.md
# or open in editor
code audit_report.md
```

---

## Step 5: Test with Different Models (2 minutes)

Try other LLMs without changing code:

```python
# GPT-4o (Default)
MODEL = "gpt-4o"  # Best quality, faster

# Claude 3.5 Sonnet (Great reasoning)
MODEL = "claude-3-5-sonnet-20240620"

# Gemini Pro (Multimodal, cheapest)
MODEL = "gemini/gemini-1.5-pro"

# Local models (free, no API key needed)
MODEL = "ollama/mistral"  # Requires Ollama running locally
```

**Just change one line and run again!**

---

## Common Issues & Fixes

### Issue 1: "API_KEY not found"

```bash
# Check if set
echo $API_KEY

# If empty, set it
export API_KEY="sk-..."
```

### Issue 2: "Clone failed"

```python
# Check repo URL format
# ✅ Correct: https://github.com/username/repo.git
# ❌ Wrong:   https://github.com/username/repo

# For private repos, add token
REPO = "https://oauth2:YOUR_GITHUB_TOKEN@github.com/username/private-repo.git"
```

### Issue 3: "Model not found"

```bash
# Check model name spelling
# OpenAI: gpt-4o, gpt-4o-mini
# Anthropic: claude-3-5-sonnet-20240620, claude-3-5-haiku-20241022
# Google: gemini/gemini-1.5-pro, gemini/gemini-1.5-flash
```

### Issue 4: "Rate limited"

```bash
# Wait a few minutes, then try again
sleep 60
python review_agent.py
```

---

## Next: Extend Your Agent

### Add Custom Tools

```python
def count_lines(self, repo_path):
    total = 0
    for file in Path(repo_path).rglob("*.py"):
        with open(file) as f:
            total += len(f.readlines())
    return f"Total Python lines: {total}"

# Add to tools list:
# {
#     "type": "function",
#     "function": {
#         "name": "count_lines",
#         "description": "Count lines of code",
#         "parameters": {"type": "object", "properties": {}}
#     }
# }
```

### Customise System Prompt

```python
system_prompt = """
You are a blockchain expert auditing Solidity contracts.

Focus on:
1. Security vulnerabilities (reentrancy, overflow)
2. Gas optimisation
3. ERC standard compliance
...
"""
```

### Save Reports to Database

```python
import sqlite3

def save_report(repo_url, report):
    conn = sqlite3.connect("audits.db")
    conn.execute("""
        CREATE TABLE IF NOT EXISTS audits (
            repo TEXT, report TEXT, date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.execute("INSERT INTO audits VALUES (?, ?, NULL)", (repo_url, report))
    conn.commit()
    conn.close()

# In main:
save_report(REPO, report)
```

---

## Costs Explained

### Per-Audit Cost Breakdown

**Scenario:** Audit a 50-file Python project

| Model | Input | Output | Total |
|-------|-------|--------|-------|
| gpt-4o | 8,000 tokens | 1,500 tokens | **~ZAR4.23** |
| gpt-4o-mini | 8,000 tokens | 1,500 tokens | **~ZAR0.47** |
| claude-3-5-sonnet | 8,000 tokens | 1,500 tokens | **~ZAR3.53** |
| gemini-1.5-pro | 8,000 tokens | 1,500 tokens | **~ZAR1.88** |

**Annual Cost (1 audit/week):**
- gpt-4o: **ZAR219.96/year**
- gpt-4o-mini: **ZAR24.44/year** ← Cheapest
- claude-3-5-sonnet: **ZAR183.30/year**
- gemini-1.5-pro: **ZAR97.76/year** ← Best value

---

## What You've Built

✅ A production-ready AI agent  
✅ Understands the agentic loop  
✅ Can audit any GitHub repository  
✅ Produces actionable feedback  
✅ Costs less than ZAR11.75 per audit  
✅ Can be customised for your domain  
✅ Extensible with custom tools  

---

## Next Steps

1. **Test on 5 different repos** (learn how it behaves)
2. **Customise the system prompt** for your needs
3. **Add custom tools** specific to your use case
4. **Integrate with your workflow** (save to database, send emails, etc.)
5. **Scale:** Audit multiple repos automatically

---

## Resources

- **Full Implementation Guide:** See "AI-Agent-Practical-Guide.md"
- **Learn About Agents:** See "AI-Agents-Complete-Guide.md"
- **Framework Comparison:** See "Frameworks-Decision-Guide.md"

---

## TL;DR (The Really Quick Version)

```bash
# 1. Setup
mkdir agent && cd agent
python -m venv venv && source venv/bin/activate
pip install litellm gitpython colorama openai python-dotenv

# 2. Get API key
export API_KEY="sk-..."

# 3. Create agent.py (copy code above)

# 4. Run
python agent.py

# 5. Read report
cat audit_report.md
```

**You now have a basic understanding of:**
- How AI agents work
- How to build one from scratch
- How to customise and extend it
- How to integrate it into workflows