/* Account trigger should do the following:
*  1. Set the account type to prospect.
*  2. Copy the shipping address to the billing address.
*  3. Set the account rating to hot.
* 4. Create a contact for each account inserted.
*/

trigger AccountTrigger on Account (before insert, after insert) {
    if (Trigger.isInsert) { // Only run on Insert
        if (Trigger.isBefore) { // Check that the following actions will only run on Before Insert
            for (Account a : Trigger.new) { // Loop through Accounts
                /*
                * Question 1
                * When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
                */
                if (String.isBlank(a.Type)) {
                    a.Type = 'Prospect'; // Set Account Type if it is empty
                }

                /*
                * Question 2
                * When an account is inserted copy the shipping address to the billing address.
                * BONUS: Check if the shipping fields are empty before copying.
                */
                if (String.isNotBlank(a.ShippingStreet)) { // If the Shipping Street is not blank, copy to Billing Street
                    a.BillingStreet = a.ShippingStreet;
                }
                if (String.isNotBlank(a.ShippingCity)) { // If the Shipping City is not blank, copy to Billing City
                    a.BillingCity = a.ShippingCity;
                }
                if (String.isNotBlank(a.ShippingState)) { // If the Shipping State is not blank, copy to Billing State
                    a.BillingState = a.ShippingState;
                }
                if (String.isNotBlank(a.ShippingPostalCode)) { // If the Shipping Zip is not blank, copy to Billing Zip
                    a.BillingPostalCode = a.ShippingPostalCode;
                }
                if (String.isNotBlank(a.ShippingCountry)) { // If the Shipping Country is not blank, copy to Billing Country
                    a.BillingCountry = a.ShippingCountry;
                }

                /*
                * Question 3
                * When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax ALL have a value.
                */  
                if (String.isNotBlank(a.Phone) && String.isNotBlank(a.Website) && String.isNotBlank(a.Fax)) {
                    a.Rating = 'Hot'; // If the 3 required fields are not blank, set the rating
                }
            }
        }

        if (Trigger.isAfter) { // Check that the following actions will only run on After Insert
            /*
            * Question 4
            * When an account is inserted create a contact related to the account with the following default values:
            * LastName = 'DefaultContact'
            * Email = 'default@email.com'
            */
            List<Contact> contactsToCreate = new List<Contact>(); // Make empty list to hold Contacts

            for (Account a : Trigger.new) { // Make a Contact for each Account
                Contact newContact = new Contact(LastName = 'DefaultContact', Email = 'default@email.com', AccountId = a.Id); // Create Contact with default values
                contactsToCreate.add(newContact); // Add the Contact to the list
            }
            
            insert contactsToCreate; // Insert the Contacts in the list
        }
    }
}