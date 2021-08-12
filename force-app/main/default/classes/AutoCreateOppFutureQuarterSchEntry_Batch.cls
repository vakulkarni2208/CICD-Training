/*
 * Author: Manideep
 * CreatedDate: 10/11/2017
 * Description: This is a Batch class to:-
                * Clone all existing Opportunities and classify each Opportunity basing on Quarter date of Schedule Entries.
                * Clone OpportunityLineItems for above newly created Opportunities.
                * Clone Schedule Entries for the Opportunities.     
                * This Batch class invokes logic in 'AutoCreateOpptyforFutureQuarterSchEntrys.cls' 
                
   ****** Considerations before running this Job *******
   * Deactivate Opportunity Validation Rules or Disable for System Admin who is running the job. 
     If not then Validation Errors will come up for many Opportunities. 
   * Deactivate all the Active Field lookup filter criterias or Disable for system Admin who is running the job. 
     If not done then "Value does not match filter criteria" will come up for many Opportunities that have inactive Accounts.
   * Reactivate all the Validation Rules/Lookup Filters that we deactivated in above steps.
   
   2017.11.29 - PJENA - Code Cleanup - ready to be deleted
             
*/

public class AutoCreateOppFutureQuarterSchEntry_Batch{
   
   public AutoCreateOppFutureQuarterSchEntry_Batch(){
   	
   }
    
}