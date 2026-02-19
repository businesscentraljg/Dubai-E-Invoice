# Dubai E-Invoice Demo Guide

## 1. Purpose
This document is a demo script and setup guide for the Dubai E-Invoice extension.
It covers:
- Initial setup
- Master data preparation
- Outbound invoice send flow
- Inbound receive and auto-conversion flow
- Monitoring and troubleshooting

---

## 2. Prerequisites
- Business Central environment with this extension published.
- COMARCH EDI REST credentials:
  - `Base URL`
  - `Login`
  - `Password`
- At least one valid subscription (`Config Type`, `Config Id`, `Business Type`).
- Test customer, vendor, and posted sales invoice data.

---

## 3. One-Time Setup

### 3.1 Open Setup Page
1. Search for `E-Invoice Setup`.
2. Open page `Invoice Setup` (`.src/Pages/Pag50000.InvoiceSetup.al`).

`[BC SCREENSHOT PLACEHOLDER: E-Invoice Setup Card - Empty/New]`

### 3.2 Fill Connection Fields
Populate:
- `Base URL`
- `Login`
- `Password`
- `Token TTL (Minutes)` (recommended: `50`)
- `Show Message` (recommended: `true` for demo)

`[BC SCREENSHOT PLACEHOLDER: Connection Fields Filled]`

### 3.3 Import Subscriptions
1. Click `Import Subscriptions`.
2. Verify records in `User Subscriptions` list.

`[BC SCREENSHOT PLACEHOLDER: Import Subscriptions Action]`
`[BC SCREENSHOT PLACEHOLDER: User Subscriptions List]`

### 3.4 Set Default Runtime Values
In `E-Invoice Setup`, set:
- `Default Config Type`
- `Default Config Id`
- `Default Business Type` (for demo: `INVOIC`)
- `Receive Top` (for demo: `50`)

`[BC SCREENSHOT PLACEHOLDER: Default Config and Business Type Fields]`

### 3.5 Configure Auto Processing (Inbound)
Set:
- `Auto Process Received` = `true` (optional for live demo)
- `Default Vendor No.`
- `Default Purch. G/L Account No.`

`[BC SCREENSHOT PLACEHOLDER: Auto Process and Default Posting Fields]`

---

## 4. Master Data Setup for Mapping

### 4.1 Vendor Mapping
Open Vendor Card and maintain:
- `ILN` (new extension field)
- `VAT Registration No.` (fallback identifier)

`[BC SCREENSHOT PLACEHOLDER: Vendor Card with ILN]`

### 4.2 Customer and Company ILN
Maintain:
- Customer `ILN`
- Company Information `ILN`

`[BC SCREENSHOT PLACEHOLDER: Customer Card ILN]`
`[BC SCREENSHOT PLACEHOLDER: Company Information ILN]`

### 4.3 User Subscription Assignment
Open `User Setup` and set:
- `Subscription Config Id` (used for outbound send/check actions)

`[BC SCREENSHOT PLACEHOLDER: User Setup Subscription Config Id]`

---

## 5. Outbound Demo Script (Sales Invoice to EDI)

### 5.1 Open Posted Sales Invoice
1. Open a posted sales invoice.
2. Go to `E-Invoice Processing` section.

`[BC SCREENSHOT PLACEHOLDER: Posted Sales Invoice - E-Invoice Processing Fields]`

### 5.2 Send Invoice
1. Click `Send Document`.
2. Verify fields update:
- `Invoice Send` = true
- `Invoice Send DateTime`
- `Control Number`
- `Submission Id` (if returned)

`[BC SCREENSHOT PLACEHOLDER: Send Document Action]`
`[BC SCREENSHOT PLACEHOLDER: Invoice Marked as Sent]`

### 5.3 Check Sent Status
1. Click `Check Sent Status`.
2. Verify:
- `Sent Status`
- `Submission Id`

`[BC SCREENSHOT PLACEHOLDER: Check Sent Status Result]`

### 5.4 Pull Sent Details and Statuses
From `E-Invoice Setup`, run:
- `Gets details of sent documents`
- `Get sent statuses`
- `Confirm sent details`
- `Confirm sent statuses`

Review pages:
- `Sent Documents`
- `Sent Statuses`

`[BC SCREENSHOT PLACEHOLDER: Sent Documents List]`
`[BC SCREENSHOT PLACEHOLDER: Sent Statuses List]`

---

## 6. Inbound Demo Script (Receive to BC Purchase Invoice)

### 6.1 Receive from EDI
From `E-Invoice Setup`, click:
- `Receive documents`
- `Confirm received documents`

Open `Received Documents` list and verify records.

`[BC SCREENSHOT PLACEHOLDER: Receive Documents Action]`
`[BC SCREENSHOT PLACEHOLDER: Received Documents List with Confirmed Flag]`

### 6.2 Convert Received XML to BC Documents
Option A (manual):
- Click `Process received to BC docs` from setup, or
- Use `Process pending received docs` from `Received Documents`.

Option B (automatic):
- Ensure `Auto Process Received = true`.
- Run sync cycle/job queue.

Expected result:
- Staging row marked `Converted = true`
- `BC Document No.` populated
- New Purchase Invoice created

`[BC SCREENSHOT PLACEHOLDER: Received Documents Converted Fields]`
`[BC SCREENSHOT PLACEHOLDER: Created Purchase Invoice Header]`
`[BC SCREENSHOT PLACEHOLDER: Created Purchase Invoice Lines]`

---

## 7. Job Queue Automation Demo

### 7.1 Create Job Queue Entry
1. From `E-Invoice Setup`, click `Open Job Queue Entries`.
2. Create recurring entry:
- Object Type to Run: `Codeunit`
- Object ID to Run: `50006`
- Object Name: `EDI Sync Job Runner`
- Set recurrence (example: every 10 minutes)

`[BC SCREENSHOT PLACEHOLDER: Job Queue Entry for Codeunit 50006]`

### 7.2 Run Full Sync Manually
Use `Run full sync cycle` for live demo without waiting for scheduler.

`[BC SCREENSHOT PLACEHOLDER: Run Full Sync Cycle Action]`

---

## 8. Monitoring Pages for Demo
- `E-Invoice Setup`
- `User Subscriptions`
- `Sent Documents`
- `Received Documents`
- `Sent Statuses`
- `Document Errors`
- `Job Queue Entries`

`[BC SCREENSHOT PLACEHOLDER: Monitoring Dashboard Montage]`

---

## 9. Troubleshooting Talking Points
- `401 Unauthorized`: verify `Base URL`, `Login`, `Password`.
- Empty receive/sent lists: verify `Default Config Id/Type` and `Business Type`.
- Conversion not happening:
  - Check `Auto Process Received`
  - Check `Default Purch. G/L Account No.`
  - Check vendor mapping via `ILN` or `VAT Registration No.`
- Review `Processing Error` in `Received Documents`.
- Review raw payload in `Raw JSON` fields for diagnostics.

`[BC SCREENSHOT PLACEHOLDER: Example Processing Error in Received Documents]`

---

## 10. Suggested 10-Minute Demo Flow
1. Open `E-Invoice Setup` and show configuration.
2. Import subscriptions.
3. Send one posted sales invoice.
4. Check sent status.
5. Pull sent details/statuses.
6. Receive inbound documents.
7. Convert to purchase invoice.
8. Show job queue automation entry and run full sync once.

`[BC SCREENSHOT PLACEHOLDER: Final End-to-End Success View]`

