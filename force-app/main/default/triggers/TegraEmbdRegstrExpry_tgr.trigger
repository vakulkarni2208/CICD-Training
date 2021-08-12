/*
 * Trigger on 'Tegra Embd Regstr Expiration by Partners' object
 * Author: Manideep
 * Created Date: 02/14/2020
 * JIRA # SDS-1493
 * Description: This trigger is being invoked either on insert/Update/Delete on the object 'Tegra Embd Regstr Expiration by Partners'. 
                This is created as for the project 'Tegra Embedded Partner Expirations'.
                         
*/
trigger TegraEmbdRegstrExpry_tgr on Tegra_Embd_Regstr_Expiration_by_Partners__c (after insert, after update, after delete) {
  
  if(trigger.isInsert || trigger.isUpdate) {
     //invioke the method in the class 'tegraEmbdRegstrExp_tgr_cls'
     TegraEmbdRegstrExpry_tgr_cls.afterInsertUpdateTegraEmbdRegExpiry(trigger.oldMap, trigger.newMap);
  }
  
  if(trigger.isDelete) {
     //invioke the method in the class 'tegraEmbdRegstrExp_tgr_cls'
     TegraEmbdRegstrExpry_tgr_cls.afterDeleteTegraEmbdRegExpiry(trigger.old);
  }  
     
}