trigger NPN_Docusign_AcoountOrLeadId on NPN_Key_Contact__c (before Insert) {
    list<Id> lstPAMID = new list<Id>();
    for (NPN_Key_Contact__c Keycontact: trigger.new){
        if(Keycontact.AccountOrLead_ID__c!= null && Keycontact.AccountOrLead_ID__c!= '' ) { 
            string AccountLeadId =Keycontact.AccountOrLead_ID__c.substring(0,3);
            if (AccountLeadId =='00Q'){
               //Keycontact.Lead__c = Keycontact.AccountOrLead_ID__c;
               Keycontact.Lead__c = Keycontact.AccountOrLead_ID__c.split('~')[0];
            }
            else{
                //Keycontact.Account__c = Keycontact.AccountOrLead_ID__c;
                lstPAMID.add(Keycontact.AccountOrLead_ID__c.split('~')[0]);
            }
        }
    }
    if(lstPAMID.size() > 0) { 
        map<Id, NPN_PartnerAttributes_Modifiaction__c> mapPAM = new map<Id,NPN_PartnerAttributes_Modifiaction__c>([select id, account__c from NPN_PartnerAttributes_Modifiaction__c where id in :lstPAMID]);
        if(!mapPAM.isEmpty()) {
            for (NPN_Key_Contact__c Keycontact: trigger.new){            
                if(mapPAM.containsKey(Keycontact.AccountOrLead_ID__c.split('~')[0]))
                    Keycontact.Account__c = mapPAM.get(Keycontact.AccountOrLead_ID__c.split('~')[0]).account__c;                
            }
        }
    }
}