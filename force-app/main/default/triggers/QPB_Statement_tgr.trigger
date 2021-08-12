trigger QPB_Statement_tgr on QPB_Statement__c (before update) {

    if(Trigger.isBefore && Trigger.isUpdate) {

        for(QPB_Statement__c qpb : trigger.New) {

            if(qpb.Attachment_Uploaded__c == false) {
                qpb.Notified__c = false;
            }
        }
    }
}