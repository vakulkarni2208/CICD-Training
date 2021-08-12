/**
 * Classes being tested: CreateScheduleEntries (class), matchScheduleEntriesToOppLineItemEntries (trigger)
 *
 * Created: Fall, 2010
 *
 * By: Duncan Stewart, for OpFocus
 * 
 * @Manideep: 1/12/2019 - Logic in this code is commented as its not being used and in the process of Opportunity RecordType Cleanup.
 * @Manideep: 3/1/2021 -  SDS-2928: Removed the code/logic that refers the existing field 'customer_type__c'
 
 */
@isTest
private class UnitTests_CreateScheduleEntries {
    
    /*
     * @Manideep - Opportunity RecordType Cleanup.
    static boolean runTest_CreateScheduleEntries          = true;
    static boolean runTest_UpdateScheduleEntries          = true;
    static boolean runTest_CreateEndOfYearScheduleEntries = true;
    static boolean runTest_CreateNotebookOpportunity      = true;
    static boolean runTest_EditNotebookOpportunity        = true;
    static boolean runTest_DeleteScheduleEntries          = true;
    static boolean runTest_FiscalQuarters                 = true;
    */
    static boolean runTest_DeleteScheduleEntries          = true;

    /*
     * @Manideep - Opportunity RecordType Cleanup.
    static testMethod void Test_CreateScheduleEntries() {
        
        if(!runTest_CreateScheduleEntries == true) {
            System.assert(runTest_CreateScheduleEntries, '===== Test_CreateScheduleEntries unit test is currently inactive; enable before release');
        } else {
                
            Account a = new Account(Name = 'UnitTest', Automotive_Startup__c = 'No');
            insert a;
            
            User u = [Select Name from User where IsActive = true limit 1];
              
            Integer year = Date.Today().Year();
            Date closeDate = Date.newInstance(year, 6, 1);
            
            Utils.GetAllRecordTypeIdsByName();
            Id NotebookRTId = Utils.mapRecordTypeIDsByName.get('Opportunity / Notebook Opportunity');
 
            Opportunity o = new Opportunity(Name = 'UnitTest - opp',
              RecordTypeId = NotebookRTId,
              AccountId = a.Id,
              Sales_Lead__c = u.Name,
              CloseDate = closeDate,
              StageName = 'Initial Discussions',
              Probability_of_Winning__c = '20%',
              Design_Start_Date__c = closeDate.addDays(1),
              Design_EOL_Date__c = closeDate.addMonths(3),
              Notebook_ODM__c = 'Flextronics',
              CPU_Type__c = 'CF',
              Panel_Size__c = '10',
              GPU_TDP__c = 1000, 
              Memory_Type__c = 'DDR2',
              Package__c = '64',
              Optimus__c = 'N',
              Ventura__c = 'N',
              X3D_HDTV__c = 'N',
              X3D_Vision__c = 'N');
            
            insert o;
            
            Pricebook2 pricebk = [Select Id from Pricebook2 where Name = 'Notebook Price Book' limit 1];
            
            List<PricebookEntry> lstPBEs = new List<PricebookEntry>(
              [Select Product2Id, Pricebook2Id, Name, IsActive, Id, UnitPrice, Product2.Name
               From   PricebookEntry
               Where  IsActive = True
               and PriceBook2Id = :pricebk.Id
               Limit  2]);
               
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
            Double unitPrice = 0;
            
            //Select o.UnitPrice, o.Quantity, o.Product_Name__c, o.PricebookEntryId, o.OpportunityId, o.Description From OpportunityLineItem o
            for (PricebookEntry pbe : lstPBEs) {
                OpportunityLineItem newOLI = new OpportunityLineItem(
                  OpportunityId = o.Id,
                  PriceBookEntryId = pbe.Id,
                  Product_Name__c = pbe.Product2.Name,
                  UnitPrice = pbe.UnitPrice,
                  Monthly_Quantity__c = 25,
                  Quantity = 25 * 3);
                  
                  if (unitPrice == 0) {
                    unitPrice = pbe.UnitPrice;
                  }
                  
                lstOLIs.add(newOLI);
            }
            
            insert lstOLIs;
            
            Map<String, Double> mapRevenueByProductName = new Map<String, Double>();
            for(OpportunityLineItem oli : lstOLIs) {
                mapRevenueByProductName.put(oli.Product_Name__c, oli.UnitPrice * oli.Monthly_Quantity__c);
            }

            // Retrieve the schedule entries
            List<Schedule_Entry__c> lstSEs = ReGetScheduleEntries(o.Id);
               
            //System.assertEquals(8, lstSEs.size(), 'Wrong # of Schedule Entries created');
            
            // Evaluate the first Schedule Entry
            Schedule_Entry__c se = lstSEs[0];
            
            System.assertEquals(25, se.Quantity__c, 'Incorrect Quantity for Schedule Entry');
            System.assertEquals(25 * unitPrice, se.Revenue__c, 'Incorrect Quantity for Schedule Entry');
            
            Integer iMonth = closeDate.Month();
            Integer iYear = closeDate.Year();
            
            Date firstDate = Date.newInstance(iYear, iMonth, 15);
            Date lastDate = firstDate.addMonths(3);
            
            System.assertEquals(firstDate, se.Schedule_Date__c, 'Initial Schedule Date is incorrect');
            
            // Evaluate the last Schedule Entry; everything should match the 1st, with date adjusted accordingly
            se = lstSEs[7];
            System.assertEquals(lastDate, se.Schedule_Date__c, 'Last Schedule Date is incorrect');
            System.assertEquals(25, se.Quantity__c, 'Incorrect Quantity for Schedule Entry');
            System.assertEquals(25 * unitPrice, se.Revenue__c, 'Incorrect Quantity for Schedule Entry');    
            
            o = reGetOpportunity(o.Id);
            Double revenue = 0;
            //lstSEs = ReGetScheduleEntries(o.Id);
            for (Schedule_Entry__c newSe : lstSEs) {
                revenue += mapRevenueByProductName.get(newSe.Product_Name__c);
            }   
            
            //System.assertEquals(revenue, o.Lifetime_Revenue__c, 'Opportunity: Lifetime Revenue is incorrect');  
            
            lstOLIs.clear();
            // Add new OLIs (duplicates of the originals in this case)
            for (PricebookEntry pbe : lstPBEs) {
                OpportunityLineItem newOLI = new OpportunityLineItem(
                  OpportunityId = o.Id,
                  PriceBookEntryId = pbe.Id,
                  Product_Name__c = pbe.Product2.Name,
                  UnitPrice = pbe.UnitPrice,
                  Monthly_Quantity__c = 25,
                  Quantity = 25 * 3);
                  
                  if (unitPrice == 0) {
                    unitPrice = pbe.UnitPrice;
                  }
                  
                lstOLIs.add(newOLI);
            }
            
            insert lstOLIs;
            
            lstSEs = ReGetScheduleEntries(o.Id);
               
            System.assertEquals(16, lstSEs.size(), 'Wrong # of Schedule Entries created');
            
            o = reGetOpportunity(o.Id);
            revenue = 0;

            for (Schedule_Entry__c newSe : lstSEs) {
                revenue += mapRevenueByProductName.get(newSe.Product_Name__c);
            }   
            
            //System.assertEquals(revenue, o.Lifetime_Revenue__c, 'Opportunity: Lifetime Revenue is incorrect');  
        }
    }
        
    static testMethod void UpdateScheduleEntries() {
        
        if(!runTest_UpdateScheduleEntries == true) {
            System.assert(runTest_UpdateScheduleEntries, '===== UpdateScheduleEntries unit test is currently inactive; enable before release');
        } else {
                
            Account a = new Account(Name = 'UnitTest', Automotive_Startup__c = 'No');
            insert a;
            
            User u = [Select Name from User where IsActive = true limit 1];
              
            Integer year = Date.Today().Year();
            Date closeDate = Date.newInstance(year, 6, 1);
            
            Utils.GetAllRecordTypeIdsByName();
            Id NotebookRTId = Utils.mapRecordTypeIDsByName.get('Opportunity / Notebook Opportunity');
 
            Opportunity o = new Opportunity(Name = 'UnitTest - opp',
              RecordTypeId = NotebookRTId,
              AccountId = a.Id,
              Sales_Lead__c = u.Name,
              CloseDate = closeDate,
              StageName = 'Initial Discussions',
              Probability_of_Winning__c = '20%',
              Design_Start_Date__c = closeDate.addDays(1),
              Design_EOL_Date__c = closeDate.addMonths(3),
              Notebook_ODM__c = 'Flextronics',
              CPU_Type__c = 'CF',
              Panel_Size__c = '10',
              GPU_TDP__c = 1000, 
              Memory_Type__c = 'DDR2',
              Package__c = '64',
              Optimus__c = 'N',
              Ventura__c = 'N',
              X3D_HDTV__c = 'N',
              X3D_Vision__c = 'N');
            
            insert o;
            
            Pricebook2 pricebk = [Select Id from Pricebook2 where Name = 'Notebook Price Book' limit 1];
            
            List<PricebookEntry> lstPBEs = new List<PricebookEntry>(
              [Select Product2Id, Pricebook2Id, Name, IsActive, Id, UnitPrice, Product2.Name
               From   PricebookEntry
               Where  IsActive = True
               and PriceBook2Id = :pricebk.Id
               Limit  2]);
               
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
            Double unitPrice = 0;
            
            //Select o.UnitPrice, o.Quantity, o.Product_Name__c, o.PricebookEntryId, o.OpportunityId, o.Description From OpportunityLineItem o
            for (PricebookEntry pbe : lstPBEs) {
                OpportunityLineItem newOLI = new OpportunityLineItem(
                  OpportunityId = o.Id,
                  PriceBookEntryId = pbe.Id,
                  Product_Name__c = pbe.Product2.Name,
                  UnitPrice = pbe.UnitPrice,
                  Monthly_Quantity__c = 25,
                  Quantity = 25 * 3);
                  
                  if (unitPrice == 0) {
                    unitPrice = pbe.UnitPrice;
                  }
                  
                lstOLIs.add(newOLI);
            }
            
            insert lstOLIs;

            Map<String, Double> mapRevenueByProductName = new Map<String, Double>();
            for(OpportunityLineItem oli : lstOLIs) {
                mapRevenueByProductName.put(oli.Product_Name__c, oli.UnitPrice * oli.Quantity);
            }

            // Retrieve the schedule entries
            List<Schedule_Entry__c> lstSEs = ReGetScheduleEntries(o.Id);
               
            //System.assertEquals(8, lstSEs.size(), 'Wrong # of Schedule Entries created');
            
            // Evaluate the first Schedule Entry
            Schedule_Entry__c se = lstSEs[0];
            
            System.assertEquals(25, se.Quantity__c, 'Incorrect Quantity for Schedule Entry');
            System.assertEquals(25 * unitPrice, se.Revenue__c, 'Incorrect Quantity for Schedule Entry');
            
            Integer iMonth = closeDate.Month();
            Integer iYear = closeDate.Year();
            
            Date firstDate = Date.newInstance(iYear, iMonth, 15);
            Date lastDate = firstDate.addMonths(3);
            
            System.assertEquals(firstDate, se.Schedule_Date__c, 'Initial Schedule Date is incorrect');
            
            // Evaluate the last Schedule Entry; everything should match the 1st, with date adjusted accordingly
            se = lstSEs[7];
            System.assertEquals(lastDate, se.Schedule_Date__c, 'Last Schedule Date is incorrect');
            System.assertEquals(25, se.Quantity__c, 'Incorrect Quantity for Schedule Entry');
            System.assertEquals(25 * unitPrice, se.Revenue__c, 'Incorrect Quantity for Schedule Entry');                            
          
            o = reGetOpportunity(o.Id);
            Double revenue = 0;
            //lstSEs = ReGetScheduleEntries(o.Id);
            for (Schedule_Entry__c newSe : lstSEs) {
                revenue += mapRevenueByProductName.get(newSe.Product_Name__c);
            }   
            
           // System.assertEquals(revenue, o.Lifetime_Revenue__c, 'Opportunity: Lifetime Revenue is incorrect');  
        }
    }
        
    static testMethod void CreateEndOfYearScheduleEntries() {
        
        if(!runTest_CreateEndOfYearScheduleEntries == true) {
            System.assert(runTest_CreateEndOfYearScheduleEntries, '===== CreateEndOfYearScheduleEntries unit test is currently inactive; enable before release');
        } else {
                
            Account a = new Account(Name = 'UnitTest', Automotive_Startup__c = 'No');
            insert a;
            
            User u = [Select Name from User where IsActive = true limit 1];
              
            Integer year = Date.today().Year();
            Date closeDate = Date.newInstance(year, 11, 1);
            
            Utils.GetAllRecordTypeIdsByName();
            Id NotebookRTId = Utils.mapRecordTypeIDsByName.get('Opportunity / Notebook Opportunity');
 
            Opportunity o = new Opportunity(Name = 'UnitTest - opp',
              RecordTypeId = NotebookRTId,
              AccountId = a.Id,
              Sales_Lead__c = u.Name,
              CloseDate = closeDate,
              StageName = 'Initial Discussions',
              Probability_of_Winning__c = '20%',
              Design_Start_Date__c = closeDate.addDays(1),
              Design_EOL_Date__c = closeDate.addMonths(3),
              Notebook_ODM__c = 'Flextronics',
              CPU_Type__c = 'CF',
              Panel_Size__c = '10',
              GPU_TDP__c = 1000, 
              Memory_Type__c = 'DDR2',
              Package__c = '64',
              Optimus__c = 'N',
              Ventura__c = 'N',
              X3D_HDTV__c = 'N',
              X3D_Vision__c = 'N');
            
            insert o;
            
            Pricebook2 pricebk = [Select Id from Pricebook2 where Name = 'Notebook Price Book' limit 1];
            
            List<PricebookEntry> lstPBEs = new List<PricebookEntry>(
              [Select Product2Id, Pricebook2Id, Name, IsActive, Id, UnitPrice
               From   PricebookEntry
               Where  IsActive = True
               and PriceBook2Id = :pricebk.Id
               Limit  2]);
               
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
            Double unitPrice = 0;

            for (PricebookEntry pbe : lstPBEs) {
                OpportunityLineItem newOLI = new OpportunityLineItem(
                  OpportunityId = o.Id,
                  PriceBookEntryId = pbe.Id,
                  UnitPrice = pbe.UnitPrice,
                  Monthly_Quantity__c = 25,
                  Quantity = 25 * 3);

                  
                  if (unitPrice == 0) {
                    unitPrice = pbe.UnitPrice;
                  }
                  
                lstOLIs.add(newOLI);
            }
            
            insert lstOLIs;

            Map<String, Double> mapRevenueByProductName = new Map<String, Double>();
            for(OpportunityLineItem oli : lstOLIs) {
                mapRevenueByProductName.put(oli.Product_Name__c, oli.UnitPrice * oli.Quantity);
            }

            // Retrieve the schedule entries
            List<Schedule_Entry__c> lstSEs = ReGetScheduleEntries(o.Id);
               
            //System.assertEquals(8, lstSEs.size(), 'Wrong # of Schedule Entries created');
            
            // Evaluate the first Schedule Entry
            Schedule_Entry__c se = lstSEs[0];
            
            System.assertEquals(25, se.Quantity__c, 'Incorrect Quantity for Schedule Entry');
            System.assertEquals(25 * unitPrice, se.Revenue__c, 'Incorrect Quantity for Schedule Entry');
            
            Integer iMonth = closeDate.Month();
            Integer iYear = closeDate.Year();
            
            Date firstDate = Date.newInstance(iYear, iMonth, 15);
            Date lastDate = firstDate.addMonths(3);
            
            System.assertEquals(firstDate, se.Schedule_Date__c, 'Initial Schedule Date is incorrect');
            
            // Evaluate the last Schedule Entry; everything should match the 1st, with date adjusted accordingly
            se = lstSEs[7];
            System.assertEquals(lastDate, se.Schedule_Date__c, 'Last Schedule Date is incorrect');
            System.assertEquals(25, se.Quantity__c, 'Incorrect Quantity for Schedule Entry');
            System.assertEquals(25 * unitPrice, se.Revenue__c, 'Incorrect Quantity for Schedule Entry');
      
            o = reGetOpportunity(o.Id);
            Double revenue = 0;
            //lstSEs = ReGetScheduleEntries(o.Id);
            for (Schedule_Entry__c newSe : lstSEs) {
                revenue += mapRevenueByProductName.get(newSe.Product_Name__c);
            }   
            
           // System.assertEquals(revenue, o.Lifetime_Revenue__c, 'Opportunity: Lifetime Revenue is incorrect');  
        }
    }
    
    static testMethod void CreateNotebookOpportunity() {
        
        if(!runTest_CreateNotebookOpportunity == true) {
            System.assert(runTest_CreateNotebookOpportunity, '===== CreateNotebookOpportunity unit test is currently inactive; enable before release');
        } else {
                
            Account a = new Account(Name = 'UnitTest', Automotive_Startup__c = 'No');
            insert a;
            
            User u = [Select Name from User where IsActive = true limit 1];
              
            Integer year = Date.Today().Year();
            Date closeDate = Date.today();
            Integer day = Date.today().day();
            Integer Month = closeDate.month();
            Date startDate;
            if (day < 15) {             
                startDate = Date.newInstance(year, month, 15);
            } else {
                if (month == 12) {
                    month = 1;
                    year = year + 1;
                } else {
                    month = month + 1;
                }
                startDate = Date.newInstance(year, month+1, 15);
            }
            Date endDate = startDate.addMonths(3);
            
            Utils.GetAllRecordTypeIdsByName();
            Id NotebookRTId = Utils.mapRecordTypeIDsByName.get('Opportunity / Notebook Opportunity');
 
            Opportunity o = new Opportunity(Name = 'UnitTest - opp',
              RecordTypeId = NotebookRTId,
              AccountId = a.Id,
              Sales_Lead__c = u.Name,
              CloseDate = closeDate,
              Design_Start_Date__c = startDate,
              Design_EOL_Date__c = endDate,
              StageName = 'Initial Discussions',
              Probability_of_Winning__c = '20%',
              Notebook_ODM__c = 'Flextronics',
              CPU_Type__c = 'CF',
              Panel_Size__c = '10',
              GPU_TDP__c = 1000, 
              Memory_Type__c = 'DDR2',
              Package__c = '64',
              Optimus__c = 'N',
              Ventura__c = 'N',
              X3D_HDTV__c = 'N',
              X3D_Vision__c = 'N');
            
            insert o;
            
            o = ReGetOpportunity(o.Id);
            
            System.assertEquals(startDate, o.Design_Start_Date__c, 'incorrect Production Start Date');
            System.assertEquals(endDate, o.Design_EOL_Date__c, 'incorrect Production End Date');
            
            Pricebook2 pricebk = [Select Id from Pricebook2 where Name = 'Notebook Price Book' limit 1];
            
            List<PricebookEntry> lstPBEs = new List<PricebookEntry>(
              [Select Product2Id, Pricebook2Id, Name, IsActive, Id, UnitPrice, Product2.Name
               From   PricebookEntry
               Where  IsActive = True
               and PriceBook2Id = :pricebk.Id
               Limit  2]);
               
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
            Double unitPrice = 0;
            //Select o.UnitPrice, o.Quantity, o.Product_Name__c, o.PricebookEntryId, o.OpportunityId, o.Description From OpportunityLineItem o
            for (PricebookEntry pbe : lstPBEs) {
                OpportunityLineItem newOLI = new OpportunityLineItem(
                  OpportunityId = o.Id,
                  PriceBookEntryId = pbe.Id,
                  Product_Name__c = pbe.Product2.Name,
                  UnitPrice = pbe.UnitPrice,
                  Monthly_Quantity__c = 25,
                  Quantity = 25 * 3);

                  
                  if (unitPrice == 0) {
                    unitPrice = pbe.UnitPrice;
                  }
                  
                lstOLIs.add(newOLI);
            }
            
            insert lstOLIs;
            
            lstOLIs = ReGetOpportunityLineItems(o.Id);
            
            Map<String, Double> mapRevenueByProductName = new Map<String, Double>();
            for(OpportunityLineItem oli : lstOLIs) {
                mapRevenueByProductName.put(oli.Product_Name__c, oli.UnitPrice * oli.Quantity);
            }
            
            System.assertEquals(2, lstOLIs.size(), 'Wrong # of Opp. Line Items created');           

            List<Schedule_Entry__c> lstSEs = ReGetScheduleEntries(o.Id);
               
            o = reGetOpportunity(o.Id);
            Double revenue = 0;
            //lstSEs = ReGetScheduleEntries(o.Id);
            for (Schedule_Entry__c newSe : lstSEs) {
                revenue += mapRevenueByProductName.get(newSe.Product_Name__c);
            }   
            
            //System.assertEquals(revenue, o.Lifetime_Revenue__c, 'Opportunity: Lifetime Revenue is incorrect');  
        }
    }
    */
    
