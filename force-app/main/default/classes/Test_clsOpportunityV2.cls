/*
    Change List: 
    2016.12.07 - PJENA - Price Override
            - Tesla Family is not longer existing, so the existing hard coded Tesla Family is changed to "Tesla HW Family"
            - The test class need to be rewritten not to depend on the existing org data.
            
    * @Manideep: 1/12/2019 - Logic in this code is commented as its not being used and in the process of Opportunity RecordType Cleanup. 

    2021.02.10 - SDS-2928-Delete Opportunity Fields That Were Hidden
*/

@isTest
private class Test_clsOpportunityV2 {

    @isTest (SeeAllData=true)
    static void ValidateTegraEmbeddedPartner_New() {
        //
        string strAccName = 'Test_clsOpportunityV2';
        Account acct = new Account(Name=strAccName);
        acct.Automotive_Startup__c = 'No';
        insert acct;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opp TEP';
        objOpp.CloseDate = system.today().addMonths(2);
        objOpp.StageName = 'Prospecting';
        objOpp.Probability = 10;
        objOpp.GEO_Area__c = 'NALA';
        objOpp.Product_Line__c = 'GeForce';
        objOpp.Province_of_Supplier_SI__c = 'Test SI';
        objOpp.City_of_Supplier_SI__c = 'Test City SI';
        objOpp.City_of_iCafe__c = 'Test iCafe';
        objOpp.Province_of_iCafe__c = 'Test Provinance icafe';
        objOpp.AccountId = acct.Id;
        
        Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
        test.startTest();
            PageReference pgRef = new PageReference('/apex/vfOpportunityV2');
            pgRef.getParameters().put('accid', null);
            //pgRef.getParameters().put('RecordTypeChange','true');
            pgRef.getParameters().put('param', 'New');
            pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Embedded Partner Opportunity'));
            Test.setCurrentPage(pgRef);
            
            ApexPages.Standardcontroller SC = new ApexPages.Standardcontroller(objOpp);
            clsOpportunityV2 objOutputCont = new clsOpportunityV2(SC);
            objOutputCont.initOne();
            objOutputCont.changeStageName();
            objOutputCont.opp.CloseDate = objOpp.CloseDate;
            objOutputCont.opp.Name = objOpp.Name;
            objOutputCont.opp.StageName = objOpp.StageName;
            objOutputCont.opp.Probability = objOpp.Probability;
            objOutputCont.opp.GEO_Area__c  = objOpp.GEO_Area__c;
            objOutputCont.opp.Product_Line__c = objOpp.Product_Line__c ;
            objOutputCont.opp.Province_of_Supplier_SI__c = objOpp.Province_of_Supplier_SI__c;
            objOutputCont.opp.City_of_Supplier_SI__c = objOpp.City_of_Supplier_SI__c;
            objOutputCont.opp.City_of_iCafe__c = objOpp.City_of_iCafe__c;
            objOutputCont.opp.Province_of_iCafe__c= objOpp.Province_of_iCafe__c;
            objOutputCont.opp.AccountId  = objOpp.AccountId;
            
            objOutputCont.pickStartingQuarter();
            clsOpportunityV2.OLIHelper objOliHelper = new clsOpportunityV2.OLIHelper();
            objOutputCont.lstProductFamilies.add(null);
             
             objOliHelper.strRecordTypeName = objOutputCont.RECORDTYPE_NAME;
            List<PricebookEntry> lstPBE = [select id, Name, UnitPrice
                                                   from   PricebookEntry
                                                   where  IsActive = true
                                                   and    Pricebook2Id = :objOutputCont.opp.Pricebook2Id
                                                   and    Product2.Family = :'Tegra Embedded'
                                                   order by Product2.Product_Sort_Order__c DESC, Name];
            //objOutputCont.mapPBEsByFamily = new map<String, List<PricebookEntry>>();
            for(PricebookEntry eachPBE: lstPBE){
                objOliHelper.pbesForFamily.add(new selectoption(eachPBE.id,eachPBE.Name));
            }
             
            clsOpportunityV2.OLIHelper objOliHelper1 = new clsOpportunityV2.OLIHelper(objOutputCont,'Tegra Embedded',lstPBE[0].id,null);      
            objOliHelper1.family = 'Tegra Embedded';
            objOliHelper1.productName =lstPBE[0].Name;
            objOliHelper1.asp = lstPBE[0].UnitPrice;
            objOliHelper1.totalUnits = 1;
            integer gettotalUnits = objOliHelper1.totalUnits;
            objOliHelper1.totalPrice = objOliHelper1.totalUnits * lstPBE[0].UnitPrice;
            Decimal gettotalPrice = objOliHelper1.totalPrice;
    
            objOutputCont.addNextQuarter();
            objOutputCont.addPreviousQuarter();
            objOutputCont.opp.CloseDate = objOpp.CloseDate.addMonths(3);
            objOutputCont.updateStartingQuarter();
            objOutputCont.addProduct();
            objOutputCont.deleteProductIndex = '0';
            objOutputCont.deleteProduct();
            objOutputCont.getErrorVal();
            objOutputCont.save();
            objOutputCont.Cancel();
          
            //Edit Inserted Opportunity
            pgRef = new PageReference('/apex/vfOpportunityV2');
            PgRef.getParameters().put('id', objOutputCont.Opp.id);
            pgRef.getParameters().put('accid', acct.Id);
            //pgRef.getParameters().put('RecordTypeChange','true');
            pgRef.getParameters().put('param', 'Edit');
            pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Embedded Partner Opportunity'));
            Test.setCurrentPage(pgRef);
            objOutputCont = new clsOpportunityV2(SC);  
              
            //Create Opportunity with account id
            pgRef = new PageReference('/apex/vfOpportunityV2');
            pgRef.getParameters().put('accid', acct.Id);
            pgRef.getParameters().put('param', 'New');
            pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Embedded Partner Opportunity'));
            Test.setCurrentPageReference(pgRef);
            objOutputCont = new clsOpportunityV2(SC);
      test.stoptest();
   }
         
