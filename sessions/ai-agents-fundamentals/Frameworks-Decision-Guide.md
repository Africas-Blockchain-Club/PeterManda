# AI Agents: Complete Frameworks Comparison & Decision Guide

**For:** WeThinkCode Education Leaders Making Technology Decisions  
**Date:** December 2025  
**Focus:** Practical comparisons beyond n8n & Zapier

---

## Executive Summary

### Quick Decision Tree

```
Do you want to CODE?
├─ YES → LiteLLM (your Mentor Agent) or LangChain
└─ NO  → Do you want VISUAL builders?
         ├─ YES → Flowise, VectorShift, or Zapier/n8n
         └─ NO  → You probably don't need an agent
```

---

## 1. All Major Frameworks Comparison

### Tier 1: Code-Based Frameworks (Maximum Control)

#### LiteLLM (Your Mentor Agent)
```python
from litellm import completion
response = completion(model="gpt-4o", messages=...)  # Switch models instantly
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐ | Minimal abstraction, direct LLM calls |
| **Flexibility** | ⭐⭐⭐⭐⭐ | Supports 100+ models and providers |
| **Production Readiness** | ⭐⭐⭐⭐⭐ | Battle-tested, used at scale |
| **Learning Curve** | ⭐⭐ | Requires Python + agent loop knowledge |
| **Community** | ⭐⭐⭐ | Growing, active maintainers |
| **Cost** | Free | Pay only for API calls |

**Best for:**
- ✅ Custom agent logic (your case)
- ✅ Multi-model flexibility
- ✅ Production deployments
- ✅ Education (understanding how agents work)

**Not ideal for:**
- ❌ Complex RAG (use LangChain instead)
- ❌ Multi-agent orchestration (use CrewAI)
- ❌ Non-coders

---

#### LangChain (Full-Featured Framework)
```python
from langchain.agents import initialize_agent
agent = initialize_agent(tools, llm, agent="zero-shot-react-description")
result = agent.invoke({"input": "Your query"})
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐ | Steep learning curve, many abstractions |
| **Flexibility** | ⭐⭐⭐⭐ | Highly extensible but opinionated |
| **Production Readiness** | ⭐⭐⭐⭐ | Mature, but rapid changes |
| **Learning Curve** | ⭐ | Complex documentation, many concepts |
| **Community** | ⭐⭐⭐⭐⭐ | Largest Python agent community |
| **Cost** | Free | Pay only for API calls |

**Best for:**
- ✅ RAG (document retrieval + agents)
- ✅ Complex multi-step workflows
- ✅ Teams that need extensive examples
- ✅ Integration with vector databases

**Not ideal for:**
- ❌ Beginners (too complex)
- ❌ Simple use cases
- ❌ Performance-critical apps (heavy dependencies)

**When to choose LangChain over LiteLLM:**
- You need RAG (retrieve documents, then reason)
- You want pre-built integrations with 100+ tools
- Your team already knows LangChain

---

#### LangGraph (Workflow Orchestration)
```python
from langgraph.graph import StateGraph
graph = StateGraph(AgentState)
graph.add_node("agent", agent_node)
graph.add_edge("agent", "tools")
app = graph.compile()
result = app.invoke({"input": "Your query"})
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐ | Visual thinking + code |
| **Flexibility** | ⭐⭐⭐⭐ | Excellent state management |
| **Production Readiness** | ⭐⭐⭐⭐ | Mature, proven at scale |
| **Learning Curve** | ⭐⭐ | Need to understand state machines |
| **Community** | ⭐⭐⭐⭐ | Active, good documentation |
| **Cost** | Free | Pay only for API calls |

**Best for:**
- ✅ Complex multi-step workflows
- ✅ State-based logic (conditionals, loops)
- ✅ Debugging (visualise agent decisions)
- ✅ Multi-agent systems

**Not ideal for:**
- ❌ Simple agents (overkill)
- ❌ Real-time systems (overhead)

---

#### CrewAI (Multi-Agent Teams)
```python
from crewai import Agent, Task, Crew

agent = Agent(role="Code Reviewer", goal="Review code", tools=[...])
task = Task(description="Audit repo", agent=agent)
crew = Crew(agents=[agent], tasks=[task])
result = crew.kickoff()
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐⭐ | Intuitive role-based design |
| **Flexibility** | ⭐⭐⭐ | Opinionated, less customisable |
| **Production Readiness** | ⭐⭐⭐⭐ | Increasingly mature |
| **Learning Curve** | ⭐⭐ | Easy to pick up, hard to extend |
| **Community** | ⭐⭐⭐ | Growing, many examples |
| **Cost** | Free | Pay only for API calls |