    // This method covers the code coverage for the Delete loginc in the trigger 'OpportunityLineItem.trigger'
    static testMethod void DeleteScheduleEntries() {
        
        if(!runTest_DeleteScheduleEntries == true) {
            System.assert(runTest_DeleteScheduleEntries, '===== DeleteScheduleEntries unit test is currently inactive; enable before deploying');
        } else {
                
            Account a = new Account(Name = 'DeleteScheduleEntries_UnitTest', Automotive_Startup__c = 'Yes');
            insert a;
            
            User u = [SELECT Id, Name FROM USER where IsActive = true LIMIT 1];
              
            Integer year = Date.Today().Year();
            Date closeDate = Date.newInstance(year, 6, 1);
            
            Utils.GetAllRecordTypeIdsByName();
            Id autoRTId = Utils.mapRecordTypeIDsByName.get('Opportunity / Automotive Opportunity');
            
            Opportunity o = new Opportunity(Name = 'DeleteScheduleEntries - opp',
              RecordTypeId = autoRTId,
              AccountId = a.Id,
              CloseDate = closeDate,
              StageName = 'Aware',
              Probability_of_Winning__c = '10%',
              Industry__c = 'Automotive',
              Automotive_Segment__c = 'Autonomous Driving',
              Company_Type__c = 'Tier1',
              Autonomy_Level__c = 'Level 2',
              Operating_System_AutomotiveOpportunity__c = 'AutoSAR');
            insert o;
            
            Pricebook2 pricebk = [SELECT Id FROM Pricebook2 WHERE Name = 'Automotive Price Book' AND IsActive = true limit 1];
            
            List<PricebookEntry> lstPBEs = new List<PricebookEntry>([SELECT Id, Name, IsActive, Product2Id, Pricebook2Id, UnitPrice, Product2.Name, Product2.Family
                                                                     FROM PricebookEntry
                                                                     WHERE IsActive = True
                                                                     AND PriceBook2Id =:pricebk.Id
                                                                     AND Product2.Family = 'Automotive'
                                                                     limit 2]);
               
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
            Double unitPrice = 0;
            //Select o.UnitPrice, o.Quantity, o.Product_Name__c, o.PricebookEntryId, o.OpportunityId, o.Description From OpportunityLineItem o
            for(PricebookEntry pbe : lstPBEs) {
                OpportunityLineItem newOLI = new OpportunityLineItem(
                OpportunityId = o.Id,
                PriceBookEntryId = pbe.Id,
                Product_Name__c = pbe.Product2.Name,
                UnitPrice = pbe.UnitPrice,
                //Monthly_Quantity__c = 25,
                //Quantity = 25 * 3,
                Quantity = 3);
                //if(unitPrice == 0) unitPrice = pbe.UnitPrice;                  
                lstOLIs.add(newOLI);
            }
            insert lstOLIs;
            
            Map<String, Double> mapRevenueByProductName = new Map<String, Double>();
            for(OpportunityLineItem oli : lstOLIs) {
                mapRevenueByProductName.put(oli.Product_Name__c, oli.UnitPrice * oli.Quantity);
            }
            
            // Create some Schedule Entries manually
            Date dateQ1_18 = Date.newInstance(2018,  1, 30);
            Date dateQ2_18 = Date.newInstance(2018,  4, 30);
            Date dateQ3_18 = Date.newInstance(2018,  7, 30);
            Date dateQ4_18 = Date.newInstance(2018, 10, 29);
            Schedule_Entry__c se1 = new Schedule_Entry__c(Opportunity__c=o.id, Schedule_Date__c=dateQ1_18, Opportunity_Type__c='Automotive', OLI_Id__c = lstOLIs[0].Id);
            Schedule_Entry__c se2 = new Schedule_Entry__c(Opportunity__c=o.id, Schedule_Date__c=dateQ2_18, Opportunity_Type__c='Automotive', OLI_Id__c = lstOLIs[0].Id);
            Schedule_Entry__c se3 = new Schedule_Entry__c(Opportunity__c=o.id, Schedule_Date__c=dateQ3_18, Opportunity_Type__c='Automotive', OLI_Id__c = lstOLIs[1].Id);
            Schedule_Entry__c se4 = new Schedule_Entry__c(Opportunity__c=o.id, Schedule_Date__c=dateQ4_18, Opportunity_Type__c='Automotive', OLI_Id__c = lstOLIs[1].Id);
            List<Schedule_Entry__c> lstSEs1 = new List<Schedule_Entry__c>{se1, se2, se3, se4};
            insert lstSEs1;
               
            // Retrieve the schedule entries
            List<Schedule_Entry__c> lstSEs = ReGetScheduleEntries(o.Id);
               
            //System.assertEquals(8, lstSEs.size(), 'Wrong # of Schedule Entries created');
            
            // Evaluate the first Schedule Entry
            Schedule_Entry__c se = lstSEs[0];
            
            /*
             * @Manideep - Opportunity RecordType Cleanup.
            System.assertEquals(25, se.Quantity__c, 'Incorrect Quantity for Schedule Entry');
            System.assertEquals(25 * unitPrice, se.Revenue__c, 'Incorrect Quantity for Schedule Entry');
            
            Integer iMonth = closeDate.Month();
            Integer iYear = closeDate.Year();
            
            Date firstDate = Date.newInstance(iYear, iMonth, 15);
            Date lastDate = firstDate.addMonths(3);
            
            System.assertEquals(firstDate, se.Schedule_Date__c, 'Initial Schedule Date is incorrect');
            
            // Evaluate the last Schedule Entry; everything should match the 1st, with date adjusted accordingly
            se = lstSEs[7];
            System.assertEquals(lastDate, se.Schedule_Date__c, 'Last Schedule Date is incorrect');
            System.assertEquals(25, se.Quantity__c, 'Incorrect Quantity for Schedule Entry');
            System.assertEquals(25 * unitPrice, se.Revenue__c, 'Incorrect Quantity for Schedule Entry');
            */
            
            // Delete one of the OLIs; the corresponding Schedule Entries should also be deleted
            Integer i = 0;
            Integer j = lstSEs.size();
            Id k;
            For(OpportunityLineItem oli : lstOLIs) {
                while(i < 1){
                    k = oli.Id;
                    delete oli;
                    i = 1;
                }
            }
            
            lstSEs = ReGetScheduleEntries(o.Id);
               
            System.assertEquals(j/2, lstSEs.size(), 'Schedule Entries not deleted w/ Opp line items');
            
            Integer l = [Select count() from Schedule_Entry__c Where Id = :k];
            System.assertEquals(0, l, 'There should be no Schedule Entries for the associated Opp Line Item');        
            
            /*
              * @Manideep - Opportunity RecordType Cleanup.
            o = reGetOpportunity(o.Id);
            Double revenue = 0;
            for (Schedule_Entry__c newSe : lstSEs) {
                revenue += mapRevenueByProductName.get(newSe.Product_Name__c);
            }   

            // System.assertEquals(revenue, o.Lifetime_Revenue__c, 'Opportunity: Lifetime Revenue is incorrect'); 
            */ 
        }
    }           

