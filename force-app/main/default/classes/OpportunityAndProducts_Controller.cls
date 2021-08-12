/*
 *    Controller Extension for the OpportunityAndProducts Visualforce page. 
 *  Allows the user to enter basic information for a Notebook Opportunity and add
 *    Products and Product Schedules, all on the same page.
 *
 *  Created: Summer, 2010
 *
 *  By: Duncan Stewart, OpFocus
 *
 * @Manideep: 5/8/2019 - This code is commented as its not being used and in the process of Opportunity RecordType 
*/
public class OpportunityAndProducts_Controller {
	
  // Dummy method for code coverage
  // This method is coverred by the class 'UnitTests_DummyCodeCoverage_DEL_Classes.cls'
  public static void fakeMethod(){
    Integer i = 0;
    i++;
  }

/*

    public Account account {get; private set;}
    public Opportunity opportunity {get; set;}
    public Pricebook2 pricebook {get; set;}
    public List<PricebookEntry> pbes {get; set;}
    public Product2 product {get; set;}
    public String namedAccountName {get; private set;}
    public String[] productLines { get; set;}

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();            
        options.add(new SelectOption('Initial Discussions', 'Initial Discussions'));
        options.add(new SelectOption('RFQ', 'RFQ'));
        options.add(new SelectOption('Closed Won', 'Closed Won'));
        options.add(new SelectOption('Closed/Lost', 'Closed/Lost'));
        return options;
    }
    
    // searchText is used to drill-down the Product query
    public String searchText {get; set;}
    
    public OLIHelper[] helpers {get; set;}
    public OLIHelper[] deletedHelpers {get; set;}
    public Integer selectedHelper {get; set;}
    public Id notebookPricebookId {get; set;}
    public Id selectedPbeId {get; set;}
    public String selectedProductName {get; set;}
    public PricebookEntry selectedProduct {get; set;}
    public String selectedQuantity {get; set;}
    public String selectedASP {get; set;}
    
    public class OLIHelper {
        public Integer index {get; set;}
        public PricebookEntry pbe {get; set;}
        public OpportunityLineItem oli {get; set;}
    }
        
    public List<Schedule_Entry__c> lstSEs {get; set;}
                    
    public OpportunityAndProducts_Controller() {
        namedAccountName = '';
        productLines = new List<String>();
        
        // search() retrieves all the Product entries from the (Standard) Pricebook;
        search();
        
         // Initialize the helpers
        deletedHelpers = new OLIHelper[]{};
        helpers = new OLIHelper[]{};
        for (Integer i=0; i<4; i++) {
            OLIHelper olih = new OLIHelper();
            olih.index = i;
            olih.pbe = new PricebookEntry();
            olih.oli = new OpportunityLineItem();
            helpers.add(olih);
        }
        
        String rtId = ApexPages.currentPage().getParameters().get('RecordType');
        
        Map<String, Schema.RecordTypeInfo> mapRTIs = Utils.getAccessibleRecordTypeInfosForSObject(new Opportunity());
                
        String currParamId = ApexPages.currentPage().getParameters().get('id');
        
        Map<String, Id> mapRTNamesById = Utils.mapRecordTypeIdsByName('Opportunity');
        
        if ((Id) rtId == mapRTNamesById.get('Notebook Opportunity')) {
                                                    
            if(currParamId.startsWith('001')){
                // System.debug('====== Working on a new Opportunity from an Account ...');
                                
                // this was opened from an Account
                account = 
                  [Select id, Name, Named_Account_Name__c
                   From   Account
                   Where  id = :currParamId];
                
                namedAccountName = account.Named_Account_Name__c;
                           
                opportunity = new Opportunity();
                opportunity.RecordTypeId = rtId;                                
                                
                Date today = Date.Today();
                opportunity.AccountId = account.Id;
                //opportunity.Name = account.Name + '-' + today.month() + '/' + today.day();

                // Set a default Close Date ~ two months from the current date
                Date closeDate = today.addMonths(2);
                opportunity.CloseDate = closeDate.toStartOfMonth();
                                
                //opportunity.StageName = 'Initial Discussions';
                //opportunity.Probability = 1;
                                                                
                lstSEs = new List<Schedule_Entry__c>();
                        
                pricebook = new Pricebook2(Id=notebookPricebookId);
                                
                // Set the default Design/Production Start Date to the 15th of the month, 2 months hence
                opportunity.Design_Start_Date__c = closeDate.toStartOfMonth() + 14;
                opportunity.Design_EOL_Date__c = (opportunity.Design_Start_Date__c).addMonths(1);
            } 
                        
            else if(currParamId.startsWith('006')){
                // System.debug('====== Working on an Opportunity edit ...');
                // this is an edit for existing Opportunity
                getAccount(currParamId);
                                
                opportunity = 
                  [Select Name, RecordTypeId, CloseDate, Description, Probability, StageName, Type, Pricebook2.Id, AccountId,
                                Closed_Lost_Comments__c, Customer_Type__c, Memory_Type__c,
                                At_Risk_Level__c, CPU_TDP__c, CPU_Type__c, Design_Start_Date__c, Design_EOL_Date__c, GPU_TDP__c,
                                Notebook_ODM__c, Notebook_Product_Line__c, Optimus__c, Package__c, Panel_Size__c, Probability_of_Winning__c,
                                Sales_Lead__c, Ventura__c, X3D_HDTV__c, X3D_Vision__c
                   From   Opportunity
                   Where  id = :currParamId];
                
                if (opportunity.Notebook_Product_Line__c == null)
                    productLines = new List<String>();
                else
                    productLines = opportunity.Notebook_Product_Line__c.split(';');
                                                                                
                account = 
                  [Select id, Name, Named_Account_Name__c
                   From   Account
                   Where  id = :Opportunity.AccountId];

                namedAccountName = account.Named_Account_Name__c;

                List<OpportunityLineItem> olis = 
                  [Select OpportunityId, PricebookEntryId, Quantity, Monthly_Quantity__c, TotalPrice, UnitPrice, Product_Name__c,
                          PricebookEntry.Name, PricebookEntry.Id, PricebookEntry.UnitPrice, 
                          PricebookEntry.Product2.Family, PricebookEntry.Product2.Description,
                          PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Name, PricebookEntry.Product2.Id 
                   From   OpportunityLineItem
                   Where  OpportunityId = :currParamId];
                                   
                // Create the OLIHelpers for this Opportunity
                integer index = 0;
                helpers = new OLIHelper[]{};        
                for(OpportunityLineItem oli :olis){
                    OLIHelper olih = new OLIHelper();
                    olih.pbe = oli.PricebookEntry;
                    olih.oli = oli;                                      
                    olih.index = index;
                    helpers.add(olih);
                    index++;
                }
                                
                for(integer i = helpers.size(); i < 4; i++) {
                    OLIHelper olih = new OLIHelper();
                    olih.index = i;
                    olih.pbe = new PricebookEntry();
                    olih.oli = new OpportunityLineItem();
                    helpers.add(olih);
                }
            }
                                
            else {
                //System.debug('====== Working on a new Opportunity from Opportunities list ...');
                // This was called from the Opportunities tab                                             
                opportunity = new Opportunity();
                opportunity.RecordTypeId = rtId;                                
                                                        
                Date closeDate = Date.today().addMonths(2);
                opportunity.CloseDate = closeDate.toStartOfMonth();
                //opportunity.StageName = 'Initial Discussions';
                //opportunity.Probability = 1;
                                                
                lstSEs = new List<Schedule_Entry__c>();
        
                pricebook = new Pricebook2(Id=notebookPricebookId);
                
                opportunity.Design_Start_Date__c = closeDate.toStartOfMonth() + 14;
                opportunity.Design_EOL_Date__c = (opportunity.Design_Start_Date__c).addMonths(1);
            }
                        
        } else {
            //System.debug('====== Opportunity Record Type was not \'Notebook Opportunity\' ' + currParamId + ' ' + rtId);
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Incorrect Opportunity Record Type was provided: ' + rtId);
            ApexPages.addMessage(msg);
        }
    }      

    public PageReference selectHelper() {
        // Keeping in place in case we add additional Record Types
        return null;
    }
        
    public PageReference getAccount(Id oppId) {
        if(account == null) {
            Opportunity tmpOpp = new Opportunity();
            tmpOpp = [Select AccountId from Opportunity where Id = :oppId];
            account = [Select Name, Named_Account_Name__c from Account where Id = :tmpOpp.AccountId];
            if (namedAccountName != account.Named_Account_Name__c)
                if (opportunity != null) opportunity.Notebook_Product_Line__c = '';
            namedAccountName = account.Named_Account_Name__c;
        }
        return null;
    }
    
    // The user just changed the AccountId for this Opp. Fetch that Account.
    public PageReference changedAccount() {
        account = [Select Name, Named_Account_Name__c from Account where Id = :opportunity.AccountId];
        namedAccountName = account.Named_Account_Name__c;
        return null;
    }
    
    public List<SelectOption> lstSOsForNamedAccountProductLines {
        get {
            List<SelectOption> lstSOs = new List<SelectOption>();
            try {
                Named_Account_Product_Lines__c rec = 
                  [select Product_Lines__c
                   from   Named_Account_Product_Lines__c
                   where  Name = :namedAccountName];
                List<String> lstProductLines = rec.Product_Lines__c.split(',');
                for (String productLine : lstProductLines) {
                    lstSOs.add(new SelectOption(productLine, productLine));
                }
            }
            catch (Exception ex) {
                // This Named Account wasn't found. Return an empty list.
                opportunity.Notebook_Product_Line__c = null;
            }
            return lstSOs;
        }
    }
        
    public PageReference search() {
        
        // search() takes a Product name snippet and return a list of PricebookEntries with that prefix      
        notebookPricebookId = 
          [select id 
           from   Pricebook2 
           where  Name = 'Notebook Price Book'].id;

        try {
            String strFieldNames = 'Id, UnitPrice, Product2.Family, Product2.Description, Product2.ProductCode,' + 
                                   'Product2.Name, Product2.Id, Name';
                        
            String soql = 'Select ' + strFieldNames + 
                          ' From PriceBookEntry' + 
                          ' Where  Pricebook2.id = :notebookPricebookId ';

            string newSearchText = searchText + '%';
            
            if (searchText <> null && searchText <> '')
                soql += ' and Name like :newSearchText';
            
            soql += ' and IsActive = true';
            soql += ' order by Product2.Product_Sort_Order__c DESC, Name ';
            pbes = Database.query(soql);

        } 
        catch (Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '' + ex );
            ApexPages.addMessage(msg);
        }
        
        return null;
    }
                 
    public PageReference selectProduct() {
        // selectProduct() takes the current row's PricebookEntry details and creates an entry on the (next) page
        try {
            // The caller passes us a parameter (via the query string) indicating the PBE ID they want
            String pbeId = ApexPages.currentPage().getParameters().get('selectedPbeId');
            selectedProductName = 
              [select Name from PricebookEntry where id = :pbeId].name;
                                                
        } catch (Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '' + ex );
            ApexPages.addMessage(msg);
        }
       
        return null;
    }
    
    public PageReference deleteProduct() {
        // deleteProduct() clears the given helper's data
        try {
            // The caller populates selectedHelper with the index of the helper they want to clear
            deletedHelpers.add(helpers[selectedHelper]);
            OLIHelper olih = new OLIHelper();   
            olih.index = selectedHelper;
            olih.pbe = new PricebookEntry();
            olih.oli = new OpportunityLineItem();
            helpers[selectedHelper] = olih;
        } 
        catch (Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '' + ex );
            ApexPages.addMessage(msg);
        }
        return null;    
    }
    
    // The user selected a Product and entered Monthly Quantity and ASP information for it.
    // The selectedPbeId, selectedQuantity, and selectedASP variables
    // describe what the user entered, and the selectedHelper variable tells us the index
    // of the helper we need to update to remember the user's information.
    public PageReference RememberHelperInfo() {
    
        OLIHelper helper = helpers[selectedHelper];
        
        helper.pbe = [select id, Name, Product2.Name from PricebookEntry where id = :selectedPbeId];
        
        if(Decimal.valueOf(selectedQuantity) > 0) {
            if (helper.oli.Id == null) {
                helper.oli.Product_Name__c = helper.pbe.Product2.Name;
                helper.oli.PricebookEntryId = helper.pbe.Id;
            }
            helper.oli.Monthly_Quantity__c = Decimal.valueOf(selectedQuantity);
            helper.oli.UnitPrice = Decimal.valueOf(selectedASP);
        }              
        return null;    
    }
        
    // The user pressed the Cancel button.
    public PageReference Cancel() {
        // Depending on where we started, return to the appropriate (type of) page
        String currParamId = ApexPages.currentPage().getParameters().get('id');
        if(currParamId.startsWith('001') || currParamId.startsWith('006')){
                return new PageReference('/' + currParamId);
        } else {
                return new PageReference('/006');
        }
    }      
                
        // Does the page have any products defined?
    public Boolean hasProducts(){
        for(OLIHelper olih : helpers) {
            OpportunityLineItem oli = olih.oli;
            if (oli.Monthly_Quantity__c <> 0 && oli.Monthly_Quantity__c <> null) {
                return true;
            }
        }              
        return false;
    }
                
    // The user wants to save a new Opportunity and its associated OpportunityLineItems
    public PageReference Save() {
            
        if  (!hasProducts()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity cannot be saved until Products have been added');
            ApexPages.addMessage(msg);
            return null;
        } 
        
        if (opportunity.Design_Start_Date__c > opportunity.Design_EOL_Date__c) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Production Start Date must be before Production End Date');
            ApexPages.addMessage(msg);
            return null;
        }
                                                                        
        if (opportunity.StageName == 'Closed/Lost' && opportunity.Closed_Lost_Comments__c == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Closed Lost Comments are required when Stage = \'Closed/Lost\'');
            ApexPages.addMessage(msg);
            return null;
        }
                                                        
        if (namedAccountName != null && namedAccountName != '' && (productLines == null || productLines.size()==0)) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one Notebook Product Line');
            ApexPages.addMessage(msg);
            return null;
        }

        // If we create the Opportunity, but creating the OpportunityLineItem(s) fails, we
        // need to roll back to this point in a controlled manner.
        System.Savepoint sp = Database.setSavepoint();        
        
        try {
            
            if (namedAccountName == null) {
                opportunity.Notebook_Product_Line__c = null;
            }
            else {
                opportunity.Notebook_Product_Line__c = Utils.join(productLines, ';');
            }
            
            // Per Margaret, resetting Start and End dates to the 15th of their respective months
            opportunity.Design_Start_Date__c = (opportunity.Design_Start_Date__c).toStartOfMonth() + 14;
            opportunity.Design_EOL_Date__c = (opportunity.Design_EOL_Date__c).toStartOfMonth() + 14;
                    
            Utils.GetAllRecordTypeIdsByName();                    
            opportunity.RecordTypeId = Utils.mapRecordTypeIDsByName.get('Opportunity / Notebook Opportunity');
            
            upsert opportunity;
                
            //create a string to hold products to be added to opportunity record
            String strProducts = '';
                
            // If the user wanted to delete any OLIs, delete them
            if (deletedHelpers.size() > 0) {
                    List<OpportunityLineItem> lstOLIsToDelete = new List<OpportunityLineItem>();
                    for (OLIHelper olih : deletedHelpers) {
                            if(olih.oli.id != null) lstOLIsToDelete.add(olih.oli);
                    }
                    delete lstOLIsToDelete;
            }

            // Calculate the number of months for which Schedule Entries will have to be created
            Integer iMonth = opportunity.Design_Start_Date__c.month();
            Integer iYear = opportunity.Design_Start_Date__c.year();
            Integer iCount = 0;
            Date scheduleDate = Date.NewInstance(iYear, iMonth, 15);
            Integer scheduleMonths = scheduleDate.monthsBetween(opportunity.Design_EOL_Date__c);
            scheduleMonths++;
                                                                        
            //For each helper, if its OLI refers to a product, make sure the OLI refers 
            // to the current Opportunity and add it to the list of OLIs to create
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
            for(OLIHelper olih : helpers){
                if(olih.oli.Monthly_Quantity__c <> null && olih.oli.PricebookEntryId <> null) {
                    if (olih.oli.OpportunityId==null) olih.oli.OpportunityId = opportunity.Id;
                    olih.oli.Quantity = olih.oli.Monthly_Quantity__c * scheduleMonths;
                    lstOLIs.add(olih.oli);
                }
                
                // capture all products to add to opportunity record
                if (olih.pbe.Product2.Name <> null) {
                    if (strProducts == '') {
                        strProducts = olih.pbe.Product2.Name;
                    }
                    else{
                        strProducts += ' / ' + olih.pbe.Product2.Name;
                    }
                }
            }
            

                    
            if (lstOLIs.size() > 0) {
                upsert lstOLIs;
            } else {
                Database.rollback(sp);
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Products must be created in order to save this Opportunity');
                ApexPages.addMessage(msg);
                return null;
            }
            
            // add products to opportunity record
            opportunity.Opportunity_Line_Item_Products__c = strProducts;
            upsert opportunity;                                                    
        }
        catch (Exception ex) {                
            // If an error occurs, such as a Validation Rule failure, return an empty PageReference
            // and let PageMessages indicate the issue for the user
            Database.rollback(sp);
            
            String errMsg = ex.getMessage();
            if (errMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                errMsg = errMsg.substring(errMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+'FIELD_CUSTOM_VALIDATION_EXCEPTION'.length()+2); 
            }
            
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
            ApexPages.addMessage(msg);
            return null;    
        }      
        
        // Take the user to the detail page for the Opportunity we just created
        return new PageReference('/' + opportunity.id);
    }
*/    
}