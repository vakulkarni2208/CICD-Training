/*
 * Created By: Manideep
 * CreatedDate: 10/11/2017
 * Description: This class is invoked by Batch class 'AutoIdentifyErrorsOppFutureQuarterSE_Batch' to
                to identify list  of possible data errors when Cloning exisitng  Opportunity:
                1. Opportunities/OpportunityLineItems with inActive Products
                2. Opportunities/OpportunityLineItems with inActive PriceBook Entries
                3. Opportunities with long name in the 'Name' field as only 120 Characters maximum are allowed in the field. 
                4. Schedule Entries with ‘Null’ in Revenue__c field.
                5. Schedule Entries with ‘Null’ Display_Quarter_Sortable__c field. 
	
	2017.11.29 - PJENA - Code Cleanup - ready to be deleted
*/
public class AutoIdentifyErrorsOppFutureQuarterSE {
	public AutoIdentifyErrorsOppFutureQuarterSE(){}
          
}