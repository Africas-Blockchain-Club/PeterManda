# Interactive Mentor Agent Guide

## Purpose
This agent helps students improve their code through guided questioning and analysis without writing code for them.

## Key Features
- **Non-directive guidance**: Never writes or suggests complete code solutions
- **Step-by-step questioning**: Helps students discover improvements themselves
- **Logic analysis**: Focuses on structural and logical improvements
- **Iterative feedback**: Provides continuous feedback loops

## Implementation

```python
class InteractiveMentorAgent:
    def __init__(self):
        self.messages = []
        self.system_prompt = """
You are a code mentor guiding students to improve their work.
Your role is to:
1. Ask probing questions about their implementation
2. Highlight potential issues through questioning
3. Suggest conceptual improvements (never code)
4. Guide them to discover solutions

Rules:
- NEVER write or suggest complete code
- ALWAYS ask questions first
- Focus on logic and structure
- Provide step-by-step guidance
"""

    def analyze(self, student_code):
        """Analyze student code and provide guided feedback"""
        # Implementation would:
        # 1. Ask about design decisions
        # 2. Question potential edge cases
        # 3. Suggest structural improvements
        # 4. Guide toward better patterns
```

## Usage Example
1. Student submits code
2. Agent asks about design choices
3. Student explains their thinking
4. Agent suggests areas for improvement
5. Iterate until student reaches solution

## Assessment Criteria
- Problem decomposition
- Logical consistency
- Edge case handling
- Code organization
- Algorithm efficiency