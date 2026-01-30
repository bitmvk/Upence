# Todo

This document tracks all pending tasks and improvements for Upence. Tasks are organized by category and complexity.

---

## 📝 UI Improvements (Simple)

### Account Management
- [ ] **#1** - Disable add account button in bottom sheet for "add bank account" page in setup until a value is entered in the "Account Name" field
- [ ] **#2** - Make the account list use the actual icon selected rather than the default icon in "add bank account" page (setup) and "manage account" page (settings)
- [ ] **#3a** - Add a "Cancel" button to the bottom sheet in the "Add bank account" page
- [ ] **#3b** - Change icon selection buttons in "add bank account" page:
  - Selected icon should have transparent background (no background color)
  - Change selected icon color to app primary color
- [ ] **#8** - In manage bank accounts page (from settings), remove divider in account card

### Category Management
- [ ] **#4** - In categories page of setup, remove "Use Default Categories" button. Instead, pre-populate 7 default categories in the app
- [ ] **#5** - Disable add button in "Add Category" bottom sheet until a name is entered

### Tags & SMS Pages
- [ ] **#10** - In Tags page (from settings), change color picker to proper color picker used everywhere else
- [ ] **#11** - In SMS patterns page, show in each card: sender, whole SMS body, and extracted information
- [ ] **#12** - Add disable button to each pattern in SMS patterns page
- [ ] **#13** - Add + button to topbar in ignored senders page

---

## 🐛 Bug Fixes

- [ ] **#6** - Icons not showing correctly after app restart: custom category icons revert to default icons, but correct icons show if another category is added. Happens for groceries and others
- [ ] **#7** - In manage bank accounts page (from settings), no icon rendered in selected account card (card has space for icon but it's empty)
- [ ] **#9** - Verify foreign key handling on deletion - ensure cascading deletes work as expected

---

## 🚀 Features (Medium Complexity)

### Regex & Rules
- [ ] **#14** - Add rule-based ignoring of senders with regex support. Show these rules in ignored senders page
- [ ] **#15** - Add regex-based sender name matching for patterns in SMS processing page:
  - Show in "Advanced" collapsible section
  - Pre-populate with sender name of that SMS
  - Display basic regex rules/examples

---

## 🎯 Features (High Complexity)

### Auto Processing & Notifications
- [ ] **#16** - Add "Auto process this transaction" checkbox under "Select this category for this pattern" in SMS processing page:
  - Same indentation as other checkboxes
  - If selected, SMS automatically processes without user intervention
  - Send notification: "This transaction has been automatically classified with [category]..."
- [ ] **#17** - Send notifications when SMS is received and identified as transaction:
  - For now, send notification for every SMS received
  - Add action button "Not transaction"
  - On action trigger: mark SMS as deleted in SMS table (keep data but don't show in pending SMS page)
  - Auto-mark future SMS with same pattern as not transactions (don't show or notify)
- [ ] **#18** - Add rules to identify which senders send transaction SMS:
  - Create default country-based rules (e.g., India: only senders ending with -S)
  - Allow users to create custom rules
  - Rules should be changeable
  - User can select one or more rule sets
  - Store in JSON format
  - **Implementation**: Dedicated page accessible from settings

---

## ❓ Questions / Decisions Needed

- **[Rules System]** Should items #14 (rule-based sender ignoring) and #15 (regex-based sender matching) use the same unified rules configuration system, or should they be separate implementations?
  - If unified: single UI and storage for both types of rules
  - If separate: different UIs and database tables for each

---

## 📊 Progress Tracking

**Total Tasks:** 18
- UI Improvements (Simple): 9
- Bug Fixes: 3
- Features (Medium): 2
- Features (High): 3
- Questions: 1

**Completed:** 0
**In Progress:** 0
**Pending:** 18

