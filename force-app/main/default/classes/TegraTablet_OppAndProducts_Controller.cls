/*
** Class:  TegraTablet_OppAndProducts_Controller
** Created by OpFocus on 05/03/2011
** Description: Controller for the TegraTablet_OppAndProducts page
*  @Manideep - 5/8/2019 - This code is not being used, so commented out as part of Opportunity RecordType Cleanup.
*/    
public class TegraTablet_OppAndProducts_Controller {

  // Dummy method for code coverage
  // This method is coverred by the class 'UnitTests_DummyCodeCoverage_DEL_Classes.cls'
  public static void fakeMethod(){
    Integer i = 0;
    i++;
  }

/*
 * @Manideep - Opportunity RecordType Cleanup.
 
    public Account                 account       {get; private set;}
    public Opportunity             opp           {get; set;}
    public Pricebook2              pricebook     {get; set;}
    public List<PricebookEntry>    pbes          {get; set;}
    public Product2                product       {get; set;}
    public List<Schedule_Entry__c> lstSEs        {get; set;}
    
    public String            searchText          {get; set;} // used in search()
    
    public OLIHelper[]       helpers             {get; set;}
    public OLIHelper[]       deletedHelpers      {get; set;}
    public Integer           selectedHelper      {get; set;}
    public Id                pricebookId         {get; set;}
    public Id                selectedPbeId       {get; set;}
    public String            selectedProductName {get; set;}
    public PricebookEntry    selectedProduct     {get; set;}
    public String            selectedQuantity    {get; set;}
    public String            selectedASP         {get; set;}
    
    public static final String rtName = 'Tegra Tablets, SB, SP Opportunity';
    public static final String pbName = 'Tegra Tablets Price Book';

                    
    public TegraTablet_OppAndProducts_Controller() {
        // Gll the Product entries from the (Standard) Pricebook;
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
        String currParamId = ApexPages.currentPage().getParameters().get('id');
        Map<String, Id> mapRTNamesById = Utils.mapRecordTypeIdsByName('Opportunity');
        
        if ((Id)rtId == mapRTNamesById.get(rtName)) {
                                                    
            if(currParamId.startsWith('001')){

                // Creating a new Opp from the Account page
                account = 
                  [Select id, Name
                   From   Account
                   Where  id = :currParamId];
                           
                Date today = Date.today();

                opp = new Opportunity();
                opp.RecordTypeId = rtId;                                
                opp.AccountId = account.Id;
                opp.Name = account.Name + '-' + today.month() + '/' + today.day();

                // Set a default Close Date ~ two months from the current date
                Date closeDate = today.addMonths(2);
                opp.CloseDate = closeDate.toStartOfMonth();
                                
                // Set the default Design/Production Start Date to the 15th of the month, 2 months hence
                opp.Design_Start_Date__c = closeDate.toStartOfMonth() + 14;
                opp.Design_EOL_Date__c = (opp.Design_Start_Date__c).addMonths(1);

                lstSEs = new List<Schedule_Entry__c>();
                pricebook = new Pricebook2(Id=pricebookId);
            } 
                        
            else if (currParamId.startsWith('006')){
                // Edit an existing Opportunity
                opp = 
                  [Select Name, RecordTypeId, CloseDate, Description, Probability, StageName, Type, Pricebook2.Id, AccountId,
                          Closed_Lost_Comments__c, OwnerId,  
                          Design_Start_Date__c, Design_EOL_Date__c,
                          Android_Revision__c,
                          Business_Approval__c, Business_Justification__c,
                          Carrier_Name__c, Competition__c, Conditions_of_Approval__c, Customer_Type__c,
                          Memory_Size__c, Memory_Type_Tegra__c,
                          Modem_Implementation__c, Modem_Technology__c, Modem_Vendor__c,
                          No_Direct_Support__c,
                          ODM__c, ODM_Other__c, Operating_System_Type__c,
                          Panel_Resolution__c, Panel_Size_Other__c, Panel_Size_Tegra__c,
                          Telco__c, Technical_Approval__c, Type_of_Device__c,
                          X3D_Display__c, Opportunity_Rejected__c, SW_Upgrade__c, SW_Revision_for_Update__c, Business_Approval_SW_Upgrade__c, Technical_Approval_SW_Upgrade__c
                   From   Opportunity
                   Where  id = :currParamId];
                                                                                
                account = 
                  [Select id, Name
                   From   Account
                   Where  id = :opp.AccountId];

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
                opp = new Opportunity();
                opp.RecordTypeId = rtId;                                
                                                        
                Date closeDate = Date.today().addMonths(2);
                opp.CloseDate = closeDate.toStartOfMonth();
                //opp.StageName = 'Initial Discussions';
                //opp.Probability = 1;
                                                
                lstSEs = new List<Schedule_Entry__c>();
        
                pricebook = new Pricebook2(Id=pricebookId);
                
                opp.Design_Start_Date__c = closeDate.toStartOfMonth() + 14;
                opp.Design_EOL_Date__c = (opp.Design_Start_Date__c).addMonths(1);
            }
                        
        } else {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Incorrect Opportunity Record Type was provided: ' + rtId);
            ApexPages.addMessage(msg);
        }
    }      


    // The user changed the Opportunity StageName. Set the Probability to the
    // correct value, based on the defaults set up in the OpportunityStage object.
    public transient Map<String, Decimal> mapProbabilitiesByStageName;
    public PageReference changeStageName() {
        if (mapProbabilitiesByStageName == null) {
            mapProbabilitiesByStageName = new Map<String, Decimal>();
            for (OpportunityStage oppStage : [select MasterLabel, DefaultProbability from OpportunityStage]) {
                mapProbabilitiesByStageName.put(oppStage.MasterLabel, oppStage.DefaultProbability);
            }
        }
        if (mapProbabilitiesByStageName.containsKey(opp.StageName))
            opp.Probability = mapProbabilitiesByStageName.get(opp.StageName);
        return null;
    } 
    
    
    public PageReference selectHelper() {
        // Keeping in place in case we add additional Record Types
        System.debug('===== selectedHelper = ' + selectedHelper);
        return null;
    }
        
    public PageReference getAccount(Id oppId) {
        if(account == null) {
            Opportunity tmpOpp = new Opportunity();
            tmpOpp = [Select AccountId from Opportunity where Id = :oppId];
            account = [Select Name from Account where Id = :tmpOpp.AccountId];
        }
        return null;
    }
        
        
    // Search for Pricebook Entries.
    // If searchText has a value, search for PBEs whose name begins with that value.
    public PageReference search() {
        
        // search() takes a Product name snippet and return a list of PricebookEntries with that prefix      
        pricebookId = 
          [select id 
           from   Pricebook2 
           where  Name = :pbName].id;

        try {
            String strFieldNames = 'Id, UnitPrice, Product2.Family, Product2.Description, Product2.ProductCode,' + 
                                   'Product2.Name, Product2.Id, Name';
                        
            String soql = 'select Id, UnitPrice, Product2.Family, Product2.Description, Product2.ProductCode, ' + 
                          '       Product2.Name, Product2.Id, Name' + ' ' +
                          'from   PriceBookEntry ' +
                          'where  Pricebook2.id = :pricebookId ';

            if (searchText <> null && searchText <> '') {
                String newSearchText = searchText + '%';
                soql += ' and Name like :newSearchText';
            }
            
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
    
    // The user selected a Product and entered Quantity and ASP information for it.
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
        
        if (opp.Design_Start_Date__c > opp.Design_EOL_Date__c) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Production Start Date must be before Production End Date');
            ApexPages.addMessage(msg);
            return null;
        }
                                                                        
        if (opp.StageName == 'Closed/Lost' && opp.Closed_Lost_Comments__c == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Closed Lost Comments are required when Stage = \'Closed/Lost\'');
            ApexPages.addMessage(msg);
            return null;
        }
                                                        
        // If we create the Opportunity, but creating the OpportunityLineItem(s) fails, we
        // need to roll back to this point in a controlled manner.
        System.Savepoint sp = Database.setSavepoint();        
        
        try {
            // Per Margaret, resetting Start and End dates to the 15th of their respective months
            opp.Design_Start_Date__c = (opp.Design_Start_Date__c).toStartOfMonth() + 14;
            opp.Design_EOL_Date__c = (opp.Design_EOL_Date__c).toStartOfMonth() + 14;
                    
            Utils.GetAllRecordTypeIdsByName();                    
            opp.RecordTypeId = Utils.mapRecordTypeIDsByName.get('Opportunity / ' + rtName);
            
            upsert opp;
            
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
            Integer iMonth = opp.Design_Start_Date__c.month();
            Integer iYear = opp.Design_Start_Date__c.year();
            Integer iCount = 0;
            Date scheduleDate = Date.NewInstance(iYear, iMonth, 15);
            Integer scheduleMonths = scheduleDate.monthsBetween(opp.Design_EOL_Date__c);
            scheduleMonths++;

            //For each helper, if its OLI refers to a product, make sure the OLI refers 
            // to the current Opportunity and add it to the list of OLIs to create
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
            for(OLIHelper olih : helpers){
                if(olih.oli.Monthly_Quantity__c <> null && olih.oli.PricebookEntryId <> null) {
                    if (olih.oli.OpportunityId==null) olih.oli.OpportunityId = opp.Id;
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
            opp.Opportunity_Line_Item_Products__c = strProducts;
            upsert opp;
                                                                   
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
        return new PageReference('/' + opp.id);
    }



    // Helper class

    public class OLIHelper {
        public Integer index {get; set;}
        public PricebookEntry pbe {get; set;}
        public OpportunityLineItem oli {get; set;}
    }
        
*/
}