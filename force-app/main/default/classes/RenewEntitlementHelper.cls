public with sharing class RenewEntitlementHelper {
    /*
     * Renew entitlement for given entitlement Id
     */
    @AuraEnabled
    public static String RenewEntitlement(String Id){
        system.debug('id-->'+id);
        //Fetch Parent entitlement
        Entitlement__c ent = [SELECT Id, Entitlement__c FROM Entitlement__c WHERE Id =:id];
        if(ent != null && ent.Entitlement__c !=null){
            //Update Parent entitlement renewal flag
            Entitlement parentEnt = new Entitlement(id =ent.Entitlement__c, Renew_Entitlement__c = true);
            update parentEnt;    
        }else{
            return 'ERROR';
        }
        return 'SUCCESS';
    }
}