# Todo

This document tracks all pending tasks and improvements for Upence. Tasks are organized by category and complexity.

---

## 📝 UI Improvements (Simple)

### Account Management
- [x] **#1** - Disable add account button in bottom sheet for "add bank account" page in setup until a value is entered in the "Account Name" field
- [x] **#2** - Make the account list use the actual icon selected rather than the default icon in "add bank account" page (setup) and "manage account" page (settings)
- [x] **#3a** - Add a "Cancel" button to the bottom sheet in the "Add bank account" page
- [x] **#3b** - Change icon selection buttons in "add bank account" page:
  - Selected icon should have transparent background (no background color)
  - Change selected icon color to app primary color
- [x] **#8** - In manage bank accounts page (from settings), remove divider in account card

### Category Management
- [x] **#4** - In categories page of setup, remove "Use Default Categories" button. Instead, pre-populate 7 default categories in the app
- [x] **#5** - Disable add button in "Add Category" bottom sheet until a name is entered

### Tags & SMS Pages
- [x] **#10** - In Tags page (from settings), change color picker to proper color picker used everywhere else
- [x] **#11** - In SMS patterns page, show in each card: sender, whole SMS body, and extracted information
- [x] **#12** - Add disable button to each pattern in SMS patterns page
- [x] **#13** - Add + button to topbar in ignored senders page

### SMS Processing Page
- [ ] **#19** - Move Advanced section into SMS body card with conditional expansion (open if not auto-parsed, closed if auto-parsed)
- [ ] **#20** - Add "Modify Pattern" button that appears immediately when user modifies auto-parsed data
- [ ] **#21** - Move pattern save options checkbox (Save this pattern, Save bank account, Save category) inside Advanced section
- [ ] **#22** - Add Display Name textfield (patternName) in Advanced section
- [ ] **#23** - Add Sender Name textfield (senderName) in Advanced section
- [ ] **#24** - Add Match with Sender (regex) textfield (senderIdentifier) in Advanced section
- [ ] **#25** - Add Priority textfield (priority field) in Advanced section
- [ ] **#26** - Add Reference Pattern textfield (referencePattern) in Advanced section (optional)
- [ ] **#27** - Track whether SMS was auto-parsed (_wasAutoParsed state)
- [ ] **#28** - Track user modifications after auto-parse (_userHasModified state)
- [ ] **#29** - Store matched pattern ID (_matchedPatternId state)
- [ ] **#30** - Implement change detection for all user inputs (textfields, dropdowns, word selection, toggles)
- [ ] **#31** - Populate advanced section fields with pattern values when auto-parsed
- [ ] **#32** - Implement _modifyExistingPattern() method to update existing patterns

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

## 💾 Database Updates

### SMS Parsing Pattern Schema
- [ ] **#33** - Add priority field to SMSParsingPattern table (default value: 0)
- [ ] **#34** - Update database schema from version 2 to 3 with migration for priority field
- [ ] **#35** - Add priority field to SMSParsingPattern model
- [ ] **#36** - Add priority field to pattern repository (insertPattern, updatePattern, _toModel)
- [ ] **#37** - Run `dart run build_runner build --delete-conflicting-outputs` after database changes

---

## ❓ Questions / Decisions Needed

- **[Rules System]** Should items #14 (rule-based sender ignoring) and #15 (regex-based sender matching) use the same unified rules configuration system, or should they be separate implementations?
  - If unified: single UI and storage for both types of rules
  - If separate: different UIs and database tables for each

---

## 📊 Progress Tracking

**Total Tasks:** 37
- UI Improvements (Simple): 17
- Bug Fixes: 3
- Features (Medium): 13
- Features (High): 3
- Questions: 1

**Completed:** 9
**In Progress:** 0
**Pending:** 28

