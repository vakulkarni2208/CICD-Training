public class AddUserHelper {       
/*
* This code is copied from DGXRegistrationHelper below is the history.
* PJENA             | 2.4        | 02/12/2019       | Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow
* PJENA             | 2.5        | 03/04/2019       | Licensing 2.0 Changes
* Akhilesh Gupta    | 2.6        | 06/10/2019       | Licensing 2.0 changes
* Akhilesh Gupta    | 2.7        | 07/11/2019       | Common query for vGPU and DGX Entitlements and change logic to not consider sNo
*/

    public static set<String> ProductLineList = new set<String>();
    public static String RWAProdFamily = '';
    @AuraEnabled
    public static String sendRegistrationMail(String email, String hostName, String prodFamilySelected){
        String URL = System.Label.ServiceCloud_UserRegistrationURL;
        String PAKID ='';
        boolean noActiveEntitlement = false;
        
        System.debug('Hello123456');
        User usr = [SELECT id, ContactId FROM User WHERE Id=:UserInfo.getUserId()][0];
        if(usr.ContactId !=null){
            Contact con = [SELECT Id, AccountId FROM Contact WHERE Id=:usr.ContactId][0];
            
            if(con !=null && con.AccountId !=null){
                /*
                //Check if an entitlement exists for the contact's account
                List<Entitlement> lstEntitlements =[SELECT Id, Name, AccountId, Hardware_Serial_Number__c, PAK_ID__c, Status 
                FROM Entitlement
                WHERE AccountId=:con.AccountId AND Status ='Active' 
                AND (Hardware_Serial_Number__c != null OR Subscription__r.SBQQ__Product__r.Family  = :System.Label.ServiceCloud_PAKIdProdFamilyForDGXFlow)];
                */
                
                //string PAKIdProdFamilyForDGXFlow = System.Label.ServiceCloud_PAKIdProdFamilyForDGXFlow;
                //system.debug('***PAKIdProdFamilyForDGXFlow Expected structure - (\'NGC Support\', \'DSWS Support\') and actual value is '  + PAKIdProdFamilyForDGXFlow);
                ProductLineList = ServiceCloudUtils.FindProductLinesForCustomer(con.AccountId);
                string addUserEntQuery = 'SELECT Id, Hardware_Serial_Number__c, PAK_ID__c FROM Entitlement WHERE AccountId = \''  + con.AccountId + '\' AND Status = \'Active\' AND PAK_ID__c != \'\'';// AND Order_Type__c != \'ZMRS\'';
                /*if ( prodFamilySelected == 'DGX') {
                    addUserEntQuery = addUserEntQuery + ' AND (Hardware_Serial_Number__c != null ';
                    if ( string.isNotBlank(PAKIdProdFamilyForDGXFlow) )  addUserEntQuery = addUserEntQuery + ' OR Subscription__r.SBQQ__Product__r.Family in ' + PAKIdProdFamilyForDGXFlow ;
                    addUserEntQuery += ' ) ORDER BY Hardware_Serial_Number__c NULLS LAST';
                } else { //GRID use case
                    addUserEntQuery = addUserEntQuery + ' AND Hardware_Serial_Number__c = null ';
                }*/
                addUserEntQuery += 'ORDER BY EndDate DESC NULLS LAST';
                system.debug('***addUserEntQuery : ' + addUserEntQuery);
                
                //Query the Entitlements
                list<Entitlement> lstEntitlements = database.query(addUserEntQuery);
                
                if(lstEntitlements != null && lstEntitlements.size() > 0){
                    for (Entitlement oEntitlement : lstEntitlements){
                        //if (oEntitlement.Hardware_Serial_Number__c != null || oEntitlement.PAK_ID__c != null ){
                        if (oEntitlement.PAK_ID__c != null ){ //Akhilesh: Removed logic to check for sNo
                            //sNo = oEntitlement.Hardware_Serial_Number__c != null ? oEntitlement.Hardware_Serial_Number__c : oEntitlement.PAK_ID__c;
                            //* PJENA               | 2.5        | 03/04/2019      | Licensing 2.0 Changes - send PAK ID (no SN#)
                            PAKID = oEntitlement.PAK_ID__c;
                            RWAProdFamily = ServiceCloudUtils.getRWAProdFamily(ProductLineList);
                            if(sendonBoardingMail(email, hostName, PAKID, URL, RWAProdFamily) == 'SUCCESS'){
                                return 'SUCCESS';
                            }
                        }
                    }
                }
            }
        }
        return 'ERROR';
    }
    
    /*
    * Send onboarding email
    * Inserts the Notification record into Service_Cloud_New_Member_Notification__c object
    * WF Rule "Service Clould: Notification to New Member" sends the notification with Email Alert named "ServiceCloud: Notification to New DGX Member"
    *   uses email alert "ServiceCloud: Notification to New DGX Member" and that uses email template "ESP Service Cloud: New DGX Member"
    * Change List: PJENA                | 2.4        | 02/12/2019      | Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow
    */
    public static String sendonBoardingMail(String email, String hostName, String PAKID, String URL, string prodFamilySelected){
        User usr = [SELECT ContactId, Contact.AccountId, Contact.FirstName, Contact.LastName FROM User WHERE Id = :UserInfo.getUserId()];
        
        //build the link
        String link = URL   
                        + '?LicType=COMMERCIAL' 
                        + '&ProductFamily=' + prodFamilySelected  
                        //+ '&PEC=' + usr.Contact.AccountId 
                        //+ '&email=' + email  
                        + '&PAKID=' + PAKID 
                        //+ '&addUser=1' 
                        ;
        //Old Link logic
        //String link = //'https://' + hostName+ System.Label.DGX_User_registration_Page_Name + '?email=' + email + URL + '&sNo=' + sNo + '&addUser=1';
        
        Service_Cloud_New_Member_Notification__c notif = new Service_Cloud_New_Member_Notification__c();
        notif.Account__c= usr.Contact.AccountId;
        notif.Link__c   = link;
        notif.Email__c  = email;
        insert notif;
        
        return 'SUCCESS';        
    }
    
    /*
    * Get countries from Country_List__c object     
    @AuraEnabled
    public static Map<String,String> getCountries(){
        List<Country_List__c> countriesDb = new List<Country_List__c>([SELECT Id, Name, ISO_Code__c FROM Country_List__c ORDER BY Name ASC]);
        Map<String,String> countries = new Map<String,String>();
        countries.put( '','');
        countries.put( 'United States', 'US');
        countries.put( 'United Kingdom', 'GB');
        System.debug('Hello@@@@@@@@@@');
        for(Country_List__c c : countriesDb){
        countries.put(c.Name, c.ISO_Code__c );
        }
        return countries; 
    }*/
    
    /*
    * Fetch UserType of logged in User
    * UserType values: DGX | GRID | GRID,DGX
    */
    @AuraEnabled
    public static String UserType() {
        system.debug('Inside getUserType');
        String userType = '';
        
        try {
            User usr = [SELECT id, ContactId, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
            System.debug('User_Details :::' + usr);
            
            if(usr.Profile.Name.contains('NPN'))
            	return 'NPN';
            if(usr.ContactId == null)
                return 'ERROR';
            
            Contact con = [SELECT Id, is_DGX_Contact__c, is_GRID_Contact__c, AccountId FROM Contact WHERE Id=:usr.ContactId];
            System.debug('conDetails :::' + con);
            
            ProductLineList = ServiceCloudUtils.FindProductLinesForCustomer(con.AccountId);
            system.debug('4456: '+ ProductLineList);
            set<String> portalList = ServiceCloudUtils.checkPortalAccess(ProductLineList); 
            system.debug('4456: '+ portalList);
            
            if(portalList.contains(ESP_Constants.LICENSING_PORTAL)){
                userType = ESP_Constants.LICENSING_PORTAL;
            }
            if(portalList.contains(ESP_Constants.SUPPORT_PORTAL)) {
                userType=userType+','+ESP_Constants.SUPPORT_PORTAL;
            }
            /*if(con.is_GRID_Contact__c){
                userType = ESP_Constants.LICENSING_PORTAL;//'GRID';
            }
            if(con.is_DGX_Contact__c){
                userType=userType+ESP_Constants.SUPPORT_PORTAL;//',DGX';
            }*/
            system.debug('userType-->'+userType);
        } catch(Exception e) {
            System.debug(LOGGINGLEVEL.INFO+'Logged error in User/Contact Object'+e.getStackTraceString());
            System.debug('get stack trace..'+e.getStackTraceString());
            PRFT_DomainLayer.PRFT_Error err = new PRFT_DomainLayer.PRFT_Error('Add second User getuserType Error',e.getStackTraceString(),String.valueof(e),null,true);
        }
        return userType;
    }
}


/*
* Perform checks before sending onboarding email
* PJENA             | 2.4        | 02/12/2019      | Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow


@AuraEnabled
public static String sendRegistrationMail(String email,String hostName) {
String URL ='';
String sNo ='';

System.debug('Hello123456');
boolean noActiveEntitlement = false;
User usr = [SELECT id, ContactId FROM User WHERE Id=:UserInfo.getUserId()][0];
if(usr.ContactId !=null){
Contact con = [SELECT Id, AccountId FROM Contact WHERE Id=:usr.ContactId][0];
if(con !=null && con.AccountId !=null){


string PAKIdProdFamilyForDGXFlow = System.Label.ServiceCloud_PAKIdProdFamilyForDGXFlow;
//system.debug('***PAKIdProdFamilyForDGXFlow Expected structure - (\'NGC Support\', \'DSWS Support\') and actual value is '  + PAKIdProdFamilyForDGXFlow);

string addUserEntQuery = 'SELECT Hardware_Serial_Number__c, PAK_ID__c FROM Entitlement WHERE AccountId = \''  + con.AccountId + '\' AND Status = \'Active\'  AND (Hardware_Serial_Number__c != null ';
if ( string.isNotBlank(PAKIdProdFamilyForDGXFlow) )  addUserEntQuery = addUserEntQuery + ' OR Subscription__r.SBQQ__Product__r.Family in ' + PAKIdProdFamilyForDGXFlow ;
addUserEntQuery += ' ) ORDER BY Hardware_Serial_Number__c NULLS LAST';
system.debug('***addUserEntQuery : ' + addUserEntQuery);

//Query the Entitlements
list<Entitlement> lstEntitlements = database.query(addUserEntQuery);


if(lstEntitlements != null && lstEntitlements.size() > 0){
for (Entitlement oEntitlement : lstEntitlements){
if (oEntitlement.Hardware_Serial_Number__c != null || oEntitlement.PAK_ID__c != null ){
sNo = oEntitlement.Hardware_Serial_Number__c != null ? oEntitlement.Hardware_Serial_Number__c : oEntitlement.PAK_ID__c;
if(sendonBoardingMail(email,hostName,sNo,URL) =='SUCCESS'){
return 'SUCCESS';    
}
}
}
}
}
}
return 'ERROR';
}*/
/*
* Send onboarding email
* Inserts the Notification record into Service_Cloud_New_Member_Notification__c object
* WF Rule "Service Clould: Notification to New Member" sends the notification with Email Alert named "ServiceCloud: Notification to New DGX Member"
*   uses email alert "ServiceCloud: Notification to New DGX Member" and that uses email template "ESP Service Cloud: New DGX Member"
* Change List: PJENA                | 2.4        | 02/12/2019      | Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow

public static String sendonBoardingMail(String email,String hostName, String sNo, String URL){
User usr = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
String link = 'https://' + hostName+ System.Label.DGX_User_registration_Page_Name + '?email=' + email + URL + '&sNo=' + sNo + '&addUser=1';
Service_Cloud_New_Member_Notification__c notif = new Service_Cloud_New_Member_Notification__c();
notif.Account__c = usr.Contact.AccountId;
notif.Link__c = link;
System.debug('Hello0000000000');
notif.Email__c = email;
insert notif;
return 'SUCCESS';        
}
*/