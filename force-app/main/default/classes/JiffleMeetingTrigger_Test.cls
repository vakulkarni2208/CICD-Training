@isTest(seeAllData = false)
private class JiffleMeetingTrigger_Test{

    @isTest static void testAfterInsert(){
        
        // Data prepartion:
        // Insert Jiffle Attendee
        jiffle__Attendee__c attendeeObj = new jiffle__Attendee__c(
            jiffle__Attendee_First_Name__c = 'Karen',                 // Attendee First Name
            jiffle__Attendee_Last_Name__c = 'Karpaty',                  // Attendee Last Name
            jiffle__Company__c = '-',                                   // Company
            jiffle__Attendee_Email__c = 'karen.karpaty@jifflenow.com.invalid',  // Attendee Email
            jiffle__Mobile__c = '-',                                    // Mobile
            jiffle__Attendee_UUID__c = 'BTKs9KV_HogFgm2gaw6cMg',        // Attendee UUID
            jiffle__User_Role__c = 'CSM',                               // User Role
            jiffle__User_Type__c = 'Internal'                          // User Type
        );
		insert attendeeObj;
        

    	// insert Meeting Questions
        MeetingQuestions__c objMeetQue = new MeetingQuestions__c(Question__c  = 'Is this a strategic executive meeting?'); 
        insert objMeetQue;
        
        jiffle__Event__c jEventObj = new jiffle__Event__c(
          Name = 'GTC Spring 2021',                                               // Event Name
          jiffle__Event_Start_Date__c = Date.newInstance(2021, 03, 29),                  // Event Start Date
          jiffle__Event_Code__c = 'gtcspring2021',                                  // Event_Code
          jiffle__Event_End_Date__c = Date.newInstance(2021, 07, 05),                     // Event End Date
          jiffle__Event_Location__c = 'Virtual | Pacific Time',                     // Event Location
          jiffle__Event_UUID__c = '4a0a5d61-c8d0-4071-bdb6-db729f83ec24',           // Event UUID
          jiffle__Event_Status__c = 'LIVE',                                         // Event Status
          jiffle__Event_Type__c = 'TradeShow',                                      // Event Type
          jiffle__Virtual_Event__c = true,                                          // Virtual Event
          jiffle__Meeting_Sync_Date__c = System.now()  // Meeting_Sync_Date
        );
        insert jEventObj;
        

        // Insert the jiffle meeting data.
        jiffle__Meeting__c objMeet = new jiffle__Meeting__c(
          jiffle__Event__c = jEventObj.Id,                                                                                                                                                                                                                                                                                                                                                                                                                                 // Event
          jiffle__Meeting_ID__c = '13',                                                                                                                                                                                                                                                                                                                                                                                                                                           // Meeting ID
          jiffle__Meeting_Requestor__c = 'Karen Karpaty',                                                                                                                                                                                                                                                                                                                                                                                                                         // Requestor Name
          jiffle__Meeting_with__c = 'Disney',                                                                                                                                                                                                                                                                                                                                                                                                                                     // Meeting with
          jiffle__MeetingRequestor__c = attendeeObj.Id,                                                                                                                                                                                                                                                                                                                                                                                                                        // Meeting Requestor
          jiffle__Request_Status__c = 'approved',                                                                                                                                                                                                                                                                                                                                                                                                                                 // Request Status
          jiffle__Meeting_Time_Zone__c = 'Pacific Time (US & Canada)',                                                                                                                                                                                                                                                                                                                                                                                                            // Meeting Time Zone
          jiffle__Meeting_Type__c = 'Sales - Compute',                                                                                                                                                                                                                                                                                                                                                                                                                            // Meeting Type
          jiffle__Meeting_UUID__c = '3YcdZ-_QoWOmC_rzSfEiKQ',                                                                                                                                                                                                                                                                                                                                                                                                                     // Meeting UUID
          jiffle__Start_Date_Time__c = System.now(),                                                                                                                                                                                                                                                                                                                                                                                                  // Start Date/Time
          jiffle__Topic_of_Interest__c = 'Automotive | Autonomous Machines',                                                                                                                                                                                                                                                                                                                                                                                                      // Topic of Interest
          jiffle__End_Date_Time__c = System.now().addMinutes(30),                                                                                                                                                                                                                                                                                                                                                                                                    // End Date/Time
          jiffle__From_Lead__c = false,                                                                                                                                                                                                                                                                                                                                                                                                                                           // From Lead
          jiffle__Checkin__c = false,                                                                                                                                                                                                                                                                                                                                                                                                                                             // Checkin
          jiffle__Category__c = 'Virtual',                                                                                                                                                                                                                                                                                                                                                                                                                                        // Category
          jiffle__JN_Custom_fields__c = 'Is this a strategic executive meeting?:No<br><br>Industry:Architecture, Eng and Construction<br><br>Region:EMEA<br><br>Opportunity Amount:500K<br><br>Stage:Prospecting<br><br>Previous meetings:NA<br><br>Customer/partner background High level.:NA<br><br>Current infrastructure:NA<br><br>Products of Interest:Omniverse, DGX-Ready Software<br><br>Opportunity Overview:test<br><br>Expectations of attendees / desired outcomes :test<br><br>NVIDIA objectives:test<br><br>Major issues/obstacles we may need to address:test\n',  // JN Meeting Information
          jiffle__Vcon_Link__c = 'https://teams.microsoft.com/l/meetup-join/19%3a...Sfdc.onload(function() {    blankshield(document.getElementById(\'rtp_ZiEYlS\').parentElement);});',                                                                                                                                                                                                                                                                                            // Vcon Link
          jiffle__Vcon_Description__c = 'Video Conference : MicrosoftTeamsMeeting Id : MSpkMmI0NzQwYS0wNTM3LTQ2NmItYWZjOC04YTNlN2U1NDc1NDUqMCoqMTk6bWVldGluZ19ORFl3TldJMk5qa3RObU5oTVMwMFpXUXdMV0UwWm1ZdFkyUmtORFl3Wm1NMlptRmhAdGhyZWFkLnYyJoin By Phone :(Conference Id: 232390370)(Toll: +1 949-570-1120)'                                                                                                                                                                     // Vcon Description
        );
        insert objMeet;
    }
    
