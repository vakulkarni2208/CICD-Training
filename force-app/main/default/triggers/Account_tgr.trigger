/*
    Changelist:
    2018.08.09 - PJENA - SDS-757    - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
    2018.12.04 - Akhilesh Gupta     - SDS-1037: Update Entitlement Process on Entitlements.
    2019.08.01 - Venkat Gattamaneni - post data to EMS on changing few fields on account.
    2020.20.01 - Akhilesh Gupta     - SDS-1944: Added function updateCases.
                                    - Use common TriggerHandler
*/

trigger Account_tgr on Account (before insert, before update, after update) {
    Account_tgr_cls helper = new Account_tgr_cls();
    helper.execute();
    
    /*** OLD CODE Before implementation of TriggerHandler ***/
    //Check - Customers cannot be inserted from SAP R3
    /*if (trigger.isBefore && trigger.isInsert){
        Account_tgr_cls accTrigger = new Account_tgr_cls(trigger.new, Account_tgr_cls.CONST_BEFOREINSERT);
    }//End: Check - Customers cannot be inserted from SAP R3
    
    //2018.08.09 - PJENA - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
    if ( trigger.isBefore && (trigger.isInsert || trigger.isUpdate) ){
        Account_tgr_cls.setAccountRegionSubRegionTerritory(trigger.new);
    }
    
    if (trigger.isAfter && trigger.isUpdate){
        //NVService.isValidForSendingToEMS(trigger.new, trigger.oldMap);//added by Venkat Gattamaneni
        //Venkat G-calling a future method to send account details to EMS system-start
        
        NVService.isValidPECAccountService(Trigger.new);
        NVService.isValidPartnerAccountService(Trigger.new);
       //Venkat G-calling a future method to send account details to EMS system-end
    }
    
    //2018.12.04 - Akhilesh Gupta - SDS-1037: Update Entitlement Process on Entitlements.
    if(trigger.isAfter &&  trigger.isUpdate ){ 
        Account_tgr_cls.updateEntiltments(trigger.new, trigger.oldMap);
        Account_tgr_cls.updateCases(trigger.new, trigger.oldMap);
        //NVService.isValidForSendingToEMS(trigger.new, trigger.oldMap);
    } */
}