/*
 * Author: @Manideep
 * Date: 8/1/2018
 * Description: 
     * This Class exposes WebService for BriefingSource.
     * When a new Briefing record is created either directly in the EBC or from Salesforce Opportunity, the EBC is not carrying over field updates into Salesforce. 
       It is updating Standard Salesforce fields in the object 'Briefing Source (DSR)' finally when the Status is changed to 'Confirmed'. So in order to carry over
       field updates for every single record update in EBC, this integraiton is built. 
 * Technical Implementaiton:
     * By exposing this class as WebService, copy the URL and put it in the 'Webhooks' in the BriefingSource. So that the EBC will trigger the Service for every '5'mins. 
       This class copies the field values from EBC to Salesforce basing on field mappings in this class and at the end Brieifng record is 'inserted' if not exist in Salesforce 
       and 'Update' if the record exisit in Salesforce through the DML 'upsert'. 
     * Defensive coding: Maximum field length defined in salesforce at object level is matched in the code before assigning value to the field.
     
 * Changes:
   09/24/2018 - @Manideep - Replace the field Mapping from 'Title' on EBC to the 'Briefing/Event Name' field with the 'Name' field on 'bsource_BS_Deal_Support_Request_c' object.    
   09/24/2018 - @Manideep - Map the field 'Account_Name__c' with the Account(text) field on EBC. 
   09/24/2018 - @Manideep - Insert Attendees(Internal and External) into the Briefing Attendee object.
   09/24/2018 - @Manideep - Map new field 'Briefing_Date__c' and with the 'Briefing_Date' field on EBC.
   09/24/2018 - @Manideep - Map new field 'Current_Infrastructure__c' and with the 'current_infrastructure_required_if_jen' field on the EBC.
   09/24/2018 - @Manideep - Map new field 'Customer_Partner_background__c' and with the 'customer_partner_background_required_i' field on the EBC.
   10/11/2018 - @Manideep - Map the fields Briefing Status, Confirmed Date to the fields on EBC.  
   
 * Changes:
   02/07/2019 - @Manideep - Changed the maximum field length of 'Name' from '255' to '80' as it was set to '80' by default. 
   02/07/2019 - @Manideep - Store the JSON response from the EBC in the custom object 'Briefing sent by EBC', so that if any record doesn't insert/update in Salesforce due to some error then we can verify the call in this object.
          
*/        
@RestResource(urlMapping='/invokeServiceBriefingSourcetoSFDC/*')
global class briefingSourceService {
  
  //Briefing Source webhook is sending briefingId Successfully  
  @HttpGet
  global static void getBriefingintoSF() {  
    system.debug('Came Here 1---->');
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    res.addHeader('Content-Type', 'applicationjson');
    system.debug('req.params----->'+req.params);
    system.debug('briefingId----->'+req.params.get('briefingId'));
    string bId = req.params.get('briefingId');
    
    //reqt.setEndpoint('https://nvidia.briefingsource.com/integration/api/briefing?id='+bId+'&objects[]=briefingStatus&objects[]=briefingType&objects[]=briefingCenter&objects[]=timezone&objects[]=salesRegion&objects[]=industry')
    
    /*
     * Make a call to BriefingSource, fetch the data along with child objects for the individual Briefing record.
     * Endpoint and Login credentials are stored in the Named Credential 'BriefingSource_Endpoint'.
     * Along with the Enpoint URL pass the request for child objects of Briefing record in the URL.
     * If additonal objects are needed to pull then refer to this API Docs URL from BriefingSource 'https://nvidia.briefingsource.com/global/docs/api/_' in the browser.  
    */  
    HttpRequest reqt = new HttpRequest(); 
    reqt.setEndpoint('callout:BriefingSource_Endpoint'+'?id='+bId+'&objects[]=briefingStatus&objects[]=briefingType&objects[]=briefingCenter&objects[]=timezone&objects[]=salesRegion&objects[]=industry');
    reqt.setMethod('GET'); 
    reqt.setHeader('Content-Type', 'application/json');
    reqt.setHeader('Accept', 'application/json');  
    system.debug('Came Here 2---->');  
    Http http = new Http();
    HTTPResponse resp = http.send(reqt);  
    string jsonFullBody = resp.getBody();
    
    system.debug('resp Status--->'+resp);
    system.debug('jsonFullBody--->'+jsonFullBody);
        
    if(string.isNotBlank(jsonFullBody)) {
       
       /*
        * @Manideep - 2/7/2019           
        * Store the raw jsonFullBody in the custom object 'Briefing sent by EBC' for reference if needed in the future.
       */ 
       Briefing_sent_by_EBC__c bSentbyEBC = new Briefing_sent_by_EBC__c();
       bSentbyEBC.Briefing_ID__c = bId;
       //bSentbyEBC.JSON_Body__c = jsonFullBody;
       bSentbyEBC.JSON_Body__c = string.valueOf(jsonFullBody).left(32768);
       system.debug('bSentbyEBC.JSON_Body__c---->'+bSentbyEBC.JSON_Body__c);
       insert bSentbyEBC;     
       
       map<String, object> briefingMetaMap = (map<String, object>) JSON.deserializeUntyped(jsonFullBody);
       
       // Collect the 'briefing' object's data in a Map
       map<String, object> briefingMap = (map<String, object>) briefingMetaMap.get('briefing');  
       
       if(!briefingMap.isEmpty()) {
              
           // Collect the 'attendee' object's array of data for the briefing in a Map
           list<map<string, object>> attendeeListMap = new list<map<string, object>>();
           list<object> attendeeList = new list<object>(); 
           if(briefingMap.containsKey('attendees')) {
              attendeeList = (list<object>) briefingMap.get('attendees');
              if(!attendeeList.isEmpty()) {
                  for(object attobj: attendeeList) {
                      attendeeListMap.add((map<string, object>) attobj);
                  }
              }
           }     
       
           // Collect the 'briefingRoom' object's array of data for the briefing in a Map
           list<map<string, object>> briefingRoomListMap = new list<map<string, object>>(); 
           list<object> briefingRoomList = new list<object>();
           if(briefingMap.containsKey('briefingRooms')) {
              briefingRoomList = (list<object>) briefingMap.get('briefingRooms');
              if(!briefingRoomList.isEmpty()) {
                  for(object bRobj: briefingRoomList) {
                      briefingRoomListMap.add((map<string, object>) bRobj);
                  }
              }  
           }    
       
           // Collect the 'briefingCenter' object's data for the briefing in a Map from the 'briefingRoom' 
           map<String, object> briefingCenterMap = (map<String, object>) briefingMap.get('briefingCenter');    
                  
           // Collect the 'briefingStatus' object's data for the briefing in a Map
           map<String, object> briefingStatusMap = (map<String, object>) briefingMap.get('briefingStatus'); 
                   
           // Collect the 'briefingType' object's data for the briefing in a Map
           map<String, object> briefingTypeMap = (map<String, object>) briefingMap.get('briefingType'); 
                          
           // Collect the 'timezone' object's data for the briefing in a Map
           map<String, object> briefingTimezoneMap = (map<String, object>) briefingMap.get('timezone'); 
           
           // Collect the 'SalesRegion' object's data for the briefing in a Map
           map<String, object> salesRegionMap = (map<String, object>) briefingMap.get('salesRegion');
           
           // Collect the 'industry' object's data for the briefing in a Map
           map<String, object> industryMap = (map<String, object>) briefingMap.get('industry'); 
          
           // object maps - Debug Logs
           system.debug('briefingMetaMap------>'+briefingMetaMap);
           system.debug('briefingMap----->'+briefingMap);
           system.debug('attendeeListMap---->'+attendeeListMap); 
           system.debug('briefingRoomListMap---->'+briefingRoomListMap); 
           system.debug('briefingCenterMap----->'+briefingCenterMap);
           system.debug('briefingStatusMap----->'+briefingStatusMap);
           system.debug('briefingTypeMap----->'+briefingTypeMap);   
           system.debug('briefingTimezoneMap----->'+briefingTimezoneMap); 
           system.debug('salesRegionMap----->'+salesRegionMap);
           system.debug('industryMap----->'+industryMap);
                                      
           // Create new or Update existing BriefingSource record in Salesforce.
           bsource__BS_Deal_Support_Request__c bSrc;                                                     
                                                                   
           // fetch the Briefing record from Salesforce if matched with the Briefing id
           List<bsource__BS_Deal_Support_Request__c> bSrcSFList = [SELECT Id, Name, bsource__Account__c, Account_Name__c, bsource__BriefingID__c, Briefing_Center__c, bsource__Status__c, bsource__Confirmed_Date__c, Briefing_Date__c, 
                                                                          bsource__Visit_Type__c, Customer_Meeting_Type__c, bsource__RequestorName__c, bsource__RequestorEmail__c, bsource__RequestorPhone__c, Region_Department__c, 
                                                                          Meeting_Type__c,  Nvidia_Host1__c, Is_this_meeting_Confidential__c, Is_Jensen_scheduled_to_attend__c, Does_this_Account_exist_in_Salesforce__c,  
                                                                          bsource__Briefing_Doc_Link__c, Opportunity_Associated_with_EBC_meeting__c, X4_Quarter_Projected_Revenue__c, Customer_Industry__c, NVIDIA_Brochure_Sent_Reviewed_Customer__c,  
                                                                          Purpose_of_Meeting__c, Customer_Objective_Success_look_like__c, First_time_Visit_at_NVIDIA__c, Highest_Level_of_Attendee__c, Customer_met_NVIDIA_Executives_in_past__c, 
                                                                          if_Yes_provide_meeting_outcome_status__c, Meeting_require_assistance_with_agenda__c, Introduce_your_customer_to_AI_Startups__c, bsource__OutstandingIssues__c, 
                                                                          bsource__EstimatedAttendees__c, Meeting_Time_Zone__c, Notes__c, Demo_Tour_Needed__c, Product_Interest_Focus__c, Current_Infrastructure__c, Customer_Partner_background__c, 
                                                                          Internal_Attendees__c, External_Attendees__c 
                                                                   FROM bsource__BS_Deal_Support_Request__c 
                                                                   WHERE bsource__BriefingID__c =:bId];
                                                                                                                       
           if(!bSrcSFList.isEmpty()) 
               bSrc = bSrcSFList[0];
           else 
               bSrc = new bsource__BS_Deal_Support_Request__c();
           
           // assign field values from EBC to Salesforce.                   
           bSrc.bsource__BriefingID__c = bId;
           
           bSrc.bsource__Briefing_Doc_Link__c = 'https://nvidia.briefingsource.com/briefing/view?id='+bId;
                     
           if(string.isNotBlank(string.valueOf(briefingMap.get('title'))))
              bSrc.Name = string.valueOf(briefingMap.get('title')).left(80);
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('account'))))
              bSrc.Account_Name__c = string.valueOf(briefingMap.get('account')).left(255);   
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('briefing_center_id'))) && !briefingCenterMap.isEmpty())
              bSrc.Briefing_Center__c = string.valueOf(briefingCenterMap.get('name')).left(255);
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('briefing_status_id'))) && !briefingStatusMap.isEmpty())
              bSrc.bsource__Status__c = string.valueOf(briefingStatusMap.get('name')).left(255);
                          
           if(string.isNotBlank(string.valueOf(briefingMap.get('briefing_type_id'))) && !briefingTypeMap.isEmpty())
              bSrc.bsource__Visit_Type__c = string.valueOf(briefingTypeMap.get('name'));   
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('customer_meeting_type'))))
              bSrc.Customer_Meeting_Type__c = string.valueOf(briefingMap.get('customer_meeting_type'));
           
           if(string.isNotBlank(string.valueOf(briefingMap.get('requestor_name'))))
              bSrc.bsource__RequestorName__c = string.valueOf(briefingMap.get('requestor_name')).left(50);
           
           if(string.isNotBlank(string.valueOf(briefingMap.get('requestor_email'))))
              bSrc.bsource__RequestorEmail__c = string.valueOf(briefingMap.get('requestor_email')).left(50);
            
           if(string.isNotBlank(string.valueOf(briefingMap.get('requestor_phone'))))
              bSrc.bsource__RequestorPhone__c = string.valueOf(briefingMap.get('requestor_phone')).left(50);  
           
           if(string.isNotBlank(string.valueOf(briefingMap.get('sales_region_id'))) && !salesRegionMap.isEmpty()) 
              bSrc.Region_Department__c = string.valueOf(salesRegionMap.get('name')).left(255);  
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('industry_id'))) && !industryMap.isEmpty()) 
              bSrc.Customer_Industry__c = string.valueOf(industryMap.get('name')).left(255);    
                                       
           if(string.isNotBlank(string.valueOf(briefingMap.get('what_type_of_meeting_are_you_requesting')))) 
              bSrc.Meeting_Type__c = string.valueOf(briefingMap.get('what_type_of_meeting_are_you_requesting'));
           
           if(string.isNotBlank(string.valueOf(briefingMap.get('nvidia_host1'))))    
              bSrc.Nvidia_Host1__c = string.valueOf(briefingMap.get('nvidia_host1')).left(255);
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('is_this_meeting_confidential')))) 
              bSrc.Is_this_meeting_Confidential__c = string.valueOf(briefingMap.get('is_this_meeting_confidential'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('is_jensen_scheduled_to_attend')))) 
              bSrc.Is_Jensen_scheduled_to_attend__c = string.valueOf(briefingMap.get('is_jensen_scheduled_to_attend'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('does_this_account_exist_in_salesforce')))) 
              bSrc.Does_this_Account_exist_in_Salesforce__c = string.valueOf(briefingMap.get('does_this_account_exist_in_salesforce'));
           
           if(string.isNotBlank(string.valueOf(briefingMap.get('what_is_the_opportunity_associated_with_')))) 
              bSrc.Opportunity_Associated_with_EBC_meeting__c = string.valueOf(briefingMap.get('what_is_the_opportunity_associated_with_')).left(255);
           
           if(string.isNotBlank(string.valueOf(briefingMap.get('what_is_the_the_4quarter_projected_reve'))))    
              bSrc.X4_Quarter_Projected_Revenue__c = string.valueOf(briefingMap.get('what_is_the_the_4quarter_projected_reve')).left(255);
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('has_the_nvidia_brochure_been_sent_revie')))) 
              bSrc.NVIDIA_Brochure_Sent_Reviewed_Customer__c = string.valueOf(briefingMap.get('has_the_nvidia_brochure_been_sent_revie'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('purpose_of_meeting')))) 
              bSrc.Purpose_of_Meeting__c = string.valueOf(briefingMap.get('purpose_of_meeting'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('customer_objective')))) 
              bSrc.Customer_Objective_Success_look_like__c = string.valueOf(briefingMap.get('customer_objective')).left(3000);
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('is_this_the_customers_first_visit_at_')))) 
              bSrc.First_time_Visit_at_NVIDIA__c = string.valueOf(briefingMap.get('is_this_the_customers_first_visit_at_'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('are_there_vp_level_and_above_invited')))) 
              bSrc.Highest_Level_of_Attendee__c = string.valueOf(briefingMap.get('are_there_vp_level_and_above_invited'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('has_this_customer_met_with_nvidia_execut')))) 
              bSrc.Customer_met_NVIDIA_Executives_in_past__c = string.valueOf(briefingMap.get('has_this_customer_met_with_nvidia_execut'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('if_yes_please_provide_date_of_meeting_a')))) 
              bSrc.if_Yes_provide_meeting_outcome_status__c = string.valueOf(briefingMap.get('if_yes_please_provide_date_of_meeting_a')).left(255);
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('do_you_need_assistance_with_the_meeting_')))) 
              bSrc.Meeting_require_assistance_with_agenda__c = string.valueOf(briefingMap.get('do_you_need_assistance_with_the_meeting_'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('would_you_like_to_introduce_your_custome')))) 
              bSrc.Introduce_your_customer_to_AI_Startups__c = string.valueOf(briefingMap.get('would_you_like_to_introduce_your_custome'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('hotbutton_issues')))) 
              bSrc.bsource__OutstandingIssues__c = string.valueOf(briefingMap.get('hotbutton_issues')).left(32768);
                          
           if(string.isNotBlank(string.valueOf(briefingMap.get('estimated_attendees')))) 
              bSrc.bsource__EstimatedAttendees__c = Integer.valueOf(briefingMap.get('estimated_attendees'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('timezone_id'))) && !briefingTimezoneMap.isEmpty()) 
              bSrc.Meeting_Time_Zone__c = string.valueOf(briefingTimezoneMap.get('name')).left(255);            
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('scheduling_notes')))) 
              bSrc.Notes__c = string.valueOf(briefingMap.get('scheduling_notes')).left(255);
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('demo_tour_needed')))) 
              bSrc.Demo_Tour_Needed__c = string.valueOf(briefingMap.get('demo_tour_needed'));
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('customer_product_interest')))) 
              bSrc.Product_Interest_Focus__c = string.valueOf(briefingMap.get('customer_product_interest')).left(1000);
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('current_infrastructure_required_if_jen')))) 
              bSrc.Current_Infrastructure__c = string.valueOf(briefingMap.get('current_infrastructure_required_if_jen')).left(255);
              
           if(string.isNotBlank(string.valueOf(briefingMap.get('customer_partner_background_required_i')))) 
              bSrc.Customer_Partner_background__c = string.valueOf(briefingMap.get('customer_partner_background_required_i')).left(255);
                                                                                   
           // Internal Attendees and External Attendees, populate them by as comma seperated values 
           if(!attendeeListMap.isEmpty()) {  
               string intAttendees;
               string extAttendees;
               for(integer i=0; i<attendeeListMap.size(); i++) {                           
                   string strType = string.valueOf(attendeeListMap[i].get('type'));                    
                   // Internal Attendees
                   if(!String.isBlank(strType) && strType.equalsIgnoreCase('INTERNAL')) {
                       if(string.isBlank(intAttendees)) 
                          intAttendees = string.valueOf(attendeeListMap[i].get('name')) + ', ';
                       else 
                          intAttendees = intAttendees + string.valueOf(attendeeListMap[i].get('name')) + ', ';      
                   } 
                   // External Attendees
                   else {
                       string strTitle = attendeeListMap[i].get('title') == null ? 'Blank Title' : string.valueOf(attendeeListMap[i].get('title'));
                       string strEmail = attendeeListMap[i].get('email') == null ? 'Blank Email' : string.valueOf(attendeeListMap[i].get('email'));
                       if(string.isBlank(extAttendees)) {
                          extAttendees = string.valueOf(attendeeListMap[i].get('name')) + '(' + strTitle + ', ' + strEmail + ')' + '; ';
                       } else {   
                          extAttendees = extAttendees + string.valueOf(attendeeListMap[i].get('name')) + '(' + strTitle + ', ' + strEmail + ')' + '; '; 
                       }
                   } 
               }   
               // Internal Attendees
               if(string.isNotBlank(intAttendees)) {
                  bSrc.Internal_Attendees__c = intAttendees.left(2500);
               }
               // External Attendees
               if(string.isNotBlank(extAttendees)) {
                  bSrc.External_Attendees__c = extAttendees.left(5000);
               }      
           }
           
           // populate Briefing Date
           if(string.isNotBlank(string.valueOf(briefingMap.get('room_id'))) && !briefingRoomListMap.isEmpty()) {              
              for(integer i=0; i<briefingRoomListMap.size(); i++) {
                  if(string.valueOf(briefingMap.get('room_id')).equals(string.valueOf(briefingRoomListMap[i].get('room_id')))
                     && string.isNotBlank(string.valueOf(briefingRoomListMap[i].get('briefing_date')))) {
                     // Process the Date before assigning to the field
                     string origBDateStr = string.valueOf(briefingRoomListMap[i].get('briefing_date'));
                     string[] dateStr = origBDateStr.split('-');
                     integer strYear = integer.valueOf(dateStr[0]);
                     integer strMonth = integer.valueOf(dateStr[1]);
                     integer strDate = integer.valueOf(dateStr[2]);
                     bSrc.Briefing_Date__c = date.newInstance(strYear, strMonth, strDate); 
                     break;
                  }        
              } 
           } 
           
           // populate Confirmed Date
           if(string.isNotBlank(string.valueOf(briefingMap.get('confirmed_at')))) {
              // Process the Date before assigning to the field
              string origCDateStr = string.valueOf(briefingMap.get('confirmed_at'));
              string[] dateStr1 = origCDateStr.split(' ');
              string[] dateStr2 = dateStr1[0].split('-');
              integer strYear = integer.valueOf(dateStr2[0]);
              integer strMonth = integer.valueOf(dateStr2[1]);
              integer strDate = integer.valueOf(dateStr2[2]);
              bSrc.bsource__Confirmed_Date__c = date.newInstance(strYear, strMonth, strDate);
           }
           
           /*
           Field - Debug Logs
           */
           system.debug('bSrc.Name---->'+bSrc.Name); 
           system.debug('bSrc.Briefing_Center__c----->'+bSrc.Briefing_Center__c);
           system.debug('bSrc.bsource__Status__c----->'+bSrc.bsource__Status__c);
           system.debug('bSrc.bsource__Visit_Type__c------>'+bSrc.bsource__Visit_Type__c);
           system.debug('bSrc.Customer_Meeting_Type__c----->'+bSrc.Customer_Meeting_Type__c);
           system.debug('bSrc.bsource__RequestorName__c----->'+bSrc.bsource__RequestorName__c);
           system.debug('bSrc.bsource__RequestorEmail__c---->'+bSrc.bsource__RequestorEmail__c);
           system.debug('bSrc.bsource__RequestorPhone__c---->'+bSrc.bsource__RequestorPhone__c);  
           system.debug('bSrc.Region_Department__c----->'+bSrc.Region_Department__c);
           system.debug('bSrc.Customer_Industry__c----->'+bSrc.Customer_Industry__c);
           system.debug('bSrc.Meeting_Type__c----->'+bSrc.Meeting_Type__c); 
           system.debug('bSrc.Nvidia_Host1__c----->'+bSrc.Nvidia_Host1__c);
           system.debug('bSrc.Is_this_meeting_Confidential__c----->'+bSrc.Is_this_meeting_Confidential__c); 
           system.debug('bSrc.Is_Jensen_scheduled_to_attend__c----->'+bSrc.Is_Jensen_scheduled_to_attend__c); 
           system.debug('bSrc.Does_this_Account_exist_in_Salesforce__c----->'+bSrc.Does_this_Account_exist_in_Salesforce__c);
           system.debug('bSrc.Opportunity_Associated_with_EBC_meeting__c------>'+bSrc.Opportunity_Associated_with_EBC_meeting__c);
           system.debug('bSrc.X4_Quarter_Projected_Revenue__c----->'+bSrc.X4_Quarter_Projected_Revenue__c);
           system.debug('bSrc.Customer_Industry__c----->'+bSrc.Customer_Industry__c);
           system.debug('bSrc.NVIDIA_Brochure_Sent_Reviewed_Customer__c----->'+bSrc.NVIDIA_Brochure_Sent_Reviewed_Customer__c);
           system.debug('bSrc.Purpose_of_Meeting__c----->'+bSrc.Purpose_of_Meeting__c);
           system.debug('bSrc.Customer_Objective_Success_look_like__c------>'+bSrc.Customer_Objective_Success_look_like__c);
           system.debug('bSrc.First_time_Visit_at_NVIDIA__c----->'+bSrc.First_time_Visit_at_NVIDIA__c);
           system.debug('bSrc.Highest_Level_of_Attendee__c----->'+bSrc.Highest_Level_of_Attendee__c);
           system.debug('bSrc.Customer_met_NVIDIA_Executives_in_past__c------>'+bSrc.Customer_met_NVIDIA_Executives_in_past__c);
           system.debug('bSrc.if_Yes_provide_meeting_outcome_status__c------>'+bSrc.if_Yes_provide_meeting_outcome_status__c);
           system.debug('bSrc.Meeting_require_assistance_with_agenda__c------>'+bSrc.Meeting_require_assistance_with_agenda__c);
           system.debug('bSrc.bsource__OutstandingIssues__c------>'+bSrc.bsource__OutstandingIssues__c);
           system.debug('bSrc.bsource__EstimatedAttendees__c------>'+bSrc.bsource__EstimatedAttendees__c); 
           system.debug('bSrc.Meeting_Time_Zone__c----->'+bSrc.Meeting_Time_Zone__c);        
           system.debug('bSrc.Notes__c------>'+bSrc.Notes__c);
           system.debug('bSrc.Demo_Tour_Needed__c----->'+bSrc.Demo_Tour_Needed__c);
           system.debug('bSrc.Product_Interest_Focus__c----->'+bSrc.Product_Interest_Focus__c);
           system.debug('bSrc.Internal_Attendees__c---->'+bSrc.Internal_Attendees__c);
           system.debug('bSrc.External_Attendees__c---->'+bSrc.External_Attendees__c); 
           system.debug('bSrc.Briefing_Date__c------>'+bSrc.Briefing_Date__c);
           system.debug('bSrc.bsource__Confirmed_Date__c------>'+bSrc.bsource__Confirmed_Date__c);                     
           
           system.debug('bSrc------>'+bSrc);           
           upsert bSrc;  //DML                                                       
           
           // loop through both Internal Attendees and External Attendees
           if(!attendeeListMap.isEmpty()) {
               
               list<bsource__Briefing_Attendee__c> briefingAttendeeList = new list<bsource__Briefing_Attendee__c>();  // Briefing Attendees related list
               map<string, bsource__Briefing_Attendee__c> bsAttdMap = new map<string, bsource__Briefing_Attendee__c>();
               map<string, Id> bIdbSrcMap = new map<string, Id>();
               
               // fetch the Briefing record from Salesforce after it is insertedupdated
               list<bsource__BS_Deal_Support_Request__c> bSrcAfterDML = [SELECT Id, Name, bsource__BriefingID__c    
                                                                         FROM bsource__BS_Deal_Support_Request__c 
                                                                         WHERE bsource__BriefingID__c =:bId];
               for(bsource__BS_Deal_Support_Request__c bsr: bSrcAfterDML) {
                   bIdbSrcMap.put(bsr.bsource__BriefingID__c, bsr.Id);
               }
               system.debug('bIdbSrcMap---->'+bIdbSrcMap);
                               
               // pull existing Briefing Attendees matched with the BriefingId.
               list<bsource__Briefing_Attendee__c> bsrcAttdList = [SELECT Id, Name, bsource__Organization__c, bsource__Deal_Support_Request__c, bsource__Email__c, bsource__First_Name__c, bsource__Last_Name__c, 
                                                                          bsource__Phone__c, bsource__Title__c, Type__c
                                                                   FROM bsource__Briefing_Attendee__c 
                                                                   WHERE bsource__Deal_Support_Request__r.bsource__BriefingID__c =:bId];                                                        
               if(!bsrcAttdList.isEmpty()) {   
                   delete bsrcAttdList;  // Delete all existing Briefing Attendees for the Briefing Id.            
               }                                                        
               
               // Create new Internal and External Attendees
               for(integer i=0; i<attendeeListMap.size(); i++) {                                                           
                   
                   bsource__Briefing_Attendee__c bAttd = new bsource__Briefing_Attendee__c();
                   
                   bAttd.Type__c = string.valueOf(attendeeListMap[i].get('type'));                  
                                       
                   bAttd.bsource__Deal_Support_Request__c = bIdbSrcMap.get(bId);
                      
                   if(string.isNotBlank(string.valueOf(attendeeListMap[i].get('firstName'))))
                      bAttd.bsource__First_Name__c = string.valueOf(attendeeListMap[i].get('firstName'));
                      
                   if(string.isNotBlank(string.valueOf(attendeeListMap[i].get('lastName'))))   
                      bAttd.bsource__Last_Name__c = string.valueOf(attendeeListMap[i].get('lastName'));
                      
                   if(string.isNotBlank(string.valueOf(attendeeListMap[i].get('title'))))
                      bAttd.bsource__Title__c = string.valueOf(attendeeListMap[i].get('title'));
                      
                   if(string.isNotBlank(string.valueOf(attendeeListMap[i].get('email'))))
                      bAttd.bsource__Email__c = string.valueOf(attendeeListMap[i].get('email'));
                                          
                   if(string.isNotBlank(string.valueOf(attendeeListMap[i].get('phone'))))   
                      bAttd.bsource__Phone__c = string.valueOf(attendeeListMap[i].get('phone'));
                      
                   if(string.isNotBlank(string.valueOf(attendeeListMap[i].get('organization'))))
                      bAttd.bsource__Organization__c = string.valueOf(attendeeListMap[i].get('organization'));
                      
                   briefingAttendeeList.add(bAttd);     
               }
               
               system.debug('briefingAttendeeList------->'+briefingAttendeeList);
               insert briefingAttendeeList;
               try {
                 insert briefingAttendeeList;
               } catch(exception e) {
                   system.debug('Exception occurred while inserting Briefing Attendees: ' + e.getMessage());
               } 
                           
           }  // End of looping over Internal Attendees and External Attendees.                               
             
       } // End of briefingMap null check 
            
    } // End of jsonBody null check 
    
  } // End of method 'getBriefingId()'
  
} // End of Class 'briefingSourceService'