public with sharing class ComponentGridPortalSearchPage {
    
    public string instanceMessage {get;set;} 
    public string searchText {get;set;}
    // In constructor we are initilizing all list which need to set of visualforce page.   
    public ComponentGridPortalSearchPage (){        
        showInstanceMessage();                        
    }        
    
    public string hiddenValue {get;set;}
            
    public pagereference ShowSearchResult(){
        system.debug('Check search text values'+hiddenValue);
        pagereference page = new pagereference('/apex/GRID_portalSearch?='+'abcd').setRedirect(true);
        return page;
    }
    
     public void showInstanceMessage(){
        instanceMessage = '';
        List<GRID_VCA_Instant_Message__c>  lstInstanceMessage =  [SELECT Expiration_Date__c,Message__c,Start_Date__c FROM GRID_VCA_Instant_Message__c where Expiration_Date__c>today Order by Expiration_Date__c ASC limit 3];
        for(GRID_VCA_Instant_Message__c grMsg :lstInstanceMessage){        
            instanceMessage = instanceMessage+'  '+grMsg.Message__c;
        }
        
    }
    
}