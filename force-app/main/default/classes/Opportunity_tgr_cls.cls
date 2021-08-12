public class Opportunity_tgr_cls {
  /*
   *****************************Functionality***********************************************************
          -----------Only in case of Before Insert Trigger---------
          - Before Insert trigger: To set Opportunity Record Type based on context Lead's Owner and Product Type
                  - If Lead owner is a Partner and Product Type = GRID => Oppty.RecordType = GRID Partner Opportunity
                  - If Lead owner is a Partner and Product Type = TESLA => Oppty.RecordType = Tesla Partner Opportunity

          9/22/2015 : Change Request by Raj
                  If the lead owner is an internal user, upon conversion of the lead, we need to use the product type field to set the opportunity record type
                          1. If Product Type = Tesla, opportunity record type should be Tesla Sales Opportunity
                          2. If Product Type = Quadro or Grid, opportunity record type should be Quadro Sales Opportunity

                  If Lead owner is a Partner and Product Type = Quadro => Oppty.RecordType = Quadro Partner Opportunity - Greg mentioned

          12/10/2015 : Changes related to GRID Sales Opportuntiy activation in Production
                  If the lead owner is an internal user, upon conversion of the lead with Product Type = GRID, set the Opportunity's Record Type to GRID Sales Opportunity
          -----------End: Only in case of Before Insert Trigger---------

          4/24/2016 - Partner Deal opptys are not setting the Forecast Category which blocks the further Claim Processing
          [
           New method setForecastCategoryName(list<Oppotunity> lstOppsInTgrNew)
          ]

          2016.08.24 Before Insert trigger invocation:
                  Set Primary Contact Role from the Converted Lead based on the LeadId For Contact
          2016.08.24 Before Update trigger invocation:
                  Set Primary Contact and its Role from the Opportunity Contact Role related list if these fields are not getting set.

          2016.09.12-Before Update invocation for setting Region/Sub-Region/Territory in case of new or Existing Opportunities

          2016.10.18 - only consider copying Contact from OCR if their Opp.Account and Contact.Account matches

          2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out

          2017.03.24 - Partner Community Named/Login license rollout

          2017.04.15 - Clear off Opp Reg status fields during cloning records
                  It will prevent the opp reg (with termination = true) cloned records sending out termination notices

          2017.05.01 - Cloned Opportunity Created Date Bug Fix - Reset CreateById, CreatedDate, LastModifiedById, LastModifiedDate to current user and current time

          2017.06.01 - PJ-26684 - Opp Reg Additional date Tracking fields - need to be nullified during cloning

          2017.08.15 - Capture prior values (Prior_Amount_Value__c)

          2017.12.09 - Set Legacy Audit fields in before insert

          2018.02.05 - Remove the following logics which does not have any relevance now
                  GEO Area logic,
                  Setting legacy audit fields, Cloned Opportunity Created Date Bug Fix
                  setForecastCategoryName

          2019.07.30 - @Manideep
                 - Tegra Embedded Registrations (Expirations)
                 - Flag inactive Tegra Embedded Partner Opportunities the Partner Owner has not updated in 60 days and re-assign ownership to the NVIDIA Account Manager (PBM)
                 
          2020.12.17 - @Manideep - SDS-2846: 
                 - Not just Opportunty Owner even if any partner user updates the opportunity then reset the 'LastModifiedDate by Partner' field. 

   */
  
  //Before Insert trigger invocation
  public static void setPartnerOpportunityRecordType(list<Opportunity> lstOppsInTgrNew){

    //get all the converted lead Ids and Opportunities that got created out of Lead conversion
    //Tips: If a opportunity is created from Lead conversion, it will have its Lead_Id_For_Opportunity__c as not-null
    list<Opportunity> lstOpportunityFromConvertedLead = new list<Opportunity>();
    list<string> lstConvertedLeadIds = new list<string>();
    for (Opportunity newOpp : lstOppsInTgrNew) {
      if (newOpp.Lead_Id_For_Opportunity__c != null) {
        lstOpportunityFromConvertedLead.add(newOpp);
        lstConvertedLeadIds.add(newOpp.Lead_Id_For_Opportunity__c);
      }
    }

    system.debug('***lstConvertedLeadIds: ' + lstConvertedLeadIds);

    //if there is not Lead Conversion then skip processing
    if (!lstConvertedLeadIds.isEmpty()) {

      //get the map of Id, Owner and Product type from converted leads
      map<Id, Lead> mapConvertedLeadIdToLeadDetails = new map<Id, Lead>([Select Id, Product_Type__c, OwnerId From Lead Where Id = : lstConvertedLeadIds]);

      //get all partner lead owners and internal lead owners separately
      //----------------------------------------------------
      set<Id> setAllLeadOwnerIds = new set<Id>();
      for (Lead l : mapConvertedLeadIdToLeadDetails.values()) {
        setAllLeadOwnerIds.add(l.OwnerId);
      }
      //2017.03.24 - Partner Community Named/Login license rollout
      //map<Id, User> mapPartnerUser = new map<Id, User>([Select Id From User Where Id = :setAllLeadOwnerIds And ProfileId in (Select Id From Profile Where UserLicense.name = :COMM_Constants.USERLICENSE_PP_GP)]) ;
      map<Id, User> mapPartnerUser = new map<Id, User>([Select Id From User Where Id = : setAllLeadOwnerIds And ProfileId in (Select Id From Profile Where UserType = : COMM_Constants.USER_USERTYPE_POWERPARTNER)]);
      set<Id> setParnterUserIds = new set<Id>();
      setParnterUserIds = mapPartnerUser.keySet();

      //Get the Internal Lead Owners by filtering the setParnterUserIds from setAllLeadOwnerIds
      set<Id> setInternalUserIds = new set<Id>();
      for (Id oLeadOwnerId : setAllLeadOwnerIds) {
        if (!setParnterUserIds.contains(oLeadOwnerId)) {
          setInternalUserIds.add(oLeadOwnerId);
        }
      }

      //----------------------------------------------------
      //End: get all partner lead owners and internal lead owners separately


      //Get the map of Product_Type and Partner Opportunity Record Type Name from custom settingsLeadProductType_OpportunityRecordType
      map<string, LeadProductType_OpportunityRecordType__c> mapCSOppRecTypeLeadProdType = LeadProductType_OpportunityRecordType__c.getAll();

      //get all the Oppty Rec Type Name and Id map
      map<string, Id> mapOpptyRectypeNameId = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_OPPORTUNITY, '');

      //From Oppty's Lead => Get Lead.Product_Type, Lead.Product_Type => Custom Settings.Oppty Record Type Name,  Custom Settings.Oppty Record Type Name => Oppty Record Type Id
      //--------------------------------------------------------------------------------------------------
      //for each oppty in trigger, set the record type based on Product Type, owner type of Lead
      for (Opportunity newOpp : lstOpportunityFromConvertedLead) {

        //If the corresponding lead is a partner lead
        if (setParnterUserIds.contains(mapConvertedLeadIdToLeadDetails.get(newOpp.Lead_Id_For_Opportunity__c).OwnerId)) {

          system.debug('***This is a Lead owned by Partner User');

          if (mapConvertedLeadIdToLeadDetails.get(newOpp.Lead_Id_For_Opportunity__c).Product_Type__c != null) {
            system.debug('***Product Type of the Converted Lead Record = ' + mapConvertedLeadIdToLeadDetails.get(newOpp.Lead_Id_For_Opportunity__c).Product_Type__c + '-Partner');

            //get the Oppty Record Type Name from Custom settings
            LeadProductType_OpportunityRecordType__c csLPTORT = mapCSOppRecTypeLeadProdType.get(mapConvertedLeadIdToLeadDetails.get(newOpp.Lead_Id_For_Opportunity__c).Product_Type__c + '-Partner');
            system.debug('***Custome Settings Record for the Produc Type matching with Lead Product Type = ' + csLPTORT);

            if (csLPTORT != null) {
              string strRecTypeName = csLPTORT.Opportunity_RecordTypeName__c;
              system.debug('*** Opportunity Record Type Name to set for this Oppty = ' + strRecTypeName);
              string strRecTypeId = mapOpptyRectypeNameId.get(strRecTypeName);
              if (strRecTypeId != null) {
                newOpp.RecordTypeId = strRecTypeId;
              }
            }
          }

        }else if (setInternalUserIds.contains(mapConvertedLeadIdToLeadDetails.get(newOpp.Lead_Id_For_Opportunity__c).OwnerId)) {

          system.debug('***This is a Lead owned by Internal User');

          if (mapConvertedLeadIdToLeadDetails.get(newOpp.Lead_Id_For_Opportunity__c).Product_Type__c != null) {
            system.debug('***Product Type of the Converted Lead Record = ' + mapConvertedLeadIdToLeadDetails.get(newOpp.Lead_Id_For_Opportunity__c).Product_Type__c + '-Internal');

            //get the Oppty Record Type Name from Custom settings
            LeadProductType_OpportunityRecordType__c csLPTORT = mapCSOppRecTypeLeadProdType.get(mapConvertedLeadIdToLeadDetails.get(newOpp.Lead_Id_For_Opportunity__c).Product_Type__c  + '-Internal');
            system.debug('***Custome Settings Record for the Produc Type matching with Lead Product Type = ' + csLPTORT);

            if (csLPTORT != null) {
              string strRecTypeName = csLPTORT.Opportunity_RecordTypeName__c;
              system.debug('*** Opportunity Record Type Name to set for this Oppty = ' + strRecTypeName);
              string strRecTypeId = mapOpptyRectypeNameId.get(strRecTypeName);
              if (strRecTypeId != null) {
                newOpp.RecordTypeId = strRecTypeId;
              }

            }
          }

        }//end of else if
      } //end of for loop
        //--------------------------------------------------------------------------------------------------

    }//enf of if
  }//end of function

  //2016.08.24 Before Insert trigger invocation:
  //Set Primary Contact Role from the Converted Lead based on the LeadId For Contact
  public static void setPrimaryContactAndRoleFromConvertedLead(list<Opportunity> lstOppsInTgrNew){
    //get all the converted lead Ids and Opportunities that got created out of Lead conversion
    //Tips: If a opportunity is created from Lead conversion, it will have its Lead_Id_For_Opportunity__c as not-null
    list<Opportunity> lstOpportunityFromConvertedLead = new list<Opportunity>();
    list<string> lstConvertedLeadIds = new list<string>();
    for (Opportunity newOpp : lstOppsInTgrNew) {
      if (newOpp.Lead_Id_For_Opportunity__c != null) {
        lstOpportunityFromConvertedLead.add(newOpp);
        lstConvertedLeadIds.add(newOpp.Lead_Id_For_Opportunity__c);
      }
    }

    system.debug('***lstConvertedLeadIds: ' + lstConvertedLeadIds);

    //if there is not Lead Conversion then skip processing
    if (!lstConvertedLeadIds.isEmpty()) {

      //get the map of Lead Id, Contact from converted leads
      list<Contact> lstContactsFromLeadConvert = [Select Id, Lead_Id_For_Contact__c From Contact Where Lead_Id_For_Contact__c != null and Lead_Id_For_Contact__c = :lstConvertedLeadIds];
      map<Id, Id> mapLeadIdContactId = new map<Id, Id>();
      for (Contact con : lstContactsFromLeadConvert) {
        mapLeadIdContactId.put(con.Lead_Id_For_Contact__c, con.Id);
      }

      //for each oppty in trigger, set the Primary Contact and Its role // Role should be pulled from Custom Settings
      for (Opportunity newOpp : lstOpportunityFromConvertedLead) {
        //newOpp.Primary_Contact__c = mapLeadIdContactId.get(newOpp.Lead_Id_For_Opportunity__c);
        newOpp.DR_Customer_Contact__c = mapLeadIdContactId.get(newOpp.Lead_Id_For_Opportunity__c);
        newOpp.Primary_Contact_Role__c = OCR_Settings__c.getOrgDefaults().Default_Contact_Role__c; //'Sales Contact';// Role should be pulled from Custom Settings
      }

    }
  }

  //2016.08.24 Before Update trigger invocation:
  //Set Primary Contact and its Role from the Opportunity Contact Role related list if these fields are not getting set.
  public static void setPrimaryContactAndRoleFromOpptyContactRoleRelatedList(list<Opportunity> lstOppsInTgrNew){
    system.debug('***in Opportunity_tgr_cls.setPrimaryContactAndRoleFromOpptyContactRoleRelatedList(trigger.new) method');
    //Filter all possible Opp Ids to be set with Primary Contact and Role
    map<Id, Opportunity> mapOppsForPrimaryContactRoleUpdate = new map<Id, Opportunity>();
    list<Id> lstOppIdsForPrimaryContactRoleUpdate = new list<Id>();

    for (Opportunity opp : lstOppsInTgrNew) {
      //if (opp.Primary_Contact__c == null || opp.Primary_Contact_Role__c == null){
      if (opp.DR_Customer_Contact__c == null || opp.Primary_Contact_Role__c == null) {
        lstOppIdsForPrimaryContactRoleUpdate.add(opp.Id);
        mapOppsForPrimaryContactRoleUpdate.put(opp.Id, opp);
      }
    }


    //Prepare all the OppId and their OCR details
    list<OpportunityContactRole> lstOCR = [ Select OpportunityId, ContactId, Role, Opportunity.AccountId, Contact.AccountId
                                            From OpportunityContactRole
                                            Where IsPrimary = true
                                                              And OpportunityId = :lstOppIdsForPrimaryContactRoleUpdate];
    system.debug('***lstOCR: ' + lstOCR);

    map<id, OpportunityContactRole> mapOppIdOCR = new map<Id, OpportunityContactRole>();
    if (lstOCR !=null && !lstOCR.isEmpty()) {
      for (OpportunityContactRole ocr : lstOCR) {
        //2016.10.18 - only consider copying Contact from OCR if their Opp.Account and Contact.Account matches
        if (ocr.Opportunity.AccountId == ocr.Contact.AccountId) {
          mapOppIdOCR.put(ocr.OpportunityId, ocr);
        }
      }
    }

    system.debug('***mapOppIdOCR: ' + mapOppIdOCR);

    //set the fields
    if (!mapOppsForPrimaryContactRoleUpdate.isEmpty()) {
      for (Id oppId : lstOppIdsForPrimaryContactRoleUpdate) {
        if (mapOppIdOCR.get(oppId) != null ) {
          //mapOppsForPrimaryContactRoleUpdate.get(oppId).Primary_Contact__c = mapOppIdOCR.get(oppId).ContactId;
          mapOppsForPrimaryContactRoleUpdate.get(oppId).DR_Customer_Contact__c = mapOppIdOCR.get(oppId).ContactId;
          mapOppsForPrimaryContactRoleUpdate.get(oppId).Primary_Contact_Role__c = mapOppIdOCR.get(oppId).Role;

          system.debug('***Primary contact being set : ' + mapOppIdOCR.get(oppId).ContactId);
          system.debug('***Primary contact Role being set : ' + mapOppIdOCR.get(oppId).Role);
        }
      }
    }


  }

  //Before Update trigger invocation
  //Set Partner Deal ForecastCategoryName to Closed if it is Closed Won. There are some issues with the Oppty ReEngineering code which is not setting this value
  //2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out - DR_Is_Oppty_Marked_As_Deal__c will not be set from Opp Reg, so removed the dependency
  //2018.02.05 - Remove the following logics which does not have any relevance now
  /*
     public static void setForecastCategoryName(list<Opportunity> lstOppsInTgrNew){
          system.debug('***In setPartnerOpportunityRecordType method: ');
          string strForecastCategoryName = DR_Settings__c.getOrgDefaults().DR_ForecastCategoryName_Closed__c; // Closed
          for (Opportunity newOpp : lstOppsInTgrNew){
                  //if (newOpp.DR_Is_Oppty_Marked_As_Deal__c != null && newOpp.DR_Is_Oppty_Marked_As_Deal__c && newOpp.IsClosed && newOpp.IsWon && newOpp.ForecastCategoryName != strForecastCategoryName){
                  if (newOpp.IsClosed && newOpp.IsWon && newOpp.ForecastCategoryName != strForecastCategoryName){
                          newOpp.ForecastCategoryName = strForecastCategoryName;
                  }
          }
     }
   */

  //2016.09.12-Before Update invocation for setting Region/Sub-Region/Territory in case of new or Existing Opportunities
  //2018.02.05 - Remove the following logics which does not have any relevance now
  public static void setRegionSubRegionTerritoryForOpps(list<Opportunity> lstOppsInTgrNew){

    system.debug('***In setRegionSubRegionTerritoryForNewOpps method: ');

    //Get the GEO Area and Region mapping from custom settings
    //map<string, CRM_OPP_GEO_Area_Region_Mapping_Settings__c> mapGEOAreaRegionMapping = CRM_OPP_GEO_Area_Region_Mapping_Settings__c.getAll();

    //collect the country names (if it is from Account billing country) and Opportunity Country (Id of the Country_List record) from the Opportunity
    set<string> sCountryNamesInOppty = new set<string>();
    for (Opportunity opp : lstOppsInTgrNew) {
      if (opp.Opportunity_Country__c != null) {
        sCountryNamesInOppty.add(opp.Opportunity_Country__c);
      }else if (opp.Country__c != null) {
        sCountryNamesInOppty.add(opp.Country__c);
      }
    }

    //Get the Country List map
    map<string, Country_List__c> mapCountryList = getMapCountryList(sCountryNamesInOppty);

    //Set the triggered Lead custom fields
    for(Opportunity opp : lstOppsInTgrNew) {
      /*
         //Rule 1: When GEO_Area has got values: restore it in new field Region based on the mappings
         if (opp.GEO_Area__c != null  && mapGEOAreaRegionMapping.get(opp.GEO_Area__c) != null){
              system.debug('***GEO Area is NOT null, so set the region from mapping and only region not the sub-region or territory');
              opp.Region__c = mapGEOAreaRegionMapping.get(opp.GEO_Area__c).Region__c;
              opp.Sub_Region__c = '';
              opp.Territory__c = '';

              //if the Opportunity_Country__c is null then copy from Account Billing Country
              if (opp.Opportunity_Country__c == null && mapCountryList.get(opp.Country__c) != null){
                      opp.Opportunity_Country__c =  mapCountryList.get(opp.Country__c).Id;
              }
              //end: copy from Account Billing Country

         }else if (opp.Opportunity_Country__c != null && mapCountryList.get(opp.Opportunity_Country__c) != null){
       */
      if (opp.Opportunity_Country__c != null && mapCountryList.get(opp.Opportunity_Country__c) != null) {
        //Rule 2: Opportunity_Country is present
        opp.Region__c = mapCountryList.get(opp.Opportunity_Country__c).Region__c;
        opp.Sub_Region__c = mapCountryList.get(opp.Opportunity_Country__c).Sub_Region__c;
        opp.Territory__c = mapCountryList.get(opp.Opportunity_Country__c).Territory__c;
      }else if (opp.Country__c != null && mapCountryList.get(opp.Country__c) != null) {
        //Rule 3: Account Billing Country is present
        opp.Region__c = mapCountryList.get(opp.Country__c).Region__c;
        opp.Sub_Region__c = mapCountryList.get(opp.Country__c).Sub_Region__c;
        opp.Territory__c = mapCountryList.get(opp.Country__c).Territory__c;

        //if the Opportunity_Country__c is null then copy from Account Billing Country
        if (opp.Opportunity_Country__c == null && mapCountryList.get(opp.Country__c) != null) {
          opp.Opportunity_Country__c =  mapCountryList.get(opp.Country__c).Id;
        }
        //end: copy from Account Billing Country
      }
    }

  }


  //2016.09.12-Helper function to return map of County Names and Country_List record (Id, Name, Region, Sub-Region, Territory)
  private static map<string, Country_List__c> getMapCountryList(set<string> sCountryNames){
    system.debug('***In getMapCountryList method: ');

    //creat a map of Country and its details from the Country List
    map<string, Country_List__c> mapCountryList = new map<string, Country_List__c>();

    //query the Region, Sub-Region and Territory details for the Countries in the Triggered Opportunity
    List<Country_List__c> lstCountryList = [Select name, Region__c, Sub_Region__c, Territory__c
                                            From Country_List__c
                                            Where Name = :sCountryNames
                                                         Or Id = :sCountryNames];

    if (!lstCountryList.isEmpty()) {
      for(Country_List__c country : lstCountryList) {
        if(mapCountryList.get(country.name) == null) {
          mapCountryList.put(country.name, country);
          mapCountryList.put(country.Id, country); //added the Id so that it can be compared with Country List Id
        }
      }
    }

    return mapCountryList;
  }

  //2017.04.15 - Clear off Opp Reg status fields during cloning/insert records
  //Before Insert trigger
  //2018.02.05 - Remove the following logics which does not have any relevance now
  /*
     public static void clearOppRegStatusFields(list<Opportunity> lstOppsInTgrNew){
          system.debug('***Enters Opp Reg trigger class clearOppRegStatusFields ');
          for (opportunity opp : lstOppsInTgrNew){

                  //submission flags
                  opp.DR_Is_Submitted_For_Approval__c = false;
                  opp.DR_Submitted_Date__c = null;
                  opp.DR_Is_Deal_Approved_by_SalesOps__c = false;
                  opp.DR_Approved_Date_SalesOps__c = null;
                  opp.DR_Is_Deal_Rejected_by_SalesOps__c = false;
                  opp.DR_Rejected_Date_SalesOps__c = null;
                  opp.DR_Is_Deal_Approved_by_PBM__c = false;
                  opp.DR_Approved_Date_PBM__c = null;
                  opp.DR_Is_Deal_Rejected_by_PBM__c = false;
                  opp.DR_Rejected_Date_PBM__c = null;

                  opp.DR_Is_Rejected__c = false;
                  opp.DR_Rejected_Date__c = null;

                  //extn submission flags
                  opp.DR_Is_Submitted_For_Extension__c = false;
                  opp.DR_Extension_Submission_Date__c = null;
                  opp.DR_Is_Deal_Extn_Approved_by_Admin__c = false;
                  opp.DR_Extn_Approved_Date_SalesOps__c = null;
                  opp.DR_Is_Deal_Extn_Approved_by_PBM__c = false;
                  opp.DR_Extn_Approved_Date_PBM__c = null;
                  opp.DR_Is_Deal_Extn_Approved_by_PBM_Mgr__c = false;
                  opp.DR_Extn_Approved_Date_PBM_Mgr__c = null;
                  opp.DR_Is_Deal_Extn_Rejected_by_Admin__c = false;
                  opp.DR_Extn_Rejected_Date_SalesOps__c = null;
                  opp.DR_Is_Deal_Extn_Rejected_by_PBM__c = false;
                  opp.DR_Extn_Rejected_Date_PBM__c = null;
                  opp.DR_Is_Deal_Extn_Rejected_by_PBM_Mgr__c = false;
                  opp.DR_Extn_Rejected_Date_PBM_Mgr__c = null;
                  opp.DR_Is_Extension_Approved__c = false;
                  opp.DR_Extension_Approved_Date__c = null;
                  opp.DR_Is_Extension_Rejected__c = false;
                  opp.DR_Extension_Rejected_Date__c = null;

                  //claim submission flags
                  opp.DR_Is_Claim_Submitted_For_Approval__c = false;
                  opp.DR_Claim_Submitted_Date__c = null;
                  opp.DR_Is_Claim_Approved_by_SalesOps__c = false;
                  opp.DR_Claim_Approved_Date_SalesOps__c = null;
                  opp.DR_Is_Claim_Approved_by_PBM__c = false;
                  opp.DR_Claim_Approved_Date_PBM__c = null;
                  opp.DR_Is_Claim_Rejected_by_SalesOps__c = false;
                  opp.DR_Claim_Rejected_Date_SalesOps__c = null;
                  opp.DR_Is_Claim_Rejected_by_PBM__c = false;
                  opp.DR_Claim_Rejected_Date_PBM__c = null;
                  opp.DR_Is_Claim_Approved__c  = false;
                  opp.DR_Claim_Approved_Date__c = null;
                  opp.DR_Is_Claim_Rejected__c = false;
                  opp.DR_Claim_Rejected_Date__c = null;

                  //termination flags
                  opp.DR_Is_Terminated__c = false;
                  opp.DR_Termination_Date__c = null;
                  opp.DR_Deal_Terminated_By__c = null;
                  opp.DR_Reason_For_Termination__c = null;

                  //expiration flags
                  opp.DR_Expiration_Date_Admin_Override__c = null;

                  //2017.05.01 - Cloned Opportunity Created Date Bug Fix - Reset CreateById, CreatedDate, LastModifiedById, LastModifiedDate to current user and current time
                  //Set the Create Date and Created By to the current userz
                  Id currentUserId = userinfo.getUserId();
                  DateTime currentDateTime = System.now();
                  opp.CreatedById = currentUserId;
                  opp.CreatedDate = currentDateTime;
                  opp.LastModifiedById = currentUserId;
                  opp.LastModifiedDate = currentDateTime;

                  //2017.12.09 - Set Legacy Audit fields in before insert
                  opp.Legacy_CreatedById__c = currentUserId;
                  opp.Legacy_CreatedDate__c = currentDateTime;
                  opp.Legacy_LastModifiedById__c = currentUserId;
                  opp.Legacy_LastModifiedDate__c = currentDateTime;
          }
          system.debug('***Exits Opp Reg trigger class clearOppRegStatusFields ');
     }
   */

  //2017.08.15 - Capture prior values (Prior_Amount_Value__c)
  //Before update
  public static void capturePriorOppValues(list<Opportunity> newRecs, map<Id, Opportunity> oldMap, map<Id, Opportunity> newMap){
    for (Opportunity opp : newRecs) {
      if (opp.Amount > 0 && oldMap.get(opp.Id).Amount <> opp.Amount && oldMap.get(opp.Id).Amount > 0) {
        opp.Prior_Amount_Value__c = oldMap.get(opp.Id).Amount;
      }
    }
  }

  // 02/14/2020 - Tegra Embedded Registrations Expirations while 'Insert'
  // Lead got Converted into Opportunity and assigned to a Partner User  ---->   update last modified date to today
  public static void tegraEmbdPartnerOpptyRegExpInsert(list<Opportunity> newOpptys) {
     
    // Check the Opportunity Record Type
    list<Opportunity> newTegraOppList = isTegraPartnerOppty(newOpptys);

    // Collect the Partner Accounts from the Custom Object 'Tegra Embd Regstr Expiration by Partners'
    map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c> tegEmbRegstrExpbyPartnersMap = new map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c>();

    Set<Id> partnerAccIdSet = new Set<Id>();
    Set<Id> oppOwnerIdSet = new Set<Id>();
    Set<Id> oppOwnerPartnerIdSet = new Set<Id>();
    
    Id partnerLoginProfId = [SELECT Id FROM Profile WHERE Name ='NPN Partner Community(LOGIN)' LIMIT 1].Id;
    
    for(Opportunity opp: newTegraOppList) {
        if(opp.DR_Partner_Sales_Rep_Company__c != null) {
           partnerAccIdSet.add(opp.DR_Partner_Sales_Rep_Company__c);
           oppOwnerIdSet.add(opp.OwnerId);     
        }
    }
    
    // Check if the new Opportunity Owner is a Partner User and add to a 'Set'     
    for(User usr: [Select Id FROM User WHERE Id IN:oppOwnerIdSet AND UserType != 'Standard' AND ProfileId =:partnerLoginProfId]) {
        oppOwnerPartnerIdSet.add(usr.Id);
    }
    system.debug('oppOwnerPartnerIdSet---->'+oppOwnerPartnerIdSet);

    if(!partnerAccIdSet.isEmpty()) {
       /* Collect the Partner Account Id's and the records from the Custom Object 'Tegra Embd Regstr Expiration by Partners' those which have
          Expire Registration enabled.
       */
       for(Tegra_Embd_Regstr_Expiration_by_Partners__c terexp: [SELECT Id, Expire_Registration__c, Partner_Sales_Rep_Company__c FROM Tegra_Embd_Regstr_Expiration_by_Partners__c WHERE Partner_Sales_Rep_Company__c IN :partnerAccIdSet AND Expire_Registration__c = true]) {
           tegEmbRegstrExpbyPartnersMap.put(terexp.Partner_Sales_Rep_Company__c, terexp);
       }
       system.debug('tegEmbRegstrExpbyPartnersMap 1--->'+tegEmbRegstrExpbyPartnersMap);
    }

    if(!newTegraOppList.isEmpty() && !tegEmbRegstrExpbyPartnersMap.isEmpty()) {
       for(Opportunity opp: newTegraOppList) {
           // while 'clone'
           if(String.isNotBlank(String.valueOf(opp.LastModifiedDate_by_Partner__c))) {
              opp.LastModifiedDate_by_Partner__c = Null;
           }
                                 
           // 1. Populate the 'LastModifiedDate by Partner' if the Opportunity Owner is a Partner User
           // 2. Check if the Opportunity's Partner Account is in the Custom Object 'Tegra Embd Regstr Expiration by Partners'
           if(!oppOwnerPartnerIdSet.isEmpty() && oppOwnerPartnerIdSet.contains(opp.OwnerId) && tegEmbRegstrExpbyPartnersMap.containsKey(opp.DR_Partner_Sales_Rep_Company__c)) {
               opp.LastModifiedDate_by_Partner__c = Date.Today();
           }
           system.debug('opp.LastModifiedDate_by_Partner__c---->'+opp.LastModifiedDate_by_Partner__c);  
       }
    } 

  }

  //2019.07.30 - Tegra Embedded Registrations Expirations while 'Update'
  public static void tegraEmbdPartnerOpptyRegExpUpdate(list<Opportunity> newOpptys, map<Id, Opportunity> oldMap, map<Id, Opportunity> newMap) {
    
    // Check the Opportunity Record Type
    list<Opportunity> newTegraOppList = isTegraPartnerOppty(newOpptys);
    
    // Collect the Partner Accounts from the Custom Object 'Tegra Embd Regstr Expiration by Partners'
    map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c> tegEmbRegstrExpbyPartnersMap = new map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c>();

    set<Id> ownerIdSet = new set<Id>();
    map<Id, User> userMap = new map<Id, User>();
    Set<Id> partnerAccIdSet = new Set<Id>();

    List<string> opptyExcldStages = new List<String>();

    Id partnerLoginProfId = [SELECT Id FROM Profile WHERE Name ='NPN Partner Community(LOGIN)' LIMIT 1].Id; // Added by Rajat 2019-10-01
    Tegra_Embedded_Registration_Expirations__c tegraEmbdRegExpCS = Tegra_Embedded_Registration_Expirations__c.getOrgDefaults();
    String optyExcldStage = string.valueOf(tegraEmbdRegExpCS.Opportunity_Stages_to_Exclude__c);

    for(Opportunity opp: newTegraOppList) {
        partnerAccIdSet.add(opp.DR_Partner_Sales_Rep_Company__c);
        ownerIdSet.add(opp.OwnerId);
    }

    if(!partnerAccIdSet.isEmpty()) {
       // Collect the Partner Account Id's and the records from the Custom Object 'Tegra Embd Regstr Expiration by Partners'
       for(Tegra_Embd_Regstr_Expiration_by_Partners__c terexp: [SELECT Id, Partner_Sales_Rep_Company__c, Expire_Registration__c FROM Tegra_Embd_Regstr_Expiration_by_Partners__c WHERE Partner_Sales_Rep_Company__c IN: partnerAccIdSet AND Expire_Registration__c = true]) {
           tegEmbRegstrExpbyPartnersMap.put(terexp.Partner_Sales_Rep_Company__c, terexp);
       }
    }
    system.debug('tegEmbRegstrExpbyPartnersMap--->'+tegEmbRegstrExpbyPartnersMap);

    if(!newTegraOppList.isEmpty() && !tegEmbRegstrExpbyPartnersMap.isEmpty()) {
               
       // collect the User details in a map
       for(User usr: [SELECT Id, UserType, ProfileId FROM User WHERE Id IN:ownerIdSet]) {
           userMap.put(usr.Id, usr);
       }

       for(Opportunity opp: newTegraOppList) {
           // owner change partner to internal  --> reset the last modified date to null
           // owner change internal to partner  --> set the last modified date to today
           // internal edits partner oppty      --> no change on last modified date
           // partner edits partner oppty       --> update last modified date
           // partner edits internal oppty      --> update last modified date to today (Cannt be done as lack of access)
           // internal edits internal oppty     --> no change on last modified date
                     
           if(tegEmbRegstrExpbyPartnersMap.containsKey(opp.DR_Partner_Sales_Rep_Company__c) && tegEmbRegstrExpbyPartnersMap.get(opp.DR_Partner_Sales_Rep_Company__c).Expire_Registration__c) {
              
              //If the Opportunity stage closed, and it is not expired then empty the LastModifiedDate by Partner date.
              if(optyExcldStage.containsIgnoreCase(opp.StageName) && !opp.Opportunity_Expired__c) {
                 opp.LastModifiedDate_by_Partner__c = null;
              }
              else{
                /*
                 For all the open opportunities, if the owner is changed to Partner user then populate the LastModifiedDate by Partner date,
                 empty the Opportunity Expiration Date and Un-check the Opportunity Expired Flag. 
                */
                if(oldMap.get(opp.Id).OwnerId != opp.OwnerId && userMap.get(opp.OwnerId).UserType != 'Standard' && userMap.get(opp.OwnerId).ProfileId == partnerLoginProfId) {
                   opp.LastModifiedDate_by_Partner__c = Date.Today();
                   opp.Opportunity_Expiration_Date__c = Null;
                   // Reset the 'Opportunity Expired' flag if its already enabled
                   if(opp.Opportunity_Expired__c) {
                      opp.Opportunity_Expired__c = false;
                   }
                }

                // If the current user is the Partner user and owns the Opportunity who updates it; then update the last modified date.
                /*
                  if(UserInfo.getUserType() != 'Standard' && partnerLoginProfId == UserInfo.getProfileId() && UserInfo.getUserId() == opp.OwnerId) 
                */ 
                // SDS-2846: Not just Opportunty Owner even if any partner user updates the opportunity then reset the 'LastModifiedDate by Partner' field 
                if(UserInfo.getUserType() != 'Standard' && partnerLoginProfId == UserInfo.getProfileId()) {
                   opp.LastModifiedDate_by_Partner__c = Date.Today();
                   opp.Opportunity_Expiration_Date__c = Null;
                   // Reset the 'Opportunity Expired' flag if its already enabled
                   if(opp.Opportunity_Expired__c) {
                      opp.Opportunity_Expired__c = false;
                   }
                }

                // If the current user is an Internal user and owns of the opportunity; reset the last modified date.
                else if(UserInfo.getUserType() == 'Standard' && UserInfo.getUserId() == opp.OwnerId) {
                   opp.LastModifiedDate_by_Partner__c = null;
                }
  
              } 
           }
       }
    }
  } // end of the method 'tegraEmbdPartnerOpptyRegExpUpdate()'

  
    
    /*
   * Check if the Opportunity is 'Tegra Embedded Partner Opportunity RecordType' 
   * Exclude the Opportunties from the process those doesn't have 'SalesOps Approver' populated
  */
  public static list<Opportunity> isTegraPartnerOppty(list<Opportunity> newOppList) {
    
    //get all the Oppty Rec Type Name and Id map
    map<string, Id> mapOpptyRectypeNameId = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_OPPORTUNITY, '');
    list<Opportunity> filteredTegraOpptys = new list<Opportunity>();
    
    for(Opportunity opp: newOppList) {
        string strRecTypeId = mapOpptyRectypeNameId.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
        if(opp.RecordTypeId == strRecTypeId && string.isNotBlank(string.valueOf(opp.DR_SalesOps_Approver__c)))
           filteredTegraOpptys.add(opp);
    }
    system.debug('filteredTegraOpptys----->'+filteredTegraOpptys);
    
    return filteredTegraOpptys;
  }
    
    //Clean Renewal Opportunities
  public static void CleanRenewalCotermedOpps(list<Opportunity> newOpptys, map<Id, Opportunity> oldMap, map<Id, Opportunity> newMap) {
  
      List<id> OppIdList = new List<id>();
      List<id> Contractids = new List<id>();
      MAP<id,Contract> ContractOppMap = new MAP<id,Contract>();
   
        For(Opportunity Opp : newOpptys){
            If(Opp.recordtypeid=='012400000009ooCAAQ'){
            OppIdList.add(opp.id);
            Contractids.add(opp.SBQQ__RenewedContract__c);  
             }
            system.debug('----VVV----'+OppIdList);
        }
     for(Contract cont : [select id, ContractNumber, SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.stageName   from Contract WHERE id =: Contractids]){ // and recordtypeid =:'012400000009ooCAAQ'  
         ContractOppMap.put(cont.id,cont);
     }
      Map<id, Opportunity> newOppMap = new Map<id, Opportunity>();
      
        List<Opportunity> OppUpdateList = new List<Opportunity>();
                For(Opportunity Opp : [SELECT Number_of_Renewal_Contracts__c , StageName, (SELECT id, contractNumber FROM SBQQ__RenewedContracts__r) FROM Opportunity WHERE id =: OppIdList]){ // and recordtypeid =:'012400000009ooCAAQ' 
                    Opp.Number_of_Renewal_Contracts__c = Opp.SBQQ__RenewedContracts__r.size();
                    newOppMap.put(Opp.id,Opp);
                    system.debug('----VVV-3---'+OppUpdateList);
                }
      
     For(Opportunity Oppx : newOpptys){ 
         Oppx.Number_of_Renewal_Contracts__c = newOppMap.get(Oppx.id).Number_of_Renewal_Contracts__c;
         
         if(Oppx.id != ContractOppMap.get(Oppx.SBQQ__RenewedContract__c).SBQQ__RenewalOpportunity__c){
                Oppx.Original_Customer_Opportunity__c = ContractOppMap.get(Oppx.SBQQ__RenewedContract__c).SBQQ__RenewalOpportunity__c;
                string parent_Opp_stage = ContractOppMap.get(Oppx.SBQQ__RenewedContract__c).SBQQ__RenewalOpportunity__r.stageName;
             if((parent_Opp_stage =='Renewal Closed Won' || parent_Opp_stage =='Closed Won' || parent_Opp_stage =='Closed Lost') && Oppx.First_Expiration_Date__c < date.today() ){
                Oppx.StageName = 'Dead';
             }
         }
         
     }

      
  }

    
    
}