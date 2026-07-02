# Interactive AI Agent: Collaborative Version

**For:** WeThinkCode Facilitators Who Want Back-and-Forth Collaboration  
**Purpose:** Agent prompts you for guidance, adapts based on feedback  
**Setup Time:** 30 minutes  
**Type:** TRUE AGENTIC AI (with human loop)

---

## What This Does Differently

### Current Agent (Batch/Autonomous)
```
python review_agent.py
↓
Agent works silently
↓
Produces report
↓
Done
```

### Interactive Agent (Collaborative)
```
python interactive_agent.py
↓
Agent: "I found documentation issues and security problems.
       Which should I focus on first?"
↓
You: "Security"
↓
Agent: "Found 3 vulnerabilities. Want me to propose fixes?"
↓
You: "Yes, show me"
↓
Agent: "[Fixes]
       Should I check gas optimization next?"
↓
You: "Yes"
↓
Agent: "[Analysis + recommendations]"
↓
You: "Done"
```

---

## Complete Interactive Agent Code

### File: interactive_agent.py

```python
"""
Interactive AI Mentor Agent - TRUE AGENTIC AI
Collaborates with facilitator through back-and-forth conversation
"""

import os
import json
import tempfile
import git
import fnmatch
from pathlib import Path
from colorama import Fore, Style, init
from litellm import completion
from dotenv import load_dotenv

load_dotenv()
init(autoreset=True)


class InteractiveAgent:
    """
    Collaborative code review agent that prompts for human guidance
    """
    
    def __init__(self, model_name, api_key, repo_url, token=None):
        self.model_name = model_name
        self.api_key = api_key
        self.repo_url = repo_url
        self.token = token
        self.messages = []
        self.max_iterations = 50  # Allow longer conversations
        
        if "gpt" in self.model_name:
            os.environ["OPENAI_API_KEY"] = self.api_key
        elif "claude" in self.model_name:
            os.environ["ANTHROPIC_API_KEY"] = self.api_key
        elif "gemini" in self.model_name:
            os.environ["GEMINI_API_KEY"] = self.api_key
    
    def clone_repo(self, local_path):
        print(f"{Fore.CYAN}⬇️  Cloning repository...{Style.RESET_ALL}")
        url = self.repo_url
        if self.token:
            if "https://" in url and "@" not in url:
                url = url.replace("https://", f"https://oauth2:{self.token}@")
        try:
            git.Repo.clone_from(url, local_path)
            print(f"{Fore.GREEN}✅ Repository cloned{Style.RESET_ALL}")
            return True
        except Exception as e:
            print(f"{Fore.RED}❌ Clone failed: {e}{Style.RESET_ALL}")
            return False
    
    def get_file_tree(self, local_path):
        """Get repository structure"""
        ignore_patterns = {'.git', 'node_modules', '__pycache__', 'venv', 'env', '.idea', '.vscode'}
        tree_str = ""
        startpath = Path(local_path)
        
        for root, dirs, files in os.walk(startpath):
            dirs[:] = [d for d in dirs if d not in ignore_patterns and not d.startswith('.')]
            level = root.replace(str(startpath), '').count(os.sep)
            indent = ' ' * 4 * level
            rel_path = os.path.basename(root) or "/"
            tree_str += f"{indent}{rel_path}/\n"
            
            for f in sorted(files):
                if not any(fnmatch.fnmatch(f, p) for p in ignore_patterns):
                    tree_str += f"{' ' * 4 * (level + 1)}{f}\n"
        
        return tree_str
    
    def read_file(self, local_path, relative_path):
        """Read file with line numbers"""
        full_path = Path(local_path) / relative_path
        try:
            full_path.resolve().relative_to(Path(local_path).resolve())
            if full_path.stat().st_size > 50000:
                return "⚠️ File too large (>50KB)"
            
            with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read(15000)
                lines = content.splitlines()
                return "\n".join([f"{i+1:3d} | {line}" for i, line in enumerate(lines)])
        except Exception as e:
            return f"❌ Error: {e}"
    
    def run(self):
        """
        Run the interactive agent with human collaboration
        """
        with tempfile.TemporaryDirectory() as tmp_dir:
            repo_path = Path(tmp_dir) / "repo"
            if not self.clone_repo(repo_path):
                return
            
            tools = [
                {
                    "type": "function",
                    "function": {
                        "name": "get_file_tree",
                        "description": "Get project file structure",
                        "parameters": {"type": "object", "properties": {}}
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "read_file",
                        "description": "Read specific file content",
                        "parameters": {
                            "type": "object",
                            "properties": {"path": {"type": "string", "description": "Relative path from repo root"}},
                            "required": ["path"]
                        }
                    }
                }
            ]
            
            # INTERACTIVE SYSTEM PROMPT - Encourages collaboration
            system_prompt = """
You are a collaborative code mentor and auditor.

YOUR STYLE:
- Be conversational and helpful
- Explain your findings clearly
- Ask for guidance at key decision points
- Propose options rather than dictating
- Wait for human input before major decisions

YOUR PROCESS:
1. Analyse the repository structure
2. Identify the main issues/opportunities
3. ASK THE FACILITATOR: "Should I focus on X, Y, or Z?"
4. Based on their answer, investigate that area deeply
5. ASK: "Do you want me to propose specific fixes?"
6. Generate recommendations
7. ASK: "Should I investigate the next area?"

DECISION POINTS - Always ask before:
- Proposing major changes
- Investigating new areas
- Changing focus
- Making final recommendations

Example questions you should ask:
- "Should I focus on security or performance?"
- "Do you want me to look at X?"
- "Should I propose code fixes?"
- "Investigate further or move on?"

Remember: You're guiding the facilitator, not automating.
Use questions liberally. Be helpful, not robotic.
"""
            
            self.messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": "Please audit this repository and help me understand how to improve it. Ask me questions and guide me through the process."}
            ]
            
            print(f"\n{Fore.MAGENTA}{'='*60}{Style.RESET_ALL}")
            print(f"{Fore.MAGENTA}   INTERACTIVE AI MENTOR AGENT{Style.RESET_ALL}")
            print(f"{Fore.MAGENTA}{'='*60}{Style.RESET_ALL}\n")
            print(f"{Fore.CYAN}💬 Collaborative mode - Agent will ask for your guidance{Style.RESET_ALL}\n")
            
            iteration = 0
            
            while iteration < self.max_iterations:
                iteration += 1
                
                print(f"{Fore.YELLOW}[Turn {iteration}] Thinking...{Style.RESET_ALL}")
                
                try:
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
                
                # Add agent's message to history
                self.messages.append(msg)
                
                # Execute tools if needed
                if msg.tool_calls:
                    for tool_call in msg.tool_calls:
                        func_name = tool_call.function.name
                        args = json.loads(tool_call.function.arguments)
                        
                        print(f"   🔎 {func_name}")
                        
                        if func_name == "get_file_tree":
                            result = self.get_file_tree(repo_path)
                        elif func_name == "read_file":
                            result = self.read_file(repo_path, args.get("path"))
                        else:
                            result = "Unknown tool"
                        
                        self.messages.append({
                            "role": "tool",
                            "tool_call_id": tool_call.id,
                            "content": result
                        })
                    
                    # Continue loop to process results
                    continue
                
                # Display agent's response
                if msg.content:
                    print(f"\n{Fore.GREEN}🤖 Agent:{Style.RESET_ALL}")
                    print(f"{msg.content}\n")
                
                # Check if agent is asking a question (contains "?")
                if "?" in msg.content:
                    # WAIT FOR HUMAN INPUT
                    human_response = input(f"{Fore.CYAN}You:{Style.RESET_ALL} ").strip()
                    
                    if human_response.lower() in ["exit", "quit", "done", "finish"]:
                        print(f"\n{Fore.GREEN}✅ Audit complete!{Style.RESET_ALL}")
                        break
                    
                    if not human_response:
                        human_response = "Continue with your analysis"
                    
                    # Add human response to conversation
                    self.messages.append({
                        "role": "user",
                        "content": human_response
                    })
                    
                    print()  # Spacing
                    continue
                
                # Agent finished (no more questions)
                print(f"{Fore.GREEN}✅ Analysis complete!{Style.RESET_ALL}")
                
                # Ask if user wants to continue
                continue_response = input(f"\n{Fore.CYAN}Continue analysis? (yes/no):{Style.RESET_ALL} ").strip().lower()
                
                if continue_response in ["yes", "y"]:
                    next_query = input(f"{Fore.CYAN}What would you like to explore?{Style.RESET_ALL} ").strip()
                    if next_query:
                        self.messages.append({
                            "role": "user",
                            "content": next_query
                        })
                    else:
                        break
                else:
                    break
            
            print(f"\n{Fore.MAGENTA}{'='*60}{Style.RESET_ALL}")
            print(f"{Fore.MAGENTA}   Thank you for using Interactive Agent{Style.RESET_ALL}")
            print(f"{Fore.MAGENTA}{'='*60}{Style.RESET_ALL}\n")


def main():
    """Run the interactive agent"""
    
    # CONFIGURATION
    MODEL = "gpt-4o"  # or "claude-3-5-sonnet-20240620" or "gemini/gemini-1.5-pro"
    API_KEY = os.getenv("API_KEY")
    REPO = "https://github.com/your-username/your-repo.git"
    
    # VALIDATION
    if not API_KEY:
        print(f"{Fore.RED}❌ API_KEY not set!{Style.RESET_ALL}")
        print(f"   Set it: export API_KEY='sk-...'")
        return
    
    if REPO == "https://github.com/your-username/your-repo.git":
        print(f"{Fore.RED}❌ Please update REPO in the script{Style.RESET_ALL}")
        return
    
    print(f"\n{Fore.CYAN}Configuration:{Style.RESET_ALL}")
    print(f"  Model: {MODEL}")
    print(f"  Repository: {REPO}\n")
    
    # RUN AGENT
    agent = InteractiveAgent(
        model_name=MODEL,
        api_key=API_KEY,
        repo_url=REPO
    )
    
    agent.run()


if __name__ == "__main__":
    main()
```