**Best for:**
- ✅ Multi-agent systems (different specialists)
- ✅ Emergent team behaviour
- ✅ Non-technical users who can code Python
- ✅ Role-based task distribution

**Not ideal for:**
- ❌ Simple single-agent tasks
- ❌ Ultra-high performance needs
- ❌ Deep customisation required

---

#### Semantic Kernel (Enterprise)
```csharp
// C#, Python, Java
var kernel = new Kernel();
kernel.ImportFunctions(myFunctions, "My");
var result = await kernel.InvokeAsync("My-MyFunction", ...);
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐ | Verbose, enterprise-style |
| **Flexibility** | ⭐⭐⭐ | Good for enterprise patterns |
| **Production Readiness** | ⭐⭐⭐⭐⭐ | Microsoft-backed, enterprise-grade |
| **Learning Curve** | ⭐⭐ | More boilerplate code |
| **Community** | ⭐⭐⭐ | Strong in enterprise circles |
| **Cost** | Free | Pay for APIs + Azure services |

**Best for:**
- ✅ Enterprise organisations using Microsoft stack
- ✅ .NET/Java/Python polyglot teams
- ✅ Azure integration requirements
- ✅ Large-scale deployments

**Not ideal for:**
- ❌ Startups (too heavy)
- ❌ Simple projects
- ❌ Python-only teams

---

#### Letta / MemGPT (Stateful Agents)
```python
from letta import Client

client = Client()
agent = client.create_agent(name="My Agent", model="gpt-4o")
response = client.user_message(agent_id=agent.id, message="Hello")
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐ | Clean API, but new concepts |
| **Flexibility** | ⭐⭐⭐ | Good memory management |
| **Production Readiness** | ⭐⭐⭐ | Evolving, promising |
| **Learning Curve** | ⭐⭐ | New paradigm (memory-first) |
| **Community** | ⭐⭐ | Small but enthusiastic |
| **Cost** | Free | Pay for API calls |

**Best for:**
- ✅ Long-running agents with memory
- ✅ Persistent state across sessions
- ✅ Chatbots that "remember" conversations
- ✅ Complex reasoning over time

**Not ideal for:**
- ❌ Stateless operations
- ❌ Real-time performance needs
- ❌ Production systems (still evolving)

---

### Tier 2: Low-Code Visual Frameworks

#### Flowise (Visual Agent Builder)
```
UI-based: Drag nodes → Connect → Deploy
No coding required, or use JavaScript for advanced logic
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | Pure visual, non-coders OK |
| **Flexibility** | ⭐⭐⭐ | Limited by UI, extensible with code |
| **Production Readiness** | ⭐⭐⭐⭐ | Self-hosted, reliable |
| **Learning Curve** | ⭐⭐⭐⭐⭐ | Very easy for visual thinkers |
| **Community** | ⭐⭐⭐⭐ | Large, active open-source community |
| **Cost** | Free | Self-hosted (free), cloud (paid) |

**Best for:**
- ✅ Non-technical users
- ✅ Rapid prototyping
- ✅ Self-hosted deployments
- ✅ Visual workflow builders who want control

**Not ideal for:**
- ❌ Complex custom logic
- ❌ High-performance systems
- ❌ Deep integrations

**How it works:**
1. Drag "Load Doc" node
2. Connect to "Agent" node
3. Connect to "LLM" node
4. Click Deploy → Get API endpoint
5. Call via REST API

---

#### VectorShift (No-Code AI Workflows)
```
UI-based: Connect components, set parameters
Supports 100+ integrations out-of-box
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐⭐ | User-friendly UI |
| **Flexibility** | ⭐⭐⭐ | Good integration library |
| **Production Readiness** | ⭐⭐⭐⭐ | Cloud-based, reliable |
| **Learning Curve** | ⭐⭐⭐⭐⭐ | Very intuitive |
| **Community** | ⭐⭐⭐ | Growing |
| **Cost** | Freemium | $0 (limited) to $99+/month |

**Best for:**
- ✅ Non-technical teams
- ✅ Pre-built integrations (Google Sheets, Slack, etc.)
- ✅ Rapid deployment
- ✅ Educational institutions (good free tier)

**Comparison to Flowise:**
- VectorShift: More integrations, cloud-first, less code
- Flowise: More control, self-hosted option, more customisable

