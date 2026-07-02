# Building Your First AI Agent: Practical Implementation Guide

**For:** WeThinkCode Education Leaders & Curriculum Developers  
**Focus:** Hands-on, step-by-step implementation with debugging tips

---

## Part 1: Complete Working Code (Copy-Paste Ready)

### File 1: requirements.txt

```
litellm>=1.35.0
gitpython>=3.1.40
colorama>=0.4.6
openai>=1.0.0
python-dotenv>=1.0.0
```

### File 2: .env (for local development)

```
# .env file (NEVER commit this to Git)
API_KEY=sk-your-openai-api-key-here
# OR for Anthropic
# API_KEY=sk-ant-your-anthropic-key-here
# OR for Google
# API_KEY=your-gemini-api-key-here
```

### File 3: review_agent.py (Complete Implementation)

```python
import os
import json
import tempfile
import git
import fnmatch
import subprocess
from pathlib import Path
from colorama import Fore, Style, init
from litellm import completion
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialise colorama
init(autoreset=True)

class MentorAgent:
    """
    Strategic Code Review Agent
    
    Analyses GitHub repositories and produces prioritised action plans
    focusing on documentation, architecture, and code quality.
    """
    
    def __init__(self, model_name, api_key, repo_url, token=None):
        """
        Initialise the Mentor Agent
        
        Args:
            model_name (str): LLM to use (e.g., "gpt-4o", "claude-3-5-sonnet-20240620")
            api_key (str): API key for the LLM provider
            repo_url (str): Repository URL (GitHub or GitLab, public or private with token)
            token (str, optional): Git service token for private repos
        """
        self.model_name = model_name
        self.api_key = api_key
        self.repo_url = repo_url
        self.token = token
        self.messages = []
        self.max_iterations = 20
        
        # Setup environment keys for LiteLLM
        self._setup_env_keys()
    
    def _setup_env_keys(self):
        """Map generic API key to provider-specific environment variables"""
        if "gpt" in self.model_name:
            os.environ["OPENAI_API_KEY"] = self.api_key
        elif "claude" in self.model_name:
            os.environ["ANTHROPIC_API_KEY"] = self.api_key
        elif "gemini" in self.model_name:
            os.environ["GEMINI_API_KEY"] = self.api_key
        elif "deepseek" in self.model_name:
            os.environ["DEEPSEEK_API_KEY"] = self.api_key
        else:
            # Default to OPENAI for unknown models
            os.environ["OPENAI_API_KEY"] = self.api_key
    
    def clone_repo(self, local_path):
        """
        Clone repository safely to temporary location
        
        Returns:
            bool: True if clone successful, False otherwise
        """
        url = self.repo_url
        
        # Embed Git service token if provided (for private repos)
        if self.token:
            if "https://" in url and "@" not in url:
                url = url.replace("https://", f"https://oauth2:{self.token}@")
        
        print(f"{Fore.CYAN}⬇️  Cloning repository...{Style.RESET_ALL}")
        try:
            git.Repo.clone_from(url, local_path)
            print(f"{Fore.GREEN}✅ Repository cloned successfully{Style.RESET_ALL}")
            return True
        except Exception as e:
            print(f"{Fore.RED}❌ Clone failed (GitHub/GitLab): {e}{Style.RESET_ALL}")
            return False
    
    # ============ TOOLS FOR THE AGENT ============
    
    def get_file_tree(self, local_path):
        """
        Returns a visual tree of the repository structure
        
        Used by the agent to:
        - Understand project layout
        - Identify missing critical files
        - Assess project organisation
        """
        ignore_patterns = {
            '.git', 'node_modules', '__pycache__', 'venv', 'env',
            '.idea', '.vscode', '*.lock', '*.png', '*.jpg', '.egg-info',
            'dist', 'build', '.pytest_cache', '.coverage'
        }
        
        tree_str = ""
        startpath = Path(local_path)
        
        for root, dirs, files in os.walk(startpath):
            # Filter ignored directories in-place
            dirs[:] = [
                d for d in dirs
                if d not in ignore_patterns and not d.startswith('.')
            ]
            
            # Calculate tree indentation
            level = root.replace(str(startpath), '').count(os.sep)
            indent = ' ' * 4 * level
            rel_path = os.path.basename(root) or "/"
            tree_str += f"{indent}{rel_path}/\n"
            
            # Add files
            subindent = ' ' * 4 * (level + 1)
            for f in sorted(files):
                if not any(fnmatch.fnmatch(f, p) for p in ignore_patterns):
                    tree_str += f"{subindent}{f}\n"
        
        return tree_str
    
    def read_file(self, local_path, relative_path):
        """
        Reads file content with line numbers
        
        Used by the agent to:
        - Examine specific files
        - Check documentation
        - Review code implementation
        
        Args:
            local_path (str): Root path of cloned repo
            relative_path (str): Path relative to root (e.g., "README.md")
        
        Returns:
            str: File content with line numbers, or error message
        """
        full_path = Path(local_path) / relative_path
        
        try:
            # Security check: ensure path is within repo
            full_path.resolve().relative_to(Path(local_path).resolve())
            
            # Safety check: don't read huge files
            if full_path.stat().st_size > 50000:
                return "⚠️ File is too large to read directly (>50KB). Use smaller sections."
            
            with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read(15000)  # First 15,000 chars
                lines = content.splitlines()
                
                # Format with line numbers for reference
                numbered = "\n".join([f"{i+1} | {line}" for i, line in enumerate(lines)])
                return numbered
        
        except FileNotFoundError:
            return f"❌ File not found: {relative_path}"
        except Exception as e:
            return f"❌ Error reading file: {e}"
    
    def check_dependencies(self, local_path):
        """
        Check if dependency files exist and are valid
        
        Used by the agent to:
        - Identify missing dependencies
        - Check Python/Node dependencies
        - Flag incomplete setup
        """
        repo_path = Path(local_path)
        results = {}
        
        # Check Python
        if (repo_path / "requirements.txt").exists():
            results["Python (pip)"] = "✅ requirements.txt found"
        elif (repo_path / "setup.py").exists():
            results["Python (setuptools)"] = "✅ setup.py found"
        elif (repo_path / "pyproject.toml").exists():
            results["Python (Poetry/PEP 517)"] = "✅ pyproject.toml found"
        else:
            results["Python dependencies"] = "⚠️ No Python dependency file found"
        
        # Check Node.js
        if (repo_path / "package.json").exists():
            results["Node.js"] = "✅ package.json found"
        elif (repo_path / "package-lock.json").exists():
            results["Node.js lock"] = "⚠️ package-lock.json but no package.json"
        
        # Check Docker
        if (repo_path / "Dockerfile").exists():
            results["Docker"] = "✅ Dockerfile found"
        
        # Check CI/CD
        if (repo_path / ".github" / "workflows").exists():
            results["GitHub Actions"] = "✅ CI/CD configured"
        
        return "\n".join([f"{k}: {v}" for k, v in results.items()])
    
    # ============ THE AGENT LOOP ============
    
    def run(self):
        """
        Execute the strategic code review audit
        
        Process:
        1. Clone the repository
        2. Define tools available to the agent
        3. Create system prompt (agent instructions)
        4. Loop until agent produces final report or max iterations
        """
        with tempfile.TemporaryDirectory() as tmp_dir:
            repo_path = Path(tmp_dir) / "repo"
            
            # Clone the repository
            if not self.clone_repo(repo_path):
                return "Failed to clone repository"
            
            # Define tools the agent can use
            tools = [
                {
                    "type": "function",
                    "function": {
                        "name": "get_file_tree",
                        "description": "Get visual tree of project structure",
                        "parameters": {"type": "object", "properties": {}}
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "read_file",
                        "description": "Read file content with line numbers. Useful for README, docs, code.",
                        "parameters": {
                            "type": "object",
                            "properties": {"path": {"type": "string", "description": "Relative path from repo root (e.g., 'README.md', 'src/main.py')"}},
                            "required": ["path"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "check_dependencies",
                        "description": "Check for dependency files (requirements.txt, package.json, etc.)",
                        "parameters": {"type": "object", "properties": {}}
                    }
                }
            ]
            
            # System prompt: Agent's instructions and personality
            system_prompt = """
You are a Senior Technical Project Manager and Lead Architect.

OBJECTIVE:
Conduct a strategic review of the codebase. Do NOT rewrite code.
Instead, produce a "Prioritised Action Plan" for the developer.

YOUR AUDIT PROCESS (CRITICAL ORDER):
1. **Discovery:** Call `get_file_tree`. Analyse structure. Is it standard? Messy?
2. **Dependencies Check:** Call `check_dependencies`. Are dependencies clear and complete?
3. **Documentation Review (CRITICAL FIRST):** Read README.md and key docs.
   - Is README concise? Does it explain how to run the app?
   - Are setup instructions clear?
   - Is there architecture documentation?
4. **Code Quality Check:** Pick 3 crucial files (entry points, main logic). Look for:
   - Spaghetti code vs clean architecture
   - Lack of comments in complex sections
   - Security risks or obvious bugs
   - Code duplication

OUTPUT FORMAT (Strict Markdown):
# 📋 Strategic Codebase Audit

## 1. 🚨 Immediate Priorities (The "Burning Fire")
List top 2-3 blocking issues that MUST be fixed first.
Examples: broken install, missing dependencies, critical security flaws.

## 2. 📚 Documentation Health
- **README Quality:** Rate /10. Is it concise? Clear setup instructions?
- **Onboarding Experience:** Can a new dev run `pip install` or `npm install` immediately?
- **Missing Docs:** What critical documentation is missing?

## 3. 🏗 Architecture & Code Hygiene
- **Project Structure:** Is it logical and maintainable?
- **Code Quality:** Comments, variable naming, DRY principle?
- **Common Pitfalls:** What's done well? What needs improvement?

## 4. 🧭 Guided Next Steps (Exact Actions)
Numbered list of exactly what the developer should do first.
Example: "1. Create requirements.txt using `pip freeze`..."

---

You MUST provide actionable, specific guidance. Not generic suggestions.
"""
            
            # Initialise conversation with system prompt
            self.messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": "Start the audit. Analyse this repository thoroughly."}
            ]
            
            print(f"{Fore.GREEN}🧠 Mentor Agent initialised{Style.RESET_ALL}")
            print(f"{Fore.CYAN}Analysing project health...{Style.RESET_ALL}\n")
            
            # ===== AGENT LOOP =====
            iteration = 0
            while len(self.messages) < self.max_iterations:
                iteration += 1
                print(f"{Fore.YELLOW}[Iteration {iteration}] 🤔 Analysing...{Style.RESET_ALL}")
                
                try:
                    # Call LLM with available tools
                    response = completion(
                        model=self.model_name,
                        messages=self.messages,
                        tools=tools,
                        tool_choice="auto"
                    )
                except Exception as e:
                    print(f"{Fore.RED}❌ API Error: {e}{Style.RESET_ALL}")
                    break
                
                msg = response.choices[0].message
                
                # If no tool_calls, agent has finished reasoning
                if not msg.tool_calls:
                    print(f"{Fore.GREEN}✅ Audit Complete!{Style.RESET_ALL}\n")
                    return msg.content
                
                # Add agent's decision to conversation
                self.messages.append(msg)
                
                # Execute each tool call
                for tool_call in msg.tool_calls:
                    func_name = tool_call.function.name
                    args = json.loads(tool_call.function.arguments)
                    
                    print(f"   🔎 Executing: {func_name} {args}")
                    
                    # Execute the appropriate tool
                    if func_name == "get_file_tree":
                        result = self.get_file_tree(repo_path)
                    elif func_name == "read_file":
                        result = self.read_file(repo_path, args.get("path"))
                    elif func_name == "check_dependencies":
                        result = self.check_dependencies(repo_path)
                    else:
                        result = f"❌ Unknown tool: {func_name}"
                    
                    # Add tool result to conversation
                    self.messages.append({
                        "role": "tool",
                        "tool_call_id": tool_call.id,
                        "content": result
                    })
            
            return "❌ Audit timed out (max iterations reached)"


def main():
    """
    Main entry point: Configure and run the agent
    """
    print(f"{Fore.MAGENTA}{'='*60}{Style.RESET_ALL}")
    print(f"{Fore.MAGENTA}   AI MENTOR: Strategic Code Review Agent{Style.RESET_ALL}")
    print(f"{Fore.MAGENTA}{'='*60}{Style.RESET_ALL}\n")
    
    # ===== CONFIGURATION =====
    # Choose your LLM (uncommment one)
    MODEL = "gpt-4o"
    # MODEL = "claude-3-5-sonnet-20240620"
    # MODEL = "gemini/gemini-1.5-pro"
    
    # Get API key from environment
    API_KEY = os.getenv("API_KEY")
    
    # Repository to audit
    REPO = "https://github.com/your-username/your-repo.git"
    # REPO = "https://github.com/facebook/react.git"  # Example: audit React
    
    # GitHub token (optional, for private repos)
    GITHUB_TOKEN = os.getenv("GITHUB_TOKEN", None)
    
    # ===== VALIDATION =====
    if not API_KEY:
        print(f"{Fore.RED}❌ Error: API_KEY not found!{Style.RESET_ALL}")
        print(f"   Set it: export API_KEY='your-key'")
        print(f"   Or create .env file with API_KEY=your-key")
        return
    
    if REPO == "https://github.com/your-username/your-repo.git":
        print(f"{Fore.RED}❌ Error: Please update REPO variable{Style.RESET_ALL}")
        print(f"   Change line: REPO = 'https://github.com/your-username/your-repo.git'")
        return
    
    print(f"Configuration:")
    print(f"  Model: {Fore.CYAN}{MODEL}{Style.RESET_ALL}")
    print(f"  Repository: {Fore.CYAN}{REPO}{Style.RESET_ALL}")
    print(f"  Private Repo: {'Yes' if GITHUB_TOKEN else 'No'}\n")
    
    # ===== RUN AGENT =====
    agent = MentorAgent(
        model_name=MODEL,
        api_key=API_KEY,
        repo_url=REPO,
        token=GITHUB_TOKEN
    )
    
    report = agent.run()
    
    # ===== SAVE REPORT =====
    if report and not report.startswith("❌"):
        filename = "strategic_audit.md"
        with open(filename, "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"{Fore.GREEN}📄 Report saved to: {filename}{Style.RESET_ALL}")
        print(f"\n{Fore.MAGENTA}Report Preview:{Style.RESET_ALL}\n")
        print(report[:500] + "...\n")
    else:
        print(f"\n{Fore.RED}Failed to generate report:{Style.RESET_ALL}")
        print(report)


if __name__ == "__main__":
    main()
```

