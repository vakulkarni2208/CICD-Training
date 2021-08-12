/**************************************************************************************************
* Name       : QueableClassForEMSService
* Purpose    : Salesforce to EMS Integration Class
***************************************************************************************************
* Author            | Version    | Created Date      | Description
***************************************************************************************************
*Venkat G           | 1.0        |  Feb 22,2019 | Generic Queueble EMS class
**************************************************************************************************/
public class QueableClassForEMSService implements Queueable, Database.AllowsCallouts {
      private List<Id> IdsList;
      private string objectType;
      private sObject sObjectObj;
      public queableClassForEMSService(List<Id> IdsListTrg,String objectType) {
            this.IdsList = IdsListTrg;
            this.objectType = objectType;
      }
      public queableClassForEMSService(Sobject sObjectObj,String objectType) {
            this.objectType = objectType;
            this.sObjectObj = sObjectObj;    
      }
      
       public void execute(QueueableContext queCont) {
           if(objectType.equals('User')){
               NVService.partnerUserRequest(IdsList);
           }
           if(objectType.equals('Account')){
               Account aaccObj = (Account) sObjectObj;
               NVAPI.AccountSyncOne(aaccObj.id);
           }
           if(objectType.equals('Contact')){
               NVService.PECContactRequest(IdsList);
           }
           if(objectType.equals('ContactEval')){
               Contact cconObj = (Contact) sObjectObj;
               NVService.rwaContactRequest(cconObj);
           }
           if(objectType.equals('SAPContact')){
               NVAPI.ContactSync(IdsList);
           }
           if(objectType.equals('Lead')){
               Lead leadObj = (Lead) sObjectObj;
               NVService.PECLeadRequest(leadObj);
           }
       }
}