    /*
     * @Manideep - Opportunity RecordType Cleanup.
    // If we create Schedule Entries that have Schedule_Date__c values, are they
    // correctly translated into Fiscal Quarters?
    static testMethod void Test_FiscalQuarters() {
        System.assert(runTest_FiscalQuarters, 'This unit test has been disabled.');
        
        Account a = new Account(Name = 'UnitTest', Automotive_Startup__c = 'No');
        insert a;
        
        User u = [Select Name from User where IsActive = true limit 1];
          
        Integer year = Date.Today().Year();
        Date closeDate = Date.newInstance(year, 6, 1);
        
        Utils.GetAllRecordTypeIdsByName();
        Id NotebookRTId = Utils.mapRecordTypeIDsByName.get('Opportunity / Notebook Opportunity');
 
        Opportunity o = new Opportunity(Name = 'UnitTest - opp',
          RecordTypeId = NotebookRTId,
          AccountId = a.Id,
          Sales_Lead__c = u.Name,
          CloseDate = closeDate,
          StageName = 'Initial Discussions',
          Probability_of_Winning__c = '20%',
          Design_Start_Date__c = closeDate.addDays(1),
          Design_EOL_Date__c = closeDate.addMonths(3),
          Notebook_ODM__c = 'Flextronics',
          CPU_Type__c = 'CF',
          Panel_Size__c = '10',
          GPU_TDP__c = 1000, 
          Memory_Type__c = 'DDR2',
          Package__c = '64',
          Optimus__c = 'N',
          Ventura__c = 'N',
          X3D_HDTV__c = 'N',
          X3D_Vision__c = 'N');
        
        insert o;
        
        // Create some Schedule Entries
        Date dateQ1_12 = Date.newInstance(2012,  1, 30);
        Date dateQ2_12 = Date.newInstance(2012,  4, 30);
        Date dateQ3_12 = Date.newInstance(2012,  7, 30);
        Date dateQ4_12 = Date.newInstance(2012, 10, 29);
        Schedule_Entry__c se1 = new Schedule_Entry__c(Opportunity__c=o.id, Schedule_Date__c=dateQ1_12, Opportunity_Type__c='Notebook');
        Schedule_Entry__c se2 = new Schedule_Entry__c(Opportunity__c=o.id, Schedule_Date__c=dateQ2_12, Opportunity_Type__c='Notebook');
        Schedule_Entry__c se3 = new Schedule_Entry__c(Opportunity__c=o.id, Schedule_Date__c=dateQ3_12, Opportunity_Type__c='Notebook');
        Schedule_Entry__c se4 = new Schedule_Entry__c(Opportunity__c=o.id, Schedule_Date__c=dateQ4_12, Opportunity_Type__c='Notebook');
        List<Schedule_Entry__c> lstSEs = new List<Schedule_Entry__c>{se1, se2, se3, se4};
        insert lstSEs;
        
        lstSEs =
          [select Schedule_Date__c, Display_Quarter__c from Schedule_Entry__c where id in :lstSEs order by Schedule_Date__c];
        
        System.assertEquals('Q1-FY2013', lstSEs[0].Display_Quarter__c, 'Quarter for Schedule Date ' + lstSEs[0].Schedule_Date__c);
        System.assertEquals('Q2-FY2013', lstSEs[1].Display_Quarter__c, 'Quarter for Schedule Date ' + lstSEs[1].Schedule_Date__c);
        System.assertEquals('Q3-FY2013', lstSEs[2].Display_Quarter__c, 'Quarter for Schedule Date ' + lstSEs[2].Schedule_Date__c);
        System.assertEquals('Q4-FY2013', lstSEs[3].Display_Quarter__c, 'Quarter for Schedule Date ' + lstSEs[3].Schedule_Date__c);
    
        for (Schedule_Entry__c se : lstSEs) se.Schedule_Date__c = se.Schedule_Date__c.addDays(-1);
        update lstSEs; 
        
        lstSEs =
          [select Schedule_Date__c, Display_Quarter__c from Schedule_Entry__c where id in :lstSEs order by Schedule_Date__c];
        
        System.assertEquals('Q4-FY2012', lstSEs[0].Display_Quarter__c, 'Quarter for Schedule Date ' + lstSEs[0].Schedule_Date__c);
        System.assertEquals('Q1-FY2013', lstSEs[1].Display_Quarter__c, 'Quarter for Schedule Date ' + lstSEs[1].Schedule_Date__c);
        System.assertEquals('Q2-FY2013', lstSEs[2].Display_Quarter__c, 'Quarter for Schedule Date ' + lstSEs[2].Schedule_Date__c);
        System.assertEquals('Q3-FY2013', lstSEs[3].Display_Quarter__c, 'Quarter for Schedule Date ' + lstSEs[3].Schedule_Date__c);
    }
    */

