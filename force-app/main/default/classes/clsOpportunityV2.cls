/*
  Change List:
  2016.04.01 - PJENA - Changes related to Tesla Product Family visibility.
  
  2016.12.07 - PJENA - Price Override
  
  2017.09.15 - Manideep - Disable Schedule Entry capability for Future Quarters and do not copy over existing Schedule Entries while Cloning Opportunity.
  
  01/18/2018 - @Manideep -  The logic that is using RecordTypes those that are part of Opportunity RecordType Cleanup is commented out.
  
  03/01/2021 - @Manideep - SDS-2928: Removed the code/logic that refers the existing fields reason_for_approval__c, conditions_of_approval__c, migrated_from_old_design__c

*/
public class clsOpportunityV2 {
  
  //Paraemters: Collected from URL
    string paramRTId ; 
    string param ; 
    string paramId;
    string paramAccId;
    Id PRICEBOOK2_ID;
    string IsRecordTypeChange;
    
    public list<OpportunityStage> lstOpportunityStage{get;set;}
    public string strProductPageBlockSectioName {get;set;}
    public string strQuarterPageblockSectionName {get;set;}
    public string strColumnName {get;set;}
    public string strHelpUrl {get;set;}
    public string strGuidelinesUrl {get;set;}
    public string strTrainingDeckUrl {get;set;}
    public string strPageMessage {get;set;}
    public string strOpportunityType{get;set;}
    public string strTegraandTeslaFamily {get;set;}
    private List<OpportunityLineItem> lstOppsOLIs;
    // List of OLIHelpers, one per Product displayed in the "GeForce Products" section of the page
    public  List<OLIHelper> lstOLIHelpers {get; private set;}
    // Ordered list of quarters for which we have Schedule Entry Helpers
    public List<Integer>     lstUnits   {get; set;}
    public List<Integer>     lstIndex   {get; set;}

    public List<String>     lstQuarters   {get; set;} 
    public List<String>     lstTempQuarters   {get; set;} 
    public List<String>     lstNewQuarters   {get; set;}     
    
    private  String        previousStartingQuarter {get; set;}
    public String          startingQuarter {get; set;}
    
    public boolean IsGeoforceOpp {get;set;}
    public boolean IsTegraOpp {get;set;}
    public boolean IsProductFamilyClmnShow {get;set;}
    public boolean bShowAsp {get;set;}
    public boolean bShowRevenue {get;set;}
    
    public datetime dtLayoutModificationDate {get;set;}
    public string strRecordtypeName {get;set;}
    // Value of the "isClone" querystring parameter
    private String paramIsClone;   
    
    // A cache of PBE Lists, indexed by Product Family
    public Map<String, List<PricebookEntry>> mapPBEsByFamily = new Map<String, List<PricebookEntry>>();

    private String todaysQuarter = Utils.getFiscalQuarterForDate(Date.today()); //retunrs current quarter in the format of "Qn-FYyyyy" eg., Q4-FY2017
    private String profileName = '';
    
    // Account object if the opportunity is created from the account
    public Account account {get; private set;}
    
    //Check if the current user's profile is System Administrator
    public Boolean userIsAdmin {
        get {
            if (profileName == '') {
                profileName = [select name from Profile where id = :UserInfo.getProfileId()].name;
            }
            return (profileName == 'System Administrator');
        }
    }
    
   public Boolean pageError {get; private set;}
   
   //FROM Tegra class
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
       
    //From Tesla Class
    public boolean displayPopup {get; set;} 
    
    //For Tergra Tablet SP,SB  
    //public boolean IsTegraSBSPRecordtype {get;set;}
    
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
    
    public string recordTypeId  {get;set;} //pjena: 12/7/2016 - Moved this declaration here from deep within this class
    public string RECORDTYPE_NAME = '';
    public String PRICEBOOK_NAME = ''; 
    Pricebook_Details__c customsetting;
    
    //flag to show Save button based on the required field being filled-in
    public boolean flag {get;set;}
    
    //PJENA-2016.09.12: Price Override
    public boolean bShowASPOverride{get;set;}
    private string strASPOverrideAdminProfiles{get;set;}
  private string strASPOverrideAdminUsers{get;set;}
  public boolean bIsOverrideAdmin{get;set;}
  //End: PJENA-2016.09.12: Price Override
    
    /*
     * @Manideep - Opportunity RecordType Cleanup
    //@Manideep - 2017.09.15: Suspend Schedule Entries while Clone/Edit of Opportunity.
    public boolean suspendScheduleEntriesForCloneBoolean {get; set;}
    public boolean suspendScheduleEntriesForEditBoolean {get; set;}
    public string startingQuarterSectionName {get; set;}
    public string addQuarterButtonName {get; set;}
    */
    
