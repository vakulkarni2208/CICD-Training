trigger AttachmentTrigger on Attachment (after insert) {
    //try {
        AttachmentTriggerHelper helper = new AttachmentTriggerHelper();
        helper.execute();
    //} catch(Exception ex) {
    //    ServiceCloudUtils.LogErrors(ex.getMessage(), ex.getStackTraceString());
    //}
}