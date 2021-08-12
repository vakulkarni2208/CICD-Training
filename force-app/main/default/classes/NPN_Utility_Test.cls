/**
 * @name    NPN_Utility_Test
 * @description     This is a test class for NPN_Utility


 */

@isTest(seeAllData=false)
private class NPN_Utility_Test {

    @isTest static void deleteAttachmentsForParentObjTest(){

        dsfs__DocuSign_Status__c sobj = new dsfs__DocuSign_Status__c(
            dsfs__DocuSign_Envelope_ID__c = '7F556F8F-9FF3-4300-A201-28B4FA309A98',
            dsfs__Subject__c = 'NVIDIA Partner Network Contracts Packet for Review and Signature',
            dsfs__Envelope_Status__c = 'Completed');
        insert sobj;

        Attachment atch = new Attachment(
            ParentId = sobj.Id,
            Body= Blob.valueOf('7F7F556F8F9FF34300A20128B4FA309A98F9FF34300A20128B4FA309A98'),
            Name ='Test Attachment');
        insert atch;

        NPN_Utility.deleteAttachmentsForParentObj(new Set<Id> {sobj.Id});
    }
}