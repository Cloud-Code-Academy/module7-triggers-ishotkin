/*
* Opportunity trigger should do the following:
* 1. Validate that the amount is greater than 5000.
* 2. Prevent the deletion of a closed won opportunity for a banking account.
* 3. Set the primary contact on the opportunity to the contact with the title of CEO.
*/

trigger OpportunityTrigger on Opportunity (before update, before delete) {
    if (Trigger.isUpdate && Trigger.isBefore) { // Only run on Before-Save Updates
        Set<Id> accountIds = new Set<Id>(); // Make an empty set for question 7
        for (Opportunity opp : Trigger.new){
            /*
            * Question 5
            * When an opportunity is updated validate that the amount is greater than 5000.
            * Error Message: 'Opportunity amount must be greater than 5000'
            */
            if (opp.Amount <= 5000) { // If the amount is not >5000, place an error
                opp.addError('Opportunity amount must be greater than 5000');
            }

            if (String.isNotBlank(opp.AccountId)) {
                accountIds.add(opp.AccountId); // Add the Account Id to the set for question 7
            }
        }

        /*
        * Question 7
        * When an opportunity is updated set the primary contact on the opportunity to the contact on the same account with the title of 'CEO'.
        */
        List<Contact> foundContacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO']; // Get the Contacts that could be used for the primary contact

        for (Opportunity opp : Trigger.new) {
            if (String.isNotBlank(opp.AccountId)) { // Loop through the Opportunities
                for (Contact c : foundContacts) { // Loop through the Contacts
                    if (opp.AccountId == c.AccountId) { // Find a Contact for the Opportunties Account and use it
                        opp.Primary_Contact__c = c.Id;
                        break; // End the Contact loop once a matching Contact is found for the Opportunity
                    }
                }
            }
        }
    }
    
    else if (Trigger.isDelete && Trigger.isBefore) { // Only run on Before-Save Deletes
        /*
        * Question 6
        * When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
        * Error Message: 'Cannot delete closed opportunity for a banking account that is won'
        */
        Set<Id> accountIds = new Set<Id>(); // Create an empty set to hold Account Ids

        for (Opportunity opp : Trigger.old) {
            if(String.isNotBlank(opp.AccountId)) { // Save the Ids of the unique Accounts
                accountIds.add(opp.AccountId);
            }
        }

        Map<Id, Account> oppAcctMap = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]); // Get the Accounts related to each Opportunity

        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won' && String.isNotBlank(opp.AccountId) && String.isNotBlank(oppAcctMap.get(opp.AccountId).Industry) && oppAcctMap.get(opp.AccountId).Industry == 'Banking'){
                opp.addError('Cannot delete closed opportunity for a banking account that is won'); // Add an error when trying to delete Closed Won Opportunities on Banking Accounts     
            }
        }        
    }
}