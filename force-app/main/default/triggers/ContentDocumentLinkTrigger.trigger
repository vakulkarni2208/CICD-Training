trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
    //try {
        ContentDocumentLinkTriggerHelper helper = new ContentDocumentLinkTriggerHelper();
        helper.execute();
    //} catch(Exception ex) {
    //    ServiceCloudUtils.LogErrors(ex.getMessage(), ex.getStackTraceString());
    //} 
}