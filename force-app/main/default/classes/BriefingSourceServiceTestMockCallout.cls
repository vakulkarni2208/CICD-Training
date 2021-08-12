/*
 * Author: @Manideep
 * Date: 8/6/2018
 * Description:
    * This test class covers code coverage for 'briefingSourceService' class.
    * This class invoked by an other test class 'BriefingSourceServiceTest'.
*/
@isTest
global class BriefingSourceServiceTestMockCallout implements HttpCalloutMock {
  global HttpResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody(generateJSONContent());
    return res;
  }
  
  static String generateJSONContent() {
        
    // Create a JSONGenerator object.
    JSONGenerator gen = JSON.createGenerator(true); 
    
    // Write data to the JSON string.
    gen.writeStartObject();
    gen.writeStringField('id', '234');
    
    // Briefing Object
    gen.writeFieldName('briefing');
    gen.writeStartObject();
    gen.writeObjectField('id', '234');
    gen.writeObjectField('briefing_center_id', '1');
    gen.writeObjectField('briefing_type_id', '2');
    gen.writeObjectField('briefing_status_id', '1');
    gen.writeObjectField('room_id', '2');
    gen.writeObjectField('title', 'BOE Technology Upper Mgmt F2F');
    gen.writeObjectField('account', 'BOE Technology');
    gen.writeObjectField('requestor_name', 'Pablo Test');
    gen.writeObjectField('requestor_email', 'ptest1@nvidia.com');
    gen.writeObjectField('requestor_phone', '6505000030');
    gen.writeObjectField('customer_meeting_type', 'Customer');
    gen.writeObjectField('sales_region_id', '');
    gen.writeObjectField('industry_id', '224');
    gen.writeObjectField('what_type_of_meeting_are_you_requesting', 'test');
    gen.writeObjectField('nvidia_host1', 'Pablo Test');
    gen.writeObjectField('is_this_meeting_confidential', 'Yes');
    gen.writeObjectField('is_jensen_scheduled_to_attend', '[No]');
    gen.writeObjectField('does_this_account_exist_in_salesforce', 'No');
    gen.writeObjectField('what_is_the_opportunity_associated_with_', 'N/A');
    gen.writeObjectField('what_is_the_the_4quarter_projected_reve', '5B');
    gen.writeObjectField('has_the_nvidia_brochure_been_sent_revie', 'No');
    gen.writeObjectField('purpose_of_meeting', 'New Customer / Introduction');
    gen.writeObjectField('customer_objective', 'First alignment meeting for NB Gaming Display');
    gen.writeObjectField('is_this_the_customers_first_visit_at_', 'Yes');
    gen.writeObjectField('are_there_vp_level_and_above_invited', 'VP');
    gen.writeObjectField('has_this_customer_met_with_nvidia_execut', 'No');
    gen.writeObjectField('if_yes_please_provide_date_of_meeting_a', 'Testing Done');
    gen.writeStringField('do_you_need_assistance_with_the_meeting_', 'No');
    gen.writeStringField('would_you_like_to_introduce_your_custome', 'No');
    gen.writeStringField('hotbutton_issues', 'No issues');
    gen.writeStringField('estimated_attendees', '4');
    gen.writeStringField('timezone_id', '6');
    gen.writeStringField('scheduling_notes', 'No Notes');
    gen.writeStringField('demo_tour_needed', 'No');
    gen.writeStringField('customer_product_interest', '["Gaming"]');
    gen.writeStringField('current_infrastructure_required_if_jen', 'GPU infrastructure');
    gen.writeStringField('customer_partner_background_required_i', 'Existing');
    gen.writeStringField('confirmed_at', string.valueOf(datetime.now()));
    
    // attendees Object
    gen.writeFieldName('attendees');
    gen.writeStartArray();
    // Internal Attendee
    gen.writeStartObject();
    gen.writeObjectField('id', '8555');
    gen.writeObjectField('briefing_id', '234');
    gen.writeObjectField('briefingId', '234');
    gen.writeObjectField('attendee_id', '8555');
    gen.writeObjectField('name', 'Pablo Test');
    gen.writeObjectField('firstName', 'Pablo');
    gen.writeObjectField('lastName', 'Test');
    gen.writeObjectField('email', 'ptest1@nvidia.com');
    gen.writeObjectField('company', 'NVIDIA');
    gen.writeObjectField('organization', 'NVIDIA');
    gen.writeObjectField('jobTitle', 'Employee');
    gen.writeObjectField('title', 'Employee');
    gen.writeObjectField('type', 'INTERNAL');
    gen.writeObjectField('phone', 'null');
    gen.writeObjectField('primaryContact', 'false');
    gen.writeObjectField('comments', 'null');
    gen.writeObjectField('unique_id', '8555');
    gen.writeObjectField('type_name', 'Requestor');
    gen.writeEndObject();
    // External Attendee 
    gen.writeStartObject();
    gen.writeObjectField('id', '8576');
    gen.writeObjectField('briefing_id', '234');
    gen.writeObjectField('briefingId', '234');
    gen.writeObjectField('attendee_id', '8576');
    gen.writeObjectField('name', 'Frank Test');
    gen.writeObjectField('firstName', 'Frank');
    gen.writeObjectField('lastName', 'Test');
    gen.writeObjectField('email', 'ftest2@nvidia.com');
    gen.writeObjectField('company', 'BOE Technology');
    gen.writeObjectField('organization', 'BOE Technology');
    gen.writeObjectField('jobTitle', 'VP & NB SBU GM');
    gen.writeObjectField('title', 'VP & NB SBU GM');
    gen.writeObjectField('type', 'EXTERNAL');
    gen.writeObjectField('phone', 'null');
    gen.writeObjectField('primaryContact', 'false');
    gen.writeObjectField('comments', 'null');
    gen.writeObjectField('unique_id', '8576');
    gen.writeObjectField('type_name', '');
    gen.writeEndObject();
    gen.writeEndArray();
        
    //BriefingRooms Object
    gen.writeFieldName('briefingRooms');
    gen.writeStartArray();
    gen.writeStartObject();
    gen.writeObjectField('id', '1234');
    gen.writeObjectField('briefing_date', date.today());
    gen.writeObjectField('room_id', '2');
    gen.writeObjectField('briefingId', '234');
    gen.writeEndObject();
    gen.writeEndArray();   
    
    // Rooms Object
    gen.writeFieldName('rooms');
    gen.writeStartArray();
    gen.writeStartObject();
    gen.writeObjectField('id', '2');
    gen.writeObjectField('name', 'Andoria');
    gen.writeObjectField('capacity', '14');
    gen.writeObjectField('active', 'true');
    gen.writeFieldName('roomType');
    gen.writeStartObject();
    gen.writeObjectField('id', '1');
    gen.writeObjectField('name', 'Conference Room');
    gen.writeEndObject();
    gen.writeEndObject();
    gen.writeEndArray();
        
    // BriefingCenter Object
    gen.writeFieldName('briefingCenter');
    gen.writeStartObject();
    gen.writeObjectField('id', '1');
    gen.writeObjectField('name', 'EBC Santa Clara');
    gen.writeObjectField('active', 'true');
    gen.writeEndObject();
    
    // BriefingType Object
    gen.writeFieldName('briefingType');
    gen.writeStartObject();
    gen.writeObjectField('id', '2');
    gen.writeObjectField('name', 'Corporate Meeting');
    gen.writeObjectField('description', 'Please use this form for all request that involve  Analysts, Investor, and PR Media.');
    gen.writeEndObject();
    
    // BriefingStatus Object
    gen.writeFieldName('briefingStatus');
    gen.writeStartObject();
    gen.writeObjectField('id', '1');
    gen.writeObjectField('name', 'Confirmed');
    gen.writeObjectField('active', 'true');
    gen.writeEndObject();
    
    // Industry Object
    gen.writeFieldName('industry');
    gen.writeStartObject();
    gen.writeObjectField('id', '224');
    gen.writeObjectField('name', 'Gaming');
    gen.writeObjectField('active', 'true');
    gen.writeEndObject();
    
    // TimeZone Object
    gen.writeFieldName('timezone');
    gen.writeStartObject();
    gen.writeObjectField('id', '6');
    gen.writeObjectField('name', '(UTC-08:00) Pacific Time (US & Canada)');
    gen.writeObjectField('code', 'America\\/Los_Angeles');
    gen.writeEndObject();
    
    // salesRegion Object
    gen.writeFieldName('salesRegion');
    gen.writeStartObject();
    gen.writeObjectField('id', '6');
    gen.writeObjectField('name', '(UTC-08:00) Pacific Time (US & Canada)');
    gen.writeObjectField('code', 'America\\/Los_Angeles');
    gen.writeEndObject();
    
    gen.writeEndObject();
    gen.writeEndObject();
       
    string strGen = gen.getAsString();

    return strGen ;
  }
  
}