# Dubai E-Invoice Client Demo - PPT Outline

## Slide 1 - Title
**Title:** Dubai E-Invoice Integration for Business Central  
**Subtitle:** End-to-End EDI REST Automation and Document Processing

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Solution Title Screen or BC Home + Extension Name]`

**Speaker Notes**
- Introduce scope: outbound invoice submission, inbound document reception, status tracking, and automation.

---

## Slide 2 - Business Problem
**Title:** Why This Integration Matters

**Content**
- Manual invoice exchange causes delays and errors.
- Status visibility is fragmented.
- No centralized monitoring for sent/received documents.

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Existing manual process reference or high-level issue visual]`

**Speaker Notes**
- Position this as process reliability + traceability, not just API connectivity.

---

## Slide 3 - Solution Overview
**Title:** What We Built

**Content**
- COMARCH EDI REST integration inside Business Central.
- Full API coverage: auth, send, receive, status, confirm, errors, subscriptions.
- Staging + processing architecture for controlled automation.

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: E-Invoice Setup with key actions visible]`

**Speaker Notes**
- Mention extension is designed for operational use and demos.

---

## Slide 4 - Architecture
**Title:** Integration Architecture

**Content**
- Setup + token management
- API orchestration layer
- Staging tables:
  - Received Documents
  - Sent Documents
  - Sent Statuses
  - Document Errors
- Auto-conversion to BC Purchase Invoice
- Job Queue scheduler

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Architecture diagram image placeholder]`

**Speaker Notes**
- Explain separation of transport, staging, and document creation.

---

## Slide 5 - Setup Configuration
**Title:** Initial Configuration in BC

**Content**
- Configure base URL and credentials
- Set default config/business type
- Configure processing defaults

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Invoice Setup - Connection fields]`
- `[BC SCREENSHOT PLACEHOLDER: Invoice Setup - Default Config fields]`

**Speaker Notes**
- Highlight `Show Message` for demo visibility.

---

## Slide 6 - Subscription Sync
**Title:** Subscription Discovery

**Content**
- Import partner subscriptions directly from EDI API
- Validate available Config IDs before transactions

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Import Subscriptions action]`
- `[BC SCREENSHOT PLACEHOLDER: User Subscriptions list]`

**Speaker Notes**
- Emphasize this avoids hardcoding configuration in source.

---

## Slide 7 - Outbound Process
**Title:** Outbound Invoice Flow

**Content**
1. Posted Sales Invoice
2. Send Document
3. Control Number + Submission ID stored
4. Check Sent Status

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Posted Sales Invoice - E-Invoice action buttons]`
- `[BC SCREENSHOT PLACEHOLDER: Posted Sales Invoice - Sent fields populated]`

**Speaker Notes**
- Call out idempotent tracking via control number.

---

## Slide 8 - Sent Monitoring
**Title:** Sent Document Monitoring

**Content**
- Pull sent details from API
- Pull sent statuses from API
- Confirm back to API after receipt

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Sent Documents page]`
- `[BC SCREENSHOT PLACEHOLDER: Sent Statuses page]`

**Speaker Notes**
- Stress auditability and lifecycle visibility.

---

## Slide 9 - Inbound Process
**Title:** Inbound Receive and Confirm

**Content**
1. Receive documents
2. Store raw payload + metadata in staging
3. Confirm receipt to API

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Receive documents action]`
- `[BC SCREENSHOT PLACEHOLDER: Received Documents list with Confirmed = true]`

**Speaker Notes**
- Clarify this stage is non-destructive and traceable.

---

## Slide 10 - Auto Conversion to BC Documents
**Title:** Received XML to Purchase Invoice

**Content**
- Vendor resolution:
  - Seller ILN -> Vendor ILN
  - Seller Tax ID -> Vendor VAT No.
  - Setup fallback vendor
- Line creation with default G/L account fallback
- Conversion status and errors tracked in staging

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Received Documents - Converted fields]`
- `[BC SCREENSHOT PLACEHOLDER: Created Purchase Invoice]`
- `[BC SCREENSHOT PLACEHOLDER: Purchase Invoice Lines]`

**Speaker Notes**
- Mention controlled mapping design and fallback behavior.

---

## Slide 11 - Automation
**Title:** Job Queue Automation

**Content**
- Recurring sync via Codeunit `50006` (`EDI Sync Job Runner`)
- Executes full pull/confirm cycle
- Optional auto-processing of received docs

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Job Queue Entry - Object ID 50006]`
- `[BC SCREENSHOT PLACEHOLDER: Run full sync cycle action]`

**Speaker Notes**
- Explain difference between manual run and scheduled run.

---

## Slide 12 - Exception Handling
**Title:** Error Handling and Diagnostics

**Content**
- API errors surfaced with response text
- Document Error staging page for remote processing errors
- Per-document conversion error tracking

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Document Errors page]`
- `[BC SCREENSHOT PLACEHOLDER: Received document with Processing Error]`

**Speaker Notes**
- Show where support team should look first.

---

## Slide 13 - Security and Control
**Title:** Security and Operational Control

**Content**
- JWT token lifecycle with configurable TTL
- No external middleware required
- Controlled processing and confirmations

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Invoice Setup - Token and processing controls]`

**Speaker Notes**
- Position as a BC-native operational model.

---

## Slide 14 - Demo Summary
**Title:** End-to-End Outcome

**Content**
- Automated outbound + inbound integration
- Full status and error visibility
- Ready for production hardening and partner-specific mappings

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Final end-to-end dashboard montage]`

**Speaker Notes**
- Recap measurable value: speed, reliability, traceability.

---

## Slide 15 - Next Steps
**Title:** Next Phase Options

**Content**
- Add partner-specific mapping profiles
- Add approval checkpoints before posting
- Add KPIs/reporting for EDI throughput and failures

**Screenshot Mapping**
- `[BC SCREENSHOT PLACEHOLDER: Roadmap slide visual placeholder]`

**Speaker Notes**
- Offer phased rollout: pilot -> controlled go-live -> scale.