    // Helper methods                                                    
    private static Opportunity ReGetOpportunity(Id oppId) {
        /*Opportunity o = 
          [Select Id, Name, Amount, AccountId, RecordTypeId, Design_Start_Date__c, Design_EOL_Date__c, 
             CloseDate, StageName, Lifetime_Revenue__c
           From   Opportunity
           Where  Id = :oppId limit 1];*/
           
           Opportunity o = 
          [Select Id, Name, Amount, AccountId, RecordTypeId, Design_Start_Date__c, Design_EOL_Date__c, 
             CloseDate, StageName
           From   Opportunity
           Where  Id = :oppId limit 1];           
        return o;
    }
                                                                
    private static List<OpportunityLineItem> ReGetOpportunityLineItems(Id oppId) {
        // Select o.UnitPrice, o.TotalPrice, o.Quantity, o.PricebookEntryId, o.OpportunityId From OpportunityLineItem o
        List<OpportunityLineItem> olis = 
          [Select UnitPrice, TotalPrice, Quantity, PricebookEntryId, OpportunityId, Product_Name__c
           From   OpportunityLineItem
           Where  OpportunityId = :oppId];
           
        return olis;
    }
 
    private static List<Schedule_Entry__c> ReGetScheduleEntries(Id oppId) {  
       List<Schedule_Entry__c> SEs = [SELECT Quantity__c, Revenue__c, Product_Name__c, Schedule_Date__c
                                      FROM Schedule_Entry__c
                                      WHERE Opportunity__c = :oppId
                                            ORDER BY Schedule_Date__c];
       return SEs;
    }
     
}