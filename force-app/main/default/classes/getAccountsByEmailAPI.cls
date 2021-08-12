/**************************************************************************************************
* Name       : getAccountByEmailAPI
* Purpose    : An apex REST service that takes email Id as parameter and searches for related accounts.
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Venkat G           | 1.0        | December 27,2018 | Initial 
**************************************************************************************************/
@RestResource(urlMapping='/NVService/getAccountByEmail/*')
global class getAccountsByEmailAPI {
     public class AccountDetails{
            
            public string Type;
            public string Id;
            public string Name;

    }
    public class ResponseJson{
            public String Status {get; set;}
            public AccountDetails Data {get;set;}
            public String Message {get;set;}
            public String StatusCode {get; set;}
            
        }
    /**************************************************************************************************
    * Input Parameters: No input parameters
    * Output: ResponseJson object  
    * Author : Venkat G
    * Purpose: Creates json response for matched accounts by contact email
    ***************************************************************************************************/ 
     
    @HttpGet 
    global static void getAccountByEmail()
    {
        ResponseJson response = new ResponseJson();
        List<Contact> returnRecords = getRecords();
        AccountDetails accountObj = new AccountDetails();
        if(!returnRecords.isEmpty() && returnRecords.size()>0)
        {
            List<Account> accountList = new List<Account>();
            List<Id> accountListId = new List<Id>();
                for(contact conObj:returnRecords){                    
                    accountListId.add(conObj.AccountId);
                }
               
                if(!accountListId.isEmpty() && accountListId.size()>0){
                    
                    accountObj.Id =returnRecords[0].Account.Id;
                    accountObj.Name = returnRecords[0].Account.Name;
                    string recordtypename = Schema.SObjectType.Account.getRecordTypeInfosById().get(returnRecords[0].Account.RecordTypeId).getname();
                    accountObj.Type = recordtypename;
                    response.Status = 'Success';
                    response.StatusCode = '200';
                    response.Data = accountObj;
                    response.Message = 'Success : Found Records';
                    
                    }
                 else{
                     response.StatusCode = '204';
                     response.Status = 'Success';
                     response.Data = null;
                     response.Message = 'Fail : No Records Found';
                    }
        }
        
        else
        {
            response.StatusCode = '204';
            response.Status = 'Success';
            response.Message = 'Fail : No Records Found';
            response.Data = null;
        }
        RestResponse responseSend = RestContext.response;
        responseSend.addHeader('Content-Type', 'application/json');
        responseSend.responseBody = Blob.valueOf(JSON.serialize(response));
        RestRequest req = RestContext.request;
            NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();
            apiErrorInfoObj.logReqMethod = 'getAccountByEmail';
            apiErrorInfoObj.logReqGetEndpoint = req.requestURI;
            apiErrorInfoObj.logResGetStatusCode = integer.valueof(response.StatusCode);
            apiErrorInfoObj.requestType = 'Inbound';
            apiErrorInfoObj.integrationType = 'REST'; 
            apiErrorInfoObj.webServiceName = 'getAccountByEmail';
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
    * Output: Contact List  
    * Author : Venkat G
    * Purpose: Requires the email to return matching account records
    ***************************************************************************************************/ 
    public static List<Contact> getRecords()
    {
        //Read the Request from the URL
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String getEmail= '';
        if(req!=null && req.requestURI!=null && req.requestURI.lastIndexOf('/')!=null)
            getEmail= req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            getEmail = EncodingUtil.urlDecode(getEmail, 'UTF-8');
        List<Contact> recordsFoundList = new  List<Contact>();
        
            if(!String.isEmpty(getEmail)){
                List<Contact> conList = [select id,AccountId,Account.Name,Account.SAP_Customer_Number__c,Account.BillingCity,Account.RecordType.Name,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.Type,Account.RecordTypeId from Contact where email=:getEmail];
                recordsFoundList.addAll(conList);
            }
       
        return recordsFoundList;
    }
    
    
}