---

## Part 2: Running Your Agent (Step-by-Step)

### Step 1: Setup

```bash
# Create project directory
mkdir ai-mentor-agent
cd ai-mentor-agent

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Mac/Linux
# OR
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Create .env File

```bash
# Create .env file with your API key
cat > .env << EOF
API_KEY=sk-your-openai-key-here
EOF

# Never commit .env to Git!
echo ".env" >> .gitignore
```

### Step 3: Update Configuration

Edit `review_agent.py` and change:

```python
REPO = "https://github.com/your-username/your-target-repo.git"
```

### Step 4: Run the Agent

```bash
python review_agent.py
```

### Expected Output

```
============================================================
   AI MENTOR: Strategic Code Review Agent
============================================================

Configuration:
  Model: gpt-4o
  Repository: https://github.com/your-username/your-repo.git
  Private Repo: No

⬇️  Cloning repository...
✅ Repository cloned successfully
🧠 Mentor Agent initialised
Analysing project health...

[Iteration 1] 🤔 Analysing...
   🔎 Executing: get_file_tree {}
[Iteration 2] 🤔 Analysing...
   🔎 Executing: read_file {'path': 'README.md'}
[Iteration 3] 🤔 Analysing...
   🔎 Executing: check_dependencies {}
...
✅ Audit Complete!

