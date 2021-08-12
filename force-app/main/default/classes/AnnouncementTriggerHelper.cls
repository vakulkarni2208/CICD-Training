/*
  * @Auhtor: Moon (Perficient)
  * @Created Date: Jan 17, 2018
  * @Desc: Helper class for Announcement__c custom object..
*/
public with sharing class AnnouncementTriggerHelper {
    /**************************************************************************************************
    * Input Parameters: triggerNewList (A collection of announcements to process after the insertion in the announcement object)
    * Output:     
    * Purpose:  Process the annoucements after the insertion in the annoucements object 
    *           Step 1: Identify all the generic announcements 
    *           Step 2: Execute a batch job to associate the announcements with the Accounts of recod type 'New_Customer_Account'
    ***************************************************************************************************/    
    public static void afterInsert(List<Announcement__c> triggerNewList){
        Set<Id> anncIdSet = new Set<Id>();
        Set<Id> anncProdSpecIdSet = new Set<Id>();
        for(Announcement__c annc : triggerNewList){
            if(annc.Access_Level__c == 'Generic')//{|| annc.Access_Level__c =='Product Specific'){
                anncIdSet.add(annc.Id);
            else if(annc.Access_Level__c =='Product Specific')   
                anncProdSpecIdSet.add(annc.Id);            
            }
        Batch_InsertAnncAccount insertAnncAcctBatch;
        if(!anncIdSet.isEmpty()){
            system.debug('**calling batch');
            insertAnncAcctBatch = new Batch_InsertAnncAccount(anncIdSet,'Generic');
            Database.executebatch(insertAnncAcctBatch,200);
        }
        else if(!anncProdSpecIdSet.isEmpty()){
            system.debug('**calling batch');
            insertAnncAcctBatch = new Batch_InsertAnncAccount(anncProdSpecIdSet,'Product Specific');
            Database.executebatch(insertAnncAcctBatch,200);
        }
    }
    /**************************************************************************************************
    * Input Parameters: triggerNewList (A collection of announcements to process after the update in the announcement object)
    *                   triggerOldMap (A snapshot of announcements prior to the update in the announcement object)
    * Output:     
    * Purpose:  Process the annoucements after the update in the annoucements object 
    *           Step 1: Identify all the archived announcements
    *           Step 2: Execute a batch job to disassociate the announcements from the Customer Accounts
    ***************************************************************************************************/ 
    public static void afterUpdate(List<Announcement__c> triggerNewList,Map<Id,Announcement__c> triggerOldMap){
        Set<Id> anncIdSetToDeleteJunctions = new Set<Id>();
        for(Announcement__c annc : triggerNewList){
            if(annc.Access_Level__c == 'Archived' && triggerOldMap.get(annc.Id).Access_Level__c != annc.Access_Level__c){
                anncIdSetToDeleteJunctions.add(annc.Id);
            }
        }
        if(!anncIdSetToDeleteJunctions.isEmpty()){
            //deleteJunctions(anncIdSetToDeleteJunctions);
            Batch_DeleteAnncAccount deleteAnncAcctBatch = new Batch_DeleteAnncAccount(anncIdSetToDeleteJunctions);
            Database.executebatch(deleteAnncAcctBatch,200);
        }
    }
}