public without sharing class cmpPartnerPortalMessage_cls {
    public List<InstanceMessageWrapper> lstWrappedInstanceMessages {get;set;} //lstWrapInstanceMessages = lstWrappedInstanceMessages
    
    //Constructor: gather all instant messages
    public cmpPartnerPortalMessage_cls(){
        getAllInstanceMessages();
    }        
    
    //WrapInstanceMessages = InstanceMessageWrapper
    public class InstanceMessageWrapper{
        public string message {get;set;}
        public string url {get;set;}
    }
    
    private void getAllInstanceMessages(){
        
        /*Logic to show Instant Messages
        CASE 1: If country & permission set group blank then message will be available for all users
        CASE 2: IF both country & permission set group are not blank
        CASE 3: IF permission set group is blank but country is not blank
        CASE 4: If permission set is not blank but country is balnk
        Note: It will no longer look at the individual Permission Set assigned
        */
        lstWrappedInstanceMessages = new List<InstanceMessageWrapper>();
        
        //Get User detail with contact, permission set group & country info. Expect that the logged on user will be always active and unique
        User portalUser = [ Select Id, ContactId, Contact.Portal_Groups__c, Contact.MailingCountry 
                            From User 
                            Where Id = :UserInfo.getUserId()];
        
        //Get Portal User's Permission Set Groups in lower case
        set<string> setPortalUserPSGroups = new set<string>();
        if(portalUser.Contact.Portal_Groups__c != null){
            for(string strPSGroup : portalUser.Contact.Portal_Groups__c.split(';')){
                if (strPSGroup != null || strPSGroup != '') setPortalUserPSGroups.add(strPSGroup.tolowercase().trim());
            }
        }
        
        //Get Portal User's Mailing Country in lower case
        string portalUserMailingCountry = portalUser.Contact.MailingCountry;
        if (portalUserMailingCountry != null) portalUserMailingCountry = portalUserMailingCountry.toLowerCase();
        
        
        
        list<GRID_VCA_Instant_Message__c> lstAllUnExpiredMessages = [   Select URL__c, Country__c, Permission_Set_Groups__c, Message__c 
                                                                        From GRID_VCA_Instant_Message__c 
                                                                        Where Expiration_Date__c > today
                                                                        Order By Expiration_Date__c ASC ];
        
        system.debug('>>>  lstAllUnExpiredMessages.size() = '+ lstAllUnExpiredMessages.size());
        system.debug('>>>  lstAllUnExpiredMessages = '+ lstAllUnExpiredMessages);
        for (GRID_VCA_Instant_Message__c msg : lstAllUnExpiredMessages){
            if(msg.Country__c == null && msg.Permission_Set_Groups__c ==  null){
            //CASE 1: If country & permission set group blank =>  message will be available for all users
            
                InstanceMessageWrapper wrpMessage = new InstanceMessageWrapper();
                wrpMessage.message  = msg.Message__c ;
                wrpMessage.url  = msg.URL__c ;
                lstWrappedInstanceMessages.add(wrpMessage);
            } else if (msg.Country__c != null && msg.Permission_Set_Groups__c !=  null){
            //CASE 2: IF both country & permission set group are not blank => Message shown to users with matching PSG and Country
                
                //Get all PS Groups from Instant Message record
                list<string> lstPSGroupNamesInMsg = new list<string>();
                set<string> setPSGroupNamesInMsg = new set<string>(); //useful for having contains method
                lstPSGroupNamesInMsg.addAll(msg.Permission_Set_Groups__c.split(';'));
                for (string strPSGroup : lstPSGroupNamesInMsg){
                    setPSGroupNamesInMsg.add(strPSGroup.toLowerCase().trim());
                }
                
                //Get all Country list from  Instant Message record
                list<string> lstCountryNamesInMsg = new list<string>();
                set<string> setCountryNamesInMsg = new set<string>(); //useful for having contains method
                lstCountryNamesInMsg.addAll(msg.Country__c.split(';'));
                for (string strCountry : lstCountryNamesInMsg){
                    setCountryNamesInMsg.add(strCountry.toLowerCase().trim());
                }
                
                //Check if the PSG group and Country is matching
                boolean isPSGroupMatchFound = false;
                boolean isCountryMatchFound = false;
                
                for (string psgInMsg : setPSGroupNamesInMsg){
                    for (string psgInContact : setPortalUserPSGroups ){
                        if (psgInMsg == psgInContact){
                            isPSGroupMatchFound = true;
                            break;
                        }
                    }
                    if (isPSGroupMatchFound) break;
                }
                
                if (setCountryNamesInMsg.contains(portalUserMailingCountry)){
                    isCountryMatchFound = true;
                }
                
                //if both PSG and Country match found, add the message to the list
                if (isPSGroupMatchFound && isCountryMatchFound){
                    InstanceMessageWrapper wrpMessage = new InstanceMessageWrapper();
                    wrpMessage.message  = msg.Message__c ;
                    wrpMessage.url  = msg.URL__c ;
                    lstWrappedInstanceMessages.add(wrpMessage);
                }
            } else if (msg.Country__c != null && msg.Permission_Set_Groups__c ==  null){
            //CASE 3: If Permission Set Group is blank but Country is not blank => Message shown to users with matching Country
                
                //Get all Country list from  Instant Message record
                list<string> lstCountryNamesInMsg = new list<string>();
                set<string> setCountryNamesInMsg = new set<string>(); //useful for having contains method
                lstCountryNamesInMsg.addAll(msg.Country__c.split(';'));
                for (string strCountry : lstCountryNamesInMsg){
                    setCountryNamesInMsg.add(strCountry.toLowerCase().trim());
                }
                
                //check if County is matching 
                boolean isCountryMatchFound = false;
                if (setCountryNamesInMsg.contains(portalUserMailingCountry)){
                    isCountryMatchFound = true;
                }
                
                //if Country match found, add the message to the list
                if(isCountryMatchFound){
                    InstanceMessageWrapper wrpMessage = new InstanceMessageWrapper();
                    wrpMessage.message  = msg.Message__c ;
                    wrpMessage.url  = msg.URL__c ;
                    lstWrappedInstanceMessages.add(wrpMessage);
                }
            } else if (msg.Country__c == null && msg.Permission_Set_Groups__c !=  null){
            //CASE 4: If Permission Set Group is NOT blank but Country is blank => Message shown to users with matching PSG
                
                //Get all PS Groups from Instant Message record
                list<string> lstPSGroupNamesInMsg = new list<string>();
                set<string> setPSGroupNamesInMsg = new set<string>(); //useful for having contains method
                lstPSGroupNamesInMsg.addAll(msg.Permission_Set_Groups__c.split(';'));
                for (string strPSGroup : lstPSGroupNamesInMsg){
                    setPSGroupNamesInMsg.add(strPSGroup.toLowerCase().trim());
                }
                
                //check if the PSG is matching
                boolean isPSGroupMatchFound = false;
                for (string psgInMsg : setPSGroupNamesInMsg){
                    for (string psgInContact : setPortalUserPSGroups ){
                        if (psgInMsg == psgInContact){
                            isPSGroupMatchFound = true;
                            break;
                        }
                    }
                    If(isPSGroupMatchFound) break;
                }
                
                //If PSG match found, add the message to the list
                if(isPSGroupMatchFound){
                    InstanceMessageWrapper wrpMessage = new InstanceMessageWrapper();
                    wrpMessage.message  = msg.Message__c ;
                    wrpMessage.url  = msg.URL__c ;
                    lstWrappedInstanceMessages.add(wrpMessage);
                }
            }
            
        }
    }
}