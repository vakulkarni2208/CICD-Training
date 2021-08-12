/*
 * Author: Manideep
 * Description: This is a Lead Assignment Service class.
 
  Changes:
  * 07/24/2017 - Query only Active Accounts to check LSID's by adding the field check 'Inactive__c' for Account query. 
  * 04/17/2018 - Replace Product Type 'GRID' with Product Type 'vGPU' for Leads of Individual Country Routing Rules basing on Product Types.
  * 06/13/2018 - Replace the logic based on 'Product Type' with 'Enterprise Segment'.
  * 07/05/2018 - Add Country, State AND Enterprise Segment logic for the individual Country (United States) based rules.
  * 09/10/2018 - Add ProductType, Region and Countries based rules.
  * 11/21/2018 - Add Industry based rules.
  * 02/01/2019 - Reorder and Restructure Lead Assignment Rules
                 * vGPU Routing Rules (NEW) – If the State is in the United States AND Enterprise Segment is Professional Visualization or GPU Virtualization, please route to John Li.
                 * Industry Routing Rules
                 * State Routing Rules (Update) – Remove the Enterprise Segment rules for Professional Visualization or GPU Virtualization.
  * 09/23/2019: @Manideep: SDS-1692: Add one new rule at the end of Routing Rules. If still no Owner is assigned, then assign the Lead to the 'Marketo Sync' User.
  * 02/20/2020: @Manideep: SDS-1957: US Routing Rules with States Update. Removed States from current US routing rules, so leads are routed based off of the Country 'US' and Enterprise Segment.
  * 02/20/2020: @Manideep: SDS-1878: DGX Forms Lead Routing Rule: Add new Routing rules based on Product type 'DGX', Region, Lead Origins in the custom setting and with/without Country.
  * 03/31/2020: @Manideep: SDS-2104: Remove APAC LSID and NPN Nurture Routing Rules.
  * 07/15/2020: @Manideep: SDS-2049: Reorder 'VGPU' Rules to the top.  
  * 07/15/2020: @Manideep: SDS-2276: Automotive Lead Routing basing on Product Type 'Automotive'.
  * 07/15/2020: @Manideep: SDS-2277: Embedded Lead Routing basing on Product Type 'Embedded'.
  * 07/15/2020: @Manideep: SDS-2278: Replace the Lead Routing based on 'Enterprise Segment' to 'Product Type'.
                           (But left the existing Enterprise Segment based rules as is in the code but deactivated in the custom setting, 
                            so if needed those can be turned back ON easily by simply reactivating or by adding the rows in the custom setting)
  * 09/23/2020: @Manideep: SDS-2603: Assign all Product Type 'EGX' Leads to 'EGX Lead Queue'. 
  
  *** 02/04/2021: @Manideep - SDS-2795: This Class is ready to Delete, so commenting out as of now because unable to delete due to failures in other test classes in the Org. ***
  
*/
public class LeadAssignmentService {
    