---

## How to Use This

### Step 1: Setup (Same as Before)

```bash
# Create project
mkdir interactive-agent
cd interactive-agent

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Mac/Linux
# OR
venv\Scripts\activate  # Windows

# Install dependencies
pip install litellm gitpython colorama openai python-dotenv
```

### Step 2: Create the File

Save the code above as `interactive_agent.py`

### Step 3: Configure

Edit this section:
```python
MODEL = "gpt-4o"
API_KEY = os.getenv("API_KEY")
REPO = "https://github.com/your-username/your-repo.git"  # ← CHANGE THIS
```

### Step 4: Set API Key

```bash
export API_KEY="sk-your-api-key"
```

### Step 5: Run

```bash
python interactive_agent.py
```

---

## What You'll See

```
============================================================
   INTERACTIVE AI MENTOR AGENT
============================================================

💬 Collaborative mode - Agent will ask for your guidance

[Turn 1] Thinking...
   🔎 get_file_tree

🤖 Agent:
I'm analyzing your repository structure. I can see it's a Python project 
with multiple modules. Before diving deeper, I should understand your priorities.

What would you like me to focus on?
A) Code quality and architecture
B) Documentation and onboarding
C) Security and best practices
D) Performance optimization

You: B) Documentation

[Turn 2] Thinking...
   🔎 read_file

🤖 Agent:
I've reviewed your documentation. Here's what I found:

DOCUMENTATION HEALTH:
- README.md exists but is brief (5/10 quality)
- Missing: Installation instructions
- Missing: API documentation
- Missing: Contributing guidelines

Should I:
A) Propose specific improvements to README.md
B) Check for code comments
C) Both

You: A) Propose improvements

[Turn 3] Thinking...

🤖 Agent:
Here are specific improvements for your README:

## PROPOSED IMPROVEMENTS

### 1. Add Installation Section
```bash
## Installation

