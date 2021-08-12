/*
** Class:  UnitTests_TegraTablet_Controller
** Created by OpFocus on 05/03/2011
** Description: Unit tests for the TegraTablet_OppAndProducts controller
*
* @Manideep: 5/8/2019 - This code is commented as its not being used and in the process of Opportunity RecordType Cleanup.
*/    
@isTest
private class UnitTests_TegraTablet_Controller {

/*
 * @Manideep - Opportunity RecordType Cleanup
    private static Account account;
    private static Opportunity opp;
    
    private static Boolean runTest_WithNoParams = true;
    private static Boolean runTest_WithBadId = true;
    private static Boolean runTest_Cancel = true;
    private static Boolean runTest_SaveDuplicateOpportunityName = true;
    
    private static Boolean runTest_PassEditOpportunity = true;
    private static Boolean runTest_PassNewOpportunity = true;
    
    private static Boolean runTest_CreateOppWithProductsFromAccount = true;
    private static Boolean runTest_CreateOppWithStandardRecordType = true;  
    private static Boolean runTest_EditOpportunityWithProducts = true;
    private static Boolean runTest_CreateOppWithRecordTypeOnly = true;

    static testMethod void Test_WithNoParams(){
        if (!runTest_WithNoParams) {
            System.assert(runTest_WithNoParams, 'Test_WithNoparams has been disabled.  Restore before deployment');
        } else {
            
            PageReference pgRef = new PageReference('/apex/TegraTablet_OppAndProducts');
            Test.setCurrentPage(pgRef);
            
            TegraTablet_OppAndProducts_Controller ctl = new TegraTablet_OppAndProducts_Controller();
            System.assert(ApexPages.hasMessages(), 'Page invocation with no params should produce an error message');
        }
    }
    
    static testMethod void Test_WithBadId(){
        if (!runTest_WithBadId) {
            System.assert(runTest_WithBadId, 'Test_WithBadId has been disabled.  Restore before deployment');
        } else {
            
            PageReference pgRef = new PageReference('/apex/TegraTablet_OppAndProducts');
            pgRef.getParameters().put('Id', 'XXXX');
            Test.setCurrentPage(pgRef);
            
            TegraTablet_OppAndProducts_Controller ctl = new TegraTablet_OppAndProducts_Controller();
            System.assert(ApexPages.hasMessages(), 'Page invocation with an Invalid Id should produce an error message');
        }
    }
        
    static testMethod void Test_Cancel() {
        if (!runTest_Cancel) {
            system.assert(runTest_Cancel, 'Test_Cancel has been disabled.  Restore before deployment');     
        } else {
        
            // Called from the New Opportunity button on the Account
            account = new Account(Name='Test Account');
            insert account;
            
            Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
             
            opp = new Opportunity(
              AccountId=account.Id, Name='The Opp', StageName='Initial Discusssions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity'), Design_Start_Date__c = System.today().addDays(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
              
            insert opp;
            
            PageReference pgRef = new PageReference('/apex/TegraTablet_OppAndProducts');
            pgRef.getParameters().put('AccountId', account.Id);
            pgRef.getParameters().put('Id', opp.Id);
            
            Test.setCurrentPage(pgRef);
    
            TegraTablet_OppAndProducts_Controller ctl = new TegraTablet_OppAndProducts_Controller();
            
            ctl.cancel();
        }
    }       
            
    static testMethod void Test_CreateOppWithProductsFromAccount() {
        if (!runTest_CreateOppWithProductsFromAccount) {
            system.assert(runTest_CreateOppWithProductsFromAccount, 'CreateOppWithProductsFromAccount has been disabled.  Restore before deployment');      
        } else {
        
            // Called from the New Opportunity button on the Account
            account = new Account(Name='Test Account');
            insert account;
            
            Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
                        
            PageReference pgRef = new PageReference('/apex/TegraTablet_OppAndProducts');
            pgRef.getParameters().put('Id', account.Id);
            pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity'));
            pgRef.getParameters().put('isEdit', 'false');
            Test.setCurrentPage(pgRef);
    
            TegraTablet_OppAndProducts_Controller ctl = new TegraTablet_OppAndProducts_Controller();
            
            System.assertEquals(account.Id, ctl.account.Id, 'Invalid Account.id in the page controller');
            System.assertEquals('Test Account', ctl.account.Name, 'Invalid Account name in the page controller');
                        
            Integer count = ctl.helpers.size();
                        
            System.assertEquals(4, count, 'Incorrect # of Product helpers created');
            
            opp = ctl.opp;
            opp.StageName = 'Initial Discussions';
            
            Date today = Date.today();
            opp.Name = 'Test Account-' + today.month() + '/' + today.day();
            String oppName = 'Test Account-' + today.month() + '/' + today.day();
                        
            System.debug('===== CreateOppWithProductsFromAccount line 112 - opp = ' + opp);
            System.debug('===== oppName = ' + oppName + ', (actual) opp.Name = ' + opp.Name);
                                            
            Id pb2Id = [Select Id from Pricebook2 where Name = 'Tegra Tablets Price Book' limit 1].Id;
            
            List<PricebookEntry> lstPBEs = new List<PricebookEntry>(
              [Select Product2Id, Pricebook2Id, Name, IsActive, Id, UnitPrice, Product2.Name
               From   PricebookEntry
               Where  Pricebook2Id = :pb2Id
               And  IsActive = True
               Limit  2]);
               
            Double unitPrice = 25;
            Double quantity = 1000;
            integer i = 0;
            
            for (PricebookEntry pbe : lstPBEs) {
                for (TegraTablet_OppAndProducts_Controller.OLIHelper olih : ctl.helpers){
                    if (i == olih.index) {
                        olih.pbe = pbe;
                        olih.oli.PricebookEntryId = pbe.id;
                        olih.oli.Opportunity = opp;
                        olih.oli.UnitPrice = unitPrice;
                        olih.oli.Monthly_Quantity__c = quantity;
                        // increment i to populate the next helper
                        i++;
                        // break out of the inner (helpers) loop and retrieve the next PricebookEntry
                        break;
                    }
                }                   
            }
            
            ctl.Save();
            
            i = [Select count() from Opportunity where AccountId = :account.Id];
            System.debug('===== There are ' + i + ' opportunities associated to account ' + account.Name);
            
            
            opp = [Select Name, RecordTypeId, CloseDate, Probability, StageName, Type, Pricebook2.Id, AccountId,
                      Design_Start_Date__c, Design_EOL_Date__c
               From   Opportunity
               Where  AccountId = :account.Id
               And    Name = :oppName
               limit 1];
               
            Utils.GetAllRecordTypeIdsByName();
            System.assertEquals(Utils.mapRecordTypeIdsByName.get('Opportunity / Tegra Tablets, SB, SP Opportunity'), opp.RecordTypeId, 'Incorrect Opportunity:RecordType assigned');
            
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>(
              [Select PricebookEntryId, Quantity, Monthly_Quantity__c, UnitPrice, TotalPrice, Product_Name__c
               From   OpportunityLineItem
               Where  OpportunityId = :opp.Id]);
               
            for (OpportunityLineItem oli : olis) {
                System.assertEquals(1000, oli.Monthly_Quantity__c, 'Opportunity line item Monthly Quantity is incorrect');
                System.assertEquals(1000*2, oli.Quantity, 'Opportunity line item Quantity is incorrect');
                System.assertEquals(25, oli.UnitPrice, 'Opportunity line item Unit Price is incorrect');
                System.assertEquals(25000*2, oli.TotalPrice, 'Opportunity line item total price is incorrect');
            }
            
            List<Schedule_Entry__c> scheduleEntries = new List<Schedule_Entry__c>(
              [Select Opportunity__c, Quantity__c, Revenue__c
               From   Schedule_Entry__c
               Where  Opportunity__c = :opp.Id]);
               
            for (Schedule_Entry__c se : scheduleEntries) {
                System.assertEquals(1000, se.Quantity__c, 'Incorrect monthly quantity for Schedule Entry');
                System.assertEquals(25000, se.Revenue__c, 'Incorrect monthly revenue for Schedule Entry');
            }                       
            ctl.changeStageName();
            ctl.getAccount(ctl.opp.id);
        }
    } 
    */      
                    
