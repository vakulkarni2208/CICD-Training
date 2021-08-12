/*
    Controller for NV_CommunitySearchController
    
    Changelist: SDS-1800 - PUB: SFDC Upload Content Multiselect Filters
                As the ContentVersion > Competency__c field was reference in code, it was not allowing to change the Comptency field to mutli-select.
                Part of the solutioning was to remove the field reference, make the field type change, and put back the field reference.

*/
public with sharing class NV_CommunitySearchController {
    public string instanceMessage {get;set;} 
    // Varibale declarations.
    public string searchKeyword {get;set;}
    public String searchword { get; set; }
    public boolean isShow {get;set;}
    public Account[] accounts {get;set;}    
    public Opportunity[] opportunities {get;set;}
    public Lead[] leads {get;set;} 
    public Case[] cases {get;set;}
    public Contract[] Contracts {get;set;} 
    public Document[] documents {get;set;}
    public Product2[] products {get;set;} 
    public Campaign[] Campaigns{get;set;}
    public ContentVersion[] lstContentVersion {get;set;}
    public String strCommunitySearchWrapper{get;set;}
    public CommunitySearchWrapper objCommunitySearchWrapper;
    
    public class CommunitySearchWrapper {
        Account[] accounts;  
        public Opportunity[] opportunities;
        public Lead[] leads; 
        public Case[] cases;
        public Contract[] Contracts; 
        public Document[] documents;
        public Product2[] products; 
        public Campaign[] Campaigns;
        public ContentVersion[] lstContentVersion;
        
        public CommunitySearchWrapper(){
            accounts = new List<Account>();        
            opportunities = new List<Opportunity>();
            leads = new List<Lead>();
            cases = new List<Case>();
            Contracts = new List<Contract>();
            documents = new List<Document>();
            products = New List<Product2>(); 
            Campaigns = new List<Campaign>();     
            lstContentVersion = new List<ContentVersion>();
            
        }
    }

    //public ContentVersion[] lstContentVersion {get;set;}
    
    
    // In constructor we are initilizing all list which need to set of visualforce page.   
    public NV_CommunitySearchController(){
          objCommunitySearchWrapper = new CommunitySearchWrapper();
          showInstanceMessage();
          showResults();
          system.debug('Check list accounts size'+accounts.size());
          system.debug('Check list opportunities size'+opportunities.size());
          system.debug('Check list leads size'+leads.size());
          system.debug('Check list cases size'+cases.size());
          system.debug('Check list Contracts size'+Contracts.size());
          system.debug('Check list documents size'+documents);
          system.debug('Check list products size'+products.size());          
    }  
    public void init(){
        searchKeyword = ApexPages.CurrentPage().getParameters().get('searchText');
        accounts = new List<Account>();        
        opportunities = new List<Opportunity>();
        leads = new List<Lead>();
        cases = new List<Case>();
        Contracts = new List<Contract>();
        documents = new List<Document>();
        products = New List<Product2>(); 
        Campaigns = new List<Campaign>();
        lstContentVersion = new List<ContentVersion>();
        
    }      
    
    public List<List<SObject>> searchList {get;set;}
    // This method is querying few of the object's list with limit 10 and seperating the indivisual list for each object.
    public PageReference showResults(){
       system.debug('searchKeyword-->' +searchword ); 
       init();
       if(searchword != null && searchword !=''){
           searchKeyword = searchword ;
           System.debug('-SSS---- '+ searchKeyword );
       }
        accounts.clear();              
        opportunities.clear();
        leads.clear();  
        cases.clear();
        Contracts.clear();
        documents.clear();
        products.clear(); 
        Campaigns.clear();
        lstContentVersion.clear();
        searchList = new List<List<SObject>>();
        searchList.clear();
        if(searchKeyword!='' && searchKeyword!=null && searchKeyword.length()>1){       
            searchList = [FIND :searchKeyword IN ALL FIELDS RETURNING 
                                              Account (Id, Name, Phone,AccountNumber,Owner.Alias limit 10),  
                                              Opportunity(Id,AccountId,Name,Account.Name,StageName,CloseDate,Owner.Alias limit 10), 
                                              /*Lead(Id,Name,Title,LeadSource,Phone,Company,Email,Status,Owner.Alias limit 10),
                                              Case(Id, ContactId,CaseNumber,Contact.Name,Priority,Status,Subject limit 10),
                                              Contract(Id,AccountId,ContractNumber,EndDate,StartDate,Status limit 10),
                                              Document(Id,Description,Name,Type limit 10),
                                              Product2(Id,Description,Family,IsActive,Name limit 10),
                                              Campaign(EndDate,Name,ParentId,parent.Name,StartDate,Type limit 10),
                                              xMDF_Project__c(Id, Name, Project_Name__c, MDF_Partner__r.Name, MDF_Activity__r.Name, Project_Description__c, Partner_Claim_Invoice_Number__c, Partner_Claim_Amount__c, Maximum_Project_Cost_to_be_Reimbursed__c, RecordType.Name limit 10),*/
                                              ContentVersion(Id, Region__c, Title, Description, Language_Region__c, Competency__c limit 10),
                                              Lead (Id,Lead_Number__c,Company,Name,Email,  DR_Partner_Sales_Rep_Name__r.Name,DR_Partner_Sales_Rep_Company__r.Name,Country,Street,City, PostalCode ,State,Region__c ,Sub_Region__c  limit 10)
                                              ];
            system.debug('Check--------'+searchList);
            system.debug('Check--------'+searchList.size());
            if(searchList.size()>=0)        
            accounts = ((List<Account>)searchList[0]);
            if(searchList.size()>=1)            
            opportunities = ((List<Opportunity>)searchList[1]);            
            if(searchList.size()>=2)
            lstContentVersion = ((List<ContentVersion>)searchList[2]);
            if(searchList.size()>=3)
            leads = ((List<Lead>)searchList[3]);
            
            /*leads = ((List<Lead>)searchList[2]);
            if(searchList.size()>=3)            
            cases = ((List<Case>)searchList[3]);
            if(searchList.size()>=4)            
            Contracts= ((List<Contract>)searchList[4]);
            if(searchList.size()>=5)            
            documents= ((List<Document>)searchList[5]);
            if(searchList.size()>=6)            
            products= ((List<Product2>)searchList[6]);
            if(searchList.size()>=7)            
            Campaigns= ((List<Campaign>)searchList[7]);
            if(searchList.size()>=8)            
            MDFProjects= ((List<xMDF_Project__c>)searchList[8]);
            */
            system.debug('Check------'+searchList.size());
            if(accounts.size()>0 || opportunities.size()>0 || leads.size()>0 || cases.size()>0 || Contracts.size()>0 || documents.size()>0 ||products.size()>0 || Campaigns.size()>0 || lstContentVersion.size() > 0){
                isShow = true;
            }
            if(accounts.size()==0 && opportunities.size()==0 && leads.size()==0 && cases.size()==0 && Contracts.size()==0 && documents.size()==0 && products.size()==0 && Campaigns.size()==0 && lstContentVersion.size() == 0){
                isShow = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Results found! - Modify Your Search')); 
            }
            objCommunitySearchWrapper.accounts = accounts;
            objCommunitySearchWrapper.opportunities = opportunities;
            objCommunitySearchWrapper.leads = leads;
            objCommunitySearchWrapper.cases = cases;
            objCommunitySearchWrapper.Contracts = Contracts;
            objCommunitySearchWrapper.documents = documents;
            objCommunitySearchWrapper.Campaigns = Campaigns;
            objCommunitySearchWrapper.lstContentVersion = lstContentVersion;
            strCommunitySearchWrapper = String.escapeSingleQuotes(JSON.serialize(objCommunitySearchWrapper));
        }
        if(searchList.size()==0){
          //  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Such Records found in System! - Modify Your Search')); 
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.COMM_PP_VF_MSG_No_Search_Results)); 
            isShow = false;   
        }
        

        return null;
    }
    
    public pagereference ShowSearchResult(){
        
        pagereference pf = new pagereference('/apex/NV_CommunitySearch?searchText='+searchKeyword);
        pf.setRedirect(true);
        return pf;
    }
    
     public void showInstanceMessage(){
        instanceMessage = '';
        List<GRID_VCA_Instant_Message__c>  lstInstanceMessage =  [SELECT Expiration_Date__c,Message__c,Start_Date__c FROM GRID_VCA_Instant_Message__c where Expiration_Date__c>today Order by Expiration_Date__c ASC limit 2];
        for(GRID_VCA_Instant_Message__c grMsg :lstInstanceMessage){        
            instanceMessage = instanceMessage+grMsg.Message__c;
        }
        
    }
}