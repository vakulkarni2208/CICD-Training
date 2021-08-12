/*
  Trigger class for Opportunity object
  
  Change list:
  2016.08.24 Before Insert trigger invocation: 
    Set Primary Customer Contact Role from the Converted Lead based on the LeadId For Contact
  
  2016.09.12-Before Update invocation for setting Region/Sub-Region/Territory in case of new or Existing Opportunities
  
  2017.04.15 - Clear off Opp Reg status fields during cloning records
      It will prevent the opp reg (with termination = true) cloned records sending out termination notices
      
  2017.08.15 - Capture prior values (Prior_Amount_Value__c)
  
  2019.02.14: @Manideep - Tegra Embedded Registrations Expirations  
*/

trigger Opportunity_tgr on Opportunity (before insert, before update) {
  if(trigger.isBefore && trigger.isInsert){
     //set Opportunity Record Types based on Owner and its Lead's Product Type - during Lead conversion
     Opportunity_tgr_cls.setPartnerOpportunityRecordType(trigger.new);
    
     //2016.08.24 Before Insert trigger invocation: 
     //Set Primary Customer Contact Role from the Converted Lead based on the LeadId For Contact
     Opportunity_tgr_cls.setPrimaryContactAndRoleFromConvertedLead(trigger.new);
    
     //2016.09.12-Before Update invocation for setting Region/Sub-Region/Territory in case of new or Existing Opportunities
     system.debug('**calls Opportunity_tgr_cls.setRegionSubRegionTerritoryForOpps(trigger.new);');
     Opportunity_tgr_cls.setRegionSubRegionTerritoryForOpps(trigger.new);
    
     //2017.04.15 - Clear off Opp Reg status fields during cloning records
     //2018.02.05 - Remove the following logics which does not have any relevance now
     /*
      system.debug('**calls Opportunity_tgr_cls.clearOppRegStatusFields(trigger.new);');
      Opportunity_tgr_cls.clearOppRegStatusFields(trigger.new);
     */
    
     // 02.14.2020 - Tegra Embedded Registrations Expirations, populate the 'LastModifiedDate by Partner' for Opportunities on Insert
     Opportunity_tgr_cls.tegraEmbdPartnerOpptyRegExpInsert(trigger.new);
  }
  
  //set Partner Deal ForecastCategoryName to "Closed" if it is Closed Won
  if(trigger.isBefore && trigger.isUpdate){
     //2018.02.05 - Remove the following logics which does not have any relevance now
     /*
      Opportunity_tgr_cls.setForecastCategoryName(trigger.new);
     */
    
     //2016.08.24 Before Update trigger invocation: 
     //Set Primary Customer Contact and its Role from the Opportunity Contact Role related list if these fields are not getting set.
     system.debug('**calls Opportunity_tgr_cls.setPrimaryContactAndRoleFromOpptyContactRoleRelatedList(trigger.new);');
     Opportunity_tgr_cls.setPrimaryContactAndRoleFromOpptyContactRoleRelatedList(trigger.new);
    
     //2016.09.12-Before Update invocation for setting Region/Sub-Region/Territory in case of new or Existing Opportunities
     system.debug('**calls Opportunity_tgr_cls.setRegionSubRegionTerritoryForOpps(trigger.new);');
     Opportunity_tgr_cls.setRegionSubRegionTerritoryForOpps(trigger.new);
    
     //2017.08.15 - Capture prior values (Prior_Amount_Value__c)
     system.debug('**calls Opportunity_tgr_cls.capturePriorOppValues(trigger.old, trigger.new);');
     Opportunity_tgr_cls.capturePriorOppValues(trigger.new, trigger.oldMap, trigger.newMap);
    
     // 02.14.2020 - Populate the 'LastModifiedDate by Partner' field on the Tegra Embedded Partner Opportunities on Update
     Opportunity_tgr_cls.tegraEmbdPartnerOpptyRegExpUpdate(trigger.new, trigger.oldMap, trigger.newMap);  
  }
    
}