    @isTest static void testAfterUpdate(){
        
        // Data prepartion:
        // Insert Jiffle Attendee
        jiffle__Attendee__c attendeeObj = new jiffle__Attendee__c(
            jiffle__Attendee_First_Name__c = 'Karen',                 // Attendee First Name
            jiffle__Attendee_Last_Name__c = 'Karpaty',                  // Attendee Last Name
            jiffle__Company__c = '-',                                   // Company
            jiffle__Attendee_Email__c = 'karen.karpaty@jifflenow.com.invalid',  // Attendee Email
            jiffle__Mobile__c = '-',                                    // Mobile
            jiffle__Attendee_UUID__c = 'BTKs9KV_HogFgm2gaw6cMg',        // Attendee UUID
            jiffle__User_Role__c = 'CSM',                               // User Role
            jiffle__User_Type__c = 'Internal'                          // User Type
        );
		insert attendeeObj;
        

    	// insert Meeting Questions
        MeetingQuestions__c objMeetQue = new MeetingQuestions__c(Question__c  = 'Is this a strategic executive meeting?'); 
        insert objMeetQue;
        
        jiffle__Event__c jEventObj = new jiffle__Event__c(
          Name = 'GTC Spring 2021',                                               // Event Name
          jiffle__Event_Start_Date__c = Date.newInstance(2021, 03, 29),                  // Event Start Date
          jiffle__Event_Code__c = 'gtcspring2021',                                  // Event_Code
          jiffle__Event_End_Date__c = Date.newInstance(2021, 07, 05),                     // Event End Date
          jiffle__Event_Location__c = 'Virtual | Pacific Time',                     // Event Location
          jiffle__Event_UUID__c = '4a0a5d61-c8d0-4071-bdb6-db729f83ec24',           // Event UUID
          jiffle__Event_Status__c = 'LIVE',                                         // Event Status
          jiffle__Event_Type__c = 'TradeShow',                                      // Event Type
          jiffle__Virtual_Event__c = true,                                          // Virtual Event
          jiffle__Meeting_Sync_Date__c = System.now()  // Meeting_Sync_Date
        );
        insert jEventObj;
        

        // Insert the jiffle meeting data.
        jiffle__Meeting__c objMeet = new jiffle__Meeting__c(
          jiffle__Event__c = jEventObj.Id,                                                                                                                                                                                                                                                                                                                                                                                                                                 // Event
          jiffle__Meeting_ID__c = '13',                                                                                                                                                                                                                                                                                                                                                                                                                                           // Meeting ID
          jiffle__Meeting_Requestor__c = 'Karen Karpaty',                                                                                                                                                                                                                                                                                                                                                                                                                         // Requestor Name
          jiffle__Meeting_with__c = 'Disney',                                                                                                                                                                                                                                                                                                                                                                                                                                     // Meeting with
          jiffle__MeetingRequestor__c = attendeeObj.Id,                                                                                                                                                                                                                                                                                                                                                                                                                        // Meeting Requestor
          jiffle__Request_Status__c = 'approved',                                                                                                                                                                                                                                                                                                                                                                                                                                 // Request Status
          jiffle__Meeting_Time_Zone__c = 'Pacific Time (US & Canada)',                                                                                                                                                                                                                                                                                                                                                                                                            // Meeting Time Zone
          jiffle__Meeting_Type__c = 'Sales - Compute',                                                                                                                                                                                                                                                                                                                                                                                                                            // Meeting Type
          jiffle__Meeting_UUID__c = '3YcdZ-_QoWOmC_rzSfEiKQ',                                                                                                                                                                                                                                                                                                                                                                                                                     // Meeting UUID
          jiffle__Start_Date_Time__c = System.now(),                                                                                                                                                                                                                                                                                                                                                                                                  // Start Date/Time
          jiffle__Topic_of_Interest__c = 'Automotive | Autonomous Machines',                                                                                                                                                                                                                                                                                                                                                                                                      // Topic of Interest
          jiffle__End_Date_Time__c = System.now().addMinutes(30),                                                                                                                                                                                                                                                                                                                                                                                                    // End Date/Time
          jiffle__From_Lead__c = false,                                                                                                                                                                                                                                                                                                                                                                                                                                           // From Lead
          jiffle__Checkin__c = false,                                                                                                                                                                                                                                                                                                                                                                                                                                             // Checkin
          jiffle__Category__c = 'Virtual',                                                                                                                                                                                                                                                                                                                                                                                                                                        // Category
          jiffle__JN_Custom_fields__c = 'Is this a strategic executive meeting?:No<br><br>Industry:Architecture, Eng and Construction<br><br>Region:EMEA<br><br>Opportunity Amount:500K<br><br>Stage:Prospecting<br><br>Previous meetings:NA<br><br>Customer/partner background High level.:NA<br><br>Current infrastructure:NA<br><br>Products of Interest:Omniverse, DGX-Ready Software<br><br>Opportunity Overview:test<br><br>Expectations of attendees / desired outcomes :test<br><br>NVIDIA objectives:test<br><br>Major issues/obstacles we may need to address:test\n',  // JN Meeting Information
          jiffle__Vcon_Link__c = 'https://teams.microsoft.com/l/meetup-join/19%3a...Sfdc.onload(function() {    blankshield(document.getElementById(\'rtp_ZiEYlS\').parentElement);});',                                                                                                                                                                                                                                                                                            // Vcon Link
          jiffle__Vcon_Description__c = 'Video Conference : MicrosoftTeamsMeeting Id : MSpkMmI0NzQwYS0wNTM3LTQ2NmItYWZjOC04YTNlN2U1NDc1NDUqMCoqMTk6bWVldGluZ19ORFl3TldJMk5qa3RObU5oTVMwMFpXUXdMV0UwWm1ZdFkyUmtORFl3Wm1NMlptRmhAdGhyZWFkLnYyJoin By Phone :(Conference Id: 232390370)(Toll: +1 949-570-1120)'                                                                                                                                                                     // Vcon Description
        );
        insert objMeet;
        
        objMeet.jiffle__JN_Custom_fields__c = 'Is this a strategic executive meeting?:Yes<br><br>Industry:Architecture, Eng and Construction<br><br>Region:EMEA<br><br>Opportunity Amount:500K<br><br>Stage:Prospecting<br><br>Previous meetings:NA<br><br>Customer/partner background High level.:NA<br><br>Current infrastructure:NA<br><br>Products of Interest:Omniverse, DGX-Ready Software<br><br>Opportunity Overview:test<br><br>Expectations of attendees / desired outcomes :test<br><br>NVIDIA objectives:test<br><br>Major issues/obstacles we may need to address:test\n';
update objMeet;
    }
}