    @isTest (SeeAllData=true)
    static void ValidateTegraEmbedded_New(){
   //
        string strAccName = 'Test_clsOpportunityV2';
        Account acct = new Account(Name=strAccName);
        acct.Automotive_Startup__c = 'No';
        insert acct;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opp GeForce';
        objOpp.CloseDate = system.today().addMonths(2);
        objOpp.StageName = 'Prospecting';
        objOpp.Probability = 10;
        //objOpp.GEO_Area__c = 'NALA';
        //objOpp.Product_Line__c = 'GeForce';
        //objOpp.Province_of_Supplier_SI__c = 'Test SI';
        //objOpp.City_of_Supplier_SI__c = 'Test City SI';
        //objOpp.City_of_iCafe__c = 'Test iCafe';
        //objOpp.Province_of_iCafe__c = 'Test Provinance icafe';
        objOpp.AccountId = acct.Id;
        objOpp.Opportunity_Class__c = 'Strategic Opportunity';
        objOpp.Industry__c = 'Aerospace';
        //objOpp.Prefered_Partner__c = 'APPRO';
        //objOpp.Application_Type__c = 'ISVs';
        //objOpp.Critical_Priority_1_Software_Apps__c = 'AMBER';
        //objOpp.At_Risk_Level__c = 'Low';
        objOpp.Blocking_Issues__c = 'Test Issues';
        objOpp.Status_Next_Step__c = 'Test Next step';
        
        Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
        PageReference pgRef = new PageReference('/apex/vfOpportunityV2');
        pgRef.getParameters().put('accid', null);
        pgRef.getParameters().put('param', 'New');
        pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Embedded Opportunity'));
        Test.setCurrentPage(pgRef);     
        ApexPages.Standardcontroller SC = new ApexPages.Standardcontroller(objOpp);
        clsOpportunityV2 objOutputCont = new clsOpportunityV2(SC);
        objOutputCont.initOne();
        objOutputCont.changeStageName();
        objOutputCont.opp.CloseDate = objOpp.CloseDate;
        objOutputCont.opp.Name = objOpp.Name;
        objOutputCont.opp.StageName = objOpp.StageName;
        objOutputCont.opp.Probability = objOpp.Probability;
        //objOutputCont.opp.GEO_Area__c  = objOpp.GEO_Area__c;
        //objOutputCont.opp.Product_Line__c = objOpp.Product_Line__c ;
        //objOutputCont.opp.Province_of_Supplier_SI__c = objOpp.Province_of_Supplier_SI__c;
        //objOutputCont.opp.City_of_Supplier_SI__c = objOpp.City_of_Supplier_SI__c;
        //objOutputCont.opp.City_of_iCafe__c = objOpp.City_of_iCafe__c;
        //objOutputCont.opp.Province_of_iCafe__c= objOpp.Province_of_iCafe__c;
        objOutputCont.opp.AccountId  = objOpp.AccountId;
        //objOutputCont.opp.Opportunity_Class__c = 'Strategic Opportunity';
        objOutputCont.opp.Industry__c = 'Aerospace';
        //objOutputCont.opp.Prefered_Partner__c = 'APPRO';
        //objOutputCont.opp.Application_Type__c = 'ISVs';
        //objOutputCont.opp.Critical_Priority_1_Software_Apps__c = 'AMBER';
        objOutputCont.opp.At_Risk_Level__c = 'Low';
        objOutputCont.opp.Blocking_Issues__c = 'Test Issues';
        objOutputCont.opp.Status_Next_Step__c = 'Test Next step';
                
        List<PricebookEntry> lstPBE = [select id, Name, UnitPrice
                                       from   PricebookEntry
                                       where  IsActive = true
                                       and    Pricebook2Id = :objOutputCont.opp.Pricebook2Id
                                       and    Product2.Family = :'Tegra Embedded'
                                       order by Product2.Product_Sort_Order__c DESC, Name]; 
         
       objOutputCont.lstProductFamilies.add(null);
       clsOpportunityV2.OLIHelper objOliHelper1 = new clsOpportunityV2.OLIHelper(objOutputCont,'Tegra Embedded',lstPBE[0].id,null);  
       //objOutputCont.mapPBEsByFamily = new map<String, List<PricebookEntry>>();
       for(PricebookEntry eachPBE: lstPBE){
           objOliHelper1.pbesForFamily.add(new selectoption(eachPBE.id,eachPBE.Name));
       } 
       objOliHelper1.pbeId = lstPBE[0].id;
       ApexPages.currentPage().getParameters().get('selectedPbeId');
       //objOutputCont.addProduct();
       objOutputCont.lstPossibleQuarters.add(new selectoption(Utils.getFiscalQuarterForDate(Date.today()),Utils.swapFiscalDateSections(Utils.getFiscalQuarterForDate(Date.today()))));
       objOutputCont.startingQuarter = Utils.getFiscalQuarterForDate(Date.today());
       objOutputCont.pickStartingQuarter();
       objOliHelper1.family = 'Tegra Embedded';
       objOliHelper1.productName =lstPBE[0].Name;
       clsOpportunityV2.ScheduleEntryHelper objSEH = new clsOpportunityV2.ScheduleEntryHelper(objOutputCont,objOliHelper1,objOutputCont.startingQuarter);
       // objOliHelper1.totalUnits = 1;
       // integer gettotalUnits = objOliHelper1.totalUnits;
       // objOliHelper1.totalPrice = objOliHelper1.totalUnits * lstPBE[0].UnitPrice;
       // Decimal gettotalPrice = objOliHelper1.totalPrice;
       objOutputCont.lstOLIHelpers[0].lstSEHs[0].units = 1;
       objOutputCont.lstOLIHelpers[0].lstSEHs[0].asp = 10;
       objOutputCont.lstOLIHelpers[0].totalUnits = 1;
       objOutputCont.lstOLIHelpers[0].totalPrice = 10;
       objOutputCont.lstOLIHelpers[0].pbeId =lstPBE[0].id;
       objOutputCont.lstOLIHelpers[0].pbe = lstPBE[0];
       objOutputCont.save();
       objOutputCont.addNextQuarter();
       objOutputCont.addPreviousQuarter();
       objOutputCont.opp.CloseDate = objOpp.CloseDate.addMonths(3);
       objOutputCont.updateStartingQuarter();
       objOutputCont.addProduct();
       objOutputCont.deleteProductIndex = '0';
       objOutputCont.deleteProduct();
       //objOutputCont.selectProduct();
       //objOutputCont.closePopup();
       //objOutputCont.showPopup();
       objOutputCont.getErrorVal();
      //objOutputCont.Cancel();
      
      //Edit Inserted Opportunity
      pgRef = new PageReference('/apex/vfOpportunityV2');
      PgRef.getParameters().put('id', objOutputCont.Opp.id);
      pgRef.getParameters().put('accid', acct.Id);
      //pgRef.getParameters().put('RecordTypeChange','true');
      pgRef.getParameters().put('param', 'Edit');
      pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Embedded Opportunity'));
      Test.setCurrentPage(pgRef);
      objOutputCont = new clsOpportunityV2(SC);
        
      //Create Opportunity with account id
      pgRef = new PageReference('/apex/vfOpportunityV2');
      pgRef.getParameters().put('accid', acct.Id);
      pgRef.getParameters().put('param', 'New');
      pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Embedded Opportunity'));
      Test.setCurrentPage(pgRef);
      objOutputCont = new clsOpportunityV2(SC);
    }
        
