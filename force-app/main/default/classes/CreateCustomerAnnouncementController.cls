/**************************************************************************************************
* Name       : CreateCustomerAnnouncementController
* Purpose    : Purpose of this controller is
*              - Retrieve the Accounts using the Asset or Account Name search
*              - Make available a selection checkbox (next to each individual account)
*                to select accounts after running the search
*              - Associate the Announcement record to the selected accounts by creating the corresponding
*                Customer Announcement records
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 11/10/2017      | Initial Draft
*Perficient         | 2.0        | 11/22/2017      | Added Search criteria funtionality
**************************************************************************************************/
public class CreateCustomerAnnouncementController {
    
    public Id annId {get;set;}
    public Announcement__c ann {get;set;} 
    public Map <id,Account> selectedAccountMap = new Map <id,Account>();
    public list<Account> selectedList {get;set;}
    public String searchText {get;set;}
    public boolean assetSearch {get;set;}
    public boolean accountSearch {get;set;}
    public String radioSelection{get;set;}
    private String queryString {get;set;}
    public boolean firstSelection = true;
    @TestVisible 
    public List<AccountWrapper> accWrapper {get; set;}    
    
   /*
    *   Construct a SelectOption collection model to support the Product drop down in the User Interface
    *   Query the products from the standard Salesforce Product object   
    */
    public List<SelectOption> lstProduct{
        get{
            List<SelectOption> options = new List<SelectOption>();
            if(selectedProductFamily !=null){
                String query= null;
                String whereClause = null;
                whereClause = 'WHERE Family LIKE \''+selectedProductFamily+'\'  ';
                query = 'SELECT Id, Name, Family FROM Product2 ' + whereClause + ' ORDER BY Name Asc';
                List<Product2> products = Database.query(query);
                for( Product2 product : products){
                    options.add(new SelectOption(product.Name, product.Name));
                }
            }
            return options;
        }
        set;
    }
    public String selectedProduct {get;set;}
    
   /*
    *   Construct a SelectOption collection model to support the Product Family drop down in the User Interface
    *   Retieve the picklist values from the standard field 'Family' available on the standard Salesforce Product object 
    */
    public List<SelectOption> lstProductFamily{
        get{
            List<SelectOption> options = new List<SelectOption>();
            List<Product2> products = [SELECT Id, Name, Family FROM Product2 ORDER BY Name Asc];
            List<Schema.PicklistEntry> ple = Product2.Family.getDescribe().getPicklistValues();
            for( Schema.PicklistEntry productEntry : ple){
                options.add(new SelectOption(productEntry.getLabel(), productEntry.getValue()));
                if(firstSelection){
                    selectedProductFamily = productEntry.getLabel();
                    firstSelection = false;
                }
            }
            return options;
        }
        set;
    }
    public String selectedProductFamily {get;set;}
    public ApexPages.StandardSetController setAcc
    {
        get
        {
            if(setAcc == Null)
            {
                setAcc = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setAcc.setpagesize(10);
            }
            return setAcc;
        }
        set;
    }

   /*
    *   This is the custom controller extension for Announcement. It takes in a single argument namely the standard 
    *   controller for Announcement. The record id is read of this Announcement Apex standard controller.
    *   The record id establishes a context for this custom page i.e the current announcement being worked upon 
    */
    public CreateCustomerAnnouncementController(ApexPages.StandardController controller){
        annId = controller.getId();
        queryString = 'SELECT Id, Name, Recordtype.Name FROM Account WHERE RecordType.DeveloperName = \'New_Customer_Account\' ORDER BY Name Asc LIMIT 10000';
        ann = [SELECT Id, Name from Announcement__c WHERE Id = :annId];
        accountSearch = true;
        assetSearch = false;
        radioSelection = 'accountSearch';
    }
    
   /*
    *   Purpose of this method is create the customer announcement records i.e relate the annoucement to the selected accounts
    *   The selected accounts are the ones retrieved based on search criteria (Asset or Account Name search) 
    *   and selected in the User Interface using the checkbox next to the Account record
    */     
    public PageReference CreateCustomerAnnouncement(){
        setSelectedAccounts();
        selectedList = selectedAccountMap.values();
        system.debug('selectedList-->'+selectedList);
        List<CustomerAnnouncement__c> cusAnnouncement = new List<CustomerAnnouncement__c>();
        for(Account acc:selectedList){
            CustomerAnnouncement__c cusAnn = new CustomerAnnouncement__c();
            cusAnn.Account__c = acc.Id;
            cusAnn.Announcement__c = annId;
            cusAnn.Name = ann.Name;
            cusAnnouncement.add(cusAnn);
        }
        insert cusAnnouncement;
        return new PageReference ('/'+annId);
    }
    
