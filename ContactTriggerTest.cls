/*************************************************************************************
 * @Name         : ContactTriggerTest.cls
 * @Description  : Test class for ContactTriggerHandler class
 * @Created By   : Deniz
 * @Created Date : 31.08.2021
 *************************************************************************************/
@isTest
public with sharing class ContactTriggerTest {
    private static Account testAccount;
    private static void initData(String actionToDo) {
        switch on actionToDo {
            when 'insertSucces','updateSucces' {
            testAccount = new Account(Name='MyTestAccount');
            insert testAccount;
            Contact testContact = new Contact(LastName ='test',Primary_Contact_Phone__c ='111', AccountId=testAccount.Id,Is_Primary_Contact__c = false);
            insert testContact;
            }
            when 'insertFail','updateFail' {
             testAccount = new Account(Name ='MyTestAccount');
            insert testAccount;
            Contact testContact = new Contact(LastName ='test',Primary_Contact_Phone__c ='111', AccountId=testAccount.Id,Is_Primary_Contact__c=true);
            insert testContact;
            }
        }
    }
    @isTest static void insertSucces() {
        initData('insertSucces');
        Test.startTest();
        Database.SaveResult result = Database.insert(new Contact(LastName='test1',Primary_Contact_Phone__c='112', AccountId=testAccount.Id,Is_Primary_Contact__c=true), false);
        Test.stopTest();
        System.assert(result.isSuccess());
    }
    @isTest static void insertFail() {
        initData('insertFail');
        Test.startTest();
        Database.SaveResult result = Database.insert(new Contact(LastName='test2',Primary_Contact_Phone__c='112', AccountId=testAccount.Id,Is_Primary_Contact__c=true), false);
        Test.stopTest();
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('There is primary contact that already exist.',
                             result.getErrors()[0].getMessage());
    }
     @isTest static void updateSucces() {
        initData('updateSucces');
        Test.startTest();
        Contact notPrimaryContact = new Contact(LastName='test',Primary_Contact_Phone__c='112', AccountId=testAccount.Id,Is_Primary_Contact__c=false);
        insert notPrimaryContact;
        notPrimaryContact.Is_Primary_Contact__c=true;
        Database.SaveResult result = Database.update(notPrimaryContact);
        Test.stopTest();
        System.assert(result.isSuccess());
    }
     @isTest static void updateFail() {
        initData('updateFail');
        Test.startTest();
        Contact notPrimaryContact = new Contact(LastName='test', AccountId=testAccount.Id,Is_Primary_Contact__c=false,Primary_Contact_Phone__c = '33');
        insert notPrimaryContact;
        notPrimaryContact.Is_Primary_Contact__c=true;
        Database.SaveResult result = Database.update(notPrimaryContact);
        Test.stopTest();
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('There is primary contact that already exist.',
                            result.getErrors()[0].getMessage());
    }
}