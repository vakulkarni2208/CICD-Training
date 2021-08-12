@isTest(seeAllData = false)
public class NV_PartnerTrainingPOSComplianceCtrl_Test {

    @isTest
    static void testMethodOne(){
    
        SuRF_Transit__c csST = new SuRF_Transit__c();
        csST.isTransit__c= true;
        //cs.Other fiels values        
        insert csST;
        
        Account accountRec = new Account();
        accountRec.Name = 'Scan computers LTD';
        insert accountRec;

        SuRF_Partner_Performance_Scorecard_Trans__c scoreRec1 = new SuRF_Partner_Performance_Scorecard_Trans__c(
        Account_ID__c = accountRec.id,                // Account ID
        Account_Name__c = 'Maple Computing',                   // Account Name
        Category__c = 'Training Compliance',                   // Category
        Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,                                 // Competency        
        Flag__c = 0.0,                                         // Flag
        Level__c = 'Preferred',                                // Level
        Order__c = 1,                                        // Order
        Partner_Program__c = 'Solution Provider',              // Partner Program
        PBM__c = 'Courteney Peter',                            // PBM
        Region__c = 'EMEAI'                                   // Region
        );
        insert scoreRec1;

        SuRF_Partner_Performance_Scorecard_Trans__c scoreRec2 = new SuRF_Partner_Performance_Scorecard_Trans__c(
        Account_ID__c = accountRec.id,                // Account ID
        Account_Name__c = 'Maple Computing',                   // Account Name
        Category__c = 'POS Revenue',                           // Category
        Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,                                 // Competency        
        Flag__c = 0.0,                                         // Flag
        Level__c = 'Preferred',                                // Level
        Order__c = 5,                                        // Order
        Partner_Program__c = 'Solution Provider',              // Partner Program
        PBM__c = 'Courteney Peter',                            // PBM        
        Region__c = 'EMEAI'                                   // Region
        );
        insert scoreRec2;

        Lead leadRec = new Lead();
        leadRec.DR_Lead_Type__c = 'Deal Registration';
        leadRec.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
        leadRec.LeadSource = 'Deal Registration';
        leadRec.Status = 'In Review';
        leadRec.CSP_Yes_No__c = false;
        leadRec.Company = 'NVIDA - 01152018_500pm';
        leadRec.Title = 'Sales Operations';
        leadRec.Email = 'anish@nvvvvvvviddia.com';
        leadRec.Phone = '(510) 557-2280';
        leadRec.Region__c = 'NALA';
        leadRec.DR_Deal_Type__c = 'DGX';
        leadRec.DR_Partner_Sales_Rep_Company__c= accountRec.id;
        leadRec.DR_Program_Type__c = 'DGX Opp Reg';
        //leadRec.DR_Product__c = 'DGX Station V100-32GB';
        leadRec.DR_Product__c = 'DGX A100 40GB HW';
        //leadRec.DR_SKU__c = 'DGX Station Supt 3yr';
        leadRec.DR_SKU__c = 'DGX A100 40GB Supt 3yr';
        leadRec.DR_Is_Approved__c = false;
        leadRec.DR_SKU_Quantity__c = 3;
        leadRec.DR_Program_Name__c = 'Test';
        leadRec.LastName = 'xyz';
        insert leadRec;
    
        Test.startTest();    
            PageReference pageRef = Page.NV_PartnerTrainingPOSCompliance;
            Test.setCurrentPageReference(pageRef);
            NV_PartnerTrainingPOSComplianceCtrl controllerExt = new NV_PartnerTrainingPOSComplianceCtrl( new ApexPages.StandardController(leadRec));
        Test.stopTest();
    }

