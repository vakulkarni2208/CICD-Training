/**
 * @File Name          : NVBugOperations.cls
 * @Description        : This class is used for SFDC and NVBUg integration
 * @Author             : Nilesh Adkar
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/29/2019         Nilesh Adkar           SDS-674 NVbug Integration
 * 1.1    06/13/2020         Nilesh Adkar           SDS-2490 Upload Images, SDS-2503 Upload Attachments as files
 **/
public class NVBugOperations implements Queueable, Database.AllowsCallouts {

    public static Http objhttp;
    public static HttpRequest req;
    public static HttpResponse res;
    public static NVBug nvbug;
    private static string strNVBugDescription='';
    private string strNvBug;
    public NV_Ticket__c nvTicket;
    private List<NVBug__c > lstNvbugs;
    static string NVBug_API_EndPointSTAGE = 'callout:NVBUG_STAGE_Endpoint';
    static string NVBug_API_EndPointPROD = 'callout:NVBUG_PROD_Endpoint'; //callout:NVBUG_PROD_Endpoint
    static string NVBugMiddleware_API_EndPointPROD = 'callout:NVBug_Middleware_Endpoint';

    public NVBugOperations(NV_Ticket__c nvTicket) {
        this.nvTicket= nvTicket;
    } 
    public NVBugOperations(List<NVBug__c> lstNvbugs){
        this.lstNvbugs = lstNvbugs;
    } 
    public void execute(QueueableContext context) {
        
        LinkBug(JSON.serialize(this.nvTicket));
    }
    /*==================================================== NEW NVBUG BUTTON CODE ==========================================================*/
    /* -----------------------------------------------------------------
      getPrepopulatedNVBug : This method populates Case details and 
      Environment profile on NVbug form in NewNVbug lightning component
    --------------------------------------------------------------------*/  
    @auraEnabled
    public static NVBug__c getPrepopulatedNVBug(string strCaseId) {
        system.debug('**inside getPrepopulatedNVBug' + strCaseId);
        NVBug__c newNVBug = (NVBug__c)NVBug__c.sObjectType.newSObject(null,true);
        newNVBug.case__c = strCaseId;
        newNVBug.Is_Send_Notification__c = true;
        newNVBug.Priority__c = 'Unprioritized';
        Case cse = [select Product_Family__c, Environment_Profile__c, Product_Category__c, Subject, CaseNumber, Description, Account.name, EntitlementId, Entitlement.Hardware_Serial_Number__c from Case where id =: strCaseId];       
        system.debug('**cse.Description**' + cse.Description);      
        string strEnvProfText = '';
        string strSerialNo = '';
        if (cse.EntitlementId != null && cse.Entitlement.Hardware_Serial_Number__c != null)
            strSerialNo = cse.Entitlement.Hardware_Serial_Number__c;
        if (cse.Environment_Profile__c != null)
            strEnvProfText = populateEnvironmentProfileText(cse.Environment_Profile__c);
        if ((cse.Product_Category__c != null && cse.Product_Category__c.contains('GRID')) || (cse.Product_Family__c != null && cse.Product_Family__c.contains('GRID'))){
            newNVBug.NVBug_Description__c = 'Case Number: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + cse.id + '">' + cse.CaseNumber + '</a><br/>--------------------------------------------------------------------------------<br/>' 
                                            + 'Agent Analysis: <br/>--------------------------------------------------------------------------------<br/>Customer Provided Case Description: ' + cse.Description+ '<br/>--------------------------------------------------------------------------------' + strEnvProfText;
            newNVBug.Synopsis__c = '[' + cse.Product_Category__c + ' ] [' + cse.Account.name + ']  [' + cse.Subject + ']';
        }
        else{
            newNVBug.NVBug_Description__c = 'Case Number: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + cse.id + '">' + cse.CaseNumber + '</a>' + '<br/> Serial Number: ' 
            + strSerialNo + '<br/>--------------------------------------------------------------------------------<br/>Agent Analysis: <br/>--------------------------------------------------------------------------------<br/>Customer Provided Case Description:<br/> ' + cse.Description+ '<br/>--------------------------------------------------------------------------------' + strEnvProfText;
            newNVBug.Synopsis__c = '[' + cse.Product_Family__c + ' ] [' + cse.Account.name + ']  [' + cse.Subject + ']';
        }
        newNVBug.Product_Category__c = cse.Product_Category__c;
        newNVBug.NVBug_Description__c = newNVBug.NVBug_Description__c.replace('\n','<br>');
        if(newNVBug.Synopsis__c!=null)
            newNVBug.Synopsis__c = newNVBug.Synopsis__c.left(200);
        newNVBug.Requestor__c = UserInfo.getName();    
        return newNVBug;
    }
    
