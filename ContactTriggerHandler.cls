/*************************************************************************************
 * @Name         : ContactTriggerHandler.cls
 * @Description  : Trigger Handler for ContactTrigger  
 * @Created By   : Deniz
 * @Created Date : 31.08.2021
 *************************************************************************************/
public with sharing class ContactTriggerHandler {
    public static void  handleBeforeUpdate(List<Contact> newContactList, Map<Id,Contact> oldContactsAndIds) {
        Set<Id> relatedAccIds = new Set<Id>(); // to collect Account Ids of new contact which is now set as the primary contact.
        for(Contact newContact : newContactList ) {
            if(newContact.Is_Primary_Contact__c) {
                 relatedAccIds.add(newContact.AccountId);
            }
        }
        try{
            List<Contact> relatedAllContacts = createRelatedAllContacts(relatedAccIds);
            for(Contact newContact : newContactList) {
                for(Contact existingContact : relatedAllContacts) {
                    if(existingContact.AccountId == newContact.AccountID
                     && newContact.ID != existingContact.ID){ //Because newContact can be already a primary contact.
                        newContact.addError(System.Label.Primary_Contact_Exists);
                    }
                }
            }
        } catch(Exception ex) {
            system.debug(ex);

        }
    }

    public static void handleBeforeInsert(List<Contact> newContactList) {
        Set<Id> relatedAccIds = new Set<Id>();
        for(Contact newContact:newContactList) {
            if(newContact.AccountId !=null && newContact.Is_Primary_Contact__c) {
                relatedAccIds.add(newContact.AccountId);
            }
        }
        List<Contact> relatedAllContacts = createRelatedAllContacts(relatedAccIds);
        for(Contact existingContact : relatedAllContacts) {
            for(Contact newContact : newContactList) {
                if(existingContact.AccountId == newContact.AccountId) {
                    newContact.addError(System.Label.Primary_Contact_Exists);
                }
            }
        }
    }
    public static List<Contact> createRelatedAllContacts(Set<Id> relatedAccIds) {
        List<Contact> relatedAllContacts = [SELECT ID,AccountId,name,Is_Primary_Contact__c
                                            FROM Contact
                                            WHERE Is_Primary_Contact__c=true and AccountId IN : relatedAccIds];
        return relatedAllContacts;
    }
    public static void handleAfterUpdate(List<Contact> newContactList, Map<Id,Contact> oldContactsAndIds) {
        Map<ID,String>primaryPhonePerAccountId = new Map<ID,String>();
        for(Contact newContact : newContactList ) {
            Contact oldContact = oldContactsAndIds.get(newContact.Id);
            //if Contact is primary contact and we change its primary contact phone, then we create map to update the other related contacts.
            if((newContact.Is_Primary_Contact__c && (oldContact.Phone!= newContact.Phone))
              || (newContact.Is_Primary_Contact__c && !oldContact.Is_Primary_Contact__c)) {
                    primaryPhonePerAccountId.put(newContact.AccountId, newContact.Phone);
            }
        }
        if(primaryPhonePerAccountId.size()>0) {
            updatePrimaryContactPhone(primaryPhonePerAccountId);
        }
    }
    public static void handleAfterInsert(List<Contact> newContactList) {
        Map<ID,String>checkedContacts = new Map<ID,String>();
        for(Contact newContact : newContactList ) {
            //if new contact is primary contact and we add phone, then we create map to update the other related contacts.
            if(newContact.Is_Primary_Contact__c && newContact.Phone !=null) {
               checkedContacts.put(newContact.AccountId, newContact.Phone);
            }
        }
        if(checkedContacts.size()>0) {
            updatePrimaryContactPhone(checkedContacts);
        }
    }
    @future
    public static void updatePrimaryContactPhone(Map<Id, String> phonePerAccountId) {
        try{
            List<Contact> updatedContacts = new List<Contact>();
            List<Contact> contacts = [SELECT ID, AccountId,Is_Primary_Contact__c, Primary_Contact_Phone__c
                                      FROM Contact
                                      WHERE AccountID in :phonePerAccountId.keySet()];
            for (Contact contactToBeUpdated : contacts) {
                if(!contactToBeUpdated.Is_Primary_Contact__c) { //to sepate new contact because we do not want to update it again.
                    contactToBeUpdated.Primary_Contact_Phone__c = phonePerAccountId.get(contactToBeUpdated.AccountId);
                    updatedContacts.add(contactToBeUpdated);
                }
            }
            update updatedContacts;
        }catch(Exception ex) {
            system.debug(ex);

        }
    }
}