---

#### Buildship (Backend Workflows)
```javascript
// Visual builder + Node.js backend
Triggers → Actions → Responses
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐ | Visual + some coding |
| **Flexibility** | ⭐⭐⭐⭐ | Node.js integration |
| **Production Readiness** | ⭐⭐⭐⭐ | Solid, enterprise-used |
| **Learning Curve** | ⭐⭐⭐ | Need some JavaScript knowledge |
| **Community** | ⭐⭐⭐ | Growing |
| **Cost** | Freemium | $0-$99+/month |

**Best for:**
- ✅ Backend API workflows
- ✅ Webhook-driven automations
- ✅ Integration between services
- ✅ Teams comfortable with JavaScript

**Not ideal for:**
- ❌ Complex reasoning
- ❌ Agents with state
- ❌ Stateful operations

---

#### StackAI (Template-Based)
```
Pre-built templates for common tasks
Visual customisation, quick deployment
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | Template-driven, very fast |
| **Flexibility** | ⭐⭐ | Limited customisation |
| **Production Readiness** | ⭐⭐⭐ | Good for simple use cases |
| **Learning Curve** | ⭐⭐⭐⭐⭐ | Easiest onboarding |
| **Community** | ⭐⭐ | Smaller community |
| **Cost** | $199+/month | Premium pricing |

**Best for:**
- ✅ "No-code" speed
- ✅ Marketing teams
- ✅ Rapid MVPs
- ✅ Templates matching your use case

**Not ideal for:**
- ❌ Custom logic
- ❌ Budget-conscious teams
- ❌ Long-term maintenance

---

#### RelevanceAI
```
Australia-based, raised $10M
Multi-agent orchestration via UI
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐ | Good UI, complex workflows |
| **Flexibility** | ⭐⭐⭐⭐ | Multi-agent support |
| **Production Readiness** | ⭐⭐⭐⭐ | Enterprise-grade |
| **Learning Curve** | ⭐⭐⭐ | Moderate |
| **Community** | ⭐⭐⭐ | Growing in APAC |
| **Cost** | $19-299+/month | Freemium to enterprise |

**Best for:**
- ✅ Multi-agent orchestration
- ✅ Australian/APAC teams
- ✅ Enterprise deployments
- ✅ Complex automation

---

#### AgentHub (Self-Executing Agents)
```
YC24 startup, raised $2.7M
Only platform with true agent self-execution
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐ | Novel interface, learning curve |
| **Flexibility** | ⭐⭐⭐⭐ | Self-executing agents |
| **Production Readiness** | ⭐⭐⭐ | New, promise high but unproven |
| **Learning Curve** | ⭐⭐⭐ | New paradigm |
| **Community** | ⭐ | Very new, small community |
| **Cost** | $297/month | Expensive, no free tier |

**Best for:**
- ✅ Agents that run without user input
- ✅ Autonomous task execution
- ✅ Teams with budget
- ✅ Future-looking experiments

**Not ideal for:**
- ❌ Cost-conscious teams
- ❌ Unproven technology risk
- ❌ No free trial to test

---

### Tier 3: Traditional Workflow Automation (Not Really "Agents")

#### n8n (Open-Source Workflows)
```javascript
Visual workflow builder with 400+ integrations
Self-hosted or cloud deployment
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐⭐ | Visual, non-coders OK |
| **Flexibility** | ⭐⭐⭐⭐ | Extensible, self-hosted |
| **Production Readiness** | ⭐⭐⭐⭐⭐ | Battle-tested, reliable |
| **Learning Curve** | ⭐⭐⭐⭐ | Easy to learn |
| **Community** | ⭐⭐⭐⭐⭐ | Large, active |
| **Cost** | Free (self-host) or $50+/month | Excellent value |

**Agent capabilities:** ⚠️ Limited
- n8n can call APIs and chain actions
- But no true reasoning/decision-making
- Good for workflows, not pure agents

**Best for:**
- ✅ Business process automation
- ✅ API chaining and integrations
- ✅ Scheduled workflows
- ✅ Self-hosted requirements

**Why n8n isn't an agent framework:**
- Lacks autonomous reasoning loop
- No "decide what to do next" capability
- Good for deterministic workflows
- Poor for ambiguous, complex reasoning

---

#### Zapier (Cloud Workflows)
```
Drag-drop automation with 7,000+ apps connected
Non-technical user friendly
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | Easiest platform |
| **Flexibility** | ⭐⭐⭐ | Limited, but improves |
| **Production Readiness** | ⭐⭐⭐⭐⭐ | Industry standard |
| **Learning Curve** | ⭐⭐⭐⭐⭐ | Non-coders start immediately |
| **Community** | ⭐⭐⭐⭐⭐ | Largest marketplace |
| **Cost** | $25-50+/month | Expensive for scale |

