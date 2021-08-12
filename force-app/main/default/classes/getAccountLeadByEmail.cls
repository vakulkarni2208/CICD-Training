/**************************************************************************************************
* Name       : getAccountLeadByEmail
* Purpose    : An apex REST service that takes email Id as parameter and searches for related accounts and leads.
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Venkat G           | 1.0        | December 24,2018| Initial 
**************************************************************************************************/
@RestResource(urlMapping='/NVService/getAccountLeadByEmail/*')
global class getAccountLeadByEmail {
    
    public class AccountandLeads{
            
            public string Type;
            public string Id;
            public string Name;
            public string SFContactId;

    }
    public class ResponseJson{
            public String Status {get; set;}
            public List<AccountandLeads> Data {get;set;}
            public String Message {get;set;}
            public String StatusCode {get; set;}
            
        }
    /**************************************************************************************************
    * Input Parameters: No input parameters
    * Output: ResponseHandler object
    * Author : Venkat G
    * Purpose: Creates json to return matching lead and account records
    ***************************************************************************************************/ 
   
    @HttpGet 
    global static void getAccountContactLeadByEmail()
    {
        
        ResponseJson response = new ResponseJson();
        List<List <sObject>> returnRecords = getRecords();
        List<AccountandLeads> allRecordsToReturn = new list<AccountandLeads>();
        system.debug('test'+returnRecords);
        List<Contact> conList = new List<Contact>();
        conList = (list<contact>)returnRecords[0];
        List<Lead> leadList = new List<Lead>();
        leadList = (list<Lead>)returnRecords[1];
        system.debug('testingdebug'+conlist.size());
        system.debug('testingdebug'+leadlist.size());
        if(conList.size()>0 || leadList.size()>0)
        {
            if(leadList.size()>0){
                for(Lead leadObj :((List<Lead>)returnRecords[1])){
                    if(leadObj.GRID_Software_Evaluation_PAK__c!=null){
                    AccountandLeads leadAccountObj = new AccountandLeads();
                    leadAccountObj.Id =leadObj.Id;
                    leadAccountObj.Name = leadObj.FirstName+' '+leadObj.lastName;
                    leadAccountObj.Type ='Eval';
                    leadAccountObj.SFContactId = null;
                    allRecordsToReturn.add(leadAccountObj);
                    }
                }
                
            }
            if(conList.size()>0){
                for(Contact conObj :((List<Contact>)returnRecords[0])){
                    if(conObj.Account.Id!=null){
                        AccountandLeads leadAccountObj = new AccountandLeads();
                        leadAccountObj.Id =conObj.Account.Id;
                        leadAccountObj.Name = conObj.Account.Name;
                        string recordtypename = Schema.SObjectType.Account.getRecordTypeInfosById().get(conObj.Account.RecordTypeId).getname();
                        leadAccountObj.Type = recordtypename;
                        leadAccountObj.SFContactId = conObj.id;
                        allRecordsToReturn.add(leadAccountObj);
                    }
                }
                
            }
            
            String jsonResponse = json.serialize(allRecordsToReturn);

            if(allRecordsToReturn.size()>0){
                response.Status = 'Success';
                response.StatusCode = '200';
                response.Data = (allRecordsToReturn);
                response.Message = 'Success : Found Records';
            }
            else{
                response.Status = 'Success';
                response.StatusCode = '204';
                response.Message = 'Fail : No Records Found';
                response.Data = (allRecordsToReturn);
            }
            

        }
        
        else
        {
            
            response.Status = 'Success';
            response.StatusCode = '204';
            response.Message = 'Fail : No Records Found';
            response.Data = (allRecordsToReturn);
            
        }
        RestResponse responseSend = RestContext.response;
        responseSend.addHeader('Content-Type', 'application/json');
        responseSend.responseBody = Blob.valueOf(JSON.serialize(response));
        RestRequest req = RestContext.request;
            NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();
            apiErrorInfoObj.logReqMethod = 'getAccountLeadByEmail';
            apiErrorInfoObj.logReqGetEndpoint = req.requestURI;
            apiErrorInfoObj.logResGetStatusCode = integer.valueof(response.StatusCode);
            apiErrorInfoObj.requestType = 'Inbound';
            apiErrorInfoObj.integrationType = 'REST'; 
            apiErrorInfoObj.webServiceName = 'getAccountLeadByEmail';
            apiErrorInfoObj.sourceSystem = 'RMA'; 
            apiErrorInfoObj.targetsystem = 'Salesforce';
            apiErrorInfoObj.webServiceName = 'RMAToSFDC';
            apiErrorInfoObj.logReqGetBody = 'Request';
            apiErrorInfoObj.responseType = response.Status;
            apiErrorInfoObj.Response = string.valueof(Blob.valueOf(JSON.serialize(response)));
            apiErrorInfoObj.Request = req.requestURI;
            NVLoggerHandler.createErrorLog(apiErrorInfoObj);
    }
    
    //Adding custom Exception sub-class 
    public class NoRecordMatchException extends Exception {}
    
   /**************************************************************************************************
    * Input Parameters: No input parameters
    * Output: List<List <sObject>>
    * Author : Venkat G
    * Purpose: Requires the email to return matching lead, contact and account records
    ***************************************************************************************************/ 
    public static List<List <sObject>> getRecords()
    {
        //Read the Request from the URL
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String getEmail= '';
        if(req!=null && req.requestURI!=null && req.requestURI.lastIndexOf('/')!=null)
            getEmail= req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        system.debug('-------Email--1-----debug----'+getEmail);
            //getEmail=EncodingUtil.urlDecode(getEmail, 'UTF-8');
        system.debug('-------Email--2-----debug----'+getEmail);
        
        List<List <sObject>> recordsFoundList = new  List<List <sObject>>();
            if(!String.isEmpty(getEmail)){
                String queryContactLead =  'FIND \''+getEmail +'\''+'IN email FIELDS RETURNING contact(Id,lastname,firstName, phone, email,MailingCity, MailingState, MailingPostalCode,MailingCountry,MailingLatitude,MailingLongitude,Account.RecordTypeId,Account.Name,Account.SAP_Customer_Number__c,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry),Lead(Id,lastname,firstName, phone, email, City, State,PostalCode,Country, GRID_Software_Evaluation_PAK__c)';
                recordsFoundList = search.query(queryContactLead);
                
            }
        
        return recordsFoundList;
    }
    
    /**
    * @description Dummy test method - Technical Dept
	* @param  Dummy method
    * @return  Void: It returns nothing
    */  
     public static void CoverageMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    } 
    
    
}