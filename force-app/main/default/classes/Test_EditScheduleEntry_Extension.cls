/*
 * 1/18/2019 - @Manideep - The code is not being used, so commented out as part of Opportunity RecordType Cleanup.
*/
//@isTest(seeAllData=true)
@isTest
private class Test_EditScheduleEntry_Extension {
    
    /*
     * @Manideep - Opportunity Record Type Cleanup.
    static testMethod void myUnitTest() {
        
        //Account acct = new Account(Name='Test Account');
        //insert acct;
        
        string strAccName = 'Test_EditScheduleEntry_Extension';
        Account acct = new Account(Name=strAccName);
        acct.Automotive_Startup__c = 'No';
        insert acct;
        Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
        Schedule_Entry__c objSchedule_Entry = new Schedule_Entry__c();
        Opportunity opp = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Notebook Opportunity'), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
              try{
        insert opp;
        
        
        objSchedule_Entry.Opportunity__c =  opp.Id;
        insert  objSchedule_Entry;

        }Catch(Exception ee){}
        
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(objSchedule_Entry);
        EditScheduleEntry_Extension obj = new EditScheduleEntry_Extension(stdController);
        obj.redirect();        
        
        Opportunity opp1 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Quadro Sales Opportunity'), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
         try{
        insert opp1;
        objSchedule_Entry.Opportunity__c =  opp1.Id;
        update  objSchedule_Entry;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController1 = new ApexPages.StandardController(objSchedule_Entry);
        EditScheduleEntry_Extension obj1 = new EditScheduleEntry_Extension(stdController1);
        obj1.redirect(); 
        
        Opportunity opp2 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Tesla Sales Opportunity'), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
         try{
        insert opp2;
        objSchedule_Entry.Opportunity__c =  opp2.Id;
        update  objSchedule_Entry;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController2 = new ApexPages.StandardController(objSchedule_Entry);
        EditScheduleEntry_Extension obj2 = new EditScheduleEntry_Extension(stdController2);
        obj2.redirect(); 
        
         Opportunity opp3 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Tegra Auto and Emb Opportunity'), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
              try{
        insert opp3;
        objSchedule_Entry.Opportunity__c =  opp3.Id;
        update  objSchedule_Entry;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController3 = new ApexPages.StandardController(objSchedule_Entry);
        EditScheduleEntry_Extension obj3 = new EditScheduleEntry_Extension(stdController2);
        obj3.redirect();
        
        Opportunity opp4 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Tegra Tablets, SB, SP Opportunity'), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
              try{
        insert opp4;
        objSchedule_Entry.Opportunity__c =  opp4.Id;
        update  objSchedule_Entry;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController4 = new ApexPages.StandardController(objSchedule_Entry);
        EditScheduleEntry_Extension obj4 = new EditScheduleEntry_Extension(stdController4);
        obj4.redirect();
        
        Opportunity opp5 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Tegra Auto OEM Opportunity'), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
         try{
        insert opp5;
        objSchedule_Entry.Opportunity__c =  opp5.Id;
        update  objSchedule_Entry;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController5 = new ApexPages.StandardController(objSchedule_Entry);
        EditScheduleEntry_Extension obj5 = new EditScheduleEntry_Extension(stdController5);
        obj5.redirect();
        
        Opportunity opp6 = new Opportunity(
              AccountId=acct.Id, Name='The Opp', StageName='Initial Discussions', CloseDate=System.today(), LeadSource='the street', 
              RecordTypeId=myRTMap.get('Opportunity / Tegra Archived Opportunities'), Design_Start_Date__c = System.today().addMonths(1), 
              Design_EOL_Date__c = System.today().addMonths(2));
         try{
        insert opp6;
        objSchedule_Entry.Opportunity__c =  opp6.Id;
        update  objSchedule_Entry;
        }Catch(Exception ee){}

        ApexPages.StandardController stdController6 = new ApexPages.StandardController(objSchedule_Entry);
        EditScheduleEntry_Extension obj6 = new EditScheduleEntry_Extension(stdController6);
        obj6.redirect();
                       
    }
*/    
}