    /*static testMethod void Test_EditOpportunityWithProducts() {
        if (!runTest_EditOpportunityWithProducts) {
            system.assert(runTest_EditOpportunityWithProducts, 'EditOpportunityWithProducts has been disabled.  Restore before deployment');        
        } else {
        
            // Called from the New Opportunity button on the Account
            account = new Account(Name='Test Account');
            insert account;
            
            Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
             
            opp = new Opportunity(
              AccountId=account.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity'), 
              Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
            
            insert opp;                         
            
            Id pb2Id = [Select Id from Pricebook2 where Name = 'Tegra Tablets Price Book' limit 1].Id;
            
            List<PricebookEntry> lstPBEs = new List<PricebookEntry>(
              [Select Product2Id, Pricebook2Id, Name, IsActive, Id, UnitPrice
               From   PricebookEntry
               Where  Pricebook2Id = :pb2Id
               And  IsActive = True
               Limit  2]);
               
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
            Double unitPrice = 0;
            
            //Select o.UnitPrice, o.Quantity, o.Product_Name__c, o.PricebookEntryId, o.OpportunityId, o.Description From OpportunityLineItem o
            for (PricebookEntry pbe : lstPBEs) {
                OpportunityLineItem newOLI = new OpportunityLineItem(
                  OpportunityId = opp.Id,
                  PriceBookEntryId = pbe.Id,
                  UnitPrice = pbe.UnitPrice,
                  Monthly_Quantity__c = 25,
                  Quantity = 25 * 2);
                  
                  if (unitPrice == 0) {
                    unitPrice = pbe.UnitPrice;
                  }
                  
                lstOLIs.add(newOLI);
            }
            
            insert lstOLIs;             
                        
            PageReference pgRef = new PageReference('/apex/TegraTablet_OppAndProducts');
            pgRef.getParameters().put('id', opp.Id);
            pgRef.getParameters().put('accid', opp.AccountId);
            pgRef.getParameters().put('RecordType', opp.RecordTypeId);
            pgRef.getParameters().put('isEdit', 'true');
            Test.setCurrentPage(pgRef);
    
            TegraTablet_OppAndProducts_Controller ctl = new TegraTablet_OppAndProducts_Controller();
            
            Integer count = ctl.helpers.size();                                             
            System.assertEquals(4, count, 'Incorrect # of Product helpers created');
            
            // Modify the Opportunity Stage
            System.assertNotEquals(null, ctl.opp, 'Controller opp should not be null');
            ctl.opp.StageName = 'RFQ';
            
            for (TegraTablet_OppAndProducts_Controller.OLIHelper olih : ctl.helpers) {
                olih.oli.Monthly_Quantity__c = 50;
                olih.oli.UnitPrice = 1200;
            }
            
            ctl.Save();
            
            opp = [Select Id, StageName from Opportunity Where Id = :opp.Id];
            
            System.assertEquals('RFQ', opp.StageName, '=Opportunity stage is incorrect');
            
            // Opportunity Line Items' Quantities should both now be 50, and Total Price = $60,000
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>(
              [Select PricebookEntryId, Quantity, Monthly_Quantity__c, Monthly_Price__c, TotalPrice, Product_Name__c
               From   OpportunityLineItem
               Where  OpportunityId = :opp.Id]);
               
            for (OpportunityLineItem oli : olis) {
                System.assertEquals(50, oli.Monthly_Quantity__c, 'Opportunity line item monthly quantity is incorrect');
                System.assertEquals(50*2, oli.Quantity, 'Opportunity line item quantity is incorrect');
                System.assertEquals(50 * 1200, oli.Monthly_Price__c, 'Opportunity line item Monthly_Price__c is incorrect');
                System.assertEquals(60000*2, oli.TotalPrice, 'Opportunity line item total price is incorrect');
            }
            
            List<Schedule_Entry__c> scheduleEntries = new List<Schedule_Entry__c>(
              [Select Id, Quantity__c, Revenue__c, Opportunity__c, Product_Name__c
               From   Schedule_Entry__c
               Where  Opportunity__c = :opp.Id]);
               
            System.assertEquals(4, scheduleEntries.size(), 'Wrong # of Schedule Entries created');
            
            for (Schedule_Entry__c se : scheduleEntries) {
                System.assertEquals(50, se.Quantity__c, 'Incorrect Monthly Quantity for Schedule Entry ' + se);
                System.assertEquals(60000, se.Revenue__c, 'Incorrect Monthly Quantity for Schedule Entry ' + se);
            }
            
            
                                                            
        }
    }*/
    
