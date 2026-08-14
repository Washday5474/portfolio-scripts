---
name: ioc-pivot-report
description: "Take confirmed IoCs from a closed triage and generate a scope-expansion retro-hunt report with historical search queries, a checklist of other hosts and users to check, and a blast-radius summary. Use after analyst-assistant confirms a True Positive, or whenever the user asks where else an indicator shows up, how far something spread, wants to pivot on an IoC, or wants to check historical logs for an indicator. Distinct from analyst-assistant, which gives a verdict on one alert, and threat-hunt-hypothesis, which is proactive hunting with no confirmed IoC yet."
license: MIT
metadata:
  author: manny-alvarado
  version: '1.0'
---

# IoC Pivot & Scope Expansion Report

## When to Use This Skill

Use this skill once an indicator is confirmed malicious (typically right after an `analyst-assistant` triage lands on True Positive) and the next question is scope: where else in the environment does this indicator appear, and how far did it spread. Triggers include:

- "Where else does this IP/hash/domain show up?"
- "Pivot on this IoC across our logs"
- "How far did this spread / what's the blast radius"
- "Check historical logs for this indicator going back 30/90 days"
- Natural follow-up after a True Positive verdict from `analyst-assistant`

This is not initial triage (`analyst-assistant`) and not hypothesis-driven proactive hunting with no known bad indicator yet (`threat-hunt-hypothesis`) — this skill starts from a *known-bad* IoC set and expands scope.

## Core Behavior

Think like an analyst doing scope containment during active incident response: the goal is a confident answer to "is this contained to what we already know, or is it bigger." Be systematic — check every plausible pivot point (other hosts, other users, lateral movement paths, persistence mechanisms) rather than stopping at the first negative result. Distinguish clearly between "we checked and found nothing" (a real, useful negative) and "we didn't have the data to check" (a gap) — these are not the same and must not be presented the same way.

## Instructions

1. **Confirm the IoC set and time window.** List the exact indicators being pivoted on (IPs, domains, hashes, usernames, process names, etc.) and the time window to search (default: 90 days back from first known occurrence, unless the user specifies otherwise).

2. **Enrich further if useful.** If any IoC wasn't already enriched (e.g. new IoCs discovered during the original triage that weren't looked up), use `search_web` for reputation/context the same way `analyst-assistant` does, citing sources.

3. **Build historical search queries per data source.** For each relevant platform in the current tool environment (check the system prompt/project's environment inventory if one is defined — typically the SIEM, NDR, EDR, identity platform, email security platform, and endpoint management tool), write a specific query to search historical logs for the IoC set. Mark clearly which platforms are relevant to which IoC types (e.g. a file hash pivot belongs in EDR telemetry, not the identity platform).

4. **Build a scope-expansion checklist.** Beyond direct IoC matches, list the standard pivot points an experienced investigator checks:
   - Other hosts with the same hash/process/persistence artifact
   - Other accounts used from the same source IP or in the same session window
   - Lateral movement indicators (new sign-ins from affected accounts to other systems, new admin/service account creation, unusual internal traffic from affected hosts)
   - Persistence mechanisms (scheduled tasks, registry run keys, new OAuth app grants, forwarding rules in mailboxes)
   - Data staging/exfil indicators from any newly-identified affected host

5. **Present findings as a blast-radius summary.** For each pivot point, state clearly: Checked / Found — details, or Checked / Not Found, or Not Checked — data unavailable (and what would be needed to check it).

6. **Give a scope verdict.** Contained to originally known scope, or Expanded — list what's newly in scope, or Indeterminate — gaps prevent a confident answer.

7. **Hand off cleanly.** If scope expanded to new hosts/accounts, note that each newly affected entity should go through its own `analyst-assistant` triage or be added to the case via `case-narrative-builder`. If the investigation is closing, flag it as a candidate for `detection-gap-analysis` so the confirmed IoCs and TTPs get turned into future detections.

## Output Structure

Structure the report using these sections, in this order:

**Title:** IoC Pivot Report: <short incident title>

**Scope of This Pivot**
- IoCs: <list>
- Time window searched: <range>
- Originally confirmed via: <link/reference to source triage>

**IoC Enrichment (new/updated only)** — table with columns: Type, Value, Reputation/Context, Source

**Historical Search Queries** — one labeled query per relevant platform (SIEM, NDR, EDR, identity platform, email security, M365, firewall/proxy). Present each as a labeled code snippet, e.g. "Rapid7 InsightIDR (LEQL):" followed by the query text.

**Scope Expansion Checklist** — table with columns: Pivot Point, Status (Checked/Not Checked), Findings. Rows: other hosts with same artifact, other accounts from same source, lateral movement indicators, persistence mechanisms, data staging/exfil from new hosts.

**Blast Radius Verdict** — Contained / Expanded / Indeterminate, with reasoning.

**Newly Identified Scope (if any)** — list of new hosts/accounts/systems requiring their own triage.

**Recommended Follow-Up**
- Additional triage needed on: ...
- Detection gap candidates for `detection-gap-analysis`: ...

## Example

**Input:** "analyst-assistant confirmed this EDR detection as a True Positive — malicious hash abc123 on host WKSTN-042. Pivot and see where else this shows up."

**Output:** Searches historical EDR telemetry and SIEM logs for the hash across all endpoints, checks the identity platform for the affected user's sign-ins to other systems in the surrounding time window, checks for the same hash or related C2 IP anywhere else in the last 90 days, and returns a blast-radius verdict — e.g. "Expanded: hash also found on WKSTN-091, recommend individual triage on that host" — plus a note to formalize the hash and C2 IP as a custom EDR detection rule via `detection-gap-analysis`.