    @isTest (SeeAllData=true)
    static void ValidateTegraEmbedded_New_NoProductSelected(){
       // 
        string strAccName = 'Test_clsOpportunityV2';
        Account acct = new Account(Name=strAccName);
        acct.Automotive_Startup__c = 'No';
        insert acct;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opp GeForce';
        objOpp.CloseDate = system.today().addMonths(2);
        objOpp.StageName = 'Prospecting';
        objOpp.Probability = 10;
        //objOpp.GEO_Area__c = 'NALA';
        //objOpp.Product_Line__c = 'GeForce';
        //objOpp.Province_of_Supplier_SI__c = 'Test SI';
        //objOpp.City_of_Supplier_SI__c = 'Test City SI';
       // objOpp.City_of_iCafe__c = 'Test iCafe';
        //objOpp.Province_of_iCafe__c = 'Test Provinance icafe';
        objOpp.AccountId = acct.Id;
        objOpp.Opportunity_Class__c = 'Strategic Opportunity';
        objOpp.Industry__c = 'Aerospace';
        //objOpp.Prefered_Partner__c = 'APPRO';
        //objOpp.Application_Type__c = 'ISVs';
        //objOpp.Critical_Priority_1_Software_Apps__c = 'AMBER';
        //objOpp.At_Risk_Level__c = 'Low';
        objOpp.Blocking_Issues__c = 'Test Issues';
        objOpp.Status_Next_Step__c = 'Test Next step';
        
        Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
        PageReference pgRef = new PageReference('/apex/vfOpportunityV2');
        pgRef.getParameters().put('accid', null);
        pgRef.getParameters().put('param', 'New');
        pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Embedded Opportunity'));
        Test.setCurrentPage(pgRef);     
        ApexPages.Standardcontroller SC = new ApexPages.Standardcontroller(objOpp);
        clsOpportunityV2 objOutputCont = new clsOpportunityV2(SC);
        objOutputCont.initOne();
        objOutputCont.changeStageName();
        objOutputCont.opp.CloseDate = objOpp.CloseDate;
        objOutputCont.opp.Name = objOpp.Name;
        objOutputCont.opp.StageName = objOpp.StageName;
        objOutputCont.opp.Probability = objOpp.Probability;
        //objOutputCont.opp.GEO_Area__c  = objOpp.GEO_Area__c;
        //objOutputCont.opp.Product_Line__c = objOpp.Product_Line__c ;
        //objOutputCont.opp.Province_of_Supplier_SI__c = objOpp.Province_of_Supplier_SI__c;
        //objOutputCont.opp.City_of_Supplier_SI__c = objOpp.City_of_Supplier_SI__c;
        //objOutputCont.opp.City_of_iCafe__c = objOpp.City_of_iCafe__c;
        //objOutputCont.opp.Province_of_iCafe__c= objOpp.Province_of_iCafe__c;
        objOutputCont.opp.AccountId  = objOpp.AccountId;
        //objOutputCont.opp.Opportunity_Class__c = 'Strategic Opportunity';
        objOutputCont.opp.Industry__c = 'Aerospace';
        //objOutputCont.opp.Prefered_Partner__c = 'APPRO';
        //objOutputCont.opp.Application_Type__c = 'ISVs';
        //objOutputCont.opp.Critical_Priority_1_Software_Apps__c = 'AMBER';
        //objOutputCont.opp.At_Risk_Level__c = 'Low';
        objOutputCont.opp.Blocking_Issues__c = 'Test Issues';
        objOutputCont.opp.Status_Next_Step__c = 'Test Next step';
        
        List<PricebookEntry> lstPBE = [select id, Name, UnitPrice
                                       from   PricebookEntry
                                       where  IsActive = true
                                       and    Pricebook2Id = :objOutputCont.opp.Pricebook2Id
                                       and    Product2.Family = :'Tegra Embedded'
                                       order by Product2.Product_Sort_Order__c DESC, Name]; 
         
       objOutputCont.lstProductFamilies.add(null);
       clsOpportunityV2.OLIHelper objOliHelper1 = new clsOpportunityV2.OLIHelper(objOutputCont,'Tegra Embedded',lstPBE[0].id,null);  
       for(PricebookEntry eachPBE: lstPBE){
           objOliHelper1.pbesForFamily.add(new selectoption(eachPBE.id,eachPBE.Name));
       } 
       objOliHelper1.pbeId = lstPBE[0].id;
       ApexPages.currentPage().getParameters().get('selectedPbeId');
       objOutputCont.lstPossibleQuarters.add(new selectoption(Utils.getFiscalQuarterForDate(Date.today()),Utils.swapFiscalDateSections(Utils.getFiscalQuarterForDate(Date.today()))));
       objOutputCont.startingQuarter = Utils.getFiscalQuarterForDate(Date.today());
       objOutputCont.pickStartingQuarter();
       objOliHelper1.family = 'Tegra Embedded';
       objOliHelper1.productName =lstPBE[0].Name;
       clsOpportunityV2.ScheduleEntryHelper objSEH = new clsOpportunityV2.ScheduleEntryHelper(objOutputCont,objOliHelper1,objOutputCont.startingQuarter);
       objOutputCont.lstOLIHelpers[0].pbeId =lstPBE[0].id;
       objOutputCont.lstOLIHelpers[0].pbe = lstPBE[0];
       objOutputCont.save();       
            
    }
    