   /*
    *   Instantiate the Account Wrapper object and add it to the Collection of Account wrapper objects
    *   The accounts are retrieved from the Apex Standard Controller container for accounts
    */     
    public List<AccountWrapper> getAccount(){
        setSelectedAccounts();
        accWrapper = new List<AccountWrapper>();
        for(Account acc:(List<Account>)setAcc.getRecords()){
            if(selectedAccountMap.containsKey(acc.Id)){
                accWrapper.add(new AccountWrapper(acc, true));
            }else{
                accWrapper.add(new AccountWrapper(acc, false));
            }
        }
        return accWrapper;
    }
    
   /*
    *   A helper method that will select all accounts (enabling the bool flag to true)
    */    
    public void SelectAll(){
        for(AccountWrapper acc: accWrapper){
            acc.bool = true;
        }
    }
   /*
    *   A helper method that will de-select all accounts (set the bool flag to false)
    */      
    public void DeSelectAll(){
        for(AccountWrapper acc: accWrapper){
            acc.bool = false;
        }
    }

   /*
    *   This method gathers the selected accounts from the Account Wrapper list.
    *   If an Account is selected, the bool checkbox equates to true 
    */
    public void setSelectedAccounts(){
        if(accWrapper !=null){
            for(AccountWrapper accWrapItem :accWrapper){
                if(accWrapItem.bool){
                    system.debug('accWrapItem.acc-->'+accWrapItem.acc);
                    selectedAccountMap.put(accWrapItem.acc.Id, accWrapItem.acc);
                }else{
                    selectedAccountMap.remove(accWrapItem.acc.Id);
                }
            }
        }
    }
    
   /*
    *   There are two ways to go about searching for accounts.
    *   Asset Search - Use the product name to retrieve all related accounts from the ESP Asset custom object
    *   Account Search - Use the text search string to run a query on Accounts
    *   In both cases, an Apex Standard Controller is instantiated with the collection of Accounts from the search 
    *
    */
    public PageReference  fetchAccounts(){
        setSelectedAccounts();
        String whereClause = '';
        /* SDS-2462 This code is commented to remove dependency on ESP_Asset object
         * if(radioSelection.equals('assetSearch')){
            String productName = '%'+ selectedProduct + '%';
            ESP_Asset__c[] assets = [SELECT Id, Product__r.name, Account__c FROM ESP_Asset__c WHERE Product__r.name LIKE :productName];
            String accountId ='';
            for(ESP_Asset__c a:assets){
                accountId = accountId +'\''+ a.Account__c + '\',';
            }
            if(accountId.length() >0){
                accountId= accountId.removeEnd(',');
                whereClause = 'WHERE Id IN ('+accountId+')';
            }else
                whereClause = '';
        } */
        if(radioSelection.equals('accountSearch')){
            if(searchText !=null && searchText.length() >0){
                whereClause = 'WHERE Name LIKE \'%'+searchText+'%\'  ';
            }
        }
        searchText='';
        queryString = 'SELECT Id, Name, Recordtype.Name from Account '+ whereClause +'ORDER BY Name Asc';  
        
        if(whereClause != null && whereClause.length() >0){
            setAcc = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
            setAcc.setpagesize(10);
        }else{
            setAcc = new ApexPages.StandardSetController(new List<account>());
            setAcc.setpagesize(10);
        }
        
        return null;
    }
    
    //Redirecting to Announcement page
    public PageReference Cancel(){
        return new PageReference ('/'+annId);
    }
    
    @TestVisible
   /*
    *   This is a Account Wrapper container that holds information which accounts have been select in the User Interface
    *   If an Account is selected, the bool checkbox equates to true 
    */
    public class AccountWrapper{
        Public Account acc{get;set;}
        Public boolean bool{get;set;}
        public AccountWrapper(Account acc,boolean bool)
        {
            this.acc = acc;
            this.bool = bool;
        }
    }
}