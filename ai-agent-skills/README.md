# AI Agent Skills — Security Analyst Toolkit

A set of structured "skills" (reusable instruction modules) built for AI agents to run consistent, evidence-driven security workflows — SOC alert triage, phishing triage, IoC enrichment, and scope-expansion pivoting — instead of freelancing a different report format every time.

## Background

I'm not a career developer — I'm a security practitioner who identifies recurring, structured tasks in day-to-day SOC work (triage reports, IoC enrichment, scope pivots) and builds AI agent skills to standardize them. I used AI (Claude/ChatGPT-style tooling within [Perplexity Computer](https://www.perplexity.ai/)) to help draft and iterate on these, working through the design decisions — trigger conditions, report structure, chaining logic between skills — myself. Full transparency, same as the rest of this portfolio.

## What's here

### `system-prompt.md`
The orchestrating system prompt for a "Security Analyst" agent. Defines an environment inventory (which platform owns which telemetry — SIEM, EDR, NDR, identity, email security, etc.), lists the skills in the intended investigation lifecycle, default chaining logic between them, and core operating principles (evidence-traceability, no fabricated verdicts, no simulated irreversible actions).

**Note:** the environment inventory table uses genericized platform categories with vendor examples (e.g. "EDR Platform (e.g. CrowdStrike Falcon, SentinelOne...)") rather than a specific company's real stack, since the original was built against a live production environment.

### `skills/`
Four of the eight skills referenced in the system prompt's lifecycle are included here (the rest — `case-narrative-builder`, `detection-gap-analysis`, `exec-summary-translator`, `threat-hunt-hypothesis` — are described in the system prompt for architecture context but not included as standalone files in this repo):

| Skill | Purpose |
|---|---|
| `analyst-assistant.md` | General SOC alert/log triage. Produces a uniform report: verdict, IoC table, timeline, MITRE ATT&CK mapping, confidence & gaps, next steps. |
| `phishing-triage.md` | Email-specific triage optimized for high-volume phishing queues. Verdict: Malicious / Spam / Legitimate. |
| `osint-ioc-enrichment.md` | Multi-source OSINT enrichment for IPs, domains, URLs, and file hashes (VirusTotal, AbuseIPDB, Shodan, urlscan.io, crt.sh, and more), with a source-routing matrix and cross-referencing logic. Called by the other skills for deeper IoC lookups. |
| `ioc-pivot-report.md` | Scope/blast-radius expansion after a confirmed True Positive — historical search queries per platform, a pivot-point checklist, and a containment verdict. |

## How these are meant to be used

Each skill file is a self-contained markdown instruction set with YAML frontmatter (`name`, `description`, `license`, `metadata`) — the format used by [Perplexity Computer's custom skills](https://www.perplexity.ai/) and similar agent frameworks (Claude, custom GPTs, etc.) that support instruction-following "skills" or "tools." Load the system prompt as the agent's base instructions, then load individual skills as needed; the skills reference each other by name for hand-offs (e.g. `analyst-assistant` → `osint-ioc-enrichment` → `ioc-pivot-report`).

## Sanitization note

These files were originally built and used against a real production security environment. Before publishing, the system prompt's environment inventory was genericized to remove specific vendor names tied to that environment; the skill files themselves never referenced a specific company's tooling and are published unchanged.
