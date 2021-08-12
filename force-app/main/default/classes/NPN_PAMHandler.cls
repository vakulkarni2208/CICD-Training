public without sharing class NPN_PAMHandler {

  public static boolean flag = true;

  /**
   * @name    afterUpdate
   * @param   triggerNewMap
   * @param   triggerOldMap
   */
  public static void afterUpdate(Map<Id, NPN_PartnerAttributes_Modifiaction__c> triggerNewMap, Map<Id, NPN_PartnerAttributes_Modifiaction__c > triggerOldMap) {
    if(flag) {
      flag = false;
      NPN_PAMHelper.linkDocuSignStatus(triggerNewMap);
    }
  }
}