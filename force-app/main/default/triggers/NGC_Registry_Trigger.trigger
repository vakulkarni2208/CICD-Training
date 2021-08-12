trigger NGC_Registry_Trigger on DGX_Registry_Container__c (before insert, before update, after insert, after update) {
    NGC_Registry_Trigger_Handler nreg = new NGC_Registry_Trigger_Handler();
    nreg.execute();
}