public class NPN_Tableau_UserMgmt_Bat_sch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, System.Schedulable {

    public string token;
    public string siteId;
    public string siteRole;
    public map<string, string> mapIDMResponseElements = new map<string, string>();
    public list<UserFailure> lstFailureUsers = new list<UserFailure>();
    public String portalPermissions;
    public String userLicense;

    public void execute(SchedulableContext sc){
        NPN_Tableau_UserMgmt_Bat_sch oNPNTableauUserMgtBAtchSch = new NPN_Tableau_UserMgmt_Bat_sch();
        database.executeBatch(oNPNTableauUserMgtBAtchSch, 20);
    }

    public NPN_Tableau_UserMgmt_Bat_sch() {

    }

    //*************************************************************************************************************************
    //  BATCH METHODs
    //*************************************************************************************************************************
    public Database.QueryLocator start(Database.BatchableContext BC){

        Set<String> ppSet = new Set<String>();
        NPN_Tableau_UserMgmt__c objNPNTableauUser = NPN_Tableau_UserMgmt__c.getInstance();

        portalPermissions = objNPNTableauUser.contact_permission__c;
        siteRole = objNPNTableauUser.siterole__c;
        userLicense = objNPNTableauUser.userlicense__c;

        ppSet.add(portalPermissions);

        //siteRole ='Viewer';
        mapIDMResponseElements = NPN_Tableau_Wrapper.signIn(NPN_Tableau_Wrapper.mapIDMResponseElements);
        system.debug('***mapIDMResponseElements :' + mapIDMResponseElements);
        token = mapIDMResponseElements.get('credentialstoken');
        siteId = mapIDMResponseElements.get('siteid');
        system.debug(siteId +'--'+token);
        return Database.getQueryLocator([SELECT Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c,
                                         Tableau_IsUserDeleted__c, Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c,
                                         Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c, Tableau_UserId__c,
                                         Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c
                                         FROM User
                                         WHERE ((IsActive = true AND Tableau_IsUserCreated__c = false AND ContactId != null AND Contact.Portal_Groups__c INCLUDES (: portalPermissions))OR
                                                        (IsActive = true AND Tableau_IsUserCreated__c = true and ContactId != null and Contact.Portal_Groups__c EXCLUDES ( : portalPermissions)) OR
                                                        (IsActive = false AND Tableau_IsUserCreated__c = true AND Tableau_IsUserDeleted__c = false)) AND
                                         Profile.Userlicense.Name =: userLicense AND Tableau_Do_Not_Sync__c = false
                                                                                                                                    
                                        ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        list<User> lstUser = (list<User>) scope;
        for(User objUser : lstUser) {
            if(objUser.isActive && objUser.Contact.Portal_Groups__c.contains(portalPermissions)) {
                mapIDMResponseElements = NPN_Tableau_Wrapper.createTableauUser(objUser.email, siteRole, siteId,  NPN_Tableau_Wrapper.mapIDMResponseElements, token);
                if(mapIDMResponseElements.containskey('iserror') && mapIDMResponseElements.get('iserror') =='false') {
                    objUser.Tableau_IsUserCreated__c = true;
                    objUser.Tableau_UserId__c = mapIDMResponseElements.get('userid');
                    objUser.Tableau_Username__c = mapIDMResponseElements.get('username');
                    objUser.Tableau_UserCreationDateTime__c = system.now();
                    objUser.Tableau_UserCreationLastAPICallResponse__c = mapIDMResponseElements.get('responseStr');
                    objUser.Tableau_IsUserDeleted__c= false;
                    objUser.Tableau_UserDeletionDateTime__c = null;
                    objUser.Tableau_UserDeletionLastAPICallResponse__c ='';
                } else {
                    objUser.Tableau_Do_Not_Sync__c = true;
                    objUser.Tableau_API_Response_Failure__c = mapIDMResponseElements.containsKey('responseStr') ? mapIDMResponseElements.get('responseStr') : '';
                    lstFailureUsers.add(new UserFailure(objUser,objUser.Tableau_API_Response_Failure__c));
                }
            } else {
                mapIDMResponseElements = NPN_Tableau_Wrapper.removeTableauUser(objUser.Tableau_UserId__c, siteId,  NPN_Tableau_Wrapper.mapIDMResponseElements, token);
                if(mapIDMResponseElements.containskey('iserror') && mapIDMResponseElements.get('iserror') =='false') {
                    objUser.Tableau_IsUserDeleted__c= true;
                    objUser.Tableau_UserDeletionDateTime__c = system.now();
                    objUser.Tableau_UserDeletionLastAPICallResponse__c = mapIDMResponseElements.get('responseStr');
                    objUser.Tableau_IsUserCreated__c = false;
                } else {
                    objUser.Tableau_Do_Not_Sync__c = true;
                    objUser.Tableau_API_Response_Failure__c = mapIDMResponseElements.containsKey('responseStr') ? mapIDMResponseElements.get('responseStr') : '';
                    lstFailureUsers.add(new UserFailure(objUser,objUser.Tableau_API_Response_Failure__c));
                }
            }
        }
        update lstUser;
    }

    public void finish(Database.BatchableContext BC){
        NPN_Tableau_Wrapper.signout(token);
        if(!lstFailureUsers.isEmpty()) {
            // send an email with list of failures
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Community_settings__c cs = Community_Settings__c.getInstance();
            String strErrorEmails  = cs.ERROR_EMAILS__c;
            string[] toAddresses = strErrorEmails.split(';');
            for (integer i=0; i < toAddresses.size(); i++) {
                toAddresses[i] = toAddresses[i].trim();
            }
            mail.setToAddresses(toAddresses);
            mail.setSubject('Tableau user batch failed');
            //build the email body
            string html ='<table width="100%">';
            html +='<tr><td><b>ContactIds</b></td><td><b>Reason</b></td></tr>';
            for(UserFailure objUserFailure : lstFailureUsers) {
                html +='<tr><td>' + objUserFailure.objUser.contactId +'</td><td>' + objUserFailure.strErrorMessage +'</td></tr>';
            }
            html +='</table>';

            //set html body
            mail.setHtmlbody(html);

            //send email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public class UserFailure {
        public User objUser;
        public String strErrorMessage;
        public UserFailure(User objUser, String strErrorMessage) {
            this.strErrorMessage = strErrorMessage;
            this.objUser = objUser;
        }
    }
}