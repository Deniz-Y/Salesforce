/*************************************************************************************
 * @Name         : PrimaryContactTest.cls
 * @Description  : Test class for PrimaryContact class
 * @Created By   : Deniz
 * @Created Date : 27.08.2021
 *************************************************************************************/
@isTest
public class PrimaryContactTest {
    private static Account testAccount;
    private static List<Contact> testContacts = new List<Contact>();

    private static void initData(String actionToDo) {
        switch on actionToDo {
            when 'getContactsTestSuccess', 'searchContactsTestSuccess', 'setPrimaryTestSuccess' {
                testAccount = new Account(Name='MyTestAccount');
                insert testAccount;

                testContacts = new List<Contact>();
                testContacts.add(new Contact(LastName='test', AccountId=testAccount.Id));
                testContacts.add(new Contact(LastName='supertest1',AccountId=testAccount.Id));
                testContacts.add(new Contact(LastName='supertest2',AccountId=testAccount.Id));
                insert testContacts;

            }
            when 'getContactsTestFail', 'searchContactsTestFail' ,'setPrimaryTestFail' {
                testAccount = new Account(Name='MyTestAccount');
                testContacts = new List<Contact>();
            }
        }
    }

    @isTest static void getContactsTestSuccess() {
        initData('getContactsTestSuccess');
        Test.startTest();
            PageReference testPage = Page.AccountPrimaryContact; 
            Test.setCurrentPage(testPage);
            ApexPages.StandardController sc = new  ApexPages.StandardController(testAccount);
            PrimaryContact primaryContactController = new PrimaryContact(sc);
            primaryContactController.searchValue='';
            primaryContactController.getContacts();
        Test.stopTest();
        System.assertEquals(primaryContactController.contacts.size(), 3);
    }

    @isTest static void getContactsTestFail() {
        initData('getContactsTestFail');
        Test.startTest();
            PageReference testPage = Page.AccountPrimaryContact; 
            Test.setCurrentPage(testPage);
            ApexPages.StandardController sc = new  ApexPages.StandardController(testAccount);
            PrimaryContact primaryContactController = new PrimaryContact(sc);
            primaryContactController.account = null;
            primaryContactController.getContacts();
        Test.stopTest();
        System.assertEquals(primaryContactController.contacts, null);
    }

    @isTest static void searchContactsTestSuccess() {
        initData('searchContactsTestSuccess');
        Test.startTest();
            PageReference testPage = Page.AccountPrimaryContact; 
            Test.setCurrentPage(testPage);
            ApexPages.StandardController sc = new  ApexPages.StandardController(testAccount);
            PrimaryContact primaryContactController = new PrimaryContact(sc);
            primaryContactController.contacts = testContacts;
            primaryContactController.searchValue='supertest';
            primaryContactController.searchContacts();
        Test.stopTest();
        System.assertEquals(primaryContactController.contacts.size(), 2);
    }

    @isTest static void searchContactsTestFail() {
        initData('searchContactsTestFail');
        Test.startTest();
            PageReference testPage = Page.AccountPrimaryContact; 
            Test.setCurrentPage(testPage);
            ApexPages.StandardController sc = new  ApexPages.StandardController(testAccount);
            PrimaryContact primaryContactController = new PrimaryContact(sc);
            primaryContactController.account = null;
            primaryContactController.searchContacts();
        Test.stopTest();
        System.assertEquals(primaryContactController.contacts, null);
    }

    @isTest static void setPrimaryTestSuccess() {
        initData('setPrimaryTestSuccess');
        Test.startTest();
            PageReference testPage = Page.AccountPrimaryContact; 
            Test.setCurrentPage(testPage);
            ApexPages.StandardController sc = new  ApexPages.StandardController(testAccount);
            PrimaryContact primaryContactController = new PrimaryContact(sc);
            primaryContactController.contacts = testContacts;
            primaryContactController.selectedContactId = testContacts[0].Id;
            primaryContactController.setPrimary();
        Test.stopTest();
        System.assertEquals(primaryContactController.contacts.size(), 3);
        Contact primaryContact = [SELECT Id FROM Contact WHERE Is_Primary_Contact__c = true LIMIT 1];
        System.assertEquals(primaryContact.Id, testContacts[0].Id);

    }
    @isTest static void setPrimaryTestFail() {
        initData('setPrimaryTestFail');
        Test.startTest();
            PageReference testPage = Page.AccountPrimaryContact; 
            Test.setCurrentPage(testPage);
            ApexPages.StandardController sc = new  ApexPages.StandardController(testAccount);
            PrimaryContact primaryContactController = new PrimaryContact(sc);
            primaryContactController.account = null;
            primaryContactController.setPrimary();
        Test.stopTest();
        System.assertEquals(primaryContactController.contacts, null);
    }

}