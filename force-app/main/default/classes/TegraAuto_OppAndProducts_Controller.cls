/*
** Class:  TegraAuto_OppAndProducts_Controller
** Created by OpFocus on 03/0/2011
** Description: Controller for the TegraAuto_OppAndProducts page
* @Manideep - 5/8/2019 - This is a old Controller Class used by the Record Types 'Tegra Auto and Emb Opportunity', 'Tegra Auto OEM Opportunity', 'Tegra Auto Tier 1 Opportunity' and 'Tegra Embedded Opportunity'. All these
                          RecordTypes are Retired. So commented out this class as part of Opportunity RecordType Cleanup.
*/    
public class TegraAuto_OppAndProducts_Controller {

  // Dummy method for code coverage
  // This method is coverred by the class 'UnitTests_DummyCodeCoverage_DEL_Classes.cls'
  public static void fakeMethod(){
    Integer i = 0;
    i++;
  }

/*
 * @Manideep - Opportunity RecordType Cleanup 
 
    // All Pricebooks for this Opp must start with this:
    public static final String PRICEBOOK_NAME = 'Tegra Auto/EMB Price Book%';

    // The Opportunity being created/edited
    public  Opportunity     opp           {get; private set;}
    public  RecordType      rt            {get; private set;}
   
    private List<OpportunityLineItem> lstOppsOLIs;
    //private List<Comments__c> lstComments;
        
    // List of OLIHelpers, one per Product displayed in the "Tegra Auto Products" section of the page
    public  List<OLIHelper> lstOLIHelpers {get; private set;}
    
    // Ordered list of quarters for which we have Schedule Entry Helpers
    public  List<String>    lstQuarters   {get; set;} 

    // Value of the "id" querystring parameter
    private String          paramId; 

    // Tegra Auto Product Schedules start many quarters in the future. This indicates the starting quarter.
    public  String          startingQuarter {get; set;}
    
    //Copy next step before saving into last step
    public String strStatusLastStep;
    
    //Copy blocking issues into strPreviousBlockingIssues variable
    public String strPreviousBlockingIssues;

    //Copy description into strPreviousDescription variable
    public String strPreviousDescription;

    //Copy competition into strPreviousCompetition variable
    public String strPreviousCompetition ;
    
    //Copy Reason for Closed Lost/Other into strPreviousReason variable
    public String strPreviousReason ;
    
    
    //Copy Reason for Closed Lost/Other Comments into strPreviousClosedLostOtherComments variable
    public String strPreviousClosedLostOtherComments;
    
    //Copy Reason for Closed Lost/Other into strPreviousReasonForApproval variable
    public String strPreviousReasonForApproval ;
    
    //Copy Reason for Closed Lost/Other into strPreviousConditionsOfApproval variable
    public String strPreviousConditionsOfApproval ;
    
    //Copy amount into strPreviousAmount variable
    public Decimal iPreviousAmount;
    
    public Boolean          pageError      {get; private set;}

    // A cache of PBE Lists, indexed by Product Family
    private Map<String, List<PricebookEntry>> mapPBEsByFamily = new Map<String, List<PricebookEntry>>();

    private String todaysQuarter = Utils.getFiscalQuarterForDate(Date.today());
    
    
    // Start adding by sushma
        public boolean TegraTier{
            get{                
                boolean val  = ([select Id,DeveloperName from RecordType where Id=:ApexPages.CurrentPage().getParameters().get('RecordType')].DeveloperName=='Tier_1_Tegra_Auto_Opportunity') ? true : false;
                return val;
            }
            /////////
            get{
                string recordTypeName = [select Id,DeveloperName from RecordType where Id=:ApexPages.CurrentPage().getParameters().get('RecordType')].DeveloperName;
                if(recordTypeName == 'Tegra_Auto_Tier1_Opportuniity'){
                    return true;
                }else {return false;}                  
            }/////////
            
        }
    // End
    
    // Initializes the page
    public PageReference InitPage() {
        
        pageError = false;
        
        // Get the Id of the Account for which we should create the Opp, if given
        String paramAcctId = ApexPages.currentPage().getParameters().get('accid');
        if (paramAcctId == 'null') paramAcctId = null;
                
        // Get the "id" querystring parameter.
        paramId = ApexPages.currentPage().getParameters().get('id');
        if (paramId != null && paramId.startsWith('006')) {
            // We've got a good Opp id
        }
        else {
            paramId = null;
        }
        
        // Get the "RecordType" querystring parameter. 
        // If given, it must be the Id for Tegra Auto Sales Opportunity Record Type.
        String paramRTId = ApexPages.currentPage().getParameters().get('RecordType');
        if (paramRTId == null) paramRTId = Utils.getRecordTypeId('Opportunity / Tegra Auto and Emb Opportunity');
        
        if (paramId == null) {
            // We're creating a new Opportunity
            opp = new Opportunity();
            opp.OwnerId = UserInfo.getUserId();
            opp.RecordTypeId = (Id)paramRTId;
            opp.Product_Line__c = 'Other';
            System.debug('===== Record Type=' + opp.RecordTypeId);
            
            lstOppsOLIs = new List<OpportunityLineItem>();
            //lstComments = new List<comments__c>();
            
            if(opp.RecordTypeId!=null) {
                rt = new RecordType();   
                rt = [select Name from RecordType where Id = : opp.RecordTypeId]; 
                    
                //opp.RecordType.Name = rt.Name; 
                System.debug('===== Record Type Name = ' + rt.Name);
            }
            /////else {
                opp.RecordType.Name = ''; 
            }/////
         
            opp.Pricebook2Id = 
              [select id 
               from   Pricebook2 
               where  name like :PRICEBOOK_NAME 
               and    IsActive=true 
               order by CreatedDate desc 
               limit 1].id;
            
            // Ideally, we'd initialize the list of OLIHelpers here. However, we first
            // need to get the user to select a Start Quarter for the OLIHelpers.
            // So we'll wait to init the OLIHelpers until the user selects a starting quarter.
            startingQuarter = null;
            lstOLIHelpers = new List<OLIHelper>();
            lstOLIHelpers.add(new OLIHelper(this, null, null, null));
            lstQuarters = new List<String>();
        }
        else {
            // We're editing an existing Opportunity
            try {
                ///////////opp = 
                  [select id, Name, AccountId, OwnerId, Pricebook2Id,
                          Migrated_From_Old_Design__c,
                          At_Risk_Indicator__c, At_Risk_Level__c, Blocking_Issues__c, 
                          CloseDate, Closed_Lost_Comments__c, Competition__c, Country__c, 
                          Code_Name_Auto__c, Distributor__c, 
                          Description, GEO_Area__c, Industry__c, LeadSource, 
                          Prefered_Partner__c, Additional_Partners__c, 
                          Product_Line__c, Project_Stage__c,
                          Type, 
                          Lifetime_Quarters__c, Linked_Opportunities__c, ODM__c, Operating_System_Type__c, 
                          System_Integrator__c, Tegra_Product__c, Tegra_Total_Lifetime_Revenue__c, Type_of_Device__c, 
                          Reason_for_Close__c, Sales_Lead__c, 
                          StageName, Status_Last_Step__c, Status_Next_Step__c, Probability,
                          (select id, Product_Name__c, ASP__c, Quantity,
                                  PricebookEntryId, PricebookEntry.Pricebook2Id, PricebookEntry.Product2Id, PricebookEntry.Product2.Family
                           from   OpportunityLineItems 
                           order by Product_Name__c)
                   from   Opportunity
                   where  id = :paramId];//////////////
                   opp = 
                  [select id, Name, AccountId, OwnerId, Pricebook2Id,
                          Migrated_From_Old_Design__c,RecordTypeId,
                          At_Risk_Indicator__c, At_Risk_Level__c, Blocking_Issues__c, 
                          CloseDate, Closed_Lost_Comments__c, Competition__c,Conditions_of_Approval__c, Description_Competition__c,
                          Code_Name_Auto__c, Distributor__c, 
                          Description, Industry__c, LeadSource, 
                          Prefered_Partner__c, Additional_Partners__c, Type_of_Device__c,
                          Product_Line__c, Project_Stage__c,
                          Type, 
                          Linked_Opportunities__c, ODM__c, Operating_System_Type__c, Operating_System__c,
                          System_Integrator__c, Tegra_Product__c,  
                          Reason_for_Close__c, Sales_Lead__c, 
                          StageName, Status_Last_Step__c, Status_Next_Step__c, Probability_of_Winning__c, Amount, Previous_At_Risk_Level__c,Prospective_Tier_1s__c,Support_Status__c,
                          Prospective_OEM_Project_Name_s__c, Link_to_OEM_Project_Record_2__c, Link_to_OEM_Project_Record_3__c,Link_to_OEM_Project_Record_4__c, Link_to_OEM_Project_Record_5__c,
                          FAE_SA_Support_Name__c,SOP__c, Opportunity_Line_Item_Products__c,Opportunity_Type__c,Operating_System_Comments__c,Sales_Approval_Request__c,
                          Sales_Approval_Request_Date__c,Sales_Management_Approval__c, Reason_for_Approval__c,Sales_Approval_Date__c, 
                          General_SharePoint_Folder_URL__c, CRD_SharePoint_URL__c, Proposal_SharePoint_URL__c, Additional_Info__c,Lifetime_Volume__c, Requested_Probability__c, POC_Auto__c,Standard_Platform_Auto__c,
                          (select id, Product_Name__c, ASP__c, Quantity,
                                  PricebookEntryId, PricebookEntry.Pricebook2Id, PricebookEntry.Product2Id, PricebookEntry.Product2.Family
                           from   OpportunityLineItems 
                           order by Product_Name__c),
                           (select id, Name, CreatedBy.Name, LastModifiedBy.Name, CreatedDate, LastModifiedDate, Comments__c, Date__c
                           from   Comments__r 
                           order by Date__c desc)
                   from   Opportunity
                   where  id = :paramId];
                   
                   if(opp.RecordTypeId!=null) {   
                        rt = new RecordType();
                        rt = [select Name from RecordType where Id = : opp.RecordTypeId]; 
                    
                        //opp.RecordType.Name = rt.Name; 
                        System.debug('===== Record Type Name = ' + rt.Name);
                    }
                    //////else {
                        opp.RecordType.Name = ''; 
                    }//////
                    // Blank out next step
                     //opp.Status_Last_Step__c = opp.Status_Next_Step__c;
                     //opp.Status_Next_Step__c = '';
            }
            catch (Exception ex) {
                pageError = true;
                String str = 'Opportunity ' + paramId + ' does not exist.';
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                ApexPages.addMessage(msg);                  
                return null;
            } 
            
            
            
            //copy status next step into last step
            strStatusLastStep = opp.Status_Next_Step__c;
            
            //copy blocking issues into strPreviousBlockingIssues variable
            strPreviousBlockingIssues = opp.Blocking_Issues__c;
            
            //copy description into strPreviousDescription variable
            strPreviousDescription = opp.Description;
            
            //copy competition into strPreviousCompetition variable
            strPreviousCompetition = opp.Competition__c;
            
            //copy Reason for Closed Lost/Otherinto strPreviousReason variable
            strPreviousReason = opp.Reason_for_Close__c;            
            
            //copy Closed Lost/Other Comments into strPreviousClosedLostOtherComments variable
            strPreviousClosedLostOtherComments = opp.Closed_Lost_Comments__c;
            
            //copy amount into iPreviuosAmount variable
            iPreviousAmount = opp.Amount;
                        
            //copy Reason for Approval into strPreviuosReasonForApproval variable
            strPreviousReasonForApproval  = opp.Reason_for_Approval__c;
            
            //copy Reason for Conditions of Approval / Feedback into strPreviousConditionsOfApproval variable
            strPreviousConditionsOfApproval = opp.Conditions_of_Approval__c;            
          
            
            lstOppsOLIs = opp.OpportunityLineItems;
            //lstComments = opp.Comments__r;

            // If the Opportunity isn't closed, see if there's a more recent Pricebook
            // we should be using
            if (opp.StageName.contains('Closed') == false) {
                Id newPricebookId = 
                  [select id 
                   from   Pricebook2 
                   where  name like :PRICEBOOK_NAME 
                   and    IsActive=true 
                   order by CreatedDate desc 
                   limit 1].id;
                if (opp.Pricebook2Id != newPricebookId) {
                    // The Pricebook has changed, but the OLIs we just fetched still refer to
                    // PriceboookEntries (PBEs) from the old Pricebook. Find the corresponding 
                    // PBEs in the new Pricebook, and switch the OLIs to use them instead.
                    Set<Id> setOliProductIds = new Set<Id>();
                    for (OpportunityLineItem oli : lstOppsOLIs)
                        setOliProductIds.add(oli.PricebookEntry.Product2Id);
                    List<PricebookEntry> lstNewPBEs =
                      [select id, Name, Product2Id, Pricebook2Id, Product2.Family, UnitPrice, IsActive
                       from   PricebookEntry
                       where  Pricebook2Id = :newPricebookId
                       and    Product2Id in :setOliProductIds];
                    
                    List<Integer> lstOliIndexesToRemove = new List<Integer>();
                    for (Integer i=0; i<lstOppsOLIs.size(); i++) {
                        OpportunityLineItem oli = lstOppsOLIs[i];
                        // Find the PBE in the new Pricebook that corresponds to this OLI's
                        // PBE in the old Pricebook
                        for (PricebookEntry pbeNew : lstNewPBEs) {
                            if (pbeNew.Product2Id == oli.PricebookEntry.Product2Id) {
                                if (pbeNew.IsActive) {
                                    oli.PricebookEntry = pbeNew;
                                    oli.ASP__c = pbeNew.UnitPrice;
                                    break;
                                }
                                else {
                                    // The PBE is not active in the new pricebook.
                                    // When we're done iterating over the OLI list,
                                    // remove it from the OLI list
                                    String str = 'Product ' + pbeNew.Name + ' is no longer available, and is being removed from this Opportunity.';
                                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, str);
                                    ApexPages.addMessage(msg);                  
                                    lstOliIndexesToRemove.add(i);
                                }
                            }
                        } 
                    }
                    
                    // If we need to remove any OLIs from the list, do so.
                    for (Integer i=0; i<lstOliIndexesToRemove.size(); i++) {
                        lstOppsOLIs.remove(lstOliIndexesToRemove[i]);
                    }
                        
                    // Remember that we're using the new Pricebook now
                    opp.Pricebook2Id = newPricebookId;

                }
            }
            
            List<Schedule_Entry__c> lstSEs =
              [select  id, OLI_Id__c,Opportunity_Type__c, Product_Name__c, 
                       Display_Quarter__c, Display_Quarter_Sortable__c, Quantity__c,
                       ASP__c
               from    Schedule_Entry__c
               where   Opportunity__c = :paramId
               order by Display_Quarter_Sortable__c];
            
            // Create OLIHelpers for each OLI. 
            // For each OLIHelper, create a list of ScheduleEntryHelpers.
            // While we're at it, built a list of Fiscal Quarters for their Schedule Entries
            lstQuarters = new List<String>();
            lstOLIHelpers = new List<OLIHelper>();
            for (OpportunityLineItem oli : lstOppsOLIs) {
                // Constructor takes: controller, Family, pbeId, oliId
                OLIHelper olih = new OLIHelper(this, oli.PricebookEntry.Product2.Family, oli.PricebookEntry.Id, oli.id);
                lstOLIHelpers.add(olih);    
                
                for (Schedule_Entry__c se : lstSEs) {
                    if (se.OLI_Id__c == oli.id) {
                        if (Utils.listContainsString(lstQuarters, se.Display_Quarter__c) == false) lstQuarters.add(se.Display_Quarter__c);
                        ScheduleEntryHelper seh = new ScheduleEntryHelper(this, olih, se.Display_Quarter__c);
                        seh.units = se.Quantity__c.intValue();
                        //seh.asp   = se.ASP__c.intValue();
                        seh.asp   = se.ASP__c;
                        olih.lstSEHs.add(seh);
                    }
                }
            }

            // If there are no quarters defined yet, define one for the current quarter
            if (lstQuarters.size() == 0) {
                // Ideally, we'd initialize the list of OLIHelpers here. However, we first
                // need to get the user to select a Start Quarter for the OLIHelpers.
                // So we'll wait to init the OLIHelpers until the user selects a starting quarter.
                startingQuarter = null;
                lstOLIHelpers = new List<OLIHelper>();
                lstOLIHelpers.add(new OLIHelper(this, null, null, null));
                lstQuarters = new List<String>();
            }
            else {
                startingQuarter = lstQuarters[0];
            }
            
            // When we saved Schedule Entries, if an SE had units=0, we didn't save
            // a record for it. That means we could have some OLI Helpers that have 
            // Lists of ScheduleEntryHelpers that don't include some quarters.
            // Run through each OLI's List of Schedule Entry Helpers to close any
            // such gaps.
            for (OLIHelper olih : lstOLIHelpers) {
                for (String quarter : lstQuarters) {
                    // See if the list of Schedule Entry Helpers contains this quarter
                    Boolean found = false;
                    for (ScheduleEntryHelper seh : olih.lstSEHs) {
                        if (seh.quarter == quarter) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        ScheduleEntryHelper seh = new ScheduleEntryHelper(this, olih, quarter);
                        olih.lstSEHs.add(seh);
                    }
                }
            }
            

        }
        return null;
    }
    
    
    // The user wants to save the Opp
    public PageReference save() {
        
        // Tegra Auto requires at least 1 product to be selected
        if (lstOLIHelpers.size() == 0) {
            String str = 'Error:  You must select a Product and enter Units and ASP before saving.';
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
            ApexPages.addMessage(msg);                  
            return null;
        }
        else {
            Boolean blnFoundAProduct = false;
            Boolean blnFoundNonZeroPrice = false;
            Boolean blnFoundNonZeroUnits = false;
            for (OLIHelper olih : lstOLIHelpers) {
                if (olih.pbeId != null)  blnFoundAProduct = true;
                if (olih.totalUnits > 0) blnFoundNonZeroUnits = true;
                if (olih.totalPrice > 0) blnFoundNonZeroPrice = true;
            }
            if (!blnFoundAProduct) {
                String str = 'You must select a Product and enter Units and ASP before saving.';
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                ApexPages.addMessage(msg);                  
                return null;
            }
            System.debug('===== Stage=' + opp.StageName + '  Probability=' + opp.Probability);
            //if (!blnFoundNonZeroUnits && (opp.StageName == 'Prospecting' || opp.Probability <= 10)) {
            if (!blnFoundNonZeroUnits) {
                 String str = 'You must enter Units for a Product before saving.';
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                ApexPages.addMessage(msg);                  
                return null;
            }
            ///////if (!blnFoundNonZeroPrice && (opp.StageName <> 'Prospecting' || opp.Probability > 10)) {
                String str = 'You must enter Units and ASP for a Product before saving.';
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                ApexPages.addMessage(msg);                  
                return null;
            }////////
        }
                
        // Begin a transaction
        String strProgress = '';
        Savepoint sp = Database.setSavepoint();
        
        try {
            // Delete any OLIs for this Opp. Any Schedule Entries for those OLIs will also be deleted.
            if (opp.id != null) delete [select id from OpportunityLineItem where OpportunityId = :opp.id];
            
            // Save the Opp
            if (strStatusLastStep != opp.Status_Next_Step__c && opp.Status_Next_Step__c != '') {
                opp.Status_Last_Step__c = strStatusLastStep;
            }
                      
            strProgress = 'saving the Opportunity';
            upsert opp;
            
            // Create OLIs and save them
            strProgress = 'after saving the Opportunity';
            
            //create comment for changes in Status_Next_Step__c field
            if (opp.Status_Next_Step__c != strStatusLastStep) {
             //if (opp.Status_Next_Step__c != opp.Status_Last_Step__c && opp.Status_Last_Step__c != '') {
                 Comments__c com = New Comments__c();
                 com.Name = 'Status: Last Step'; //commnet type
                 com.Comments__c = strStatusLastStep;
                 //com.Comments__c = opp.Status_Last_Step__c;
                 com.Opportunity__c = opp.Id;
                 insert com;
             }
             
             // Blank out next step
             //opp.Status_Last_Step__c = opp.Status_Next_Step__c;
             //opp.Status_Next_Step__c = '';
             
              //upsert opp;
            
            //create comment for changes in blocking issues field
             if (opp.Blocking_Issues__c != strPreviousBlockingIssues) {
                 Comments__c com = New Comments__c();
                 com.Name = 'Blocking Issues / Help Needed'; //commnet type
                 com.Comments__c = strPreviousBlockingIssues;
                 com.Opportunity__c = opp.Id;
                 insert com;
             }
            
             
              //create comment for changes in description field
             if (opp.Description != strPreviousDescription) {
                 Comments__c com = New Comments__c();
                 com.Name = 'Description'; //commnet type
                 com.Comments__c = strPreviousDescription;
                 com.Opportunity__c = opp.Id;
                 insert com;
             }
             
             //create comment for changes in competition field
             if (opp.Competition__c != strPreviousCompetition) {
                 Comments__c com = New Comments__c();
                 com.Name = 'Competition'; //commnet type
                 com.Comments__c = strPreviousCompetition;
                 com.Opportunity__c = opp.Id;
                 insert com;
             } 
            
             //create comment for changes in Reason for Closed Lost/Other field
             if (opp.Reason_for_Close__c != strPreviousReason) {
                 Comments__c com = New Comments__c();
                 com.Name = 'Reason for Closed Lost/Other'; //commnet type
                 com.Comments__c = strPreviousReason;
                 com.Opportunity__c = opp.Id;
                 insert com;
             }
             
             
             //create comment for changes in Closed Lost/Other Comments field
             if (opp.Closed_Lost_Comments__c != strPreviousClosedLostOtherComments) {
                 Comments__c com = New Comments__c();
                 com.Name = 'Closed Lost/Other Comments'; //commnet type
                 com.Comments__c = strPreviousClosedLostOtherComments;
                 com.Opportunity__c = opp.Id;
                 insert com;
             }

            //create comment for changes in amount field
             if (opp.Amount != iPreviousAmount) {
                 Comments__c com = New Comments__c();
                 com.Name = 'Amount'; //comment type
                 com.Comments__c = iPreviousAmount.format();
                 com.Opportunity__c = opp.Id;
                 insert com;
             }
             
             //create comment for changes in Reason for Approval field
             if (opp.Reason_for_Approval__c != strPreviousReasonForApproval) {
                 Comments__c com = New Comments__c();
                 com.Name = 'Reason for Approval'; //commnnt type
                 com.Comments__c = strPreviousReasonForApproval;
                 com.Opportunity__c = opp.Id;
                 insert com;
             }

             //create comment for changes in Conditions of Approval / Feedback field
           ////////////
             if(opp.Conditions_of_Approval__c != strPreviousConditionsOfApproval) {
                 Comments__c com = New Comments__c();
                 com.Name = 'Conditions of Approval / Feedback'; //commnnt type
                 com.Comments__c = strPreviousConditionsOfApproval;
                 com.Opportunity__c = opp.Id;
                 insert com;
             }             
            /////////////
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
            
            //create a string to hold products to be added to opportunity record
            String strProducts = '';
            
            for (OLIHelper olih : lstOLIHelpers) {
                if (olih.family == null || olih.family == '' || olih.pbeId == null || olih.totalUnits == 0) {
                    if (olih.isDeletable == false) {
                        // The user has set the family or PBE Id to null, or entered 0 for all 
                        // Schedule Entry units, but the OLIH isn't deletable (probably because 
                        // because it has Schedule Entries that go too far into the past), so complain.
                        Database.rollback(sp);
                        String str = 'You cannot delete this Product from this Opportunity';
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                        ApexPages.addMessage(msg);                  
                        return null;
                    }
                    else {
                        // The user has set the family or PBE Id to null, or entered 0 for all 
                        // Schedule Entry units, indicating that he doesnt want to save
                        // this OLI. So don't.
                        continue;
                    }
                }
                
                olih.oli = new OpportunityLineItem();
                olih.oli.OpportunityId    = opp.id;
                olih.oli.Product_Name__c  = olih.productName;
                
                // capture all products to add to opportunity record
                if (strProducts == '') {
                    strProducts = olih.productName;
                }
                else{
                    strProducts += ' / ' + olih.productName;
                }
                
                
                olih.oli.pricebookEntryId = olih.pbeId;
                // olih.oli.ASP__c           = olih.asp;
                olih.oli.Quantity         = olih.totalUnits;
                olih.oli.TotalPrice       = olih.totalPrice; 
                lstOLIs.add(olih.oli);
            }
                        
            strProgress = 'saving the Opportunity Products';
            System.debug('===== about to insert lstOLIs ' + lstOLIs);
            insert lstOLIs; 
            System.debug('===== done inserting lstOLIs ' + lstOLIs);

            // add products to opportunity record
            opp.Opportunity_Line_Item_Products__c = strProducts;
            strProgress = 'saving the Opportunity with products';
            upsert opp;
            
            // Remove empty quarters from the start and end of the list
            
            // Check the start of the list
            for (Integer i=0; i<lstQuarters.size(); i++) {
                if (totalUnitsForQuarter(lstQuarters[i]) == 0) {
                    // There are no units for this quarter. Delete the quarter
                    // and all schedule entries for it
                    deleteQuarter(lstQuarters[i]);
                    lstQuarters[i] = '';
                }
                else {
                    // We've found the first non-empty quarter, so we're
                    // done checking the start of the list
                    break;
                }
            }

            // Check the end of the list
            for (Integer i=lstQuarters.size()-1; i>=0; i--) {
                if (totalUnitsForQuarter(lstQuarters[i]) == 0) {
                    // There are no units for this quarter. Delete the quarter
                    // and all schedule entries for it
                    deleteQuarter(lstQuarters[i]);
                    lstQuarters[i] = '';
                }
                else {
                    // We've found the last non-empty quarter, so we're
                    // done checking the end of the list
                    break;
                }
            }
            for (Integer i=lstQuarters.size()-1; i>=0; i--) {
                if (lstQuarters[i] == '') lstQuarters.remove(i);
            }
            // Create Schedule Entries and save them
            strProgress = 'after saving the Opportunity Products';
            List<Schedule_Entry__c> lstSEs = new List<Schedule_Entry__c>();
            for (OLIHelper olih : lstOLIHelpers) {
                if (olih.family == '' || olih.family == null || olih.pbeId == null || olih.totalUnits == 0) continue;               
                for (ScheduleEntryHelper seh : olih.lstSEHs) {
                    Schedule_Entry__c se = new Schedule_Entry__c();
                    se.Opportunity__c      = opp.id;
                    se.Opportunity_Type__c = 'Tegra Auto/Emb Sales Opportunity';
                    se.OLI_Id__c           = olih.oli.id;
                    se.Product_Name__c     = olih.productName;
                    se.Display_Quarter__c  = seh.quarter;
                    se.Quantity__c         = seh.units;
                    se.ASP__c              = seh.asp;
                    se.Revenue__c          = (seh.revenue==null)?0 : seh.revenue;
                    lstSEs.add(se); 
                }
            }
            
            strProgress = 'saving the Schedule Entries';
            insert lstSEs;
        }
        catch (Exception ex) {          
            // If error, roll back the transaction.
            Database.rollback(sp);

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error ' + strProgress);
            ApexPages.addMessage(msg);

            ApexPages.addMessages(ex);

            return null;    
        }
        
        PageReference pgRef = new PageReference('/' + opp.id);
        return pgRef;
    }
    
    
    // The user clicked Cancel
    public PageReference cancel() {
        if (paramId != null && (paramId.startsWith('001') || paramId.startsWith('006'))) {
            // We were invoked with either an Opportunity Id or an Account Id. Go to the 
            // View page for that record 
            return new PageReference('/' + paramId);
        } 
        else {
            // We were invoked without an Id. Go to the Opportunity list.
            return new PageReference('/006');
        }
    }
    
    
    // The user changed the Opportunity StageName. Set the Probability to the
    // correct value, based on the defaults set up in the OpportunityStage object.
    public transient Map<String, Decimal> mapProbabilitiesByStageName;
    public Boolean disableInput {get; set;}
    public PageReference changeStageName() {
        if (mapProbabilitiesByStageName == null) {
            mapProbabilitiesByStageName = new Map<String, Decimal>();
            for (OpportunityStage oppStage : [select MasterLabel, DefaultProbability from OpportunityStage]) {
                mapProbabilitiesByStageName.put(oppStage.MasterLabel, oppStage.DefaultProbability);
            }
        }
        if (mapProbabilitiesByStageName.containsKey(opp.StageName)) {
            opp.Probability = mapProbabilitiesByStageName.get(opp.StageName);
        }
        
        
        if(opp.StageName == 'Closed Lost' || opp.StageName== 'Closed - Other')  {
            disableInput = true ;
        }
        else {
            disableInput = false ;
        }
        return null;
    } 
    
    
    // The user wants to add a row to the list of Product Helpers
    public PageReference addProduct() {
        // Add a Product Helper
        OLIHelper olih = new OLIHelper(this, null, null, null);
        lstOLIHelpers.add(olih);
        
        // Add a Schedule Entry Helper for each quarter that's defined
        for (String quarter : lstQuarters) olih.addQuarter(quarter);
        return null;
    }
    
    
    // The user wants to delete the OLIH with the given index
    public String deleteProductIndex {get; set;}
    public PageReference deleteProduct() {
        if (deleteProductIndex == null) deleteProductIndex = ApexPages.currentPage().getParameters().get('deleteProductIndex');
        Integer index = Integer.valueOf(deleteProductIndex);
        for (Integer i=0; i<lstOLIHelpers.size(); i++) {
            if (lstOLIHelpers[i].index == index) {
                lstOLIHelpers.remove(i);
                break;
            }
        }
        return null;
    }
    
    
    // The user wants to a quarter to the end of the list of quarters
    public PageReference addNextQuarter() {
        // Add the quarter to the end of the list
        String nextQuarter = Utils.getNextQuarter(lstQuarters[lstQuarters.size()-1]);
        lstQuarters.add(nextQuarter);
        
        // Add ScheduleEntryHelpers to all of the current Products
        for (OLIHelper olih : lstOLIHelpers) olih.addQuarter(nextQuarter);          
        return null;
    }
    

    // The user wants to a quarter to the start of the list of quarters
    public PageReference addPreviousQuarter() {
        // Add the quarter to the start of the list
        String prevQuarter = Utils.getPreviousQuarter(lstQuarters[0]);
        lstQuarters.add(0, prevQuarter);
        
        // Add ScheduleEntryHelpers to all of the current Products
        for (OLIHelper olih : lstOLIHelpers) olih.addQuarter(prevQuarter);          
        return null;
    }
    

    private String profileName = '';
    public Boolean userIsAdmin {
        get {
            if (profileName == '') {
                profileName = [select name from Profile where id = :UserInfo.getProfileId()].name;
            }
            return (profileName == 'System Administrator' || profileName == 'OpFocus Admin');
        }
    }

   

    // Getter method for the list of Families for Products in the 's price book.
    // For performance, we cache the list of product families.
    public List<SelectOption> lstProductFamilies {
        get {
            if (lstProductFamilies == null) {
                // Get a list of all Product Families for this price book, and put it
                // in a cache.
                lstProductFamilies = new List<SelectOption>();
                lstProductFamilies.add(new SelectOption('', '')); // value, label
                List<AggregateResult> lstARs =
                  [select Family
                   from   Product2
                   where id in (select Product2Id from PricebookEntry where Pricebook2Id = :opp.Pricebook2Id)
                   and   IsActive = true
                   group by family
                   order by family];
                for (AggregateResult ar : lstARs) {
                    lstProductFamilies.add(new SelectOption((String)ar.get('Family'), (String)ar.get('Family'))); // value, label
                }
            }
            return lstProductFamilies;
        }
        private set;
    }


    // Returns a list of ScheduleEntryHelpers, sorted by quarter,
    // suitable for display at the bottom of the page
    public List<ScheduleEntryHelper> lstSEHsByQuarter {
        get {
            lstSEHsByQuarter = new List<ScheduleEntryHelper>();
            for (String quarter : lstQuarters) {
                for (OLIHelper olih : lstOLIHelpers) {
                    for (ScheduleEntryHelper seh : olih.lstSEHs) {
                        if (seh.quarter == quarter) {
                            lstSEHsByQuarter.add(seh);
                            break;
                        }
                    }
                }
            }
            return lstSEHsByQuarter;
        }
        private set;
    }
    
     // Returns a list of Comments, sorted by date desc,
    // suitable for display at the bottom of the page
    public List<Comments__c> lstCommentsByDateDesc {
        get {
            lstCommentsByDateDesc = new List<Comments__c>();
            for (Comments__c com : opp.Comments__r) {
                lstCommentsByDateDesc.add(com);
            }
            return lstCommentsByDateDesc ;
        }
        private set;
    }

    private Integer totalUnitsForQuarter(String quarter) {
        Integer total = 0;
        for (OLIHelper olih : lstOLIHelpers) {
            if (olih.family == '' || olih.family == null || olih.pbeId == null || olih.totalUnits == 0) continue;               
            for (ScheduleEntryHelper seh : olih.lstSEHs) {
                if (seh.quarter == quarter) {
                    total += seh.units;
                    break; // get the next OLIHelper
                }
            }
        }
        return total;
    }
    
    private void deleteQuarter(String quarter) {
        for (OLIHelper olih : lstOLIHelpers) {
            if (olih.family == '' || olih.family == null || olih.pbeId == null || olih.totalUnits == 0) continue;
            for (Integer i=0; i<olih.lstSEHs.size(); i++) {
                ScheduleEntryHelper seh = olih.lstSEHs[i];
                if (seh.quarter == quarter) {
                    olih.lstSEHs.remove(i);
                    break;
                }
            }               
        }
        return;
    }


    // The page presents a SELECT list of quarters and lets the user pick the starting
    // quarter. This method returns the list of quarters:
    public List<SelectOption> lstPossibleQuarters {
        get {
            List<SelectOption> lstOptions = new List<SelectOption>();

            // Get the current quarter
            String qtr = Utils.getFiscalQuarterForDate(Date.today());
            lstOptions.add(new SelectOption(qtr, Utils.swapFiscalDateSections(qtr))); // value, label); 
            for (Integer i=0; i<40; i++) {
                qtr = Utils.getNextQuarter(qtr);
                lstOptions.add(new SelectOption(qtr, Utils.swapFiscalDateSections(qtr))); // value, label); 
            }
            return lstOptions;
        }
    }
    
    public PageReference pickStartingQuarter() { 
        // Create a new empty Product Helper
        lstOLIHelpers = new List<OLIHelper>();
        lstOLIHelpers.add(new OLIHelper(this, null, null, null));
            
        // Add the current quarter to the list of quarters, and create a 
        // Schedule Entry Helper for the Product Helper we just created
        lstQuarters = new List<String>();
        lstQuarters.add(startingQuarter);

        for (OLIHelper olih : lstOLIHelpers) olih.addQuarter(startingQuarter);
                    
        return null; 
    }
    
    // Helper classes
    

    // Each OLIHelper is a row in the "Tegra Auto Products" section of the page
    public class OLIHelper {
        public TegraAuto_OppAndProducts_Controller ctl {get; private set;}
        public Integer             index        {get; private set;}
        public Id                  oliId        {get; set;}
        public Id                  pbeId        {get; set;}
        public Integer             defaultUnits {get; set;}
    //  public String              family             -- defined below with custom getter/setter methods
    //  public List<SelectOption>  pbesForFamily      -- defined below with custom getter/setter methods
    //  public Integer             defaultAsp         -- defined below with custom getter/setter methods
        public List<ScheduleEntryHelper>  lstSEHs   {get; set;}
        public OpportunityLineItem oli       {get; set;} // Populated only when the Opp is saved.
        
        public OLIHelper(TegraAuto_OppAndProducts_Controller ctl, String family, Id pbeId, Id oliId) {
            this.ctl     = ctl;
            this.index   = ctl.lstOLIHelpers.size();
            this.family  = 'Tegra Auto/Emb'; // NOTE: Hard-coded to "Tegra Auto/Emb"
            this.lstSEHs = new List<ScheduleEntryHelper>();
            this.pbeId   = pbeId;
            this.oliId   = oliId;
        }
        
        // Add a ScheduleEntryHelper for the given quarter
        public void addQuarter(String quarter) {
            this.lstSEHs.add(new ScheduleEntryHelper(ctl, this, quarter));
        }
        
        // A Product is deletable if it doesn't have any saved Schedule Entries that go 
        // more than 2 quarters into the past.
        public Boolean isDeletable { 
            get {
                // Admins can always delete anything
                if (ctl.userIsAdmin) return true;
                
                if (this.oliId == null) {
                    // This OLI hasn't been saved yet, so it and its Schedule Entries can be deleted
                    return true;
                }
                else {
                    // This OLI has been saved already. If it has any Schedule Entries that go 
                    // more than 2 quarters, into the past, it cannot be deleted. 
                    for (ScheduleEntryHelper seh : lstSEHs) {
                        if (Utils.quarterIsThreeFiscalQuartersBeforeQuarter(seh.quarter, ctl.todaysQuarter)) {
                            return false;
                        }
                    }
                    return true;
                }
            }
        }
        
        // When a new Family is selected, set the pbeId to the first one for this Family
        public String family {
            get {family='Tegra Auto/Emb';return 'Tegra Auto/Emb';} // NOTE: Hard-coded to "Tegra Auto/Emb" 
            set {
                if (family != value) {
                    family = value;
                    
                    if (value == '' || value == null) {
                        // The user hasn't selected a family yet
                        pbeId = null;
                    }
                    else {
                        // Set the pbeId to the first one for this family
                        List<SelectOption> tmp = pbesForFamily;
                        pbeId = ctl.mapPBEsByFamily.get(family)[0].id;
                    }
                }
            }
        }

        // Returns the Select Options for the Products for the selected Family
        public List<SelectOption> pbesForFamily {
            get {
                pbesForFamily = new List<SelectOption>();
                if (family == '' || family == null) {
                    // The user hasn't selected a family yet, so we can't display
                    // any PBEs for that family 
                    return pbesForFamily;
                }
                if (ctl.mapPBEsByFamily.containsKey(family) == false) {
                    List<PricebookEntry> lstPBEs =
                      [select id, Name, UnitPrice
                       from   PricebookEntry
                       where  IsActive = true
                       and    Pricebook2Id = :ctl.opp.Pricebook2Id
                       and    Product2.Family = :this.family
                       order by Product2.Product_Sort_Order__c DESC, NAME];
                    ctl.mapPBEsByFamily.put(family, lstPBEs);
                }
                else {
                    for (PricebookEntry pbe : ctl.mapPBEsByFamily.get(family)) {
                        pbesForFamily.add(new SelectOption(pbe.id, pbe.name)); // value, label
                    }
                }
                return pbesForFamily;
            }
            set;
        }
        
        public String productName {
            get {
                if (family=='' || family==null || pbeId==null) return '';
                for (PricebookEntry pbe : ctl.mapPBEsByFamily.get(family)) {
                    if (pbe.id == this.pbeId) return pbe.Name;
                }
                return '';
            }
        }
        
        // ASP for the selected PBE
        //public Integer defaultAsp {
        public Decimal defaultAsp {
            get {
                // Tegra Auto page allows user to set the ASP, but if no ASP has been
                // set yet, we'll display the value from the Pricebook.
                if (defaultAsp != null) return defaultAsp;
                if (family=='' || family==null || pbeId == null) return null;
                for (PricebookEntry pbe : ctl.mapPBEsByFamily.get(family)) {
                    //if (pbe.id == this.pbeId) return pbe.UnitPrice.intValue();
                     if (pbe.id == this.pbeId) return pbe.UnitPrice;
                }
                return null;
            }
            set;
        }

        // Total of the Units for all this OLI's Schedule Entry Helpers
        public Integer totalUnits {
            get {
                Integer total = 0;
                for (ScheduleEntryHelper seh : this.lstSEHs) total += seh.units;
                return total;
            }
        }
        
        public Decimal totalPrice {
            get {
                Decimal total = 0;
                for (ScheduleEntryHelper seh : this.lstSEHs) total += seh.revenue;
                return total;
            }
        }
    }

    // Describes a row in the "Tegra Auto Product Revenue by Quarter" section of the page,
    // one row for each quarterly entry for a single Product.
    public class ScheduleEntryHelper {
        public TegraAuto_OppAndProducts_Controller ctl {get; private set;}
        public OLIHelper  olih    {get; set;}
        public String     quarter {get; set;}
        public Integer    units   {get; set;}
        public Decimal    asp     {get; set;} // Tegra Auto allows ASP to be set differently for each Schedule Entry
        
        public ScheduleEntryHelper(TegraAuto_OppAndProducts_Controller ctl, OLIHelper olih, String quarter) {
            this.ctl     = ctl;
            this.olih    = olih;
            this.quarter = quarter;

            // If this is the last quarter in the list, and there's a quarter before this one,
            // default the units and ASP to the values from the previous quarter
            if ((ctl.lstQuarters[ctl.lstQuarters.size()-1] == quarter) && (ctl.lstQuarters.size() > 1)) {
            
                // Find the SEH for the previous quarter
                String previousQuarter = ctl.lstQuarters[ctl.lstQuarters.size()-2];
                
                for (ScheduleEntryHelper seh : this.olih.lstSEHs) {
                    if (seh.quarter == previousQuarter) {
                        this.units = seh.units;
                        this.asp = seh.asp;
                        break;
                    }
                }
            }
            // If this is the first quarter in the list, and there's a quarter after this one,
            // default the units and ASP to the values from the previous quarter
            else
            if ((ctl.lstQuarters[0] == quarter) && (ctl.lstQuarters.size() > 1)) {
            
                // Find the SEH for the next quarter
                String nextQuarter = ctl.lstQuarters[1];
                
                for (ScheduleEntryHelper seh : this.olih.lstSEHs) {
                    if (seh.quarter == nextQuarter) {
                        this.units = seh.units;
                        this.asp = seh.asp;
                        break;
                    }
                }
            }

        }
        
        public Decimal revenue {
            get {
                if (asp == null) asp = 0;
                if (units == null) units = 0;
                return asp * units;
            }
        }

        // A SEH editable if its OLIH has been saved and its quarter isn't 
        // more than 2 quarters into the past.
        public Boolean isEditable { 
            get {
                // Admins can always edit anything
                //if (ctl.userIsAdmin) return true;

                //if (olih.oliId == null) return true;
                return true;
                //return (! Utils.quarterIsThreeFiscalQuartersBeforeQuarter(this.quarter, ctl.todaysQuarter)); 
            }
        }
        
        public String quarterSortable {
            get {
                return Utils.swapFiscalDateSections(this.quarter);
            }
        }

    }
*/    
}