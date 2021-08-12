/*
    Changelist:
        2016.06.20 : Move setLeadRegionSubRegionTerritory method from After Insert/Update to Before Insert/Update 
        2016.07.27 - After Insert : Leadspace Integration - Add Leads to Campaigns based on the LeadSource and Lead_Origin__c
        2017.03.03 : Lead Assignment Routing Rules
        2017.07.12 - @Manideep - Before Insert/Update: "Country/State picklist Enablement"
                     - Carry over 'MKTO_Country__c' and 'MKTO_State__c' values into 'Country' and 'State' fields
                       through a method 'ctryStatePicklistforMKTO()'. 
                     - Carry over 'Country' and 'State' field values into 'MKTO_Country__c' and 'MKTO_State__c' fields
                       through a method 'ctryStateMatchforMKTO()'.
        2017.08.10 - @Manideep - Before Insert/Update: "Pre-MQL Alerts for NALA" 
                     * Send email notification to LSID matched 'NALA' Account Owner for the Leads through Send_MKTO_PreMQL_Alerts() 
                       in Lead_tgr_cls.
        2017.06.19 - SOEM Lead conversion
        2017.12.21 : @Manideep - Automotive Lead Conversion Validation of Open Tasks
        2017.02.27 : @Manideep - Automotive Lead Conversion Required fields Validation 
        2019.09.11 : @Manideep - Decommission of "Automotive Lead Conversion Validation of Open Tasks" as the auto creation of Tasks through Process Builder is retired.
        2019.09.30 : @Venkat - Licensing Eval approval code added
        2020.02.28 : @Manideep - (JIRA: SDS-2009) - Deleted invoking these methods autoConvertLead()
        2020.07.17 : Rajat     - SDS-2527: Added autoConvertLead() for Community Level Automation
        2021.01.03 : @Manideep - SDS-2795: Deleted the existing logic that calls the methods Send_MKTO_PreMQL_Alerts() and leadAssignmentMethod() in Lead_tgr_cls.cls
*/
trigger Lead_tgr on Lead (before insert, before update, after insert, after update) {
    
    //This will process leads originated from EMEAI Training and NPN Communities web forms
    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
                
        //Date: 2015.09.02
        //Set Lead Custom fields (Region__c, Sub_Region__c, Territory__c) from Custom object Country_List__c
        //system.debug('***calls Lead_tgr_cls.setLeadRegionSubRegionTerritory(trigger.new)');
        //Lead_tgr_cls.setLeadRegionSubRegionTerritory(trigger.new);
        
        //2016.07.27 : Leaspace - add leads to Campaigns based on the Leadspace profile
        if(trigger.isInsert) {
            Lead_tgr_cls.addLSLeadsToCampaign(trigger.new);            
        }
        try {
            Lead_tgr_cls.checkSOEMLeads(Trigger.new);
        } catch(Exception ex) {
            NV_Error_Log__c objERLG = new NV_Error_Log__c(Error_Description__c=ex.getStackTraceString(), Error_Message__c = ex.getMessage(), Functionality__c = 'SOEM Lead Convert');
            insert objERLG;            
        }
        //Added by Venkat for Lead Integration on 22/Feb/2019 - START 
        if(trigger.isUpdate) {
           if(trigger.new.size() >= 1){
                for(Lead leadObj : Trigger.new){
                    if(!String.isEmpty(leadObj.GRID_Software_Evaluation_PAK__c)  && Trigger.oldMap.get(leadObj.Id).GRID_Software_Evaluation__c != leadObj.GRID_Software_Evaluation__c && (leadObj.GRID_Software_Evaluation__c == 'Approved' || leadObj.GRID_Software_Evaluation__c == 'Re-approved')){
                        System.enqueueJob(new queableClassForEMSService(leadObj,'Lead'));
          }   }   }   }
         if(trigger.isInsert) {
           if(trigger.new.size() >= 1){
                for(Lead leadObj : Trigger.new){
                    if(!String.isEmpty(leadObj.GRID_Software_Evaluation_PAK__c) && (leadObj.GRID_Software_Evaluation__c == 'Approved')){
                        System.enqueueJob(new queableClassForEMSService(leadObj,'Lead'));
          }   }   }   }    
        
        //Added by Venkat for Lead Integration on 22/Feb/2019 - END
        
        /* Rajat added below for Community Level Automation on 9-July-2020 START */
        Lead_tgr_cls.autoConvertLead(trigger.new, trigger.newMap);
        /* Rajat added below for Community Level Automation on 9-July-2020 END */
        
    } else if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){ 
        //in case of before triggers, set the recordtypeId based on the lead origin  
        Lead_tgr_cls.setRecordType(trigger.new);
                
        // Automotive Lead Conversion Validation Rules
        if(trigger.isUpdate) { 
           list<Lead> leadList = new list<Lead>();
           Id autoLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(COMM_Constants.LEAD_RT_Automotive_LEAD).getRecordTypeId(); //Lead RecordType Id
           for(Lead ld: Trigger.new) {
               if(ld.RecordTypeId == autoLeadRTId) {
                  leadList.add(ld);
               }
           }
           if(!leadList.isEmpty()) {
               Lead_tgr_cls.automotiveLeadRequireddFieldsValidation(leadList); // Automotive Lead Converison Required fields Validation
               
               /*
               Lead_tgr_cls.automotiveLeadConversionValidation(leadList);  // Automotive Lead Conversion Validation of Open Tasks
               */      
           }       
        }
        
        //Date: 2015.09.02
        //Sets Product_Type_2__c based on Product_Type__c field value on Lead object. 
        //It appends new options to Product_Type_2__c as and when the value in Product_Type__c changes but never removes any values
        system.debug('***calls Lead_tgr_cls.setProductType2FromProductType(trigger.new)');
        Lead_tgr_cls.setProductType2FromProductType(trigger.new);
        
        /* 
         * @Manideep - Date: 2017.07.12 
         * Country/State picklist Enablement issue handling for Marketo
         * Only the users in this Custom Setting are allowed to invoke this logic
        */
        Set<String> userNameSet = new Set<String>();
        Map<String, MKTO_Country_State_Config__c> mktoCSMap = MKTO_Country_State_Config__c.getAll();
        for(MKTO_Country_State_Config__c mcs: mktoCSMap.Values()) {
            for(String str: mcs.UserName__c.split(';')) {
                userNameSet.add(str);
            }    
        }
        if(!userNameSet.isEmpty() && userNameSet.contains(string.valueOf(Userinfo.getUserName()))) {
            Lead_tgr_cls.ctryStatePicklistforMKTO(trigger.new);
        } else {
            Lead_tgr_cls.ctryStateMatchforMKTO(trigger.new, trigger.newMap, trigger.oldMap);  //newMap and oldMap will be null while Lead insert         
        }
        
        /* @Manideep - Date:2017.07.12 - This below code logic was incorporated in "Country/State picklist Enablement" Logic.
         // Set Lead Custom fields (Region__c, Sub_Region__c, Territory__c) from Custom object Country_List__c
         * system.debug('***calls Lead_tgr_cls.setLeadRegionSubRegionTerritory(trigger.new)');
         * Lead_tgr_cls.setLeadRegionSubRegionTerritory(trigger.new);
        */
        
        /*
        //Date 2015.09.03
        //If the Country is not withing those 9 then Copy State to State_2 and blank out State field
        //9 Countries are Australia(AU), Brazil(BR), Canada(CA), China(CN), India(IN), Ireland(IE), Italy(IT), Mexico(MX), United States(US)
        system.debug('***calls Lead_tgr_cls.setStateToNullForOtherThanNCountries(trigger.new)');
        Lead_tgr_cls.setStateToNullForOtherThanNCountries(trigger.new);
        */  
        
    }
    
}