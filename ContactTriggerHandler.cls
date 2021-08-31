/*************************************************************************************
 * @Name         : ContactTriggerHandler.cls
 * @Description  : Trigger Handler for ContactTrigger  
 * @Created By   : Deniz
 * @Created Date : 31.08.2021
 *************************************************************************************/
public with sharing class ContactTriggerHandler {
    public static void  handleBeforeUpdate(List<Contact> newContactList, Map<Id,Contact> oldContactsAndIds){
        Set<Id> relatedAccIds= new Set<Id>(); // to collect Account Ids of new contact which is now set as the primary contact.
        for(Contact newContact : newContactList ) {
            if(newContact.Is_Primary_Contact__c){
                 relatedAccIds.add(newContact.AccountId);
            }
        }
        List<Contact> relatedAllContacts = [Select ID,name,Is_Primary_Contact__c,Primary_Contact_Phone__c,AccountId from Contact where Is_Primary_Contact__c=true and AccountId IN : relatedAccIds];
        for(Contact newContact : newContactList) {
            for(Contact existingContact : relatedAllContacts) {
                if(existingContact.AccountId == newContact.AccountID
                    && newContact.ID != existingContact.ID){ //Because newContact can be already a primary contact.
                    newContact.addError('There is primary contact that already exist.');
                }
            }
        }
    }

    public static void handleBeforeInsert(List<Contact> newContactList){
        Set<Id> relatedAccIds= new Set<Id>();
        for(Contact newContact:newContactList) {
            if(newContact.AccountId !=null && newContact.Is_Primary_Contact__c){
                relatedAccIds.add(newContact.AccountId);
            }
        }
        List<Contact> relatedAllContacts = [Select ID,AccountId,name,Is_Primary_Contact__c from Contact where Is_Primary_Contact__c=true and AccountId IN : relatedAccIds];
        for(Contact existingContact : relatedAllContacts) {
            for(Contact newContact : newContactList) {
                if(existingContact.AccountId == newContact.AccountId) {
                    newContact.addError('There is primary contact that already exist.');
                }
            }
        }
    }
    public static void handleAfterUpdate(List<Contact> newContactList, Map<Id,Contact> oldContactsAndIds){
        Map<ID,String>checkedContacts=new Map<ID,String>();
        for(Contact newContact : newContactList ){
            Contact oldContact = oldContactsAndIds.get(newContact.Id);
            //if Contact is primary contact and we change its primary contact phone, then we create map to update the other related contacts.
            if(newContact.Is_Primary_Contact__c && (oldContact.Primary_Contact_Phone__c != newContact.Primary_Contact_Phone__c)){
               checkedContacts.put(newContact.AccountId, newContact.Primary_Contact_Phone__c);
            }
        }
        if(checkedContacts.size()>0){
            updatePrimaryContactPhone(checkedContacts);
        }
    }
    public static void handleAfterInsert(List<Contact> newContactList){
        Map<ID,String>checkedContacts=new Map<ID,String>();
        for(Contact newContact : newContactList ) {
            //if new contact is primary contact and we add primary contact phone, then we create map to update the other related contacts.
            if(newContact.Is_Primary_Contact__c && newContact.Primary_Contact_Phone__c !=null){
               checkedContacts.put(newContact.AccountId, newContact.Primary_Contact_Phone__c);
            }
        }
        if(checkedContacts.size()>0){
            updatePrimaryContactPhone(checkedContacts);
        }
    }
    @future
    public static void updatePrimaryContactPhone(Map<Id, String> phonePerAccountId) {
        List<Contact> updatedContacts = new List<Contact>();
        List<Contact> contacts = [Select ID, AccountId,Is_Primary_Contact__c, Primary_Contact_Phone__c from Contact Where AccountID in :phonePerAccountId.keySet()];
            for (Contact contactToBeUpdated : contacts) {
                if(!contactToBeUpdated.Is_Primary_Contact__c){ //to sepate new contact because we do not want to update it again.
                    contactToBeUpdated.Primary_Contact_Phone__c = phonePerAccountId.get(contactToBeUpdated.AccountId);
                   updatedContacts.add(contactToBeUpdated);
                }
            }
        update updatedContacts;
    }
}