    /* ---------------------------
           Get Bug method
    -------------------------------*/
    public static NVBug getBug(integer BugId) {
        objhttp = new Http();
        req = new HttpRequest();
        res = new HttpResponse();
        req.setMethod('GET'); // req.setMethod('GET');
        if(isSandbox())
            NVBug_API_EndPointPROD = NVBug_API_EndPointSTAGE;
        req.setEndpoint(NVBug_API_EndPointPROD + '/getbug/' + BugId);
        /*Blob headerValue = Blob.valueOf('svcnvbugsapipubdev' + ':' + 'XM9qST4Ye');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        // Set the necessary Headers
        req.setHeader('Authorization', authorizationHeader);*/
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/json');
        //      req.setHeader('Accept-Language', 'en-CA');
        req.setTimeout(120000);

        try {
            res = objhttp.send(req);
            system.debug('**' + res.getBody());
            if (res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) {
                // Logic to parse the response
                Map<String, Object> m = (Map<String, Object> ) JSON.deserializeUntyped(res.getBody());
                if (m == null)
                    return null;
                List<Map<String, Object>> myMaps = new List<Map<String, Object>> ();
                Map<String, Object> mapObj = (Map<String, Object> ) m.get('ReturnValue');
                if (mapObj == null)
                    return null;
                system.debug('**m**' + m);
                system.debug('**mapObj **' + mapObj);
                nvbug = new NVBUg();
                nvbug.IsSendNotification = (Boolean) mapObj.get('IsSendNotification');
                nvbug.BugId = BugId;
                nvbug.Synopsis = (string) mapObj.get('Synopsis');
                strNVBugDescription = nvbug.DescriptionMarkup;
                Map<string, Object> mapBug;
                mapBug = (Map<string, Object> ) mapObj.get('Priority');
                if (mapBug != null) {
                    nvbug.Priority = new Type();
                    nvbug.Priority.key = (Integer) mapBug.get('Key');
                    nvbug.Priority.value = (string) mapBug.get('Value');
                }
                nvbug.BugAction = new Type();
                mapBug = (Map<string, Object> ) mapObj.get('BugAction');
                if (mapBug != null) {
                    nvbug.BugAction.key = (Integer) mapBug.get('Key');
                    nvbug.BugAction.value = (string) mapBug.get('Value');
                    system.debug('**nvbug.BugAction**' + nvbug.BugAction);
                }
                nvbug.Disposition = new Type();
                mapBug = (Map<string, Object> ) mapObj.get('Disposition');
                if (mapBug != null) {
                    nvbug.Disposition.key = (Integer) mapBug.get('Key');
                    nvbug.Disposition.value = (string) mapBug.get('Value');
                    system.debug('**nvbug.Disposition**' + nvbug.Disposition);
                }
                nvbug.Severity = new Type();
                mapBug = (Map<string, Object> ) mapObj.get('Severity');
                if (mapBug != null) {
                    nvbug.Severity.key = (Integer) mapBug.get('Key');
                    nvbug.Severity.value = (string) mapBug.get('Value');
                    system.debug('**nvbug.Severity**' + nvbug.Severity);
                }
                nvbug.OperatingSystems = (string) mapObj.get('OperatingSystems');
                nvbug.GeographicOrigin = (string) mapObj.get('GeographicOrigin');
                nvbug.Origin = (string) mapObj.get('Origin');
                nvbug.DescriptionMarkup= (string) mapObj.get('DescriptionMarkup');
                nvbug.DescriptionPlainTextReadOnly= (string) mapObj.get('DescriptionPlainTextReadOnly');
                nvbug.Description= (string) mapObj.get('Description');
                nvbug.Version = (string) mapObj.get('Version');
                nvbug.CustomKeywords = (string) mapObj.get('CustomKeywords');
                nvbug.BugType = (string) mapObj.get('BugType');
                nvbug.Categories = (string) mapObj.get('Categories');
                nvbug.ApplicationDivisionID = (Integer) mapObj.get('ApplicationDivisionID');
                system.debug('**mapObj.get(Categories)**' + mapObj.get('Categories'));
                nvbug.BusinessUnits = (string) mapObj.get('BusinessUnits');
                nvbug.Engineer = new Type();
                mapBug = (Map<string, Object> ) mapObj.get('Engineer');
                if (mapBug != null) {
                    nvbug.Engineer.key = (Integer) mapBug.get('Key');
                    nvbug.Engineer.value = (string) mapBug.get('Value');
                    system.debug('**nvbug.Engineer**' + nvbug.Engineer);
                }
                nvbug.QAEngineer = new Type();
                mapBug = (Map<string, Object> ) mapObj.get('QAEngineer');
                if (mapBug != null) {
                    nvbug.QAEngineer.key = (Integer) mapBug.get('Key');
                    nvbug.QAEngineer.value = (string) mapBug.get('Value');
                    system.debug('**nvbug.QAEngineer**' + nvbug.QAEngineer);
                }
                nvbug.ModuleInfo = new Type();
                mapBug = (Map<string, Object> ) mapObj.get('ModuleInfo');
                if (mapBug != null) {
                    nvbug.ModuleInfo.key = (Integer) mapBug.get('Key');
                    nvbug.ModuleInfo.value = (string) mapBug.get('Value');
                    system.debug('**nvbug.ModuleInfo**' + nvbug.ModuleInfo);
                }
                nvbug.ARB = mapObj.get('ARB');
                nvbug.CCUsers = mapObj.get('CCUsers');
                nvbug.CCGroups = mapObj.get('CCGroups');
                system.debug('**' + nvbug.ARB);    
                system.debug('**' + nvbug);
                return nvbug;    
            }            
        } catch (System.CalloutException e) {
            System.debug('Callout error: ' + e);
        }
        return null;
    }
    /* ---------------------------------------------------------
      saveNewNVBug : This method saves NVbug from
      NVbug form in NewNVbug lightning component
    ------------------------------------------------------------*/  
    @auraEnabled
    public static NVBug__c saveNewNVBug(NVBug__c newNVBug) {
        system.debug('**inside saveNewNVBug' + newNVBug);
        newNVBug.name = 'Refresh to get NVBug';
        if(newnvbug.Synopsis__c!=null)
        newNVBug.Synopsis__c=newnvbug.Synopsis__c.left(200);
        insert newNVBug;
        //createNV_Ticket(newNVBug);
        return newNVBug;
    }
    /* ------------------------------------------------
      This method saves the SFDC Bug to NVBUG System
    ---------------------------------------------------*/
    @AuraEnabled
    public static string saveBug(NVBug__c newnvbug) {
        //system.debug('**saveBug**' + strNVBug);
        //NVBug__c newnvbug = (NVBug__c) JSON.deserialize(strNVBug, NVBug__c.class);
        system.debug('**saveBug**' + newnvbug);
        integer bugId = 1786967; // Generic NVBUG
        if(!isSandbox())
            bugId = 0;
        // If linking existing Bug in NVbug to Case
        if (newnvbug != null && newnvbug.name.isnumeric())
            bugId = Integer.valueOf(newnvbug.name);
        nvbug = new NVBUg();

        if(newnvbug!=null && newnvbug.NVBug_Template__c!=null && newnvbug.NVBug_Template__c.contains('(') && newnvbug.NVBug_Template__c.contains(')') && !isSandbox())
            bugId=integer.valueof(newnvbug.NVBug_Template__c.substring(newnvbug.NVBug_Template__c.indexof('(')+1,newnvbug.NVBug_Template__c.indexof(')')));
        system.debug('**bugId before getbug call**'+bugId);
        nvbug = getBug(bugId);
        if(nvbug==null){
            delete newnvbug;
            return 'Template not found';
        }
        // Update / Link Case to NVBug
        if (newnvbug != null && newnvbug.name.isnumeric())
            nvbug.BugId = bugId;
        // Create new NVBug
        else {
            system.debug('**nvbug**newnvbug**'+nvbug+'**'+newnvbug);
            nvbug.IsSendNotification = newnvbug.Is_Send_Notification__c;
            nvbug.BugId = 0;
            if(newnvbug!=null && newnvbug.Synopsis__c!=null)
                nvbug.Synopsis = newnvbug.Synopsis__c.left(200);
            nvbug.DescriptionMarkup= newnvbug.NVBug_Description__c;
            if(nvbug.DescriptionMarkup!=null){
                nvbug.DescriptionMarkup = nvbug.DescriptionMarkup.replace('<br><br>','<br>');
                nvbug.DescriptionMarkup = nvbug.DescriptionMarkup.replace('<p>','<br>');
                nvbug.DescriptionMarkup = nvbug.DescriptionMarkup.replace('</p>','');
                AggregateResult apiVersion = [SELECT Max(ApiVersion) version FROM ApexClass];
                String Version = String.valueOf(apiVersion.get('version'));
                system.debug('**'+nvbug.DescriptionMarkup.countMatches('/servlet/rtaImage?')+'**');
                Http http = new Http();
                HttpRequest request;
                string strBaseURL = System.URL.getSalesforceBaseURL().toExternalForm().tolowercase();
                String base64Encode;
                integer count=nvbug.DescriptionMarkup.countMatches('/servlet/rtaImage?');
                for(integer i=0;i<count;i++)  {
                    string strImageId=nvbug.DescriptionMarkup.substring(nvbug.DescriptionMarkup.indexOf('refid=')+6,nvbug.DescriptionMarkup.indexOf('refid=')+21);
                    system.debug('**strImageId**'+strImageId);
                    request = new HttpRequest();
                    request.setEndpoint(strBaseURL + '/services/data/v'+ Version +'/sobjects/NVBug__c/' + newnvbug.id + '/richTextImageFields/NVBug_Description__c/' + strImageId);
                    request.setMethod('GET');
                    string strAuthorization= 'Bearer ' + fetchUserSessionId(); //Bearer 
                    request.setHeader('Authorization', strAuthorization);
                    //request.setHeader('Content-Type', 'image/jpeg');
                    system.debug('**request**' + request);
                    HttpResponse response = http.send(request);
                    system.debug('**image response**' + response.getBody());
                    Blob image = response.getBodyAsBlob();
                    base64Encode= 'src="data:image/jpeg;base64, '+EncodingUtil.base64Encode(image); 
                    system.debug('**base64Encode**'+ base64Encode);
                    nvbug.DescriptionMarkup= nvbug.DescriptionMarkup.replace(nvbug.DescriptionMarkup.substring(nvbug.DescriptionMarkup.indexOf('src="/servlet/rtaImage?'),nvbug.DescriptionMarkup.indexOf(strImageId)+15),base64Encode);
                    system.debug('**'+nvbug.DescriptionMarkup);                        
                }
                system.debug('**'+nvbug.DescriptionMarkup);                
            }    
            nvbug.Priority = new Type();
            nvbug.Priority.value = newnvbug.Priority__c;
            nvbug.Severity = new Type();
            nvbug.Severity.value = newnvbug.Severity__c;
            nvbug.Origin = 'Customer';
            nvbug.Version = newnvbug.Versions__c;
            nvbug.Requester = new Type();
            nvbug.Requester.value = newnvbug.Requestor__c;
        }
        NVBug__c nvbg; 
        ApplicationIntegration appInte = new ApplicationIntegration();
        if(newnvbug.Rma__c==null){
            nvbg= [SELECT name, Case__c,RMA__c, Case__r.subject, Case__r.casenumber,NVBug_URL__c, Id FROM NVBug__c WHERE Id =: newnvbug.id LIMIT 1];
            nvbug.BugApplicationIntegration = new List<ApplicationIntegration> ();
            appInte.ApplicationName = 'Salesforce';
            appInte.ApplicationID = nvbg.Case__r.casenumber;
            appInte.ApplicationURL = System.URL.getOrgDomainUrl().toExternalForm() + '/' + nvbg.Case__c;
            appInte.LinkSummary = nvbg.Case__r.subject.left(200);
            nvbug.BugApplicationIntegration.add(appInte);
            system.debug('**nvbug.BugApplicationIntegration**' + nvbug.BugApplicationIntegration);
            system.debug('**' + nvbug);
        }
        else{
            nvbg= [SELECT name,Case__c, RMA__c, RMA__r.NVIDIA_Part_Description__c, RMA__r.Crm_Complaint_Number__c,NVBug_URL__c, Id FROM NVBug__c WHERE Id =: newnvbug.id LIMIT 1];
            nvbug.BugApplicationIntegration = new List<ApplicationIntegration> ();
            appInte.ApplicationName = 'Salesforce';
            appInte.ApplicationID = nvbg.RMA__r.Crm_Complaint_Number__c;
            appInte.ApplicationURL = System.URL.getOrgDomainUrl().toExternalForm() + '/' + nvbg.RMA__c;
            appInte.LinkSummary = nvbg.RMA__r.NVIDIA_Part_Description__c;
            nvbug.BugApplicationIntegration.add(appInte);
            system.debug('**nvbug.BugApplicationIntegration**' + nvbug.BugApplicationIntegration);
            system.debug('**' + nvbug);
        }
        objhttp = new Http();
        req = new HttpRequest();
        res = new HttpResponse();
        req.setMethod('POST'); // req.setMethod('GET');
        if(isSandbox())
            NVBug_API_EndPointPROD = NVBug_API_EndPointSTAGE;
        req.setEndpoint(NVBug_API_EndPointPROD + '/SaveBug');
        /*Blob headerValue = Blob.valueOf('svcnvbugsapipubdev' + ':' + 'XM9qST4Ye');
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        // Set the necessary Headers
        req.setHeader('Authorization', authorizationHeader);*/
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);
        String reqBody = JSON.serialize(nvbug);
        //        reqBody = reqBody.replace('"{Value', '{"Value"');
        req.setBody(reqBody);
        system.debug('**' + reqBody);
        system.debug('**' + req);
        try {
            res = objhttp.send(req);
            if (res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) {
                // Logic to parse the response
                system.debug('**' + res.getBody());
                if (newnvbug != null && !newnvbug.name.isnumeric()) {
                    NVBugSaveBugResponse nvRes = (NVBugSaveBugResponse) JSON.deserialize(res.getBody(), NVBugSaveBugResponse.class);
    
                    nvbg.name = nvRes.ReturnValue;
                    update nvbg;
    
                   /* List<NV_Ticket__c > lstNVticket = [select id, name, Link__c, NVBug__r.NVBug_URL__c from NV_Ticket__c where nvbug__c =: newnvbug.id];
                    for (NV_Ticket__c tmpnvticket: lstNVticket) {
                        tmpnvticket.name = newnvbug.name;
                        tmpnvticket.Link__c = tmpnvticket.NVBug__r.NVBug_URL__c;
                    }
                    update lstNVticket;*/
                }
               if (newnvbug != null)
                    createNV_Ticket(nvbg );            
            }

        } catch (System.CalloutException e) {
            System.debug('Callout error: ' + e);
            return 'Unable to create NVBug. Please raise Get Help.';
        }
        return 'NVBug ' + nvbg.name + ' created.';
    }
    /* ---------------------------------------------------------
      createNV_Ticket : This method links multiple cases to 
      multiple NVbugs
    ------------------------------------------------------------*/ 
    @auraEnabled 
    public static void createNV_Ticket(NVBUg__c nvbg) {
        NVBug__c newNVbug = [SELECT name, Synopsis__c,Case__c,RMA__c, NVBug_URL__c, Id FROM NVBug__c WHERE Id =: nvbg.id LIMIT 1];
        NV_Ticket__c newNVTicket = new NV_Ticket__c();
        newNVTicket.Case__c = newNVbug.Case__c;
        newNVTicket.NVBug__c = newNVbug.id;
        newNVTicket.name = newNVbug.name;
        newNVTicket.Link__c = newNVbug.NVBug_URL__c;
        newNVTicket.Description__c = newNVbug.Synopsis__c;
        system.debug('**newNVbug.NVBug_URL__c**' + newNVbug.NVBug_URL__c);
        newNVTicket.IsApplicationIntegrationEntryCreated__c = true;
        if(newNVbug.RMA__C==null)
            newNVTicket.Type__c = 'NVBug';
        else
            newNVTicket.Type__c = 'Failure Analysis NVBug';    
        newNVTicket.RecordTypeId = [SELECT DeveloperName, Id, SobjectType FROM RecordType WHERE SobjectType = 'NV_Ticket__c' AND DeveloperName = 'NVBug'].id;
        insert newNVTicket;
        /*FeedItem post = new FeedItem();
        post.ParentId = newNVbug.Case__c; // Record Id eg. Opportunity id, custom object id..
        post.Body = 'NVBug System Bug link';
        post.LinkUrl =  newNVbug.NVBug_URL__c;
        insert post;*/
    }
    /*====================================================LINK EXISTING NVBUG BUTTON CODE ==========================================================*/
    /* ---------------------------------------------------
      LinkBug : This method links the SFDC Bug to Case
    -------------------------------------------------------*/
    public static void LinkBug(string strNVTicket) {
        NV_Ticket__c newnvTicket = (NV_Ticket__c) JSON.deserialize(strNVTicket, NV_Ticket__c.class);
        if (newnvTicket != null) {
            string strBugNo;
            if (newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c != null && newnvTicket.NVBug_Number_Formula__c == null){
                strBugNo = string.valueof(newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c);
                system.debug('**newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c**'+newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c);
            }    
            else if ((newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c == null && newnvTicket.NVBug_Number_Formula__c != null) ||
                (newnvTicket.NVBug_Number_Formula__c != null && newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c != null && string.valueof(newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c) == newnvTicket.NVBug_Number_Formula__c)){
                strBugNo = newnvTicket.NVBug_Number_Formula__c;
                system.debug('**newnvTicket.NVBug_Number_Formula__c**'+newnvTicket.NVBug_Number_Formula__c);
            }
            else
                return;
            List<NVBug__c > lstNVBug = [select id, name from NVBug__c where name =: strBugNo];
            system.debug('**lstNVBug**'+lstNVBug);
            if (!lstNVBug.isEmpty()) {
                newnvTicket.NVBug__c = lstNVBug.get(0).id;
                newnvTicket.IsApplicationIntegrationEntryCreated__c = true; 
                upsert newnvTicket;
                LinkBugCallout(JSON.serialize(newnvTicket));
            } 
            else {
                if(System.isQueueable()){
                    system.debug('**System.isQueueable()**'+ System.isQueueable());
                    if (newnvTicket != null && newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c != null) {
                        try {
                            NVBug nvbug = getBug(Integer.valueOf(newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c));
                            if (nvbug == null) {
                                newnvTicket.NVBug_System_Message__c = 'Bug not found';
                                newnvTicket.name = 'Bug not found';
                                update newnvTicket;
                                return;
                            } else {
                                NVBug__c newnvbug = new NVBug__c();
                                newnvbug.Product_Category__c = newnvTicket.Product_Category__c;
                                newnvbug.name = String.valueOf(newnvTicket.Bug_no_in_NVBug_Not_in_SFDC__c);
                                newnvbug.Is_Send_Notification__c = nvbug.IsSendNotification;
                                newnvbug.Synopsis__c= nvbug.Synopsis;
                                if(nvbug.DescriptionMarkup!=null){
                                    nvbug.DescriptionMarkup.replace('<br>','\n');
                                    nvbug.DescriptionMarkup.replace('<br/>','\n');
                                    nvbug.DescriptionMarkup.replace('<p>','\n');
                                    nvbug.DescriptionMarkup.replace('</p>','');
                                }
                                //if(nvbug!=null && nvbug.DescriptionMarkup!=null && nvbug.DescriptionMarkup.length()<131072)
                                    newnvbug.NVBug_Description__c = nvbug.DescriptionMarkup;
                                //else if(nvbug!=null && nvbug.DescriptionMarkup!=null && nvbug.DescriptionMarkup.length()>131072)
                                //    newnvbug.NVBug_Description__c = nvbug.DescriptionMarkup.left(131000);
                                
                                newnvbug.Priority__c = nvbug.Priority.value;
                                newnvbug.Bug_Action__c = nvbug.BugAction.value;
                                newnvbug.Disposition__c = nvbug.Disposition.value;
                                newnvbug.Engineer__c = nvbug.Severity.value;
                                newnvbug.Operating_Systems__c = nvbug.OperatingSystems;
                                newnvbug.Geographic_Origin__c = nvbug.GeographicOrigin;
                                newnvbug.Origin__c = 'Customer';
                                newnvbug.Custom_Keywords__c = nvbug.CustomKeywords;
                                newnvbug.BugType__c = nvbug.BugType;
                                newnvbug.Categories__c = nvbug.Categories;
                                newnvbug.ApplicationDivisionID__c = nvbug.ApplicationDivisionID;
                                newnvbug.Business_Units__c = nvbug.BusinessUnits;
                                newnvbug.Engineer__c = nvbug.Engineer.value;
                                newnvbug.QA_Engineer__c = nvbug.QAEngineer.value;
                                newnvbug.Module_Info__c = nvbug.ModuleInfo.value;
                                newnvbug.ARB__c = string.valueOf(nvbug.ARB);
                                newnvbug.CCUsers__c = string.valueOf(nvbug.CCUsers);
                                newnvbug.CCGroups__c = string.valueOf(nvbug.CCGroups);
                                newnvbug.Case__c = newnvTicket.Case__c;
                                try{
                                    insert newnvbug;
                                }
                                catch(DmlException ex){
                                    if(nvbug!=null && nvbug.Description!=null) {
                                        newnvbug.NVBug_Description__c = nvbug.Description.left(131000); 
                                        insert newnvbug;
                                    }    
                                }
                                catch(Exception ex){
                                    System.debug('**ex**' + ex.getMessage());
                                    System.debug('**ex**' + ex.getStackTraceString());
                                }
                                newnvTicket.NVBug__c = newnvbug.id;
                                newnvTicket.name = newnvbug.name;
                                newnvTicket.Link__c = newnvbug.NVBug_URL__c;
                                newNVTicket.IsApplicationIntegrationEntryCreated__c = true;
                                upsert newnvTicket;
                                LinkBugCallout(JSON.serialize(newnvTicket));
                            }
                        } catch (Exception ex) {
                            newnvTicket.NVBug_System_Message__c = ex.getMessage();
                            newnvTicket.name = 'Error in linking NVbug.';
                            upsert newnvTicket;
                        }
                    }
                }
                else{
                    ID jobID = System.enqueueJob(new NVBugOperations(newnvTicket));
                }
            }
        }
    }
    /* ---------------------------------------------------------
      LinkBugCallout : This method This method links the NVBug to Case
      in NVbug System
    ------------------------------------------------------------*/
    @future(callout = true)
    public static void LinkBugCallout(string strNVTicket) {
        NV_Ticket__c newnvTicket = (NV_Ticket__c) JSON.deserialize(strNVTicket, NV_Ticket__c.class);

        NV_Ticket__c nvTicket = [select IsApplicationIntegrationEntryCreated__c ,Case__c, Case__r.subject, Case__r.casenumber, Id, NVBug_Number_Formula__c FROM NV_Ticket__c where id =: newnvTicket.id limit 1];
        List<ApplicationIntegration> lstAppInt = new List<ApplicationIntegration>();
        ApplicationIntegration appInte = new ApplicationIntegration();
        appInte.ApplicationName = 'Salesforce';
        appInte.ApplicationID = nvTicket.Case__r.casenumber;
        appInte.ApplicationURL = System.URL.getOrgDomainUrl().toExternalForm() + '/' + newnvTicket.Case__c;
        appInte.LinkSummary = nvTicket.Case__r.subject;
        appInte.BugID = (nvTicket.NVBug_Number_Formula__c!=null && nvTicket.NVBug_Number_Formula__c.isnumeric()) ? Integer.valueOf(nvTicket.NVBug_Number_Formula__c):-1;
        lstAppInt.add(appInte);

        objhttp = new Http();
        req = new HttpRequest();
        res = new HttpResponse();
        req.setMethod('POST'); // req.setMethod('GET');
        if(isSandbox())
            NVBug_API_EndPointPROD = NVBug_API_EndPointSTAGE;
        req.setEndpoint(NVBug_API_EndPointPROD + '/AddBugToApplication');
        /*Blob headerValue = Blob.valueOf('svcnvbugsapipubdev' + ':' + 'XM9qST4Ye');
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        // Set the necessary Headers
        req.setHeader('Authorization', authorizationHeader);*/
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);
        String reqBody = JSON.serialize(lstAppInt);
        req.setBody(reqBody);
        system.debug('**' + reqBody);
        system.debug('**' + req);
        try {
            res = objhttp.send(req);
            system.debug('**' + res.getBody());
        } catch (Exception ex) {
            System.debug('Callout error: ' + ex);
        }
    }

    /*==================================================== LINK FILES TO NVBUG BUTTON CODE ==========================================================*/
    /* -----------------------------------------------------------------
      getFilesOnCases : This method gets the list of files from Cases 
      and displays in Data table Lightning component LinkCaseFilesToNvBugs
    --------------------------------------------------------------------*/
    @auraEnabled
    public static List<ContentVersion> getFilesOnCases(Id strId) {
        system.debug('**inside getFilesOnCases fired from ' + strId.getSObjectType().getDescribe().getName());
        set<Id> setIds = new set<Id>();
        if(strId.getSObjectType().getDescribe().getName()=='NVBug__c'){
            List<NV_Ticket__C> lstNVticket = [select case__c from NV_Ticket__C where NVBug__c= :strId];
            for(NV_Ticket__C tmpNVTicket : lstNVticket )
                setIds.add(tmpNVTicket.case__c );
        }
        else if(strId.getSObjectType().getDescribe().getName()=='Case'){
            setIds.add(strId);
        }
        Map<Id,EmailMessage> mapEmails= new Map<Id,EmailMessage>([select id from EmailMessage where relatedToId in :setIds]);
        if(mapEmails!=null)
            setIds.addAll(mapEmails.keyset());

        if(setIds.isEmpty()) return null;
        List<ContentDocumentLink> lstcdlink = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in : setIds];
        set<Id> setCDids = new set<Id> ();
        for (ContentDocumentLink tmpCDL: lstcdlink) {
            setCDids.add(tmpCDL.ContentDocumentId);
            system.debug('**tmpCDL.ContentDocumentId**' + tmpCDL.ContentDocumentId);
        }
        List<ContentVersion> lstCv = [SELECT Checksum, ContentSize, Description, FileExtension, FileType, FirstPublishLocationId, FirstPublishLocation.name, Id, Origin, PathOnClient, VersionNumber, ContentDocumentId, File_Link__c, Title, Created_By_Formula__c, CreatedDate FROM ContentVersion WHERE ContentDocumentId in: setCDids];
        return lstCv;
    }
    /* -----------------------------------------------------------------
      getNVBugs : This method gets the list of NVBugs associated with Cases 
      and displays in Data table Lightning component LinkCaseFilesToNvBugs
    --------------------------------------------------------------------*/
    @auraEnabled
    public static List<NVBug__c > getNVBugs(string strCaseId) {
        system.debug('**inside getNVBugsCases');
        List<NV_Ticket__c > lstNT = [SELECT Id, NVBug__c FROM NV_Ticket__c WHERE Case__c =: strCaseId];
        set<Id> setNTids = new set<Id> ();
        for (NV_Ticket__c tmpNT: lstNT) {
            setNTids.add(tmpNT.NVBug__c);
            system.debug('**' + tmpNT.NVBug__c);
        }
        List<NVBug__c > lstNVBugs = [SELECT Id, Name, Synopsis__c, CreatedDate, Created_By_Formula__c, NVBug_URL__c FROM NVBug__c WHERE id in: setNTids];
        return lstNVBugs;
    }
    /* ---------------------------------------------------------
      updateFileNewName : This method updates name of files
    ------------------------------------------------------------*/  
    @auraEnabled
    public static void updateFileNewName(List<ContentVersion> lstCv) {
        system.debug('**inside updateFileNewName' + lstCv);
        update lstCv;
    }
    /* ---------------------------------------------------------
      linkNvBugFilesToNVbugSystem : This method uploads files attached on NVbug to 
      NVBug system. Called from Content Document Link trigger
    ------------------------------------------------------------*/
    public static void linkNvBugFilesToNVbugSystem(string strCDL) {
        List<ContentDocumentLink> lstcdl = (List<ContentDocumentLink> ) JSON.deserialize(strCDL, List<ContentDocumentLink> .class);

        set<Id> setNvBugIds = new set<Id> ();
        set<Id> setCDIds = new set<Id> ();

        for (ContentDocumentLink tmpCDL: lstcdl) {
            setNvBugIds.add(tmpCDL.LinkedEntityId);
            setCDIds.add(tmpCDL.contentdocumentid);
        }
        List<ContentVersion> lstCv = [SELECT Checksum, ContentSize, Description, FileExtension, FileType, FirstPublishLocationId, FirstPublishLocation.name, Id, Origin, PathOnClient, VersionNumber, ContentDocumentId, File_Link__c, Title, Created_By_Formula__c, CreatedDate FROM ContentVersion WHERE ContentDocumentId in: setCDids and FirstPublishLocationId in: setNvBugIds];
        for (ContentVersion tmpCv: lstCv)
            uploadFile(tmpCv.id, tmpCv.FirstPublishLocationId);

    }
    /* ---------------------------------------------------------
      linkCaseFilesToNVbug : This method uploads files attached on Cases to 
      NVBug system. Called from Content Document Link trigger
    ------------------------------------------------------------*/  
    @auraEnabled
    public static string linkCaseFilesToNVbug(List<ContentVersion> lstCv, List<NVBug__c > lstNVbug) {
        system.debug('**inside linkCaseFilesToNVbug' + lstCv + '**' + lstNVbug);
        set<Id> setCDIds = new set<Id> ();
        set<Id> setNVBugIds = new set<Id> ();
        for (ContentVersion tmpCv: lstCv) {
            setCDIds.add(tmpCv.contentdocumentid);
        }
        for (NVbug__c tmpbug: lstNVbug) {
            setNVBugIds.add(tmpbug.id);
        }
        List<ContentDocumentLink> lstExistingNVBugCDL = [select id, contentdocumentid, linkedentityid from ContentDocumentLink where contentdocumentid in: setCDIds and linkedentityid in: setNVBugIds];
        Map<Id, Set<Id>> mapCDNvBugIds = new Map<Id, Set<Id>> ();

        if (!lstExistingNVBugCDL.isempty()) {
            for (ContentDocumentLink tmpCDL: lstExistingNVBugCDL) {
                setNVBugIds = new set<Id> ();
                if (mapCDNvBugIds.get(tmpCDL.contentdocumentid) == null) {
                    setNVBugIds.add(tmpCDL.linkedentityid);
                    mapCDNvBugIds.put(tmpCDL.contentdocumentid, setNVBugIds);
                } else {
                    setNVBugIds = mapCDNvBugIds.get(tmpCDL.contentdocumentid);
                    setNVBugIds.add(tmpCDL.linkedentityid);
                }
            }
        }
        List<ContentDocumentLink> lstNVBugCDL = new List<ContentDocumentLink> ();
        if (lstCv != null && lstNVbug != null) {
            ContentDocumentLink objCDL;
            for (ContentVersion tmpCv: lstCv) {
                for (NVbug__c tmpbug: lstNVbug) {
                    if (mapCDNvBugIds.get(tmpCv.contentdocumentid) != null && mapCDNvBugIds.get(tmpCv.contentdocumentid).contains(tmpbug.id)) {
                        system.debug('**linkCaseFilesToNVbug loop**' + tmpCv.id + '**' + tmpbug.id);
                        continue;
                    }
                    objCDL = new ContentDocumentLink();
                    objCDL.contentdocumentid = tmpCv.contentdocumentid;
                    objCDL.linkedentityid = tmpbug.id;
                    objCDL.ShareType = 'V';
                    objCDL.Visibility = 'AllUsers';
                    lstNVBugCDL.add(objCDL);
                    system.debug('**linkCaseFilesToNVbug loop**' + tmpCv.id + '**' + tmpbug.id);
                    uploadFile(tmpCv.id, tmpbug.id);
                }
            }
            try {
                insert lstNVBugCDL;
            } catch (exception ex) {
                return 'Unable to link file with NVbug. Please contact Support.';
            }
        }
        return 'Files linked.';
    }        
    /* ---------------------------------------------------------
      uploadFile : This method calls Middleware file upload utility
    ------------------------------------------------------------*/
    @future(callout = true)
    public static void uploadFile(string strContentVersionId, string strNVBugId) {
        system.debug('**' + strContentVersionId + '**strNVBugId**' + strNVBugId);
        ContentVersion cv = [SELECT Checksum, ContentSize, Description, FileExtension, FileType, FirstPublishLocation.name, Id, Origin, PathOnClient, VersionNumber, ContentDocumentId FROM ContentVersion where Id =: strContentVersionId];
        string strNvbugNumber = [select name from NVbug__C where id =: strNVBugId].name;
        String strSoapRequest = '';
        strSoapRequest = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:nvidia:xi:SFDC:SALESOPS:NVBugs">';
        strSoapRequest = strSoapRequest + '<soapenv:Header/>';
        strSoapRequest = strSoapRequest + '<soapenv:Body>';
        strSoapRequest = strSoapRequest + '<urn:MT_NVBugAttachment_Metadata>';
        strSoapRequest = strSoapRequest + '<Root>';
        strSoapRequest = strSoapRequest + '<SFBugID>' + strNVBugId + '</SFBugID>';
        strSoapRequest = strSoapRequest + '<NVBugID>' + strNvbugNumber + '</NVBugID>';
        strSoapRequest = strSoapRequest + '<PATHONCLIENT>' + cv.PathOnClient + '</PATHONCLIENT>';
        strSoapRequest = strSoapRequest + '<ContentDocumentId>' + cv.ContentDocumentId + '</ContentDocumentId>';
        strSoapRequest = strSoapRequest + '<ContentSize>' + cv.ContentSize + '</ContentSize>';
        strSoapRequest = strSoapRequest + '<ID>' + cv.Id + '</ID>';
        strSoapRequest = strSoapRequest + '</Root>';
        strSoapRequest = strSoapRequest + '</urn:MT_NVBugAttachment_Metadata>';
        strSoapRequest = strSoapRequest + '</soapenv:Body>';
        strSoapRequest = strSoapRequest + '</soapenv:Envelope>';

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-type', 'application/xml');
        req.setTimeout(120000);

        //req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setMethod('POST');
        req.setEndpoint(NVBugMiddleware_API_EndPointPROD);
        req.setBody(strSoapRequest);
        req.setTimeout(120000);
        system.debug('**' + strSoapRequest);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('**' + res.getbody());
    }
    /*====================================================OTHER CODE ==========================================================*/
    public static String fetchUserSessionId(){
     String sessionId = '';
     // Refer to the Page
     PageReference reportPage = Page.GetSessionIdVF;
     // Get the content of the VF page
     try{
     String vfContent = reportPage.getContent().toString();
     System.debug('vfContent '+vfContent);
     // Find the position of Start_Of_Session_Id and End_Of_Session_Id
     Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
     endP = vfContent.indexOf('End_Of_Session_Id');
     // Get the Session Id
     sessionId = vfContent.substring(startP, endP);
     System.debug('sessionId '+sessionId);
     }
     catch(VisualforceException e){
     return 'session1';
     }
     // Return Session Id
     return sessionId;
 }
    
    /* ------------------------------------------------------------------------
      populateEnvironmentProfileText : This method prepopulates
      Environment profile details on NVBug form in NewNVbug lightning component
    ---------------------------------------------------------------------------*/   
    public static string populateEnvironmentProfileText(string strEnvProfId) {
        Environment_Profile__c envProf = [select id, Account__c, Account_Name__c, Active__c, BIOS__c, BMC__c, CEC__c, Compute_Nodes__c,
            Connection_Speed__c, Container__c, Cooling_Style__c, Customer_Contact__c,
            Data_at_Rest_Encryption_Used__c, Dedicated_Agent__c,
            Description__c, Display_Driver_Version__c, Display_Resolution__c,
            DL_Framework__c, DriveCC_Version__c, Drive_Partitioning__c,
            Drive_Partitioning_Customization__c, Driver_version__c, DriveSim_Version__c,
            DRS_Enabled__c, End_Point_Client_Version__c, End_Point_Type__c,
            ETH_IB_connections__c, Firmware_Notes__c, FPGA__c, Graphics_Virtualization_Type__c,
            GRID_Card_Model_s__c, GRID_Cards_Installed_Per_Server__c, Hypervisor_Version__c,
            Inforom_GPU_Stats__c, License_Server_Host_Type__c, License_Server_OS__c,
            License_Server_version__c, Location__c, M_2__c, Memory_Per_Server__c, MLX__c,
            Network_Cables_Used__c, Networking_Notes__c, Network_Switches_Used_and_Topology__c,
            NICs__c, Number_of_Cards_Connected__c, Number_of_Cards_Present__c, Number_of_Displays__c,
            Number_of_vCPUs__c, Onsite_Technician__c, OS__c, OS_Version__c, Part_of_Cluster__c,
            Patches_Applied_Over_Host_Hypervisor__c, PLX__c, Power_Source_Type__c, PSU__c,
            Rack_Info__c, RecordTypeName__c, Remoting_Protocol__c, Remoting_Solution__c,
            Remoting_Solution_Version__c, SBIOS__c, Scope__c, Security_Restrictions__c,
            Server_Brand__c, Server_Model__c, Service_Notes__c, Size_of_PODs__c, Storage__c,
            Switch_Info__c, Type_of_Cards__c, U_2__c, Usage_Type__c, VBIOS__c, Vendor_Name_Model__c,
            vGPU_Manager_Driver_Version__c, vGPU_Profile__c, Virtualization_Platform__c, Virtual_Machine__c,
            Visible_to_Customer__c, VM_info__c, VM_Memory__c from Environment_Profile__c
            where id =: strEnvProfId
        ];

        string strEnvProfile = '<p><br></p>Environment Profile Details' + '<p><br></p>---------------------------------------------<p><br></p>';
        if (envProf.RecordTypeName__c.contains('DGX')) {
            /*strEnvProfile = strEnvProfile + 'Name:' + '  '  + envProf.Name + '<p><br></p>' + 'Active:' + '  '  + envProf.Active__c+ '<p><br></p>' );
            strEnvProfile = strEnvProfile + 'Scope:' + '  '  + envProf.Scope__c + '<p><br></p>' + 'Visible to Customer:' + '  '  + envProf.Visible_to_Customer__c+ '<p><br></p>' );
            strEnvProfile = strEnvProfile + 'Account:' + '  '  + envProf.Account_Name__c+ '<p><br></p>' + 'Record Type:' + '  '  + envProf.RecordTypeName__c + '<p><br></p>' );
            strEnvProfile = strEnvProfile + 'Description:' + '  '  + envProf.Description__c + '<p><br></p><p><br></p>' );*/
            strEnvProfile = strEnvProfile + '<u>Infrastructure</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '-----------------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.Location__c !=null  ?  'Location: ' +  envProf.Location__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Rack_Info__c !=null  ?  'Rack Info: ' +  envProf.Rack_Info__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Security_Restrictions__c !=null  ?  'Security Restrictions: ' +  envProf.Security_Restrictions__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Power_Source_Type__c !=null  ?  'Power Source Type: ' +  envProf.Power_Source_Type__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Dedicated_Agent__c !=null  ?  'Dedicated Agent: ' +  envProf.Dedicated_Agent__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Cooling_Style__c !=null  ?  'Cooling Style: ' +  envProf.Cooling_Style__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Onsite_Technician__c !=null  ?  'Onsite Technician: ' +  envProf.Onsite_Technician__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Customer_Contact__c !=null  ?  'Customer Contact: ' +  envProf.Customer_Contact__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Service_Notes__c !=null  ?  'Service Notes: ' +  envProf.Service_Notes__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>Operating System and Software</u> <p><br></p>';
            //strEnvProfile = strEnvProfile + '-----------------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.OS__c !=null  ?  'OS: ' +  envProf.OS__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Virtual_Machine__c !=null  ?  'Virtual Machine: ' +  envProf.Virtual_Machine__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.OS_Version__c !=null  ?  'OS Version: ' +  envProf.OS_Version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Container__c !=null  ?  'Container: ' +  envProf.Container__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Data_at_Rest_Encryption_Used__c !=null  ?  'Data at Rest Encryption Used: ' +  envProf.Data_at_Rest_Encryption_Used__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.VM_info__c !=null  ?  'VM info: ' +  envProf.VM_info__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Drive_Partitioning__c !=null  ?  'Drive Partitioning: ' +  envProf.Drive_Partitioning__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Part_of_Cluster__c !=null  ?  'Part of Cluster: ' +  envProf.Part_of_Cluster__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Drive_Partitioning_Customization__c !=null  ?  'Drive Partitioning Customization: ' +  envProf.Drive_Partitioning_Customization__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Driver_version__c !=null  ?  'Driver version: ' +  envProf.Driver_version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.DL_Framework__c !=null  ?  'DL Framework: ' +  envProf.DL_Framework__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>Networking:</u>' + '  ' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '-----------------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.Number_of_Cards_Present__c !=null  ?  'Number of Cards Present: ' +  envProf.Number_of_Cards_Present__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Number_of_Cards_Connected__c !=null  ?  'Number of Cards Connected: ' +  envProf.Number_of_Cards_Connected__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Type_of_Cards__c !=null  ?  'Type of Cards: ' +  envProf.Type_of_Cards__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Connection_Speed__c !=null  ?  'Connection Speed: ' +  envProf.Connection_Speed__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.ETH_IB_connections__c !=null  ?  'ETH/IB connections: ' +  envProf.ETH_IB_connections__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Switch_Info__c !=null  ?  'Switch Info: ' +  envProf.Switch_Info__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Networking_Notes__c !=null  ?  'Networking Notes: ' +  envProf.Networking_Notes__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>POD/Cluster Deployments:</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '-----------------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.Storage__c !=null  ?  'Storage: ' +  envProf.Storage__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Compute_Nodes__c !=null  ?  'Compute Nodes: ' +  envProf.Compute_Nodes__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Size_of_PODs__c !=null  ?  'Size of PODs: ' +  envProf.Size_of_PODs__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Network_Cables_Used__c !=null  ?  'Network Cables Used: ' +  envProf.Network_Cables_Used__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Network_Switches_Used_and_Topology__c !=null  ?  'Network Switches Used and Topology: ' +  envProf.Network_Switches_Used_and_Topology__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>Firmware:</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '-----------------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.SBIOS__c !=null  ?  'SBIOS: ' +  envProf.SBIOS__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.PLX__c !=null  ?  'PLX: ' +  envProf.PLX__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.CEC__c !=null  ?  'CEC: ' +  envProf.CEC__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.FPGA__c !=null  ?  'FPGA: ' +  envProf.FPGA__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.BMC__c !=null  ?  'BMC: ' +  envProf.BMC__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.NICs__c !=null  ?  'NICs: ' +  envProf.NICs__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.PSU__c !=null  ?  'PSU: ' +  envProf.PSU__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.MLX__c !=null  ?  'MLX: ' +  envProf.MLX__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.VBIOS__c !=null  ?  'VBIOS: ' +  envProf.VBIOS__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.M_2__c !=null  ?  'M.2: ' +  envProf.M_2__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Firmware_Notes__c !=null  ?  'Firmware Notes: ' +  envProf.Firmware_Notes__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.U_2__c !=null  ?  'U.2 : ' +  envProf.U_2__c + '<p><br></p>' : '');

        } else if (envProf.RecordTypeName__c.contains('vGPU')) {
            /*strEnvProfile = strEnvProfile + 'Name:' + '  '  + envProf.Name + '<p><br></p>' + 'Active:' + '  '  + envProf.Active__c+ '<p><br></p>' );
            strEnvProfile = strEnvProfile + 'Account:' + '  '  + envProf.Account_Name__c + '<p><br></p>' + 'Visible to Customer:' + '  '  + envProf.Visible_to_Customer__c+ '<p><br></p>' );
            strEnvProfile = strEnvProfile + 'Scope:' + '  '  + envProf.Scope__c + '<p><br></p>' + 'Record Type:' + '  '  + envProf.RecordTypeName__c+ '<p><br></p>' );
            strEnvProfile = strEnvProfile + 'Description:' + '  '  + envProf.Description__c+ '<p><br></p><p><br></p>' );*/
            strEnvProfile = strEnvProfile + '<u>Server</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.GRID_Card_Model_s__c !=null ? 'GRID Card Model(s): ' + envProf.GRID_Card_Model_s__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.GRID_Cards_Installed_Per_Server__c !=null ? 'GRID Cards Installed Per Server: ' + envProf.GRID_Cards_Installed_Per_Server__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Server_Brand__c !=null ? 'Server Brand: ' + envProf.Server_Brand__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Virtualization_Platform__c !=null ? 'Virtualization Platform: ' + envProf.Virtualization_Platform__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Server_Model__c !=null ? 'Server Model: ' + envProf.Server_Model__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Hypervisor_Version__c !=null ? 'Hypervisor Version: ' + envProf.Hypervisor_Version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Memory_Per_Server__c !=null ? 'Memory Per Server: ' + envProf.Memory_Per_Server__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Graphics_Virtualization_Type__c !=null ? 'Graphics Virtualization Type: ' + envProf.Graphics_Virtualization_Type__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.vGPU_Manager_Driver_Version__c !=null ? 'vGPU Manager Driver Version: ' + envProf.vGPU_Manager_Driver_Version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Patches_Applied_Over_Host_Hypervisor__c !=null ? 'Patches Applied Over Host Hypervisor: ' + envProf.Patches_Applied_Over_Host_Hypervisor__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.vGPU_Profile__c !=null ? 'vGPU Profile: ' + envProf.vGPU_Profile__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.DRS_Enabled__c !=null ?    'DRS Enabled: ' + envProf.DRS_Enabled__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>VM:</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.Display_Resolution__c !=null ? 'Display Resolution: ' + envProf.Display_Resolution__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.OS__c !=null ? 'OS: ' + envProf.OS__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Display_Driver_Version__c !=null ? 'Display Driver Version: ' + envProf.Display_Driver_Version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.OS_Version__c !=null ? 'OS Version: ' + envProf.OS_Version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.VM_Memory__c !=null ? 'VM Memory: ' + envProf.VM_Memory__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Number_of_vCPUs__c !=null ? 'Number of vCPUs: ' + envProf.Number_of_vCPUs__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Number_of_Displays__c !=null ? 'Number of Displays: ' + envProf.Number_of_Displays__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>License Server</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.License_Server_OS__c !=null ? 'License Server OS: ' + envProf.License_Server_OS__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.License_Server_Host_Type__c !=null ? 'License Server Host Type: ' + envProf.License_Server_Host_Type__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.License_Server_version__c !=null ? 'License Server version: ' + envProf.License_Server_version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>End Point Client</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.Vendor_Name_Model__c !=null ? 'Vendor Name / Model: ' + envProf.Vendor_Name_Model__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Remoting_Solution__c !=null ? 'Remoting Solution: ' + envProf.Remoting_Solution__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.End_Point_Type__c !=null ? 'End Point Type: ' + envProf.End_Point_Type__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Remoting_Solution_Version__c !=null ? 'Remoting Solution Version: ' + envProf.Remoting_Solution_Version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.End_Point_Client_Version__c !=null ? 'End Point Client Version: ' + envProf.End_Point_Client_Version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Remoting_Protocol__c !=null ? 'Remoting Protocol: ' + envProf.Remoting_Protocol__c + '<p><br></p><br/>' : '');

        } else if (envProf.RecordTypeName__c.contains('DRIVE Constellation')) {
            /*strEnvProfile = strEnvProfile + 'Name:' + '  '  + envProf.Name + '<p><br></p>' + 'Active:' + '  '  + envProf.Active__c+ '<p><br></p>' );
            strEnvProfile = strEnvProfile + 'Account:' + '  '  + envProf.Account_Name__c + '<p><br></p>' + 'Visible to Customer:' + '  '  + envProf.Visible_to_Customer__c+ '<p><br></p>' );
            strEnvProfile = strEnvProfile + 'Scope:' + '  '  + envProf.Scope__c + '<p><br></p>' + 'Record Type:' + '  '  + envProf.RecordTypeName__c+ '<p><br></p>' );
            strEnvProfile = strEnvProfile + 'Description:' + '  '  + envProf.Description__c+ '<p><br></p><p><br></p>' );*/
            strEnvProfile = strEnvProfile + '<u>Infrastructure</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '-----------------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.Location__c !=null ?   'Location: ' + envProf.Location__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Rack_Info__c !=null ?  'Rack Info: ' + envProf.Rack_Info__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Security_Restrictions__c !=null ?  'Security Restrictions: ' + envProf.Security_Restrictions__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Power_Source_Type__c !=null ?  'Power Source Type: ' + envProf.Power_Source_Type__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Cooling_Style__c !=null ?  'Cooling Style: ' + envProf.Cooling_Style__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Customer_Contact__c !=null ?   'Customer Contact: ' + envProf.Customer_Contact__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Dedicated_Agent__c !=null ?    'Dedicated Agent: ' + envProf.Dedicated_Agent__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Onsite_Technician__c !=null ?  'Onsite Technician: ' + envProf.Onsite_Technician__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Service_Notes__c !=null ?  'Service Notes: ' + envProf.Service_Notes__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>Operating System & Software</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '-----------------------------------------------<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.Container__c !=null ?  'Container: ' + envProf.Container__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.DriveSim_Version__c !=null ?   'DriveSim Version: ' + envProf.DriveSim_Version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Usage_Type__c !=null ? 'Usage Type: ' + envProf.Usage_Type__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.DriveCC_Version__c !=null ?    'DriveCC Version: ' + envProf.DriveCC_Version__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Drive_Partitioning_Customization__c !=null ?   'Drive Partitioning Customization: ' + envProf.Drive_Partitioning_Customization__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Drive_Partitioning__c !=null ? 'Drive Partitioning: ' + envProf.Drive_Partitioning__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.DL_Framework__c !=null ?   'DL Framework: ' + envProf.DL_Framework__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>Firmware</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '---------------------------------------------<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.SBIOS__c !=null ?  'SBIOS: ' + envProf.SBIOS__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.FPGA__c !=null ?   'FPGA: ' + envProf.FPGA__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.CEC__c !=null ?    'CEC: ' + envProf.CEC__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.NICs__c !=null ?   'NICs: ' + envProf.NICs__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.BMC__c !=null ?    'BMC: ' + envProf.BMC__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.MLX__c !=null ?    'MLX: ' + envProf.MLX__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.PSU__c !=null ?    'PSU: ' + envProf.PSU__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.M_2__c !=null ?    'M.2: ' + envProf.M_2__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.VBIOS__c !=null ?  'VBIOS: ' + envProf.VBIOS__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.U_2__c !=null ?    'U.2: ' + envProf.U_2__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.PLX__c !=null ?    'PLX: ' + envProf.PLX__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Firmware_Notes__c !=null ? 'Firmware Notes: ' + envProf.Firmware_Notes__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + '<br/><u>POD/Cluster Deployments</u>' + '<p><br></p>';
            //strEnvProfile = strEnvProfile + '---------------------------------------------' + '<p><br></p>';
            strEnvProfile = strEnvProfile + (envProf.Storage__c !=null ?    'Storage: ' + envProf.Storage__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Compute_Nodes__c !=null ?  'Compute Nodes: ' + envProf.Compute_Nodes__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Size_of_PODs__c !=null ?   'Size of PODs: ' + envProf.Size_of_PODs__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Network_Cables_Used__c !=null ?    'Network Cables Used: ' + envProf.Network_Cables_Used__c + '<p><br></p>' : '');
            strEnvProfile = strEnvProfile + (envProf.Network_Switches_Used_and_Topology__c !=null ? 'Network Switches Used and Topology: ' + envProf.Network_Switches_Used_and_Topology__c + '<p><br></p>' : '');

        }
        strEnvProfile = strEnvProfile.replace('null', '');
        return strEnvProfile;
    }
    
    /* -----------------------------------------------------------------
      getNVTicket : This method create NV_Ticket__c object and returns to 
      CreateWinDesignSupportRequest Lightning component
    --------------------------------------------------------------------*/
    @auraEnabled
    public static NV_Ticket__c getNV_Ticket() {
        system.debug('**inside getNVBugsCases');
        NV_Ticket__c nvTicket = new NV_Ticket__c ();
        return nvTicket;
    }    

    /* -----------------------------------------------------------------
      createWinDesignSupportRequestFromOpportunity: This method create NV_Ticket__c object and returns to 
      CreateWinDesignSupportRequest Lightning component
    --------------------------------------------------------------------*/
    @auraEnabled
    public static string createWinDesignSupportRequestFromOpportunity (NV_Ticket__c nvTicket, string strOpptyId) {
        system.debug('**inside getNVBugsCases');
        string strNVBug;
        if(nvTicket!=null && nvTicket.Bug_no_in_NVBug_Not_in_SFDC__c==null && !nvTicket.Bug_no_in_NVBug_Not_in_SFDC__c.isNumeric()) 
            return 'NVBug number can not be blank and should be numeric';
        List<Opportunity> lstOppty = [select AccountID, DR_Customer_Contact__c from Opportunity where Id = :strOpptyId];    
        List<NVBug__c> lstsfdcNVbug = [select Id,Synopsis__c,NVBug_Description__c from NVBug__c where name=:nvTicket.Bug_no_in_NVBug_Not_in_SFDC__c];
        Case cse = new Case();
        cse.AccountId = lstOppty.get(0).AccountId;
        cse.Related_Opportunity__c = strOpptyId;
        cse.ContactId = lstOppty.get(0).DR_Customer_Contact__c;
        cse.status = 'New';
        cse.Priority = 'Medium';
        cse.origin= 'Email';
        cse.OwnerId = UserInfo.getUserId();
        cse.RecordTypeId = [SELECT DeveloperName, Id, SobjectType FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Design_Win_Support_Request' ].id;
        if(!lstsfdcNVbug.isEmpty()) {
            cse.subject = lstsfdcNVbug.get(0).Synopsis__c;
            cse.Description = lstsfdcNVbug.get(0).NVBug_Description__c ; 
            nvTicket.NVBug__c = lstsfdcNVbug.get(0).id;
        }
        else{
            NVBug nvbug = getBug(Integer.valueOf(nvTicket.Bug_no_in_NVBug_Not_in_SFDC__c));
            if(nvbug==null)
                return null;
            cse.subject = nvbug.Synopsis;
            if(nvbug!=null && nvbug.Description!=null) 
                cse.Description = nvbug.Description.left(131000);                
        }    
       insert cse;
       nvTicket.Case__c = cse.id;
       nvTicket.Type__c = 'NVBug';
       nvTicket.RecordTypeId = [SELECT DeveloperName, Id, SobjectType FROM RecordType WHERE SobjectType = 'NV_Ticket__c' AND DeveloperName = 'NVBug' ].id;
       insert nvTicket;
       return cse.id; 
    }
    public static Boolean isSandbox(){
        boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        return runningInASandbox;
    }         
    /*==================================================== CLASSES ==========================================================*/
    public class NVBug {
        boolean IsSendNotification;
        integer BugId;
        Integer ApplicationDivisionID;
        string BugType;
        string Synopsis;
        string DescriptionMarkup;
        string Description;
        string DescriptionPlainTextReadOnly;
        Type BugAction;
        string OperatingSystems;
        string GeographicOrigin;
        string Origin;
        string CustomKeywords;
        string Categories;
        string BusinessUnits;
        string Version;
        Type Disposition;
        Type Priority;
        Type Severity;
        Type Engineer;
        Type QAEngineer;
        Type ModuleInfo;
        Type Requester;
        List<ApplicationIntegration> BugApplicationIntegration;
        Object ARB;
        Object CCUsers;
        Object CCGroups;

    }

    class ApplicationIntegration {
        string ApplicationName;
        string ApplicationID;
        string ApplicationURL;
        string LinkSummary;
        integer BugID;
    }

    class Type {
        integer Key;
        string Value;
    }

    class NVBugFile {
        integer BugID;
        string Guid, FileName, OptionalAttacherUserName;
        string Buffer;
        Boolean IsPublic;
    }
    class NVBugSaveBugResponse {
        Integer TotalCount, StartIndex, EndIndex;
        Boolean IsSuccess;
        string ReturnValue, ErrorMessage;
    }
}
//---------------------------------------------------- Redundant / Housekeeping code -------------------------------