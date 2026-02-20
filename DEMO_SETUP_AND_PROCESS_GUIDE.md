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

<img width="1524" height="709" alt="image" src="https://github.com/user-attachments/assets/d81fc9ca-d431-4769-9b77-8f256553cde0" />


### 3.2 Fill Connection Fields
Populate:
- `Base URL`
- `Login`
- `Password`
- `Token TTL (Minutes)` (recommended: `50`)
- `Show Message` (recommended: `true` for demo)

<img width="1524" height="709" alt="image" src="https://github.com/user-attachments/assets/26cbac7a-2b4d-47e5-9f3b-2df9b9887ef5" />


### 3.3 Import Subscriptions
1. Click `Import Subscriptions`.
2. Verify records in `User Subscriptions` list.

<img width="1543" height="656" alt="image" src="https://github.com/user-attachments/assets/e2924fe2-6d3b-41e4-bb12-aefad94b2086" />

<img width="1590" height="632" alt="image" src="https://github.com/user-attachments/assets/c6fdecec-96e8-4e67-8f19-c5767ec3e84a" />

<img width="1731" height="702" alt="image" src="https://github.com/user-attachments/assets/94002dcf-2059-4d63-9350-2853db8f43e3" />


### 3.4 Set Default Runtime Values
In `E-Invoice Setup`, set:
- `Default Config Type`
- `Default Config Id`
- `Default Business Type` (for demo: `INVOIC`)
- `Receive Top` (for demo: `50`)

<img width="1524" height="709" alt="image" src="https://github.com/user-attachments/assets/26cbac7a-2b4d-47e5-9f3b-2df9b9887ef5" />`

### 3.5 Configure Auto Processing (Inbound)
Set:
- `Auto Process Received` = `true` (optional for live demo)
- `Default Vendor No.`
- `Default Purch. G/L Account No.`

<img width="1530" height="653" alt="image" src="https://github.com/user-attachments/assets/cdce6bb3-2cf0-4dca-b401-de2e645933b9" />

---

## 4. Master Data Setup for Mapping

### 4.1 Vendor Mapping
Open Vendor Card and maintain:
- `ILN` (new extension field)
- `VAT Registration No.` (fallback identifier)

<img width="1673" height="574" alt="image" src="https://github.com/user-attachments/assets/c76f16fb-2f7c-4056-830a-fdbe3b79a6dc" />

<img width="1656" height="719" alt="image" src="https://github.com/user-attachments/assets/e2db9e75-d7fa-4d5a-ae83-3eb459c39507" />


### 4.2 Customer and Company ILN
Maintain:
- Customer `ILN`
- Company Information `ILN`

<img width="1655" height="635" alt="image" src="https://github.com/user-attachments/assets/29dbf996-e1d8-4e45-814f-00c07f7f4d70" />

<img width="1501" height="687" alt="image" src="https://github.com/user-attachments/assets/8d0aeb9c-1de0-4f64-8b1d-c2c9a0f0ed70" />


### 4.3 User Subscription Assignment
Open `User Setup` and set:
- `Subscription Config Id` (used for outbound send/check actions)

<img width="1375" height="453" alt="image" src="https://github.com/user-attachments/assets/41d9f56e-be15-4e8f-865c-5a1a837ecfa2" />


---

## 5. Outbound Demo Script (Sales Invoice to EDI)

### 5.1 Open Posted Sales Invoice
1. Open a posted sales invoice.
2. Go to `E-Invoice Processing` section.

<img width="1638" height="771" alt="image" src="https://github.com/user-attachments/assets/f67aa989-ef8d-463b-bb12-3711635d9215" />


### 5.2 Send Invoice
1. Click `Send Document`.
2. Verify fields update:
- `Invoice Send` = true
- `Invoice Send DateTime`
- `Control Number`
- `Submission Id` (if returned)

<img width="1653" height="774" alt="image" src="https://github.com/user-attachments/assets/737509d3-f533-4e3c-87da-21ae06ff9955" />

<img width="1645" height="773" alt="image" src="https://github.com/user-attachments/assets/60b1fc21-fe43-448c-a0ba-7574c6feb187" />


### 5.3 Check Sent Status
1. Click `Check Sent Status`.
2. Verify:
- `Sent Status`
- `Submission Id`

<img width="1643" height="783" alt="image" src="https://github.com/user-attachments/assets/f8467b4d-84c7-40fa-860a-d94ab67b4a85" />

<img width="1659" height="789" alt="image" src="https://github.com/user-attachments/assets/87eb1308-6ebd-4baf-ac52-6a2677d5ff02" />


### 5.4 Pull Sent Details and Statuses
From `E-Invoice Setup`, run:
- `Gets details of sent documents`
- `Get sent statuses`
- `Confirm sent details`
- `Confirm sent statuses`
  
<img width="1537" height="764" alt="image" src="https://github.com/user-attachments/assets/edfdfc5d-3899-4d8a-b72e-582696918fca" />


Review pages:
- `Sent Documents`
- `Sent Statuses`

<img width="1743" height="525" alt="image" src="https://github.com/user-attachments/assets/4cba21c2-e795-4bd5-bf50-0bd8d76d3394" />

<img width="1736" height="661" alt="image" src="https://github.com/user-attachments/assets/75bdab6e-3183-44b6-aa7d-895ca698fac1" />


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

