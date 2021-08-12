@isTest
public class KnowledgeArticleVersion_tgr_cls_test {
    
    private static User testAdminUser = new User(Id = UserInfo.getUserId());
    final static String NAME          = 'KnowledgeArticleVersion_tgr_cls';
    
    /*public static testMethod void getKnowledgeArticleVersionListTest1() {
        System.runAs(testAdminUser) {
            Test.startTest();
            
            List<KnowledgeArticleVersion> results = getKnowledgeArticleVersionList();
            System.assertEquals(results.isEmpty(), true);
            
            Test.stopTest();
        }
    }
    
    public static List<KnowledgeArticleVersion> getKnowledgeArticleVersionList() {
        return [SELECT Id, Title FROM KnowledgeArticleVersion WHERE PublishStatus = 'online' LIMIT 500 ];
    }*/

    public static testMethod void getKnowledgeArticleVersionListTest2() {
        System.runAs(testAdminUser) { 
            
        Account acct                = Test_COMM_Factory.getAccount(NAME);
        acct.Support_Level__c       = ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c;
        insert acct;
            
        RecordType crt  = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
         //Create a Partner Contact
         Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Contact partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena11', 'FContact11', acct.Id, 'drcontactjena11@nv.com', contactRecTypeId, COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
                
        Case c          = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        c.contactid =partnerContact1.id;
        insert c;
            
        Knowledge__kav kav = createKnowledgeForceKav(true);
        // publish
        Knowledge__kav kavResult = [SELECT KnowledgeArticleId,PublishStatus FROM Knowledge__kav WHERE Id =: kav.Id LIMIT 1];
        System.assertEquals(kavResult.PublishStatus, 'Draft');
        
        CaseArticle CaseArt = new CaseArticle();
        CaseArt.CaseId = c.Id;
        CaseArt.KnowledgeArticleId = kavResult.KnowledgeArticleId;  
        insert CaseArt;
        
        kavResult.Customer_Updates__c = 'Update';
        update kavResult;
        // PublishStatus: Draft → Online
        KbManagement.PublishingService.publishArticle(kavResult.KnowledgeArticleId, true);
        }
    }

    private static Knowledge__kav createKnowledgeForceKav(Boolean isInsert) {
        Knowledge__kav knowledge = new Knowledge__kav(UrlName = 'UrlName', Title = 'Title', Summary = 'Summary', Language = 'ja', Customer_Updates__c = 'Insert');
        if (isInsert) {
            insert knowledge;
        }
        return knowledge;
    }

}