@istest
public class TestComponentTriggerHelper {
    
    final static String NAME = 'TestComponentTriggerHelper';
    
    @testsetup
    public static void setup(){
        
        //Create Account
        Account acc = Test_COMM_Factory.getAccount('Test Account');
        insert acc;
        
        //Create Asset - 
        Asset ast 				= Test_COMM_Factory.getAsset(NAME, acc.Id);
        ast.SerialNumber		= 'Test123';
        insert ast;
        
        //System Part Creation
        Part__c systemPart          = Test_COMM_Factory.getPart();
        systemPart.Part_Number__c   = 'systemPart';
        systemPart.Description__c   = 'CRU, FAN DC 12V(92*92*56)';
        systemPart.Product_Family__c= 'DGX-1 Pascal Product Family';
        systemPart.Name             = 'CRU, FAN DC 12V(92*92*56)';
        systemPart.Component_Part_Name__c ='LINKCOMP2';
        insert systemPart;
        
        //Component Part Creation
        Part__c componentPart       = Test_COMM_Factory.getPart();
        componentPart.Part_Number__c= 'componentPart';
        componentPart.Description__c= 'CRU, FAN DC 12V(92*92*56)';
        componentPart.Name          = 'componentPart';
        componentPart.Product_Family__c      ='DGX-1 Pascal Product Family';
        componentPart.Component_Part_Name__c ='LINKCOMP2';
        insert componentPart;
    }
    
    @istest
    public static void TestAutopopulatePartDetails(){
        
        Test.startTest();
        
        //Test System Part Auto populate
        NV_Component__c comp1   	= Test_COMM_Factory.getComponent();
        comp1.Material_Number__c	= 'systemPart';
        comp1.Component_Name__c 	= 'sample-comp1';
        comp1.Asset_Serial_Number__c= 'Test123';
        insert comp1;
        
        comp1 = [select Id, Material_Number__c, System_Part__r.Part_Number__c from NV_Component__c where id =: comp1.Id];
        system.assertNotEquals(Null, comp1.System_Part__c);
        system.assertEquals(comp1.Material_Number__c, comp1.System_Part__r.Part_Number__c);
        
        comp1.System_Part__c    = null;
        update comp1;
        
        comp1 = [select Id, Material_Number__c, System_Part__r.Part_Number__c from NV_Component__c where id =: comp1.Id];
        system.assertNotEquals(Null, comp1.System_Part__c);
        system.assertEquals(comp1.Material_Number__c, comp1.System_Part__r.Part_Number__c);
        
        //Test Component Part Auto populate
        NV_Component__c comp2   = Test_COMM_Factory.getComponent();
        comp2.Component_PN__c   = 'componentPart';
        comp2.Component_Name__c = 'sample-comp2';
        insert comp2;
        comp2 = [select Id, Component_PN__c, Component_Part__r.Part_Number__c from NV_Component__c where id =: comp2.Id];
        system.assertNotEquals(Null, comp2.Component_Part__c);
        system.assertEquals(comp2.Component_PN__c, comp2.Component_Part__r.Part_Number__c);
        
        comp2.Component_Part__c = null;
        update comp2;
        comp2 = [select Id, Component_PN__c, Component_Part__r.Part_Number__c from NV_Component__c where id =: comp2.Id];
        system.assertNotEquals(Null, comp2.Component_Part__c);
        system.assertEquals(comp2.Component_PN__c, comp2.Component_Part__r.Part_Number__c);
        
        Test.stopTest();
    }
}