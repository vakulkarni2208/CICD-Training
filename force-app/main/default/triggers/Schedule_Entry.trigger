/*
**  Trigger: Schedule_Entry
**  SObject: Schedule_Entry__c
**  Created by OpFocus on 10/04/2010
**  Description: This trigger updates Opportunities when changes are made
**              to the associated Schedule Entries. It also computes the
**              Display_Quarter__c (fiscal quarter) for records that have
**              a Schedule_Date__c value.
**  1/22/2018: @Manideep: Removed the boolean check variable reference for the class 'CreateScheduleEntries.cls'.
*/
trigger Schedule_Entry on Schedule_Entry__c (before delete, before insert, before update) {
    
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {

        // See if the monthly dates of any Schedule Entries are set,
        // requiring us to compute their Fiscal Quarters
        Boolean blnNeedToRecomputeQuarters = false;
        for (Schedule_Entry__c se : Trigger.new) {
            if ((Trigger.isInsert && se.Schedule_Date__c != null)  ||
                (Trigger.isUpdate && (se.Schedule_Date__c != Trigger.oldMap.get(se.id).Schedule_Date__c))     
               ) {
                blnNeedToRecomputeQuarters = true;
                break;
            }
        }

        // If there are any Schedule Entries whose Display_Quarter__c needs to be computed, compute them
        if (blnNeedToRecomputeQuarters) {
        
            // For each Schedule_Entry__c that has a Schedule_Date__c, compute its
            // fiscal quarter and store it in Display_Quarter__c
            for (Schedule_Entry__c se : Trigger.new) {
                if ((Trigger.isInsert && se.Schedule_Date__c != null)  ||
                    (Trigger.isUpdate && (se.Schedule_Date__c != Trigger.oldMap.get(se.id).Schedule_Date__c))    
                   ) {
                    se.Display_Quarter__c = Utils.getFiscalQuarterForDate(se.Schedule_Date__c);
                }
            }
        }
    }

    /*if (Trigger.isBefore && Trigger.isDelete) {
        // Recalculate Opportunity.Lifetime_Revenue__c for the deleted Opportunities
        List<Id> lstOppIds = new List<Id>();
        for (Schedule_Entry__c se : Trigger.old) lstOppIds.add(se.Opportunity__c);

        Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>( 
          [Select Id, Lifetime_Revenue__c
           From   Opportunity
           Where  Id in :lstOppIds]);
        for (Schedule_Entry__c se : Trigger.old) {
            Opportunity opp = mapOpps.get(se.Opportunity__c);
            if (opp != null) {
                if (opp.Lifetime_Revenue__c == null) opp.Lifetime_Revenue__c = 0;
                opp.Lifetime_Revenue__c -= se.Revenue__c;
                if (opp.Lifetime_Revenue__c < 0) opp.Lifetime_Revenue__c = 0;
            }
        }                  
        update mapOpps.values();

    }*/
}