**Agent capabilities:** ⚠️ Very Limited
- Zapier AI does some decision-making
- But mostly template-based
- Good for simple automations

**Why use Zapier:**
- ✅ Non-technical teams
- ✅ 7,000+ pre-built integrations
- ✅ No infrastructure needed
- ✅ Fast deployment

**Why NOT for serious agents:**
- ❌ Expensive (cost scales with usage)
- ❌ Limited reasoning capability
- ❌ Vendor lock-in
- ❌ Not suitable for complex logic

---

#### Make.com (Mid-Market Workflows)
```
Alternative to Zapier/n8n
Better than Zapier (cheaper), less than n8n (more integrations)
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐⭐ | User-friendly |
| **Flexibility** | ⭐⭐⭐⭐ | Good logic capabilities |
| **Production Readiness** | ⭐⭐⭐⭐ | Reliable |
| **Learning Curve** | ⭐⭐⭐ | Moderate |
| **Community** | ⭐⭐⭐ | Growing |
| **Cost** | $9-99+/month | Middle ground pricing |

**Best for:**
- ✅ Mid-market automation
- ✅ Balance of power and ease
- ✅ Cost-conscious teams
- ✅ More complex logic than Zapier

---

#### Microsoft Copilot Studio + Power Automate
```
Enterprise option for Microsoft shops
Integration with M365, Azure, Teams
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Ease of Use** | ⭐⭐⭐ | Good if you know M365 |
| **Flexibility** | ⭐⭐⭐⭐⭐ | Enterprise-grade |
| **Production Readiness** | ⭐⭐⭐⭐⭐ | Microsoft-backed |
| **Learning Curve** | ⭐⭐⭐ | Depends on M365 familiarity |
| **Community** | ⭐⭐⭐⭐ | Large enterprise base |
| **Cost** | $50-500+/month | Part of M365 |

**Best for:**
- ✅ Microsoft-centric organisations
- ✅ Office 365 + Teams integration
- ✅ Enterprise security requirements
- ✅ Power BI reporting integration

**Not ideal for:**
- ❌ Non-Microsoft shops
- ❌ Cost-conscious startups
- ❌ Multi-vendor environments

---

## 2. Decision Matrix

### Choose LiteLLM (Your Mentor Agent) If...

✅ You want **maximum control** over agent logic  
✅ You need **multi-model flexibility** (swap models with one line)  
✅ You're building **production-grade agents**  
✅ You understand **Python and want to learn deeply**  
✅ Your team values **simplicity and no abstractions**  
✅ You care about **cost efficiency** (direct API calls)  
✅ You're teaching **how agents work** to students  

❌ You don't code  
❌ You want pre-built integrations (use LangChain)  
❌ You need RAG (use LangChain + LiteLLM)  
❌ You want visual builders  

---

### Choose LangChain If...

✅ You need **RAG** (document retrieval + reasoning)  
✅ You want **pre-built integrations** with 100+ tools  
✅ You need **community examples and tutorials**  
✅ Your team is already **familiar with LangChain**  
✅ You're building **complex multi-step workflows**  
✅ You want **memory management** and **session handling**  

❌ You value simplicity (too complex)  
❌ You're just starting (steep learning curve)  
❌ Performance is critical (heavy)  
❌ You want to understand agents from scratch  

---

### Choose CrewAI If...

✅ You need **multiple agents collaborating**  
✅ You want **role-based task distribution**  
✅ You like **intuitive, readable syntax**  
✅ You're interested in **emergent behaviours**  
✅ You have **Python skills but want simplicity**  

❌ You have a simple single-agent task  
❌ You need extreme customisation  
❌ You value lightweight dependencies  

---

### Choose Flowise If...

✅ You're **non-technical** (true no-code)  
✅ You want **visual workflow builders**  
✅ You need **self-hosted option**  
✅ You want **quick prototyping**  
✅ You care about **control over infrastructure**  
✅ You're in an **educational setting** (open-source, free)  

❌ You need complex custom logic  
❌ You don't want to manage infrastructure  
❌ You need 100s of pre-built integrations  

---

### Choose Zapier If...

