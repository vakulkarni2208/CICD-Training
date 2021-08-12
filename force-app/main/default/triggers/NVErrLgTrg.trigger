trigger NVErrLgTrg on NV_Error_Log__c (after insert) {
    string dummy = 'dummy';
    try {
    NVErrorLogHelper.sendEmail(Trigger.new);
    } catch(Exception ex) {
    }
}