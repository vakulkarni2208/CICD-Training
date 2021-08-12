/**************************************************************************************************
* Name       : TestCreateCusAccController
* Purpose    : Test class for CreateCustomerAnnouncementController
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 11/10/2017      | Initial Draft
*Perficient         | 2.0        | 1/4/2017        | Added Test functionality for search criteria
*Perficient         | 2.0        | 1/28/2017       | Make Account name unique.
**************************************************************************************************/
@isTest
public class TestCreateCusAccController {

    final static String NAME = 'TestCreateCusAccController';
    @isTest
    
    Static void TestController(){
        
        List<Account> lstAccount1 = new List<Account>();
        for(Integer i =0; i< 5 ;i++){
            Account a = new Account(Name= 'a' + i + NAME);
            lstAccount1.add(a);
        }
        insert lstAccount1;
        Set<Id> selectedAccId = new Set<Id>();
        for(Account a :lstAccount1){
            selectedAccId.add(a.Id);
        }
        
        List<Account> lstAccount2 = new List<Account>();
        for(Integer i =0; i< 5 ;i++){
            Account a = new Account(Name= 'b' + i + NAME);
            lstAccount2.add(a);
        }
        insert lstAccount2;
        Set<Id> unselectedAccId = new Set<Id>();
        for(Account a :lstAccount2){
            unselectedAccId.add(a.Id);
        }
        
        Product2 product = new Product2(Name = '1U Card', Family = 'Tesla HW Family');
        insert product;
        
        /* SDS-2462 This code is commented to remove dependency on ESP_Asset object
        ESP_Asset__c asset = new ESP_Asset__c();
        asset.Name = 'Test asset';
        asset.Product__c = product.Id;
        asset.Account__c = lstAccount1.get(0).Id;
        insert asset;*/
        
        Announcement__c ann = new Announcement__c(Name = 'Test Announcement', Access_Level__c = 'Generic');
        insert ann;
        
        PageReference ref = Page.createAnnouncementLightning;
        ref.getParameters().put('Id', ann.id);
        Test.setCurrentPage(ref);
        
        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(ann);
        CreateCustomerAnnouncementController createAnn = new CreateCustomerAnnouncementController(controller);
        List<SelectOption> lstProductFamily = createAnn.lstProductFamily;
        List<SelectOption> lstProduct = createAnn.lstProduct;
        createAnn.fetchAccounts();
        createAnn.radioSelection = 'assetSearch';
        createAnn.selectedProductFamily = 'Tesla HW Family';
        lstProductFamily = createAnn.lstProductFamily;
        lstProduct = createAnn.lstProduct;
        createAnn.fetchAccounts();
        createAnn.selectedProduct = '1U Card';
        createAnn.fetchAccounts();
        createAnn.radioSelection = 'accountSearch';
        createAnn.searchText = 'Test Accounta';
        createAnn.fetchAccounts();
        createAnn.getAccount();
        createAnn.SelectAll();
        createAnn.DeSelectAll();
        for(CreateCustomerAnnouncementController.AccountWrapper wrapper : createAnn.accWrapper){
            if(wrapper.acc.Name.equals('Test Accounta')){
                wrapper.bool = true;
            }
        }
        createAnn.CreateCustomerAnnouncement();
        Test.stopTest();
        createAnn.Cancel();
        
        List<CustomerAnnouncement__c> cusAnnouncement = [SELECT Id, Name, Account__c, Announcement__c FROM CustomerAnnouncement__c];
        for(CustomerAnnouncement__c cus :cusAnnouncement){
            System.assertEquals(ann.Id, cus.Announcement__c);    
            System.assertEquals('Test Announcement', cus.Name);
        }
    }
}