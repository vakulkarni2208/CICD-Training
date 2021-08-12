/**************************************************************************************************
* Name       : getAccountBySerialNumber
* Purpose    : An apex REST service that takes email Id as parameter and searches for related accounts.
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Venkat G           | 1.0        | December 27,2018 | Initial 
**************************************************************************************************/
@RestResource(urlMapping='/NVService/getAccountBySerialNumber/*')
global class getAccountBySerialNumber {
     public class AccountDetails{
            
            public string Type;
            public string Id;
            public string Name;

    }
    public class ResponseJson{
            public String Status {get; set;}
            public List<AccountDetails> Data {get;set;}
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
    global static void getAccountBySerialNumber()
    {
        ResponseJson response = new ResponseJson();
        List<accountDetails> accountDetailList = getRecord();
        
        if(accountDetailList!=null && accountDetailList.size()>0)
        {
            response.Status = 'Success';
            response.StatusCode = '200';
            response.Data = accountDetailList;
            response.Message = 'Success : Found Records';
                    
        }
        else{  
            response.StatusCode = '204';
            response.Status = 'Success';
            response.Data = null;
            response.Message = 'Fail : No Records Found';
            }   
            RestResponse responseSend = RestContext.response;
            responseSend.addHeader('Content-Type', 'application/json');
            responseSend.responseBody = Blob.valueOf(JSON.serialize(response));
            RestRequest req = RestContext.request;
            NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();
            apiErrorInfoObj.logReqMethod = 'getAccountBySerialNumber';
            apiErrorInfoObj.logReqGetEndpoint = req.requestURI;
            apiErrorInfoObj.logResGetStatusCode = integer.valueof(response.StatusCode);
            apiErrorInfoObj.requestType = 'Inbound';
            apiErrorInfoObj.integrationType = 'REST'; 
            apiErrorInfoObj.webServiceName = 'getAccountBySerialNumber';
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
    public static List<accountDetails> getRecord()
    {
        //Read the Request from the URL
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String getSerialNumber= '';
        List<accountDetails> accountDetailList = new List<accountDetails>();
        Map<Id,accountDetails> accountDetailMap = new Map<Id,accountDetails>();
        if(req!=null && req.requestURI!=null && req.requestURI.lastIndexOf('/')!=null)
            getSerialNumber = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        // Account accountObj = new Account();
         getSerialNumber=EncodingUtil.urlDecode(getSerialNumber, 'UTF-8');
        
            if(!String.isEmpty(getSerialNumber)){
                List<Entitlement> entitlementList = [select id,AccountId,Account.Name,Account.SAP_Customer_Number__c,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.RecordTypeId, Entitlement_Status__c from Entitlement where Hardware_Serial_Number__c  =:getSerialNumber and Entitlement_Status__c =:'Active'];
                if(entitlementList!=null && entitlementList.size()>0){
                    for(Entitlement entitlementObj:entitlementList){
                        accountDetails accountDetailObj= new accountDetails();
                        if(entitlementObj.AccountId!=null){
                            accountDetailObj.Id = entitlementObj.AccountId;
                            accountDetailObj.Name = entitlementObj.Account.Name;
                            string recordtypename = Schema.SObjectType.Account.getRecordTypeInfosById().get(entitlementObj.Account.RecordTypeId).getname();
                            accountDetailObj.Type = recordtypename;
                            if(!accountDetailMap.containsKey(accountDetailObj.Id)){
                                accountDetailMap.put(accountDetailObj.Id,accountDetailObj);
                            }
                        }
                    }
                }
            
            accountDetailList.addall(accountDetailMap.values());                 
            }
        
        return accountDetailList;
    }
}