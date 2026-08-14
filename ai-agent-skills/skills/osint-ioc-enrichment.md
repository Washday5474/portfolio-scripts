---
name: osint-ioc-enrichment
description: "Perform deep, multi-source OSINT enrichment on one or more indicators of compromise (IPs, domains, URLs, file hashes). Use when the user asks to enrich, look up, check reputation on, pivot infrastructure for, or run OSINT on an IoC, or when analyst-assistant, phishing-triage, or ioc-pivot-report need a deeper enrichment pass than a generic web search. Routes each indicator to the most relevant public OSINT sources by type (VirusTotal, AbuseIPDB, AlienVault OTX, Talos, abuse.ch for reputation; urlscan.io, Joe Sandbox, ANY.RUN, Hybrid Analysis, triage.dropbox for sandbox/behavioral analysis; Shodan, Censys, BuiltWith, crt.sh, WHOIS/DNS history for infrastructure), cross-references findings across sources, and returns a consolidated triage-friendly verdict with confidence and source links. Uses free/public lookups only — no API keys assumed."
license: MIT
metadata:
  author: manny-alvarado
  version: '1.0'
---

# OSINT IoC Enrichment

## When to Use This Skill

Use this skill whenever an indicator of compromise needs a real enrichment pass — not just a single web search, but a systematic sweep of the OSINT sources that actually cover that indicator type. Triggers include:

- Direct asks: "enrich this IP/domain/URL/hash," "run OSINT on this," "check reputation on...," "what do VirusTotal/Shodan/urlscan say about..."
- A hand-off from another skill in the lineup that needs deeper enrichment than its own default pass:
  - `analyst-assistant` — for any IoC in its table that warrants more than a quick reputation check (external IP/domain/URL with no immediate hits, or a hash that needs sandbox/family classification)
  - `phishing-triage` — for sender IPs, links, and attachments pulled from a reported email
  - `ioc-pivot-report` — when building or refreshing the "IoC Enrichment (new/updated only)" table for a scope-expansion pivot
- Ad hoc infrastructure/attack-surface questions: "what's exposed on this IP," "what's this domain's hosting/tech stack history," "has this cert/domain been seen before"

Do not use this skill for full alert triage, timeline reconstruction, or verdict-on-an-alert work — that's `analyst-assistant`. This skill only enriches indicators; it doesn't decide whether an alert is a true positive on its own (though its findings feed directly into that decision).

## Core Behavior

Act as an analyst doing a proper OSINT sweep, not a single Google search. For every indicator, work out its type, pick the sources that actually apply to that type (a file hash has no business being run through Shodan; an IP has no business being run through BuiltWith), query each relevant source, and then cross-reference: agreement across independent sources is a stronger signal than one hit, and a single source flagging something the rest miss is worth calling out rather than averaging away.

Treat the user as a peer security engineer. Skip definitions of basic terms. Be precise about what each source actually returned — don't summarize "it's malicious" when the real finding is "3/70 engines flag it as generic heuristic, no named family, first seen 2 days ago." That distinction changes the triage call downstream.

This skill uses free/public-tier lookups only (no API keys assumed in this environment):
- **Web UI lookups**: search the web for the indicator directly against a source's public lookup page (e.g. `virustotal.com/gui/ip-address/<ip>`, `abuseipdb.com/check/<ip>`) and read the cached/indexed result.
- **Free public API endpoints**: some sources expose a no-key or low-friction public endpoint (e.g. `crt.sh?q=<domain>&output=json`, abuse.ch's public feeds) — fetch these directly when available.
- If a source requires a login/API key to see anything useful and no key is configured in this environment, note it as **"not queryable without an API key in this environment"** rather than silently skipping it or fabricating a result. This keeps the report honest about coverage gaps.

Never fabricate scan results, detection ratios, or scores. If a lookup returns nothing, comes back inconclusive, or the source can't be reached, say so explicitly — "no OSINT hits" and "not queryable" are both useful, distinct signals and must not be blurred together or omitted.

## Instructions

1. **Classify each indicator.** For every IoC provided, identify its type: IPv4/IPv6, domain, URL, or file hash (and hash algorithm — MD5/SHA1/SHA256). Deduplicate. Skip RFC1918/private IPs, localhost, and well-known benign infrastructure (major cloud provider ranges tied to a sanctioned service already in use) — note these as skipped with a one-line reason rather than running dead-end lookups.

2. **Route each indicator to its source set.** Use the Source Routing Matrix below to determine which OSINT sources apply. Don't run every source against every indicator — an IP doesn't need BuiltWith, a hash doesn't need Shodan. Query all applicable sources per indicator, not just the first one that returns a hit.

3. **Query each applicable source.** For each source, perform the lookup and record: what the source reported, when the data was last updated/first seen (staleness matters — a "malicious" verdict from a 2019 scan carries less weight than one from last week), and the direct URL to the source's result page for that indicator (needed for the report's Source column and for the user to pivot manually later).

