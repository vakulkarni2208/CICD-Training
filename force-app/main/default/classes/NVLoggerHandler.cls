/**************************************************************************************************
* Name       : NVLoggerHandler
* Purpose    : NVLoggerHandler class is to log status of integration services.
***************************************************************************************************
* Author            | Version    | Created Date      | Description
***************************************************************************************************
*Venkat G           | 1.0        |  December 19,2018  | create NVLog record for each of the service call
**************************************************************************************************/

public without sharing class NVLoggerHandler{

    /**
    * @description  This method is to create exception/error log if any faced while integration with external systems.
    * @param  API_InfoWrapper : This is wrapper class which having information like error/success detail, request message, response message etc.
    * @return Void : It does not return anything.
    */      
    public static void createErrorLog(API_InfoWrapper apiErrWrapperObj){
    
        NV_Log__c api_Error_Logger = new NV_Log__c() ;
        
        if( apiErrWrapperObj.sObjectType == 'Account' && apiErrWrapperObj.relatedRecordId <> null ){
            api_Error_Logger.Account__c = apiErrWrapperObj.relatedRecordId;      
        }
        api_Error_Logger.Exception__c = apiErrWrapperObj.errorName;        
        api_Error_Logger.Inbound_Outbound__c =  apiErrWrapperObj.requestType;
        api_Error_Logger.Integration_Type__c = apiErrWrapperObj.integrationType ;
        api_Error_Logger.Source_System__c = apiErrWrapperObj.sourceSystem ;
        api_Error_Logger.Target_System__c = apiErrWrapperObj.targetSystem ;        
        api_Error_Logger.StatusCode__c  = apiErrWrapperObj.logResGetStatusCode ;
        api_Error_Logger.WebMethod_Name__c = apiErrWrapperObj.logReqMethod ;
        api_Error_Logger.EndpointURL__c = apiErrWrapperObj.logReqGetEndpoint ;
        api_Error_Logger.WebServiceName__c = apiErrWrapperObj.webServiceName ;
        api_Error_Logger.Status__c = apiErrWrapperObj.responseType ;
        api_Error_Logger.Request__c = apiErrWrapperObj.Request;
        api_Error_Logger.Response__c = apiErrWrapperObj.Response;
        
        try{
        system.debug('inside');
            Database.SaveResult sr = Database.insert(api_Error_Logger, false);
            system.debug('inside'+sr);
        }
        catch(DMLException ex){
            System.debug('ExceptionMessage :: '+ex.getMessage());
        }
    }
    
    /**
    * @description : This method is to createinstance of nv log.
    * @param       :String logReqMethod,String logReqGetEndpoint,Integer logResGetStatusCode,String requestType,String integrationType,String webServiceName,String sourceSystem,String targetsystem,String logReqGetBody,String responseType,String Response,String Request
    * @return Void : It does not return anything.
    */      
    public static void createNVLoggerWrapper(String logReqMethod,String logReqGetEndpoint,Integer logResGetStatusCode,String requestType,String integrationType,String webServiceName,String sourceSystem,String targetsystem,String logReqGetBody,String responseType,String Response,String Request){
        NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();
        apiErrorInfoObj.logReqMethod = logReqMethod;
        apiErrorInfoObj.logReqGetEndpoint = logReqGetEndpoint;
        apiErrorInfoObj.logResGetStatusCode = logResGetStatusCode;
        apiErrorInfoObj.requestType = requestType;
        apiErrorInfoObj.integrationType =  integrationType; 
        apiErrorInfoObj.sourceSystem = sourceSystem; 
        apiErrorInfoObj.targetsystem = targetsystem;
        apiErrorInfoObj.webServiceName = webServiceName;
        apiErrorInfoObj.responseType = responseType;
        apiErrorInfoObj.Request = Request;
        apiErrorInfoObj.Response = Response;
        NVLoggerHandler.createErrorLog(apiErrorInfoObj);
    }

    /**
    * @author Venkat
    * @date December 19,2018
    *
    * @description Wrapper Class for creating integration API Log
    */
    public class API_InfoWrapper{
        public string errorName ;
        public String relatedRecordId ;
        public String logReqMethod ;
        public String logReqGetEndpoint ;
        public String requestType ;
        public String integrationType ; 
        public String sourceSystem ; 
        public String targetsystem ;
        public String logReqGetBody ;
        public String logResGetBody ;
        public Integer logResGetStatusCode ;
        public string sObjectType ;
        public string WebServiceName ;
        public string responseType ;
        public string Request;
        public string Response;
    }    
    
    
}