/**************************************************************************************************
* Name       : getAccountByPAKIdAndSerialNumber
* Purpose    : An apex REST service used to pass entitlement PAKId or entitlement serialnumber and send back the related account record
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Venkat G           | 1.0        |  December 26,2018 | Initial 
*Venkat G           | 1.1        |  January 04,2019  | Added post method 
**************************************************************************************************/

@RestResource(urlMapping='/NVService/getAccountByPAKId/*')
global class getAccountByPAKIdAndSerialNumber {
        
    public class jsonRequest{
        public String PAKID;
        public String SerialNumber;  
    }
    public class ResponseJson{
            public String Status {get; set;}
            public List<AccountDetails> Data {get;set;}
            public String Message {get;set;}
            public String StatusCode {get; set;}
            
    }
    public class accountDetails{
        public String Id;
        public String Name;  
        public String Type; 
    }
    /**************************************************************************************************
    * Input Parameters: No input parameters
    * Output: ResponseHandler object   
    * Author : Venkat G
    * Purpose:  Creates json to return account
    ***************************************************************************************************/ 
  
    @HttpGet 
    global static void getAccountByPAKId()
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
        apiErrorInfoObj.logReqMethod = 'getAccountByPAKId';
        apiErrorInfoObj.logReqGetEndpoint = req.requestURI;
        apiErrorInfoObj.logResGetStatusCode = integer.valueof(response.StatusCode);
        apiErrorInfoObj.requestType = 'Inbound';
        apiErrorInfoObj.integrationType = 'REST'; 
        apiErrorInfoObj.webServiceName = 'getAccountByPAKId';
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
    * Purpose: Requires the pak id to return matching account record
    ***************************************************************************************************/ 
    public static List<accountDetails> getRecord()
    {
        //Read the Request from the URL
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String getPAKId= '';
        List<accountDetails> accountDetailList = new List<accountDetails>();
        Map<Id,accountDetails> accountDetailMap = new Map<Id,accountDetails>();

        if(req!=null && req.requestURI!=null && req.requestURI.lastIndexOf('/')!=null)
            getPAKId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        // Account accountObj = new Account();
         getPAKId=EncodingUtil.urlDecode(getPAKId, 'UTF-8');

        system.debug('test'+getPAKId);
            if(!String.isEmpty(getPAKId)){
                List<Entitlement> entitlementList = [select id,AccountId,Account.Name,Account.SAP_Customer_Number__c,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.RecordTypeId from Entitlement where PAK_ID__c  =:getPAKId];
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