✅ You're **truly non-technical**  
✅ You want **fastest time-to-automation** (minutes)  
✅ You need **7,000+ pre-built integrations**  
✅ You don't want to manage any infrastructure  
✅ You have **simple workflows** (A → B → C)  

❌ You care about **cost** (expensive at scale)  
❌ You need **custom logic** or reasoning  
❌ You want to understand how it works  
❌ You need **full control**  

---

### Choose n8n If...

✅ You want **visual workflows** with some coding  
✅ You need **self-hosted option** (free deployment)  
✅ You want **balance of power and ease**  
✅ You care about **cost** (free self-hosted)  
✅ You need **400+ integrations**  
✅ You want **open-source** (no vendor lock-in)  

❌ You need true **autonomous agents**  
❌ You want **pure no-code** (some coding required)  
❌ You need **highest reasoning capability**  

---

### Choose Semantic Kernel If...

✅ You're in an **enterprise organisation**  
✅ You use **Microsoft stack** (.NET, Azure)  
✅ You have **large budgets**  
✅ You need **official support**  
✅ You want **multi-language support** (C#, Python, Java)  

❌ You're a startup (too heavy, expensive)  
❌ You don't use Azure (unnecessary complexity)  
❌ You prefer simplicity (too verbose)  

---

## 3. Comparison Table: Head-to-Head

| Feature | LiteLLM | LangChain | CrewAI | LangGraph | Flowise | n8n | Zapier |
|---------|---------|-----------|--------|-----------|---------|------|--------|
| **Coding Required** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No | ⚠️ Some | ❌ No |
| **Ease for Non-Coders** | ❌ No | ❌ No | ❌ No | ❌ No | ✅ Yes | ✅ Yes | ✅✅ Yes |
| **Multi-Model Support** | ✅✅ 100+ | ✅ Yes | ✅ Yes | ✅ Yes | ⚠️ Limited | ❌ No | ❌ No |
| **RAG Built-In** | ❌ No | ✅ Yes | ⚠️ Via plugins | ⚠️ Via LangChain | ✅ Yes | ❌ No | ❌ No |
| **Multi-Agent** | ⚠️ Manual | ✅ Yes | ✅✅ Native | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **State Management** | ⚠️ Manual | ✅ Yes | ✅ Yes | ✅✅ Excellent | ✅ Yes | ✅ Yes | ✅ Yes |
| **Self-Hosted** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| **Visual Builder** | ❌ No | ❌ No | ❌ No | ⚠️ Partial | ✅ Yes | ✅ Yes | ✅✅ Yes |
| **Learning Curve** | ⭐⭐ | ⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Production Ready** | ✅✅ | ✅ | ✅ | ✅✅ | ✅ | ✅✅ | ✅✅ |
| **Free** | ✅ (pay APIs) | ✅ (pay APIs) | ✅ (pay APIs) | ✅ (pay APIs) | ✅ | ✅ (self-host) | ⚠️ (cloud only) |
| **Typical Cost** | $0.01-0.30 per audit | $0.05-0.50 | $0.05-0.50 | $0.05-0.50 | $0-50/mo | $0-50/mo | $25-300+/mo |

---

## 4. For WeThinkCode Specifically

### Current Needs Analysis

**Your Requirements:**
- Audit student GitHub repositories
- Provide strategic feedback (not just code fixes)
- Prioritise documentation before code
- Scale to multiple cohorts
- Curriculum-specific guidance (blockchain, AI)

### Recommendation: Hybrid Approach

**Short-term (Immediate):**
```
Use: LiteLLM (your Mentor Agent)
Why: Complete control, low cost, educational value
Cost: ~ZAR1.18-3.53 per audit
Setup: 1-2 hours
```

**Medium-term (6 months):**
```
Add: Flowise for non-technical feedback
Why: Some feedback types don't need coding
Cost: Free (self-hosted)
Setup: 1-2 days
```

**Long-term (1 year+):**
```
Consider: CrewAI for multi-agent feedback
Why: Different specialists (code reviewer, security, docs)
Cost: Low (API only)
Setup: 1-2 weeks
```

### Customisation Path for WeThinkCode

**Step 1: Customise System Prompt (Immediate)**
```python
system_prompt = """
You are a WeThinkCode Code Mentor...

FOCUS AREAS:
1. Smart contract security (for blockchain cohort)
2. AI/ML best practices (for AI cohort)
3. Software engineering principles
4. Documentation for learning
...
"""
```

**Step 2: Add Blockchain-Specific Tools**
```python
def check_solidity_security(self, repo_path):
    """Check for common Solidity vulnerabilities"""
    
def analyze_contract_gas(self, repo_path):
    """Estimate gas costs"""
```

**Step 3: Add AI/Curriculum Integration**
```python
def send_feedback_to_student_portal(self, student_id, report):
    """Post audit to WTC student dashboard"""
    
def track_progress_over_time(self, student_id):
    """Compare this audit to previous ones"""
```

**Step 4: Schedule Audits**
```bash
# Weekly audits of all student repos
0 9 * * 1 python audit_all_students.py  # Monday 9am
```

---

## 5. Cost Comparison (Annual)

### Scenario: Audit 30 Student Repos Weekly (1,560/year)

| Tool | Setup | Per-Audit | Annual | Notes |
|------|-------|-----------|--------|-------|
| **LiteLLM + gpt-4o** | ZAR0 | ZAR3.53 | ZAR5499 | Our recommendation |
| **LiteLLM + gpt-4o-mini** | ZAR0 | ZAR1.18 | ZAR1833 | Cost-optimised |
| **Flowise (self-hosted)** | ZAR0-11750 | ZAR0 | ZAR0-11750 | Free + infrastructure |
| **n8n (self-hosted)** | ZAR0-11750 | ZAR0 | ZAR0-11750 | Free + infrastructure |
| **Zapier** | ZAR0 | ZAR11.75-23.50 | ZAR18330-36660 | No setup, expensive at scale |
| **StackAI** | ZAR0 | ZAR4.70 | ZAR72756 | Fixed monthly ($199) + APIs |

**Winner for WeThinkCode:** LiteLLM + gpt-4o-mini = **ZAR1833/year**

---

## 6. Migration Paths

### If You Start with Flowise and Want More Power

```
Flowise (Visual) → Add LangChain (Code)
Why: Flowise handles simple feedback, LangChain for complex reasoning
```

### If You Start with Zapier and Outgrow

```
Zapier (Automation) → n8n (Self-hosted workflows) → LiteLLM (Agents)
Why: Linear progression as complexity increases
```

### If You Want Maximum Flexibility

```
LiteLLM (Start) → LangChain (Add RAG) → CrewAI (Multi-agents)
Why: Add capabilities as needed without switching platforms
```

---

## 7. Questions to Ask Before Choosing

1. **How technical is your team?**
   - Non-technical → Flowise/Zapier
   - Some Python → LiteLLM
   - Deep Python → LangChain

2. **How urgent is deployment?**
   - Days → Zapier/Flowise
   - Weeks → LiteLLM/n8n
   - Months → LangChain/CrewAI

3. **How much can you spend?**
   - < ZAR2350/year → LiteLLM or self-hosted
   - ZAR2350-23500/year → n8n or Make.com
   - > ZAR23500/year → Zapier or enterprise solutions

4. **How much control do you need?**
   - Maximum → LiteLLM/LangChain
   - Good balance → n8n/Flowise
   - Minimal (just use) → Zapier

5. **Do you need to customise for your domain?**
   - Yes (blockchain, AI) → LiteLLM/LangChain
   - Maybe → Flowise/n8n
   - No → Zapier

---

## Conclusion

**For WeThinkCode in December 2025:**

1. **Start:** Your Mentor Agent (LiteLLM) ✅
   - Full control
   - Customisable for blockchain/AI
   - Cost: ~ZAR1833/year
   - Timeline: Ready now

2. **Extend:** Add Flowise for non-coders (optional)
   - Some teachers give feedback via visual interface
   - Timeline: Q1 2026

3. **Scale:** Migrate to multi-agent system (optional)
   - Different specialists for different reviews
   - Timeline: Q4 2026+

**Your competitive advantage:**
- Custom agent tuned for blockchain + AI education
- Understand exactly how it works
- Teach students about agents
- Scale without vendor lock-in
- Cost-effective

---

## Resources

**Official Docs:**
- LiteLLM: https://docs.litellm.ai
- LangChain: https://python.langchain.com
- CrewAI: https://docs.crewai.com
- Flowise: https://flowiseai.com/docs

**Comparisons:**
- GitHub: "awesome-ai-agents"
- Reddit: r/LLMDevs
- LinkedIn: Search "AI agents comparison 2025"

**For Educators:**
- Your Mentor Agent is production-ready
- Use it for student feedback at scale
- Customise for your curriculum
- Share the learning resources with your team

---