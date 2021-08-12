/**
 * Created: 02/10/2021 - Akhilesh Gupta 
 * 2021.10.02 - Akhilesh Gupta 	- SDS-2901: Invocable Method called from Process Builder when 
 * 									- New 24x7 Entitlement gets created.
 * 									- 24x7 Entitlement expires.
 * 									- Method reEvaluateEntitlementProcess is to update Entitlement process on all the Entitlements associated with Account Ids provided.
 */
public class ESP_ReEvaluateEntitlementProcess {
    
	@InvocableMethod
    public static void reEvaluateEntitlementProcess(List<Id> accIds) {
    //public static void reEvaluateEntitlementProcess(List<Entitlement> lstCurrentEntitlement) {
        set<Id> accIdSet = new set<Id>();
        accIdSet.addAll(accIds);
        ESP_EntitlementUtils.reEvaluateEntitlementProcess(accIdSet);
    }
}