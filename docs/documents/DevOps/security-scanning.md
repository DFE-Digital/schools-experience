---
title: Security scan triage
nav_order: 60
parent: DevOps
layout: page
---

# Security scan triage

This page records how findings from the OWASP ZAP scan of the service were triaged, and what was done about each one.

## Actioned

| Finding | Disposition |
| --- | --- |
| CSP: `style-src 'unsafe-inline'` (Medium, 5 instances) | Fixed. `'unsafe-inline'` is removed from `style-src`. Styles are allowed with a per-response nonce, and the layout includes an actual `<style nonce>` element so Google Maps can discover the nonce. The obsolete Flipper-only jQuery, Popper and Bootstrap sources are removed from the CSP. The GTM noscript fallback uses a CSS class instead of an inline `style` attribute. |

## Triaged, no change

| Finding | Disposition |
| --- | --- |
| Session cookie removal on the public homepage (Cookie Slack Detector, Low) | Not auth-bypass evidence. The homepage is public, so the session cookie is not expected to change the response. |
| Cross-Origin-Embedder-Policy missing (Low) | Not enforced. COEP only matters when cross-origin isolation is needed, and no such need or compatibility evidence exists. Enabling it could break third-party embeds such as Google Maps and GTM. |
| `Sec-Fetch-Dest`, `Sec-Fetch-Mode`, `Sec-Fetch-Site`, `Sec-Fetch-User` missing (Informational) | These are request headers sent by browsers, not response headers the server should set. The finding is not applicable to the server. |
| `no-store` / cache-control and CSRF tokens (Non-Storable Content, Re-examine Cache-control) | Kept. `no-store` protects pages that contain personal data, and CSRF tokens protect form submissions. Neither should be removed to satisfy the scanner. |
| Base64 Disclosure (Informational) | Consistent with a masked CSRF token. The evidence is 86 base64url characters, the length of a 64-byte Rails masked token, and the layout renders `csrf_meta_tags`. This is not yet verified against the live response, so it should be confirmed before it is treated as harmless. |
| Modern Web Application, Session Management Response, User Agent Fuzzer (Informational) | Informational detections, not vulnerabilities. |

## Scanner follow-up (separate investigation)

The scan reports 3 endpoints, all GET, with 83% 4xx responses, 1% 5xx responses and 2% network failures. These counts do not on their own show an authentication failure. The workflow in `.github/workflows/build.yml` already sends HTTP Basic credentials, so the 4xx rate needs its own investigation: check the scanner's credentials and paths against the deployed environment.

The rule `10038` (Content Security Policy header not set) is already suppressed globally in `.zap/rules.tsv`. That suppression is not changed here and should be reviewed separately. Do not add more suppressions as part of this work.
