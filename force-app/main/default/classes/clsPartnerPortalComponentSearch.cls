public with sharing class clsPartnerPortalComponentSearch {
    
    public string instanceMessage {get;set;}
    //public List<string> lstStringInstanceMessage {get;set;}
    public List<GRID_VCA_Instant_Message__c>  lstInstantMessage {get;set;}
    public string searchText {get;set;}
    
    public List<WrapInstanceMessages> lstWrapInstanceMessages {get;set;} 
    // In constructor we are initilizing all list which need to set of visualforce page.   
    public clsPartnerPortalComponentSearch (){        
        lstWrapInstanceMessages = new List<WrapInstanceMessages>();
        showInstanceMessage();        
                        
    }        
        
    public class WrapInstanceMessages{
        public string message {get;set;}
        public string url {get;set;}
    }
    
    public string hiddenValue {get;set;}
            
    public pagereference ShowSearchResult(){
        system.debug('Check search text values'+hiddenValue);
        pagereference page = new pagereference('/apex/GRID_portalSearch?='+'abcd').setRedirect(true);
        return page;
    }
    
     public void showInstanceMessage(){
        //lstStringInstanceMessage = new List<string>();  
        /*set<string> messagePermissionSets = new set<string>();
        for(PermissionSetAssignment psa :[SELECT AssigneeId,Id,PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment where AssigneeId=:UserInfo.getUserId()]){
           //  if(psa.PermissionSet.Name.contains('MSG'))
             messagePermissionSets.add(psa.PermissionSet.Name);                                  
        }
        system.debug('check-------------'+messagePermissionSets);   
        instanceMessage = '';
        List<GRID_VCA_Instant_Message__c>  lstInstanceMessage =  [SELECT Expiration_Date__c,URL__c,Portal_Permission_Set__c,Portal_Permission_Set__r.Name, Message__c,Start_Date__c FROM GRID_VCA_Instant_Message__c where Expiration_Date__c>today Order by Expiration_Date__c ASC];
        system.debug('lstInstanceMessage---------'+lstInstanceMessage.size());
        for(GRID_VCA_Instant_Message__c grMsg :lstInstanceMessage){
            if(messagePermissionSets.contains(grMsg.Portal_Permission_Set__r.Name)||grMsg.Portal_Permission_Set__c==null){
                WrapInstanceMessages w = new WrapInstanceMessages();
                w.message  = grMsg.Message__c ;
                w.url  = grMsg.URL__c ;
                lstWrapInstanceMessages.add(w);
                //lstStringInstanceMessage.add(grMsg.Message__c);        
            }
            //instanceMessage = instanceMessage+'  '+grMsg.Message__c;
        }
        //system.debug('lstStringInstanceMessage--------'+lstStringInstanceMessage);
        system.debug('lstWrapInstanceMessages--------'+lstWrapInstanceMessages);
        //lstInstantMessage =  [SELECT Expiration_Date__c,Message__c,Start_Date__c FROM GRID_VCA_Instant_Message__c where Expiration_Date__c>today Order by Expiration_Date__c ASC limit 3]; */
        //Get User detail with contact, permission set group & country info
        User objLoggedInUser = new user();
        set<string> setUserPG = new set<string>();
        objLoggedInUser = [SELECT Id, ContactId, Contact.Portal_Groups__c, Contact.MailingCountry FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true]; /*ContactId != null*/
        
        //Get logged in user portal group
        if(objLoggedInUser != null && objLoggedInUser.Contact.Portal_Groups__c != null){
            for(string eachPG: objLoggedInUser.Contact.Portal_Groups__c.split(';')){
                setUserPG.add(eachPG.tolowercase());
            }
        }
        
        list<string> lstPSNames;
        set<string> setCountryNames;
        for(GRID_VCA_Instant_Message__c eachInstantMessage: [SELECT Expiration_Date__c,URL__c,Country__c,Permission_Set_Groups__c,Portal_Permission_Set__c,Portal_Permission_Set__r.Name, Message__c,Start_Date__c FROM GRID_VCA_Instant_Message__c where Expiration_Date__c>today Order by Expiration_Date__c ASC]){
            //CASE 1: If country & permission set group blank then message will be available for all users
            if(eachInstantMessage.Country__c == null && eachInstantMessage.Permission_Set_Groups__c ==  null){
                WrapInstanceMessages wrpMessage = new WrapInstanceMessages();
                wrpMessage.message  = eachInstantMessage.Message__c ;
                wrpMessage.url  = eachInstantMessage.URL__c ;
                lstWrapInstanceMessages.add(wrpMessage);
            }//CASE 2: IF country & permission set group are not blank
            else if(eachInstantMessage.Country__c != null && eachInstantMessage.Permission_Set_Groups__c !=  null){
                //Get selected portal groups of instant message
                lstPSNames = new list<string>();
                if (eachInstantMessage.Permission_Set_Groups__c != null){
                    lstPSNames.addAll(eachInstantMessage.Permission_Set_Groups__c.split(';'));
                }
                
                //Get selected country of instant message
                setCountryNames = new set<string>();
                if (eachInstantMessage.Country__c != null){
                    for(string eachCountry: eachInstantMessage.Country__c.split(';')){
                        setCountryNames.add(eachCountry.tolowercase());
                    }
                }
                
                system.debug(lstPSNames + 'Msg*****User'+setUserPG);
                system.debug(eachInstantMessage.Country__c + 'cnt*****Usercnt'+objLoggedInUser.Contact.MailingCountry);
                //Match portal group & country with instant messages
                if(lstPSNames.size()>0){
                    for(string eachPG: lstPSNames){
                        if(setUserPG != null && setUserPG.contains(eachPG.tolowercase()) && setCountryNames != null && setCountryNames.contains(objLoggedInUser.Contact.MailingCountry.tolowercase())){
                            WrapInstanceMessages wrpMessage = new WrapInstanceMessages();
                            wrpMessage.message  = eachInstantMessage.Message__c ;
                            wrpMessage.url  = eachInstantMessage.URL__c ;
                            lstWrapInstanceMessages.add(wrpMessage);
                        }
                    }
                }
            }//CASE 3: IF permission set group is blank but country is not blank
            else if(eachInstantMessage.Country__c != null && eachInstantMessage.Permission_Set_Groups__c ==  null){
                //Get selected country of instant message
                setCountryNames = new set<string>();
                if (eachInstantMessage.Country__c != null){
                    for(string eachCountry: eachInstantMessage.Country__c.split(';')){
                        setCountryNames.add(eachCountry.tolowercase());
                    }
                }
                
                //Match logged in user country
                if(setCountryNames != null && objLoggedInUser.Contact.MailingCountry != null && setCountryNames.contains(objLoggedInUser.Contact.MailingCountry.tolowercase())){
                    WrapInstanceMessages wrpMessage = new WrapInstanceMessages();
                    wrpMessage.message  = eachInstantMessage.Message__c ;
                    wrpMessage.url  = eachInstantMessage.URL__c ;
                    lstWrapInstanceMessages.add(wrpMessage);
                }
            }//CASE 4: If permission set is not blank but country is balnk
            else if(eachInstantMessage.Country__c == null && eachInstantMessage.Permission_Set_Groups__c !=  null){
                //Get selected portal groups on contact
                lstPSNames = new list<string>();
                if (eachInstantMessage.Permission_Set_Groups__c != null){
                    lstPSNames.addAll(eachInstantMessage.Permission_Set_Groups__c.split(';'));
                }
                
                //Match logged in user portal group
                if(lstPSNames.size()>0){
                    for(string eachPG: lstPSNames){
                        if(setUserPG != null && setUserPG.contains(eachPG.tolowercase())){
                            WrapInstanceMessages wrpMessage = new WrapInstanceMessages();
                            wrpMessage.message  = eachInstantMessage.Message__c ;
                            wrpMessage.url  = eachInstantMessage.URL__c ;
                            lstWrapInstanceMessages.add(wrpMessage);
                        }
                    }
                }
            }
        }
    }
    
}