  /*
  public static List<LeadAssignmentTemplate> leadService(List<LeadAssignmentTemplate> leadAsgnTmpList) { 
        
    // 'Marketo' User from Custom Setting
    String strMktUsr = Lead_Assignment_Routing__c.getInstance('Marketo_User').Marketo_User_Username__c;
     
    List<User> mkUsr = [SELECT Id, Name, Email FROM User WHERE UserName = :strMktUsr]; // 'Marketo' User along with fields 
    system.debug('mkUsr----->'+mkUsr);
    
    //Lead RecordType Id's
    Id EntrCustRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD).getRecordTypeId(); 
    
    Set<String> leadRegionSet = new Set<String>();
    for(LeadAssignmentTemplate lat: leadAsgnTmpList) {     
        leadRegionSet.add(lat.Region);      
    }
        
    // Collect values from the Custom Setting 'Lead Assignment Routing'
    String defaultUserEmail;
    map<String, String> PTRegionMap = new map<String, String>();                                                                    // based on Region 
    map<String, map<String, String>> PTRegionCtryMap = new map<String, map<String, String>>();                                      // based on Region and Country
    map<String, map<String, map<String, String>>> VGPUPrdTypeRegCtryMap = new map<String, map<String, map<String, String>>>();      // based on VGPU - Product Type and Countries 
    map<String, String> EGXPrdTypeQueueNameMap = new map<String, String>();                                                         // based on EGX - Product Type and Lead Queue Name 
    map<String, map<String, map<String, String>>> ProdTypeRegionCountryMap = new map<String, map<String, map<String, String>>>();   // based on Product Type, Region and Countries
    //map<String, map<String, String>> ProdTypeRegionMap = new map<String, map<String, String>>();                                  // based on Product Type and Region
    map<String, map<String, map<String, map<String, String>>>> ProdTypeCmpnyTypeRegionCtryMap = new map<String, map<String, map<String, map<String, String>>>>();  // based on Product Type, Company Type and Region and Country
    map<String, map<String, map<String, String>>> ProdTypeCmpnyTypeRegionMap = new map<String, map<String, map<String, String>>>(); // based on Product Type, Company Type and Region   
    map<String, map<String, map<String, map<String, String>>>> LeadOriginPTRegionCtryMap = new map<String, map<String, map<String, map<String, String>>>>();  // based on Lead Origin, Product Type, Region and Country
    map<String, map<String, map<String, String>>> LeadOriginPTRegionMap = new map<String, map<String, map<String, String>>>();      // based on Lead Origin, Product Type and Region
    map<String, String> EMEACtryEmailMap = new map<String, String>();                                                               // based on Country (EMEA)
    map<String, String> indvCtryEmailMap = new map<String, String>();                                                               // based on Country 
    map<String, String> entrpSegIndvCtryEmailMap = new map<String, String>();                                                       // based on Country and Enterprise Segment
    map<String, String> entrpSeg2IndvCtryEmailMap = new map<String, String>();                                                      // based on Country and Enterprise Segment
    map<String, String> entrpSeg3IndvCtryEmailMap = new map<String, String>();                                                      // based on Country and Enterprise Segment
    map<String, map<String, String>> indvCtryIndustryEmailMap = new map<String, map<String, String>>();                             // based on Country and Industry
    map<String, map<String, String>> entrpSegIndvCtryStateEntrpSegEmailMap = new map<String, map<String, String>>();                // based on Country, State and Enterprise Segment
    map<String, String> entrpSegIndvCtryEntrpSegEmailMap = new map<String, String>();                                               // based on Country and Enterprise Segment
    map<String, map<String, String>> entrpSegvGPUIndvCtryStateEntrpSegEmailMap = new map<String, map<String, String>>();            // based on Country, State and Enterprise Segment (vGPU)
    map<String, String> entrpSegvGPUIndvCtryEntrpSegEmailMap = new map<String, String>();                                           // based on Country and Enterprise Segment (vGPU)
    map<String, map<String, String>> indvCtryStateEmailMap = new map<String, map<String, String>>();                                // based on Country, State and Enterprise Segment
    map<String, String> indvCtryESEmailMap = new map<String, String>();                                                             // based on Country and Enterprise Segment
    map<String, map<String, String>> indvCtryStatevGPUEmailMap = new map<String, map<String, String>>();                            // based on Country, State and Enterprise Segment (vGPU)
    map<String, String> indvCtryvGPUEmailMap = new map<String, String>();                                                           // based on Country and Enterprise Segment (vGPU)
    List<String> partnerUsersLst = new List<String>(); 
    Set<String> userEmailIdSet = new Set<String>();
    
    Map<String, Lead_Assignment_Routing__c> larCSMap = Lead_Assignment_Routing__c.getAll();
    for(Lead_Assignment_Routing__c lar: larCSMap.values()) {        
        if(string.isNotBlank(string.valueOf(lar.Category__c)) && lar.Rule_inActive__c != true) {                      
                      
           // Lead Origin, Product Type, Region and Countries
           if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.LORIGIN_PRD_TYPE_REGION) && string.isNotBlank(lar.Lead_Origin__c)
              && string.isNotBlank(lar.ProductType__c) && string.isNotBlank(lar.Region__c) && string.isNotBlank(string.valueOf(lar.UserEmail__c))) {
              
              Set<String> tempLeadOriginSet = new Set<String>();
              
              for(String str: string.valueOf(lar.Lead_Origin__c).split(';')) {
                  str = str.trim();
                  tempLeadOriginSet.add(str);
              } 
                                     
              if(!tempLeadOriginSet.isEmpty()) {        // Lead Origin Check  
                  if(string.valueOf(lar.ProductType__c).equalsIgnoreCase(COMM_Constants.LEAD_PRODUCT_TYPE_DGX)) {         // Product Type Check  
                     
                     map<String, map<String, map<String, String>>> tempPTRegCtryEmailMap = new map<String, map<String, map<String, String>>>();
                     
                     // Region 1 or Region 2 or Region 3
                     if(string.valueOf(lar.Region__c).equalsIgnoreCase(LeadAssignment_Constants.Region_NALA)
                         || string.valueOf(lar.Region__c).equalsIgnoreCase(LeadAssignment_Constants.Region_EMEAI)
                         || string.valueOf(lar.Region__c).equalsIgnoreCase(LeadAssignment_Constants.Region_APAC)) {
                        
                        map<String, map<String, String>> tempRegCtryEmailMap = new map<String, map<String, String>>();
                        map<String, map<String, String>> tempPTRegEmailMap = new map<String, map<String, String>>();
                        
                        if(string.isNotBlank(lar.Countries__c)) {      // Countries are NOT Blank
                           map<String, String> tempMapCtryEmail = new map<String, String>();
                           for(String strCtry: string.valueOf(lar.Countries__c).split(';')) {
                               strCtry = strCtry.trim();
                               tempMapCtryEmail.put(strCtry, lar.UserEmail__c);
                               userEmailIdSet.add(string.valueOf(lar.UserEmail__c)); 
                           }  
                           tempRegCtryEmailMap.put(lar.Region__c, tempMapCtryEmail);
                           tempPTRegCtryEmailMap.put(lar.ProductType__c, tempRegCtryEmailMap);
                        } 
                        else {                                         // Countries are Blank   
                           map<String, String> tempRegEmailMap = new map<String, String>();
                           tempRegEmailMap.put(lar.Region__c, lar.UserEmail__c); 
                           tempPTRegEmailMap.put(lar.ProductType__c, tempRegEmailMap);
                           userEmailIdSet.add(string.valueOf(lar.UserEmail__c));                       
                        }      
                        
                        for(String LdOrgStr: tempLeadOriginSet) {
                            if(!tempPTRegCtryEmailMap.isEmpty()) {
                                LeadOriginPTRegionCtryMap.put(LdOrgStr, tempPTRegCtryEmailMap);   // Countries are NOT Blank
                            } else if(!tempPTRegEmailMap.isEmpty()) {
                                LeadOriginPTRegionMap.put(LdOrgStr, tempPTRegEmailMap);          // Countries are Blank   
                            }      
                        } 
                     
                     } // end of Region check
                     
                     system.debug('LeadOriginPTRegionCtryMap Final---->'+LeadOriginPTRegionMap);
                     system.debug('LeadOriginPTRegionMap Final-------->'+LeadOriginPTRegionMap);     
                                          
                  } // end of Product Type check
                                              
              } // end of Lead Origin Check 
           } // end of Lead Origin, Product Type, Region and Countries
                                   
           // Product Type 'Quadro', Region and Countries
           if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.PRD_TYPE_REGION) && string.isNotBlank(string.valueOf(lar.UserEmail__c))) {
              if(string.isNotBlank(lar.ProductType__c) && string.valueOf(lar.ProductType__c).equalsIgnoreCase(COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO)) {
                 // Region1
                 if(string.isNotBlank(lar.Region__c) && string.valueOf(lar.Region__c).equalsIgnoreCase(LeadAssignment_Constants.Region_NALA)) {
                    if(string.isNotBlank(lar.Countries__c)) {      // Countries are NOT Blank
                       map<String, String> tempMap = new map<String, String>();
                       for(String str: string.valueOf(lar.Countries__c).split(';')) {
                           str = str.trim();
                           tempMap.put(str, lar.UserEmail__c);
                           userEmailIdSet.add(string.valueOf(lar.UserEmail__c)); 
                       }  
                       PTRegionCtryMap.put(lar.Region__c, tempMap);
                    } 
                    else {                                         // Countries are Blank   
                       PTRegionMap.put(lar.Region__c, lar.UserEmail__c); 
                       userEmailIdSet.add(string.valueOf(lar.UserEmail__c));                       
                    }      
                 } 
                 // Region 2
                 else if(string.isNotBlank(lar.Region__c) && string.valueOf(lar.Region__c).equalsIgnoreCase(LeadAssignment_Constants.Region_EMEAI)) {
                    if(string.isNotBlank(lar.Countries__c)) {      // Countries are NOT Blank
                       map<String, String> tempMap = new map<String, String>();
                       for(String str: string.valueOf(lar.Countries__c).split(';')) {
                           str = str.trim();
                           tempMap.put(str, lar.UserEmail__c);
                           userEmailIdSet.add(string.valueOf(lar.UserEmail__c));
                       }  
                       PTRegionCtryMap.put(lar.Region__c, tempMap);
                    } 
                    else {                                         // Countries are Blank
                       PTRegionMap.put(lar.Region__c, lar.UserEmail__c);
                       userEmailIdSet.add(string.valueOf(lar.UserEmail__c));
                    }      
                 }
                 // Region 3 
                 else if(string.isNotBlank(lar.Region__c) && string.valueOf(lar.Region__c).equalsIgnoreCase(LeadAssignment_Constants.Region_APAC)) {
                    if(string.isNotBlank(lar.Countries__c)) {      // Countries are NOT Blank
                       map<String, String> tempMap = new map<String, String>();
                       for(String str: string.valueOf(lar.Countries__c).split(';')) {
                           str = str.trim();
                           tempMap.put(str, lar.UserEmail__c);
                           userEmailIdSet.add(string.valueOf(lar.UserEmail__c));
                       }  
                       PTRegionCtryMap.put(lar.Region__c, tempMap);
                    } 
                    else {                                         // Countries are Blank
                       PTRegionMap.put(lar.Region__c, lar.UserEmail__c);
                       userEmailIdSet.add(string.valueOf(lar.UserEmail__c));
                    }      
                 }
              }              
              
           }  // end of ProductType 'Quadro', Region and Countries 
           
           // Product Type is 'vGPU', Region and Country
           if(String.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.VGPU_PROD_TYPE_REGION_COUNTRY) && string.isNotBlank(lar.ProductType__c)
              && string.isNotBlank(lar.Region__c) && string.isNotBlank(lar.Countries__c) && string.isNotBlank(string.valueOf(lar.UserEmail__c))) {  
                
                map<string, string> tempMap = new map<string, string>();
                map<string, map<string, string>> tempMap2 = new map<string, map<string, string>>();                                
                
                for(String str: string.valueOf(lar.Countries__c).split(';')) {                 
                   str = str.trim();
                    tempMap.put(str, string.valueOf(lar.UserEmail__c));
                    tempMap2.put(lar.Region__c, tempMap);                   
                    // check if the map has key already and accordingly add values without overwriting existing values
                    if(VGPUPrdTypeRegCtryMap.isEmpty() || !VGPUPrdTypeRegCtryMap.containsKey(lar.ProductType__c)) {
                        VGPUPrdTypeRegCtryMap.put(lar.ProductType__c, tempMap2);
                    } else if(VGPUPrdTypeRegCtryMap.containsKey(lar.ProductType__c)) {
                        if(VGPUPrdTypeRegCtryMap.get(lar.ProductType__c).containsKey(lar.Region__c)) { 
                           VGPUPrdTypeRegCtryMap.get(lar.ProductType__c).get(lar.Region__c).putAll(tempMap);   
                        } else {
                           VGPUPrdTypeRegCtryMap.get(lar.ProductType__c).putAll(tempMap2);
                        }
                    }
                    tempMap.clear();
                    tempMap2.clear();  
                }                                
                userEmailIdSet.add(string.valueOf(lar.UserEmail__c));    
           }
                      
           // Product Type 'example - Embedded, Quadro etc.,', Region and Country
           if(String.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.PROD_TYPE_REGION_COUNTRY) && string.isNotBlank(lar.ProductType__c)
              && string.valueOf(lar.ProductType__c) != 'EGX'
              && string.isNotBlank(lar.Region__c) && string.isNotBlank(lar.Countries__c) && string.isNotBlank(string.valueOf(lar.UserEmail__c))) { 
                
                map<string, string> tempMap = new map<string, string>();
                map<string, map<string, string>> tempMap2 = new map<string, map<string, string>>();
 
                for(String str: string.valueOf(lar.Countries__c).split(';')) {
                   str = str.trim();
                    tempMap.put(str, string.valueOf(lar.UserEmail__c));
                    tempMap2.put(lar.Region__c, tempMap);
                    //ProdTypeRegionCountryMap.put(lar.ProductType__c, tempMap2);
                    // check if the map has key already and accordingly add values without overwriting existing values
                    if(ProdTypeRegionCountryMap.isEmpty() || !ProdTypeRegionCountryMap.containsKey(lar.ProductType__c)) {
                        ProdTypeRegionCountryMap.put(lar.ProductType__c, tempMap2);
                    } else if(ProdTypeRegionCountryMap.containsKey(lar.ProductType__c)) {
                        if(ProdTypeRegionCountryMap.get(lar.ProductType__c).containsKey(lar.Region__c)) { 
                           ProdTypeRegionCountryMap.get(lar.ProductType__c).get(lar.Region__c).putAll(tempMap);   
                        } else {
                           ProdTypeRegionCountryMap.get(lar.ProductType__c).putAll(tempMap2);
                        }
                    }
                    tempMap.clear();
                    tempMap2.clear();
                }    
                userEmailIdSet.add(string.valueOf(lar.UserEmail__c));    
           }
           
           // Product Type is 'EGX' only, Region and Country
           if(String.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.PROD_TYPE_REGION_COUNTRY) && string.isNotBlank(lar.ProductType__c)
              && string.valueOf(lar.ProductType__c) == 'EGX'
              && string.isNotBlank(lar.Region__c) && string.isNotBlank(lar.Countries__c)) { 
                 
              EGXPrdTypeQueueNameMap.put(string.valueOf(lar.ProductType__c), 'EGX_Lead_Queue');          
           }           
           
           // Product Type 'Automotive', Company Type, Region and Country
           if(String.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.PROD_TYPE_CMPY_TYPE_REGION_COUNTRY) 
              && string.isNotBlank(lar.ProductType__c) && string.isNotBlank(lar.Company_Type__c) && string.isNotBlank(lar.Region__c) 
              && string.isNotBlank(lar.Countries__c) && string.isNotBlank(string.valueOf(lar.UserEmail__c))) { 
                
                map<string, string> tempMap1 = new map<string, string>();
                map<string, map<string, string>> tempMap2 = new map<string, map<string, string>>();
                map<string, map<string, map<string, string>>> tempMap3 = new map<string, map<string, map<string, string>>>();
                
                for(String str: string.valueOf(lar.Countries__c).split(';')) {
                   str = str.trim();
                    tempMap1.put(str, string.valueOf(lar.UserEmail__c));
                    tempMap2.put(lar.Region__c, tempMap1);
                    tempMap3.put(lar.Company_Type__c, tempMap2);
                    //ProdTypeCmpnyTypeRegionCtryMap.put(lar.ProductType__c, tempMap3);  
                    if(ProdTypeCmpnyTypeRegionCtryMap.isEmpty() || !ProdTypeCmpnyTypeRegionCtryMap.containsKey(lar.ProductType__c)) {
                        ProdTypeCmpnyTypeRegionCtryMap.put(lar.ProductType__c, tempMap3);
                    } else if(ProdTypeCmpnyTypeRegionCtryMap.containsKey(lar.ProductType__c)) {
                        if(ProdTypeCmpnyTypeRegionCtryMap.get(lar.ProductType__c).containsKey(lar.Company_Type__c)) {
                           if(ProdTypeCmpnyTypeRegionCtryMap.get(lar.ProductType__c).get(lar.Company_Type__c).containsKey(lar.Region__c)) {
                             ProdTypeCmpnyTypeRegionCtryMap.get(lar.ProductType__c).get(lar.Company_Type__c).get(lar.Region__c).putAll(tempMap1);
                           } else {
                             ProdTypeCmpnyTypeRegionCtryMap.get(lar.ProductType__c).get(lar.Company_Type__c).putAll(tempMap2);
                           } 
                        } else {
                           ProdTypeCmpnyTypeRegionCtryMap.get(lar.ProductType__c).putAll(tempMap3);
                        }
                    }
                    tempMap1.clear();
                    tempMap2.clear();
                    tempMap3.clear();
               }
               userEmailIdSet.add(string.valueOf(lar.UserEmail__c));  
           }    
           
           // Product Type 'Automotive', Company Type and Region but the Country is Blank 
           if(String.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.PROD_TYPE_CMPY_TYPE_REGION) 
              && string.isNotBlank(lar.ProductType__c) && string.isNotBlank(lar.Company_Type__c) && string.isNotBlank(lar.Region__c) 
              && string.isBlank(lar.Countries__c) && string.isNotBlank(string.valueOf(lar.UserEmail__c))) { 
                
                map<string, string> tempMap1 = new map<string, string>();
                map<string, map<string, string>> tempMap2 = new map<string, map<string, string>>();
                
                for(string str: string.valueOf(lar.Region__c).split(';')) {
                     str = str.trim();
                     tempMap1.put(str, string.valueOf(lar.UserEmail__c));
                    tempMap2.put(lar.Company_Type__c, tempMap1);
                    //ProdTypeCmpnyTypeRegionMap.put(lar.ProductType__c, tempMap2);    
                    // check if the map has key already and accordingly add values without overwriting existing values
                    if(ProdTypeCmpnyTypeRegionMap.isEmpty() || !ProdTypeCmpnyTypeRegionMap.containsKey(lar.ProductType__c)) {
                        ProdTypeCmpnyTypeRegionMap.put(lar.ProductType__c, tempMap2);
                    } else if(ProdTypeCmpnyTypeRegionMap.containsKey(lar.ProductType__c)) {
                        if(ProdTypeCmpnyTypeRegionMap.get(lar.ProductType__c).containsKey(lar.Company_Type__c)) { 
                           ProdTypeCmpnyTypeRegionMap.get(lar.ProductType__c).get(lar.Company_Type__c).putAll(tempMap1);   
                        } else {
                           ProdTypeCmpnyTypeRegionMap.get(lar.ProductType__c).putAll(tempMap2);
                        }
                    }
                    tempMap1.clear();
                    tempMap2.clear();
                }         
                userEmailIdSet.add(string.valueOf(lar.UserEmail__c));
           }
             
           if(string.isNotBlank(string.valueOf(lar.Countries__c)) && string.isNotBlank(string.valueOf(lar.UserEmail__c))) {
              string userEmailId = string.valueOf(lar.UserEmail__c);
              userEmailIdSet.add(userEmailId);            
              // EMEA NSC Countries
              if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.EMEA_NSC)) {
                 for(String str: string.valueOf(lar.Countries__c).split(';')) {
                     str = str.trim();
                     EMEACtryEmailMap.put(str, userEmailId);
                 }          
              }         
              // Individual Country Routing - based on Enterprise Segment
              else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.IndCtryRouting_EntrpSeg)) {
                 for(String str: string.valueOf(lar.Countries__c).split(';')) {
                     str = str.trim();
                     entrpSegIndvCtryEmailMap.put(str, userEmailId);
                     for(String emailStr: userEmailid.split(';')) {
                         userEmailIdSet.add(emailStr); // add Email Id's to this Set by splitting
                     }
                 }          
              } 
              // Individual Country Routing version 2 - based on Enterprise Segment
              else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.IndCtryRouting2_EntrpSeg)) {
                 for(String str: string.valueOf(lar.Countries__c).split(';')) {
                     str = str.trim();
                     entrpSeg2IndvCtryEmailMap.put(str, userEmailId);
                     for(String emailStr: userEmailid.split(';')) {
                         userEmailIdSet.add(emailStr); // add Email Id's to this Set by splitting
                     }
                 }
              } 
              // Individual Country Routing version 3 - based on Enterprise Segment
              else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.IndCtryRouting3_EntrpSeg)) {
                 for(String str: string.valueOf(lar.Countries__c).split(';')) {
                     str = str.trim();
                     entrpSeg3IndvCtryEmailMap.put(str, userEmailId);
                     for(String emailStr: userEmailid.split(';')) {
                         userEmailIdSet.add(emailStr); // add Email Id's to this Set by splitting
                     }
                 }
              } 
              // Individual Country Routing - NOT based on Enterprise Segment
              else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.IndCtryRouting_NonPrdType)) {
                 for(String str: string.valueOf(lar.Countries__c).split(';')) {
                     str = str.trim();
                     indvCtryEmailMap.put(str, lar.UserEmail__c);
                 }              
              }
              // Individual Country Routing - based on Country, State and Enterprise Segment (vGPU) - 'Professional Visualization' or 'GPU Virtualization' 
              else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.IndCtryRouting_States_EntrpSeg_vGPU)) {
                 // looping over Countries
                 for(String strCtry: string.valueOf(lar.Countries__c).split(';')) {
                     strCtry = strCtry.trim();
                     map<String, String> stateUserEmailMap = new map<String, String>();
                     // looping over States
                     for(String strState: string.valueOf(lar.States__c).split(';')) {
                         stateUserEmailMap.put(strState, userEmailId);                          
                         if(entrpSegvGPUIndvCtryStateEntrpSegEmailMap.containsKey(strCtry)) {
                            if(!entrpSegvGPUIndvCtryStateEntrpSegEmailMap.get(strCtry).isEmpty()) 
                                entrpSegvGPUIndvCtryStateEntrpSegEmailMap.get(strCtry).putAll(stateUserEmailMap);
                         } else {
                            entrpSegvGPUIndvCtryStateEntrpSegEmailMap.put(strCtry, stateUserEmailMap);
                         }
                                             
                         for(String emailStr: userEmailid.split(';')) {
                             userEmailIdSet.add(emailStr); // add Email Id's to this Set by splitting
                         }
                     }
                 }
              } 
              // Individual Country Routing - based on Country and Enterprise Segment (vGPU) - 'Professional Visualization' or 'GPU Virtualization' 
              else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.IndCtryRouting_Country_EntrpSeg_vGPU)) {
                 // looping over Countries
                 for(String strCtry: string.valueOf(lar.Countries__c).split(';')) {
                     strCtry = strCtry.trim();       
                     entrpSegvGPUIndvCtryEntrpSegEmailMap.put(strCtry, userEmailId);                       
                     for(String emailStr: userEmailid.split(';')) {
                         userEmailIdSet.add(emailStr); // add Email Id's to this Set by splitting
                     }
                 }
              }               
              //Individual Country Routing - based on Industry
              else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.IndCtryRouting_Industry)) {
                 // looping over Countries
                 for(String strCtry: string.valueOf(lar.Countries__c).split(';')) {
                     strCtry = strCtry.trim();
                     map<String, String> industryUserEmailMap = new map<String, String>();
                     // looping over Industry
                     for(String strIndustry: string.valueOf(lar.Industry__c).split(';')) {
                         industryUserEmailMap.put(strIndustry, userEmailId);
                         if(indvCtryIndustryEmailMap.containsKey(strCtry)) {
                            if(!indvCtryIndustryEmailMap.get(strCtry).isEmpty()) 
                                indvCtryIndustryEmailMap.get(strCtry).putAll(industryUserEmailMap);
                         } else {
                             indvCtryIndustryEmailMap.put(strCtry, industryUserEmailMap);
                         }
                         
                         for(String emailStr: userEmailid.split(';')) {
                             userEmailIdSet.add(emailStr); // add Email Id's to this Set by splitting
                         } 
                     }
                 }
              }
              
              // Individual Country Routing - based on Country, State and Enterprise Segment
              else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.IndCtryRouting_States_EntrpSeg)) {
                 // looping over Countries
                 for(String strCtry: string.valueOf(lar.Countries__c).split(';')) {
                     strCtry = strCtry.trim();
                     map<String, String> stateUserEmailMap = new map<String, String>();
                     // looping over States
                     for(String strState: string.valueOf(lar.States__c).split(';')) {
                         stateUserEmailMap.put(strState, userEmailId);                          
                         if(entrpSegIndvCtryStateEntrpSegEmailMap.containsKey(strCtry)) {
                            if(!entrpSegIndvCtryStateEntrpSegEmailMap.get(strCtry).isEmpty()) 
                                entrpSegIndvCtryStateEntrpSegEmailMap.get(strCtry).putAll(stateUserEmailMap);
                            // else 
                                 entrpSegIndvCtryStateEntrpSegEmailMap.put(strCtry, stateUserEmailMap); //  
                         } else {
                            entrpSegIndvCtryStateEntrpSegEmailMap.put(strCtry, stateUserEmailMap);
                         }
                                             
                         for(String emailStr: userEmailid.split(';')) {
                             userEmailIdSet.add(emailStr); // add Email Id's to this Set by splitting
                         }
                     }
                 }
              } 
              
              // Date: 02/20/2020
              // Individual Country Routing - based on Country and Enterprise Segment
              else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.IndCtryRouting_Country_EntrpSeg)) {
                 // looping over Countries
                 for(String strCtry: string.valueOf(lar.Countries__c).split(';')) {
                     strCtry = strCtry.trim();
                     entrpSegIndvCtryEntrpSegEmailMap.put(strCtry, userEmailId);
                 }                             
                 
                 for(String emailStr: userEmailid.split(';')) {
                     userEmailIdSet.add(emailStr); // add Email Id's to this Set by splitting
                 }
              } 
              
           }   
           // NPN Nurture - Partner Lead Owners
           else if(string.isNotBlank(string.valueOf(lar.Partner_Lead_Owner__c))) {
              for(String str: string.valueOf(lar.Partner_Lead_Owner__c).split(';')) {
                  str = str.trim();
                  partnerUsersLst.add(str);
              }
           } 
           // Default User
           else if(string.valueOf(lar.Category__c).equalsIgnoreCase(LeadAssignment_Constants.Default_User)) {   
              String str = string.valueOf(lar.UserEmail__c).trim();
              defaultUserEmail = str; 
              userEmailIdSet.add(str);
           }   
        
        } // end of Category empty check            
    } // end of looping over Custom setting 
            
    system.debug('PTRegionCtryMap------>'+PTRegionCtryMap);
    system.debug('PTRegionMap------>'+PTRegionMap); 
    system.debug('VGPUPrdTypeRegCtryMap----->'+VGPUPrdTypeRegCtryMap);
    system.debug('ProdTypeRegionCountryMap---->'+ProdTypeRegionCountryMap);
    system.debug('ProdTypeCmpnyTypeRegionCtryMap----->'+ProdTypeCmpnyTypeRegionCtryMap);
    system.debug('ProdTypeCmpnyTypeRegionMap----->'+ProdTypeCmpnyTypeRegionMap);
    system.debug('userEmailIdSet------>'+userEmailIdSet);
            
    // Map of Users with User fields
    Map<string, User> userEmailMap = new Map<string, User>();
    for(User usr: [SELECT Id, Name, FirstName, LastName, Email FROM User WHERE Email IN :userEmailIdSet AND IsActive = true]) {
        userEmailMap.put(usr.Email, usr);
    } 
    system.debug('userEmailMap------>'+userEmailMap);  
    
    // Map of Queues 
    map<string, Group> grpQueueMap = new map<string, Group>();
    for(Group grpQue: [select Id, DeveloperName from Group where Type = 'Queue' AND DeveloperName = 'EGX_Lead_Queue']) {
        grpQueueMap.put(grpQue.DeveloperName, grpQue);
        system.debug('grpQueueMap---->'+grpQueueMap); 
    }                                                                                  
                
    for(LeadAssignmentTemplate lat: leadAsgnTmpList) {
                    
        boolean assignedOwner = false;
                
        //Date: 07/15/2020
        // Assign Owner by processing Product Type 'VGPU' and 'Enterprise Customer Lead' RecordType 
        if(!assignedOwner && (lat.RecordTypeId == EntrCustRT) && string.isNotBlank(lat.ProductType) 
            // && string.valueOf(lat.ProductType).equalsIgnoreCase(COMM_Constants.LEAD_PRODUCT_TYPE_vGPU) 
            && string.isNotBlank(lat.Region) && string.isNotBlank(lat.Country) && VGPUPrdTypeRegCtryMap.containsKey(lat.ProductType) 
            && VGPUPrdTypeRegCtryMap.get(lat.ProductType).containsKey(lat.Region)
            && VGPUPrdTypeRegCtryMap.get(lat.ProductType).get(lat.Region).containsKey(lat.Country)
            && userEmailMap.containsKey(VGPUPrdTypeRegCtryMap.get(lat.ProductType).get(lat.Region).get(lat.Country))) {                 
            
            lat.ownerId = userEmailMap.get(VGPUPrdTypeRegCtryMap.get(lat.ProductType).get(lat.Region).get(lat.Country)).Id;
            assignedOwner = true;
        }
        
        // Date: 9/10/2018
        // New Rules with Product Type 'Quadro' and 'Enterprise Customer Lead' RecordType
        if(!assignedOwner && (lat.RecordTypeId == EntrCustRT) && string.isNotBlank(lat.ProductType) && string.valueOf(lat.ProductType).equalsIgnoreCase(COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO) && string.isNotBlank(lat.Region)) {
            if(PTRegionCtryMap.containsKey(lat.Region) && string.isNotBlank(lat.Country) && PTRegionCtryMap.get(lat.Region).containsKey(lat.Country) && userEmailMap.containsKey(PTRegionCtryMap.get(lat.Region).get(lat.Country))) {   
               lat.ownerId = userEmailMap.get(PTRegionCtryMap.get(lat.Region).get(lat.Country)).Id;
               assignedOwner = true;
            } else if(PTRegionMap.containsKey(lat.Region) && userEmailMap.containsKey(PTRegionMap.get(lat.Region))) {
               lat.ownerId = userEmailMap.get(PTRegionMap.get(lat.Region)).Id;
               assignedOwner = true;
            }
        }
        
        //Date: 09/23/2020
        // Assign owner by processing Product Type 'EGX' and 'Enterprise Customer Lead' RecordType
        if(!assignedOwner && (lat.RecordTypeId == EntrCustRT) && string.isNotBlank(lat.ProductType)
            && string.isNotBlank(lat.Region) && string.isNotBlank(lat.Country)
            && !EGXPrdTypeQueueNameMap.isEmpty()
            && EGXPrdTypeQueueNameMap.containsKey(string.valueOf(lat.ProductType))) {
            
            lat.ownerId = grpQueueMap.get(EGXPrdTypeQueueNameMap.get(lat.ProductType)).Id;
            assignedOwner = true;   
        }  
                
        //Date: 07/15/2020
        // Assign Owner by processing Product Type 'example - Embedded, Deep Learning (DGX), etc.,', Region and Countries and 'Enterprise Customer Lead' RecordType
        if(!assignedOwner && (lat.RecordTypeId == EntrCustRT) && string.isNotBlank(lat.ProductType) && string.isNotBlank(lat.Region) && string.isNotBlank(lat.Country)
            && ProdTypeRegionCountryMap.containsKey(lat.ProductType) && ProdTypeRegionCountryMap.get(lat.ProductType).containsKey(lat.Region)
            && ProdTypeRegionCountryMap.get(lat.ProductType).get(lat.Region).containsKey(lat.Country)
            && userEmailMap.containsKey(ProdTypeRegionCountryMap.get(lat.ProductType).get(lat.Region).get(lat.Country))) {
                              
            lat.ownerId = userEmailMap.get(ProdTypeRegionCountryMap.get(lat.ProductType).get(lat.Region).get(lat.Country)).Id;
            assignedOwner = true;
        }
                
        //Date: 07/15/2020
        // Assign Owner by processing Product Type 'example - Automotive', Company Type, Region and Country 
        if(!assignedOwner && (lat.RecordTypeId == EntrCustRT) && string.isNotBlank(lat.ProductType) && string.isNotBlank(lat.CompanyType) && string.isNotBlank(lat.Region) 
            && string.isNotBlank(lat.Country)
            && ProdTypeCmpnyTypeRegionCtryMap.containsKey(lat.ProductType) 
            && ProdTypeCmpnyTypeRegionCtryMap.get(lat.ProductType).containsKey(lat.CompanyType)
            && ProdTypeCmpnyTypeRegionCtryMap.get(lat.ProductType).get(lat.CompanyType).containsKey(lat.Region)
            && ProdTypeCmpnyTypeRegionCtryMap.get(lat.ProductType).get(lat.CompanyType).get(lat.Region).containsKey(lat.Country)
            && userEmailMap.containsKey(ProdTypeCmpnyTypeRegionCtryMap.get(lat.ProductType).get(lat.CompanyType).get(lat.Region).get(lat.Country))) {
                              
            lat.ownerId = userEmailMap.get(ProdTypeCmpnyTypeRegionCtryMap.get(lat.ProductType).get(lat.CompanyType).get(lat.Region).get(lat.Country)).Id;
            assignedOwner = true;
        }
           
        //Date: 07/15/2020
        // Assign Owner by processing Product Type 'example - Automotive', Company Type and Region 
        if(!assignedOwner && (lat.RecordTypeId == EntrCustRT) && string.isNotBlank(lat.ProductType) && string.isNotBlank(lat.CompanyType) && string.isNotBlank(lat.Region)
            && ProdTypeCmpnyTypeRegionMap.containsKey(lat.ProductType) 
            && ProdTypeCmpnyTypeRegionMap.get(lat.ProductType).containsKey(lat.CompanyType)
            && ProdTypeCmpnyTypeRegionMap.get(lat.ProductType).get(lat.CompanyType).containsKey(lat.Region)
            && userEmailMap.containsKey(ProdTypeCmpnyTypeRegionMap.get(lat.ProductType).get(lat.CompanyType).get(lat.Region))) {
                              
             lat.ownerId = userEmailMap.get(ProdTypeCmpnyTypeRegionMap.get(lat.ProductType).get(lat.CompanyType).get(lat.Region)).Id;
             assignedOwner = true;
        }
                        
        if(!assignedOwner) {                                                                          
                      
           // Rule 5: To EMEA NSC Based on Territories           
           if(!assignedOwner && !userEmailMap.isEmpty() && string.isNotBlank(lat.Country) && !EMEACtryEmailMap.isEmpty() && EMEACtryEmailMap.containsKey(lat.Country)
               && userEmailMap.containsKey(EMEACtryEmailMap.get(lat.Country))) {  
                  lat.OwnerId = userEmailMap.get(EMEACtryEmailMap.get(lat.Country)).Id;
                  assignedOwner = true;          
           }
              
           // Rule 6: Individual Country Routing           
           // Prepare the Countries based on Enterprise Segment - 1.GPU Virtualization or Professional Visualization 2.Accelerated Computing, High Performance Computing, or Deep Learning 3.All Others
           for(String strg: entrpSegIndvCtryEmailMap.keySet()) {
               list<string> usrEmailList = new list<string>();  
               //split the UserEmail Id's basing on Enterprise Segments
               for(String strEmail: entrpSegIndvCtryEmailMap.get(strg).split(';')) {
                   usrEmailList.add(strEmail);
               }
               if(string.isNotBlank(string.valueOf(lat.EnterpriseSegment))) {
                  if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV) || string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV))
                     indvCtryEmailMap.put(strg, usrEmailList[0]);
                  else if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_HPC) || string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_DL))          
                     indvCtryEmailMap.put(strg, usrEmailList[1]);
                  else
                     indvCtryEmailMap.put(strg, usrEmailList[2]);
               }
               else if(string.isBlank(string.valueOf(lat.EnterpriseSegment))) {
                     indvCtryEmailMap.put(strg, usrEmailList[2]);
               }      
           }
           
           // Prepare the Countries 2 based on Enterprise Segment - 1.GPU Virtualization or Professional Visualization 2.Accelerated Computing, High Performance Computing, or Deep Learning 3.All Others
           for(String strg: entrpSeg2IndvCtryEmailMap.keySet()) {
               list<string> usrEmailList = new list<string>();  
               //split the UserEmail Id's basing on Enterprise Segments
               for(String strEmail: entrpSeg2IndvCtryEmailMap.get(strg).split(';')) {
                   usrEmailList.add(strEmail);
               }
               if(string.isNotBlank(string.valueOf(lat.EnterpriseSegment))) {
                  if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV) || string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV))
                     indvCtryEmailMap.put(strg, usrEmailList[0]);
                  else if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_HPC) || string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_DL))          
                     indvCtryEmailMap.put(strg, usrEmailList[1]);
                  else
                     indvCtryEmailMap.put(strg, usrEmailList[2]);
               } 
               else if(string.isBlank(string.valueOf(lat.EnterpriseSegment))) {
                     indvCtryEmailMap.put(strg, usrEmailList[2]);
               }    
           } 
           
           // Prepare the Countries 3 based on Enterprise Segment - 1.GPU Virtualization or Professional Visualization 2.Deep Learning 3.Accelerated Computing, High Performance Computing 4.All Others
           for(String strg: entrpSeg3IndvCtryEmailMap.keySet()) {
               list<string> usrEmailList = new list<string>();  
               //split the UserEmail Id's basing on Enterprise Segments
               for(String strEmail: entrpSeg3IndvCtryEmailMap.get(strg).split(';')) {
                   usrEmailList.add(strEmail);
               }
               if(string.isNotBlank(string.valueOf(lat.EnterpriseSegment))) {
                  if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV) || string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV))
                     indvCtryEmailMap.put(strg, usrEmailList[0]);
                  else if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_DL))          
                     indvCtryEmailMap.put(strg, usrEmailList[1]);
                  else if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_HPC))          
                     indvCtryEmailMap.put(strg, usrEmailList[2]);
                  else
                     indvCtryEmailMap.put(strg, usrEmailList[3]);
               } 
               else if(string.isBlank(string.valueOf(lat.EnterpriseSegment))) {
                     indvCtryEmailMap.put(strg, usrEmailList[3]);
               }     
           }
           
           // Prepare the Countries with States based on Enterprise Segment (vGPU) - 'Professional Visualization' or 'GPU Virtualization'       
           for(String strg: entrpSegvGPUIndvCtryStateEntrpSegEmailMap.keySet()) {      
               // loop through the States
               for(String strState: entrpSegvGPUIndvCtryStateEntrpSegEmailMap.get(strg).keySet()) {
                   list<string> usrEmailList = new list<string>(); 
                   map<String, String> tempindvCtryStatevGPUEmailMap = new map<String, String>();
                   //split the UserEmail Id's basing on Enterprise Segments
                   for(String strEmail: entrpSegvGPUIndvCtryStateEntrpSegEmailMap.get(strg).get(strState).split(';')) {
                       usrEmailList.add(strEmail);
                   }
                   if(string.isNotBlank(string.valueOf(lat.EnterpriseSegment))) {
                      if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV) || string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV)) {
                         tempindvCtryStatevGPUEmailMap.put(strState, usrEmailList[0]);  // 1st Value in the User Email of Custom Setting.                        
                         if(!indvCtryStatevGPUEmailMap.isEmpty()) 
                             indvCtryStatevGPUEmailMap.get(strg).putAll(tempindvCtryStatevGPUEmailMap);
                         else 
                             indvCtryStatevGPUEmailMap.put(strg, tempindvCtryStatevGPUEmailMap);  
                      } 
                   } 
               }
           }  
           
           // Prepare the Countries with with Enterprise Segment (vGPU) - 'Professional Visualization' or 'GPU Virtualization'       
           for(String strgCtry: entrpSegvGPUIndvCtryEntrpSegEmailMap.keySet()) {      
               list<string> usrEmailList = new list<string>(); 
               //split the UserEmail Id's basing on Enterprise Segments
               for(String strEmail: entrpSegvGPUIndvCtryEntrpSegEmailMap.get(strgCtry).split(';')) {
                   usrEmailList.add(strEmail);
               }
               if(string.isNotBlank(string.valueOf(lat.EnterpriseSegment))) {
                  if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV) || string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV)) {
                     indvCtryvGPUEmailMap.put(strgCtry, usrEmailList[0]);  // 1st Value in the User Email of Custom Setting.                               
                  } 
               }
           }  
           
           // Prepare the Countries based on Industry
           for(String strg: indvCtryIndustryEmailMap.keySet()) {
               // loop through the Industries
               for(String strIndsty: indvCtryIndustryEmailMap.get(strg).keySet()) {
                   list<string> usrEmailList = new list<string>(); 
                   map<String, String> tempIndCtryIndstyEmailMap = new map<String, String>();
                   //split the UserEmail Id's basing on Industry
                   for(String strEmail: indvCtryIndustryEmailMap.get(strg).get(strIndsty).split(';')) {
                       usrEmailList.add(strEmail);
                   }
                   if(string.isNotBlank(string.valueOf(lat.Industry))) {
                      if(string.valueOf(lat.Industry).equalsIgnoreCase(COMM_Constants.LEAD_Industry_HC)) {
                         tempIndCtryIndstyEmailMap.put(strIndsty, usrEmailList[0]);
                      } 
                      else if(string.valueOf(lat.Industry).equalsIgnoreCase(COMM_Constants.LEAD_Industry_HRED)) {
                         tempIndCtryIndstyEmailMap.put(strIndsty, usrEmailList[0]);
                      }
                      else if(string.valueOf(lat.Industry).equalsIgnoreCase(COMM_Constants.LEAD_Industry_ME) || string.valueOf(lat.Industry).equalsIgnoreCase(COMM_Constants.LEAD_Industry_MFG) 
                              || string.valueOf(lat.Industry).equalsIgnoreCase(COMM_Constants.LEAD_Industry_TCS) || string.valueOf(lat.Industry).equalsIgnoreCase(COMM_Constants.LEAD_Industry_RET)) {
                         tempIndCtryIndstyEmailMap.put(strIndsty, usrEmailList[0]); 
                      }
                      
                      indvCtryIndustryEmailMap.get(strg).putAll(tempIndCtryIndstyEmailMap);
                   }
               }
           }
           
           // Prepare the Countries with States based on Enterprise Segment - 1.High Performance Computing or Deep Learning 2. All Others       
           for(String strg: entrpSegIndvCtryStateEntrpSegEmailMap.keySet()) {      
               // loop through the States
               for(String strState: entrpSegIndvCtryStateEntrpSegEmailMap.get(strg).keySet()) {
                   list<string> usrEmailList = new list<string>(); 
                   map<String, String> tempindvCtryStateEmailMap = new map<String, String>();
                   //split the UserEmail Id's basing on Enterprise Segments
                   for(String strEmail: entrpSegIndvCtryStateEntrpSegEmailMap.get(strg).get(strState).split(';')) {
                       usrEmailList.add(strEmail);
                   }
                   if(string.isNotBlank(string.valueOf(lat.EnterpriseSegment))) {
                      if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_HPC) || string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_DL)) {
                         tempindvCtryStateEmailMap.put(strState, usrEmailList[0]);  // 1st Value in the User Email of Custom Setting.                        
                         if(!indvCtryStateEmailMap.isEmpty()) 
                             indvCtryStateEmailMap.get(strg).putAll(tempindvCtryStateEmailMap);
                         else 
                             indvCtryStateEmailMap.put(strg, tempindvCtryStateEmailMap);  
                      } 
                      else {
                         tempindvCtryStateEmailMap.put(strState, usrEmailList[1]);  // 2nd Value in the User Email of Custom Setting.
                         if(!indvCtryStateEmailMap.isEmpty()) 
                             indvCtryStateEmailMap.get(strg).putAll(tempindvCtryStateEmailMap);
                         else 
                             indvCtryStateEmailMap.put(strg, tempindvCtryStateEmailMap);                             
                      }  
                   }
                   else if(string.isBlank(string.valueOf(lat.EnterpriseSegment))) {
                        tempindvCtryStateEmailMap.put(strState, usrEmailList[1]);   // 2nd Value in the User Email of Custom Setting.
                        if(!indvCtryStateEmailMap.isEmpty()) 
                            indvCtryStateEmailMap.get(strg).putAll(tempindvCtryStateEmailMap);
                        else 
                            indvCtryStateEmailMap.put(strg, tempindvCtryStateEmailMap);                         
                   }    
               }
           } 
           
           // Date: 02/20/2020
           // Prepare the Countries based on Enterprise Segment - 1.High Performance Computing or Deep Learning 2. All Others       
           for(String strg: entrpSegIndvCtryEntrpSegEmailMap.keySet()) {      
               list<string> usrEmailList = new list<string>();
               //split the UserEmail Id's basing on Enterprise Segments
               for(String strEmail: entrpSegIndvCtryEntrpSegEmailMap.get(strg).split(';')) {
                   usrEmailList.add(strEmail);
               }
               if(string.isNotBlank(string.valueOf(lat.EnterpriseSegment))) {
                  if(string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_HPC) || string.valueOf(lat.EnterpriseSegment).equalsIgnoreCase(COMM_Constants.LEAD_ENTERPRISE_SEGMENT_DL)) {                              
                      indvCtryESEmailMap.put(strg, usrEmailList[0]);           // 1st Value in the User Email of Custom Setting.
                  } 
                  else { 
                      indvCtryESEmailMap.put(strg, usrEmailList[1]);           // 2nd Value in the User Email of Custom Setting.       
                  }
               }   
               else if(string.isBlank(string.valueOf(lat.EnterpriseSegment))) {
                       indvCtryESEmailMap.put(strg, usrEmailList[1]);          // 2nd Value in the User Email of Custom Setting.                             
               } 
           }  
           
           // Assgin Owner by processing both the Countries based on Enterprise Segment and Non-Enterprise Segment        
           if(!assignedOwner && !userEmailMap.isEmpty() && string.isNotBlank(lat.Country) && !indvCtryEmailMap.isEmpty() && indvCtryEmailMap.containsKey(lat.Country)
               && userEmailMap.containsKey(indvCtryEmailMap.get(lat.Country))) {  
                  lat.OwnerId = userEmailMap.get(indvCtryEmailMap.get(lat.Country)).Id;
                  assignedOwner = true;           
           }
           
           // Assgin Owner by processing Country, State and Enterprise Segment (vGPU) - 'Professional Visualization' or 'GPU Virtualization'          
           if(!assignedOwner && !userEmailMap.isEmpty() && string.isNotBlank(lat.Country) && !indvCtryStatevGPUEmailMap.isEmpty() && indvCtryStatevGPUEmailMap.containsKey(lat.Country)
               && userEmailMap.containsKey(indvCtryStatevGPUEmailMap.get(lat.Country).get(lat.State)) 
               && (lat.EnterpriseSegment == COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV || lat.EnterpriseSegment == COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV)) {  
                  lat.OwnerId = userEmailMap.get(indvCtryStatevGPUEmailMap.get(lat.Country).get(lat.State)).Id;
                  assignedOwner = true;           
           }
           
           // Assgin Owner by processing Country and Enterprise Segment (vGPU) - 'Professional Visualization' or 'GPU Virtualization'          
           if(!assignedOwner && !userEmailMap.isEmpty() && string.isNotBlank(lat.Country) && !indvCtryvGPUEmailMap.isEmpty() && indvCtryvGPUEmailMap.containsKey(lat.Country) 
               && (lat.EnterpriseSegment == COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV || lat.EnterpriseSegment == COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV)) {  
                  lat.OwnerId = userEmailMap.get(indvCtryvGPUEmailMap.get(lat.Country)).Id;
                  assignedOwner = true;           
           }
           
           // Assgin Owner by processing Country and Industry         
           if(!assignedOwner && !userEmailMap.isEmpty() && string.isNotBlank(lat.Country) && !indvCtryIndustryEmailMap.isEmpty() && indvCtryIndustryEmailMap.containsKey(lat.Country)
               && userEmailMap.containsKey(indvCtryIndustryEmailMap.get(lat.Country).get(lat.Industry))) {  
                  lat.OwnerId = userEmailMap.get(indvCtryIndustryEmailMap.get(lat.Country).get(lat.Industry)).Id;
                  assignedOwner = true;           
           }
                        
           // Assgin Owner by processing Country, State and Enterprise Segment        
           if(!assignedOwner && !userEmailMap.isEmpty() && string.isNotBlank(lat.Country) && !indvCtryStateEmailMap.isEmpty() && indvCtryStateEmailMap.containsKey(lat.Country)
               && userEmailMap.containsKey(indvCtryStateEmailMap.get(lat.Country).get(lat.State))) {  
                  lat.OwnerId = userEmailMap.get(indvCtryStateEmailMap.get(lat.Country).get(lat.State)).Id;
                  assignedOwner = true;           
           }
           
           // Date: 02/20/2020
           // Assgin Owner by processing Country and Enterprise Segment        
           if(!assignedOwner && !userEmailMap.isEmpty() && string.isNotBlank(lat.Country) && !indvCtryESEmailMap.isEmpty() && indvCtryESEmailMap.containsKey(lat.Country)) {  
                  lat.OwnerId = userEmailMap.get(indvCtryESEmailMap.get(lat.Country)).Id;
                  assignedOwner = true;           
           }
                      
           // Date: 02/20/2020
           // Assign Owner by processing Lead Origin, Product Type, Region and with or without Country 
           if(!assignedOwner && !userEmailMap.isEmpty() && string.isNotBlank(lat.LeadOrigin) && string.isNotBlank(lat.ProductType) && string.isNotBlank(lat.Region)) {                 
               // with Country
               if(!assignedOwner && string.isNotBlank(lat.Country) && !LeadOriginPTRegionCtryMap.isEmpty() && LeadOriginPTRegionCtryMap.containsKey(lat.LeadOrigin)
                   && LeadOriginPTRegionCtryMap.get(lat.LeadOrigin).containsKey(lat.ProductType) 
                   && LeadOriginPTRegionCtryMap.get(lat.LeadOrigin).get(lat.ProductType).containsKey(lat.Region)
                   && LeadOriginPTRegionCtryMap.get(lat.LeadOrigin).get(lat.ProductType).get(lat.Region).containsKey(lat.Country)) {
                  system.debug('LeadOriginPTRegionCtryMap.get(lat.LeadOrigin).get(lat.ProductType).get(lat.Region).get(lat.Country)---->');
                  lat.OwnerId = userEmailMap.get(LeadOriginPTRegionCtryMap.get(lat.LeadOrigin).get(lat.ProductType).get(lat.Region).get(lat.Country)).Id;
                  assignedOwner = true;
               }               
               // without Country
               if(!assignedOwner && !LeadOriginPTRegionMap.isEmpty() && LeadOriginPTRegionMap.containsKey(lat.LeadOrigin)
                   && LeadOriginPTRegionMap.get(lat.LeadOrigin).containsKey(lat.ProductType) 
                   && LeadOriginPTRegionMap.get(lat.LeadOrigin).get(lat.ProductType).containsKey(lat.Region)) {
                  system.debug('LeadOriginPTRegionMap.get(lat.LeadOrigin).get(lat.ProductType).get(lat.Region)---->'+LeadOriginPTRegionMap.get(lat.LeadOrigin).get(lat.ProductType).get(lat.Region));
                  lat.OwnerId = userEmailMap.get(LeadOriginPTRegionMap.get(lat.LeadOrigin).get(lat.ProductType).get(lat.Region)).Id;
                  assignedOwner = true; 
               }
           }
                          
           // Rule 7: NSC Default
           if(!assignedOwner && !userEmailMap.isEmpty() && userEmailMap.containsKey(defaultUserEmail)) {
              lat.OwnerId = userEmailMap.get(defaultUserEmail).Id;
              assignedOwner = true;
           } 
           
           // Rule 8: If still no Owner is assigned, then assign the Lead to the 'Marketo Sync' User
           if(!assignedOwner) {
              lat.OwnerId = mkUsr[0].Id;
              assignedOwner = true;
           } 
                          
        }       
    } // End of Lead List loop  
        
    return leadAsgnTmpList;
  } 
  */
  
  // This is dummy method for the code coverage purpose
  public void ccMethod() {}
    
}