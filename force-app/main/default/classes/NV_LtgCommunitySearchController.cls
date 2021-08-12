/*
    Controller for NV_CommunityHomePageSearchResultsPage.cmp
    
    Changelist: SDS-1800 - PUB: SFDC Upload Content Multiselect Filters
                As the ContentVersion > Competency__c field was reference in code, it was not allowing to change the Comptency field to mutli-select.
                Part of the solutioning was to remove the field reference, make the field type change, and put back the field reference.

*/

public class NV_LtgCommunitySearchController { 
    
    public class CommunitySearchWrapper {
        @AuraEnabled public Account[] accounts;  
        @AuraEnabled public Opportunity[] opportunities;
        //@AuraEnabled public ContentVersion[] lstContentVersion;
        @AuraEnabled public Lead[] leads;
        
        public CommunitySearchWrapper(){
            accounts = new List<Account>();        
            opportunities = new List<Opportunity>();  
            //lstContentVersion = new List<ContentVersion>();
            leads = new List<Lead>();
        }
    }
    
    @AuraEnabled
    public static CommunitySearchWrapper search(String searchWord){ 
       
        CommunitySearchWrapper objCommunitySearchWrapper = new CommunitySearchWrapper();
        List<List<SObject>> searchList ;
        Account[] accounts = new Account[]{};  
        Opportunity[] opportunities  = new Opportunity[]{}; 
        //ContentVersion[] lstContentVersion  = new ContentVersion[]{};
        Lead[] leads = new Lead[]{};
        String strCommunitySearchWrapper;
       System.debug('-SSS---- '+ searchWord);
       string searchKeyword;
       if(searchword != null && searchword !=''){
           searchKeyword = searchword ;
           System.debug('-SSS---- '+ searchKeyword );
       }
        accounts.clear();              
        opportunities.clear();
        //lstContentVersion.clear();
        leads.clear();
        searchList = new List<List<SObject>>();
        searchList.clear();
        if(searchKeyword!='' && searchKeyword!=null && searchKeyword.length()>1){       
            searchList = [FIND :searchKeyword IN ALL FIELDS RETURNING 
                                              Account (Id, Name, Phone,AccountNumber,Owner.Alias limit 10),  
                                              Opportunity(Id,AccountId,Name,Account.Name,StageName,CloseDate,Owner.Alias limit 10), 
                                              
                                              Lead (Id,Lead_Number__c,Company,Name,Email,  DR_Partner_Sales_Rep_Name__r.Name,DR_Partner_Sales_Rep_Company__r.Name,Country,Street,City, PostalCode ,State,Region__c ,Sub_Region__c limit 10)
                                              ];
			//ContentVersion(Id, Region__c, Title, Description, Language_Region__c, Competency__c limit 10),											  
            system.debug('Check--------'+searchList);
            system.debug('Check--------'+searchList.size());
            if(searchList.size()>=0)        
            accounts = ((List<Account>)searchList[0]);
            if(searchList.size()>=1)            
            opportunities = ((List<Opportunity>)searchList[1]);
            if(searchList.size()>=2)
            //lstContentVersion = ((List<ContentVersion>)searchList[2]);
            //(searchList.size()>=3)
            leads = ((List<Lead>)searchList[2]);
            objCommunitySearchWrapper.accounts = accounts;
            objCommunitySearchWrapper.opportunities = opportunities;
            //objCommunitySearchWrapper.lstContentVersion = lstContentVersion;
            objCommunitySearchWrapper.leads= leads;
            strCommunitySearchWrapper = String.escapeSingleQuotes(JSON.serialize(objCommunitySearchWrapper));
        }
        return objCommunitySearchWrapper;
    }
    

}