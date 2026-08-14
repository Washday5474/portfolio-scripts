---
name: phishing-triage
description: "Triage a reported or suspicious email with a phishing-specific structure: header/sender analysis, URL and attachment IoC extraction with reputation enrichment via osint-ioc-enrichment, and a Malicious/Spam/Legitimate verdict. Use when the user pastes email headers/body, forwards a reported phishing email, or asks to triage/review/investigate a suspicious email. Optimized for high-volume phishing queues instead of the general analyst-assistant triage format."
license: MIT
metadata:
  author: manny-alvarado
  version: '1.1'
---

# Phishing Triage

## When to Use This Skill

Use this skill specifically for suspicious/reported email triage. Triggers include:

- User pastes raw email headers and/or body content
- User forwards or describes a "reported phishing" email from a mailbox (e.g. a Microsoft 365 reported-messages queue)
- "Is this phishing?", "triage this email," "review this suspicious email," "check this email for IoCs"

Use this instead of `analyst-assistant` for email-specific triage — phishing has its own verdict scale, its own evidence types (headers, sender reputation, URL/attachment analysis), and high enough volume in most SOCs to warrant a dedicated, faster structure rather than forcing every email through the general log-triage report. If the input is a log/alert unrelated to email, use `analyst-assistant` instead.

## Core Behavior

Think like an analyst working a high-volume phishing queue: fast, pattern-recognition-driven, but still evidence-based. If the current tool environment includes a dedicated email security platform (check the system prompt/project's environment inventory — e.g. Proofpoint TAP/Email Protection), treat its threat verdict, severity score, and sandboxing results as the primary evidence source and lead the assessment with it rather than starting from raw header inference. Use header/content analysis to corroborate or fill gaps when platform verdict data isn't available or is inconclusive. Prioritize the checks that catch the most cases fastest (sender/reply-to mismatch, display name spoofing, urgency/credential-harvesting language, lookalike domains, URL redirect chains) while still being thorough enough to catch well-crafted spear-phishing that won't have the obvious tells. Don't assume every reported email is malicious — a large share of user-reported email is legitimate marketing or internal mail that looks unusual; call these out plainly as Legitimate rather than defaulting to caution.

## Instructions

1. **Check for an email security platform verdict first.** If the environment includes a dedicated email security platform (e.g. Proofpoint) and the user provides or references its threat data (threat ID, severity score, category such as impostor/malware/phish/spam, sandboxing verdict), lead with that as the strongest signal. Then parse headers if provided: From/Reply-To/Return-Path mismatches, SPF/DKIM/DMARC results, originating IP and its reverse DNS/ASN, and the full hop path if multiple Received headers are present. If neither platform data nor headers are available, note that analysis is limited and work from body/sender info available.

2. **Evaluate the sender.** Display name vs. actual address mismatch, lookalike/typosquatted domain check against the real organization it's impersonating (if any), and whether the domain is newly registered or has a suspicious reputation. Hand the sending domain/IP to `osint-ioc-enrichment` for registration/reputation context rather than a single ad hoc search.

3. **Extract and enrich IoCs via `osint-ioc-enrichment`:**
   - URLs (including expanding shorteners or redirect chains where the destination is visible in the text) — run through `osint-ioc-enrichment` for reputation and any known phishing-kit/sandbox associations (it will pull urlscan.io, VirusTotal, and related sources as applicable)
   - Attachment names, types, and hashes if provided — run the hash through `osint-ioc-enrichment` for reputation and sandbox/family classification
   - Sender domain/IP — run through `osint-ioc-enrichment` for reputation and any known campaign association
   - Any embedded phone numbers or alternate contact info used in callback-phishing attempts
   - Use `osint-ioc-enrichment`'s Compact Block output to populate the IoC table directly. If it's unavailable, fall back to a plain web search and note the enrichment pass was limited.

4. **Analyze content patterns.** Identify social engineering tactics used: urgency/fear language, credential harvesting request, invoice/payment fraud pattern, brand impersonation, callback phishing, QR code (quishing) payload, or generic spam/marketing with no malicious intent.

5. **Reach a verdict:** **Malicious**, **Spam**, or **Legitimate**. Use Malicious only when evidence supports actual phishing/malicious intent (not just "looks unusual"). Spam covers unwanted but non-malicious bulk mail. Legitimate covers real business/personal email that was reported out of caution.

6. **Recommend next steps** appropriate to the verdict: purge from mailboxes org-wide, block sender domain/URL, alert affected users if they may have already interacted with it, report to the user who forwarded it, or simply close with no action for Legitimate/Spam. If `osint-ioc-enrichment` flagged any IoC as pivot-worthy (e.g. shared infrastructure with a known phishing kit), note that `ioc-pivot-report` is the natural next step to check for other affected mailboxes/campaigns.

## Output Structure

```markdown
# Phishing Triage: <short subject/sender reference>

**Verdict:** Malicious / Spam / Legitimate
**Confidence:** High / Medium / Low

## BLUF
1-2 sentences on what this email is and why it earned this verdict.

## Email Security Platform Verdict (if available)
- Platform / Threat ID: ...
- Category & Severity: ...
- Sandbox/attachment verdict: ...

## Sender & Header Analysis
- From / Reply-To / Return-Path: ...
- SPF/DKIM/DMARC: ...
- Originating IP / ASN: ...
- Domain reputation: ... (via `osint-ioc-enrichment`, with source)

## Social Engineering Tactics Identified
List of tactics observed (urgency, credential harvest, impersonation, etc.)

## Indicators of Compromise
| Type | Value | Reputation / Context | Source |
|---|---|---|---|

## Assessment
Reasoning connecting header, sender, content, and IoC evidence to the verdict.

## Recommended Next Steps
1. Prioritized actions (purge, block, notify affected users, etc.)
```

## Example

**Input:** User forwards a reported email claiming to be from IT support asking the recipient to "verify their password immediately" via a linked page, with headers showing a Reply-To address on a domain unrelated to the company.

**Output:** Flags the Reply-To mismatch and credential-harvesting language, runs the embedded URL and sending domain through `osint-ioc-enrichment` (corroborated hit — flagged in a public phishing-kit writeup plus a recent VirusTotal detection), checks the sending domain's registration date, reaches a Malicious verdict with High confidence, and recommends purging the email org-wide, blocking the sender domain and URL, checking whether any recipients already submitted credentials via the link, and running `ioc-pivot-report` if the kit is confirmed to be part of a broader campaign.
