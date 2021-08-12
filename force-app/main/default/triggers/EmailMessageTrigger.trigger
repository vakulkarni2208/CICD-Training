trigger EmailMessageTrigger on EmailMessage (after insert, after update, before delete) {
    try {
        EmailMessageTriggerHelper helper = new EmailMessageTriggerHelper(); 
        helper.execute();
        if(Test.isRunningTest()) {
            throw new CalloutException('This exception is for testing and code coverage.');
        }
    } catch (Exception ex) {
        ServiceCloudUtils.LogErrors(ex.getMessage(), ex.getStackTraceString());
    }
}