### Requirements
- Python 3.8+
- pip or poetry

### Quick Start
```bash
git clone <repo>
cd <project>
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Add Usage Examples
[Examples...]

Should I continue analyzing other areas or would you like to dive deeper into documentation?

You: Continue

[Turn 4] Thinking...

🤖 Agent:
Great! Now checking code quality...

✅ Analysis complete!

Continue analysis? (yes/no): no

============================================================
   Thank you for using Interactive Agent
============================================================
```

---

## Key Differences from Current Agent

| Feature | Current | Interactive |
|---------|---------|------------|
| Asks questions | ❌ No | ✅ Yes |
| Waits for input | ❌ No | ✅ Yes |
| Adapts to feedback | ❌ No | ✅ Yes |
| Multi-turn conversation | ❌ No | ✅ Yes |
| User control | Low | ✅ High |
| Collaborative | ❌ No | ✅ Yes |

---

## Real Example: Using Interactive Agent for Student Project

```
🤖 Agent:
Analysing WeThinkCode student blockchain project...

I've found several areas to review:
1. Smart contract security
2. Gas optimisation
3. Error handling
4. Code documentation

Which should I investigate first?

You: 1) Smart contract security

🤖 Agent:
Checking for security vulnerabilities...

FOUND: 3 potential reentrancy risks in token transfer functions.

Should I:
A) Explain the risks
B) Show how to fix them
C) Both

You: C) Both

🤖 Agent:
[Detailed explanation + fixes...]

Next, should I check gas optimisation or error handling?

You: Gas optimisation

🤖 Agent:
[Gas analysis...]

Should I save these recommendations to a report file?

You: Yes, save it

✅ Report saved to audit_report.md
```

---

## Benefits for WeThinkCode

✅ **Teachers can explore** - "Tell me more about X"  
✅ **Customised feedback** - Teacher guides the analysis  
✅ **Learning experience** - Students see the reasoning  
✅ **Iterative improvement** - Address issues step-by-step  
✅ **True collaboration** - Not just "here's a report"  

---

## When to Use Each Version

### Use Current (Batch) Agent When:
- Auditing 120 student repos
- Need quick reports
- Don't need interaction
- Running on schedule

### Use Interactive Agent When:
- Deeply analysing one specific project
- Teaching students about code quality
- Exploring potential issues
- Collaborating on improvements

---

## Hybrid Workflow for WeThinkCode

```
MONDAY 9am:
Batch Agent runs on all 120 student repos
↓ Get quick audit reports

TUESDAY-THURSDAY:
For top 5 projects needing deep work:
Interactive Agent used with teacher guidance
↓ Back-and-forth improvement sessions

FRIDAY:
Review all improvements
↓ Prepare feedback for next week
```

---

## Next Steps

1. **Copy the code** above into `interactive_agent.py`
2. **Set your API key** and repo URL
3. **Run it:** `python interactive_agent.py`
4. **Have a conversation** with your agent
5. **Experience true agentic AI** - not just automation

This is the difference between:
- ❌ **Automation:** "Do this task"
- ✅ **Agentic AI:** "Let's work together to improve this"

**Your agent now truly collaborates with you.** 🚀

---

*Made for WeThinkCode Education Leaders*  
*True Agentic AI with Human Loop*  
*Production-Ready • Collaborative • Educational*