4. **Cross-reference across sources.** For each indicator, synthesize what independent sources agree on vs. where they conflict:
   - **Corroborated**: 2+ independent sources flag the same thing (e.g. AbuseIPDB abuse reports + VirusTotal detections + Shodan showing exposed C2-typical ports)
   - **Single-source flag**: only one source flags it — still worth reporting, but call out that it's uncorroborated
   - **Clean across sources**: nothing found anywhere queried — report as "no OSINT hits across N sources queried" (list which), not just "clean," so the user knows the actual coverage
   - **Conflicting**: sources disagree (e.g. VirusTotal clean but AbuseIPDB has recent abuse reports) — surface the conflict rather than picking a side

5. **Assign a per-indicator verdict.** Classify each indicator as **Malicious**, **Suspicious**, **Clean**, or **Insufficient Data** (when key sources couldn't be queried). This maps directly into the IoC tables used by `analyst-assistant`, `phishing-triage`, and `ioc-pivot-report`.

6. **Note pivot-worthy findings.** Flag anything that suggests further pivoting is warranted — shared C2 infrastructure, a hash tied to a named malware family/threat actor, a domain sharing a registrant/cert/IP with other known-bad infrastructure, or a URL that's part of a known phishing kit. This is the handoff point to `ioc-pivot-report` for scope expansion.

7. **Output using the report structure below.** Default to the **Full Report** format when called directly by the user for one or more indicators. Use the **Compact Block** format when another skill invokes this skill inline to fill a single row/cell of its own IoC table (e.g. `analyst-assistant` enriching one IP in its Indicators of Compromise table) — the compact block is designed to drop straight into that table's "Reputation / Context" and "Source" columns.

## Source Routing Matrix

Query every source in the relevant row that's reachable; don't stop at the first hit.

| Indicator Type | Reputation / Blocklist | Sandbox / Behavioral | Infrastructure / Attack Surface |
|---|---|---|---|
| **IPv4/IPv6** | AbuseIPDB, VirusTotal, AlienVault OTX, Talos Intelligence, abuse.ch (ThreatFox) | — (not applicable) | Shodan, Censys, BGP/ASN lookup (e.g. bgp.he.net), reverse DNS |
| **Domain** | VirusTotal, AlienVault OTX, Talos Intelligence, abuse.ch (URLhaus for domains hosting malware) | urlscan.io (historical scans of the domain) | crt.sh (cert transparency), WHOIS/WHOIS history, DNS history (e.g. SecurityTrails/DNSDB if available, else current DNS), BuiltWith (tech stack + hosting history) |
| **URL** | VirusTotal, urlscan.io reputation view, abuse.ch (URLhaus) | urlscan.io (live scan/screenshot), ANY.RUN, Hybrid Analysis, Joe Sandbox (if a public report exists for the URL) | BuiltWith (tech stack of the landing page), crt.sh for the host domain |
| **File Hash (MD5/SHA1/SHA256)** | VirusTotal (detection ratio + vendor labels), AlienVault OTX, abuse.ch (MalwareBazaar) | Hybrid Analysis, ANY.RUN, Joe Sandbox, triage.dropbox (tria.ge) — for family/behavioral classification | — (not applicable) |

Notes on specific sources:
- **VirusTotal** is the anchor source for every indicator type except pure infrastructure fingerprinting — always check it first, it often surfaces which other sources already have write-ups.
- **urlscan.io** is the primary sandbox source for URLs/domains when a live or historical scan exists; it also surfaces the resolved IP, redirect chain, and a screenshot reference.
- **Joe Sandbox / ANY.RUN / Hybrid Analysis / tria.ge** public report search is hash- and URL-driven — search each by the exact hash/URL; only report if a public analysis actually exists, don't assume one does.
- **Shodan / Censys** matter most for IPs that might be attacker-controlled infrastructure (exposed panels, open C2-typical ports, banner grabs) rather than for user-workstation IPs.
- **BuiltWith** is most useful for phishing/typosquat domains (tech stack fingerprint can match a known phishing kit or hosting pattern) — less useful for a bare IP.
- **crt.sh** (certificate transparency) is a strong pivot for finding sibling domains registered under the same cert/organization — flag this explicitly when it surfaces related domains.
- **abuse.ch** feeds (URLhaus, MalwareBazaar, ThreatFox) are good free, no-key, machine-readable sources — prefer these when available since they're low-friction.

## Report Structure — Full Report

```markdown
# OSINT Enrichment: <indicator or short batch title>

**Indicators queried:** <count> | **Sources queried:** <count>

## Summary
1-3 sentences: overall read across all indicators — what's confirmed bad, what's clean, what's still uncertain.

## Indicator Findings

### <Indicator value> (<Type>)
**Verdict:** <Malicious | Suspicious | Clean | Insufficient Data>

| Source | Category | Finding | Last Updated | Link |
|---|---|---|---|---|
| VirusTotal | Reputation | ... | ... | [link](url) |
| AbuseIPDB | Reputation | ... | ... | [link](url) |
| Shodan | Infrastructure | ... | ... | [link](url) |

**Cross-reference:** <Corroborated across N sources | Single-source flag | Clean across N sources queried | Conflicting — detail>
**Pivot-worthy:** <Yes — reason | No>

(repeat per indicator)

## Consolidated IoC Table
Drop-in format for `analyst-assistant` / `phishing-triage` / `ioc-pivot-report`:

| Type | Value | Reputation / Context | Source |
|---|---|---|---|
| IP | ... | ... | [link](url) |

## Coverage Gaps
List any source that couldn't be queried (no API key in this environment, source unreachable, no public report found) and what querying it would add.

## Recommended Follow-Up
- Pivot candidates for `ioc-pivot-report`: ...
- Indicators still needing manual authenticated lookup (e.g. full VirusTotal API, Shodan with key): ...
```

## Report Structure — Compact Block

When invoked inline by another skill for a single indicator, return only this (no headers, meant to be pasted directly):

```
<Verdict emoji-free tag: MALICIOUS | SUSPICIOUS | CLEAN | INSUFFICIENT DATA> — <one-line synthesis, e.g. "Flagged by VirusTotal (14/70) and AbuseIPDB (42 reports, last seen 3d ago); Shodan shows exposed Cobalt Strike–typical port 50050."> | Sources: [VirusTotal](url), [AbuseIPDB](url), [Shodan](url)
```

## Example

**Input:** `analyst-assistant` hands off an external IP (185.220.101.x) and a SHA256 hash from a SentinelOne detection for deeper enrichment.

**Output:** For the IP — queries AbuseIPDB (multiple abuse reports, tagged as Tor exit node), VirusTotal (8/94 vendors flag it, tied to a generic "malicious activity" tag), Shodan (open ports consistent with a relay, no C2 panel banners), and Talos (neutral). Cross-reference: corroborated Tor exit node, no strong evidence of dedicated C2 use beyond that. Verdict: Suspicious. For the hash — VirusTotal shows 61/72 detections with vendor consensus naming a known infostealer family, Hybrid Analysis has a public sandbox report showing credential-harvesting behavior and C2 beacon to a different, newly-seen IP. Verdict: Malicious, and flags that second IP as pivot-worthy for `ioc-pivot-report`. Returns both the full report and a consolidated IoC table ready to paste into the original `analyst-assistant` report, plus a note that the newly surfaced C2 IP should go through its own enrichment pass.
