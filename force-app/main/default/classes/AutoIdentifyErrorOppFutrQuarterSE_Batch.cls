/*
 * Author: Manideep
 * CreatedDate: 10/11/2017
 * Description: * This Batch class invokes logic in 'AutoIdentifyErrorsOppFutureQuarterSE.cls' by replicating a mock cloning of above qualified Opportunties. 
                * This Batch class is invokes the class 'AutoIdentifyErrorsOppFutureQuarterSE' to
                  to identify list of possible data errors when Cloning existing Opportunity:
                  1. Opportunities/OpportunityLineItems with inActive Products
                  2. Opportunities/OpportunityLineItems with inActive PriceBook Entries
                  3. Opportunities with long name in the 'Name' field as only 120 Characters maximum are allowed in the field. 
                  4. Schedule Entries with ‘Null’ in Revenue__c field.
                  5. Schedule Entries with ‘Null’ Display_Quarter_Sortable__c field.
	
	2017.11.29 - PJENA - Code Cleanup - ready to be deleted
*/

public class AutoIdentifyErrorOppFutrQuarterSE_Batch {
   
   // Constructor
	public AutoIdentifyErrorOppFutrQuarterSE_Batch() {}
}