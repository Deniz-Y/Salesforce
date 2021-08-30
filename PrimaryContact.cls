/*************************************************************************************
 * @Name         : PrimaryContact.cls
 * @Description  : Apex class for AccountPrimaryContact page
 * @Created By   : Deniz
 * @Created Date : 27.08.2021
 *************************************************************************************/
public with sharing class PrimaryContact {
    public Id selectedContactId {get; set;}
    public String searchValue {get;set;}
    public List<Contact> contacts;
    @TestVisible
    private Account account;//private final
    public PrimaryContact(ApexPages.StandardController stdController) {
        this.account = (Account) stdController.getRecord();
    }
    /*
    * this is for retriving of contacts.
    */
    public List<Contact> getContacts() {
    try {
        if(String.isBlank(searchValue) || this.contacts == null) {
            this.contacts = [SELECT Id, Name, Title, Phone, Is_Primary_Contact__c 
                                    FROM Contact 
                                    WHERE AccountId =: this.account.Id 
                                    LIMIT 1000 ];
        }else{
            String finalSearchValue = '%' + String.escapeSingleQuotes(searchValue) + '%';
            this.contacts = [select Id, Name,Title,Phone,Is_Primary_Contact__c  
                               FROM Contact 
                               WHERE Account.Id = :this.account.Id
                               AND Name like :finalSearchValue LIMIT 1000];
        }
    }catch (Exception ex){
        system.debug(ex);
        ApexPages.addMessage(new  ApexPages.Message( ApexPages.severity.FATAL,'ERROR!') );
    }
    return this.contacts;
    }
    /*
    * this is button action.by using this method,we call getContacts() method to create and show new contacts.
    */
    public void searchContacts(){
        getContacts();
        }
    /*
    * this is link action.in this method,I select all related contacts and edit Is_Primary_Contact__c field and then I update them.Then,
    * I again call getContacts() method to show new contacts.
    */
    public void setPrimary() {
        try {
        List<Contact> contactsToUpdate = [SELECT Id, Name, Title, Phone, Is_Primary_Contact__c 
                FROM Contact 
                WHERE AccountId =: this.account.Id ];
        for (Contact contactToUpdate : contactsToUpdate) {
                if(contactToUpdate.Is_Primary_Contact__c) {
                    contactToUpdate.Is_Primary_Contact__c = false;
                }
                if(contactToUpdate.ID == this.selectedContactId) {
                    contactToUpdate.Is_Primary_Contact__c=true;
                }
        }
        update contactsToUpdate;
        getContacts();
        }catch (Exception ex){
        system.debug(ex);
        ApexPages.addMessage(new  ApexPages.Message( ApexPages.severity.FATAL,'ERROR!') );
        }
    }  
}
