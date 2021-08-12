/*************************************************************
    Test class for clsCloneOpp_RecordType_ExtensionV2

    2021.04.15 Test class optimization.
*************************************************************/

@isTest(seeAllData=false)
private class Test_clsCloneOpp_RecordType_ExtensionV2 {

    static testMethod void myUnitTest() {
        /*
        Account acct = new Account(Name='Test Account');
        insert acct;
        */
        
        string strAccName = 'Test_clsCloneOpp_RecordType_ExtensionV2';
        Account acct = new Account(Name=strAccName);
        acct.Automotive_Startup__c = 'No';
        insert acct;
        Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
        Opportunity opp = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Opportunity').getRecordTypeId(), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Notebook Opportunity'), Design_Start_Date__c = System.today().addMonths(1)
        try{
            insert opp;
        }Catch(Exception ee){}
            
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        clsCloneOpp_RecordType_ExtensionV2 obj = new clsCloneOpp_RecordType_ExtensionV2(stdController);
        obj.redirect();        
        
        Opportunity opp1 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Partner Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Quadro Sales Opportunity')
        try{
            insert opp1;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController1 = new ApexPages.StandardController(opp1);
       clsCloneOpp_RecordType_ExtensionV2 obj1 = new clsCloneOpp_RecordType_ExtensionV2(stdController1);
        obj1.redirect(); 
        
        Opportunity opp2 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Partner Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tesla Sales Opportunity')
         try{
        insert opp2;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController2 = new ApexPages.StandardController(opp2);
       clsCloneOpp_RecordType_ExtensionV2 obj2 = new clsCloneOpp_RecordType_ExtensionV2(stdController2);
        obj2.redirect(); 
        
         Opportunity opp3 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tegra Auto and Emb Opportunity')
              try{
        insert opp3;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController3 = new ApexPages.StandardController(opp3);
       clsCloneOpp_RecordType_ExtensionV2 obj3 = new clsCloneOpp_RecordType_ExtensionV2(stdController2);
        obj3.redirect();
        
        Opportunity opp4 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Partner Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity')
              try{
        insert opp4;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController4 = new ApexPages.StandardController(opp4);
       clsCloneOpp_RecordType_ExtensionV2 obj4 = new clsCloneOpp_RecordType_ExtensionV2(stdController4);
        obj4.redirect();
        
        Opportunity opp5 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Embedded Entertainment Opportunity')
         try{
        insert opp5;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController5 = new ApexPages.StandardController(opp5);
       clsCloneOpp_RecordType_ExtensionV2 obj5 = new clsCloneOpp_RecordType_ExtensionV2(stdController5);
        obj5.redirect();
        
        Opportunity opp6 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Partner Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tegra Archived Opportunities')
         try{
        insert opp6;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController6 = new ApexPages.StandardController(opp6);
       clsCloneOpp_RecordType_ExtensionV2 obj6 = new clsCloneOpp_RecordType_ExtensionV2(stdController6);
        obj6.redirect();
                  
    }
}