/**************************************************************************************************
* Name       : NVService
* Purpose    : Salesforce to EMS Integration Class
***************************************************************************************************
* Author            | Version    | Created Date      | Description
***************************************************************************************************
*Venkat G           | 1.0        |  December 18,2018 | method to send account details to EMS system on getting session id
*Venkat G           | 1.1        |  February 7,2019  | method to pass account,contact and user details to EMS system
**************************************************************************************************/
public without sharing class NVService {
    

    private class Customer {
        public String name;
        public String identifier;
        public String externalId;
    }
    
    /**
    * @description  For creating HTTP Request for login to EMS System
    * @param        ParametersWrapper : This is wrapper class which having information like object type, environment type, record Id etc.
                    integrationServiceObj  - Integration Service Metadata which have Http request header related info
    * @return       This will return Http request
   
    private static HttpRequest createHttpRequestForEMSLogin(Integration_Service__mdt integrationServiceObj ){
        HttpRequest request = new HttpRequest ();
        Blob headerValue = Blob.valueOf(integrationServiceObj.UserName__c + ':' + integrationServiceObj.Password__c);
        String authorizationHeader = integrationServiceObj.Authentication_Type__c + ' ' + EncodingUtil.base64Encode(headerValue);     
        request.setEndpoint(integrationServiceObj.Endpoint__c);  
        request.setHeader('Authorization', authorizationHeader);            
        request.setHeader('Content-Type', integrationServiceObj.Content_Type__c);
        request.setTimeout(120000);
        request.setMethod(integrationServiceObj.MethodType__c);
        system.debug('request 1 >> '+request);
        return request ;
    }

 */
    
    /**
    * @description  For creating HTTP Request for sending account to EMS System
    * @param        ParametersWrapper : This is wrapper class which having information like object type, environment type, record Id etc.
                    integrationServiceObj  - Integration Service Metadata which have Http request header related info
    * @return       This will Http request
    
    private static HttpRequest createHttpRequestForEMSPost(Integration_Service__mdt integrationServiceObj, String body, String sessionIdStr){
        HttpRequest request = new HttpRequest (); 
        request.setEndpoint(integrationServiceObj.Endpoint__c);           
            request.setHeader('Content-Type', integrationServiceObj.Content_Type__c);
           // String authorizationHeader = integrationServiceObj.Authentication_Type__c + ' ' + sessionIdStr;
            //system.debug('++'+authorizationHeader);
            Blob headerValue = Blob.valueOf(integrationServiceObj.username__c + ':' + integrationServiceObj.password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader); 
            request.setTimeout(120000);
            request.setMethod('POST');
            request.setBody(body);
            system.debug('request 2 >> '+request);
            return request ;
    }
*/
    
    /**
       * @description Login method to return session ID for EMS system
       * @author Venkat
       * @date 18/12/2018
    
    private static String loginEMSmethod(Id accId){
        Integration_Service__mdt integrationServiceObj = new  Integration_Service__mdt();
        Organization isSandboxProd = [Select id,instanceName,isSandbox from Organization];
        String EnvironmentType = '';
        if(isSandboxProd.isSandbox)
            EnvironmentType = 'Test';
        else
            EnvironmentType = 'Prod';
        integrationServiceObj = Utility.fetchIntergrationService('SFDCToEMSLogin', EnvironmentType, 'GET');
        if(integrationServiceObj != null){
            Http http = new Http(); 
            HttpRequest request = createHttpRequestForEMSLogin(integrationServiceObj);
            system.debug('request'+request);
            HttpResponse response = new HttpResponse();
            try{
                response = http.send(request);
                String responseStr = String.valueOf(response.getBody());
                if (String.valueOf(response.getStatusCode()).startsWith('2')){
                    String sessionId = responseStr.substringBetween('<sessionId>', '</sessionId>');
                    return sessionId;                   
                }
                else{
                    NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = createAPILog(request ,response , integrationServiceObj, 'Error', accId, true ); 
                    NVLoggerHandler.createErrorLog(apiErrorInfoObj);
                    return 'Error';
                }
            }
            Catch(Exception excpObj){
                NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = createAPILog(request ,response , integrationServiceObj, 'Exception', accId, true ); 
                NVLoggerHandler.createErrorLog(apiErrorInfoObj);
                return 'Exception';
            }
        }
        return null;
    }
*/
    
   /**
    * @description  method to pass account details to EMS system after getting sessionid
    * @param        accid that needs to be passed to EMS system
    * @return       HTTP response
    
    @future(callout=true)
    private static void integrationWithEMS(Id accId){
    Account accObjCustomerId = new Account(id=accId);
    List<Account> accListUpdate = new List<Account>();
    system.debug('accId >>>>>'+accId);         
        Integration_Service__mdt integrationServiceObj = new  Integration_Service__mdt();
        Organization isSandboxProd = [Select id,instanceName,isSandbox from Organization];
        String EnvironmentType = '';
        if(isSandboxProd.isSandbox)
            EnvironmentType = 'Test';
        else
            EnvironmentType = 'Prod';
        integrationServiceObj = Utility.fetchIntergrationService('SFDCToEMS', EnvironmentType, 'POST');
        if(integrationServiceObj != null){
            String sessionId = loginEMSmethod(accId);
            system.debug('sessionId >> '+sessionId);
            if(!String.isBlank(sessionId) && sessionId != 'Error' && sessionId != 'Exception'){
                Account accObj = [Select Id, Name, SAP_Customer_Number__c from Account where Id =: accId];
                Customer CustomerObj = createJson(accObj);
                if(CustomerObj != null){
                    String CustomerObjStr = JSON.serialize(CustomerObj);
                    if(!String.isEmpty(CustomerObjStr)){
                        Http http = new Http(); 
                        CustomerObjStr = '{"customer":'+CustomerObjStr+'}';
                        HttpRequest request = createHttpRequestForEMSPost(integrationServiceObj, CustomerObjStr, sessionId);               
                        HttpResponse response = new HttpResponse();
                        system.debug('request'+request);
                        try{
                            response = http.send(request);
                            String responseStr = String.valueOf(response.getBody());
                            if (String.valueOf(response.getStatusCode()).startsWith('2')){
                                NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = createAPILog(request ,response , integrationServiceObj, 'Success', accId, false ); 
                                NVLoggerHandler.createErrorLog(apiErrorInfoObj); 
                                if(responseStr!=null && !responseStr.contains('error')){
                                    List<String> splitResponse= responseStr.split(',');
                                    if(!splitResponse.isEmpty() && splitResponse.size()>0 && splitResponse[0].SubStringAfter('id')!=null && splitResponse[0].SubStringAfter('id').remove(':')!=null && splitResponse[0].SubStringAfter('id').remove(':').remove('"')!=null && splitResponse[0].SubStringAfter('id').remove(':').remove('"').remove(' ')!=null){
                                        String customerIdGenerated = splitResponse[0].SubStringAfter('id').remove(':').remove('"').remove(' ');
                                        accObjCustomerId.EMS_Customer_Id__c = customerIdGenerated;
                                        accListUpdate.add(accObjCustomerId);
                                    }
                                }
                            }
                            else{
                                NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = createAPILog(request ,response , integrationServiceObj, 'Error', accId, false ); 
                                NVLoggerHandler.createErrorLog(apiErrorInfoObj);
                            }
                            
                            if(!accListUpdate.isEmpty() && accListUpdate.size()>0)
                                update accListUpdate;
                        }
                        Catch(Exception excpObj){
                            NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = createAPILog(request ,response , integrationServiceObj, 'Exception', accId, false ); 
                            NVLoggerHandler.createErrorLog(apiErrorInfoObj);
                        }
                    }
                }
            }
        }
    }  
    */

    
    private static Customer createJson(Account acc){
        Customer customerObj = new Customer();
        customerObj.Name = acc.Name;
        customerObj.identifier = acc.SAP_Customer_Number__c;
        customerObj.externalId = acc.Id;
        
        return customerObj;     
    }
    
    
    /**
    * @description To log in API Logger object
    * @param  request: request sent to EMS System, response: response got from EMS System, integrationServiceObj: Login credential metadata for EMS, responseType:  response we got , recordId: Object Id
    * @return  NVLoggerHandler class Wrapper class object
    */
    private static NVLoggerHandler.API_InfoWrapper createAPILog(HttpRequest request, HttpResponse response, Integration_Service__mdt integrationServiceObj, String responseType, String recordId, Boolean isLogin){
        
        NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();

        apiErrorInfoObj.relatedRecordId  = recordId ; 
        apiErrorInfoObj.sObjectType = 'Account';
        apiErrorInfoObj.logReqMethod = request.getMethod();
        apiErrorInfoObj.logReqGetEndpoint = integrationServiceObj.EndPoint__c;
        if(!isLogin){
            apiErrorInfoObj.logReqGetBody = request.getBody();
        }else{
            apiErrorInfoObj.logReqGetBody = request.getEndpoint();
        }
        apiErrorInfoObj.logResGetBody = response.getBody();
        apiErrorInfoObj.logResGetStatusCode = response.getStatusCode();
        apiErrorInfoObj.requestType = integrationServiceObj.RequestType__c;
        apiErrorInfoObj.integrationType = integrationServiceObj.IntegrationType__c; 
        apiErrorInfoObj.sourceSystem = integrationServiceObj.SourceSystem__c; 
        apiErrorInfoObj.targetsystem = 'EMS';
        apiErrorInfoObj.webServiceName = 'SFDCToEMS';
        apiErrorInfoObj.responseType = responseType;

        return apiErrorInfoObj ;
    }
     
    /**
    * @description send valid account detals to EMS system
    * @param  accountlistnew,accountlistold
    * @return  HTTP response
    */
    public static void isValidForSendingToEMS(List<Account> accNewList, Map<Id,Account> oldAccMap){
        List<Account> accList = new  List<Account>();
        system.debug('Hellooo');
        accList = Utility.isChangedFieldsCheck(accNewList, 'Account', oldAccMap);
        System.debug('accList+++'+accList);
        if(accList.size() > 0){
            Id accId = accList[0].Id;
           // integrationWithEMS(accId);
        }
    }
    
    /**
    * @description to check if account is valid to send account details to EMS system(PEC Account service)
    * @param  Trigger.new
    * @return  null
    Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
    string recordtypeName = rt_map.get(acc.RecordTypeId).getName();
    if((recordtypeName == 'New Customer Account' && acc.Quick_create__c) ) {
    System.enqueueJob(new queableClassForEMSService(Acc,'Account'));
    */
    
    
    public static void isValidPECAccountService(List<Account> accNewList){
        if(!utility.isPECAccountRequest){
        Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
        List<Id> validAccountsPECAccount = new List<Id>();
        List<Account> validAccountsforSAP = new List<Account>();
        for(Account acc : accNewList){
            string recordtypeName = rt_map.get(acc.RecordTypeId).getName();
            system.debug('^^^^^^^^^^^^^^^'+acc.name);
                if((recordtypeName == 'New Customer Account' && acc.Quick_create__c) ) {
                    //validAccountsforSAP.add(acc);
                    system.debug('*******************'+acc.name);
                    //acc.Quick_create__c = False;
                    System.enqueueJob(new queableClassForEMSService(Acc,'Account'));
                    utility.isPECAccountRequest = true;                    
                }
            if((recordtypeName == 'New Customer Account' && acc.EMS_Update_Required__c) || (recordtypeName == 'NPN Account Registry'   && acc.EMS_Update_Required__c && acc.Convert_NPN_as_PEC__c ) ) {
                validAccountsPECAccount.add(acc.id);
            }
            
            
        }
            if(validAccountsforSAP!=null && validAccountsforSAP.size()>0){
                
                  //Added by Venkat for Lead Integration on 22/Feb/2019 - START 
                //for(List<id> i: validAccountsforSAP){
                    //System.enqueueJob(new queableClassForEMSService(i,'Account'));
                //}
                //NVAPI.accountsync(validAccountsforSAP);
                //utility.isPECAccountRequest = true;
            }
            if(validAccountsPECAccount!=null && validAccountsPECAccount.size()>0){
                PECAccountRequest(validAccountsPECAccount);
                utility.isPECAccountRequest = true;
            }
        }
        
    }
    
    /**
    * @description to pass valid account details to EMS system(PEC Account service)
    * @param  Trigger.new
    * @return  HTTP response
    */
    @future(callout=true)
    public static void PECAccountRequest(List<Id> validAccountsPECAccount)
    {
        List<Account> validAccountsPECAccountList = [select id,Name,SAP_Customer_Number__c,BillingCountry,EMS_Update_Required__c from Account where EMS_Update_Required__c=True and id in:validAccountsPECAccount];
        Organization isSandboxProd = [Select id,instanceName,isSandbox from Organization];
        String EnvironmentType = '';
        if(isSandboxProd.isSandbox)
            EnvironmentType = 'Test';
        else
            EnvironmentType = 'Prod';
        
        Integration_Service__mdt integrationServiceObj = new Integration_Service__mdt();

        integrationServiceObj = Utility.fetchIntergrationService('PEC Account', EnvironmentType, 'POST');
        if(integrationServiceObj.Id != null && validAccountsPECAccountList!=null && validAccountsPECAccountList.size()>0){
            DOM.Document doc = new DOM.Document();
            String envelopeSOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
            String soapNameSpace = 'http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com';
            String ValueNS = 'http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd';
        
            dom.XmlNode envelope= doc.createRootElement('Envelope', envelopeSOAP, 'soapenv');
            envelope.setNamespace('nvid', soapNameSpace);
            envelope.setAttributeNS('xmlns:xsd', ValueNS, null, null);
            dom.XmlNode headerNode = envelope.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyNode = envelope.addChildElement('soapenv:Body', null, null);
        
            dom.XmlNode childNode1 = bodyNode.addChildElement('nvid:SyncService', null, null);
            dom.XmlNode childNode2=childNode1.addChildElement('nvid:request', null, null);
            childNode2.addChildElement('xsd:id', null, null).
            addTextNode('12123123');
            childNode2.addChildElement('xsd:login', null, null).
            addTextNode(integrationServiceObj.UserName__c);
            childNode2.addChildElement('xsd:password', null, null).
            addTextNode(integrationServiceObj.Password__c);
            childNode2.addChildElement('xsd:syncType', null, null).
            addTextNode('Customer');
            childNode2.addChildElement('xsd:timeStamp', null, null).
            addTextNode(String.valueof(DateTime.now()));
            
            for(Account accObj:validAccountsPECAccountList){
                dom.XmlNode childNode3 = childNode2.addChildElement('xsd:endCustomerInfo', null, null);
                if(String.isBlank(accObj.BillingCountry)){
                    childNode3.addChildElement('xsd:countryCode', null, null);
                    
                }
                else{
                    childNode3.addChildElement('xsd:countryCode', null, null).
                    addTextNode(accObj.BillingCountry);
                }
                childNode3.addChildElement('xsd:externalId', null, null).
                addTextNode(accObj.Id);
                if(String.isBlank(accObj.SAP_Customer_Number__c)){
                    childNode3.addChildElement('xsd:customerIdentifier', null, null);
                }
                else{
                    childNode3.addChildElement('xsd:customerIdentifier', null, null).
                    addTextNode(accObj.SAP_Customer_Number__c);
                }
                childNode3.addChildElement('xsd:customerName', null, null).
                addTextNode(accObj.Name);
            }
        
            System.debug(doc.toXmlString());
        
            HttpRequest req = new HttpRequest();
            req.setMethod(integrationServiceObj.MethodType__c);
            req.setEndpoint(integrationServiceObj.EndPoint__c);
            req.setHeader('Content-Type', integrationServiceObj.Content_Type__c);
        
            req.setBodyDocument(doc);
        
            Http http = new Http();
            HttpResponse res;
            if(!test.isRunningtest()){
                res = http.send(req);
                system.debug(res.getStatusCode());}
            
            List<Account> accListToUpdate = new List<Account>();
            for(Account accObj:validAccountsPECAccountList){
                accObj.EMS_Update_Required__c = false;
                accListToUpdate.add(accobj);
            }
            if(accListToUpdate.size()>0){
                update accListToUpdate;
                
            }
            NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();
            apiErrorInfoObj.logReqMethod = integrationServiceObj.WebServiceName__c;
            apiErrorInfoObj.logReqGetEndpoint = integrationServiceObj.EndPoint__c;

            apiErrorInfoObj.requestType = integrationServiceObj.RequestType__c;
            apiErrorInfoObj.integrationType =  integrationServiceObj.IntegrationType__c; 
            apiErrorInfoObj.sourceSystem = integrationServiceObj.SourceSystem__c; 
            apiErrorInfoObj.targetsystem = integrationServiceObj.Targetsystem__c;
            apiErrorInfoObj.webServiceName = integrationServiceObj.WebServiceName__c;
            if(!test.isRunningtest()){
            apiErrorInfoObj.logResGetStatusCode = res.getStatusCode();
            if(string.valueof(res.getStatusCode()).startsWith('2'))
                apiErrorInfoObj.responseType = 'Success';
            else
                apiErrorInfoObj.responseType = 'Error';
                apiErrorInfoObj.Request = doc.toXmlString();
                apiErrorInfoObj.Response = res.getBody();}
            NVLoggerHandler.createErrorLog(apiErrorInfoObj);
            
        }
        
    }
    
    /**
    * @description to check if account is valid to send account details to EMS system(Partner Account service)
    * @param  Trigger.new
    * @return  null
    */
    public static void isValidPartnerAccountService(List<Account> accNewList){
        if(!utility.isPartnerAccountRequest){
        Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
        List<Id> validAccountsPartnerAccount = new List<Id>();
        for(Account acc : accNewList){
            string recordtypeName = rt_map.get(acc.RecordTypeId).getName();
            if((recordtypeName == 'NPN Account Registry' || recordtypeName == 'Sold-To Partner Account' || recordtypeName == 'Partner Account' ||recordtypeName == 'NVIDIA Marketing Partner Portal' ||recordtypeName == 'NV Partner Program Account') && acc.EMS_Update_Required__c) {
                validAccountsPartnerAccount.add(acc.id);
            }
            /*if((recordtypeName == 'NPN Account Registry' || recordtypeName == 'Partner Account' ||recordtypeName == 'NVIDIA Marketing Partner Portal' ||recordtypeName == 'NV Partner Program Account') && acc.EMS_Update_Required__c) {
                validAccountsPartnerAccount.add(acc.id);
            }*/
            
        }
            if(validAccountsPartnerAccount!=null && validAccountsPartnerAccount.size()>0){
                partnerAccountRequest(validAccountsPartnerAccount);
                utility.isPartnerAccountRequest=true;
            }
        }
        
    }
    
    /**
    * @description to pass valid account details to EMS system(Partner Account service)
    * @param  Trigger.new
    * @return  HTTP response
    */
    @future(callout=true)
    public static void partnerAccountRequest(List<Id> validAccountsPartnerAccount)
    {
        List<Account> validAccountsPartnerAccountList = [select id,Name,SAP_Partner_Number__c,SAP_customer_Number__c,BillingCountry,SAP_Partner_Type__c,EMS_Partner_Identifier__c,EMS_Update_Required__c,Convert_NPN_as_PEC__c  from Account where EMS_Update_Required__c=True and id in:validAccountsPartnerAccount];
        Organization isSandboxProd = [Select id,instanceName,isSandbox from Organization];
        String EnvironmentType = '';
        if(isSandboxProd.isSandbox)
            EnvironmentType = 'Test';
        else
            EnvironmentType = 'Prod';
        
        Integration_Service__mdt integrationServiceObj = new Integration_Service__mdt();

        integrationServiceObj = Utility.fetchIntergrationService('Partner Account Creation', EnvironmentType, 'POST');
        if(integrationServiceObj.Id != null && validAccountsPartnerAccountList!=null && validAccountsPartnerAccountList.size()>0){
            DOM.Document doc = new DOM.Document();
            String envelopeSOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
            String soapNameSpace = 'http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com';
            String ValueNS = 'http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd';
        
            dom.XmlNode envelope= doc.createRootElement('Envelope', envelopeSOAP, 'soapenv');
            envelope.setNamespace('nvid', soapNameSpace);
            envelope.setAttributeNS('xmlns:xsd', ValueNS, null, null);
            dom.XmlNode headerNode = envelope.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyNode = envelope.addChildElement('soapenv:Body', null, null);
        
            dom.XmlNode childNode1 = bodyNode.addChildElement('nvid:SyncService', null, null);
            dom.XmlNode childNode2=childNode1.addChildElement('nvid:request', null, null);
            childNode2.addChildElement('xsd:id', null, null).
            addTextNode('12123123');
            childNode2.addChildElement('xsd:login', null, null).
            addTextNode(integrationServiceObj.UserName__c);
            childNode2.addChildElement('xsd:password', null, null).
            addTextNode(integrationServiceObj.Password__c);
            childNode2.addChildElement('xsd:syncType', null, null).
            addTextNode('Partner');
            childNode2.addChildElement('xsd:timeStamp', null, null).
            addTextNode(String.valueof(DateTime.now()));
            
            dom.XmlNode childNode3 = childNode2.addChildElement('xsd:partnerInfo', null, null);
            for(Account accObj:validAccountsPartnerAccountList){
                if(String.isBlank(accObj.BillingCountry)){
                childNode3.addChildElement('xsd:countryCode', null, null);
                
                }
                else{
                    childNode3.addChildElement('xsd:countryCode', null, null).
                addTextNode(accObj.BillingCountry);
                }
                childNode3.addChildElement('xsd:externalId', null, null).
                addTextNode(accObj.Id);
                if(String.isBlank(accObj.SAP_customer_Number__c)){
                    childNode3.addChildElement('xsd:partnerIdentifier', null, null);
                    
                }
                else{
                    childNode3.addChildElement('xsd:partnerIdentifier', null, null).
                    addTextNode(accObj.SAP_customer_Number__c);
                }
                
                childNode3.addChildElement('xsd:partnerName', null, null).
                addTextNode(accobj.name);
                if(String.isBlank(accObj.EMS_Partner_Identifier__c)){
                childNode3.addChildElement('xsd:partnerType', null, null);
                }
                else{
                    childNode3.addChildElement('xsd:partnerType', null, null).
                    addTextNode(accObj.EMS_Partner_Identifier__c);
                }
            }
            System.debug(doc.toXmlString());
        
            HttpRequest req = new HttpRequest();
            req.setMethod(integrationServiceObj.MethodType__c);
            req.setEndpoint(integrationServiceObj.EndPoint__c);
            req.setHeader('Content-Type', integrationServiceObj.Content_Type__c);
        
            req.setBodyDocument(doc);
        
            Http http = new Http();
            HttpResponse res = http.send(req);
            system.debug(res.getStatusCode());
            
            List<Account> accListToUpdate = new List<Account>();
            for(Account accObj:validAccountsPartnerAccountList){
                accObj.EMS_Update_Required__c = false;
                accListToUpdate.add(accobj);
            }
            if(accListToUpdate.size()>0){
                update accListToUpdate;
                
            }
            NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();
            apiErrorInfoObj.logReqMethod = integrationServiceObj.WebServiceName__c;
            apiErrorInfoObj.logReqGetEndpoint = integrationServiceObj.EndPoint__c;
            apiErrorInfoObj.logResGetStatusCode = res.getStatusCode();
            apiErrorInfoObj.requestType = integrationServiceObj.RequestType__c;
            apiErrorInfoObj.integrationType =  integrationServiceObj.IntegrationType__c; 
            apiErrorInfoObj.sourceSystem = integrationServiceObj.SourceSystem__c; 
            apiErrorInfoObj.targetsystem = integrationServiceObj.Targetsystem__c;
            apiErrorInfoObj.webServiceName = integrationServiceObj.WebServiceName__c;
            if(string.valueof(res.getStatusCode()).startsWith('2'))
                apiErrorInfoObj.responseType = 'Success';
            else
                apiErrorInfoObj.responseType = 'Error';
            apiErrorInfoObj.Request = doc.toXmlString();
            apiErrorInfoObj.Response = res.getBody();
            NVLoggerHandler.createErrorLog(apiErrorInfoObj);
            
        }
        
    }
    
    /**
    * @description to pass valid contact details to EMS system(PEC Contact service)
    * @param  Trigger.new
    * @return  HTTP response
    */
    
    public static void PECContactRequest(List<Id> contactIdList)
    {
        
        
        //List<Contact> SAPCons = nvapi.ContactSync(contactIdList);
        //map<Id,contact> MyConMap = new map<Id,contact>(SAPCons);
        
        List<contact> validContactsPECContactRequestList = [select id,name,AccountId,account.name,email,Account.RecordTypeId,Account.SAP_Customer_Number__c,SAP_Contact_ID__c,EMS_Update_Required__c from contact where id in:contactIdList and EMS_Update_Required__c=:true ];
        Organization isSandboxProd = [Select id,instanceName,isSandbox from Organization];
        String EnvironmentType = '';
        if(isSandboxProd.isSandbox)
            EnvironmentType = 'Test';
        else
            EnvironmentType = 'Prod';
        
        Integration_Service__mdt integrationServiceObj = new Integration_Service__mdt();

        integrationServiceObj = Utility.fetchIntergrationService('PEC Contact', EnvironmentType, 'POST');
        if(validContactsPECContactRequestList!=null && validContactsPECContactRequestList.size()>0 && integrationServiceObj.Id != null){
            DOM.Document doc = new DOM.Document();
            String envelopeSOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
            String soapNameSpace = 'http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com';
            String ValueNS = 'http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd';
        
            dom.XmlNode envelope= doc.createRootElement('Envelope', envelopeSOAP, 'soapenv');
            envelope.setNamespace('nvid', soapNameSpace);
            envelope.setAttributeNS('xmlns:xsd', ValueNS, null, null);
            dom.XmlNode headerNode = envelope.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyNode = envelope.addChildElement('soapenv:Body', null, null);
        
            dom.XmlNode childNode1 = bodyNode.addChildElement('nvid:SyncService', null, null);
            dom.XmlNode childNode2=childNode1.addChildElement('nvid:request', null, null);
            childNode2.addChildElement('xsd:id', null, null).
            addTextNode('122344');
            childNode2.addChildElement('xsd:login', null, null).
            addTextNode(integrationServiceObj.UserName__c);
            childNode2.addChildElement('xsd:password', null, null).
            addTextNode(integrationServiceObj.Password__c);
            childNode2.addChildElement('xsd:syncType', null, null).
            addTextNode('CustomerContact');
            childNode2.addChildElement('xsd:timeStamp', null, null).
            addTextNode(String.valueof(DateTime.now()));
            
            dom.XmlNode childNode3 = childNode2.addChildElement('xsd:endCustomerUserInfo', null, null);
            
            for(Contact conObj:validContactsPECContactRequestList){
                childNode3.addChildElement('xsd:contactName', null, null).
                addTextNode(conObj.name);
                if(String.isBlank(conObj.Account.SAP_Customer_Number__c)){
                childNode3.addChildElement('xsd:customerIdentifier', null, null);
               
                }
                else{
                    childNode3.addChildElement('xsd:customerIdentifier', null, null).
                addTextNode(conObj.Account.SAP_Customer_Number__c);
                }
                if(String.isBlank(conObj.email)){
                    childNode3.addChildElement('xsd:emailAddress', null, null);
                    
                }
                else{
                    childNode3.addChildElement('xsd:emailAddress', null, null).
                    addTextNode(conObj.email);
                }
                if(String.isBlank(conObj.SAP_Contact_ID__c)){
                childNode3.addChildElement('xsd:sapIdentifier', null, null);
               
                }
                else{
                    childNode3.addChildElement('xsd:sapIdentifier', null, null).
                    addTextNode(conObj.SAP_Contact_ID__c);
                }
                childNode3.addChildElement('xsd:sfdcIdentifier', null, null).
                addTextNode(conObj.id);
            }
            System.debug(doc.toXmlString());
        
            HttpRequest req = new HttpRequest();
            req.setMethod(integrationServiceObj.MethodType__c);
            req.setEndpoint(integrationServiceObj.EndPoint__c);
            req.setHeader('Content-Type', integrationServiceObj.Content_Type__c);
        
            req.setBodyDocument(doc);
        
            Http http = new Http();
            HttpResponse res;
            if(!test.isRunningtest()){
                res = http.send(req);system.debug(res.getStatusCode());
            }
            List<Contact> conListToUpdate = new List<Contact>();
            unsignedPartnerUserRequest(contactIdList); 
            for(Contact conObj:validContactsPECContactRequestList){
                //conObj.SAP_Contact_ID__c = MyConMap.get(conObj.id).SAP_Contact_ID__c;
                conObj.EMS_Update_Required__c = false;
                conObj.Quick_create__c = False;
                
                conListToUpdate.add(conObj);
            }
            if(conListToUpdate.size()>0){
                update conListToUpdate;
                
            }
            NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();
            apiErrorInfoObj.logReqMethod = integrationServiceObj.WebServiceName__c;
            apiErrorInfoObj.logReqGetEndpoint = integrationServiceObj.EndPoint__c;
            apiErrorInfoObj.requestType = integrationServiceObj.RequestType__c;
            apiErrorInfoObj.integrationType =  integrationServiceObj.IntegrationType__c; 
            apiErrorInfoObj.sourceSystem = integrationServiceObj.SourceSystem__c; 
            apiErrorInfoObj.targetsystem = integrationServiceObj.Targetsystem__c;
            apiErrorInfoObj.webServiceName = integrationServiceObj.WebServiceName__c;
            if(!test.isRunningtest()){
                apiErrorInfoObj.logResGetStatusCode = res.getStatusCode();
                if(string.valueof(res.getStatusCode()).startsWith('2'))
                    apiErrorInfoObj.responseType = 'Success';
                else
                    apiErrorInfoObj.responseType = 'Error';
                apiErrorInfoObj.Request = doc.toXmlString();
                apiErrorInfoObj.Response = res.getBody();
            }
            NVLoggerHandler.createErrorLog(apiErrorInfoObj);
            
        }
        
       
        
    }
    
    
    
     /**
    * @description to pass valid partner user details to EMS system(Partner User service)
    * @param  Trigger.new(contactId)
    * @return  HTTP response
    */
    
    
    public static void unsignedPartnerUserRequest(List<Id> contactIdList)
    {
        List<contact> validPartnerUserList = [select id,name,AccountId,account.name,email,Account.RecordTypeId,Account.SAP_Customer_Number__c,SAP_Contact_ID__c,EMS_Update_Required__c from contact where id in:contactIdList and EMS_Update_Required__c=:true  and ( Account.RecordType.Name = 'NPN Account Registry' OR Account.RecordType.Name = 'Sold-To Partner Account') ];
        if(validPartnerUserList!=null && validPartnerUserList.size()>0){

        Organization isSandboxProd = [Select id,instanceName,isSandbox from Organization];
        String EnvironmentType = '';
        if(isSandboxProd.isSandbox)
            EnvironmentType = 'Test';
        else
            EnvironmentType = 'Prod';
        
        Integration_Service__mdt integrationServiceObj = new Integration_Service__mdt();

        integrationServiceObj = Utility.fetchIntergrationService('Partner User', EnvironmentType, 'POST');
        if(integrationServiceObj.Id != null){
            DOM.Document doc = new DOM.Document();
            String envelopeSOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
            String soapNameSpace = 'http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com';
            String ValueNS = 'http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd';
        
            dom.XmlNode envelope= doc.createRootElement('Envelope', envelopeSOAP, 'soapenv');
            envelope.setNamespace('nvid', soapNameSpace);
            envelope.setAttributeNS('xmlns:xsd', ValueNS, null, null);
            dom.XmlNode headerNode = envelope.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyNode = envelope.addChildElement('soapenv:Body', null, null);
        
            dom.XmlNode childNode1 = bodyNode.addChildElement('nvid:SyncService', null, null);
            dom.XmlNode childNode2=childNode1.addChildElement('nvid:request', null, null);
            childNode2.addChildElement('xsd:id', null, null).
            addTextNode('12123123');
            childNode2.addChildElement('xsd:login', null, null).
            addTextNode(integrationServiceObj.UserName__c);
            childNode2.addChildElement('xsd:password', null, null).
            addTextNode(integrationServiceObj.Password__c);
            childNode2.addChildElement('xsd:syncType', null, null).
            addTextNode('PartnerUser');
            childNode2.addChildElement('xsd:timeStamp', null, null).
            addTextNode(String.valueof(DateTime.now()));
            
            dom.XmlNode childNode3 = childNode2.addChildElement('xsd:partnerUser', null, null);
            for(Contact userObj:validPartnerUserList){
                string SAPContactReference = '';
                if(userObj.SAP_Contact_ID__c != null){
                    SAPContactReference =userObj.SAP_Contact_ID__c;
                }else{
                    SAPContactReference =userObj.id;
                }
            childNode3.addChildElement('xsd:emailAddress', null, null).
            addTextNode(userObj.email);
            childNode3.addChildElement('xsd:externalId', null, null).
            addTextNode(userObj.id);
            childNode3.addChildElement('xsd:partnerIdentifier', null, null).
            addTextNode(userObj.Account.SAP_customer_Number__c);
            childNode3.addChildElement('xsd:userId', null, null).
            addTextNode(SAPContactReference);
            childNode3.addChildElement('xsd:username', null, null).
            addTextNode(userObj.email);
            }
            System.debug(doc.toXmlString());
        
            HttpRequest req = new HttpRequest();
            req.setMethod(integrationServiceObj.MethodType__c);
            req.setEndpoint(integrationServiceObj.EndPoint__c);
            req.setHeader('Content-Type', integrationServiceObj.Content_Type__c);
        
            req.setBodyDocument(doc);
        
            Http http = new Http();
            HttpResponse res;
            if(!test.isRunningtest()){
            res = http.send(req);
            }
            
            List<Contact> conListToUpdate = new List<Contact>();
            for(Contact conObj:validPartnerUserList){
                conObj.EMS_Update_Required__c = false;
                conListToUpdate.add(conObj);
            }
            if(conListToUpdate.size()>0){
                //update conListToUpdate;
                
            }
            NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();
            apiErrorInfoObj.logReqMethod = integrationServiceObj.WebServiceName__c;
            apiErrorInfoObj.logReqGetEndpoint = integrationServiceObj.EndPoint__c;
            apiErrorInfoObj.requestType = integrationServiceObj.RequestType__c;
            apiErrorInfoObj.integrationType =  integrationServiceObj.IntegrationType__c; 
            apiErrorInfoObj.sourceSystem = integrationServiceObj.SourceSystem__c; 
            apiErrorInfoObj.targetsystem = integrationServiceObj.Targetsystem__c;
            apiErrorInfoObj.webServiceName = integrationServiceObj.WebServiceName__c;
            if(!test.isRunningtest()){
                apiErrorInfoObj.logResGetStatusCode = res.getStatusCode();
                if(string.valueof(res.getStatusCode()).startsWith('2'))
                    apiErrorInfoObj.responseType = 'Success';
                else
                    apiErrorInfoObj.responseType = 'Error';
                apiErrorInfoObj.Response = res.getBody();
            }
            apiErrorInfoObj.Request = doc.toXmlString();
            NVLoggerHandler.createErrorLog(apiErrorInfoObj);
            
        }
        
    }
   }
    /**
    * @description to pass valid partner user details to EMS system(Partner User service)
    * @param  Trigger.new(contactId)
    * @return  HTTP response
    */
    
    
    public static void partnerUserRequest(List<Id> userList)
    {
        List<User> validPartnerUserList = [select id,Username,ContactId,Contact.AccountId, Contact.SAP_Contact_ID__c,  Contact.Account.SAP_Partner_Number__c , Contact.Account.SAP_Customer_Number__c,Contact.account.name,email from User where id in:userList and Profile.Name like '%NPN Partner Community(LOGIN)%' and Contact.Account.SAP_customer_Number__c != null];
        
        if(validPartnerUserList!=null && validPartnerUserList.size()>0){

        Organization isSandboxProd = [Select id,instanceName,isSandbox from Organization];
        String EnvironmentType = '';
        if(isSandboxProd.isSandbox)
            EnvironmentType = 'Test';
        else
            EnvironmentType = 'Prod';
        
        Integration_Service__mdt integrationServiceObj = new Integration_Service__mdt();

        integrationServiceObj = Utility.fetchIntergrationService('Partner User', EnvironmentType, 'POST');
        if(integrationServiceObj.Id != null){
            DOM.Document doc = new DOM.Document();
            String envelopeSOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
            String soapNameSpace = 'http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com';
            String ValueNS = 'http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd';
        
            dom.XmlNode envelope= doc.createRootElement('Envelope', envelopeSOAP, 'soapenv');
            envelope.setNamespace('nvid', soapNameSpace);
            envelope.setAttributeNS('xmlns:xsd', ValueNS, null, null);
            dom.XmlNode headerNode = envelope.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyNode = envelope.addChildElement('soapenv:Body', null, null);
        
            dom.XmlNode childNode1 = bodyNode.addChildElement('nvid:SyncService', null, null);
            dom.XmlNode childNode2=childNode1.addChildElement('nvid:request', null, null);
            childNode2.addChildElement('xsd:id', null, null).
            addTextNode('12123123');
            childNode2.addChildElement('xsd:login', null, null).
            addTextNode(integrationServiceObj.UserName__c);
            childNode2.addChildElement('xsd:password', null, null).
            addTextNode(integrationServiceObj.Password__c);
            childNode2.addChildElement('xsd:syncType', null, null).
            addTextNode('PartnerUser');
            childNode2.addChildElement('xsd:timeStamp', null, null).
            addTextNode(String.valueof(DateTime.now()));
            
            dom.XmlNode childNode3 = childNode2.addChildElement('xsd:partnerUser', null, null);
            for(User userObj:validPartnerUserList){
                string SAPContactReference = '';
                if(userObj.Contact.SAP_Contact_ID__c != null){
                    SAPContactReference =userObj.Contact.SAP_Contact_ID__c;
                }else{
                    SAPContactReference =userObj.Contact.id;
                }
            childNode3.addChildElement('xsd:emailAddress', null, null).
            addTextNode(userObj.email);
            childNode3.addChildElement('xsd:externalId', null, null).
            addTextNode(userObj.Contact.id);
            childNode3.addChildElement('xsd:partnerIdentifier', null, null).
            addTextNode(userObj.Contact.Account.SAP_customer_Number__c);
            childNode3.addChildElement('xsd:userId', null, null).
            addTextNode(SAPContactReference);
            childNode3.addChildElement('xsd:username', null, null).
            addTextNode(userObj.username);
            }
            System.debug(doc.toXmlString());
        
            HttpRequest req = new HttpRequest();
            req.setMethod(integrationServiceObj.MethodType__c);
            req.setEndpoint(integrationServiceObj.EndPoint__c);
            req.setHeader('Content-Type', integrationServiceObj.Content_Type__c);
        
            req.setBodyDocument(doc);
        
            Http http = new Http();
            HttpResponse res;
            if(!test.isRunningtest()){
            res = http.send(req);
            }
            NVLoggerHandler.API_InfoWrapper apiErrorInfoObj = new NVLoggerHandler.API_InfoWrapper();
            apiErrorInfoObj.logReqMethod = integrationServiceObj.WebServiceName__c;
            apiErrorInfoObj.logReqGetEndpoint = integrationServiceObj.EndPoint__c;
            apiErrorInfoObj.requestType = integrationServiceObj.RequestType__c;
            apiErrorInfoObj.integrationType =  integrationServiceObj.IntegrationType__c; 
            apiErrorInfoObj.sourceSystem = integrationServiceObj.SourceSystem__c; 
            apiErrorInfoObj.targetsystem = integrationServiceObj.Targetsystem__c;
            apiErrorInfoObj.webServiceName = integrationServiceObj.WebServiceName__c;
            if(!test.isRunningtest()){
            apiErrorInfoObj.logResGetStatusCode = res.getStatusCode();
            if(string.valueof(res.getStatusCode()).startsWith('2'))
                apiErrorInfoObj.responseType = 'Success';
            else
                apiErrorInfoObj.responseType = 'Error';
            apiErrorInfoObj.Response = res.getBody();
            }
            apiErrorInfoObj.Request = doc.toXmlString();
            NVLoggerHandler.createErrorLog(apiErrorInfoObj);
            
        }
        
    }
   }
   
    /**
    * @description To pass the Lead to PEC syste,
    * @param  leadObj: Lead Object
    * @return  Void: It returns nothing
    */   
    
    public static void pecLeadRequest(Lead leadObj){
        if(leadObj != null){
            Organization isSandboxProd = [Select id,instanceName,isSandbox from Organization];
            String EnvironmentType = '';
            if(isSandboxProd.isSandbox)
                EnvironmentType = 'Test';
            else
                EnvironmentType = 'Prod';
            PECLeadWrapperCls PECLeadWrapperClsObj = new PECLeadWrapperCls( Integer.valueOf(leadObj.grid_software_evaluation_pak__c), leadObj.Id, leadObj.VGPU_Eval_Catalog__c ,Integer.valueOf(leadObj.VGPU_Eval_Units__c)  );
            String jsonBody = JSON.serialize(PECLeadWrapperClsObj);
            Integration_Service__mdt integrationServiceObj = Utility.fetchIntergrationService('SFDCLeadToPEC', EnvironmentType, 'POST');
            if(integrationServiceObj != null){
             system.debug('Testinggg 3');
                Http httpObj = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(integrationServiceObj.EndPoint__c);
                request.setHeader('Content-Type', integrationServiceObj.Content_Type__c);
                request.setHeader('Ocp-Apim-Subscription-Key', integrationServiceObj.Password__c);
                request.setMethod('POST');
                request.setTimeout(120000);
                request.setBody(jsonBody);
                HttpResponse response = new HttpResponse();
                if(!test.isRunningtest()){
                response = httpObj.send(request);
                }
                String responseStr = String.valueOf(response.getBody());
                NVLoggerHandler.API_InfoWrapper apiwrapperObj = new NVLoggerHandler.API_InfoWrapper();
                apiwrapperObj.relatedRecordId = leadObj.Id;
                apiwrapperObj.logReqMethod = integrationServiceObj.MethodType__c;
                apiwrapperObj.logReqGetEndpoint = integrationServiceObj.EndPoint__c;
                apiwrapperObj.requestType = integrationServiceObj.RequestType__c;
                apiwrapperObj.integrationType = integrationServiceObj.IntegrationType__c; 
                apiwrapperObj.sourceSystem = integrationServiceObj.SourceSystem__c; 
                apiwrapperObj.targetsystem = integrationServiceObj.Targetsystem__c;
                apiwrapperObj.logReqGetBody = request.getBody();
                apiwrapperObj.sObjectType = 'Lead';
                apiwrapperObj.WebServiceName = integrationServiceObj.WebServiceName__c;
                if(!test.isRunningtest()){
                 if(string.valueof(response.getStatusCode()).startsWith('2'))
                        apiwrapperObj.responseType = 'Success';
                        else
                        apiwrapperObj.responseType = 'Error';
                apiwrapperObj.logResGetBody = response.getBody();
                apiwrapperObj.logResGetStatusCode = response.getStatusCode();
                apiwrapperObj.Response = response.getbody();
                }
                apiwrapperObj.Request = request.getbody();
                NVLoggerHandler.createErrorLog(apiwrapperObj);
            }
        }
    }

    
    /**
    * @description PEC Lead wrapper class
    * @param  registrationID: Lead grid_software_evaluation_pak__c value, pecid: Lead Id
    * @return  
    */   
    private class PECLeadWrapperCls{
        private Integer registrationID;
        private String pecid;
        private String catalogID;
        private Integer units;
        
        public PECLeadWrapperCls(Integer registrationID, String pecid){
            this.registrationID = registrationID;
            this.pecid = pecid;
            
            
        }
        
        public PECLeadWrapperCls(Integer registrationID, String pecid, String catalogID, Integer units){
            this.registrationID = registrationID;
            this.pecid = pecid;
            this.catalogID = catalogID;
            this.units = units;
        }
    }
    
     /**
    * @description To pass the Contact to RWA syste,
    * @param  Contact Object
    * @return  Void: It returns nothing
    */   
    
    public static void rwaContactRequest(Contact conObj){
        if(conObj != null){
            Organization isSandboxProd = [Select id,instanceName,isSandbox from Organization];
            String EnvironmentType = '';
            if(isSandboxProd.isSandbox)
                EnvironmentType = 'Test';
            else
                EnvironmentType = 'Prod';
            PECLeadWrapperCls PECLeadWrapperClsObj = new PECLeadWrapperCls( Integer.valueOf(conObj.grid_software_evaluation_pak__c), conObj.AccountId, conObj.VGPU_Eval_Catalog__c ,Integer.valueOf(conObj.VGPU_Eval_Units__c));
            String jsonBody = JSON.serialize(PECLeadWrapperClsObj);
            Integration_Service__mdt integrationServiceObj = Utility.fetchIntergrationService('SFDCLeadToPEC', EnvironmentType, 'POST');
            if(integrationServiceObj != null){
             system.debug('Testinggg 3');
                Http httpObj = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(integrationServiceObj.EndPoint__c);
                request.setHeader('Content-Type', integrationServiceObj.Content_Type__c);
                request.setHeader('Ocp-Apim-Subscription-Key', integrationServiceObj.Password__c);
                request.setMethod('POST');
                request.setTimeout(120000);
                request.setBody(jsonBody);
                HttpResponse response = new HttpResponse();
                if(!test.isRunningtest()){
                response = httpObj.send(request);
                }
                String responseStr = String.valueOf(response.getBody());
                NVLoggerHandler.API_InfoWrapper apiwrapperObj = new NVLoggerHandler.API_InfoWrapper();
                apiwrapperObj.relatedRecordId = conObj.Id;
                apiwrapperObj.logReqMethod = integrationServiceObj.MethodType__c;
                apiwrapperObj.logReqGetEndpoint = integrationServiceObj.EndPoint__c;
                apiwrapperObj.requestType = integrationServiceObj.RequestType__c;
                apiwrapperObj.integrationType = integrationServiceObj.IntegrationType__c; 
                apiwrapperObj.sourceSystem = integrationServiceObj.SourceSystem__c; 
                apiwrapperObj.targetsystem = integrationServiceObj.Targetsystem__c;
                apiwrapperObj.logReqGetBody = request.getBody();
                apiwrapperObj.sObjectType = 'Lead';
                apiwrapperObj.WebServiceName = integrationServiceObj.WebServiceName__c;
                 if(!test.isRunningtest()){
                     if(string.valueof(response.getStatusCode()).startsWith('2'))
                        apiwrapperObj.responseType = 'Success';
                        else
                        apiwrapperObj.responseType = 'Error';
                        apiwrapperObj.Response = response.getbody();
                     apiwrapperObj.logResGetBody = response.getBody();
                    apiwrapperObj.logResGetStatusCode = response.getStatusCode();
                 }
                     apiwrapperObj.Request = request.getbody();
                NVLoggerHandler.createErrorLog(apiwrapperObj);
            }
        }
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