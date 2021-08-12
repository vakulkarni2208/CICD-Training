/*
 * 6/12/2019: @Manideep -  This class has logic that's commented out as part of Opportunity Record Type Cleanup.
*/ 

@isTest(seeAllData=true)
private class Test_clsSelectOppRecordType_ExtensionV2 {

    static testMethod void myUnitTest() {
        
        /*
        Account acct = new Account(Name='Test Account');
        insert acct;
        */
        string strAccName = 'Test_clsSelectOppRecordType_ExtensionV2';
        Account acct = new Account(Name=strAccName);
        acct.Automotive_Startup__c = 'No';
        insert acct;
        Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
        
        /*
        Opportunity opp = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Notebook Opportunity').getRecordTypeId(), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Notebook Opportunity'), Design_Start_Date__c = System.today().addMonths(1)
        try{
         insert opp;
        } catch(Exception ee){}
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        clsSelectOppRecordType_ExtensionV2 obj = new clsSelectOppRecordType_ExtensionV2(stdController);
        obj.redirect(); 
        */       
        
        /*
        Opportunity opp1 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Quadro Sales Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Quadro Sales Opportunity')
        try{
         insert opp1;
        } catch(Exception ee){}

        ApexPages.StandardController stdController1 = new ApexPages.StandardController(opp1);
        clsSelectOppRecordType_ExtensionV2 obj1 = new clsSelectOppRecordType_ExtensionV2(stdController1);
        obj1.redirect(); 
        */
        
        /*
        Opportunity opp2 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tesla Sales Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tesla Sales Opportunity')
         try{
        insert opp2;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController2 = new ApexPages.StandardController(opp2);
        clsSelectOppRecordType_ExtensionV2 obj2 = new clsSelectOppRecordType_ExtensionV2(stdController2);
        obj2.redirect(); 
        */
        
        // for the logic of calling specific Record Types
        Opportunity opp3 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tegra Auto and Emb Opportunity')
        try{
         insert opp3;
        } catch(Exception ee){}

        ApexPages.StandardController stdController3 = new ApexPages.StandardController(opp3);
        clsSelectOppRecordType_ExtensionV2 obj3 = new clsSelectOppRecordType_ExtensionV2(stdController3);
        obj3.redirect();
        
        /*
        Opportunity opp4 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Tablets, SB, SP Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity')
              try{
        insert opp4;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController4 = new ApexPages.StandardController(opp4);
        clsSelectOppRecordType_ExtensionV2 obj4 = new clsSelectOppRecordType_ExtensionV2(stdController4);
        obj4.redirect();
        */
        
        /*
        Opportunity opp5 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Embedded Entertainment Opportunity')
        try{
         insert opp5;
        } catch(Exception ee){}

        ApexPages.StandardController stdController5 = new ApexPages.StandardController(opp5);
        clsSelectOppRecordType_ExtensionV2 obj5 = new clsSelectOppRecordType_ExtensionV2(stdController5);
        obj5.redirect();
        */
        
        /*
        Opportunity opp6 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Archived Opportunities').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tegra Archived Opportunities')
         try{
        insert opp6;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController6 = new ApexPages.StandardController(opp6);
       clsSelectOppRecordType_ExtensionV2 obj6 = new clsSelectOppRecordType_ExtensionV2(stdController6);
        obj6.redirect();
        */
        
        // for the logic of all other Record Types
        Opportunity opp7 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SW & Service Renewals').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2)); //myRTMap.get('Opportunity / SW & Service Renewals')
        try{
         insert opp7;
        } catch(Exception ee){}

        ApexPages.StandardController stdController7 = new ApexPages.StandardController(opp7);
        clsSelectOppRecordType_ExtensionV2 obj7 = new clsSelectOppRecordType_ExtensionV2(stdController7);
        obj7.redirect();
        
        // for the logic of unknown user specific RecordTypes
        Opportunity opp8 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              Design_Start_Date__c = System.today().addMonths(1), Design_EOL_Date__c = System.today().addMonths(2));
              
        try{
         insert opp8;
        } catch(Exception ee){}

        ApexPages.StandardController stdController8 = new ApexPages.StandardController(opp8);
        clsSelectOppRecordType_ExtensionV2 obj8 = new clsSelectOppRecordType_ExtensionV2(stdController8);
        obj8.redirect();
                  
    }
}