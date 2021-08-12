@isTest(seeAllData=false)
public class Test_ContactSetTimezoneSchedulableBatch{
public static testMethod void scheduleBatchJob(){
Test.StartTest();
Account acc = Test_COMM_Factory.getAccount('na test');
insert acc;
Contact con = Test_COMM_Factory.getContact(acc.id);
con.Is_mailing_address_changed__c = true;
insert con;
Id RecTypeId = Test_COMM_Factory.getRecordTypeId('Case', 'Community_User_Record_Type');
Case cse = Test_COMM_Factory.getCase(acc.id, RecTypeId);
cse.contactId = con.id;
insert cse;
Contact_Set_Timezone_schedulable_batch timezone = new Contact_Set_Timezone_schedulable_batch(con.id);
String sch = '0 0 23 * * ?';
Test.setMock(HttpCalloutMock.class, new Mock()); 
system.schedule('Test Territory Check', sch, timezone);
Test.StopTest();

}

private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            string strResponse;
            system.debug('**req.getEndpoint()**'+ req.getEndpoint());
            if (req.getEndpoint().contains('geocode')) {
                strResponse = '{ "results" : [ { "address_components" : [ { "long_name" : "8389", "short_name" : "8389", "types" : [ "street_number" ] }, { "long_name" : "Academy Road", "short_name" : "Academy Rd", "types" : [ "route" ] }, { "long_name" : "Taylor Village", "short_name" : "Taylor Village", "types" : [ "neighborhood", "political" ] }, { "long_name" : "Ellicott City", "short_name" : "Ellicott City", "types" : [ "locality", "political" ] }, { "long_name" : "2, Ellicott City", "short_name" : "2, Ellicott City", "types" : [ "administrative_area_level_3", "political" ] }, { "long_name" : "Howard County", "short_name" : "Howard County", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "Maryland", "short_name" : "MD", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] }, { "long_name" : "21043", "short_name" : "21043", "types" : [ "postal_code" ] }, { "long_name" : "6687", "short_name" : "6687", "types" : [ "postal_code_suffix" ] } ], "formatted_address" : "8389 Academy Rd, Ellicott City, MD 21043, USA", "geometry" : { "location" : { "lat" : 39.2456643, "lng" : -76.79250429999999 }, "location_type" : "RANGE_INTERPOLATED", "viewport" : { "northeast" : { "lat" : 39.2470132802915, "lng" : -76.79115531970848 }, "southwest" : { "lat" : 39.2443153197085, "lng" : -76.7938532802915 } } }, "partial_match" : true, "place_id" : "Ei04Mzg5IEFjYWRlbXkgUmQsIEVsbGljb3R0IENpdHksIE1EIDIxMDQzLCBVU0EiGxIZChQKEgm7qk7Axx_IiREvY9WfsHjc_hDFQQ", "types" : [ "street_address" ] }, { "address_components" : [ { "long_name" : "21403", "short_name" : "21403", "types" : [ "postal_code" ] }, { "long_name" : "Highland Beach", "short_name" : "Highland Beach", "types" : [ "locality", "political" ] }, { "long_name" : "Anne Arundel County", "short_name" : "Anne Arundel County", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "Maryland", "short_name" : "MD", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] } ], "formatted_address" : "Highland Beach, MD 21403, USA", "geometry" : { "bounds" : { "northeast" : { "lat" : 38.9889888, "lng" : -76.4471949 }, "southwest" : { "lat" : 38.903932, "lng" : -76.53847689999999 } }, "location" : { "lat" : 38.9359831, "lng" : -76.4910093 }, "location_type" : "APPROXIMATE", "viewport" : { "northeast" : { "lat" : 38.9889888, "lng" : -76.4471949 }, "southwest" : { "lat" : 38.903932, "lng" : -76.53847689999999 } } }, "partial_match" : true, "place_id" : "ChIJR_IpVNf1t4kRmRyh7syKE-c", "postcode_localities" : [ "Annapolis", "Highland Beach" ], "types" : [ "postal_code" ] } ], "status" : "OK" }';
            } else if (req.getEndpoint().contains('timezone')) {
                strResponse = '{ "dstOffset" : 0, "rawOffset" : -18000, "status" : "OK", "timeZoneId" : "America/New_York", "timeZoneName" : "Eastern Standard Time" }';
            } else if (req.getEndpoint().contains('nvidiaaxis2service')) {
                strResponse = null;
            }             
            else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
            res.setBody(strResponse);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }    
}