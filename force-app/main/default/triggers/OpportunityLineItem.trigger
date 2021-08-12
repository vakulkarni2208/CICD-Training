/*
**  Trigger: OpportunityLineItem
**  SObject: OpportunityLineItem
**  Created by OpFocus on 10/04/2010
**  Description: This trigger maintains Schedule Entries for Notebook Opportunity
**        OpportunityLineItems
**  12/17/2018: @Manideep: Commented out the Create Schedule Entries Code for Notebook/Tegra Tablet Opportunities as part of retiring Old Opportunity Record Types.
*/
trigger OpportunityLineItem on OpportunityLineItem (before delete, after insert, after update) {
  
  // ====================================================================================================
  // ====== Delete Schedule Entries when associated Opportunity Line Items are deleted ==================
  // ====== (Do this BEFORE creating new Schedule Entries for an edit) ==================================
  // ====================================================================================================
  if (Trigger.isBefore && Trigger.isDelete) {
    
    // Schedule_Entry__c has a TEXT field that contains the OLI Id.
    // This is a TEXT field, not a lookup, because the platform won't let us create
    // a lookup to an OpportunityLineItem.  
    // If the user is deleting an OLI, find all ScheduleEntries that have a text field that
    // refers to the OLI being deleted, and delete them. 
    List<String> lstOliIds = new List<String>();
    List<Id> lstOppIds = new List<Id>();
    
    for (OpportunityLineItem oli : Trigger.old) {
      lstOliIds.add(oli.id);
      lstOppIds.add(oli.OpportunityId);
    }    
    
    List<Schedule_Entry__c> scheduleEntries = 
      [Select Id, OLI_Id__c, Revenue__c
       From   Schedule_Entry__c
       Where  OLI_Id__c in :lstOliIds];
    
    delete scheduleEntries;
    
  }
  
  if (Trigger.isAfter && Trigger.isUpdate) {
    
    // Schedule_Entry__c has a TEXT field that contains the OLI Id.
    // This is a TEXT field, not a lookup, because the platform won't let us create
    // a lookup to an OpportunityLineItem.  
    // If the user is deleting an OLI, find all ScheduleEntries that have a text field that
    // refers to the OLI being deleted, and delete them. 
    List<String> lstOliIds = new List<String>();
    List<Id> lstOppIds = new List<Id>();
    
    for (OpportunityLineItem oli : Trigger.old) {
      lstOliIds.add(oli.id);
      lstOppIds.add(oli.OpportunityId);
    }    
    
    List<Schedule_Entry__c> scheduleEntries = 
      [Select Id, OLI_Id__c, Revenue__c
       From   Schedule_Entry__c
       Where  OLI_Id__c in :lstOliIds];
    
    delete scheduleEntries;                        
  }
  
  /*
  // ====================================================================================================
  // ===== Create Schedule Entries for Notebook and Tegra Tablet Opportunity' Line Items ================
  // ====================================================================================================
  if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {

    Set<Id> setOppIds = new Set<Id>();
    for (OpportunityLineItem oli : Trigger.new) {
      setOppIds.add(oli.OpportunityId);
    }

    // Retrieve all of the associated Notebook or Tegra Tablet Opportunities
    //Map<Id, Opportunity> opps = new Map<Id, Opportunity>(
    //  [Select Id, Name, Design_Start_Date__c, Design_EOL_Date__c, Lifetime_Revenue__c, RecordType.Name 
    //   From   Opportunity 
    //   Where Id in :setOppIds 
    //   AND (RecordType.Name = 'Notebook Opportunity' or RecordType.Name = 'Tegra Tablets, SB, SP Opportunity')]);
    //
        
    Map<Id, Opportunity> opps = new Map<Id, Opportunity>(
      [Select Id, Name, Design_Start_Date__c, Design_EOL_Date__c, RecordType.Name 
       From   Opportunity 
       Where Id in :setOppIds 
       AND (RecordType.Name = 'Notebook Opportunity' or RecordType.Name = 'Tegra Tablets, SB, SP Opportunity' or RecordType.Name = 'Embedded Entertainment Opportunity' or RecordType.Name = 'Tegra Tablets,SB,SP OpportunityV2' or RecordType.Name = 'Embedded Entertainment OpportunityV2')]);
     
     if (opps.size() > 0) {
      // Pull out all of the Opportunity Line Items for these Opps
      List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
      for (OpportunityLineItem oli : Trigger.new) {
        if (opps.containskey(oli.OpportunityId)) {
          olis.add(oli);                
        }
      }
  
      // Create a map, indexed by Opp Id, where each entry contains a list of that Opp's OLIs
      Map<Id, List<OpportunityLineItem>> mapOLIsByOppId = new Map<Id, List<OpportunityLineItem>>();
      for (OpportunityLineItem oli : olis) {
        List<OpportunityLineItem> lstOLIs = mapOLIsByOppId.get(oli.OpportunityId);
        if (lstOLIs == null) {
          lstOLis = new List<OpportunityLineItem>();
        }
        lstOLIs.add(oli);
        mapOLIsByOppId.put(oli.OpportunityId, lstOLIs);  
      }
        
      // Now we have a map of OLIs, indexed by their Opp Id
      // Create a list of Schedule Entries for them
      List<Schedule_Entry__c> lstSEs = new List<Schedule_Entry__c>();
      for (Opportunity opp : opps.values()) {  
        List<Schedule_Entry__c> ses = CreateScheduleEntries.createScheduleForNotebookOpps(opp, mapOLIsByOppId.get(opp.Id));
        if (ses <> null) lstSEs.addAll(ses);
      }
      if (lstSEs.size() > 0) {
        insert lstSEs;
      }
    }
  }
  */
  
}