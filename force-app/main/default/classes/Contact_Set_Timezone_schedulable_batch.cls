/*
Description : Contact_Set_Timezone_schedulable_batch class is used to update Timezone of Open Case's contact

Version    Date        Description
-----------------------------------------------------------------
1.0        02/25/21    SDS-2581 Update Contact Timezone

*/
global class Contact_Set_Timezone_schedulable_batch implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts {
  String query;
  List<Contact> contactList = new List<Contact>();
  public string MESSAGE_TEXT {get;set;}
  public string MESSAGE_TYPE {get;set;}
  set<Id> setContactIds = new set<Id>();
  
    // This is just used for troubleshooting by passing a single record.
    global Contact_Set_Timezone_schedulable_batch(String strContactId){
    query = PRFT_DomainLayer.buildQueryFields('Contact',' Where Id = \''+strContactId+'\'','Select ');
        System.debug('Checking query constructor--'+query);
    }
  
    global Contact_Set_Timezone_schedulable_batch() {
        List<Case> lstCases = [select contactId from Case where Status <> 'Closed' and contactId !=null];
        if(!lstCases.isEmpty()){
            for(Case tmpCase : lstCases){
                setContactIds.add(tmpCase.contactId);
            }
        }
        query = PRFT_DomainLayer.buildQueryFields('Contact',' Where (Is_Mailing_Address_Changed__c = true or TimeZone__c = null) and id in :setContactIds','Select ');        
        System.debug('Checking query--'+query);
    }
    
  // Query the Contacts
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('checking query11---'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext sc){
        Contact_Set_Timezone_schedulable_batch conTzBatch = new Contact_Set_Timezone_schedulable_batch();
        Id batchJobId = Database.executebatch(conTzBatch,10);
    }    
    
  // Execute the batch apex to resync them due to batch limits it is ideal to set the batch size as 10.
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        System.debug('checking execuet 11---'+scope);
        callGoogleGeolocation(scope );
    }
    
    // Final Method checks if all the records have been executed or not.
    global void finish(Database.BatchableContext BC) {

    } 
    
    public static void callGoogleGeolocation(List<Contact> lstContact ){
        Http objhttp;
        HttpRequest req;
        HttpResponse res;
        objhttp = new Http();
        req = new HttpRequest();
        res = new HttpResponse();
        req.setMethod('GET'); // req.setMethod('GET');
        List<Contact> lstTimezoneChangedContacts = new List<Contact>(); 
        set<Id> setConIds = new set<Id>();
        for(Contact tmpCon : lstContact )
             setConIds.add(tmpCon.id);
        system.debug('**future**' + lstContact );          
        List<Contact> lstContactToUpdate = new List<Contact>();
        string response;
        Contact con;
        Response gresp = new Response();
        List<Result> lstgeoResult=new List<Result>();
        GoogleTimeZone gtimezone;
        Geometry geom = new Geometry();
        Map<String, Timezone_List__c> mapTimezone = Timezone_List__c.getAll();
        for(Contact tmpCon : lstContact ){
            if(tmpCon.MailingStreet!=null || tmpCon.MailingCity!=null || tmpCon.MailingState !=null || tmpCon.MailingPostalCode!=null){
                string strEndpoint = 'https://maps.googleapis.com/maps/api/geocode/json?address='+ tmpCon.MailingStreet +' '+ tmpCon.MailingCity +' '+ tmpCon.MailingState+' '+ tmpCon.MailingPostalCode+ '&key=AIzaSyAcQZCSPZcJCT-5LAYEO6AikPld59gHY2g';
                strEndpoint = strEndpoint.replace('null','');
                strEndpoint = strEndpoint.replace(' ','+');
                strEndpoint = strEndpoint.replace('\n','+');
                strEndpoint = strEndpoint.replace('++','+');
                req.setEndpoint(strEndpoint );
                req.setHeader('Accept', 'application/json');
                req.setHeader('Content-type', 'application/json');
                req.setTimeout(120000); 
                system.debug('**' + req.getBody());
                res = objhttp.send(req);
                system.debug('**' + res.getBody());
                gresp = (Response)JSON.deserialize(res.getBody(), Response.class);
                system.debug('**' + gresp );
                lstgeoResult = gresp.results;
                geom = lstgeoResult.get(0).geometry;
                system.debug('**' + geom );
                system.debug('**' + lstgeoResult.get(0).geometry);
                Location loc = geom.location;    
                strEndpoint = 'https://maps.googleapis.com/maps/api/timezone/json?location='+ loc.lat + ',' + loc.lng + '&timestamp='+ tmpCon.Difference_in_Seconds__c + '&key=AIzaSyAcQZCSPZcJCT-5LAYEO6AikPld59gHY2g';
                req.setEndpoint(strEndpoint );
                req.setHeader('Accept', 'application/json');
                req.setHeader('Content-type', 'application/json');
                req.setTimeout(120000); 
                system.debug('**' + req.getBody());
                res = objhttp.send(req);
                system.debug('**' + res.getBody());
                gtimezone = (GoogleTimeZone)JSON.deserialize(res.getBody(), GoogleTimeZone.class);
                if(mapTimezone!=null && mapTimezone.containsKey('Google-'+gtimezone.timeZoneId)){
                  if(mapTimezone.containsKey('Salesforce-'+gtimezone.timeZoneId)){
                    tmpCon.TimeZone__c = gtimezone.timeZoneId;
                  }
                  else{
                    for(Timezone_List__c tmpTimezone : mapTimezone.values()){
                        if(tmpTimezone.Timezone_Type__c=='Salesforce' && tmpTimezone.Offset__c == mapTimezone.get('Google-'+gtimezone.timeZoneId).Offset__c){
                          tmpCon.TimeZone__c = tmpTimezone.TimeZoneId__C;
                          break;                        
                      }
                    }
                  }
                    
                }
                //tmpCon.TimeZone__c = gtimezone.timeZoneId;
                Schema.DescribeFieldResult F = Contact.TimeZone__c.getDescribe();
                List<Schema.PicklistEntry> lstPickList = F.getPicklistValues();
                for(Schema.PicklistEntry tmp : lstPickList){
                    //system.debug('**tmp.getlabel()**' + tmp.getvalue());
                    if(tmpCon.TimeZone__c == tmp.getvalue()){
                        tmpCon.Time_Zone_Text__c = tmp.getlabel();
                        tmpCon.TimeZone__c = tmp.getvalue();
                        //system.debug('**tmp.getlabel()**' + tmp.getlabel());
                    }    
                }
                con = new Contact (id=tmpCon.id,TimeZone__c = tmpCon.TimeZone__c,Time_Zone_Text__c =tmpCon.Time_Zone_Text__c,Is_Mailing_Address_Changed__c=false);
                lstContactToUpdate.add(con);
            }
        }

        if(lstContactToUpdate!=null && !lstContactToUpdate.isEmpty())
            Database.update(lstContactToUpdate,false);
                        
    }
/*-------------------Google API Response class-------------------------------------------------*/    
public class Response { 
    final List<Result> results; 
}    
class GoogleTimeZone{
   long dstOffset ;
   long rawOffset ;
   string status ; 
   string timeZoneId ; 
   string timeZoneName ;
}
public class AddressComponent {
    public String longName;
    public String shortName;
    public List<String> types = null;
}
public class Example {
    public List<Result> results = null;
    public String status;
}
public class Geometry {
    public Location location;
    public String locationType;
    public Viewport viewport;
}
public class Location {
    public Double lat;
    public Double lng;
}
public class Northeast {
    public Double lat;
    public Double lng;
}
public class PlusCode {
    public String compoundCode;
    public String globalCode;
}
public class Result {
    public List<AddressComponent> addressComponents = null;
    public String formattedAddress;
    public Geometry geometry;
    public String placeId;
    public PlusCode plusCode;
    public List<String> types = null;
}
public class Southwest {
    public Double lat;
    public Double lng;
}
public class Viewport {
    public Northeast northeast;
    public Southwest southwest;
}
/*-------------------Google API Response class-------------------------------------------------*/    

  
}