📄 Report saved to: strategic_audit.md
```

### Step 5: View the Report

```bash
cat strategic_audit.md
# or open in editor
code strategic_audit.md
```

---

## Part 3: Debugging & Troubleshooting

### Issue 1: "API_KEY not found"

**Solution:**
```bash
# Check if environment variable is set
echo $API_KEY  # Mac/Linux
echo %API_KEY%  # Windows PowerShell

# If not set, set it:
export API_KEY="sk-..."  # Mac/Linux
$env:API_KEY="sk-..."  # Windows PowerShell
```

### Issue 2: "Clone failed"

**Possible causes:**
```python
# 1. Invalid URL
REPO = "https://github.com/username/repo.git"  # ✅ Correct

# 2. Private repo without token
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
# Set: export GITHUB_TOKEN="your-github-token"

# 3. Network issue
# Check: ping github.com
```

### Issue 3: "Model not found" or "Invalid API key"

**Solution:**
```python
# Check if model name is correct
MODEL = "gpt-4o"  # OpenAI
MODEL = "claude-3-5-sonnet-20240620"  # Anthropic
MODEL = "gemini/gemini-1.5-pro"  # Google

# Verify API key format:
# OpenAI: starts with sk-
# Anthropic: starts with sk-ant-
# Google: looks like random string
```

### Issue 4: Agent takes too long

**Solutions:**
```python
# 1. Reduce max iterations
self.max_iterations = 10  # Instead of 20