    //Constructor : Initializations
    public clsOpportunityV2(ApexPages.StandardController controller) {
                
        //Collect all the parameters from the url
    paramId = Apexpages.Currentpage().getParameters().get('id');                
        paramRTId = Apexpages.Currentpage().getParameters().get('RecordType');
        param = Apexpages.Currentpage().getParameters().get('param'); //"New" for new oppty, "Edit" for editing oppty, "Clone" in case of Cloning the oppty
        paramAccId = Apexpages.Currentpage().getParameters().get('accid');
        IsRecordTypeChange = Apexpages.Currentpage().getParameters().get('RecordTypeChange'); //"True" in case of record type change otherwise this parameter is not present in the url
        
        /*
         * @Manideep - Opportunity RecordType Cleanup 
        //Collect all RecordTypes applicable for suspention of Schedule Entries.
        set<Id> suspendSchEtryForRTIdSet = new set<Id>();
        for(String strRT: Opportunity_ReEngineering_Constants.RT_Disable_ScheduleEntry_For_Clone.split(';')) {
            suspendSchEtryForRTIdSet.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(strRT).getRecordTypeId());  
        } 
                      
        if(param == 'Clone' && suspendSchEtryForRTIdSet.contains(paramRTId)) {
           suspendScheduleEntriesForCloneBoolean = true;
           suspendScheduleEntriesForEditBoolean = false;
        } else if((param == 'Edit' || param == 'New') && suspendSchEtryForRTIdSet.contains(paramRTId)) {
           suspendScheduleEntriesForCloneBoolean = false;
           suspendScheduleEntriesForEditBoolean = true;
        } else {
           suspendScheduleEntriesForCloneBoolean = false;
           suspendScheduleEntriesForEditBoolean = false;
        }     
        system.debug('suspendScheduleEntriesForCloneBoolean----->'+suspendScheduleEntriesForCloneBoolean); 
        system.debug('suspendScheduleEntriesForEditBoolean----->'+suspendScheduleEntriesForEditBoolean);      
        
        if(!suspendScheduleEntriesForEditBoolean && !suspendScheduleEntriesForCloneBoolean) {
            startingQuarterSectionName = 'Starting Quarter';
            addQuarterButtonName = 'Add Starting Quarter';
        } else {
          startingQuarterSectionName = 'Products';
          addQuarterButtonName = 'Add Products';
        }
        */  
        
        //Oopportunity type flag initialization
        IsGeoforceOpp = false;
        IsTegraOpp = false;
        //IsTegraSBSPRecordtype = false; 
        //Tesla variable used to hide product family column
        IsProductFamilyClmnShow = false;
        
        //pageblocksection & column name variable initialization
        strProductPageBlockSectioName = '';
        strQuarterPageblockSectionName = '';
        strColumnName = '';
        strHelpUrl = '';
        strPageMessage = '';
        strGuidelinesUrl = '';
        strTrainingDeckUrl = '';
        strOpportunityType = '';
        strTegraandTeslaFamily = '';
        lstPageBlockWrapper  = new List<pageblockWrapper>();
        
        //Get all list of stage names & probability
        lstOpportunityStage = new List<OpportunityStage>();
        lstOpportunityStage = [SELECT MasterLabel, DefaultProbability From OpportunityStage];
        
        //Get PriceBook Name, Famil, Product Line from Custom Settings "Opportunity Re Engineering Details"
        if(paramRTId != null){
            recordTypeId = paramRTId;
        }
        RecordType rt = [Select Name From RecordType Where id=:recordTypeId];
        customsetting = Pricebook_Details__c.getValues(rt.Name);
        if(customsetting !=null && customsetting.Pricebook_Name__c != null) PRICEBOOK_NAME = customsetting.Pricebook_Name__c;
        RECORDTYPE_NAME = rt.Name;
        //End: Get PriceBook Name, Famil, Product Line from Custom Settings "Opportunity Re Engineering Details"
        
        // Get the "id" querystring parameter.
        //paramId = ApexPages.currentPage().getParameters().get('id');
        if (paramId != null && (paramId.startsWith('006') || paramId.startsWith('001'))) {
            // We've got a good Opp id or account id
        }   
        else {
            paramId = null;
        }
        
        //Get procebook2id for the associated Record Type of the Opportunity (Custom Settings "Pricebook_Details__c" contains the map of Record Type and Price Book name)
        if(param != null 
            && (param.equalsIgnoreCase('Clone') || param.equalsIgnoreCase('New') || (param.equalsIgnoreCase('Edit'))) 
            && PRICEBOOK_NAME != null && PRICEBOOK_NAME != ''){
      PRICEBOOK2_ID = [  Select id 
                                From Pricebook2 
                                Where name = :PRICEBOOK_NAME 
                                  And IsActive = true 
                                order by CreatedDate desc 
                                limit 1].id;
        }
        
        /*
         * @Manideep - Opportunity RecordType Cleanup
        //For Record Type = "Tegra Tablets, SB, SP Opportunity", "Embedded Entertainment Opportunity": required for popup initialization
        if(System.Label.Tegra_Tablets_SB_SP_Opportunity.contains(RECORDTYPE_NAME)) {
            
            IsTegraSBSPRecordtype = true;
            
            //Get the Price Book Entries related to the Price Book set in PRICEBOOK2_ID;
            search();
            
      //Initialize the helpers. By default it adds 4 rows in the pop-up (main opp v2 vf code, the pop-up is a div so no separate vf for it)
            deletedHelpers = new OLIHelper[]{};
            helpers = new OLIHelper[]{};
            for (integer i = 0; i < 4; i++) {
                OLIHelper olih = new OLIHelper();
                olih.index = i;
                olih.pbe = new PricebookEntry();
                olih.oli = new OpportunityLineItem();
                helpers.add(olih);
            }
        }
        //End: For Record Type = "Tegra Tablets, SB, SP Opportunity", "Embedded Entertainment Opportunity": required for popup initialization
        */
        
        //set the controller vars from Custom Settings
        if(customsetting.Name.equalsIgnoreCase(RECORDTYPE_NAME)) {
            strRecordtypeName = RECORDTYPE_NAME;
            strProductPageBlockSectioName = customsetting.Product_Pageblock_Section_Name__c != null ? customsetting.Product_Pageblock_Section_Name__c : '';
            strQuarterPageblockSectionName = customsetting.Quarter_PageBlock_Section__c != null ? customsetting.Quarter_PageBlock_Section__c : '';
            strColumnName = customsetting.Column_Name__c != null ? customsetting.Column_Name__c : '';
            strHelpUrl = customsetting.Help_Url__c != null ? customsetting.Help_Url__c : '';
            strPageMessage = customsetting.Message_to_Select_Quarter__c != null ? customsetting.Message_to_Select_Quarter__c : '';
            strGuidelinesUrl = customsetting.Guidlines_link__c != null ? customsetting.Guidlines_link__c : '';
            strTrainingDeckUrl = customsetting.Training_Deck_Url__c != null ? customsetting.Training_Deck_Url__c : '';
            strOpportunityType = customsetting.Opportunity_Type__c != null ? customsetting.Opportunity_Type__c : '';
            strTegraandTeslaFamily = customsetting.family__c != null ? customsetting.family__c : '';
            dtLayoutModificationDate = customsetting.Layout_Modified_Date__c;
            bShowAsp = customsetting.ShowASP__c;
            bShowRevenue = customsetting.ShowRevenue__c;
            //PJENA-2016.09.12: Price Override
            bShowASPOverride = customsetting.Show_ASP_Override__c;
            strASPOverrideAdminProfiles = customsetting.ASP_Override_Admin_Profile_s__c != null ? customsetting.ASP_Override_Admin_Profile_s__c : '';
      strASPOverrideAdminUsers = customsetting.ASP_Override_Admin_User_s__c != null ? customsetting.ASP_Override_Admin_User_s__c : '';
      bIsOverrideAdmin = isPriceOverrideAdmin();
      
            //End: PJENA-2016.09.12: Price Override
        }
    //End: //set the controller vars from Custom Settings
    
        //CASE 1: For NEW opportunity created from tab for all record types
        if ((paramId == null && (paramAccId == null || paramAccId == 'null') && param != null && param.equalsIgnoreCase('New')) || (IsRecordTypeChange != null && IsRecordTypeChange == 'true')) {
        
        //@Manideep workaround for above condition
        //if((paramId == null && (paramAccId == null || paramAccId == 'null') && param != null && param.equalsIgnoreCase('New')) || (paramId != null && IsRecordTypeChange != null && IsRecordTypeChange == 'true')) 
        
            if(paramRTId != null && RECORDTYPE_NAME != null && RECORDTYPE_NAME != '')
            {
                
                /*
                 * @Manideep - Opportunity RecordType Cleanup                
                //Added for opportunity recordtype change***4/9/2014
                if(IsRecordTypeChange != null && IsRecordTypeChange == 'true')
                {
                   //Make dynamic query on opportunity
                   Map<String, Schema.SObjectField> schemaOpportunity = Schema.SObjectType.Opportunity.fields.getMap();
                   integer iCount = 1;
                    string SOQL = 'SELECT ';
                    for(string fName : schemaOpportunity.keySet()){
                        if(iCount < schemaOpportunity.keySet().size()){
                            SOQL += fName + ', ';
                            iCount = iCount+1;
                        }
                        else{
                            SOQL += fName;  
                        }
                        
                    }
                    SOQL += ' FROM Opportunity WHERE id =: paramId';
                                        
                    //Make Query
                    Opportunity OppRecordTypeChange = new Opportunity();
                    OppRecordTypeChange = Database.query(SOQL); 
                    
                    if(OppRecordTypeChange != null){
                        opp = new Opportunity(id = paramId);
                        opp = OppRecordTypeChange.clone();
                    }
                    
                    //Code snippet for 'Tegra Auto Tier1 Opportunity' OR 'Tegra Auto OEM Opportunity' OR 'Tegra Embedded Opportunity' have the same functionality
                    if(System.Label.Tegra_auto_and_embedded_opportunity != null &&  System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME))
                    {
                            IsProductFamilyClmnShow = true;
                            IsTegraOpp = true;
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
                            //strPreviousReasonForApproval  = opp.Reason_for_Approval__c;
                            
                            //copy Reason for Conditions of Approval / Feedback into strPreviousConditionsOfApproval variable
                            //strPreviousConditionsOfApproval = opp.Conditions_of_Approval__c;            
                    }
                }
                */                
                
                //CASE 1.1: Code snippet for 'GeForce Sales Opportunity' OR 'Quadro Sales Opportunity' OR 'Quadro Partner Opportunity' OR 'GRID Sales Opportunity' OR 'Quadro Partner Deal' OR 'Tegra Embedded Partner Opportunity' OR 'Automotive Opportunity'
                if(System.Label.GeForce_and_Quadro_Sales_Opportunity != null &&  System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME))
                {
                        IsGeoforceOpp = true;
                        
                        if(IsRecordTypeChange == null) //Added for Opprecordtype change
                           opp = new Opportunity();
                            
                        opp.OwnerId = UserInfo.getUserId();
                        opp.RecordTypeId = (Id)paramRTId;
                        //Get product line from custom setting
                        if(customsetting !=null && customsetting.product_Line__c!=null)
                            opp.product_Line__c = customsetting.product_Line__c;
                        //Priceboo2id
                        if(PRICEBOOK2_ID != null)
                            opp.Pricebook2Id = PRICEBOOK2_ID;
                                
                        lstOppsOLIs = new List<OpportunityLineItem>();
                        
                        // Create a new empty Product Helper
                        lstOLIHelpers = new List<OLIHelper>();
                        lstOLIHelpers.add(new OLIHelper(this, null, null, null));
                    
                        // Add the current quarter to the list of quarters, and create a 
                        // Schedule Entry Helper for the Product Helper we just created
                        lstQuarters = new List<String>();
                }
                                               
                //CASE 1.2: Code snippet for 'Tegra Auto Tier1 Opportunity' OR 'Tegra Auto OEM Opportunity' OR 'Tegra Embedded Opportunity' have the same functionality
                if(System.Label.Tegra_auto_and_embedded_opportunity != null &&  System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME))
                {
                        IsTegraOpp = true;
                        IsProductFamilyClmnShow = true;
                        // We're creating a new Opportunity
                       if(IsRecordTypeChange == null) //Added for Opprecordtype change
                            opp = new Opportunity();
                        
                        opp.OwnerId = UserInfo.getUserId();
                        opp.RecordTypeId = (Id)paramRTId;
                        opp.Product_Line__c = customsetting.product_Line__c;  
                        System.debug('===== Record Type=' + opp.RecordTypeId);
                        
                        lstOppsOLIs = new List<OpportunityLineItem>();
                        //lstComments = new List<comments__c>();
                            
                            //Priceboo2id
                        if(PRICEBOOK2_ID != null)
                            opp.Pricebook2Id = PRICEBOOK2_ID;
                            
                            // Ideally, we'd initialize the list of OLIHelpers here. However, we first
                            // need to get the user to select a Start Quarter for the OLIHelpers.
                            // So we'll wait to init the OLIHelpers until the user selects a starting quarter.
                            startingQuarter = null;
                            lstOLIHelpers = new List<OLIHelper>();
                            lstOLIHelpers.add(new OLIHelper(this, null, null, null));
                            lstQuarters = new List<String>();     
                }
                system.debug('*******IsTegraOpp'+IsTegraOpp);
                
                /*
                 * @Manideep - Opportunity RecordType Cleanup
                //Case 1.3: code for tesla sales opportunity
                if(System.Label.Tesla_Sales_Opportunity != null && System.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME))
                {
                    
                    IsGeoforceOpp = true;
                    
                    --
                    2016.04.01 - PJENA - Changes related to Tesla Product Family visibility.
                    IsProductFamilyClmnShow = true;
                    --
                    
                    // We're creating a new Opportunity
                   if(IsRecordTypeChange == null) //Added for Opprecordtype change
                        opp = new Opportunity();
                        
                    opp.OwnerId = UserInfo.getUserId();
                    opp.RecordTypeId = (Id)paramRTId;   
                    //Get product line from custom setting
                    if(customsetting !=null && customsetting.product_Line__c!=null)
                        opp.product_Line__c = customsetting.product_Line__c;
                    //Priceboo2id
                    if(PRICEBOOK2_ID != null)
                        opp.Pricebook2Id = PRICEBOOK2_ID;
                        
                    lstOppsOLIs = new List<OpportunityLineItem>();
                    
                    // Create a new empty Product Helper
                    // Ideally, we'd initialize the list of OLIHelpers here. However, we first
                    // need to get the user to select a close date for the OLIHelpers.
                    // So we'll wait to init the OLIHelpers until the user selects a starting quarter.
                    startingQuarter = null;
                    lstOLIHelpers = new List<OLIHelper>();
                    lstOLIHelpers.add(new OLIHelper(this, null, null, null));
                    lstQuarters = new List<String>();
                }
                
                //Case 1.4: Code for Tegra Tablets, SB, SP Opportunity OR Embedded Entertainment Opportunity
                if(System.Label.Tegra_Tablets_SB_SP_Opportunity.contains(RECORDTYPE_NAME)){
                    // This was called from the Opportunities tab                                             
                  if(IsRecordTypeChange == null) //Added for Opprecordtype change
                        opp = new Opportunity();
                        
                    opp.RecordTypeId = recordTypeId;                                
                    opp.OwnerId = UserInfo.getUserId();                                        
                    Date closeDate = Date.today().addMonths(2);
                    opp.CloseDate = closeDate.toStartOfMonth();
                    //opp.StageName = 'Initial Discussions';
                    //opp.Probability = 1;
                                                    
                    lstSEs = new List<Schedule_Entry__c>();
            
                    pricebook = new Pricebook2(Id=PRICEBOOK2_ID);
                    
                    opp.Design_Start_Date__c = closeDate.toStartOfMonth() + 14;
                    opp.Design_EOL_Date__c = (opp.Design_Start_Date__c).addMonths(1);
                }
                */                             
            }
        } //End: CASE 1: For NEW opportunity created from tab for all record types
        
        //Case 2: For NEW opportunity created from account page
        else if(paramId == null && paramAccId != null && paramAccId.startsWith('001')){
            account = [SELECT id, Name
                        FROM Account
                        WHERE id = :paramAccId];
            
            //CASE 2.1: Code snippet for GeForce Sales Opportunity and Quadro Sales Opportunity
            //if(paramRTId != null && RECORDTYPE_NAME != null && RECORDTYPE_NAME != '' && ((System.Label.GeForce_and_Quadro_Sales_Opportunity != null &&  System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)) || (system.Label.Tesla_Sales_Opportunity != null && system.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME))|| (system.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME))))
            if(paramRTId != null && RECORDTYPE_NAME != null && RECORDTYPE_NAME != '' && ((System.Label.GeForce_and_Quadro_Sales_Opportunity != null && System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)) || (system.Label.Tesla_Sales_Opportunity != null)))
            {
                if(system.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME))
                {
                    IsTegraOpp = true;
                    IsProductFamilyClmnShow = true;
                }
                //else if((System.Label.GeForce_and_Quadro_Sales_Opportunity != null && System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)) || (system.Label.Tesla_Sales_Opportunity != null && system.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME)))
                else if(System.Label.GeForce_and_Quadro_Sales_Opportunity != null && System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME))
                {
                    IsGeoforceOpp = true;
                }
                                
                Date today = Date.today();
                opp = new Opportunity();
                
                opp.AccountId = account.Id;
                opp.OwnerId = UserInfo.getUserId();
                opp.RecordTypeId = (Id)paramRTId;
                if(customsetting !=null && customsetting.product_Line__c!=null)
                    opp.product_Line__c = customsetting.product_Line__c;

                lstOppsOLIs = new List<OpportunityLineItem>();
                
                //Priceboo2id
                if(PRICEBOOK2_ID != null)
                    opp.Pricebook2Id = PRICEBOOK2_ID;
                
                /*
                 * @Manideep - Opportunity RecordType Cleanup
                //Only for tesla opportunity                    
                if(system.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME))
                    startingQuarter = null;
                */
                                
                // Create a new empty Product Helper
                lstOLIHelpers = new List<OLIHelper>();
                lstOLIHelpers.add(new OLIHelper(this, null, null, null));
                // Add the current quarter to the list of quarters, and create a 
                // Schedule Entry Helper for the Product Helper we just created
                lstQuarters = new List<String>();
                
                //Only for Geoforce and Quadro sales opportunity
                if(System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)){
                    lstQuarters.add(Utils.getFiscalQuarterForDate(Date.today()));
                    for (OLIHelper olih : lstOLIHelpers) olih.addQuarter(Utils.getFiscalQuarterForDate(Date.today())); 
                }         
            } 
            
            /*
             * @Manideep - Opportunity RecordType Cleanup
            //Case 2.2:code for Tegra Tablets, SB, SP Opportunity
            if(System.Label.Tegra_Tablets_SB_SP_Opportunity.contains(RECORDTYPE_NAME)){
                Date today = Date.today();
                
                opp = new Opportunity();
                opp.RecordTypeId = recordTypeId;                                
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
            */ 
            
        } //End: Case 2: For NEW opportunity created from account page
        
        //CASE 3: For EDIT or Clone opportunity
        else{
            
            if(param != null && (param.equalsIgnoreCase('Edit') || param.equalsIgnoreCase('Clone')) && RECORDTYPE_NAME != null && RECORDTYPE_NAME != '')
            {
                // We're editing an existing Opportunity
                try {
                           
                           //Make dynamic query on opportunity
                           Map<String, Schema.SObjectField> schemaOpportunity = Schema.SObjectType.Opportunity.fields.getMap();
                           //set<string> setFieldName = new set<string>();
                            string SOQL = 'SELECT ';
                            for(string fName : schemaOpportunity.keySet()){
                                SOQL += fName + ', ';
                            }
                                    
                            Map<String, Schema.SObjectField> schemaOLI = Schema.SObjectType.OpportunityLineItem.fields.getMap();
                             SOQL += '(SELECT ';
                            for(string fName : schemaOLI.keySet()){
                                    SOQL += fName + ', ';
                            }
                            SOQL += ' PricebookEntry.Pricebook2Id, PricebookEntry.Product2Id, PricebookEntry.Product2.Family';
                            SOQL += ' FROM OpportunityLineItems order by Product_Name__c),';
                            
                            Map<String, Schema.SObjectField> schemaComments = Schema.SObjectType.Comments__c.fields.getMap();
                            SOQL += '(SELECT ';
                            integer iCount = 1;
                            for(string fName : schemaComments.keySet()){
                                if(iCount < schemaComments.keySet().size()){
                                    SOQL += fName + ', ';
                                    iCount = iCount + 1;
                                    
                                    //setFieldName.add(fName);
                                }
                                else{
                                    SOQL += fName +' ';
                                    
                                    //setFieldName.add(fName);
                                }
                            }
                            
                            SOQL += ',LastModifiedBy.Name';
                            SOQL += ' FROM Comments__r order by Date__c desc)';
                            SOQL += ' FROM Opportunity WHERE id =: paramId';
                            system.debug('*****'+ SOQL);
                            
                            //Make Query
                            opp = Database.query(SOQL);
                            opp.RecordtypeId = paramRTId;
                            
                            //For Clone of geforce or quadro recordtype name should blank
                            //if((System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME) || System.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME) || System.Label.Tegra_Tablets_SB_SP_Opportunity.contains(RECORDTYPE_NAME) || System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)) && param.equalsIgnoreCase('Clone'))
                            if((System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME) || System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)) && param.equalsIgnoreCase('Clone'))
                            {
                                opp.Name = ''; 
                            }
                            
                            /*
                             * @Manideep - Opportunity RecordType Cleanup
                            //@Manideep - Set the Opportunity CloseDate to null while cloning existing opportunity, so that Schedule Entries will not be copied over.
                            if(suspendScheduleEntriesForCloneBoolean)  
                               opp.CloseDate = null; 
                            */  
                            
                            /*
                             * @Manideep - Opportunity RecordType Cleanup
                            //For Tegra SB SP recordtype
                            if(system.Label.Tegra_Tablets_SB_SP_Opportunity.contains(RECORDTYPE_NAME))
                            {
                                
                                List<OpportunityLineItem> olis = [Select OpportunityId, PricebookEntryId, Quantity, Monthly_Quantity__c, TotalPrice, UnitPrice, Product_Name__c,
                                                                          PricebookEntry.Name, PricebookEntry.Id, PricebookEntry.UnitPrice, 
                                                                          PricebookEntry.Product2.Family, PricebookEntry.Product2.Description,
                                                                          PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Name, PricebookEntry.Product2.Id 
                                                                       From OpportunityLineItem
                                                                       Where  OpportunityId = :paramId];
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
                            */
                    }
                    catch (Exception ex) {
                        pageError = true;
                        String str = 'Opportunity ' + paramId + ' does not exist.';
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                        ApexPages.addMessage(msg);                  
                        return;
                    }

                    //CASE 3.1: Code snippet for GeForce Sales Opportunity and Quadro Sales Opportunity
                    //if((System.Label.GeForce_and_Quadro_Sales_Opportunity != null &&  System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)) || (system.Label.Tesla_Sales_Opportunity != null && system.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME)))
                    if((System.Label.GeForce_and_Quadro_Sales_Opportunity != null && System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)))
                    {
                            IsGeoforceOpp = true;
                            system.debug('*****opp.CloseDate'+opp.CloseDate);
                            startingQuarter = Utils.getFiscalQuarterForDate(opp.CloseDate);
                            //Used to hide productfamilycolumn
                            /*
                            2016.04.01 - PJENA - Changes related to Tesla Product Family visibility.
                            if(system.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME))
                                IsProductFamilyClmnShow = true;
                            */
                    }
                    
                    //CASE 3.2: Code snippet for 'Tegra Auto Tier1 Opportunity' OR 'Tegra Auto OEM Opportunity' OR 'Tegra Embedded Opportunity' have the same functionality
                    if(System.Label.Tegra_auto_and_embedded_opportunity != null &&  System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME))
                    {          
                            IsProductFamilyClmnShow = true;
                            IsTegraOpp = true;
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
                            //strPreviousReasonForApproval  = opp.Reason_for_Approval__c;
                            
                            //copy Reason for Conditions of Approval / Feedback into strPreviousConditionsOfApproval variable
                            //strPreviousConditionsOfApproval = opp.Conditions_of_Approval__c;                 
                            
                    }
                    
                   //if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME) || System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME) || system.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME))
                   if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME) || System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME))
                   {
                                                                                             
                                        lstOppsOLIs = opp.OpportunityLineItems;
                                        
                                        /*
                                         * @Manideep - Opportunity RecordType Cleanup
                                        // Clear the existing Opportunitylineitems list while Cloning Opportunity, so that Schedule Entries will not get copied over.
                                        system.debug('lstOppsOLIs before Clear()------>'+lstOppsOLIs);
                                        if(suspendScheduleEntriesForCloneBoolean) {
                                           lstOppsOLIs.clear();   
                                        }
                                        system.debug('lstOppsOLIs after Clear()------->'+lstOppsOLIs);
                                        */
                                         
                                        // If the Opportunity isn't closed, see if there's a more recent Pricebook
                                        // we should be using
                                        if (opp.StageName.contains('Closed') == false) {
                                                if (opp.Pricebook2Id != PRICEBOOK2_ID) {
                                                        // The Pricebook has changed, but the OLIs we just fetched still refer to
                                                        // PriceboookEntries (PBEs) from the old Pricebook. Find the corresponding 
                                                        // PBEs in the new Pricebook, and switch the OLIs to use them instead.
                                                        Set<Id> setOliProductIds = new Set<Id>();
                                                        for (OpportunityLineItem oli : lstOppsOLIs)
                                                                setOliProductIds.add(oli.PricebookEntry.Product2Id);
                                                                
                                                       //Dynamic query on pricebook entry                                                                    
                                                       Map<String, Schema.SObjectField> schemaPBE = Schema.SObjectType.PricebookEntry.fields.getMap();
                                                        string SOQL = 'SELECT ';
                                                        integer iCount = 1;
                                                        for(string fName : schemaPBE.keySet()){
                                                            if(iCount < schemaPBE.keyset().size())
                                                            {
                                                                SOQL += fName + ', ';
                                                                iCount = iCount+1;
                                                            }
                                                            else{
                                                                SOQL += fName + ' ';
                                                            }
                                                        }
                                                        SOQL += 'FROM PricebookEntry WHERE Pricebook2Id = :PRICEBOOK2_ID AND Product2Id in :setOliProductIds';
                                                        
                                                        //Make Query on pricebook entry
                                                        List<PricebookEntry> lstNewPBEs = Database.Query(SOQL);
                                                        
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
                                                        opp.Pricebook2Id = PRICEBOOK2_ID;
                                        
                                                }
                                        }
                                        //PJENA-2016.09.12: Price Override : query the new field ASP_Override__c
                                        List<Schedule_Entry__c> lstSEs =[SELECT  id, OLI_Id__c,Opportunity_Type__c, Product_Name__c,
                                                                                    Display_Quarter__c, Display_Quarter_Sortable__c, Quantity__c, ASP__c, ASP_Override__c
                                                                               FROM Schedule_Entry__c
                                                                               WHERE Opportunity__c =: paramId
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
                                                
                                                if(lstSEs != null && lstSEs.size() >0){
                                                        for (Schedule_Entry__c se : lstSEs) {
                                                                if (se.OLI_Id__c == oli.id) {
                                                                        if (Utils.listContainsString(lstQuarters, se.Display_Quarter__c) == false) lstQuarters.add(se.Display_Quarter__c);
                                                                        ScheduleEntryHelper seh = new ScheduleEntryHelper(this, olih, se.Display_Quarter__c);
                                                                        seh.units = se.Quantity__c.intValue();
                                                                        //seh.asp   = se.ASP__c.intValue();
                                                                        if(System.Label.Tegra_auto_and_embedded_opportunity != null &&  System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)){
                                      //PJENA-2016.09.12: Price Override
                                                                          seh.aspoverride = se.ASP_Override__c;
                                                                          //End: PJENA-2016.09.12: Price Override
                                      seh.asp   = se.ASP__c;
                                      system.debug('*********se.ASP__c'+ se.ASP__c);
                                                                        }
                                                                        else if((System.Label.GeForce_and_Quadro_Sales_Opportunity != null &&  System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)) || (system.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME))){
                                      seh.asp   = (se.ASP__c == null) ? null : se.ASP__c.intValue();
                                      //PJENA-2016.09.12: Price Override
                                      seh.aspoverride   = (se.ASP_Override__c == null) ? null : se.ASP_Override__c.intValue();
                                      //End: PJENA-2016.09.12: Price Override
                                                                        }
                                                                        
                                                                        olih.lstSEHs.add(seh);
                                                                }
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
                      if(System.Label.Tegra_auto_and_embedded_opportunity != null &&  System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)){
                        startingQuarter = lstQuarters[0];
                      }
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
            }
        }
        //End: CASE 3: For EDIT or Clone opportunity
        
        //Flag is set to false to begin with, so that it does not show the Save button
        try{
            //initOne();
            flag = false;
            if(opp.Probability == null){
                opp.Probability = 0.00;
            }
        }Catch(Exception ee){
          
        }
        //End: Flag is set to false to begin with, so that it does not show the Save button
    }
    //End : Constructor
        
    // On page opportunity Stage and Probablity doesnot work to-gather so we have to write custom code to achieve the same.
    // The user changed the Opportunity StageName. Set the Probability to the
    // correct value, based on the defaults set up in the OpportunityStage object.
    public transient Map<String, Decimal> probabilityStageNameMap;
    public Boolean disableInput {get; set;} 
    public PageReference changeStageName(){        
    if (probabilityStageNameMap == null) {
      probabilityStageNameMap = new Map<String, Decimal>();
      for (OpportunityStage oppStage : [Select MasterLabel, DefaultProbability From OpportunityStage]){
        probabilityStageNameMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
      }
    }
      
    if (probabilityStageNameMap.containsKey(opp.StageName)) {
      opp.Probability = probabilityStageNameMap.get(opp.StageName);           
    }
    
    if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME) && (opp.StageName == 'Closed Lost' || opp.StageName== 'Closed - Other')){
      disableInput = true ;
    }else if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME) || System.Label.Tegra_Tablets_SB_SP_Opportunity.contains(RECORDTYPE_NAME)) {  
      disableInput = false ;
    }
    return null;
  }

  public void getErrorVal(){
    if(opp.Name == null){
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, '*Please fill required field*')); 
    }
  }
    
    //default constructor
    public clsOpportunityV2(){
        //do nothing
    }
    //end: default constructor
        
    PageBlock__c objPageBlock ;    
    
    
    //variables and getter/setter
    public String output {get;set;}
    public String hide {get;set;}    
    
    public Opportunity opp {get;set;}    
    public List<pageblockWrapper> lstPageBlockWrapper  {get;set;}      
    public class pageblockWrapper{
        public string Name {get;set;}
        public string mode {get;set;}        
        public List<pageblockSectionWrapper> lstpageblockSectionWrapper {get;set;}
        public pageblockWrapper(){
           lstpageblockSectionWrapper = new List<pageblockSectionWrapper>(); 
        }
    }
    
    public class pageblockSectionWrapper{
        public string pageblocSectionkName {get;set;}
        public integer Columns {get;set;}    
        public integer serialNo {get;set;}
        public List<pageblocksectionfieldWrapper> lstpageblocksectionfieldWrapper {get;set;}
        public pageblockSectionWrapper(){
            lstpageblocksectionfieldWrapper  = new List<pageblocksectionfieldWrapper>();
        }
    }
    
    public class pageblocksectionfieldWrapper{
        public string fieldName {get;set;}   
        public integer serialNo {get;set;}
        public boolean IsRequired {get;set;}
        public boolean IsReadOnly {get;set;} 
        public boolean IsEmptySpace {get;set;}
        public boolean IsTextAreaField{get;set;}  
    }
    
    List<string> lstButtons = new List<string>();
    public List<string> getButtons(){                
        return lstButtons;
    }
    
     public void initOne(){
        try{
        flag = true;
        Map<string,boolean> mapFieldNameAndAccessibility = new Map<string,boolean>();
        Map<String, Schema.SobjectField> fields = Opportunity.getSObjectType().getDescribe().fields.getMap();
        for (String s : fields.keySet()) {
            if ((fields.get(s).getDescribe().isAccessible())) {
                mapFieldNameAndAccessibility.put(s,true);
                
            }
        }
        
        //Get readonly & required field from custom setting
        map<string,string> mapRecordtypeNameandReadonlyField = new map<string,string>(); 
        //map<string,string> mapRecordtypeNameandRequiredField = new map<string,string>(); 
        RecordType recordtypeOpp = [select Id,Name from RecordType where id=:Apexpages.Currentpage().getParameters().get('RecordType')];
        Pricebook_Details__c csForReadOnlyandRequired = Pricebook_Details__c.getValues(recordtypeOpp.Name);  
        //if(csForReadOnlyandRequired.name != null && csForReadOnlyandRequired.Name.equalsIgnoreCase(recordtypeOpp.Name))
        if(csForReadOnlyandRequired.Name.equalsIgnoreCase(recordtypeOpp.Name))
        {
            //mapRecordtypeNameandRequiredField.put(recordtypeOpp.Name, csForReadOnlyandRequired.Required_Fields__c != null ?csForReadOnlyandRequired.Required_Fields__c:'');
            mapRecordtypeNameandReadonlyField.put(recordtypeOpp.Name, csForReadOnlyandRequired.Read_Only_Fields__c != null ?csForReadOnlyandRequired.Read_Only_Fields__c:'');                                   
        }
         
        system.debug('check---------'+mapFieldNameAndAccessibility);
        //system.debug('mapRecordtypeNameandRequiredField---------'+mapRecordtypeNameandRequiredField);
        system.debug('mapRecordtypeNameandReadonlyField---------'+mapRecordtypeNameandReadonlyField);
        pageblockWrapper objpageblockWrap = new pageblockWrapper();
        PageBlock__c objPageBlock = [select Id,Name,Mode__c from PageBlock__c where Record_Type_Id__c=:recordTypeId   limit 1];
        objpageblockWrap.Name = objPageBlock.Name;
        objpageblockWrap.mode = objPageBlock.Mode__c;
        List<pageblockSectionWrapper> lstToAddpageblockSectionWrapper = new List<pageblockSectionWrapper>();
                            
        //Get Opportunity fields
        Schema.DescribeSObjectResult objDSObjResult = Opportunity.getSObjectType().getDescribe();
        Map<String,Schema.DescribeFieldResult> finalMap = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.SObjectField> objectFields = objDSObjResult.fields.getMap();
        for(string eachField: objectFields.keyset()){
            Schema.DescribeFieldResult dr = objectFields.get(eachField).getDescribe();
            finalMap.put(eachField, dr);
        }
        
        for(PageBlockSection__c objPageBlockSection :[select Id,Name,Columns__c,Sequence_Number__c,PageBlock__c,(select Id,Name,PageBlockSection__c,Sequence_Number__c,IsRequired__c,IsEditable__c,Is_Empty_Space__c from Fields__r) from PageBlockSection__c where pageblock__c=:objPageBlock.id]){        
            pageblockSectionWrapper objpageblockSectionWrapper  = new pageblockSectionWrapper ();
            objpageblockSectionWrapper.pageblocSectionkName = objPageBlockSection.Name;
            objpageblockSectionWrapper.Columns = integer.valueOf(objPageBlockSection.Columns__c);
            objpageblockSectionWrapper.serialNo = integer.valueOf(objPageBlockSection.Sequence_Number__c);
            List<pageblocksectionfieldWrapper> lstToAddPageBlockSectionWrapperField = new List<pageblocksectionfieldWrapper>();

            for(Field__c field :objPageBlockSection.Fields__r){                
                if(mapFieldNameAndAccessibility.containskey(field.Name.toLowerCase()) || field.Is_Empty_Space__c==true){
                    if(mapFieldNameAndAccessibility.get(field.Name.toLowerCase())==true || field.Is_Empty_Space__c==true){

                    
                        pageblocksectionfieldWrapper objpageblocksectionfieldWrapper = new pageblocksectionfieldWrapper();
                        objpageblocksectionfieldWrapper.fieldName = field.Name;
                        objpageblocksectionfieldWrapper.serialNo = integer.valueOf(field.Sequence_Number__c); 
                        objpageblocksectionfieldWrapper.IsRequired =  field.IsRequired__c;
                        objpageblocksectionfieldWrapper.IsEmptySpace = field.Is_Empty_Space__c;
                        //Added for Readonly & reqired field
                        system.debug('****field.Name'+field.Name);
                        //if(mapRecordtypeNameandRequiredField != null && mapRecordtypeNameandRequiredField.get(recordtypeOpp.Name) != null &&  mapRecordtypeNameandRequiredField.get(recordtypeOpp.Name).contains(field.Name)){
                        //    objpageblocksectionfieldWrapper.IsRequired = true;                          
                        //}
                        
                        if(field.IsEditable__c == false){
                             objpageblocksectionfieldWrapper.IsReadOnly = true; 
                        }
                        else if(mapRecordtypeNameandReadonlyField != null && mapRecordtypeNameandReadonlyField.get(recordtypeOpp.Name) != null &&  mapRecordtypeNameandReadonlyField.get(recordtypeOpp.Name).contains(field.Name)){
                            objpageblocksectionfieldWrapper.IsReadOnly = true;                          
                        }
                        
                        //Check for textarea field to apply style
                        if(field.Is_Empty_Space__c == false && finalMap != null && finalMap.get(field.Name.tolowercase()) != null){
                           if(string.valueof(finalMap.get(field.Name.tolowercase()).getType()) == 'TEXTAREA'){
                               objpageblocksectionfieldWrapper.IsTextAreaField = true;
                                system.debug('******field type**'+finalMap.get(field.Name.tolowercase()).getType());
                            }
                       }
                                                      
                        lstToAddPageBlockSectionWrapperField.add(objpageblocksectionfieldWrapper);
                    }
                }
            }
            List<pageblocksectionfieldWrapper> sortedlstToAddPageBlockSectionWrapperField = sorting(lstToAddPageBlockSectionWrapperField);
            system.debug('check----'+sortedlstToAddPageBlockSectionWrapperField);  
            objpageblockSectionWrapper.lstpageblocksectionfieldWrapper = sortedlstToAddPageBlockSectionWrapperField ;
            lstToAddpageblockSectionWrapper.add(objpageblockSectionWrapper);
        }
        List<pageblockSectionWrapper> sortedWrapperPageBlockSection = sorting(lstToAddpageblockSectionWrapper);
        objpageblockWrap.lstpageblockSectionWrapper  = sortedWrapperPageBlockSection;
        lstPageBlockWrapper.add(objpageblockWrap);
        system.debug('&&&&&&&&&&&&&&&&&&&&'+lstPageBlockWrapper);
        for(Button__c btn : [select id,Name from Button__c where pageBlock__c=:objPageBlock.Id]){
            lstButtons.add(btn.Name);
        }
        }Catch(Exception ee){
          
        }
    }
  
  //Cancel method to redirect to opportunity detail record or opportunity tab based on the opportunity Id
  public pagereference cancel(){
        pagereference page;
        if(opp.id != null){
            page = new pagereference('/'+opp.id).setRedirect(true);
        }else{
            page = new pagereference('/006/o').setRedirect(true);
        }
        return page;
    }
    //End: Cancel method
       
  //Sorting PageBlockSectionWrapper: Sort list based on the sequence number enter in records.    
    public list<pageblockSectionWrapper> sorting(list<pageblockSectionWrapper> currlist){
    integer j = 0;          
    pageblockSectionWrapper  tmp = new pageblockSectionWrapper ();  
    if(currlist.size()>1){              
      for(integer i = 0; i < currlist.size(); i++){
        j = i;
        for(integer k = i; k<currlist.size(); k++){               
          if(currlist[j].serialNo  > currlist[k].serialNo){   
            j = k;
          }
        }                    
        tmp = currlist[i];
        currlist[i] = currlist[j];
        currlist[j] = tmp;
      }                
    }
    return currlist;  
  }
    //End: Sorting PageBlockSectionWrapper
    
  //Sort pageblocksectionfieldWrapper : Sort list based on the sequence number entered in records.    
     public list<pageblocksectionfieldWrapper> sorting(list<pageblocksectionfieldWrapper> currlist){
    integer j = 0;          
    pageblocksectionfieldWrapper tmp = new pageblocksectionfieldWrapper();  
    if(currlist.size() > 1){           
      for(integer i=0; i < currlist.size(); i++){
        j = i;
        for(integer k = i; k < currlist.size(); k++){               
          if(currlist[j].serialNo  > currlist[k].serialNo){   
            j = k;   
          }
        }                    
        tmp = currlist[i];
        currlist[i] = currlist[j];
        currlist[j] = tmp;
      }                
    }
    return currlist;
  }
  //End: Sort pageblocksectionfieldWrapper
  
  //OLIHelper class
    //   Each OLIHelper is a row in the "GeForce Products" section of the page
     public class OLIHelper {
        public clsOpportunityV2 ctl {get; private set;}
        public integer index {get; private set;}
        public Id oliId {get; set;}
        public Id pbeId {get; set;}
        public integer defaultUnits {get; set;}
        public List<ScheduleEntryHelper>  lstSEHs   {get; set;}
        public OpportunityLineItem oli {get; set;} // Populated only when the Opp is saved.
        public string strRecordTypeName {get;set;}
        //For Tegra SB,SP Variable
        public PricebookEntry pbe {get; set;}
        
        public OLIHelper(){}
        
        //Added on 06-08-2014 to get recordtype name
        //clsOpportunityV2 objOutputCtrl;
        public OLIHelper(clsOpportunityV2 ctl, String family, Id pbeId, Id oliId) {
            this.ctl = ctl;
            this.index = ctl.lstOLIHelpers.size();
            strRecordTypeName = ctl.RECORDTYPE_NAME;
            
            //objOutputCtrl = new clsOpportunityV2();
            system.debug('******06-08-2014'+strRecordTypeName);
            if(System.Label.Tegra_auto_and_embedded_opportunity.contains(strRecordTypeName)){
        //this.family  = 'Tegra Auto/Emb'; // NOTE: Hard-coded to "Tegra Auto/Emb"        
        this.family  = ctl.strTegraandTeslaFamily;
            }
            
            if(System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(strRecordTypeName)){
                this.family  = family;
            }
            
            if(System.Label.Tesla_Sales_Opportunity.contains(strRecordTypeName)){
                //this.family = 'Tesla';
                /*
                2016.04.01 - PJENA - Changes related to Tesla Product Family visibility.
                this.family  = ctl.strTegraandTeslaFamily;
                */
                this.family  = family;
            }
            system.debug('******family'+family);

            this.lstSEHs = new List<ScheduleEntryHelper>();
            this.pbeId   = pbeId;
            this.oliId   = oliId;
        }
        
        // Add a ScheduleEntryHelper for the given quarter
        public void addQuarter(string quarter) {
            this.lstSEHs.add(new ScheduleEntryHelper(ctl, this, quarter));
        }
        
        // Update a ScheduleEntryHelper for the given quarter
        public void updateQuarter(string quarter) {
            if(system.Label.Tesla_Sales_Opportunity.contains(strRecordTypeName)){
                this.lstSEHs.add(new ScheduleEntryHelper(ctl, this, quarter));
            }
        }
        
        //A Product is deletable if it doesn't have any saved Schedule Entries that go more than 2 quarters into the past.
        public Boolean isDeletable { 
      get {
        // Admins can always delete anything
        if (ctl.userIsAdmin) return true;
                    
        if (this.oliId == null) {
          // This OLI hasn't been saved yet, so it and its Schedule Entries can be deleted
          return true;
        }else{
          // This OLI has been saved already. If it has any Schedule Entries that go more than 2 quarters, into the past, it cannot be deleted. 
          for (ScheduleEntryHelper seh : lstSEHs) {
            //if (Utils.quarterIsThreeFiscalQuartersBeforeQuarter(seh.quarter, ctl.todaysQuarter)) {
            //     return false;
            // }
            if(System.Label.Tegra_auto_and_embedded_opportunity.contains(strRecordTypeName) || System.Label.Tesla_Sales_Opportunity.contains(strRecordTypeName)){
              if (Utils.quarterIsThreeFiscalQuartersBeforeQuarter(seh.quarter, ctl.todaysQuarter)){
                return false;
              }       
            }
          }
          
          return true;
        }
      }
    }
        
        // When a new Family is selected, set the pbeId to the first one for this Family
        public string family{
      get{
        if(System.Label.Tegra_auto_and_embedded_opportunity.contains(strRecordTypeName)){
          // family='Tegra Auto/Emb';// NOTE: Hard-coded to "Tegra Auto/Emb"
          family= ctl.strTegraandTeslaFamily;
        }
        /*
        2016.04.01 - PJENA - Changes related to Tesla Product Family visibility.
        if(System.Label.Tesla_Sales_Opportunity.contains(strRecordTypeName)){
          //family='Tesla';
                           family= ctl.strTegraandTeslaFamily; 
        }
                */
        return family;
      } 
            
            set{
                if (family != value) {
          family = value;
                    
                    system.debug('******value'+ value);
                    if (value == '' || value == null) {
                        // The user hasn't selected a family yet    
                        pbeId = null;
                    }else {
            // Set the pbeId to the first one for this family
            List<SelectOption> tmp = pbesForFamily;
            if(ctl.mapPBEsByFamily.containskey(family) != null){
                            pbeId = ctl.mapPBEsByFamily.get(family)[0].id;
            }
                    }
                }
      }
        }

        //Returns the Select Options for the Products for the selected Family
        public List<SelectOption> pbesForFamily{
      get{
        
        pbesForFamily = new List<SelectOption>();
                
                if (family == '' || family == null) {
                    // The user hasn't selected a family yet, so we can't display
                    // any PBEs for that family 
                    return pbesForFamily;
                }
                
                if (ctl.mapPBEsByFamily.containsKey(family) == false) {
                    List<PricebookEntry> lstPBEs = [Select id, Name, UnitPrice
                          From   PricebookEntry
                          Where  IsActive = true
                            And    Pricebook2Id = :ctl.opp.Pricebook2Id
                            And    Product2.Family = :this.family
                          order by Product2.Product_Sort_Order__c DESC, Name];
          ctl.mapPBEsByFamily.put(family, lstPBEs);
        }else{
          for (PricebookEntry pbe : ctl.mapPBEsByFamily.get(family)) {
                        pbesForFamily.add(new SelectOption(pbe.id, pbe.name)); // value, label
                    }
                }
                return pbesForFamily;
            }
            
            set;
        }
        
        @TestVisible public string productName{
            get {
                if (family=='' || family==null || pbeId==null) return '';
                for (PricebookEntry pbe : ctl.mapPBEsByFamily.get(family)) {
                    if (pbe.id == this.pbeId) return pbe.Name;
                }
                return '';
            }
        }
        
        // ASP for the selected PBE
    @TestVisible public decimal asp{
      get {
                if (family=='' || family==null || pbeId == null) return null;
                for (PricebookEntry pbe : ctl.mapPBEsByFamily.get(family)) {
                    if (pbe.id == this.pbeId) return pbe.UnitPrice;
                }
                return null;
            }
            set;
        }

        // Total of the Units for all this OLI's Schedule Entry Helpers
    @TestVisible public integer totalUnits {
            get {
                integer total = 0;
                for (ScheduleEntryHelper seh : this.lstSEHs){ 
                  total += seh.units;
                }
                return total;
            }
        }
        
    @TestVisible public decimal totalPrice {
            get {
                decimal total = 0;
                for (ScheduleEntryHelper seh : this.lstSEHs){
                  total += seh.revenue;
                }
                return total;
            }
        }
    }
    //End: OLIHelper class
    
    //ScheduleEntryHelper class
  // Describes a row in the "GeForce Product Revenue by Quarter" section of the page, one row for each quarterly entry for a single Product.
    public class ScheduleEntryHelper {
        public clsOpportunityV2 ctl {get; private set;}
        public OLIHelper  olih    {get; set;}
        public string     quarter {get; set;}
        public integer    units   {get; set;}
        public decimal    asp     {get; set;} // Migrated opps allow ASP to be set differently for each Schedule Entry
    public decimal    aspoverride     {get; set;} //PJENA-2016.09.12: Price Override
        string strRecordTypeName {get; set;}
        
        public ScheduleEntryHelper(clsOpportunityV2 ctl, OLIHelper olih, string quarter) {
            this.ctl     = ctl;
            this.olih    = olih;
            this.quarter = quarter;
            strRecordTypeName = ctl.RECORDTYPE_NAME;
            
            if(system.Label.GeForce_and_Quadro_Sales_Opportunity.contains(strRecordTypeName)){
               this.units   = 0;
               //if(ctl.opp.Migrated_From_Old_Design__c) this.asp = this.olih.asp;
            }
            
            if(system.Label.Tesla_Sales_Opportunity.contains(strRecordTypeName)){
                this.units   = 0;
            }
            
            if(system.Label.Tegra_auto_and_embedded_opportunity.contains(strRecordTypeName)){
        // If this is the last quarter in the list, and there's a quarter before this one, default the units and ASP to the values from the previous quarter
        if ((ctl.lstQuarters[ctl.lstQuarters.size()-1] == quarter) && (ctl.lstQuarters.size() > 1)) {
                    
          // Find the SEH for the previous quarter
          String previousQuarter = ctl.lstQuarters[ctl.lstQuarters.size()-2];
                        
          for (ScheduleEntryHelper seh : this.olih.lstSEHs) {
            if (seh.quarter == previousQuarter) {
              this.units = seh.units;
              this.asp = seh.asp;
              //PJENA-2016.09.12: Price Override
              this.aspoverride = seh.aspoverride;
              //End: PJENA-2016.09.12: Price Override
              break;
            }
          }
        }
        
        //If this is the first quarter in the list, and there's a quarter after this one, default the units and ASP to the values from the previous quarter
        else if ((ctl.lstQuarters[0] == quarter) && (ctl.lstQuarters.size() > 1)) {
          // Find the SEH for the next quarter
          string nextQuarter = ctl.lstQuarters[1];
          
          for (ScheduleEntryHelper seh : this.olih.lstSEHs) {
            if (seh.quarter == nextQuarter) {
              this.units = seh.units;
              this.asp = seh.asp;
              //PJENA-2016.09.12: Price Override
              this.aspoverride = seh.aspoverride;
              //End: PJENA-2016.09.12: Price Override
              break;
            }
          }
        }
            }
    }
        
        public decimal revenue {
      get {
        if(System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(strRecordTypeName) || System.Label.Tesla_Sales_Opportunity.contains(strRecordTypeName)){
          /*
          if (ctl.opp.Migrated_From_Old_Design__c) {
            // Migrated opps could have different ASP values for each SEH 
            if (asp == null) return null;
                                    return asp * units;
          }else {
          */
            //PJENA-2016.09.12: Price Override : If there ASP Override, then calculate revenue based on ASP Override price
            /* commentd code as part of Price Override
            if (olih.asp == null) return null;
            return olih.asp * units;
            */
            
            if (olih.asp == null){
              return null;
            }else{
              if (this.aspoverride == null || this.aspoverride == 0){
                return olih.asp * units;
              }else{
                return this.aspoverride * units;
              }
            }
            //End: PJENA-2016.09.12: Price Override : If there ASP Override, then calculate revenue based on ASP Override price
          //}
        }
                        
        if(System.Label.Tegra_auto_and_embedded_opportunity.contains(strRecordTypeName)){
          if (asp == null) asp = 0;
          if (units == null) units = 0;
          //PJENA-2016.09.12: Price Override : If there ASP Override, then calculate revenue based on ASP Override price
          /* commentd code as part of Price Override
          return asp * units;
          */
          if (this.aspoverride == null || this.aspoverride == 0){
            return  asp * units;
          }else{
            return this.aspoverride * units;
          }
          
        }
        return null;
      }
    }

        // A SEH editable if its OLIH has been saved and its quarter isn't 
        // more than 2 quarters into the past.
        public boolean isEditable { 
      get {
        if(System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(strRecordTypeName) || System.Label.Tesla_Sales_Opportunity.contains(strRecordTypeName)){
          // Admins can always edit anything
          if (ctl.userIsAdmin) return true;
                
          //if (olih.oliId == null) return true;
          return (! Utils.quarterIsThreeFiscalQuartersBeforeQuarter(this.quarter, ctl.todaysQuarter)); 
        }
                        
        if(System.Label.Tegra_auto_and_embedded_opportunity.contains(strRecordTypeName)){
          return true;
        }
        
        return null;
            }
        }

        public string quarterSortable {
            get {
                system.debug('****'+quarter);
                return Utils.swapFiscalDateSections(this.quarter);
            }
        }

    }
    //End: ScheduleEntryHelper class
    
    
    /*
      Add Starting Quarter buton click
      Called from VF page
    */
    //pickStartingQuarter property
    public PageReference pickStartingQuarter() {
        
        if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)){
      // Create a new empty Product Helper
      lstOLIHelpers = new List<OLIHelper>();
      lstOLIHelpers.add(new OLIHelper(this, null, null, null));
                    
      // Add the current quarter to the list of quarters, and create a Schedule Entry Helper for the Product Helper we just created
      lstQuarters = new List<String>();
      IsTegraOpp=true;
       }
        
        if(System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME) || System.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME)){
      lstQuarters.clear();
      //get the latest value for startingQuarter
      startingQuarter = Utils.getFiscalQuarterForDate(opp.CloseDate);
      system.debug('startingQuarter----------------->'+startingQuarter);                
        }
        
        // Add the current quarter to the list of quarters, and create a  Schedule Entry Helper for the Product Helper we just created
        system.debug('*****startingQuarter'+startingQuarter);
        lstQuarters.add(startingQuarter);
        for (OLIHelper olih : lstOLIHelpers) olih.addQuarter(startingQuarter);
        
        return null; 
    }
    //End: pickStartingQuarter property
    
    
    /*
      The user wants to add a row to the list of Product Helpers
      Called from VF page
    */
    //addProduct() property
    public PageReference addProduct() {
        // Add a Product Helper
        OLIHelper olih = new OLIHelper(this, null, null, null);
        lstOLIHelpers.add(olih);
        
        // Add a Schedule Entry Helper for each quarter that's defined
        for (String quarter : lstQuarters) olih.addQuarter(quarter);
        return null;
    }
    //End: addProduct() property
    
    
    /*
      The user wants to delete the OLIH with the given index
      Called from VF page
    */
    //deleteProductIndex and deleteProductIndex property
    public String deleteProductIndex {get; set;}
    public PageReference deleteProduct() {
        if(System.Label.Tegra_Tablets_SB_SP_Opportunity.contains(RECORDTYPE_NAME)) {
            try {
                // The caller populates selectedHelper with the index of the helper they want to clear
                deletedHelpers.add(helpers[selectedHelper]);
                OLIHelper olih = new OLIHelper();   
                olih.index = selectedHelper;
                olih.pbe = new PricebookEntry();
                olih.oli = new OpportunityLineItem();
                helpers[selectedHelper] = olih;
            } catch (Exception ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '' + ex );
                ApexPages.addMessage(msg);
            }
        }else{
      if (deleteProductIndex == null) deleteProductIndex = ApexPages.currentPage().getParameters().get('deleteProductIndex');
            integer index = Integer.valueOf(deleteProductIndex);
            for (Integer i = 0; i < lstOLIHelpers.size(); i++) {
                if (lstOLIHelpers[i].index == index) {
                    lstOLIHelpers.remove(i);
                    break;
                }
            }
        }
        return null;
    }
    //End: deleteProductIndex and deleteProductIndex property
    
   
    /*
      Getter method for the list of Families for Products in the Opp's price book.
      For performance, we cache the list of product families.
      Called from VF page
    */
     //lstProductFamilies property
    public List<SelectOption> lstProductFamilies {
        get {
          system.debug('***PJ: calling lstProductFamilies');
            if (lstProductFamilies == null) {
                // Get a list of all Product Families for this price book, and put it
                // in a cache.
        lstProductFamilies = new List<SelectOption>();
                
                if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME) || System.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME)){
                    lstProductFamilies.add(new SelectOption('', '')); // value, label
                }
                
        List<AggregateResult> lstARs = [Select Family
                                   From   Product2
                                   Where id in (Select Product2Id From PricebookEntry Where Pricebook2Id = :opp.Pricebook2Id)
                                     And   IsActive = true
                                     And   Family <> null
                                   Group by Family
                                   order by Family];
                                   
        for (AggregateResult ar : lstARs) {
          lstProductFamilies.add(new SelectOption((String)ar.get('Family'), (String)ar.get('Family'))); // value, label
                }
            }
            
            //return lstProductFamilies;
            if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME) || System.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME)){
                return lstProductFamilies;      
            }
            
            
            /*Written by Sushma Start */
            if(System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)){
              system.debug('PJ: inside lstProductFamilies getter and record type in System.Label.GeForce_and_Quadro_Sales_Opportunity');
        List<selectOption> newltsToReturn = new List<selectOption>();
        newltsToReturn.add(new SelectOption('', '')); // value, label 
        set<string> checkDuplicate = new set<string>();
        for(selectOption so : lstProductFamilies){
          if(so.getLabel() == 'GeForce GPU Products'){
            checkDuplicate.add(so.getLabel());
            newltsToReturn.add(new selectOption(so.getLabel(), so.getvalue()));
          }
        }            
        for(selectOption so :lstProductFamilies){
          if(!checkDuplicate.contains(so.getLabel())){
            newltsToReturn.add(new selectOption(so.getLabel(),so.getvalue()));
            checkDuplicate.add(so.getLabel());
          }
        }
        
        return newltsToReturn;
            }
            
            return null;
            /* End */
        }
        private set;
    }
    //End: lstProductFamilies property
    
    /*
      The user wants to a quarter to the end of the list of quarters
      Called from VF page
    */
    //addNextQuarter property
    public PageReference addNextQuarter() {
        // Add the quarter to the end of the list
        String nextQuarter = Utils.getNextQuarter(lstQuarters[lstQuarters.size()-1]);
        lstQuarters.add(nextQuarter);
        
        // Add ScheduleEntryHelpers to all of the current Products
        for (OLIHelper olih : lstOLIHelpers) olih.addQuarter(nextQuarter);          
        return null;
    }
    //End: addNextQuarter property
    
    /*
      The user wants to a quarter to the start of the list of quarters
      Called from VF page
    */
    //addPreviousQuarter property
    public PageReference addPreviousQuarter() {
        // Add the quarter to the start of the list
        String prevQuarter = Utils.getPreviousQuarter(lstQuarters[0]);
        lstQuarters.add(0, prevQuarter);
        
        // Add ScheduleEntryHelpers to all of the current Products
        for (OLIHelper olih : lstOLIHelpers) olih.addQuarter(prevQuarter);          
        return null;
    }
    //End: addPreviousQuarter property
    
    /*
      helper method used by action function method updateStartingQuarter()
      Detailed Functionality: TBD
    */
    //changeQuarter helper method
    public PageReference changeQuarter(String previousQuarter, String quarter) {

        for (OLIHelper olih : lstOLIHelpers) {
            //if (olih.family == '' || olih.family == null || olih.pbeId == null || olih.totalUnits == 0) continue;
            for (Integer i=0; i<olih.lstSEHs.size(); i++) {
                ScheduleEntryHelper seh = olih.lstSEHs[i];
                system.debug('check---------'+seh.quarter);
                system.debug('check---previousQuarter------'+previousQuarter);
                system.debug('check------lstTempQuarters.size()---'+lstTempQuarters.size());                
                if (seh.quarter == previousQuarter) {
                    seh.quarter = quarter;
                    
                    for (Integer j = 0; j < lstTempQuarters.size(); j++) {
                        system.debug('lstTempQuarters[j]-----------'+lstTempQuarters[j]);
                        system.debug('check---previousQuarter------'+previousQuarter);
                        system.debug('lstIndex[j]-----------'+lstIndex[j]);     
                        system.debug('seh.olih.index-----------'+seh.olih.index);                           
                        if(lstTempQuarters[j] == previousQuarter && lstIndex[j] == seh.olih.index) {
                            lstNewQuarters.add(seh.quarter + ':' + lstUnits[j] + ':' + seh.olih.index);
                            /*String str = 'Quarter: ' + seh.quarter + ', units: ' + lstUnits[j];
                            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, str);
                            ApexPages.addMessage(msg);*/
                            break;
                        }
                    }
                    break;
                }
            }
        }
        system.debug('lstNewQuarters---------------'+lstNewQuarters.size());
        return null;
    }
    //End: changeQuarter helper method
    
    /*
      Action Function called from vf's js method updateQuarters() to update Starting Quarters based on the Close Date
    */
    //updateStartingQuarter method : JS action function
    public PageReference updateStartingQuarter() {
        integer numberQuartersBefore = 0;
        integer numberQuartersAfter = 0;
        integer numberQuarters = lstQuarters.size();
        integer i = 0;
        lstUnits = new List<Integer>();
        lstTempQuarters = new List<string>();
        lstNewQuarters = new List<string>();   
        lstIndex = new List<integer>();
        system.debug('check----------->'+lstOLIHelpers);
        
        for (OLIHelper olih : lstOLIHelpers) {
            for (i = 0; i < olih.lstSEHs.size(); i++) {
                ScheduleEntryHelper seh = olih.lstSEHs[i];
                lstUnits.add(seh.Units);
                lstTempQuarters.add(seh.quarter);
                lstIndex.add(seh.olih.index);
            }               
        }
        
        //copy the starting quarter into previousStartingQuarter

       //startingQuarter = Utils.getFiscalQuarterForDate(opp.CloseDate);
       system.debug('check------opp.StartingQuarter__c--------'+opp.StartingQuarter__c);
       system.debug('check------startingQuarter--------'+startingQuarter);
       if (opp.StartingQuarter__c == null) {
           previousStartingQuarter = startingQuarter;
       }
       else {      
           previousStartingQuarter = opp.StartingQuarter__c;
       }
        
        // Figure out position of starting quarter
        for (i=0; i<lstQuarters.size(); i++) {
            if(lstQuarters[i] == previousStartingQuarter) {
                numberQuartersBefore = i;
                numberQuartersAfter = lstQuarters.size() - (i+1);
                break;   
            }
        }
        
        system.debug('check-------' + previousStartingQuarter); 
        system.debug('check-------'  +opp.CloseDate);
        system.debug('Utils.getFiscalQuarterForDate(opp.CloseDate)---------' + Utils.getFiscalQuarterForDate(opp.CloseDate));
        
        changeQuarter(previousStartingQuarter, Utils.getFiscalQuarterForDate(opp.CloseDate));        
        if( lstQuarters.size() > 0 ){             // list size must be greater than to avoid index error.
          lstQuarters[numberQuartersBefore] = Utils.getFiscalQuarterForDate(opp.CloseDate);
        }
        opp.StartingQuarter__c = Utils.getFiscalQuarterForDate(opp.CloseDate);
        
        //update previous quarters
        if (numberQuartersBefore > 0) {
            for (i=0; i < numberQuartersBefore ; i++) {
                changeQuarter(lstQuarters[numberQuartersBefore-(i+1)], Utils.getPreviousQuarter(lstQuarters[numberQuartersBefore-i]));
                lstQuarters[numberQuartersBefore-(i+1)] = Utils.getPreviousQuarter(lstQuarters[numberQuartersBefore-i]);
            }
        } 
        
        //update nextquarters
        if (numberQuartersAfter > 0) {
            for (i=0; i < numberQuartersAfter ; i++) {
                changeQuarter(lstQuarters[numberQuartersBefore+(i+1)], Utils.getNextQuarter(lstQuarters[numberQuartersBefore+i]));
                lstQuarters[numberQuartersBefore+(i+1)] = Utils.getNextQuarter(lstQuarters[numberQuartersBefore+i]);
            }
        }
        system.debug('check this value---------->'+lstQuarters);
        
        return null;
    }
    //End: updateStartingQuarter method : JS action function
        
    /*
    Returns a list of ScheduleEntryHelpers, sorted by quarter, suitable for display at the bottom of the page
    Called from VF Page
    */
    //lstSEHsByQuarter property
    public List<ScheduleEntryHelper> lstSEHsByQuarter{
    get {
      lstSEHsByQuarter = new List<ScheduleEntryHelper>();
      system.debug('lstQuarters------------'+lstQuarters);
      for (String quarter : lstQuarters) {
                system.debug('lstOLIHelpers-----------'+lstOLIHelpers.size());
                for (OLIHelper olih : lstOLIHelpers) {
                    system.debug('olih.lstSEHs-----------'+olih.lstSEHs.size());
                    for (ScheduleEntryHelper seh : olih.lstSEHs) {
                        system.debug('check-----seh.quarter'+seh.quarter+'Quarter--------'+quarter+'lstUnits-----------'+lstUnits);
                                             
                        if(System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME) || System.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME)){
              if (seh.quarter == quarter && (lstUnits == null)) {
                lstSEHsByQuarter.add(seh);
                break;
              }else if (seh.quarter == quarter && lstUnits != null) {   
                system.debug('lstNewQuarters.size()--------'+lstNewQuarters.size());                            
                for (Integer i = 0; i < lstNewQuarters.size(); i++) {                                
                  if(string.valueof(lstNewQuarters[i].split(':', 3)[0]) == seh.quarter) {
                    if (integer.valueof(lstNewQuarters[i].split(':', 3)[2]) == seh.olih.index) {
                      seh.units = integer.valueof(lstNewQuarters[i].split(':', 3)[1]);
                      lstSEHsByQuarter.add(seh);
                      break;
                    }
                  }
                }
              }
                        }
                        
                        if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)){
              if (seh.quarter == quarter){
                lstSEHsByQuarter.add(seh);
                break;
              }
                        }
                        system.debug('lstSEHsByQuarter-------------------->'+lstSEHsByQuarter);                                                      
                    }
                }
      }
            return lstSEHsByQuarter;
    }
        
        private set;
    }
    //End: lstSEHsByQuarter property
    
  /*
    Returns a list of Comments, sorted by date desc, suitable for display at the bottom of the page
    Called from VF Page
    */
    //lstCommentsByDateDesc property
    public List<Comments__c> lstCommentsByDateDesc {
        get {
            lstCommentsByDateDesc = new List<Comments__c>();
            if(opp != null && opp.Comments__r != null){
                for (Comments__c com : opp.Comments__r) {
                    lstCommentsByDateDesc.add(com);
                }
            }
            return lstCommentsByDateDesc ;
        }
        private set;
    }
    //End: lstCommentsByDateDesc property
    
    /*
      Save action method
    */
    //Save method
    public PageReference save(){
                
        //if this is a clone opportunity, set the opportunity ID to null
        if (param != null && param.equalsIgnoreCase('Clone')) {
            opp.id = null;            
        }
        
        string strProgress = '';
        
        //Begin a transaction
        Savepoint sp = Database.setSavepoint();
        try 
        {
            if (lstOLIHelpers != null && lstOLIHelpers.size() == 0){
                string str = 'Error: You must select a Product and enter Units and ASP before saving.';
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                ApexPages.addMessage(msg);                  
                return null;
            }
            
            /*
             * @Manideep - Opportunity RecordType Cleanup
            //For Opps with recrod type "Tegra Tablets, SB, SP Opportunity", "Embedded Entertainment Opportunity"
            //****************************************************************************************************************
            if(System.Label.Tegra_Tablets_SB_SP_Opportunity.contains(RECORDTYPE_NAME)) {
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
            
                // Per Margaret, resetting Start and End dates to the 15th of their respective months
                opp.Design_Start_Date__c = (opp.Design_Start_Date__c).toStartOfMonth() + 14;
                opp.Design_EOL_Date__c = (opp.Design_EOL_Date__c).toStartOfMonth() + 14;
                opp.Pricebook2Id = PRICEBOOK2_ID;        
                Utils.GetAllRecordTypeIdsByName(); 
                opp.RecordTypeId = recordTypeId;
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
          
          //Add Opp Line Items
                //For each helper, if its OLI refers to a product, make sure the OLI refers 
                // to the current Opportunity and add it to the list of OLIs to create
                //-------------------------------------------------------------------------
                List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
                system.debug('******'+ helpers);
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
                system.debug(lstOLIs.size() +'******'+ lstOLIs);        
                if (lstOLIs.size() > 0) {
                    upsert lstOLIs;
                } else {
                    Database.rollback(sp);
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Products must be created in order to save this Opportunity');
                    ApexPages.addMessage(msg);
                    return null;
                }
                //-------------------------------------------------------------------------
                //End: Add Opp Line Items
                
                // add products to opportunity record
                opp.Opportunity_Line_Item_Products__c = strProducts;
                upsert opp;
                
              //End: For Opps with recrod type "Tegra Tablets, SB, SP Opportunity", "Embedded Entertainment Opportunity"
              //****************************************************************************************************************
              
            }
            */
            else{
                //For all other record types except  "Tegra Tablets, SB, SP Opportunity", "Embedded Entertainment Opportunity"
                //****************************************************************************************************************
                  if(paramRTId != null && RECORDTYPE_NAME != null && RECORDTYPE_NAME != '' && System.Label.GeForce_and_Quadro_Sales_Opportunity != null &&  System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)){
                        
                  }
                  
                  //For Tegra Auto Tier 1 Opportunity, Tegra Auto OEM Opportunity,Tegra Embedded Opportunity
                  if(System.Label.Tegra_auto_and_embedded_opportunity != null &&  System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)){
                      // Tegra Auto requires at least 1 product to be selected
                      if (lstOLIHelpers.size() == 0) {
                          String str = 'Error:  You must select a Product and enter Units and ASP before saving.';
                          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                          ApexPages.addMessage(msg);                  
                          return null;
                      }
                      else 
                      {
                          Boolean blnFoundAProduct = false;
                          Boolean blnFoundNonZeroPrice = false;
                          Boolean blnFoundNonZeroUnits = false;
                          system.debug('******lstOLIHelpers***'+lstOLIHelpers);
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
                          if (!blnFoundNonZeroUnits) {
                               String str = 'You must enter Units for a Product before saving.';
                              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                              ApexPages.addMessage(msg);                  
                              return null;
                          }
                      }
                  }
                  //End: For Tegra Auto Tier 1 Opportunity, Tegra Auto OEM Opportunity,Tegra Embedded Opportunity
    
                  // Delete any OLIs for this Opp. Any Schedule Entries for those OLIs will also be deleted.
                  if (opp.id != null) delete [select id from OpportunityLineItem where OpportunityId = :opp.id];
                
                  // Save the Opp
                  if (System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME) && strStatusLastStep != opp.Status_Next_Step__c && opp.Status_Next_Step__c != '') {
                      opp.Status_Last_Step__c = strStatusLastStep;
                  }
                          
                  strProgress = 'saving the Opportunity';
                  upsert opp;
                                  
                  strProgress = 'after saving the Opportunity';
          
          //Insert Comments for Tegra Auto Tier 1 Opportunity, Tegra Auto OEM Opportunity, Tegra Embedded Opportunity
          //----------------------------------------------------------------------------------------------------
                  if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)){
                      //create comment for changes in Status_Next_Step__c field
                      if (opp.Status_Next_Step__c != strStatusLastStep){
                           Comments__c com = New Comments__c();
                           com.Name = 'Status: Last Step'; //commnet type
                           com.Comments__c = strStatusLastStep;
                           //com.Comments__c = opp.Status_Last_Step__c;
                           com.Opportunity__c = opp.Id;
                           insert com;
                       }
                         
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
                       /*if (opp.Reason_for_Approval__c != strPreviousReasonForApproval) {
                           Comments__c com = New Comments__c();
                           com.Name = 'Reason for Approval'; //commnnt type
                           com.Comments__c = strPreviousReasonForApproval;
                           com.Opportunity__c = opp.Id;
                           insert com;
                       }
                       */
          }
          //----------------------------------------------------------------------------------------------------
          //End: Insert Comments for Tegra Auto Tier 1 Opportunity, Tegra Auto OEM Opportunity, Tegra Embedded Opportunity
          
          // Create Opportunity Line Items and save them
          //----------------------------------------------------------------------------------------------------
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
                              string str = 'You cannot delete this Product from this Opportunity';
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
                      if( (System.Label.GeForce_and_Quadro_Sales_Opportunity != null &&  System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME)) 
                          || (System.Label.Tesla_Sales_Opportunity != null && System.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME)) ){
                          olih.oli.ASP__c   = olih.asp;
                      }
                      olih.oli.Quantity         = olih.totalUnits;
                      olih.oli.TotalPrice       = olih.totalPrice; 
                      lstOLIs.add(olih.oli);
                  }
                                    
                  strProgress = 'saving the Opportunity Products';
                  system.debug('===== about to insert lstOLIs ' + lstOLIs);
                  insert lstOLIs; 
                  system.debug('===== done inserting lstOLIs ' + lstOLIs);
                  //----------------------------------------------------------------------------------------------------
                  //End: Create Opportunity Line Items and save them
          
          // Update Opportunity_Line_Item_Products__c For GeForce Sales Opportunity, Quadro Sales Opportunity, Quadro Partner Opportunity, GRID Sales Opportunity, Quadro Partner Deal,Tegra Embedded Partner Opportunity
          // or Tegra Auto Tier 1 Opportunity, Tegra Auto OEM Opportunity, Tegra Embedded Opportunity
          //-------------------------------------------------------------------------------------------------
                  if(System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME) || System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)){        
                      // add products to opportunity record
                      opp.Opportunity_Line_Item_Products__c = strProducts;
                      strProgress = 'saving the Opportunity with products';
                      upsert opp;
                  }
          //-------------------------------------------------------------------------------------------------
          
          // Remove empty quarters from the start and end of the list
          //-------------------------------------------------------------------------------
                  // Check the start of the list
                  for (Integer i=0; i<lstQuarters.size(); i++) {
                      if (totalUnitsForQuarter(lstQuarters[i]) == 0) {
                          // There are no units for this quarter. Delete the quarter
                          // and all schedule entries for it
                          deleteQuarter(lstQuarters[i]);
                          lstQuarters[i] = '';
                      } else {
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
                      } else {
                          // We've found the last non-empty quarter, so we're
                          // done checking the end of the list
                          break;
                      }
                  }
                
                  for (Integer i=lstQuarters.size()-1; i>=0; i--) {
                      if (lstQuarters[i] == '') lstQuarters.remove(i);
                  }
                  //-------------------------------------------------------------------------------
                
                  // Create Schedule Entries and save them
                  //-------------------------------------------------------------------------------
                  strProgress = 'after saving the Opportunity Products';
                  List<Schedule_Entry__c> lstSEs = new List<Schedule_Entry__c>();
                  for (OLIHelper olih : lstOLIHelpers){
                      if (olih.family == '' || olih.family == null || olih.pbeId == null || olih.totalUnits == 0) continue;               
                      for (ScheduleEntryHelper seh : olih.lstSEHs){
                          Schedule_Entry__c se = new Schedule_Entry__c();
                          se.Opportunity__c = opp.id;
                          
                          if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)){
                              //se.Opportunity_Type__c = 'Tegra Auto/Emb Sales Opportunity';
                              se.Opportunity_Type__c = strOpportunityType;
                          }
                          
                          if(System.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME)){
                              //se.Opportunity_Type__c = 'Tesla Sales Opportunity';
                              se.Opportunity_Type__c = strOpportunityType;
                          }
                          
                          se.OLI_Id__c           = olih.oli.id;
                          se.Product_Name__c     = olih.productName;
                          se.Display_Quarter__c  = seh.quarter;
                          se.Quantity__c         = seh.units;
      
                          //if ((System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME) || System.Label.Tesla_Sales_Opportunity.contains(RECORDTYPE_NAME)) && opp.Migrated_From_Old_Design__c)
                          /*
                          if(System.Label.GeForce_and_Quadro_Sales_Opportunity.contains(RECORDTYPE_NAME) && opp.Migrated_From_Old_Design__c) {  
                se.ASP__c = seh.asp;
                //PJENA-2016.09.12: Price Override
                se.ASP_Override__c = seh.aspoverride;
                //End: PJENA-2016.09.12: Price Override
                lstSEs.add(se); 
                          }
                          */
                          
                          if(System.Label.Tegra_auto_and_embedded_opportunity.contains(RECORDTYPE_NAME)){
                              se.ASP__c = seh.asp;
                              system.debug('seh.revenue***' + seh.revenue);
                              //PJENA-2016.09.12: Price Override
                se.ASP_Override__c = seh.aspoverride;
                //End: PJENA-2016.09.12: Price Override
                              se.Revenue__c = (seh.revenue==null)?0 : seh.revenue;
                              lstSEs.add(se);  
                              system.debug( seh.asp+'*1111******se.ASP__c' + se.ASP__c);
                              system.debug( '*se******se.ASP__c' + se);
                              system.debug( '*lstSEs******se.ASP__c' + lstSEs);
                          }else{
                              se.ASP__c = olih.asp;
                              system.debug('*******se.ASP__c' + se.ASP__c);
                              //PJENA-2016.09.12: Price Override
                se.ASP_Override__c = seh.aspoverride;
                //End: PJENA-2016.09.12: Price Override
                              se.Revenue__c = (seh.revenue==null)?0 : seh.revenue;
                lstSEs.add(se); 
                          }
                      }
                  }          
          system.debug('*****'+lstSEs);
          
          if(lstSEs != null && lstSEs.size() > 0){
            strProgress = 'saving the Schedule Entries';
            insert lstSEs;
          }
          //End: Create Schedule Entries and save them
          //-------------------------------------------------------------------------------
               
                 //Added on 10-sep-2014 For RecordTypeChange from pagelayout
                 if(IsRecordTypeChange != null && IsRecordTypeChange == 'true'){
                      Opportunity objOpp = new Opportunity(id=paramId);
                      delete objOpp;
                 }
               
            }
            //End: For all other record types except  "Tegra Tablets, SB, SP Opportunity", "Embedded Entertainment Opportunity"
             //****************************************************************************************************************
        }catch (Exception ex) {          
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
  //End: Save method
    
    /*
    deleteQuarter called from Save method
    */
    //deleteQuarter helper method
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
    //End: deleteQuarter helper method
    
    /*
      Helper method Called from Save method to sum total units per quarter
    */
    //totalUnitsForQuarter helped method
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
    //End: totalUnitsForQuarter
    
    /*
      The page presents a SELECT list of quarters and lets the user pick the starting quarter. This method returns the list of 40 quarters:
      PJENA: Used in Tegra Auto/Emb Products secton of the VF i.e., IsTegraOpp = true
    */
    //lstPossibleQuarters method
    public List<SelectOption> lstPossibleQuarters {
        get {
          system.debug('***PJ: in method lstPossibleQuarters');
            List<SelectOption> lstOptions = new List<SelectOption>();

            // Get the current quarter
            string qtr = Utils.getFiscalQuarterForDate(Date.today());
            lstOptions.add(new SelectOption(qtr, Utils.swapFiscalDateSections(qtr))); // value, label); 
            for (Integer i = 0; i < 40; i++) {
                qtr = Utils.getNextQuarter(qtr);
                system.debug(qtr+'************qtr'+Utils.swapFiscalDateSections(qtr));
                lstOptions.add(new SelectOption(qtr, Utils.swapFiscalDateSections(qtr))); // value, label); 
            }
            return lstOptions;
        }
    }
    //End: lstPossibleQuarters method
    
    /* 
     * @Manideep - Opportunity RecordType Cleanup
    //PJENA: not sure where is it being used
    public void closePopup() {
    displayPopup = false;
    startingQuarter = null;
    }
  
  //PJENA: not sure where is it being used
  public void showPopup() {        
    displayPopup = true;    
    }  
    */
   
    /*
    Search for Pricebook Entries.  searchText has a value, search for PBEs whose name begins with that value.
    PJENA: it is being used from vf page in case of Tegra i.e., where IsTegraSBSPRecordtyp = true
    */
    /* 
     * @Manideep - Opportunity RecordType Cleanup
    //search action method
    public PageReference search(){
    // search() takes a Product name snippet and return a list of PricebookEntries with that prefix      
        pricebookId = PRICEBOOK2_ID;
        try {
      string strFieldNames = 'Id, UnitPrice, Product2.Family, Product2.Description, Product2.ProductCode,' + 
                                   'Product2.Name, Product2.Id, Name';
                        
            string soql = 'select Id, UnitPrice, Product2.Family, Product2.Description, Product2.ProductCode, ' + 
                          '       Product2.Name, Product2.Id, Name' + ' ' +
                          'from   PriceBookEntry ' +
                          'where  Pricebook2.id = :pricebookId ';

            if (searchText <> null && searchText <> '') {
                string newSearchText = searchText + '%';
                soql += ' and Name like :newSearchText';
            }
            
            soql += ' and IsActive = true';
            soql += ' order by Product2.Product_Sort_Order__c DESC, Name ';
            pbes = Database.query(soql);
    }catch (Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '' + ex );
            ApexPages.addMessage(msg);
        }
        return null;
    }
    //End: search action method
    */
        
    /*
      PJENA: it is being used from vf page in case of Tegra i.e., where IsTegraSBSPRecordtyp = true
    */
    //selectHelper method.
    /* 
     * @Manideep - Opportunity RecordType Cleanup
    public PageReference selectHelper() {
        // Keeping in place in case we add additional Record Types
        System.debug('===== selectedHelper = ' + selectedHelper);
        return null;
    }
    //End: selectHelper method.
    */
    
    //getAccount: getting account from Opportunity Id
    //pjena: not sure where it is being used
    /* 
     * @Manideep - Opportunity RecordType Cleanup 
    public PageReference getAccount(Id oppId) {
        if(account == null) {
            Opportunity tmpOpp = new Opportunity();
            tmpOpp = [Select AccountId from Opportunity where Id = :oppId];
            account = [Select Name from Account where Id = :tmpOpp.AccountId];
        }
        return null;
    }
    //End: getAccount: getting account from Opportunity Id
    */
    
    //selectProduct method
    /* 
      PJENA: it is being used from vf page in case of Tegra i.e., where IsTegraSBSPRecordtyp = true
    */
    /* 
     * @Manideep - Opportunity RecordType Cleanup 
    public PageReference selectProduct(){
        // selectProduct() takes the current row's PricebookEntry details and creates an entry on the (next) page
        try {
            // The caller passes us a parameter (via the query string) indicating the PBE ID they want
            String pbeId = ApexPages.currentPage().getParameters().get('selectedPbeId');
            selectedProductName = [select Name from PricebookEntry where id = :pbeId].name;
        } catch (Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '' + ex );
            ApexPages.addMessage(msg);
        }
        return null;
    }
    //End: selectProduct method
    */
    
    //RememberHelperInfo method
    /* 
    The user selected a Product and entered Quantity and ASP information for it.
  The selectedPbeId, selectedQuantity, and selectedASP variables describe what the user entered, and the selectedHelper variable tells us the index
    of the helper we need to update to remember the user's information.
    
  PJENA: it is being used from vf page in case of Tegra i.e., where IsTegraSBSPRecordtyp = true
    */
    /* 
     * @Manideep - Opportunity RecordType Cleanup 
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
    //End: RememberHelperInfo method
    */
    
    //hasProducts method
    // Does the page have any products defined?
    /* 
     * @Manideep - Opportunity RecordType Cleanup 
    public Boolean hasProducts(){
        for(OLIHelper olih : helpers) {
            OpportunityLineItem oli = olih.oli;
            if (oli.Monthly_Quantity__c <> 0 && oli.Monthly_Quantity__c <> null) {
                return true;
            }
        }              
        return false;
    }
    //End: hasProducts method
    */
    
    //PJENA-2016.09.12: Price Override
    /*
      If the current user is System Administrator or in the  Opportunity Re Engineering Details usernames or profiles then return true 
    */
    //isPriceOverrideAdmin
    @TestVisible private boolean isPriceOverrideAdmin(){
      boolean bPriceOverrideAdmin = false;
      if (userIsAdmin) bPriceOverrideAdmin = true; //if logged on user System Adminstrator then return true
      else {//Not System Admins but addes in Opportunity Re Engineering Details as "ASP Override Admin Profile(s)" or "ASP Override Admin User(s)"
        
        //check for usernames in custom settings
      if (string.isNotBlank(strASPOverrideAdminUsers)){
        if ( strASPOverrideAdminUsers.containsIgnoreCase(UserInfo.getUserName()) ){
          bPriceOverrideAdmin = true;
        }
      }
      
      //check for profiles in custom settings
      if ( !bPriceOverrideAdmin && string.isNotBlank(strASPOverrideAdminProfiles) ){
        map<Id, string> mapCSASPOverrideAdminProfiles = getProfsById(strASPOverrideAdminProfiles);
        if (mapCSASPOverrideAdminProfiles.get(UserInfo.getProfileId()) != null ){
          bPriceOverrideAdmin = true;
        }
      }
      
      }
      return bPriceOverrideAdmin;
    }
    //isPriceOverrideAdmin
    
    //getProfsById
  @TestVisible private map<Id, string> getProfsById(string strProfNames){
    map<Id, string> allProfsByName = new map<id, string>();
      list<Profile> lstProfs;
      string strSQL = '';
      if (strProfNames == null || strProfNames.trim() == ''){
        lstProfs = [Select Name From Profile];
      } else{
        list<string> lstProfNames = strProfNames.split(';');
        if (lstProfNames.size() == 1){
            lstProfs = [Select Name From Profile Where Name = :strProfNames];
        }else if (lstProfNames.size() > 1){
          string csProfNames = '(';
          for (integer i = 0; i < lstProfNames.size(); i++){
            if (i == lstProfNames.size()-1){//last prof name in the list - end with ")"
              csProfNames += '\'' + lstProfNames[i].trim() + '\')';
            }else{
              csProfNames += '\'' + lstProfNames[i].trim() + '\',';
            }
          }
          string strProfSOQL = 'Select Name From Profile Where Name in ' + csProfNames;
          system.debug('***strProfSOQL: ' + strProfSOQL);
          lstProfs = database.query(strProfSOQL);
        }
      }
      for (Profile prof : lstProfs){
        allProfsByName.put(prof.Id, prof.Name);
      }
      return allProfsByName;
    }
    //End: getProfsByName
    
    //End: PJENA-2016.09.12: Price Override
    
}