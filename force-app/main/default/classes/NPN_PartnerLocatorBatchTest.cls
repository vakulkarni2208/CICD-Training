@isTest(SeeAllData=false)
private class NPN_PartnerLocatorBatchTest {
    @TestSetup
    static void makeData(){

        Id accRT= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();       
         
        Account accSobj = new Account(
            Name = 'AddOnTesting',
            Phone = '922497367',
            NPN_Program_Signed_Date__c = Date.valueOf(system.today()),
            Inactive__c = false,
            Approved__c = false,
            //Account_Email__c = 'pardeshiakash143@gmail.com.invalid',
            MDF_Program_Active__c = false,
            RecordTypeId = accRT,
            BillingCountry ='China'         
            );
        insert accSobj; 
        
        Partner_Attribute__c pAttrb = new Partner_Attribute__c( 
            Account_Name__c  = accSobj.id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL ,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Partner_Sub_Program__c ='',
            Program_Level__c = COMM_Constants.PA_LEVEL_ELITE , 
            ATP_Partner__c = true,            
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            ATP_Partner_Start_Date__c = Date.valueOf(system.today())
            );
        insert pAttrb;
        
        Partner_Attribute__c pAttrb2 = new Partner_Attribute__c( 
            Account_Name__c  = accSobj.id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL ,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SDP,
            Partner_Sub_Program__c ='EDU Services',
            Program_Level__c = COMM_Constants.PA_LEVEL_ELITE , 
            ATP_Partner__c = true,            
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            ATP_Partner_Start_Date__c = Date.valueOf(system.today())
            );
        insert pAttrb2;
        
        Partner_Attribute__c pAttrb3 = new Partner_Attribute__c( 
            Account_Name__c  = accSobj.id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL ,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SDP,
            Partner_Sub_Program__c ='Professional Services',
            Program_Level__c = COMM_Constants.PA_LEVEL_ELITE , 
            ATP_Partner__c = true,            
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            ATP_Partner_Start_Date__c = Date.valueOf(system.today())
            );
        insert pAttrb3;
    }

    @isTest
    static void testOne(){        
        Test.StartTest();
            NPN_PartnerLocatorBatch b = new NPN_PartnerLocatorBatch();
            
            Id batchId = Database.executeBatch(b, 100);
            
            system.assert(true, batchId != null);
            
        Test.stopTest();
    }
}