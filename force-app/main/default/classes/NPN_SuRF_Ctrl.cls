global without sharing class NPN_SuRF_Ctrl {
    //fields
    public Id accId {get; set;}
    public Id contactId {get;set;}
    public Decimal decAgreementMonth {get; set;}
    public Decimal decAgreementYear {get;set;}
    public String currentFiscalYear {get; set;}
    public String updateTime {get; set;}
    public Set<String> programSet {get; set;}
    public map<String,Set<String>> subProgramMap {get; set;}
    public List<SelectOption> programSelect {get; set;}
    public List<SelectOption> subProgramSelect {get; set;}
    public String defaultProgram {get; set;}
    public String defaultSubProgram {get; set;}
    public String selectedProgram {get; set;}
    public String selectedSubProgram {get; set;}
    public Boolean hasOneProgram {get; set;}
    public Boolean currentProgramHasOneSubProgram {get; set;}
    public Map<String,Integer> programContactCount {get; set;}
    public map<String, Boolean> mapProgramPOSRequirement {get; set;}
    public String strProgramPOSRequirement {get; set;}
    public map<String, set<String>> mapProgramCompetencyExemptPOS {get; set;}
    public map<String, Boolean> mapProgramCompetencyComplianceKey {get; set;}
    public Integer currentYear {get; set;}
    public Integer previousYear {get; set;}
    public String currentMonth {get; set;}
    public Integer contactCount{get;set;}
    public Integer currentFiscalQuarter{get;set;}
    public list<Partner_Attribute__c> lstPA {get; set;}
    
    public List<SelectOption> getMonths() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('January','January'));
        options.add(new SelectOption('February','February'));
        options.add(new SelectOption('March','March'));
        options.add(new SelectOption('April','April'));
        options.add(new SelectOption('May','May'));
        options.add(new SelectOption('June','June'));
        options.add(new SelectOption('July','July'));
        options.add(new SelectOption('August','August'));
        options.add(new SelectOption('September','September'));
        options.add(new SelectOption('October','October'));
        options.add(new SelectOption('November','November'));
        return options;
    }
    
    //global controller variables
    public Boolean isTransit {get; set;}
    public String loadPartnerScorecard{get; set;}
    public String loadPartnerContacts{get; set;}
    public String loadPartnerTraining{get; set;}
    public String loadPartnerContactTraining{get; set;}
    public String loadPartnerContactTrainingDrilldown{get; set;}
    public String loadPartnerContactCourseTraining{get; set;}
    public String loadPartnerContactCourseTrainingDrilldown1{get; set;}
    public String loadPartnerContactCourseTrainingDrilldown2{get; set;}
    public String loadPartnerContactCourseTrainingDrilldown3{get; set;}
    public String loadPartnerPortalLogin{get; set;}
    public String loadPartnerPortalLoginDrilldown{get; set;}
    public String loadPartnerPortalLoginDrilldown2{get; set;}
    public String loadPartnerOpportunity{get; set;}
    public String loadPartnerLeadManagement{get; set;}
    public String loadPartnerPOSSubmission{get; set;}
    public String loadPartnerPOS{get; set;}
    public String loadPartnerPrograms{get; set;}
    public String loadPartnerContactCount{get; set;}
    public String loadDGXHOTComplianceContacts{get; set;}   // Added for SDS-3054
    public String loadDGXHOTCompliance{get; set;}   // Added for SDS-3054
    public Map<Integer,String> monthMap{get; set;} 
    
    public NPN_Surf_Ctrl() {
        isTransit = SuRF_Transit__c.getOrgDefaults().isTransit__c;
        list<User> lstUser= [Select AccountId, Account.NPN_Program_Signed_Date__c from User where id =: Userinfo.getUserid()];
        if(lstUser.size() > 0) {
            accId = lstUser[0].AccountId;
            if(lstUser[0].Account.NPN_Program_Signed_Date__c != null) {
                decAgreementMonth = lstUser[0].Account.NPN_Program_Signed_Date__c.month()-1;
                decAgreementYear = lstUser[0].Account.NPN_Program_Signed_Date__c.year();
            }
        }
        contactId = [Select ContactId from User where id =: Userinfo.getUserid()].ContactId;        
        mapProgramPOSRequirement = new map<String, Boolean>();
        mapProgramCompetencyComplianceKey = new map<String, Boolean>();
        mapProgramCompetencyExemptPOS = new Map<String, set<String>>();
        List<NPN_Exempt_from_POS_Submission__mdt> lstNPNExemptPOSList = [SELECT Id, MasterLabel, Exempted_from_POS_Submission__c, Partner_Program_Name__c, Partner_Sub_Program__c, Partner_Competency__c, Program_Level__c from NPN_Exempt_from_POS_Submission__mdt];
        for(NPN_Exempt_from_POS_Submission__mdt objNPNExemptPOSList : lstNPNExemptPOSList) {
            objNPNExemptPOSList.Partner_Sub_Program__c = objNPNExemptPOSList.Partner_Sub_Program__c == null ? '' : objNPNExemptPOSList.Partner_Sub_Program__c;
            if(mapProgramCompetencyExemptPOS.containskey(objNPNExemptPOSList.Partner_Program_Name__c + objNPNExemptPOSList.Partner_Sub_Program__c)) {
               mapProgramCompetencyExemptPOS.get(objNPNExemptPOSList.Partner_Program_Name__c + objNPNExemptPOSList.Partner_Sub_Program__c).add(objNPNExemptPOSList.Partner_Competency__c);
            } else {
               mapProgramCompetencyExemptPOS.put(objNPNExemptPOSList.Partner_Program_Name__c + objNPNExemptPOSList.Partner_Sub_Program__c, new set<String>{objNPNExemptPOSList.Partner_Competency__c}); 
            }
        }
        List<NPN_POS_Submissions_ComplianceKey__mdt> lstNPNPOSKeyList = [SELECT Id, MasterLabel, Partner_Program_Name__c, Partner_Sub_Program__c, Partner_Competency__c, Program_Level__c from NPN_POS_Submissions_ComplianceKey__mdt];
        for(NPN_POS_Submissions_ComplianceKey__mdt objNPNPOSKeyList : lstNPNPOSKeyList) {
            objNPNPOSKeyList.Partner_Sub_Program__c = objNPNPOSKeyList.Partner_Sub_Program__c == null ? '' : objNPNPOSKeyList.Partner_Sub_Program__c;
            mapProgramCompetencyComplianceKey.put(objNPNPOSKeyList.Partner_Program_Name__c + objNPNPOSKeyList.Partner_Sub_Program__c + objNPNPOSKeyList.Partner_Competency__c + objNPNPOSKeyList.Program_Level__c, false);
        }
        lstPA = [select id, Partner_Program_Name__c, Partner_Sub_Program__c, Partner_Competency__c, Program_Level__c from Partner_Attribute__c where Account_Name__c = :accId and Date_Competency_Terminated__c = null];
        for(Partner_Attribute__c objPA : lstPA) {
            objPA.Partner_Sub_Program__c = objPA.Partner_Sub_Program__c == null ? '' : objPA.Partner_Sub_Program__c;
            /*if(mapProgramPOSRequirement.containskey(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c) && !mapProgramPOSRequirement.get(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c)) {
                if(!mapProgramCompetencyExemptPOS.containskey(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c) || !mapProgramCompetencyExemptPOS.get(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c).contains(objPA.Partner_Competency__c)) {
                    mapProgramPOSRequirement.put(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c, true);
                }
            } else {
                if(mapProgramCompetencyExemptPOS.containskey(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c) && mapProgramCompetencyExemptPOS.get(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c).contains(objPA.Partner_Competency__c)) {
                    mapProgramPOSRequirement.put(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c, false);
                } else {
                    mapProgramPOSRequirement.put(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c, true);
                }
            }*/
            if((!mapProgramPOSRequirement.containskey(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c) || !mapProgramPOSRequirement.get(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c)) && mapProgramCompetencyExemptPOS.containskey(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c) && mapProgramCompetencyExemptPOS.get(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c).contains(objPA.Partner_Competency__c)) {
                mapProgramPOSRequirement.put(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c, false);
            } else {
                mapProgramPOSRequirement.put(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c, true);
            }
        }
        for(Partner_Attribute__c objPA : lstPA) {           
            if(mapProgramCompetencyComplianceKey.containskey(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c + objPA.Partner_Competency__c + objPA.Program_Level__c)){
                mapProgramPOSRequirement.put(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c, mapProgramCompetencyComplianceKey.get(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c + objPA.Partner_Competency__c + objPA.Program_Level__c));
            } else {
                if(!mapProgramPOSRequirement.containskey(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c)) {
                    mapProgramPOSRequirement.put(objPA.Partner_Program_Name__c + objPA.Partner_Sub_Program__c, true);    
                }
            }
        }
        strProgramPOSRequirement = JSON.serialize(mapProgramPOSRequirement);        
        programSet = new Set<String>();
        subProgramMap = new map<String,Set<String>>();
        programContactCount = new Map<String,Integer>();
        if(isTransit) {
            loadPartnerScorecard = 'SELECT Account_Name__c, Competency__c, Level__c, Program_Signed_Date__c, Competency_Signed_Date__c, Region__c, PBM__c, Order__c, Flag__c, Category__c '
                +'FROM SuRF_Partner_Performance_Scorecard_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                +'ORDER BY Competency__c limit 40000';
            loadPartnerContacts = 'SELECT Role__c, Phone_Number__c, Contact_Name__c, Email__c '
                +'FROM SuRF_Contacts_Trans__c WHERE Account_ID__c = accId '
                +'ORDER BY Role__c, Contact_Name__c limit 40000';
            loadPartnerTraining = 'SELECT Competency__c, Type__c, ProductType__c, Curriculum_Title__c, Partner_Training_Compliance__c, Partner_Training_Required__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Partner_Training_Required__c != \'Min: 0\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c != NULL '
                +'ORDER BY Competency__c, Type__c ASC limit 40000';
             loadPartnerContactTraining = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c,Partner_Training_Compliance__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Account_ID__c = \''+accId+'\' AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Curriculum')
                +'\' ORDER BY Type__c, Contact_Name__c, Curriculum_Title__c,Training_Completion_Status__c limit 40000';
            loadPartnerContactTrainingDrilldown = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c,Partner_Training_Compliance__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                +'AND Curriculum_Title__c = curriculum AND Training_Record_Type__c = '
                + String.escapeSingleQuotes('Curriculum')
                + ' ORDER BY Contact_Name__c, Curriculum_Title__c limit 40000';
            loadPartnerContactCourseTraining = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Training_Record_Type__c = '
                +String.escapeSingleQuotes('Course')
                +' ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            loadPartnerContactCourseTrainingDrilldown1 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Contact_Name__c = name '
                +'ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            loadPartnerContactCourseTrainingDrilldown2 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c = curriculum '
                +'ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            loadPartnerContactCourseTrainingDrilldown3 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                +'AND Contact_Name__c = name AND Curriculum_Title__c = curriculum ORDER BY Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            loadPartnerPortalLogin = 'SELECT Competency__c, Contact_Name__c, Login_Time__c '
                +'FROM SuRF_Portal_Login_Trans__c WHERE Account_ID__c = \''+accId+'\' '
                +'ORDER BY Login_Time__c DESC, Contact_Name__c, Competency__c limit 40000';
            loadPartnerPortalLoginDrilldown = 'SELECT Contact_Name__c, Login_Time__c '
                +'FROM SuRF_Portal_Login_Trans__c WHERE Account_ID__c = \''+accId+'\' AND Year__c = year AND Month__c = month '
                +'ORDER BY Login_Time__c DESC, Contact_Name__c, Competency__c limit 40000';
            loadPartnerPortalLoginDrilldown2 = 'SELECT Contact_Name__c, Login_Time__c FROM SuRF_Portal_Login_Trans__c '
                +'WHERE Account_ID__c = \''+accId+'\' AND Login_Time__c = LAST_N_DAYS:startTime AND Login_Time__c < LAST_N_DAYS:endTime '
                +'ORDER BY Login_Time__c ASC, Contact_Name__c, Competency__c limit 40000';
            loadPartnerOpportunity = 'SELECT Competency__c, Level__c, Target__c, Quantity__c, Stage__c, POS_Amount__c, Product__c, Probability__c '
                +'FROM SuRF_Opportunity_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program '
                +'ORDER BY Competency__c limit 40000';
            loadPartnerLeadManagement = 'SELECT Lead_Status__c, Region__c FROM SuRF_Lead_Management_Trans__c WHERE Account_ID__c = \''+accId+'\' ORDER BY Lead_Status__c limit 40000';
            loadPartnerPOSSubmission = 'SELECT Submission_Date__c FROM SuRF_POS_Submission_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram ORDER BY Submission_Date__c DESC limit 40000';
            loadPartnerPOS = 'SELECT Competency__c, Fiscal_Year_Quarter__c, Product_Code__c, Partner_POS_Revenue__c, POS_Quantity__c, Target__c, Target_Achieved__c '
                +'FROM SuRF_POS_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram ORDER BY Competency__c, Fiscal_Year_Quarter__c DESC limit 40000';
            loadPartnerPrograms = 'SELECT Partner_Program__c, Partner_SubProgram__c FROM SuRF_Partner_Performance_Scorecard_Trans__c WHERE Account_ID__c = \''+accId+'\' ORDER BY Partner_Program__c limit 40000';
            loadPartnerContactCount = 'SELECT Contact_Name__c FROM SuRF_Contacts_Trans__c WHERE Account_ID__c = \''+accId+'\' limit 40000';
            loadDGXHOTComplianceContacts ='SELECT Account_ID__c,Account_Name__c,Competency__c,Contact_Name__c,Curriculum_Course_Title__c,Curriculum_Title__c,Due_Date__c,Email__c,Id,Name,Partner_Program__c,Partner_SubProgram__c,Partner_Training_Compliance__c,Partner_Training_Required__c,Phone_Number__c,ProductType__c,Role__c,Training_Compliance_Status__c,Training_Record_Type__c,Type__c FROM SuRF_DGX_HOT_CPL_Contacts_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
            +'ORDER BY Competency__c limit 40000'; // Added for SDS-3054
            loadDGXHOTCompliance ='SELECT Category__c,Competency__c,Flag__c,Id,Order__c,Partner_Program_Name__c, Partner_Sub_Program__c FROM SuRF_DGX_HOT_Compliance_Trans__c WHERE Account_ID__c = accId AND Partner_Program_Name__c = program AND Partner_Sub_Program__c = subprogram '
            +'ORDER BY Competency__c limit 40000';  // added for SDS-3054
            for(SuRF_Partner_Performance_Scorecard_Trans__c o : Database.query(loadPartnerPrograms)) {
                programSet.add(o.Partner_Program__c);
                if(subProgramMap.containsKey(o.Partner_Program__c)) {
                    subProgramMap.get(o.Partner_Program__c).add(o.Partner_SubProgram__c);
                } else {
                    subProgramMap.put(o.Partner_Program__c, new Set<String>{o.Partner_SubProgram__c});
                }
            }
            contactCount = Database.query(loadPartnerContactCount).size();
            for(String program : programSet) {
                Integer count = 0;
                Set<String> placementSet = new Set<String>();
                for(SuRF_Contacts_Trans__c o : Database.query(loadPartnerContactCount)) {
                    if(!placementSet.contains(o.Contact_Name__c)) {
                        placementSet.add(o.Contact_Name__c);
                        count++;
                    }
                }
                programContactCount.put(program,count);
            }
        }
        else {
            loadPartnerScorecard = 'SELECT Account_Name__c, Competency__c, Level__c, Program_Signed_Date__c, Competency_Signed_Date__c, Region__c, PBM__c, Order__c, Flag__c, Category__c '
                +'FROM SuRF_Partner_Performance_Scorecard__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                +'ORDER BY Competency__c limit 40000';
            loadPartnerContacts = 'SELECT Role__c, Phone_Number__c, Contact_Name__c, Email__c '
                +'FROM SuRF_Contacts__c WHERE Account_ID__c = accId '
                +'ORDER BY Role__c, Contact_Name__c limit 40000';
            loadPartnerTraining = 'SELECT Competency__c, Type__c, ProductType__c, Curriculum_Title__c, Partner_Training_Compliance__c, Partner_Training_Required__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Partner_Training_Required__c !=\'Min: 0\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c != NULL '
                +'ORDER BY Competency__c, Type__c ASC limit 40000';
            loadPartnerContactTraining = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c,  Partner_Training_Compliance__c,Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Account_ID__c = \''+accId+'\' AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Curriculum')
                +'\' ORDER BY Type__c, Contact_Name__c, Curriculum_Title__c,Training_Completion_Status__c limit 40000';
            loadPartnerContactTrainingDrilldown = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c, Training_Completion_Status__c,Partner_Training_Compliance__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                +'AND Curriculum_Title__c = curriculum AND Training_Record_Type__c = '
                +String.escapeSingleQuotes('Curriculum')
                +' ORDER BY Contact_Name__c, Curriculum_Title__c limit 40000';
            loadPartnerContactCourseTraining = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Course')
                +'\' ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            loadPartnerContactCourseTrainingDrilldown1 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Contact_Name__c = name '
                +'ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            loadPartnerContactCourseTrainingDrilldown2 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c = curriculum '
                +'ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            loadPartnerContactCourseTrainingDrilldown3 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                +'AND Contact_Name__c = name AND Curriculum_Title__c = curriculum ORDER BY Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            loadPartnerPortalLogin = 'SELECT Competency__c, Contact_Name__c, Login_Time__c '
                +'FROM SuRF_Portal_Login__c WHERE Account_ID__c = \''+accId+'\' '
                +'ORDER BY Login_Time__c DESC, Contact_Name__c, Competency__c limit 40000';
            loadPartnerPortalLoginDrilldown = 'SELECT Contact_Name__c, Login_Time__c '
                +'FROM SuRF_Portal_Login__c WHERE Account_ID__c = \''+accId+'\' AND Year__c = year AND Month__c = month '
                +'ORDER BY Login_Time__c DESC, Contact_Name__c, Competency__c limit 40000';
            loadPartnerPortalLoginDrilldown2 = 'SELECT Contact_Name__c, Login_Time__c FROM SuRF_Portal_Login__c '
                +'WHERE Account_ID__c = \''+accId+'\' AND Login_Time__c = LAST_N_DAYS:startTime AND Login_Time__c < LAST_N_DAYS:endTime '
                +'ORDER BY Login_Time__c ASC, Contact_Name__c, Competency__c limit 40000';
            loadPartnerOpportunity = 'SELECT Competency__c, Level__c, Target__c, Quantity__c, Stage__c, POS_Amount__c, Product__c, Probability__c '
                +'FROM SuRF_Opportunity__c WHERE Account_ID__c = accId AND Partner_Program__c = program '
                +'ORDER BY Competency__c limit 40000';
            loadPartnerLeadManagement = 'SELECT Lead_Status__c, Region__c FROM SuRF_Lead_Management__c WHERE Account_ID__c = \''+accId+'\' ORDER BY Lead_Status__c limit 40000';
            loadPartnerPOSSubmission = 'SELECT Submission_Date__c FROM SuRF_POS_Submission__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram ORDER BY Submission_Date__c DESC limit 40000';
            loadPartnerPOS = 'SELECT Competency__c, Fiscal_Year_Quarter__c, Product_Code__c, Partner_POS_Revenue__c, POS_Quantity__c, Target__c, Target_Achieved__c '
                +'FROM SuRF_POS__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram ORDER BY Competency__c, Fiscal_Year_Quarter__c DESC limit 40000';
            loadPartnerPrograms = 'SELECT Partner_Program__c, Partner_SubProgram__c FROM SuRF_Partner_Performance_Scorecard__c WHERE Account_ID__c = \''+accId+'\' ORDER BY Partner_Program__c limit 40000';
            loadPartnerContactCount = 'SELECT Contact_Name__c FROM SuRF_Contacts__c WHERE Account_ID__c = \''+accId+'\' limit 40000';
            loadDGXHOTComplianceContacts ='SELECT Account_ID__c,Account_Name__c,Competency__c,Contact_Name__c,Curriculum_Course_Title__c,Curriculum_Title__c,Due_Date__c,Email__c,Id,Name,Partner_Program__c,Partner_SubProgram__c,Partner_Training_Compliance__c,Partner_Training_Required__c,Phone_Number__c,ProductType__c,Role__c,Training_Compliance_Status__c,Training_Record_Type__c,Type__c FROM SuRF_DGX_HOT_CPL_Contacts__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
            +'ORDER BY Competency__c limit 40000'; // Added for SDS-3054
            loadDGXHOTCompliance ='SELECT Category__c,Competency__c,Flag__c,Id,Order__c,Partner_Program_Name__c, Partner_Sub_Program__c FROM SuRF_DGX_HOT_Compliance__c WHERE Account_ID__c = accId AND Partner_Program_Name__c = program AND Partner_Sub_Program__c = subprogram '
            +'ORDER BY Competency__c limit 40000';  // added for SDS-3054
            for(SuRF_Partner_Performance_Scorecard__c o : Database.query(loadPartnerPrograms)) {
                if(o.Partner_SubProgram__c == null)
                    o.Partner_SubProgram__c = '';
                programSet.add(o.Partner_Program__c);
                if(subProgramMap.containsKey(o.Partner_Program__c)) {
                    subProgramMap.get(o.Partner_Program__c).add(o.Partner_SubProgram__c);
                } else {
                    subProgramMap.put(o.Partner_Program__c, new Set<String>{o.Partner_SubProgram__c});
                }
            }
            contactCount = Database.query(loadPartnerContactCount).size();
            for(String program : programSet) {
                Integer count = 0;
                Set<String> placementSet = new Set<String>();
                for(SuRF_Contacts__c o : Database.query(loadPartnerContactCount)) {
                    if(!placementSet.contains(o.Contact_Name__c)) {
                        placementSet.add(o.Contact_Name__c);
                        count++;
                    }
                }
                programContactCount.put(program,count);
            }
        }
        currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        currentFiscalQuarter = [SELECT Number FROM Period WHERE Type = 'Quarter' AND StartDate <= TODAY AND EndDate >= TODAY].Number;
        Datetime timeUpdated = [SELECT Time_Updated__c FROM SuRF_UpdateTime__c LIMIT 1][0].Time_Updated__c;
        updateTime = 'Last Updated: ' + timeUpdated;
        programSelect = new List<SelectOption>();
        subProgramSelect = new List<SelectOption>();
        if(programSet.size() != 0) {
            defaultProgram = new List<String>(programSet)[0];
        }
        for(String program : programSet) {
            programSelect.add(new SelectOption(program,program));
        }
        if(programSet.size() < 2)
            hasOneProgram = true;
        else
            hasOneProgram = false;
        if(subProgramMap.containsKey(defaultProgram)) {
            if(subProgramMap.get(defaultProgram).size() > 1) {
                currentProgramHasOneSubProgram = false;
            } else {
                currentProgramHasOneSubProgram = true;
            }
            for(String subProgram : subProgramMap.get(defaultProgram)) {
                if(subProgram == null)
                    subProgram = ''; 
                defaultSubProgram = subProgram;
                selectedSubProgram = subProgram;
                subProgramSelect.add(new SelectOption(subProgram ,subProgram));
            }
        }
        currentYear = System.Today().year();
        previousYear = System.Today().year() - 1;
        monthMap = new Map<Integer,String>();
        monthMap.put(1,'January');
        monthMap.put(2,'February');
        monthMap.put(3,'March');
        monthMap.put(4,'April');
        monthMap.put(5,'May');
        monthMap.put(6,'June');
        monthMap.put(7,'July');
        monthMap.put(8,'August');
        monthMap.put(9,'September');
        monthMap.put(10,'October');
        monthMap.put(11,'November');
        monthMap.put(12,'December');
        currentMonth = monthMap.get(System.Today().month());
    } 
    
    public PageReference populateSubPrograms() {
        subProgramSelect = new List<SelectOption>();
        List<SelectOption> options = new List<SelectOption>();
        if(subProgramMap.containsKey(selectedProgram)){       
            if(subProgramMap.get(selectedProgram).size() > 1) {
                currentProgramHasOneSubProgram = false;
            } else {
                currentProgramHasOneSubProgram = true;
            }
            for(String subProgram : subProgramMap.get(selectedProgram)) {
                if(subProgram == null)
                    subProgram = ''; 
                subProgramSelect.add(new SelectOption(subProgram ,subProgram));
                selectedSubProgram = subProgram;
            }
        }
        
        system.debug('subProgramSelect=>'+subProgramSelect);
        system.debug('currentProgramHasOneSubProgram =>'+currentProgramHasOneSubProgram );
        system.debug('selectedProgram =>'+selectedProgram);
        return null;
    }   
    
    //remote action methods
    @RemoteAction
    global static SuRF_Partner_Performance_Scorecard__c[] loadPartnerScorecard(String program, String subprogram, String loadPartnerScorecard, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Partner_Performance_Scorecard__c> lst = new List<SuRF_Partner_Performance_Scorecard__c>();
            for(SuRF_Partner_Performance_Scorecard_Trans__c transObj : Database.query(loadPartnerScorecard.substringBefore('accId')+'\''+accId+'\''+loadPartnerScorecard.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerScorecard.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerScorecard.substringAfter('subprogram'))) {
                SuRF_Partner_Performance_Scorecard__c obj = new SuRF_Partner_Performance_Scorecard__c();
                obj.Account_Name__c = transObj.Account_Name__c;
                obj.Category__c = transObj.Category__c;
                obj.Competency__c = transObj.Competency__c;
                obj.Competency_Signed_Date__c = transObj.Competency_Signed_Date__c;
                obj.Flag__c = transObj.Flag__c;
                obj.Level__c = transObj.Level__c;
                obj.Order__c = transObj.Order__c;
                obj.PBM__c = transObj.PBM__c;
                obj.Program_Signed_Date__c = transObj.Program_Signed_Date__c;
                obj.Region__c = transObj.Region__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerScorecard.substringBefore('accId')+'\''+accId+'\''+loadPartnerScorecard.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerScorecard.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerScorecard.substringAfter('subprogram'));
    }
    @RemoteAction
    global static SuRF_Contacts__c[] loadPartnerContacts(String program, String loadPartnerContacts, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Contacts__c> lst = new List<SuRF_Contacts__c>();
            for(SuRF_Contacts_Trans__c transObj : Database.query(loadPartnerContacts.substringBefore('accId')+'\''+accId+'\''+loadPartnerContacts.substringAfter('accId'))) {
                SuRF_Contacts__c obj = new SuRF_Contacts__c();
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Email__c = transObj.Email__c;
                obj.Phone_Number__c = transObj.Phone_Number__c;
                obj.Role__c = transObj.Role__c;
                lst.add(obj);
            }
            return lst;
        } else {
            system.debug(loadPartnerContacts);
            return Database.query(loadPartnerContacts.substringBefore('accId')+'\''+accId+'\''+loadPartnerContacts.substringAfter('accId'));
        }
    }
    
    @RemoteAction
    global static SuRF_Contacts_and_Training__c[] loadPartnerTraining(String program, String subprogram, String accId, Boolean isTransit) {
        if(isTransit) {
             String loadPartnerTraining = 'SELECT Competency__c, Type__c, ProductType__c, Curriculum_Title__c, Partner_Training_Compliance__c, Partner_Training_Required__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Partner_Training_Required__c != \'Min: 0\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c != NULL '
                +'ORDER BY Competency__c, Type__c ASC limit 40000';
            List<SuRF_Contacts_and_Training__c> lst = new List<SuRF_Contacts_and_Training__c>();
            for(SuRF_Contacts_and_Training_Trans__c transObj : Database.query(loadPartnerTraining.substringBefore('accId')+'\''+accId+'\''+loadPartnerTraining.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerTraining.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerTraining.substringAfter('subprogram'))) {
                SuRF_Contacts_and_Training__c obj = new SuRF_Contacts_and_Training__c();
                obj.Competency__c = transObj.Competency__c;
                obj.Curriculum_Title__c = transObj.Curriculum_Title__c;
                obj.Partner_Training_Compliance__c = transObj.Partner_Training_Compliance__c;
                obj.Partner_Training_Required__c = transObj.Partner_Training_Required__c;
                obj.Type__c = transObj.Type__c;
                obj.ProductType__c = transObj.ProductType__c;
                lst.add(obj);
            }
            return lst;
        }
        else {
            String loadPartnerTraining = 'SELECT Competency__c, Type__c, ProductType__c, Curriculum_Title__c, Partner_Training_Compliance__c, Partner_Training_Required__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Partner_Training_Required__c !=\'Min: 0\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c != NULL '
                +'ORDER BY Competency__c, Type__c ASC limit 40000';
            return Database.query(loadPartnerTraining.substringBefore('accId')+'\''+accId+'\''+loadPartnerTraining.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerTraining.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerTraining.substringAfter('subprogram'));
        }
    }
    @RemoteAction
    global static SuRF_Contacts_and_Training__c[] loadPartnerContactTraining(String program, String subprogram, String accId, Boolean isTransit) {
        if(isTransit) {
            String loadPartnerContactTraining = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c,  Partner_Training_Compliance__c,Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Curriculum')
                +'\' ORDER BY Type__c, Contact_Name__c, Curriculum_Title__c,Training_Completion_Status__c limit 40000';
            List<SuRF_Contacts_and_Training__c> lst = new List<SuRF_Contacts_and_Training__c>();
            for(SuRF_Contacts_and_Training_Trans__c transObj : Database.query(loadPartnerContactTraining.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactTraining.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerContactTraining.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerContactTraining.substringAfter('subprogram'))) {
                SuRF_Contacts_and_Training__c obj = new SuRF_Contacts_and_Training__c();
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Curriculum_Title__c = transObj.Curriculum_Title__c;
                obj.Partner_Training_Compliance__c = transObj.Partner_Training_Compliance__c;
                obj.Training_Completion_Status__c = transObj.Training_Completion_Status__c;
                obj.Type__c = transObj.Type__c;
                lst.add(obj);
            }
            return lst;
        }
        else {
            String loadPartnerContactTraining = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c,  Partner_Training_Compliance__c,Training_Completion_Status__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Curriculum')
                +'\' ORDER BY Type__c, Contact_Name__c, Curriculum_Title__c,Training_Completion_Status__c limit 40000';
            return Database.query(loadPartnerContactTraining.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactTraining.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerContactTraining.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerContactTraining.substringAfter('subprogram'));
        }
    }
    @RemoteAction
    global static SuRF_Contacts_and_Training__c[] loadPartnerContactTrainingDrilldown(String program, String subprogram, String curriculum, String accId, Boolean isTransit) {
        if(isTransit) {
            String loadPartnerContactTrainingDrilldown = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c, Training_Completion_Status__c,Partner_Training_Compliance__c '
                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                +'AND Curriculum_Title__c = curriculum AND Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Curriculum')
                +'\' ORDER BY Contact_Name__c, Curriculum_Title__c limit 40000';
            List<SuRF_Contacts_and_Training__c> lst = new List<SuRF_Contacts_and_Training__c>();
            for(SuRF_Contacts_and_Training_Trans__c transObj : Database.query(loadPartnerContactTrainingDrilldown.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactTrainingDrilldown.substringAfter('accId').substringBefore('program')
                                                                              +'\''+program+'\''
                                                                              +loadPartnerContactTrainingDrilldown.substringAfter('program').substringBefore('subprogram')
                                                                              +'\''+subprogram+'\''
                                                                              +loadPartnerContactTrainingDrilldown.substringAfter('subprogram').substringBefore('curriculum')
                                                                              +'\''+curriculum+'\''
                                                                              +loadPartnerContactTrainingDrilldown.substringAfter('curriculum'))) {
                SuRF_Contacts_and_Training__c obj = new SuRF_Contacts_and_Training__c();
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Curriculum_Title__c = transObj.Curriculum_Title__c;
                obj.Training_Completion_Status__c = transObj.Training_Completion_Status__c;
                obj.Type__c = transObj.Type__c;
                lst.add(obj);
            }
            return lst;
        }
        else {
            String loadPartnerContactTrainingDrilldown = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c, Training_Completion_Status__c,Partner_Training_Compliance__c '
                +'FROM SuRF_Contacts_and_Training__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                +'AND Curriculum_Title__c = curriculum AND Training_Record_Type__c = \''
                +String.escapeSingleQuotes('Curriculum')
                +'\' ORDER BY Contact_Name__c, Curriculum_Title__c limit 40000';
            return Database.query(loadPartnerContactTrainingDrilldown.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactTrainingDrilldown.substringAfter('accId').substringBefore('program')
                                      +'\''+program+'\''
                                      +loadPartnerContactTrainingDrilldown.substringAfter('program').substringBefore('subprogram')
                                      +'\''+subprogram+'\''
                                      +loadPartnerContactTrainingDrilldown.substringAfter('subprogram').substringBefore('curriculum')
                                      +'\''+curriculum+'\''
                                      +loadPartnerContactTrainingDrilldown.substringAfter('curriculum'));
       }
    }
    @RemoteAction
    global static SuRF_Contacts_and_Training__c[] loadPartnerContactCourseTraining(String program, String subprogram, String loadPartnerContactCourseTraining, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Contacts_and_Training__c> lst = new List<SuRF_Contacts_and_Training__c>();
            for(SuRF_Contacts_and_Training_Trans__c transObj : Database.query(loadPartnerContactCourseTraining.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactCourseTraining.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerContactCourseTraining.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerContactCourseTraining.substringAfter('subprogram'))) {
                SuRF_Contacts_and_Training__c obj = new SuRF_Contacts_and_Training__c();
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Curriculum_Course_Title__c = transObj.Curriculum_Course_Title__c;
                obj.Curriculum_Title__c = transObj.Curriculum_Title__c;
                obj.Training_Completion_Status__c = transObj.Training_Completion_Status__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerContactCourseTraining.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactCourseTraining.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerContactCourseTraining.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerContactCourseTraining.substringAfter('subprogram'));
    }
    @RemoteAction
    global static SuRF_Contacts_and_Training__c[] loadPartnerContactCourseTrainingDrilldown1(String program, String name, String subprogram, String loadPartnerContactCourseTrainingDrilldown1, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Contacts_and_Training__c> lst = new List<SuRF_Contacts_and_Training__c>();
            for(SuRF_Contacts_and_Training_Trans__c transObj : Database.query(loadPartnerContactCourseTrainingDrilldown1.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactCourseTrainingDrilldown1.substringAfter('accId').substringBefore('program')
                                                                              +'\''+program+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown1.substringAfter('program').substringBefore('subprogram')
                                                                              +'\''+subprogram+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown1.substringAfter('subprogram').substringBefore('name')
                                                                              +'\''+name+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown1.substringAfter('name'))) {
                SuRF_Contacts_and_Training__c obj = new SuRF_Contacts_and_Training__c();
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Curriculum_Course_Title__c = transObj.Curriculum_Course_Title__c;
                obj.Curriculum_Title__c = transObj.Curriculum_Title__c;
                obj.Training_Completion_Status__c = transObj.Training_Completion_Status__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerContactCourseTrainingDrilldown1.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactCourseTrainingDrilldown1.substringAfter('accId').substringBefore('program')
                                      +'\''+program+'\''
                                      +loadPartnerContactCourseTrainingDrilldown1.substringAfter('program').substringBefore('subprogram')
                                      +'\''+subprogram+'\''
                                      +loadPartnerContactCourseTrainingDrilldown1.substringAfter('subprogram').substringBefore('name')
                                      +'\''+name+'\''
                                      +loadPartnerContactCourseTrainingDrilldown1.substringAfter('name'));
    }
    @RemoteAction
    global static SuRF_Contacts_and_Training__c[] loadPartnerContactCourseTrainingDrilldown2(String program, String curriculum, String subprogram, String loadPartnerContactCourseTrainingDrilldown2, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Contacts_and_Training__c> lst = new List<SuRF_Contacts_and_Training__c>();
            for(SuRF_Contacts_and_Training_Trans__c transObj : Database.query(loadPartnerContactCourseTrainingDrilldown2.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactCourseTrainingDrilldown2.substringAfter('accId').substringBefore('program')
                                                                              +'\''+program+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown2.substringAfter('program').substringBefore('subprogram')
                                                                              +'\''+subprogram+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown2.substringAfter('subprogram').substringBefore('curriculum')
                                                                              +'\''+curriculum+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown2.substringAfter('curriculum'))) {
                SuRF_Contacts_and_Training__c obj = new SuRF_Contacts_and_Training__c();
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Curriculum_Course_Title__c = transObj.Curriculum_Course_Title__c;
                obj.Curriculum_Title__c = transObj.Curriculum_Title__c;
                obj.Training_Completion_Status__c = transObj.Training_Completion_Status__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerContactCourseTrainingDrilldown2.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactCourseTrainingDrilldown2.substringAfter('accId').substringBefore('program')
                                      +'\''+program+'\''
                                      +loadPartnerContactCourseTrainingDrilldown2.substringAfter('program').substringBefore('subprogram')
                                      +'\''+subprogram+'\''
                                      +loadPartnerContactCourseTrainingDrilldown2.substringAfter('subprogram').substringBefore('curriculum')
                                      +'\''+curriculum+'\''
                                      +loadPartnerContactCourseTrainingDrilldown2.substringAfter('curriculum'));
    }
    @RemoteAction
    global static SuRF_Contacts_and_Training__c[] loadPartnerContactCourseTrainingDrilldown3(String program, String name, String curriculum, String subprogram, String loadPartnerContactCourseTrainingDrilldown3, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Contacts_and_Training__c> lst = new List<SuRF_Contacts_and_Training__c>();
            for(SuRF_Contacts_and_Training_Trans__c transObj : Database.query(loadPartnerContactCourseTrainingDrilldown3.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactCourseTrainingDrilldown3.substringAfter('accId').substringBefore('program')
                                                                              +'\''+program+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown3.substringAfter('program').substringBefore('subprogram')
                                                                              +'\''+subprogram+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown3.substringAfter('subprogram').substringBefore('name')
                                                                              +'\''+name+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown3.substringAfter('name').substringBefore('curriculum')
                                                                              +'\''+curriculum+'\''
                                                                              +loadPartnerContactCourseTrainingDrilldown3.substringAfter('curriculum'))) {
                SuRF_Contacts_and_Training__c obj = new SuRF_Contacts_and_Training__c();
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Curriculum_Course_Title__c = transObj.Curriculum_Course_Title__c;
                obj.Curriculum_Title__c = transObj.Curriculum_Title__c;
                obj.Training_Completion_Status__c = transObj.Training_Completion_Status__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerContactCourseTrainingDrilldown3.substringBefore('accId')+'\''+accId+'\''+loadPartnerContactCourseTrainingDrilldown3.substringAfter('accId').substringBefore('program')
                                      +'\''+program+'\''
                                      +loadPartnerContactCourseTrainingDrilldown3.substringAfter('program').substringBefore('subprogram')
                                      +'\''+subprogram+'\''
                                      +loadPartnerContactCourseTrainingDrilldown3.substringAfter('subprogram').substringBefore('name')
                                      +'\''+name+'\''
                                      +loadPartnerContactCourseTrainingDrilldown3.substringAfter('name').substringBefore('curriculum')
                                      +'\''+curriculum+'\''
                                      +loadPartnerContactCourseTrainingDrilldown3.substringAfter('curriculum'));
    }
    @RemoteAction
    global static SuRF_Portal_Login__c[] loadPartnerPortalLogin(String loadPartnerPortalLogin, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Portal_Login__c> lst = new List<SuRF_Portal_Login__c>();
            for(SuRF_Portal_Login_Trans__c transObj : Database.query(loadPartnerPortalLogin)) {
                SuRF_Portal_Login__c obj = new SuRF_Portal_Login__c();
                obj.Competency__c = transObj.Competency__c;
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Login_Time__c = transObj.Login_Time__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerPortalLogin);
    }
    @RemoteAction
    global static SuRF_Portal_Login__c[] loadPartnerPortalLoginDrilldown(Integer year, Integer month, String loadPartnerPortalLoginDrilldown, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Portal_Login__c> lst = new List<SuRF_Portal_Login__c>();
            for(SuRF_Portal_Login_Trans__c transObj : Database.query(loadPartnerPortalLoginDrilldown.substringBefore('year')
                                                                     +year
                                                                     +loadPartnerPortalLoginDrilldown.substringAfter('year').substringBefore('month')
                                                                     +month
                                                                     +loadPartnerPortalLoginDrilldown.substringAfter('month'))) {
                SuRF_Portal_Login__c obj = new SuRF_Portal_Login__c();
                obj.Competency__c = transObj.Competency__c;
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Login_Time__c = transObj.Login_Time__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerPortalLoginDrilldown.substringBefore('year')
                                  +year
                                  +loadPartnerPortalLoginDrilldown.substringAfter('year').substringBefore('month')
                                  +month
                                  +loadPartnerPortalLoginDrilldown.substringAfter('month'));
    }
    @RemoteAction
    global static SuRF_Portal_Login__c[] loadPartnerPortalLoginDrilldown2(Integer startYear, Integer startMonth, Integer endYear, Integer endMonth, Integer isCurrentMonthYear, String loadPartnerPortalLoginDrilldown2, Boolean isTransit) {
        Datetime startDate = Datetime.newInstance(startYear, startMonth, 1);
        Datetime endDate;
        if(isCurrentMonthYear == 1)
            endDate = Datetime.newInstance(endYear, endMonth, System.today().day());
        else
            endDate = Datetime.newInstance(endYear, endMonth, Date.daysInMonth(endYear, endMonth));
        Long startTime = (Datetime.now().getTime() / 86400000) - (startDate.getTime() / 86400000);
        Long endTime = (Datetime.now().getTime() / 86400000) - (endDate.getTime() / 86400000);
        if(isTransit) {
            List<SuRF_Portal_Login__c> lst = new List<SuRF_Portal_Login__c>();
            for(SuRF_Portal_Login_Trans__c transObj : Database.query(loadPartnerPortalLoginDrilldown2.substringBefore('startTime')
                                                                     +startTime
                                                                     +loadPartnerPortalLoginDrilldown2.substringAfter('startTime').substringBefore('endTime')
                                                                     +endTime
                                                                     +loadPartnerPortalLoginDrilldown2.substringAfter('endTime'))) {
                SuRF_Portal_Login__c obj = new SuRF_Portal_Login__c();
                obj.Competency__c = transObj.Competency__c;
                obj.Contact_Name__c = transObj.Contact_Name__c;
                obj.Login_Time__c = transObj.Login_Time__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerPortalLoginDrilldown2.substringBefore('startTime')
                                  +startTime
                                  +loadPartnerPortalLoginDrilldown2.substringAfter('startTime').substringBefore('endTime')
                                  +endTime
                                  +loadPartnerPortalLoginDrilldown2.substringAfter('endTime'));
    }
    @RemoteAction
    global static SuRF_Opportunity__c[] loadPartnerOpportunity(String program, String loadPartnerOpportunity, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Opportunity__c> lst = new List<SuRF_Opportunity__c>();
            for(SuRF_Opportunity_Trans__c transObj : Database.query(loadPartnerOpportunity.substringBefore('accId')+'\''+accId+'\''+loadPartnerOpportunity.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerOpportunity.substringAfter('program'))) {
                SuRF_Opportunity__c obj = new SuRF_Opportunity__c();
                obj.Competency__c = transObj.Competency__c;
                obj.Level__c = transObj.Level__c;
                obj.POS_Amount__c = transObj.POS_Amount__c;
                obj.Probability__c = transObj.Probability__c;
                obj.Product__c = transObj.Product__c;
                obj.Quantity__c = transObj.Quantity__c;
                obj.Stage__c = transObj.Stage__c;
                obj.Target__c = transObj.Target__c;
                lst.add(obj);
            }
            return lst;
        }
        else     
            return Database.query(loadPartnerOpportunity.substringBefore('accId')+'\''+accId+'\''+loadPartnerOpportunity.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerOpportunity.substringAfter('program'));
    }
    @RemoteAction
    global static SuRF_Lead_Management__c[] loadPartnerLeadManagement(String loadPartnerLeadManagement, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_Lead_Management__c> lst = new List<SuRF_Lead_Management__c>();
            for(SuRF_Lead_Management_Trans__c transObj : Database.query(loadPartnerLeadManagement)) {
                SuRF_Lead_Management__c obj = new SuRF_Lead_Management__c();
                obj.Lead_Status__c = transObj.Lead_Status__c;
                obj.Region__c = transObj.Region__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerLeadManagement);
    }
    @RemoteAction
    global static SuRF_POS_Submission__c[] loadPartnerPOSSubmission(String program, String subprogram, String loadPartnerPOSSubmission, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_POS_Submission__c> lst = new List<SuRF_POS_Submission__c>();
            for(SuRF_POS_Submission_Trans__c transObj : Database.query(loadPartnerPOSSubmission.substringBefore('accId')+'\''+accId+'\''+loadPartnerPOSSubmission.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerPOSSubmission.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerPOSSubmission.substringAfter('subprogram'))) {
                SuRF_POS_Submission__c obj = new SuRF_POS_Submission__c();
                obj.Submission_Date__c = transObj.Submission_Date__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerPOSSubmission.substringBefore('accId')+'\''+accId+'\''+loadPartnerPOSSubmission.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerPOSSubmission.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerPOSSubmission.substringAfter('subprogram'));
    }
    @RemoteAction
    global static SuRF_POS__c[] loadPartnerPOS(String program, String subprogram, String loadPartnerPOS, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_POS__c> lst = new List<SuRF_POS__c>();
            for(SuRF_POS_Trans__c transObj : Database.query(loadPartnerPOS.substringBefore('accId')+'\''+accId+'\''+loadPartnerPOS.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerPOS.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerPOS.substringAfter('subprogram'))) {
                SuRF_POS__c obj = new SuRF_POS__c();
                obj.Competency__c = transObj.Competency__c;
                obj.Fiscal_Year_Quarter__c = transObj.Fiscal_Year_Quarter__c;
                obj.Partner_POS_Revenue__c = transObj.Partner_POS_Revenue__c;
                obj.POS_Quantity__c = transObj.POS_Quantity__c;
                obj.Product_Code__c = transObj.Product_Code__c;
                obj.Target__c = transObj.Target__c;
                obj.Target_Achieved__c = transObj.Target_Achieved__c;
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadPartnerPOS.substringBefore('accId')+'\''+accId+'\''+loadPartnerPOS.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadPartnerPOS.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadPartnerPOS.substringAfter('subprogram'));
    }
    /*
    @RemoteAction
    global static void sendEmail() {
        String accountName = [select account.name from user where id =: USerInfo.getUserId()].account.Name;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Community_settings__c cs = Community_Settings__c.getInstance();
        String strErrorEmails  = 'vakulkarni@nvidia.com; bherlihy@nvidia.com';
        string[] toAddresses = strErrorEmails.split(';');
        for (integer i=0; i < toAddresses.size(); i++){
           toAddresses[i] = toAddresses[i].trim();
        }
        mail.setToAddresses(toAddresses);
        mail.setSubject('Request Contact - NPN Compliance tab on Portal');
        //build the email body
        String textBody = 'The following Account has requested to update their contacts: '+accountName;  
        //set html body
        mail.setPlainTextbody(textBody);      
            
        //send email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }*/

    
    //Added for SDS-3054
    @RemoteAction
    global static SuRF_DGX_HOT_CPL_Contacts__c [] loadDGXHOTComplianceContacts(String program, String subprogram, 
                            String loadDGXHOTComplianceContacts, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_DGX_HOT_CPL_Contacts__c> lst = new List<SuRF_DGX_HOT_CPL_Contacts__c>();
            for(SuRF_DGX_HOT_CPL_Contacts_Trans__c transObj : Database.query(loadDGXHOTComplianceContacts.substringBefore('accId')+'\''+accId+'\''+loadDGXHOTComplianceContacts.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadDGXHOTComplianceContacts.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadDGXHOTComplianceContacts.substringAfter('subprogram'))) {
                SuRF_DGX_HOT_CPL_Contacts__c obj = new SuRF_DGX_HOT_CPL_Contacts__c(
				Account_Id__c = transObj.Account_Id__c,
                Account_Name__c = transObj.Account_Name__c,
                Competency__c = transObj.Competency__c,
                Contact_Name__c = transObj.Contact_Name__c,
                Curriculum_Course_Title__c  = transObj.Curriculum_Course_Title__c,
                Curriculum_Title__c = transObj.Curriculum_Title__c,
                Due_Date__c = transObj.Due_Date__c,
                Email__c = transObj.Email__c,
                Partner_Program__c = transObj.Partner_Program__c,
                Partner_SubProgram__c = transObj.Partner_SubProgram__c,
                Partner_Training_Compliance__c = transObj.Partner_Training_Compliance__c,
                Partner_Training_Required__c = transObj.Partner_Training_Required__c,
                Phone_Number__c = transObj.Phone_Number__c,
                ProductType__c = transObj.ProductType__c,
                Role__c = transObj.Role__c,
                Training_Compliance_Status__c = transObj.Training_Compliance_Status__c,
                Training_Record_Type__c = transObj.Training_Record_Type__c,
                Type__c = transObj.Type__c);
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadDGXHOTComplianceContacts.substringBefore('accId')+'\''+accId+'\''+loadDGXHOTComplianceContacts.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadDGXHOTComplianceContacts.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadDGXHOTComplianceContacts.substringAfter('subprogram'));
    }

    //Added for SDS-3054
    @RemoteAction
    global static SuRF_DGX_HOT_Compliance__c [] loadDGXHOTCompliance(String program, String subprogram, 
            String loadDGXHOTCompliance, String accId, Boolean isTransit) {
        if(isTransit) {
            List<SuRF_DGX_HOT_Compliance__c> lst = new List<SuRF_DGX_HOT_Compliance__c>();
            for(SuRF_DGX_HOT_Compliance_Trans__c transObj : Database.query(loadDGXHOTCompliance.substringBefore('accId')+'\''+accId+'\''+loadDGXHOTCompliance.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadDGXHOTCompliance.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadDGXHOTCompliance.substringAfter('subprogram'))) {
                SuRF_DGX_HOT_Compliance__c obj = new SuRF_DGX_HOT_Compliance__c(
                Account_Id__c = transObj.Account_Id__c,
                Account_Name__c = transObj.Account_Name__c,
                Competency__c = transObj.Competency__c,
                Flag__c = transObj.Flag__c,
                Partner_Program_Name__c = transObj.Partner_Program_Name__c,
                Partner_Sub_Program__c = transObj.Partner_Sub_Program__c,
                Order__c = transObj.Order__c);
                lst.add(obj);
            }
            return lst;
        }
        else
            return Database.query(loadDGXHOTCompliance.substringBefore('accId')+'\''+accId+'\''+loadDGXHOTCompliance.substringAfter('accId').substringBefore('program')+'\''+program+'\''+loadDGXHOTCompliance.substringAfter('program').substringBefore('subprogram')+'\''+subprogram+'\''+loadDGXHOTCompliance.substringAfter('subprogram'));
    }
}