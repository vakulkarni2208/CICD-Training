/*
	2017.03.15 - PJENA - added the user custom field DO_NOT_USE__c for NVContacts corner case wherein it was showing the inactive user and we were not able to update the inactive user's email address
*/
trigger updateSalesManagerNameForDeactivatedUser on NV_Contacts__c (before insert,before update) {
    set<string> emailds = new set<string>();
    for(NV_Contacts__c obj :trigger.new){
        emailds.add(obj.Sales_Manager_Email__c);
    }
    
    List<User> lstUser = [select id,Email from User where email In :emailds and DO_NOT_USE__c = false];
    Map<string,Id> mapEmailAndSFDCId = new Map<string,Id>();
    
    for(User usr :lstUser){
        mapEmailAndSFDCId.put(usr.email,usr.id);
    }
    
    for(NV_Contacts__c obj :trigger.new){
        if(obj.Sales_Manager_Email__c!=null){
            if(mapEmailAndSFDCId.containskey(obj.Sales_Manager_Email__c)){
                obj.Sales_Manager_Name__c = mapEmailAndSFDCId.get(obj.Sales_Manager_Email__c);
            }
        }
    }
}