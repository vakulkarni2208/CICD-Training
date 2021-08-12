/**************************************************************************************************
* Name       : createServiceCloudUserByUserDetails
* Purpose    : An apex REST service that takes email Id as parameter and searches for related accounts and leads.
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Venkat G           | 1.0        | April 03,2019   | Initial 
**************************************************************************************************/
@RestResource(urlMapping='/NVService/createServiceCloudUserByUserDetails/*')
global class createServiceCloudUserByUserDetails {
    static User userObj;
    static Contact contactObj;
    static Account accountObj;
    static List<Profile> profileList = [SELECT Id,Name FROM Profile];
    static Map<String,Id> profileNameIdMap = new Map<String,id>();
    static List<UserRole> userRoleList = [SELECT Id,Name FROM UserRole];
    static Map<String,Id> userroleNameIdMap = new Map<String,id>();
    static ResponseJson response = new ResponseJson();
    static String message='';
    
    global class ServiceCloudUserInfo {
        public String contactId;
        public String FirstName;
        public String LastName;
        public String Email;
        public String Username;
        public String AccountId;
        public String Role;
        public String Profile;
    }
    public class ResponseJson{
        public String Status {get; set;}
        public Id userId {get;set;}
        public String Message {get;set;}
        public String StatusCode {get; set;}
            
    }
    
    /**************************************************************************************************
    * Input Parameters: No input parameters
    * Output: No return parameter
    * Author : Venkat G
    * Purpose: Takes contact details/user details as input and creates service cloud user and returns user id as response
    ***************************************************************************************************/ 
    @HttpPost 
global static void createServiceCloudUser() {
    String requestBody = RestContext.request.requestBody.toString();
    if(test.isRunningTest()){
    requestBody = '{ "contactId": "003g000001rUSgz", "Email": "muthu9701+1@gmail.com", "Username": "muthu9701+1@gmail.com.v1" }'; 
    }
    ServiceCloudUserInfo serviceCloudWrapp = (ServiceCloudUserInfo) JSON.deserialize(requestBody, ServiceCloudUserInfo.class);
    if(serviceCloudWrapp.username.containsIgnoreCase('nvidia.com'))
        serviceCloudWrapp.username= serviceCloudWrapp.username+'.esp';
    userobj = new User();
    accountObj = new Account();
    if(serviceCloudWrapp!=null){    
        for(Profile ProfObj:profileList){
            profileNameIdMap.put(ProfObj.Name,ProfObj.Id);
        }
        for(UserRole roleObj:userRoleList){
            userroleNameIdMap.put(roleObj.Name,roleObj.Id);
        }
    
        if(!String.isBlank(serviceCloudWrapp.username)){
            getExistingUsers(serviceCloudWrapp.username);
            if(userobj.id!=null){
                message = 'Success :Username already exists';
                
            }
        }
        //if contact id provided in request
        if(String.isBlank(serviceCloudWrapp.contactId) || !getExistingContact(serviceCloudWrapp.contactId)){
                message = 'Please provide valid contact id';
        }
        
        if(!String.isBlank(serviceCloudWrapp.contactId) && String.isBlank(message)){
            userObj = new User(contactId=serviceCloudWrapp.contactId,FirstName=serviceCloudWrapp.FirstName,LastName=serviceCloudWrapp.LastName,Email=serviceCloudWrapp.Email,Username=serviceCloudWrapp.username);
            if(!String.isBlank(serviceCloudWrapp.Role) && userroleNameIdMap.get(serviceCloudWrapp.Role)!=null){
                userobj.UserRoleId = userroleNameIdMap.get(serviceCloudWrapp.Role);
            }
            if(!String.isBlank(serviceCloudWrapp.Profile) && profileNameIdMap.get(serviceCloudWrapp.Profile)!=null){
                userobj.ProfileId = profileNameIdMap.get(serviceCloudWrapp.Profile);
            }
            CreateUser(serviceCloudWrapp.contactId);
            if(userobj.id!=null){
                message = 'Success :Created User';
            }
        }
        //if contact id is blank
        /*if(String.isBlank(serviceCloudWrapp.contactId) && String.isBlank(message)){
            
            if(String.isBlank(serviceCloudWrapp.LastName)){
                message = 'Please provide lastname';
            }
            if(String.isBlank(serviceCloudWrapp.Email)){
                message = 'Please provide email';
            }
            if(String.isBlank(serviceCloudWrapp.Email)){
                message = 'Please provide email';
            }
            getExistingAccount(serviceCloudWrapp.AccountId);
            if(accountObj.id==null || String.isBlank(serviceCloudWrapp.accountId)){
                message = 'Please provide valid account to link to new contact';
            }
            if(String.isBlank(message)){
                contactObj = new Contact(FirstName=serviceCloudWrapp.FirstName,LastName=serviceCloudWrapp.LastName,Email=serviceCloudWrapp.Email,AccountId=serviceCloudWrapp.AccountId);
                newContact(contactObj);
                if(contactObj.Id!=null){
                    userObj = new User(contactId=contactObj.Id,FirstName=serviceCloudWrapp.FirstName,LastName=serviceCloudWrapp.LastName,Email=serviceCloudWrapp.Email,Username=serviceCloudWrapp.username);
                    if(!String.isBlank(serviceCloudWrapp.Role) && userroleNameIdMap.get(serviceCloudWrapp.Role)!=null){
                        userobj.UserRoleId=userroleNameIdMap.get(serviceCloudWrapp.Role);
                    }
                    if(!String.isBlank(serviceCloudWrapp.Profile) && profileNameIdMap.get(serviceCloudWrapp.Profile)!=null){
                        userobj.ProfileId=profileNameIdMap.get(serviceCloudWrapp.Profile);
                    }
                    CreateUser(userObj.contactId,userObj.FirstName,userObj.LastName,userObj.Email,userObj.username,userObj.UserRoleId,userObj.ProfileId,profileNameIdMap,userroleNameIdMap,requestBody);
                    if(userobj.id!=null){
                        message = 'Success :Created User';
                    }
                }
            }
            CreateResponse(userobj.id,'Success',message,'200');
            
        }
        */
        CreateResponse(userobj.id,'Success',message,'200');
        RestResponse responseSend = RestContext.response;
        responseSend.addHeader('Content-Type', 'application/json');
        responseSend.responseBody = Blob.valueOf(JSON.serialize(response));
        createNVLogs('createServiceCloudUser', RestContext.request.requestURI,integer.valueof(response.StatusCode),'Inbound','REST','createServiceCloudUserByUserDetails','RMA', 'Salesforce', 'Request',response.Status,responseSend.responseBody.toString(),requestBody);
        
    }
 }
 
    
    /**************************************************************************************************
    * Input Parameters: String method,String requestEndpoint,Integer statuscode,string methodtype,String APItype,String methodname,String sourcesystem,String targetsystem,String requestType,String status,String response,String request
    * Output: No return parameter
    * Author : Venkat G
    * Purpose:Creates NV logs
    ***************************************************************************************************/ 
    @future
    public static void createNVLogs(String method,String requestEndpoint,Integer statuscode,string methodtype,String APItype,String methodname,String sourcesystem,String targetsystem,String requestType,String status,String response,String request){
        NVLoggerHandler.createNVLoggerWrapper(method, requestEndpoint,statuscode,methodtype,APItype,methodname,sourcesystem, targetsystem, requestType,Status,response,request);
    }

    /**************************************************************************************************
    * Input Parameters: User object
    * Output: No return parameter
    * Author : Venkat G
    * Purpose: Takes user instance as parameter and inserts service cloud user.
    ***************************************************************************************************/ 
    
    public static void CreateUser(String contactId){
        List<Contact> conList = [SELECT Id, firstName, lastName, email, CompanyName__c, Phone  ,MailingCountryCode, MobilePhone, MailingStreet, Mailing_Region__c,   MailingCity,MailingState, MailingCountry, MailingPostalCode FROM Contact WHERE Id =:contactId];
        if(conList!=null && conList.size()>0){
            String alias ='';
            Contact contactObj = conList[0];
            if(userobj.firstName != null && userobj.firstName.length()>0){
                alias =''+contactObj.FirstName.substring(0,1);        
            }
            else if(contactObj.firstName != null && contactObj.firstName.length()>0){
                alias =''+contactObj.FirstName.substring(0,1);
                userObj.firstName = contactObj.Firstname;
            }
            if(userobj.LastName != null && userobj.LastName.length()>0){
                alias = alias+userobj.LastName.substring(userobj.LastName.length());
            }
            else if(contactObj.LastName.length()>0){
                alias = alias+contactObj.LastName.substring(contactObj.LastName.length());
                userObj.LastName = contactObj.LastName;
            } 
            userobj.alias = alias;
            if(String.isBlank(userobj.ProfileId)){
                userobj.ProfileId = profileNameIdMap.get(System.Label.Profile_for_DGX_Registration);     
            }
            if(String.isBlank(userobj.username)){
                userobj.username = contactObj.email;
            }
            
            if(String.isBlank(userobj.FederationIdentifier)){
                userobj.FederationIdentifier = contactObj.email;
            }
            
            userobj.TimeZoneSidKey = 'America/Los_Angeles';
            userobj.EmailEncodingKey = 'UTF-8';
            userobj.LanguageLocaleKey = 'en_US';
            userobj.LocaleSidKey = 'en_US';
            userobj.Street=contactObj.MailingStreet;
            userobj.City=contactObj.MailingCity;
            userobj.Country =  contactObj.MailingCountry; 
            userobj.State = contactObj.MailingState;
            userobj.Country  = contactObj.MailingCountry; 
            userobj.PostalCode= contactObj.MailingPostalCode;   
            userobj.Phone    =contactObj.Phone;
                
            Database.SaveResult srObj = Database.Insert(userobj, false);
            if(srObj!=null){
                if (!srObj.isSuccess()){
                    message =  srObj.getErrors()[0].getMessage();
                }
            }
            else{
                message = 'Success :Created User';
            }
            system.debug('testuser'+message);
        }
        
    }
    
    /**************************************************************************************************
    * Input Parameters: User Id,Status,Message,StatusCode
    * Output: No return parameter
    * Author : Venkat G
    * Purpose: Creates Response object to respond to the 3rd part syatem.
    ***************************************************************************************************/ 
    public static void createResponse(Id userId,String Status,String message,String StatusCode){
        response.Status = Status;
        response.StatusCode = StatusCode;
        response.userId = userId;
        response.Message = message;
    }
    
    /**************************************************************************************************
    * Input Parameters: Contact object
    * Output: No return parameter
    * Author : Venkat G
    * Purpose: Creates contact record
    ***************************************************************************************************
    public static void newContact(Contact contactObj){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SalesContact').getRecordTypeId();
        contactObj.is_Created__c = true;
        contactObj.RecordTypeId = recordTypeId;
        Database.SaveResult srObj = Database.Insert(contactObj, false);
            if(srObj!=null){
                if (!srObj.isSuccess()){
                    message =  srObj.getErrors()[0].getMessage();
                }
            }
    }
    */
    /**************************************************************************************************
    * Input Parameters: Username
    * Output: No return parameter
    * Author : Venkat G
    * Purpose: Queries for existing users with the passed username
    ***************************************************************************************************/ 
    public static void getExistingUsers(String username){
        List<User> userList = [SELECT UserName, Profile.Name, ContactId,id FROM User WHERE UserName = : username limit 1];
        if(userList!=null && userList.size()>0){
            userobj = userList[0];
        }
    }
    
    /**************************************************************************************************
    * Input Parameters: Username
    * Output: No return parameter
    * Author : Venkat G
    * Purpose: Queries for existing users with the passed username
    ***************************************************************************************************
    public static void getExistingAccount(String accountId){
        List<Account> accList = [SELECT Id FROM Account WHERE Id = : accountId limit 1];
        if(accList!=null && accList.size()>0){
            accountObj = accList[0];
        }
    }
    */
    
    /**************************************************************************************************
    * Input Parameters: Username
    * Output: No return parameter
    * Author : Venkat G
    * Purpose: Queries for existing users with the passed username
    ***************************************************************************************************/ 
    public static Boolean getExistingContact(String ContactId){
        List<Contact> ContactList = [SELECT Id FROM Contact WHERE id = : ContactId limit 1];
        if(ContactList!=null && ContactList.size()>0){
            return true;
        }
        return false;
    }
}