/*
 * @Manideep: 5/8/2019 - This code is not being used and commented as part of Opportunity RecordType Cleanup process.
*/
@isTest(seeAllData=true)
private class Test_CloneOpportunityRecordType_Ext {
    
/*
 * @Manideep - Opportunity RecordType Cleanup
    static testMethod void myUnitTest() {
        
        //Account acct = new Account(Name='Test Account');
        //insert acct;
     
        string strAccName = 'Test_CloneOpportunityRecordType_Ext';
        Account acct = new Account(Name=strAccName);
        acct.Automotive_Startup__c = 'No';
        insert acct;
        
        Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
        
        Opportunity opp = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Notebook Opportunity').getRecordTypeId(), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Notebook Opportunity'), Design_Start_Date__c = System.today().addMonths(1)
              try{
        insert opp;
        }Catch(Exception ee){}
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        CloneOpportunityRecordType_Extension obj = new CloneOpportunityRecordType_Extension(stdController);
        obj.redirect();        
        
        Opportunity opp1 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Quadro Sales Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Quadro Sales Opportunity')
         try{
        insert opp1;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController1 = new ApexPages.StandardController(opp1);
        CloneOpportunityRecordType_Extension obj1 = new CloneOpportunityRecordType_Extension(stdController1);
        obj1.redirect(); 
        
        Opportunity opp2 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tesla Sales Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tesla Sales Opportunity')
         try{
        insert opp2;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController2 = new ApexPages.StandardController(opp2);
        CloneOpportunityRecordType_Extension obj2 = new CloneOpportunityRecordType_Extension(stdController2);
        obj2.redirect(); 
        
         Opportunity opp3 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tegra Auto and Emb Opportunity')
              try{
        insert opp3;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController3 = new ApexPages.StandardController(opp3);
        CloneOpportunityRecordType_Extension obj3 = new CloneOpportunityRecordType_Extension(stdController2);
        obj3.redirect();
        
        Opportunity opp4 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Tablets, SB, SP Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity')
              try{
        insert opp4;
        }Catch(Exception ee){}
        
        ///////////////////
        ApexPages.StandardController stdController4 = new ApexPages.StandardController(opp4);
        CloneOpportunityRecordType_Extension obj4 = new CloneOpportunityRecordType_Extension(stdController4);
        obj4.redirect();
                
        Opportunity opp5 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Embedded Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Embedded Entertainment Opportunity')
         try{
        insert opp5;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController5 = new ApexPages.StandardController(opp5);
        CloneOpportunityRecordType_Extension obj5 = new CloneOpportunityRecordType_Extension(stdController5);
        obj5.redirect();
        //////////////////
        
        Opportunity opp6 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tegra Archived Opportunities').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / Tegra Archived Opportunities')
         try{
        insert opp6;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController6 = new ApexPages.StandardController(opp6);
        CloneOpportunityRecordType_Extension obj6 = new CloneOpportunityRecordType_Extension(stdController6);
        obj6.redirect();     
        
        Opportunity opp7 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GeForce Sales Opportunity').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / GeForce Sales Opportunity')
         try{
        insert opp7;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController7 = new ApexPages.StandardController(opp7);
        CloneOpportunityRecordType_Extension obj7 = new CloneOpportunityRecordType_Extension(stdController7);
        obj7.redirect();
        
        Opportunity opp8 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SW & Service Renewals').getRecordTypeId(), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));//myRTMap.get('Opportunity / SW & Service Renewals')
         try{
        insert opp8;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController8 = new ApexPages.StandardController(opp8);
        CloneOpportunityRecordType_Extension obj8 = new CloneOpportunityRecordType_Extension(stdController8);
        obj8.redirect();
               
    }
 */
}