# 2. Use faster model
MODEL = "gpt-4o-mini"  # Faster, cheaper
MODEL = "claude-3-5-haiku"  # Faster version

# 3. Check network speed
# Slow API calls = slow agent
```

### Issue 5: "Rate limit exceeded"

**Solution:**
```python
# Wait and retry
import time
time.sleep(30)  # Wait 30 seconds
# Then run agent again
```

---

## Part 4: Extending Your Agent

### Extension 1: Add Custom Tool

```python
def get_code_metrics(self, local_path):
    """Count lines of code, files, etc."""
    repo_path = Path(local_path)
    
    metrics = {
        "total_files": 0,
        "python_files": 0,
        "js_files": 0,
        "total_lines": 0
    }
    
    for file_path in repo_path.rglob("*"):
        if file_path.is_file():
            metrics["total_files"] += 1
            
            if file_path.suffix == ".py":
                metrics["python_files"] += 1
            elif file_path.suffix == ".js":
                metrics["js_files"] += 1
            
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    metrics["total_lines"] += len(f.readlines())
            except:
                pass
    
    return f"Code Metrics:\n" + "\n".join([f"  {k}: {v}" for k, v in metrics.items()])
```

Add to tools list in `run()`:
```python
{
    "type": "function",
    "function": {
        "name": "get_code_metrics",
        "description": "Get code statistics (file count, lines, etc.)",
        "parameters": {"type": "object", "properties": {}}
    }
}
```

### Extension 2: Save Reports to Database

```python
import sqlite3
import psycopg2
from psycopg2 import sql

