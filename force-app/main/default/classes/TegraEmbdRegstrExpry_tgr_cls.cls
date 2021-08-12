/*

 * Trigger Class on 'Tegra Embd Regstr Expiration by Partners' object
 * Author: Manideep
 * Created Date: 02/14/2020
 * JIRA # SDS-1493
 * Description: This trigger class is being invoked by the trigger 'TegraEmbdRegstrExpry_tgr.trg'
                This class is created for the project 'Tegra Embedded Partner Expirations'.
*/

public without sharing class TegraEmbdRegstrExpry_tgr_cls {

  /*
   * This method is being invoked by the trigger 'tegraEmbdRegstrExp_tgr.trg'.
   * Upon the insert of the new record in the object 'Tegra Embd Regstr Expiration by Partners' along with TRUE in 'Expire Registration' field on the record will Update the 'Last Modified Date by Partner' field
     to Today's Date on all the dependent opportunities of that Partner Account (Partner Sales Rep Company).
   * Upon the Update of an existing record in the object 'Tegra Embd Regstr Expiration by Partners' by changing the value in the field 'Expire Registration' from FALSE to TRUE will update the 'Last Modified Date by Partner' field
     to Today's Date on all the dependent opportunities of that Partner Account (Partner Sales Rep Company).
   * Upon the Update of an existing record in the object 'Tegra Embd Regstr Expiration by Partners' by changing the value in the field 'Expire Registration' from TRUE to FALSE will update the 'Last Modified Date by Partner' field
     to NULL on all the dependent opportunities of that Partner Account (Partner Sales Rep Company).
   */
  public static void afterInsertUpdateTegraEmbdRegExpiry(map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c> oldTrgTegEmbRegExpPartnersMap, map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c> newTrgTegEmbRegExpPartnersMap) {

    list<Opportunity> oppFilteredList = new list<Opportunity>();
    map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c> oldTegEmbRegExpPartnersMap = new map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c>();
    map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c> newTegEmbRegExpPartnersMap = new map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c>();
    map<Id, Date> opptyIdSetDateMap = new map<Id, Date>();  // This map is used to set the 'LastModifiedDate by Partner' field

    /* Rajat added below code block Start */
    Tegra_Embedded_Registration_Expirations__c tegraEmbdRegExpCS = Tegra_Embedded_Registration_Expirations__c.getOrgDefaults(); 
    String optyExcludedStages = string.valueOf(tegraEmbdRegExpCS.Opportunity_Stages_to_Exclude__c);
    Id partnerLoginProfId = [SELECT Id FROM Profile WHERE Name ='NPN Partner Community(LOGIN)' LIMIT 1].Id;                 
    /* Rajat added below code block END */

    // Not in 'Insert' scenario
    if(oldTrgTegEmbRegExpPartnersMap != NULL && !oldTrgTegEmbRegExpPartnersMap.isEmpty()) {
       for(Tegra_Embd_Regstr_Expiration_by_Partners__c tegEmbExp: oldTrgTegEmbRegExpPartnersMap.values()) {
           if(string.isNotBlank(string.valueOf(tegEmbExp.Partner_Sales_Rep_Company__c)))
              oldTegEmbRegExpPartnersMap.put(tegEmbExp.Partner_Sales_Rep_Company__c, tegEmbExp);
       }
    }

    for(Tegra_Embd_Regstr_Expiration_by_Partners__c tegEmbExp: newTrgTegEmbRegExpPartnersMap.values()) {
        if(string.isNotBlank(string.valueOf(tegEmbExp.Partner_Sales_Rep_Company__c)))
           newTegEmbRegExpPartnersMap.put(tegEmbExp.Partner_Sales_Rep_Company__c, tegEmbExp);
    }

    if(!newTegEmbRegExpPartnersMap.isEmpty()) {
        oppFilteredList = [SELECT Id, Name, DR_Partner_Sales_Rep_Company__c, LastModifiedDate_by_Partner__c, Opportunity_Expired__c, StageName
                           FROM Opportunity
                           WHERE DR_Partner_Sales_Rep_Company__c IN: newTegEmbRegExpPartnersMap.keySet() 
                           AND RecordType.Name =:COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY 
                           AND Owner.UserType != 'Standard' 
                           AND Owner.ProfileId = :partnerLoginProfId 
                           AND Opportunity_Expired__c = false];                                                                                                                 
    }

    for(Opportunity opp: oppFilteredList) {

        /* The Expire Registration is unchecked; then reset the LastModifiedBy Partner date to null for both open and closed opportunities */
        if((oldTegEmbRegExpPartnersMap.isEmpty() || (!oldTegEmbRegExpPartnersMap.isEmpty() && oldTegEmbRegExpPartnersMap.get(opp.DR_Partner_Sales_Rep_Company__c).Expire_Registration__c))
            && !newTegEmbRegExpPartnersMap.get(opp.DR_Partner_Sales_Rep_Company__c).Expire_Registration__c) {
            // Put null in the map to set the LastModifiedDate_by_Partner__c as null
            opptyIdSetDateMap.put(opp.Id, null);
        }

        /* The Expire Registration is checked; then set the LastModifiedBy Partner date to today for OPEN opportunities only */
        else if((oldTegEmbRegExpPartnersMap.isEmpty() || (!oldTegEmbRegExpPartnersMap.isEmpty() && !oldTegEmbRegExpPartnersMap.get(opp.DR_Partner_Sales_Rep_Company__c).Expire_Registration__c))
                && newTegEmbRegExpPartnersMap.get(opp.DR_Partner_Sales_Rep_Company__c).Expire_Registration__c && !optyExcludedStages.containsIgnoreCase(opp.StageName)) {            
                // Put the date value in the map to set the LastModifiedDate_by_Partner__c
                opptyIdSetDateMap.put(opp.Id, Date.Today());
        }
    }

    if(!opptyIdSetDateMap.isEmpty()) {
        updateLastModDateOnOpptys(opptyIdSetDateMap);
    }

  }

  /*
   * This method is being invoked by the trigger 'tegraEmbdRegstrExp_tgr.trg'.
   * At the Deletion of the record in the object 'Tegra Embd Regstr Expiration by Partner' update the 'Last Modified Date by Partner' field to NULL
     on all the dependent opportunities of that Partner Account.
  */
  public static void afterDeleteTegraEmbdRegExpiry(list<Tegra_Embd_Regstr_Expiration_by_Partners__c> deletedTegraEmbRegExpPartnersList) {

    list<Opportunity> oppUpdateList = new list<Opportunity>();
    list<Opportunity> oppFilteredList = new list<Opportunity>();
    map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c> tegEmbRegExpPartnersMap = new map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c>();
    Map<Id, Date> opptyIdSetDateMap = new Map<Id, Date>();

    Id partnerLoginProfId = [SELECT Id FROM Profile WHERE Name ='NPN Partner Community(LOGIN)' LIMIT 1].Id; // Added by Rajat 2019-10-01

    for(Tegra_Embd_Regstr_Expiration_by_Partners__c tegEmbExp: deletedTegraEmbRegExpPartnersList) {
        if(string.isNotBlank(string.valueOf(tegEmbExp.Partner_Sales_Rep_Company__c)))
           tegEmbRegExpPartnersMap.put(tegEmbExp.Partner_Sales_Rep_Company__c, tegEmbExp);
    }

    if(!tegEmbRegExpPartnersMap.isEmpty()) {
        oppFilteredList = [SELECT Id, Name, DR_Partner_Sales_Rep_Company__c, LastModifiedDate_by_Partner__c, Opportunity_Expired__c
                           FROM Opportunity
                           WHERE DR_Partner_Sales_Rep_Company__c IN: tegEmbRegExpPartnersMap.keySet() 
                           AND RecordType.Name =: COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY 
                           AND Owner.UserType != 'Standard' 
                           AND Owner.ProfileId = :partnerLoginProfId 
                           AND LastModifiedDate_by_Partner__c != NULL
                           AND Opportunity_Expired__c = false];                                                        
    }

    for(Opportunity opp: oppFilteredList) {
        if(opp.LastModifiedDate_by_Partner__c != null) {
           // Put null in the map to set the LastModifiedDate_by_Partner__c as null
           opptyIdSetDateMap.put(opp.Id, null);
        }
    }

    if(!opptyIdSetDateMap.isEmpty()) {
        updateLastModDateOnOpptys(opptyIdSetDateMap);
    }

  }

  /*
   * Handling this through @future method just to make sure we dont get into Time-out issues while updating Opportunities
   */
  @future
  public static void updateLastModDateOnOpptys(map<Id, Date> opptyIdLastModDateMap) {

    list<Opportunity> opptysForUpdate = new list<Opportunity>();
    
    for(Id opptyId: opptyIdLastModDateMap.keySet()) {
        opptysForUpdate.add(new Opportunity(Id = opptyId, LastModifiedDate_by_Partner__c = opptyIdLastModDateMap.get(opptyId)));
    }

    if(!opptysForUpdate.isEmpty()) {
        update opptysForUpdate;
    }

  }

}