    @isTest (SeeAllData=true)
    static void ValidateTegraEmbedded_New_changeInOppFields(){
        //
        string strAccName = 'Test_clsOpportunityV2';
        Account acct = new Account(Name=strAccName);
        acct.Automotive_Startup__c = 'No';
        insert acct;
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opp GeForce';
        objOpp.CloseDate = system.today().addMonths(2);
        objOpp.StageName = 'Prospecting';
        objOpp.Probability = 10;
        //objOpp.GEO_Area__c = 'NALA';
        //objOpp.Product_Line__c = 'GeForce';
        //objOpp.Province_of_Supplier_SI__c = 'Test SI';
        //objOpp.City_of_Supplier_SI__c = 'Test City SI';
        //objOpp.City_of_iCafe__c = 'Test iCafe';
        //objOpp.Province_of_iCafe__c = 'Test Provinance icafe';
        objOpp.AccountId = acct.Id;
        objOpp.Opportunity_Class__c = 'Strategic Opportunity';
        objOpp.Industry__c = 'Aerospace';
        //objOpp.Prefered_Partner__c = 'APPRO';
        //objOpp.Application_Type__c = 'ISVs';
        //objOpp.Critical_Priority_1_Software_Apps__c = 'AMBER';
        //objOpp.At_Risk_Level__c = 'Low';
        objOpp.Blocking_Issues__c = 'Test Issues';
        objOpp.Status_Next_Step__c = 'Test Next step';
        objOpp.Description = 'Test Description';
        objOpp.Competition__c = 'Test';
        objOpp.Reason_for_Close__c = 'Test';
        objOpp.Closed_Lost_Comments__c = 'Test Comments';
        objOpp.Amount = 100;
        //objOpp.Reason_for_Approval__c = 'Test Approved';
        
        Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
        PageReference pgRef = new PageReference('/apex/vfOpportunityV2');
        pgRef.getParameters().put('accid', null);
        pgRef.getParameters().put('param', 'New');
        pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity / Tegra Embedded Opportunity'));
        Test.setCurrentPage(pgRef);     
        ApexPages.Standardcontroller SC = new ApexPages.Standardcontroller(objOpp);
        clsOpportunityV2 objOutputCont = new clsOpportunityV2(SC);
        objOutputCont.initOne();
        objOutputCont.changeStageName();
        objOutputCont.opp.CloseDate = objOpp.CloseDate;
        objOutputCont.opp.Name = objOpp.Name;
        objOutputCont.opp.StageName = objOpp.StageName;
        objOutputCont.opp.Probability = objOpp.Probability;
        //objOutputCont.opp.GEO_Area__c  = objOpp.GEO_Area__c;
        //objOutputCont.opp.Product_Line__c = objOpp.Product_Line__c ;
        //objOutputCont.opp.Province_of_Supplier_SI__c = objOpp.Province_of_Supplier_SI__c;
        //objOutputCont.opp.City_of_Supplier_SI__c = objOpp.City_of_Supplier_SI__c;
        //objOutputCont.opp.City_of_iCafe__c = objOpp.City_of_iCafe__c;
        //objOutputCont.opp.Province_of_iCafe__c= objOpp.Province_of_iCafe__c;
        objOutputCont.opp.AccountId  = objOpp.AccountId;
        //objOutputCont.opp.Opportunity_Class__c = 'Strategic Opportunity';
        objOutputCont.opp.Industry__c = 'Aerospace';
        //objOutputCont.opp.Prefered_Partner__c = 'APPRO';
        //objOutputCont.opp.Application_Type__c = 'ISVs';
        //objOutputCont.opp.Critical_Priority_1_Software_Apps__c = 'AMBER';
        //objOutputCont.opp.At_Risk_Level__c = 'Low';
        objOutputCont.opp.Blocking_Issues__c = 'Test Issues';
        objOutputCont.opp.Status_Next_Step__c = 'Test Next step';
        objOutputCont.opp.Description = 'Test Description';
        objOutputCont.opp.Competition__c = 'Test';
        objOutputCont.opp.Reason_for_Close__c = 'Test';
        objOutputCont.opp.Closed_Lost_Comments__c = 'Test Comments';
        objOutputCont.opp.Amount = 100;
        //objOutputCont.opp.Reason_for_Approval__c = 'Test Approved';        
        
        List<PricebookEntry> lstPBE = [select id, Name, UnitPrice
                                       from   PricebookEntry
                                       where  IsActive = true
                                       and    Pricebook2Id = :objOutputCont.opp.Pricebook2Id
                                       and    Product2.Family = :'Tegra Embedded'
                                       order by Product2.Product_Sort_Order__c DESC, Name]; 
         
       objOutputCont.lstProductFamilies.add(null);
       clsOpportunityV2.OLIHelper objOliHelper1 = new clsOpportunityV2.OLIHelper(objOutputCont,'Tegra Embedded',lstPBE[0].id,null);  
       //objOutputCont.mapPBEsByFamily = new map<String, List<PricebookEntry>>();
       for(PricebookEntry eachPBE: lstPBE){
           objOliHelper1.pbesForFamily.add(new selectoption(eachPBE.id,eachPBE.Name));
       } 
       objOliHelper1.pbeId = lstPBE[0].id;
       ApexPages.currentPage().getParameters().get('selectedPbeId');
       //objOutputCont.addProduct();
       objOutputCont.lstPossibleQuarters.add(new selectoption(Utils.getFiscalQuarterForDate(Date.today()),Utils.swapFiscalDateSections(Utils.getFiscalQuarterForDate(Date.today()))));
       objOutputCont.startingQuarter = Utils.getFiscalQuarterForDate(Date.today());
       objOutputCont.pickStartingQuarter();
       objOliHelper1.family = 'Tegra Embedded';
       objOliHelper1.productName =lstPBE[0].Name;
       clsOpportunityV2.ScheduleEntryHelper objSEH = new clsOpportunityV2.ScheduleEntryHelper(objOutputCont,objOliHelper1,objOutputCont.startingQuarter);
       objOutputCont.lstOLIHelpers[0].lstSEHs[0].units = 1;
       objOutputCont.lstOLIHelpers[0].lstSEHs[0].asp = 10;
       objOutputCont.lstOLIHelpers[0].totalUnits = 1;
       objOutputCont.lstOLIHelpers[0].totalPrice = 10;
       objOutputCont.lstOLIHelpers[0].pbeId =lstPBE[0].id;
       objOutputCont.lstOLIHelpers[0].pbe = lstPBE[0];
       objOutputCont.save();
       objOutputCont.addNextQuarter();
       objOutputCont.addPreviousQuarter();
       objOutputCont.opp.CloseDate = objOpp.CloseDate.addMonths(3);
       objOutputCont.updateStartingQuarter();
       objOutputCont.addProduct();
       objOutputCont.deleteProductIndex = '0';
       objOutputCont.deleteProduct();
       objOutputCont.getErrorVal();
            
    }
    
}