    @isTest
    static void testMethodTwo(){
    
        Account accountRec = new Account();
        accountRec.Name = 'Scan computers LTD';
        insert accountRec;

        SuRF_Partner_Performance_Scorecard__c scoreRec1 = new SuRF_Partner_Performance_Scorecard__c(
        Account_ID__c = accountRec.id,
        Account_Name__c = 'Spring Firm Srl',                     // Account Name
        Category__c = 'POS Revenue',                             // Category
        Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_GV,                                  // Competency        
        Flag__c = 0,                                           // Flag
        Level__c = 'Preferred',                                  // Level
        Order__c = 5,                                          // Order
        Partner_Program__c = 'Solution Provider',                // Partner Program
        PBM__c = 'Ana Hall',                                     // PBM        
        Region__c = 'EMEAI'
        );
        insert scoreRec1;

        SuRF_Partner_Performance_Scorecard__c scoreRec2 = new SuRF_Partner_Performance_Scorecard__c(
        Account_ID__c = accountRec.id,                // Account ID
        Account_Name__c = 'PCM Technology Solutions UK LTD',     // Account Name
        Category__c = 'Training Compliance',                     // Category
        Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_GV,                                  // Competency        
        Flag__c = 0,                                           // Flag
        Level__c = 'Preferred',                                  // Level
        Order__c = 1,                                          // Order
        Partner_Program__c = 'Solution Provider',                // Partner Program
        PBM__c = 'Courteney Peter',                              // PBM
        Region__c = 'EMEAI'
        );
        insert scoreRec2;

        Lead leadRec = new Lead();
        leadRec.DR_Lead_Type__c = 'Deal Registration';
        leadRec.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
        leadRec.LeadSource = 'Deal Registration';
        leadRec.Status = 'In Review';
        leadRec.CSP_Yes_No__c = false;
        leadRec.Company = 'NVIDA - 01152018_500pm';
        leadRec.Title = 'Sales Operations';
        leadRec.Email = 'anish@nvvvvvvviddia.com';
        leadRec.Phone = '(510) 557-2280';
        leadRec.Region__c = 'NALA';
        leadRec.DR_Deal_Type__c = 'vGPU';
        leadRec.DR_Partner_Sales_Rep_Company__c= accountRec.id;
        leadRec.LastName = 'xyz';
        insert leadRec;
    
        Test.startTest();    
            PageReference pageRef = Page.NV_PartnerTrainingPOSCompliance;
            Test.setCurrentPageReference(pageRef);
            NV_PartnerTrainingPOSComplianceCtrl controllerExt = new NV_PartnerTrainingPOSComplianceCtrl( new ApexPages.StandardController(leadRec));
        Test.stopTest();
    }

    @isTest
    static void testMethodThree(){
    
        Account accountRec = new Account();
        accountRec.Name = 'Scan computers LTD';
        accountRec.NPN_Program_Signed_Date__c = System.today().addMonths(-1);
        insert accountRec;

        Partner_Attribute__c  paObj = new Partner_Attribute__c (
            Account_Name__c = accountRec.Id,
            Partner_Competency__c = COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_DL,
            Partner_Program_Name__c = COMM_CONSTANTS.PA_PROGRAM_SP,
            Program_Level__c = COMM_CONSTANTS.PA_LEVEL_PREF,
            Date_Competency_Signed__c = System.today().addMonths(-1),
            Date_Competency_Terminated__c = null
        );
        insert paObj;

        Lead leadRec = new Lead();
        leadRec.DR_Lead_Type__c = 'Deal Registration';
        leadRec.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
        leadRec.LeadSource = 'Deal Registration';
        leadRec.Status = 'In Review';
        leadRec.CSP_Yes_No__c = false;
        leadRec.Company = 'NVIDA - 01152018_500pm';
        leadRec.Title = 'Sales Operations';
        leadRec.Email = 'anish@nvvvvvvviddia.com';
        leadRec.Phone = '(510) 557-2280';
        leadRec.Region__c = 'NALA';
        leadRec.DR_Deal_Type__c = 'DGX';
        leadRec.DR_Partner_Sales_Rep_Company__c= accountRec.id;
        leadRec.DR_Program_Type__c = 'DGX Opp Reg';
        //leadRec.DR_Product__c = 'DGX Station V100-32GB';
        leadRec.DR_Product__c = 'DGX A100 40GB HW';
        //leadRec.DR_SKU__c = 'DGX Station Supt 3yr';
        leadRec.DR_SKU__c = 'DGX A100 40GB Supt 3yr';
        leadRec.DR_Is_Approved__c = false;
        leadRec.DR_SKU_Quantity__c = 3;
        leadRec.DR_Program_Name__c = 'Test';
        leadRec.LastName = 'xyz';
        insert leadRec;
    
        Test.startTest();    
        PageReference pageRef = Page.NV_PartnerTrainingPOSCompliance;
        Test.setCurrentPageReference(pageRef);
        NV_PartnerTrainingPOSComplianceCtrl controllerExt = new NV_PartnerTrainingPOSComplianceCtrl( new ApexPages.StandardController(leadRec));
        Test.stopTest();
    }
}