def save_report_to_db(repo_url, report, model_used, use_postgres=False):
    """Store audit reports in database (SQLite or PostgreSQL)"""
    
    if use_postgres:
        # PostgreSQL connection
        try:
            conn = psycopg2.connect(
                dbname="audits",
                user="postgres",
                password=os.getenv("POSTGRES_PASSWORD"),
                host="localhost"
            )
            cursor = conn.cursor()
            
            cursor.execute(sql.SQL("""
                CREATE TABLE IF NOT EXISTS audits (
                    id SERIAL PRIMARY KEY,
                    repo_url TEXT,
                    model TEXT,
                    report TEXT,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """))
            
            cursor.execute(
                "INSERT INTO audits (repo_url, model, report) VALUES (%s, %s, %s)",
                (repo_url, model_used, report)
            )
            
            conn.commit()
            
        except Exception as e:
            print(f"PostgreSQL Error: {e}")
            
        finally:
            if 'conn' in locals():
                conn.close()
    
    else:
        # SQLite connection
        try:
            conn = sqlite3.connect("audits.db")
            cursor = conn.cursor()
            
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS audits (
                    id INTEGER PRIMARY KEY,
                    repo_url TEXT,
                    model TEXT,
                    report TEXT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            cursor.execute(
                "INSERT INTO audits (repo_url, model, report) VALUES (?, ?, ?)",
                (repo_url, model_used, report)
            )
            
            conn.commit()
            
        except Exception as e:
            print(f"SQLite Error: {e}")
            
        finally:
            if 'conn' in locals():
                conn.close()

# Usage in main():
save_report_to_db(REPO, report, MODEL, use_postgres=True)  # Set to False for SQLite
```

### Extension 3: Batch Audit Multiple Repos

```python
def audit_multiple_repos(repo_urls, model, api_key):
    """Audit multiple repositories"""
    results = {}
    
    for repo_url in repo_urls:
        print(f"\nAuditing: {repo_url}")
        agent = MentorAgent(model_name=model, api_key=api_key, repo_url=repo_url)
        report = agent.run()
        results[repo_url] = report
    
    return results

# Usage:
repos = [
    "https://github.com/user/repo1.git",
    "https://github.com/user/repo2.git",
    "https://github.com/user/repo3.git",
]

results = audit_multiple_repos(repos, MODEL, API_KEY)

# Save all reports
for repo, report in results.items():
    filename = repo.split('/')[-1].replace('.git', '_audit.md')
    with open(filename, 'w') as f:
        f.write(report)
```

---

## Part 5: Cost Estimation

### API Call Costs

Typical audit costs:

| Model | Input Cost | Output Cost | Avg Audit Cost |
|-------|-----------|-----------|----------------|
| gpt-4o | $5 / 1M tokens | $15 / 1M tokens | ~$0.10-0.30 |
| gpt-4o-mini | $0.15 / 1M tokens | $0.60 / 1M tokens | ~$0.01-0.05 |
| claude-3-5-sonnet | $3 / 1M tokens | $15 / 1M tokens | ~$0.10-0.25 |
| gemini-1.5-pro | $1.25 / 1M tokens | $5 / 1M tokens | ~$0.05-0.15 |

### Reducing Costs

```python
# 1. Use cheaper model for simple repos
if repo_size_mb < 10:
    MODEL = "gpt-4o-mini"  # 10x cheaper
else:
    MODEL = "gpt-4o"

# 2. Limit iterations
self.max_iterations = 10  # Instead of 20

# 3. Reduce file sizes
if full_path.stat().st_size > 25000:  # Was 50000
    return "File too large..."

# 4. Cache results
import hashlib
cache = {}
repo_hash = hashlib.md5(REPO.encode()).hexdigest()
if repo_hash in cache:
    return cache[repo_hash]
```

---

## Quick Reference: Agent Commands

```bash
# Setup
mkdir my-agent && cd my-agent
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# Configure
export API_KEY="your-key"
# Edit review_agent.py and change REPO

# Run
python review_agent.py

# View results
cat strategic_audit.md
code strategic_audit.md  # Open in VS Code

# Audit multiple repos (batch)
# Create a script that calls agent.run() in a loop

# Save to database
# Use the SQLite extension above
```

---

## Conclusion

You now have a **production-ready AI Mentor Agent** that:
- ✅ Clones any GitHub repository
- ✅ Analyses structure, dependencies, documentation
- ✅ Produces strategic action plans
- ✅ Extensible with custom tools
808: - ✅ Costs ~ZAR0.24-5.88 per audit

**Next steps for WeThinkCode:**
1. Test on student repositories
2. Customise system prompt for blockchain/AI focus
3. Integrate with student portal
4. Schedule weekly audits for all cohorts
5. Create feedback loop based on reports

Start simple, extend as needed.