/*
  ChangeList: 
  * 2017.07.12 - @Manideep - Before Insert/Update: "Country/State picklist Enablement"
                           - Carry over 'MKTO_Country__c' and 'MKTO_State__c' values into 'MailingCountry' and 'MailingState' fields
                             through a method 'ctryStatePicklistforMKTO()'. 
                           - Carry over 'MailingCountry' and 'MailingState' field values into 'MKTO_Country__c' and 'MKTO_State__c' fields
                             through a method 'ctryStateMatchforMKTO()'.
                             
    2017.11.05 - PJENA - Override updates to Contact's FirstName, LastName, EMAIL by MKTO User
    
    2018.05.27 - PJENA - ESP For NPN Partners
        - Append Permissions & Group Assignments multi-picklist field with the option "Service Cloud Access" if the contact is Partner Contact type and one of the flags "is DGX Contact" or "is GRID Contact" is TRUE
        
    2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
    
    2019.05.26 - PJENA - ESP for All NPN Partners - Remove the call to appendServiceCloudAccessToPSG method
    (SDS-889 - PUB: Add Service Cloud to NPN Portal using SSO)
    2020.08.28 - Venkat - SAP Integration - SDS-2650
    
*/
trigger Contact_tgr on Contact (before insert, before update, after insert, after update) {
//SDS-2853 start
    if (trigger.isBefore){
            Contact_tgr_cls.setAddressChangeFlag(Trigger.old,Trigger.new);
    }
    //SDS-2853 End    
    //Before Insert/Update
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        //Date: 2015.09.02
        //Sets Product_Type_2__c based on Product_Type__c field value on Contact object. 
        //It appends new options to Product_Type_2__c as and when the value in Product_Type__c changes but never removes any values
        system.debug('***calls Contact_tgr_cls.setProductType2FromProductType(trigger.new)');
        Contact_tgr_cls.setProductType2FromProductType(trigger.new);
        
        /*
         * @Manideep - Date: 2017.07.12
         * Country/State picklist Enablement issue handling for Marketo
         * Only the users in this Custom Setting are allowed to invoke this logic
        */
        Set<String> userNameSet = new Set<String>();
        Map<String, MKTO_Country_State_Config__c> mktoCSMap = MKTO_Country_State_Config__c.getAll();
        for(MKTO_Country_State_Config__c mcs: mktoCSMap.Values()) {
            for(String str: mcs.UserName__c.split(';')) {
                userNameSet.add(str);
            }    
        }
        if(!userNameSet.isEmpty() && userNameSet.contains(string.valueOf(Userinfo.getUserName()))) {
           Contact_tgr_cls.ctryStatePicklistforMKTO(trigger.new);
        } else {
           Contact_tgr_cls.ctryStateMatchforMKTO(trigger.new, trigger.newMap, trigger.oldMap);   //newMap and oldMap will be null while Lead insert 
        }
        
        //2017.11.05 - PJENA - Override updates to Contact's FirstName, LastName, EMAIL by MKTO User
        if (trigger.isBefore && trigger.IsUpdate){
            system.debug('***Begin: Calls overrideUpdatesByMKTOUser');
            Contact_tgr_cls.overrideUpdatesByMKTOUser(trigger.new, trigger.oldMap);
            system.debug('***End: Calls overrideUpdatesByMKTOUser');
        }
        
    }
    
    
    //Liccensing -calling a future method to send contact details to EMS system-start
    if (trigger.isAfter && (trigger.isUpdate) && !Utility.isPECContactRequest){
        List<Id> conIdList = new List<Id>();
        for(Contact conObj:Trigger.New){
            conIdList.add(conObj.id);
        }
        Utility.isPECContactRequest = true;
         System.enqueueJob(new QueableClassForEMSService(conIdList,'Contact'));
    }
    //Liccensing calling a future method to send contact details to EMS system-end
    
    
    //PEC Utility - SAP Integration
    if (trigger.isAfter && !Utility.isSAPSyncRequest ){
        List<Id> conIdList = new List<Id>();
        for(Contact conObj:Trigger.New){
            IF(conObj.quick_create__c == True)
            conIdList.add(conObj.id);}
        //Utility.isPECContactRequest = true;
        //System.enqueueJob(new QueableClassForEMSService(conIdList,'SAPContact'));
         Utility.isSAPSyncRequest = true;
         NVAPI.ContactSync(conIdList); 
    }
    
    
        //Added by Venkat for Lead Integration on 22/Feb/2019 - START 
        if(trigger.isUpdate) {
           if(trigger.new.size() == 1){
                for(contact conObj : Trigger.new){
                    if(!String.isEmpty(conObj.GRID_Software_Evaluation_PAK__c)  && Trigger.oldMap.get(conObj.Id).GRID_Software_Evaluation__c != conObj.GRID_Software_Evaluation__c && (conObj.GRID_Software_Evaluation__c == 'Approved' || conObj.GRID_Software_Evaluation__c == 'Re-approved')){
                        System.enqueueJob(new queableClassForEMSService(conObj,'ContactEval'));
                    }  
                }
            }     
        }
        //Added by Venkat for Lead Integration on 22/Feb/2019 - END
       
        //2020.12.09 - VKULK - Partner Contact Self Register
    /*if(trigger.isAfter && trigger.isInsert) {
        Contact_tgr_cls.processSelfRegister(Trigger.new);
    }*/
    //2020.12.09 - VKULK - Partner Contact Self Register - End
        
}