    /*     
     * @Manideep - Opportunity RecordType Cleanup       
    public static testMethod void Test_PassNewOpportunity() {
        if (!runTest_PassNewOpportunity) {
            system.assert(runTest_PassNewOpportunity, 'PassNewOpportunity has been disabled.  Restore before deployment');      
        } else {
        
            // Called from the New Opportunity button on the Account
            account = new Account(Name='Test Account');
            insert account;
            
            Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
             
            opp = new Opportunity(
              AccountId=account.Id, Name='The Opp', StageName='Initial Discusssions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Developer Opportunity'), Design_Start_Date__c = System.today().addDays(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
                        
            ApexPages.StandardController controller = new ApexPages.StandardController(opp);
            SelectOppRecordType_Extension controllerExt = new SelectOppRecordType_Extension(controller);
            
            // DirectOpportunityByType is the custom page that redirects for a New Tegra Tablets, SB, SP Opportunity
            PageReference pgRef = new PageReference('/apex/DirectOpportunityByType');
            pgRef.getParameters().put('id', opp.AccountId);
            pgRef.getParameters().put('accid', opp.AccountId);
            pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity'));
            Test.setCurrentPage(pgRef);             
                                    
            String nextPage = controllerExt.redirect().getURL();
            
            //System.assertEquals('/006/e?%28your+field+id%29=%28your+field+value%29&nooverride=1&RecordType=' + pgRef.getParameters().get('RecordType'), nextPage, 'Redirect URL for a Tegra Tablets, SB, SP Opportunity edit is incorrect');                                  
            
        }
    }
                    
    public static testMethod void Test_PassEditOpportunity() {
        if (!runTest_PassEditOpportunity) {
            system.assert(runTest_PassEditOpportunity, 'PassEditOpportunity has been disabled.  Restore before deployment');        
        } else {
        
            // Called from the Edit Opportunity button on an Opportunity
            account = new Account(Name='Test Account');
            insert account;
            
            Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
             
            opp = new Opportunity(
              AccountId=account.Id, Name='The Opp', StageName='Initial Discusssions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Developer Opportunity'), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
              
            insert opp;
                        
            ApexPages.StandardController controller = new ApexPages.StandardController(opp);
            EditOpportunityRecordType_Extension controllerExt = new EditOpportunityRecordType_Extension(controller);
            
            // DirectOpportunityByType is the custom page that redirects for a New Tegra Tablets, SB, SP Opportunity
            PageReference pgRef = new PageReference('/apex/Opportunity_Edit_by_Record_Type');
            pgRef.getParameters().put('id', opp.Id);
            pgRef.getParameters().put('accid', opp.AccountId);
            pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity'));
            Test.setCurrentPage(pgRef);             
                                    
            String nextPage = controllerExt.redirect().getURL();
            
            //System.assertEquals('/006/e?%28your+field+id%29=%28your+field+value%29&nooverride=1&RecordType=' + pgRef.getParameters().get('RecordType'), nextPage, 'Redirect URL for a Tegra Tablets, SB, SP Opportunity edit is incorrect');                                  
            
        }
    }
    
    public static testMethod void Test_CreateOppWithRecordTypeOnly() {
        if (!runTest_CreateOppWithRecordTypeOnly) {
            system.assert(runTest_CreateOppWithRecordTypeOnly, 'CreateOppWithRecordTypeOnly has been disabled.  Restore before deployment');        
        } else {
        
            Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
             
            PageReference pgRef = new PageReference('/apex/TegraTablet_OppAndProducts');
            
            pgRef.getParameters().put('id', '');
            pgRef.getParameters().put('accid', '');                                
            pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity'));
            Test.setCurrentPage(pgRef);
    
            TegraTablet_OppAndProducts_Controller ctl = new TegraTablet_OppAndProducts_Controller();
             
            opp = new Opportunity();
              
            opp = ctl.opp;
            System.assertNotEquals(null, opp, 'No opportunity was created');
                                            
            System.assertEquals(myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity'), opp.RecordTypeId, 'Incorrect Record Type assigned to new Opportunity');
                                    
            Date twoMonthsFromToday = Date.today().toStartOfMonth().addMonths(2);
            System.assertEquals(twoMonthsFromToday, opp.CloseDate, 'Default Close Date should be two months from today');
            
            PageReference newRef = ctl.selectHelper();
            System.assertEquals(null, newRef, 'selectHelper should return a null reference');
            
            Id pb2Id = [Select Id from Pricebook2 where Name = 'Tegra Tablets Price Book' limit 1].Id;
                        
            PricebookEntry pbe = new PricebookEntry();
            pbe = 
              [Select Product2Id, Pricebook2Id, Name, IsActive, Id, UnitPrice
               From   PricebookEntry
               Where  Pricebook2Id = :pb2Id
               And  IsActive = True
               Limit  1];
               
            pgRef.getParameters().put('selectedPBEid', pbe.Id);
            newRef = ctl.selectProduct();
            String pbeName = ctl.selectedProductName;
            System.assertEquals(pbeName, pbe.name, 'selectProduct should return the associated PricebookEntry.Product name');
        }
    }
 */
}