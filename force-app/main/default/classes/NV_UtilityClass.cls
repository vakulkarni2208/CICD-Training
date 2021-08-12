public class NV_UtilityClass {
     //--------------------------------------------------------------------------------------------------------
    //set lstNVIDIAContactsWrapper object
    // Extracting NV Contacts data based on filtered logic. Preventing to add same content type records into list. If duplicate record exist using third filter with Account Owner.
     //--------------------------------------------------------------------------------------------------------
     //--------------------------------------------------------------------------------------------------------
    //set lstNVIDIAContactsWrapper object
    // Extracting NV Contacts data based on filtered logic. Preventing to add same content type records into list. If duplicate record exist using third filter with Account Owner.
     //--------------------------------------------------------------------------------------------------------
    public static list<NVIDIAContactsProductWiseWrapper> putAllNVIDIACONTACTDetail(Contact contactDetail, set<string> allProgramTypeContentType){       
        /*Map<string,integer> mapContentTypeAndUSStates = new Map<string,integer>();
        Map<string,integer> mapContentTypeAndOtherStates = new Map<string,integer>();           
        Map<string,integer> mapContentTypeAndBlankStates = new Map<string,integer>();   
        */
        list<NVIDIAContactsProductWiseWrapper> lstNVIDIAContactsProductWiseWrapper = new list<NVIDIAContactsProductWiseWrapper>();
        map<String, list<NVContactPriorityWrapper>> mapProgramTypeContentTypeLstNVContact = new map<String, list<NVContactPriorityWrapper>>(); 
        List<NV_Contacts__c> lstNVContact =   new List<NV_Contacts__c>();
        boolean IsContenttypeFound = false;
        List<NV_Contacts__c> lstNVContactstocompare = [ SELECT Billing_Country__c, Other_States__c, Account_Owner_Name__c, US_States__c, Marketing_Manager_Contact_Number__c, Sub_Region__c,
                                                            Marketing_Manager_Email__c, Marketing_Manager_Name__c, Product_Line__c, Sales_Manager_Contact_Number__c, Program_Type__c, Sub_Program__c,
                                                            Sales_Manager_Email__c, Sales_Manager_Name__c, Sales_Manager_Name__r.Name, Support_Manager_Contact_Number__c, Region__c,
                                                            Support_Manager_Email__c, Support_Manager_Name__c, Sales_Title__c, Marketing_Title__c, Support_Title__c, ProgramType_Competency_Concatenation__c   
                                                        FROM NV_Contacts__c 
                                                        WHERE (ProgramType_Competency_Concatenation__c in :allProgramTypeContentType
                                                        AND (
                                                               Billing_Country__c = :contactDetail.Account.BillingCountry 
                                                            OR Region__c = :contactDetail.Account.Billing_Region__c
                                                            OR Sub_Region__c = :contactDetail.Account.Billing_Sub_Region__c
                                                            OR Account_Owner_Name__c =:contactDetail.Account.OwnerId
                                                        ))
                                                        ];
                                                        
        for(NV_Contacts__c objNV : lstNVContactstocompare) {
            if(objNV.Billing_Country__c == contactDetail.Account.BillingCountry
                && (objNV.US_States__c == contactDetail.Account.BillingState 
                    || objNV.Other_States__c == contactDetail.Account.BillingState )) {
                if(!mapProgramTypeContentTypeLstNVContact.containsKey(objNV.ProgramType_Competency_Concatenation__c)){
                    mapProgramTypeContentTypeLstNVContact.put(objNV.ProgramType_Competency_Concatenation__c, new list<NVContactPriorityWrapper> { new NVContactPriorityWrapper(1,objNV)});
                }else {
                    mapProgramTypeContentTypeLstNVContact.get(objNV.ProgramType_Competency_Concatenation__c).add(new NVContactPriorityWrapper(1,objNV));                                                    
                }
            } else if(objNV.Billing_Country__c == contactDetail.Account.BillingCountry) {
                if(!mapProgramTypeContentTypeLstNVContact.containsKey(objNV.ProgramType_Competency_Concatenation__c)){
                    mapProgramTypeContentTypeLstNVContact.put(objNV.ProgramType_Competency_Concatenation__c, new list<NVContactPriorityWrapper> { new NVContactPriorityWrapper(2,objNV)});
                }else {
                    mapProgramTypeContentTypeLstNVContact.get(objNV.ProgramType_Competency_Concatenation__c).add(new NVContactPriorityWrapper(2,objNV));                                                    
                }
            } else if(objNV.Region__c == contactDetail.Account.Billing_Region__c) {
                if(!mapProgramTypeContentTypeLstNVContact.containsKey(objNV.ProgramType_Competency_Concatenation__c)){
                    mapProgramTypeContentTypeLstNVContact.put(objNV.ProgramType_Competency_Concatenation__c, new list<NVContactPriorityWrapper> { new NVContactPriorityWrapper(3,objNV)});
                }else {
                    mapProgramTypeContentTypeLstNVContact.get(objNV.ProgramType_Competency_Concatenation__c).add(new NVContactPriorityWrapper(3,objNV));                                                    
                }
            } else if(objNV.Sub_Region__c == contactDetail.Account.Billing_Sub_Region__c) {
                if(!mapProgramTypeContentTypeLstNVContact.containsKey(objNV.ProgramType_Competency_Concatenation__c)){
                    mapProgramTypeContentTypeLstNVContact.put(objNV.ProgramType_Competency_Concatenation__c, new list<NVContactPriorityWrapper> { new NVContactPriorityWrapper(4,objNV)});
                }else {
                    mapProgramTypeContentTypeLstNVContact.get(objNV.ProgramType_Competency_Concatenation__c).add(new NVContactPriorityWrapper(4,objNV));                                                    
                }
            } else if(objNV.Account_Owner_Name__c == contactDetail.Account.OwnerId) {
                if(!mapProgramTypeContentTypeLstNVContact.containsKey(objNV.ProgramType_Competency_Concatenation__c)){
                    mapProgramTypeContentTypeLstNVContact.put(objNV.ProgramType_Competency_Concatenation__c, new list<NVContactPriorityWrapper> { new NVContactPriorityWrapper(5,objNV)});
                }else {
                    mapProgramTypeContentTypeLstNVContact.get(objNV.ProgramType_Competency_Concatenation__c).add(new NVContactPriorityWrapper(5,objNV));                                                    
                }
            }
        }
        
        system.debug(mapProgramTypeContentTypeLstNVContact);
        List<NV_Contacts__c> lstNVContactsToBeEmailed = new List<NV_Contacts__c>();
        for(String strProgramTypeContentType : mapProgramTypeContentTypeLstNVContact.keyset()) {
            list<NVContactPriorityWrapper> lstNVContactPriorityWrapper = mapProgramTypeContentTypeLstNVContact.get(strProgramTypeContentType);
            if(lstNVContactPriorityWrapper.size() == 1) {
                lstNVContact.add(lstNVContactPriorityWrapper[0].objNVContact);
            } else {
                NVContactPriorityWrapper tempNVContactPriorityWrapper;
                Map<Decimal, List<NV_Contacts__c>> mapPriorityListNVContact = new Map<Decimal, List<NV_Contacts__c>>();
                for(NVContactPriorityWrapper objNVContactPriorityWrapper : lstNVContactPriorityWrapper) {
                    if(tempNVContactPriorityWrapper == null) {
                        tempNVContactPriorityWrapper = objNVContactPriorityWrapper;
                    } else if(tempNVContactPriorityWrapper.decPriority > objNVContactPriorityWrapper.decPriority) {
                        tempNVContactPriorityWrapper = objNVContactPriorityWrapper;
                        mapPriorityListNVContact.clear();
                    } else if(tempNVContactPriorityWrapper.decPriority == objNVContactPriorityWrapper.decPriority) {
                        if(objNVContactPriorityWrapper.objNVContact.Account_Owner_Name__c == contactDetail.Account.OwnerId) {
                            tempNVContactPriorityWrapper = objNVContactPriorityWrapper;
                            mapPriorityListNVContact.clear();
                        } else if(tempNVContactPriorityWrapper.objNVContact.Account_Owner_Name__c == contactDetail.Account.OwnerId) {
                            mapPriorityListNVContact.clear();
                        } else {    
                            if(!mapPriorityListNVContact.containsKey(tempNVContactPriorityWrapper.decPriority)) {
                                mapPriorityListNVContact.put(tempNVContactPriorityWrapper.decPriority, new list<NV_Contacts__c> {tempNVContactPriorityWrapper.objNVContact,objNVContactPriorityWrapper.objNVContact});
                            } else {
                                mapPriorityListNVContact.get(tempNVContactPriorityWrapper.decPriority).add(objNVContactPriorityWrapper.objNVContact);
                            }
                        }
                    }
                }
                if(!mapPriorityListNVContact.isEmpty()) {
                    lstNVContactsToBeEmailed.addAll(mapPriorityListNVContact.get(tempNVContactPriorityWrapper.decPriority));
                    system.debug(lstNVContactsToBeEmailed);
                    mapPriorityListNVContact.clear();
                }
                lstNVContact.add(tempNVContactPriorityWrapper.objNVContact);
            }
            
        }
        
        map<String, list<NVIDIAContactsWrapper>> mapProductTypeLstNVContactsWrapper = new map<String, list<NVIDIAContactsWrapper>>();  
        for(NV_Contacts__c obj :lstNVContact){
            
            NVIDIAContactsWrapper objWrapNV = new NVIDIAContactsWrapper();
            objWrapNV.contentType = obj.Product_Line__c;
            objWrapNV.subProgram = obj.Sub_Program__c;
                
            objWrapNV.Marketing_Manager_Name = obj.Marketing_Manager_Name__c;
            objWrapNV.Marketing_Manager_Email = obj.Marketing_Manager_Email__c;
            objWrapNV.Marketing_Manager_Contact_Number = string.valueOf(obj.Marketing_Manager_Contact_Number__c);
                
            objWrapNV.Sales_Manager_Name = obj.Sales_Manager_Name__r.Name;
            objWrapNV.Sales_Manager_Email = obj.Sales_Manager_Email__c;
            objWrapNV.Sales_Manager_Contact_Number = string.valueOf(obj.Sales_Manager_Contact_Number__c);
                
            objWrapNV.Support_Manager_Name = obj.Support_Manager_Name__c;
            objWrapNV.Support_Manager_Email = obj.Support_Manager_Email__c;
            objWrapNV.Support_Manager_Contact_Number = string.valueOf(obj.Support_Manager_Contact_Number__c);
                
            objWrapNV.SalesManager_Title1 = obj.Sales_Title__c;
            objWrapNV.MarketingManager_Title2 = obj.Marketing_Title__c;
            objWrapNV.SupportManager_Title3 = obj.Support_Title__c;

            if(!mapProductTypeLstNVContactsWrapper.containsKey(obj.Program_Type__c)) {
                mapProductTypeLstNVContactsWrapper.put(obj.Program_Type__c, new list<NVIDIAContactsWrapper>{objWrapNV});
            } else {
                mapProductTypeLstNVContactsWrapper.get(obj.Program_Type__c).add(objWrapNV);
            }

        }
        system.debug(mapProductTypeLstNVContactsWrapper);
        for(String strProgramType : mapProductTypeLstNVContactsWrapper.keyset()) {
            lstNVIDIAContactsProductWiseWrapper.add(new NVIDIAContactsProductWiseWrapper(strProgramType.toUpperCase(), mapProductTypeLstNVContactsWrapper.get(strProgramType)));
        }
        return lstNVIDIAContactsProductWiseWrapper;
    }
  //--------------------------------------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------------------------------------
    // Wrapper class to consolidate NVIDIA CONTACT Grid details.     
    //--------------------------------------------------------------------------------------------------------
    public class NVIDIAContactsWrapper{
        @AuraEnabled public string contentType {get;set;}
        @AuraEnabled public string subProgram {get;set;}
        
        @AuraEnabled public string Marketing_Manager_Name {get;set;}
        @AuraEnabled public string Marketing_Manager_Email {get;set;}
        @AuraEnabled public string Marketing_Manager_Contact_Number {get;set;}
        
        @AuraEnabled public string Sales_Manager_Name {get;set;}
        @AuraEnabled public string Sales_Manager_Email {get;set;}
        @AuraEnabled public string Sales_Manager_Contact_Number {get;set;}
        
        @AuraEnabled public string Support_Manager_Name {get;set;}
        @AuraEnabled public string Support_Manager_Email {get;set;}
        @AuraEnabled public string Support_Manager_Contact_Number {get;set;}

        @AuraEnabled public string SalesManager_Title1 {get;set;}
        @AuraEnabled public string MarketingManager_Title2 {get;set;}
        @AuraEnabled public string SupportManager_Title3 {get;set;}
  
    }   
    
    public class NVIDIAContactsProductWiseWrapper {
        @AuraEnabled public string productType {get;set;}
        @AuraEnabled public List<NVIDIAContactsWrapper> lstNVIDIAContactsWrapper {get;set;}
        public NVIDIAContactsProductWiseWrapper(String strProductType, List<NVIDIAContactsWrapper> lstNVIDIACntsWrapper) {
            lstNVIDIAContactsWrapper = lstNVIDIACntsWrapper;
            productType = strProductType;
        }
    }
    
    public class NVContactPriorityWrapper {
        
        public NV_Contacts__c objNVContact;
        public Decimal decPriority;
        
        public NVContactPriorityWrapper(Decimal priority, NV_Contacts__c objNVCon) {
            objNVContact = objNVCon;
            decPriority = priority;
        }
    }
}