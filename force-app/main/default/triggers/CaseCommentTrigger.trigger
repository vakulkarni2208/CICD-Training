trigger CaseCommentTrigger on CaseComment (before insert, after insert, after update) {
    //try {
        CaseCommentTriggerHelper helper = new CaseCommentTriggerHelper();
        helper.execute();
    //} catch(Exception ex) {
        //ServiceCloudUtils.LogErrors(ex.getMessage(), ex.getStackTraceString());
    //}
}