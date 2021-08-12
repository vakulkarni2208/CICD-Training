/*
2021.04.02 - PJENA -Generic methods for creating infratructure to test Opop Reg related test scenarios
    
*/
@isTest
public class SOQ_OppReg_Test_Factory{
    public static DR_Quote_Test_Helper__mdt OppRegMDT{get;set;}
    
    static {
        OppRegMDT =  [SELECT Id, Type__c, Deal_Type__c, Program_Type__c, PriceBookId__c, RecordTypeId__c, Stage__c, OppRegLeadId__c,
                            End_Customer_Account__c, End_Customer_Contact__c, End_Customer_Contact_Role__c,
                            Partner_VAR_Account__c,Partner_VAR_Contact__c,
                            Primary_HW_Product__c,Primary_Support_SKU__c,Secondary_HW_Product__c,Secondary_Support_SKU__c
                        FROM DR_Quote_Test_Helper__mdt 
                        WHERE DeveloperName = 'OppRegOpportunity' LIMIT 1];
        
    }

    public static Opportunity createOpportunity(string oppName){
        Opportunity oppReg = new Opportunity();
        oppReg.name = oppName;
        oppReg.Type =  OppRegMDT.Type__c; //'Deal Registration';
        oppReg.DR_Deal_Type__c = OppRegMDT.Deal_Type__c; //DGX
        oppReg.DR_Lead_Type__c = OppRegMDT.Type__c;
        //oppReg.DR_Program_Name__c = '';
        oppReg.Program_Type__c = OppRegMDT.Program_Type__c; //'DGX Opp Reg';
        //opp.Industry__c
        oppReg.Primary_Customer_Use_Case__c = 'test';
        oppReg.Pricebook2Id = OppRegMDT.PriceBookId__c;
        oppReg.RecordTypeId = OppRegMDT.RecordTypeId__c;
        oppReg.StageName = 'Prospecting';
        oppReg.Probability = 10.0;
        oppReg.DR_Is_Approved__c = true;
        oppReg.DR_Approved_Date__c = Datetime.now();
        oppReg.CloseDate = System.Today();
        oppReg.Lead_Id_For_Opportunity__c = OppRegMDT.OppRegLeadId__c;
    
        //PEC
        oppReg.AccountId = OppRegMDT.End_Customer_Account__c;
        oppReg.DR_Customer_Contact__c = OppRegMDT.End_Customer_Contact__c;
        oppReg.Primary_Contact_Role__c = OppRegMDT.End_Customer_Contact_Role__c;
    
        //SP/VAR
        oppReg.DR_Partner_Sales_Rep_Company__c = OppRegMDT.Partner_VAR_Account__c;
        oppReg.DR_Partner_Sales_Rep_Name__c = OppRegMDT.Partner_VAR_Contact__c;
        oppReg.Do_you_have_a_NPN_Solution_Provider_VAR__c = 'Yes';
        oppReg.NPN_Solution_Provider_VAR__c = OppRegMDT.Partner_VAR_Account__c;
        //opp.Primary_NPN_OEM_ODM_Disti__c = OppRegMDT.;
            
        //Product Info
        oppReg.DR_Product__c = OppRegMDT.Primary_HW_Product__c;
        oppReg.DR_SKU__c = OppRegMDT.Primary_Support_SKU__c;
        oppReg.DR_SKU_Quantity__c = 1;
        oppReg.DR_Secondary_Product__c = OppRegMDT.Secondary_HW_Product__c;
        oppReg.DR_Secondary_SKU__c = OppRegMDT.Secondary_Support_SKU__c;
        oppReg.DR_Secondary_SKU_Quntity__c = 1;

        oppReg.OwnerId = UserInfo.getUserId();
    
        if (Test.isRunningTest()){
            insert oppReg;
        }
        return oppReg;
    }

}