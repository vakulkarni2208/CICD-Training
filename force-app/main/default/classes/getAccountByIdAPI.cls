/**************************************************************************************************
* Name       : getAccountByIdAPI
* Purpose    : An apex REST service that takes email Id as parameter and searches for related accounts.
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Venkat G           | 1.0        | December 27,2018 | Initial 
**************************************************************************************************/
@RestResource(urlMapping='/NVService/getAccountById/*')
global class getAccountByIdAPI {
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
    * Purpose: Creates json response for matched account by id
    ***************************************************************************************************/ 
     
    @HttpGet 
    global static void getAccountById()
    {
        ResponseJson response = new ResponseJson();
        accountDetails returnRecords = getRecord();
        
        if(returnRecords.Id!=null)
        {
            response.Status = 'Success';
            response.StatusCode = '200';
            response.Data = returnRecords;
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
            apiErrorInfoObj.logReqMethod = 'getAccountById';
            apiErrorInfoObj.logReqGetEndpoint = req.requestURI;
            apiErrorInfoObj.logResGetStatusCode = integer.valueof(response.StatusCode);
            apiErrorInfoObj.requestType = 'Inbound';
            apiErrorInfoObj.integrationType = 'REST'; 
            apiErrorInfoObj.webServiceName = 'getAccountById';
            apiErrorInfoObj.sourceSystem = 'RWA'; 
            apiErrorInfoObj.targetsystem = 'Salesforce';
            apiErrorInfoObj.webServiceName = 'RWAToSFDC';
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
    * Output: accountDetails   
    * Author : Venkat G
    * Purpose: Requires the account id to return matching account record
    ***************************************************************************************************/ 
    public static accountDetails getRecord()
    {
        //Read the Request from the URL
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String getAccountId= '';
        accountDetails accountDetailObj = new accountDetails();
        if(req!=null && req.requestURI!=null && req.requestURI.lastIndexOf('/')!=null)
            getAccountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            if(!String.isEmpty(getAccountId)){
                List<Account> accObjList = [select id,Name,RecordTypeId from Account where Id =:getAccountId];
                if(accObjList!=null && accObjList.size()>0){
                    
                    accountDetailObj.Id = accObjList[0].Id;
                    accountDetailObj.Name = accObjList[0].Name;
                    string recordtypename = Schema.SObjectType.Account.getRecordTypeInfosById().get(accObjList[0].RecordTypeId).getname();
                    accountDetailObj.Type = recordtypename;
                  
                    }      
            }
        return accountDetailObj;
    }
}