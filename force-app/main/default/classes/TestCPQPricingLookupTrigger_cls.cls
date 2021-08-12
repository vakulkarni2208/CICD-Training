/******************************************************************************************************************
       * Author: Samar Saha
       * Date: Apr 2021
       * Class Name : TestCPQPricingLookupTrigger_cls
       * Description: Test class for CPQPricingLookupTrigger_cls
******************************************************************************************************************/ 
@isTest
public class TestCPQPricingLookupTrigger_cls 
{   
    @TestSetup
    static void setup() {
        CPQ_Pricing_Lookup__c cpqLook = new CPQ_Pricing_Lookup__c();
        cpqLook.Name = '985-WKS000+P2INR36';
        cpqLook.Condition_Type__c = 'ZPR0';
        cpqLook.Inactive__c = False;
        cpqLook.Valid_To__c = Date.valueof('3999-12-31');
        cpqLook.Condition_Record_Number__c = '0000667853';
        insert cpqLook;
        
        CPQ_Pricing_Lookup__c cpqLook1 = new CPQ_Pricing_Lookup__c();
        cpqLook1.Name = '985-WKS000+P2INR36';
        cpqLook1.Condition_Type__c = 'ZPR0';
        cpqLook1.Inactive__c = False;
        cpqLook1.Valid_To__c = Date.valueof('3999-12-31');
        cpqLook1.Condition_Record_Number__c = '0000367853';
        insert cpqLook1;
        //reset inactive value since trigger made it True
        cpqLook1.Inactive__c = False;
        update cpqLook1;        
    }
    
    @isTest
    static void higherRecordNumber() {
        List<CPQ_Pricing_Lookup__c> cpqLookUpList = [Select Id, Name, Condition_Type__c, Inactive__c, Inactive_To_String__c, Valid_To__c, Condition_Record_Number__c, CPQ_Price_Identifier__c  
                                                         from CPQ_Pricing_Lookup__c where Condition_Record_Number__c = '0000667853'];                                                         
        CPQ_Pricing_Lookup__c cpqLook = new CPQ_Pricing_Lookup__c();
        cpqLook.Name = '985-WKS000+P2INR36';
        cpqLook.Condition_Type__c = 'ZPR0';
        cpqLook.Inactive__c = False;
        cpqLook.Valid_To__c = Date.valueof('3999-12-31');
        cpqLook.Condition_Record_Number__c = '0000867853';
        insert cpqLook;                                                   
    }
    
    @isTest
    static void lowerRecordNumber() {
        List<CPQ_Pricing_Lookup__c> cpqLookUpList = [Select Id, Name, Condition_Type__c, Inactive__c, Inactive_To_String__c, Valid_To__c, Condition_Record_Number__c, CPQ_Price_Identifier__c  
                                                         from CPQ_Pricing_Lookup__c where Condition_Record_Number__c = '0000667853'];                                                         
        CPQ_Pricing_Lookup__c cpqLook = new CPQ_Pricing_Lookup__c();
        cpqLook.Name = '985-WKS000+P2INR36';
        cpqLook.Condition_Type__c = 'ZPR0';
        cpqLook.Inactive__c = False;
        cpqLook.Valid_To__c = Date.valueof('3999-12-31');
        cpqLook.Condition_Record_Number__c = '0000467853';
        insert cpqLook;                                                    
    }
    
    @isTest
    static void updateHigherRecordNumber() {     
        List<CPQ_Pricing_Lookup__c> cpqLookUpList = [Select Id, Name, Condition_Type__c, Inactive__c, Inactive_To_String__c, Valid_To__c, Condition_Record_Number__c, CPQ_Price_Identifier__c  
                                                         from CPQ_Pricing_Lookup__c];                                                                       
        List<CPQ_Pricing_Lookup__c> updateList = new List<CPQ_Pricing_Lookup__c>();
        for(CPQ_Pricing_Lookup__c cpq : cpqLookUpList){
            if(cpq.Condition_Record_Number__c == '0000667853'){
                updateList.add(cpq);
            }
        }
        update updateList;                     
    }
    
    @isTest
    static void updateLowerRecordNumber() {     
        List<CPQ_Pricing_Lookup__c> cpqLookUpList = [Select Id, Name, Condition_Type__c, Inactive__c, Inactive_To_String__c, Valid_To__c, Condition_Record_Number__c, CPQ_Price_Identifier__c  
                                                         from CPQ_Pricing_Lookup__c];                                                                       
        List<CPQ_Pricing_Lookup__c> updateList = new List<CPQ_Pricing_Lookup__c>();
        for(CPQ_Pricing_Lookup__c cpq : cpqLookUpList){
            if(cpq.Condition_Record_Number__c == '0000367853'){
                updateList.add(cpq);
            }
        }
        update updateList;                     
    }
}