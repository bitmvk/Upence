1. Disable add account button in the bottomsheet for "add bank account" page in the set up until a value is entered in the "Account Name" field.
2. make the account list use the actual icon selected rather than the default icon in the "add bank account" page of set up and the "manage account" page of the main app.
3. Add a "Cancel" button to the bottom sheet in the "Add bank account" page
3. Change the icon selection buttons the following way in the "add bank account" page in set up:
    i. the selected icon shouldnt have a background. The background should remain transaprent.
    ii. Change the icon color of the selected icon to the app primary color.
4. in the "categories" page of set up, remove the button saying "use Default Categories". Insead, make the 7 categories in the default list already preexisting in the app.
5. Disable the add button in "Add categoy" bottom sheet until a name is entered
6. for some reason, I can see the icon I selected for a new category created when I created it. but when I reaopen the app after closing it and navigate to categories page from settings, few of the icons are just showing the default categories icons, even though in the database I can see that they are the correct icons. The correct icons are being rendered if I added an other category to the list. This is happening also for groceries.
7. in the manage bank account page, from settings, there is no icon rendered in the selected account card, but the card has place for the icon to be rendered.
8. in the account card in the manage bank accounts page in settings, remove the divider.
9. I havent checked how toe deletion is handling the foreign keys. See if they are being handled as expected.
10. In the Tags page navigated from settings, change the color picker to the proper color picker used every where else.
11. In SMS patterns page, show the sender, the whole body of the sms, and the extracted information from the sms in the card.
12. Add a disable button to each pattern in SMS pattern page.
13. add a + button to the topbar in the ignored senders page.
14. Add rule based ignoring of senders. Allow regex rules. Show this setting in the ignored senders page
15. add a regex based sender name matching for patterns. This should be visible in "advanced" collapsible section in  the SMS processing page. it should be pre populated with the sender name of that perticular sms. Also show some basic regex rules
16. Add a "auto process this transaction" check box under "select this category for this pattern" check box with the sane indentation in the SMS processing page. If this is selected, the sms should automatically be processed without any user intervernsion. the auto processing should send a notification saying "this transaction has been automatically classified with the following ..."
17. send notifications to the user when a sms is recieved and it has been identified as a transaction. This will be a complecated feature, especially the classification part. For now, send a notification for every sms which is recieved. The notification should have 1 action button to it saying "Not transaction". On acction trigger, mark the sms as deleted from the sms table. Keep the sms in the table but dont show the sms in the main pending sms page.
this should also mark the futurea sms with the same pattern as not transactions and directly mark them as deleted, and dont send a notification.
18. Add rules which will be used to Identify which senders send transaction sms. for india, only senders ending with -s have to be searched to see if they are actually transaction sms. allow the user to make custom rules like this. Also create few default country based rules which can pre filter the sms. These rules should be changable. The user created rules should also be stored. Prefer storing these in json format or create a table for them. allow the user to selecte 1 or more sets of rules as tehy want.