/*-----------------------------------------------------------------------------------------------------------------------------------------------
Batch class name : ESP_DGXStationCoolentNotify_BAT_SCH
Description : Notify DGX station customers to remind about DGX Station Cooling Liquid at the anniversary of the DGX stations.
              Customer should be able to see an announcement for DGX Station Cooling Liquid on the community

Date            Version    Description
-----------    ---------   ----------------------------------------------------------------------- 
10/25/2019        1.0        Created
          
----------------------------------------------------------------------------------------------------------------------------------------------------
*/

public class ESP_DGXStationCoolentNotify_BAT_SCH implements Database.Batchable<SObject>,Schedulable,Database.RaisesPlatformEvents {

public Database.QueryLocator start(Database.BatchableContext BC){
    system.debug('**batch start**');
    List<Entitlement> lstEntitlement = [select id, AccountId from Entitlement where Product_Family__C like '%DGX Station%' and (startDate=:Date.Today().addYears(-1) or startDate=:Date.Today().addYears(-2) or startDate=:Date.Today().addYears(-3)) and Entitlement_Status__c='Active'];
    Set<Id> setActIds = new Set<Id>();
    if(lstEntitlement.isEmpty())
        return null;
    else{
            for(Entitlement tmpEnt : lstEntitlement ){
                setActIds.add(tmpEnt.AccountId );
            }
    }    
// Create Customer specific announcement for each Account
    CustomerAnnouncement__c custAnnounce;
    List<CustomerAnnouncement__c> lstCustAnnounce = new List<CustomerAnnouncement__c>();
    Announcement__c announce = [select id, name from Announcement__c where name= :label.Service_Cloud_Coolent_Announcement_Id and Access_Level__c ='Customer Specific' limit 1];
    for(Id actId : setActIds){
        custAnnounce = new CustomerAnnouncement__c (Announcement__c=announce.id ,Account__c=actId);
        lstCustAnnounce.add(custAnnounce );
    } 
    insert lstCustAnnounce; 
    system.debug('**setActIds**'+setActIds);  
// Find DGX contacts for above accounts    
    string strSql = 'select id,name,email,Account.Billing_Region__c,AccountId from contact where accountId in :setActIds and Community_User_Active__c=true and Synced_IDM_DGX__c=true and is_DGX_Contact__c=true';
    return Database.getQueryLocator(strSql );
}

public void execute(Database.BatchableContext BC, List<Contact>scope){
    system.debug('**batch execution**');
    EmailTemplate JapanTemplateId = [Select DeveloperName,Id,subject from EmailTemplate where DeveloperName= 'Service_Cloud_DGX_Station_Coolent_Reminder_Japan' limit 1];
    EmailTemplate TemplateId = [Select DeveloperName,Id,subject from EmailTemplate where DeveloperName= 'Service_Cloud_DGX_Station_Coolent_Reminder' limit 1];
    OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where Address='no_reply@nvidia.com' limit 1];
    List<Messaging.SingleEmailMessage> lstMessages= new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail ;
    List<string> lstToAddresses = new List<string>();
    for(Contact tmpContact : scope)
    {
            mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(owa.id);
            if(tmpContact.Account.Billing_Region__c=='JAPAN')
                mail.setTemplateID(JapanTemplateId.Id);
            else
                mail.setTemplateID(templateId.Id);     
            mail.setTargetObjectId(tmpContact.Id);
            mail.setSaveAsActivity(true);
            lstMessages.add(mail);
    }
    if(!lstMessages.isEmpty()){          
         Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMessages,false);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                  + results[0].errors[0].message);
        }
    }
}    


public void finish(Database.BatchableContext BC){
}

public void execute(SchedulableContext sc){
     ESP_DGXStationCoolentNotify_BAT_SCH bch = new ESP_DGXStationCoolentNotify_BAT_SCH();
     Database.executeBatch(bch,20);

}

}