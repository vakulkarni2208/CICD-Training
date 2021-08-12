/*
    Trigger for BRNSHRK__Brainshark_Learning__c to set Contact and Account Id with matching email address
    2015.11.6 - Remove before update trigger event
    2017.05.25 - Add Before Update and Copy SFDC User Id to Owner Id for Inter Users
*/
trigger Brainshark_Learning_tgr on BRNSHRK__Brainshark_Learning__c (before insert, before update) {
    //set Account and Contact to Brainshark Learning Records
    Brainshark_Learning_tgr_cls.setAccountAndContact(trigger.new);
}