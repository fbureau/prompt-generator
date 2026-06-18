# prompt-generator

**master-prompt** — a Claude Skill that turns any need into an expert, structured, optimized prompt. Reusable across Claude Chat, Cowork and Claude Code.

## Contents

```
master-prompt/
├── SKILL.md      # the skill (instructions + best practices)
└── exemples.md   # before/after examples loaded on demand
```

## Installation

### Claude Chat (claude.ai) and Cowork

1. Zip the folder: `cd prompt-generator && zip -r master-prompt.zip master-prompt/`
2. On claude.ai: **Settings → Capabilities → Skills → Upload skill**, then select the zip.
3. The skill triggers automatically whenever you ask to create or improve a prompt. Cowork uses the same skills as your claude.ai account.

### Claude Code

Copy the folder into your personal skills (available in all your projects):

```sh
mkdir -p ~/.claude/skills
cp -r master-prompt ~/.claude/skills/
```

Or into a specific project (shared with your team via git):

```sh
mkdir -p .claude/skills
cp -r master-prompt .claude/skills/
```

Then invoke it with `/master-prompt <your need>` or simply ask "write me a prompt for…".

## Usage

The skill works in two modes and picks automatically:

- **Execution (default)** — for a concrete one-off need, it builds the expert prompt internally, runs it, and returns the result directly. No copy-paste, no intermediate step. The prompt engineering still happens; it's just invisible, and the guardrails apply to the answer itself.

  > write me a LinkedIn post about our new pricing → returns the finished post

- **Prompt only** — for a reusable/system prompt (to run later on many inputs, with `[BRACKETED]` variables), for loop mode, or when you explicitly ask ("just give me the prompt"), it returns the prompt itself in a code block.

  > a reusable prompt to extract data from CVs → returns the prompt

If the request is too vague, it asks at most 2 targeted questions first.

## What the engineered prompts include

(Applied to the answer in execution mode, or written into the prompt in prompt-only mode.)

- A precise expert role, context and intent (no empty personas)
- Exact output format, target length, language, tone
- Anti-hallucination guardrails: say "I don't know", ask for clarification, separate facts from inferences
- Blunt honesty: no flattery, push back when a premise is wrong
- Conciseness: no filler, length calibrated to useful information
- Natural formatting: no em dashes, no systematic bullet lists, no emojis
- Token efficiency: the shortest wording that remains complete, `[BRACKETED]` variables for reusable prompts
- Long-document handling: data at the top, question at the end, quote grounding before analysis
- Agent-specific guidance (Claude Code / Cowork): explicit action verbs, "done" criteria, no over-engineering, confirmation before destructive actions
- Loop mode for long, autonomous, or iterative tasks: generates loop scaffolding (orchestration + verifiable exit gate + self-verification + state files for cross-context-window resumption) instead of a single prompt
- Ghostwriter mode for written content: human voice, varied rhythm, banned AI vocabulary, imitation of your own writing samples (no "undetectability" promise — that doesn't exist)

> Note: the skill's instructions are written in French, but it always generates prompts in the language of your request.
