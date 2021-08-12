@isTest
private class NPN_Test_Surf_Ctrl {

    static User usr;
    static Contact con;
    static Account acc;
    static String accIdStr;
    static String program ='Service Delivery Partner';
    static String subprogram ='EDU Services';
    static Boolean isTransit = false;
    static void createUser() {
        User usr1 = [select id from user where id = :UserInfo.getUserId()];
        acc = new Account();
        acc.name = 'abcd1234';
        
        insert acc;

        accIdStr = String.valueOf(acc.Id);

        con = new Contact();
        con.firstName = 'abcd123 FName';
        con.lastName = 'abcd123 LName';
        con.email = 'xyz@bxw.com';
        con.accountId = acc.id;
        insert con;

        Profile profileId = [SELECT Id FROM Profile WHERE UserLicense.name = 'Partner Community Login' LIMIT 1];

        usr = new User(LastName = 'LIVESTON', FirstName='JASON', Alias = 'jliv', Email = 'test@test.com',
                       Username = 'test@test.com.sfdcstage1',
                       ProfileId = profileId.id,
                       TimeZoneSidKey = 'GMT',
                       LanguageLocaleKey = 'en_US',
                       EmailEncodingKey = 'UTF-8',
                       LocaleSidKey = 'en_US',
                       ContactId = con.id
                       );
        System.runAs(usr1) {
            insert usr;
        }
    }

    static testMethod void testIsTransitTrue() {
        createUser();
        System.runAs(usr) {
            SuRF_Transit__c trans = SuRF_Transit__c.getOrgDefaults();
            trans.isTransit__c = true;
            insert trans;
            SuRF_UpdateTime__c objSUT = new SuRF_UpdateTime__c();
            insert objSUT;
            SuRF_UpdateStart__c objSUS = new SuRF_UpdateStart__c();
            insert objSUS;
            SuRF_Contacts_and_Training_trans__c objSCT = new SuRF_Contacts_and_Training_trans__c(Account_ID__c = acc.id, Partner_Program__c= program,Partner_SubProgram__c = subprogram, Curriculum_Title__c='Compute DGX Sales Curriculum (2020)', Training_Record_Type__c='Sales');
            insert objSCT;
            SuRF_Contacts__c objSC = new SuRF_Contacts__c(Account_ID__c = acc.id);
            insert objSC;
            SuRF_Lead_Management_trans__c objSLM = new SuRF_Lead_Management_trans__c(Account_ID__c = acc.id);
            insert objSLM;
            SuRF_Opportunity_trans__c objSO = new SuRF_Opportunity_trans__c(Account_ID__c = acc.id, Partner_Program__c= program, Partner_SubProgram__c = subprogram);
            insert objSO;
            SuRF_Portal_Login_trans__c objSPL = new SuRF_Portal_Login_trans__c(Account_ID__c = acc.id);
            insert objSPL;
            SuRF_POS_trans__c objSPOS = new SuRF_POS_trans__c(Account_ID__c = acc.id, Partner_Program__c= program, Partner_SubProgram__c = subprogram);
            insert objSPOS;
            SuRF_Partner_Performance_Scorecard_trans__c objSPPS = new SuRF_Partner_Performance_Scorecard_trans__c(Account_ID__c = acc.id, Partner_Program__c= program, Partner_SubProgram__c = subprogram);
            insert objSPPS;
            SuRF_DGX_HOT_CPL_Contacts_Trans__c   objDHTCC = new SuRF_DGX_HOT_CPL_Contacts_Trans__c  (
                Account_Id__c = acc.Id,
                Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
                Partner_Program__c  = COMM_Constants.PA_PROGRAM_SP,
                Partner_Training_Compliance__c  = 1
            );            
            insert objDHTCC;
            SuRF_DGX_HOT_Compliance_Trans__c  objDHTC = new SuRF_DGX_HOT_Compliance_Trans__c  (Account_Id__c = acc.Id,
            Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Flag__c = 1);
            insert objDHTC;

            NPN_SuRF_Ctrl objNSC = new NPN_SuRF_Ctrl();

            isTransit = true;
            String loadPartnerScorecard = 'SELECT Account_Name__c, Competency__c, Level__c, Program_Signed_Date__c, Competency_Signed_Date__c, Region__c, PBM__c, Order__c, Flag__c, Category__c '
                                          +'FROM SuRF_Partner_Performance_Scorecard_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                                          +'ORDER BY Competency__c limit 40000';

            String loadPartnerContacts = 'SELECT Role__c, Phone_Number__c, Contact_Name__c, Email__c '
                                         +'FROM SuRF_Contacts_Trans__c WHERE Account_ID__c = accId '
                                         +'ORDER BY Role__c, Contact_Name__c limit 40000';
            String loadPartnerTraining = 'SELECT Competency__c, Type__c, ProductType__c, Curriculum_Title__c, Partner_Training_Compliance__c, Partner_Training_Required__c '
                                         +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Partner_Training_Required__c != \'Min: 0\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c != NULL '
                                         +'ORDER BY Competency__c, Type__c ASC limit 40000';
            String loadPartnerContactTraining = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c,Partner_Training_Compliance__c, Training_Completion_Status__c '
                                                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Account_ID__c = \''+accIdStr+'\' AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Training_Record_Type__c = \''
                                                +String.escapeSingleQuotes('Curriculum')
                                                +'\' ORDER BY Type__c, Contact_Name__c, Curriculum_Title__c,Training_Completion_Status__c limit 40000';
            String loadPartnerContactTrainingDrilldown = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c,Partner_Training_Compliance__c, Training_Completion_Status__c '
                                                         +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                                                         +'AND Curriculum_Title__c = curriculum AND Training_Record_Type__c = '
                                                         + String.escapeSingleQuotes('Curriculum')
                                                         + ' ORDER BY Contact_Name__c, Curriculum_Title__c limit 40000';
            String loadPartnerContactCourseTraining = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                                                      +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram' +
                                                      'AND Training_Record_Type__c = \''+String.escapeSingleQuotes('Course')
                                                      +'\' ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            String loadPartnerContactCourseTrainingDrilldown1 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                                                                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Training_Record_Type__c = \''
                                                                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Contact_Name__c = name '
                                                                +'ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            String loadPartnerContactCourseTrainingDrilldown2 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                                                                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Training_Record_Type__c = \''
                                                                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c = curriculum '
                                                                +'ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            String loadPartnerContactCourseTrainingDrilldown3 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                                                                +'FROM SuRF_Contacts_and_Training_Trans__c WHERE Training_Record_Type__c = \''
                                                                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                                                                +'AND Contact_Name__c = name AND Curriculum_Title__c = curriculum ORDER BY Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            String loadPartnerPortalLogin = 'SELECT Competency__c, Contact_Name__c, Login_Time__c '
                                            +'FROM SuRF_Portal_Login_Trans__c WHERE Account_ID__c = \''+accIdStr+'\' '
                                            +'ORDER BY Login_Time__c DESC, Contact_Name__c, Competency__c limit 40000';
            String loadPartnerPortalLoginDrilldown = 'SELECT Contact_Name__c, Login_Time__c '
                                                     +'FROM SuRF_Portal_Login_Trans__c WHERE Account_ID__c = \''+accIdStr+'\' AND Year__c = year AND Month__c = month '
                                                     +'ORDER BY Login_Time__c DESC, Contact_Name__c, Competency__c limit 40000';
            String loadPartnerPortalLoginDrilldown2 = 'SELECT Contact_Name__c, Login_Time__c FROM SuRF_Portal_Login_Trans__c '
                                                      +'WHERE Account_ID__c = \''+accIdStr+'\' AND Login_Time__c = LAST_N_DAYS:startTime AND Login_Time__c < LAST_N_DAYS:endTime '
                                                      +'ORDER BY Login_Time__c ASC, Contact_Name__c, Competency__c limit 40000';
            String loadPartnerOpportunity = 'SELECT Competency__c, Level__c, Target__c, Quantity__c, Stage__c, POS_Amount__c, Product__c, Probability__c '
                                            +'FROM SuRF_Opportunity_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program '
                                            +'ORDER BY Competency__c limit 40000';
            String loadPartnerLeadManagement = 'SELECT Lead_Status__c, Region__c FROM SuRF_Lead_Management_Trans__c WHERE Account_ID__c = \''+accIdStr+'\' ORDER BY Lead_Status__c limit 40000';
            String loadPartnerPOSSubmission = 'SELECT Submission_Date__c FROM SuRF_POS_Submission_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram ORDER BY Submission_Date__c DESC limit 40000';
            String loadPartnerPOS = 'SELECT Competency__c, Fiscal_Year_Quarter__c, Product_Code__c, Partner_POS_Revenue__c, POS_Quantity__c, Target__c, Target_Achieved__c '
                                    +'FROM SuRF_POS_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram ORDER BY Competency__c, Fiscal_Year_Quarter__c DESC limit 40000';
            String loadPartnerPrograms = 'SELECT Partner_Program__c, Partner_SubProgram__c FROM SuRF_Partner_Performance_Scorecard_Trans__c WHERE Account_ID__c = \''+accIdStr+'\' ORDER BY Partner_Program__c limit 40000';
            String loadDGXHOTComplianceContacts ='SELECT Account_ID__c,Account_Name__c,Competency__c,Contact_Name__c,Curriculum_Course_Title__c,Curriculum_Title__c,Due_Date__c,Email__c,Id,Name,Partner_Program__c,Partner_SubProgram__c,Partner_Training_Compliance__c,Partner_Training_Required__c,Phone_Number__c,ProductType__c,Role__c,Training_Compliance_Status__c,Training_Record_Type__c,Type__c FROM SuRF_DGX_HOT_CPL_Contacts_Trans__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
            +'ORDER BY Competency__c limit 40000'; // Added for SDS-3054
            String loadDGXHOTCompliance ='SELECT Category__c,Competency__c,Flag__c,Id,Order__c,Partner_Program_Name__c, Partner_Sub_Program__c FROM SuRF_DGX_HOT_Compliance_Trans__c WHERE Account_ID__c = accId AND Partner_Program_Name__c = program AND Partner_Sub_Program__c = subprogram '
            +'ORDER BY Competency__c limit 40000';  // added for SDS-3054
            NPN_SuRF_Ctrl.loadPartnerScorecard(program, subprogram, loadPartnerScorecard,accIdStr, isTransit);
            NPN_SuRF_Ctrl.loadPartnerContacts(program, loadPartnerContacts, accIdStr, isTransit);
            NPN_SuRF_Ctrl.loadPartnerTraining(program, subprogram,accIdStr,isTransit);
            NPN_SuRF_Ctrl.loadPartnerContactTraining(program, subprogram, accIdStr, isTransit);
            NPN_SuRF_Ctrl.loadPartnerContactTrainingDrilldown(program, subprogram,'', accIdStr, isTransit);
            //NPN_SuRF_Ctrl.loadPartnerContactCourseTraining(program, subprogram,loadPartnerContactCourseTraining, accIdStr, isTransit);
            NPN_SuRF_Ctrl.loadPartnerContactCourseTrainingDrilldown1( program,'abcd123 FName', subprogram, loadPartnerContactCourseTrainingDrilldown1, accIdStr, isTransit);
            NPN_SuRF_Ctrl.loadPartnerContactCourseTrainingDrilldown2(program,'xyz', subprogram, loadPartnerContactCourseTrainingDrilldown2, accIdStr, isTransit);
            NPN_SuRF_Ctrl.loadPartnerContactCourseTrainingDrilldown3(program,'abcd123 FName','xyz',subprogram, loadPartnerContactCourseTrainingDrilldown3, accIdStr,isTransit);
            NPN_SuRF_Ctrl.loadPartnerPortalLogin(loadPartnerPortalLogin, isTransit);
            NPN_SuRF_Ctrl.loadPartnerPortalLoginDrilldown(2014,12,loadPartnerPortalLoginDrilldown,isTransit);
            NPN_SuRF_Ctrl.loadPartnerPortalLoginDrilldown2(2014,01,2015,02,1,loadPartnerPortalLoginDrilldown2,isTransit);
            NPN_SuRF_Ctrl.loadPartnerOpportunity(program, loadPartnerOpportunity, accIdStr, isTransit);
            //NPN_SuRF_Ctrl.loadPartnerLeadManagement(loadPartnerContactCourseTraining, isTransit);
            NPN_SuRF_Ctrl.loadPartnerPOSSubmission(program, subprogram, loadPartnerPOSSubmission, accIdStr, isTransit);
            NPN_SuRF_Ctrl.loadPartnerPOS(program,subprogram, loadPartnerPOS, accIdStr, isTransit);
            objNSC.selectedSubProgram = subprogram;
            objNSC.populateSubPrograms();
            objNSC.getMonths();
            NPN_SuRF_Ctrl.loadDGXHOTCompliance(COMM_Constants.PA_PROGRAM_SP,null,loadDGXHOTCompliance, accIdStr,  isTransit);
            NPN_SuRF_Ctrl.loadDGXHOTComplianceContacts(COMM_Constants.PA_PROGRAM_SP, null, loadDGXHOTComplianceContacts, accIdStr, isTransit);
        }
    }
    /*static testMethod void testIsTransitFalse() {
            createUser();
            System.runAs(usr) {
                    SuRF_Transit__c trans = SuRF_Transit__c.getOrgDefaults();
                    trans.isTransit__c = false;
                    insert trans;
                    SuRF_UpdateTime__c objSUT = new SuRF_UpdateTime__c();
                    insert objSUT;
                    SuRF_Contacts__c objSC = new SuRF_Contacts__c(Account_ID__c = acc.id);
                    insert objSC;
                    SuRF_Contacts_and_Training__c objSCT = new SuRF_Contacts_and_Training__c(Account_ID__c = acc.id, Partner_Program__c='OEM');
                    insert objSCT;
                    SuRF_Lead_Management__c objSLM = new SuRF_Lead_Management__c(Account_ID__c = acc.id);
                    insert objSLM;
                    SuRF_Opportunity__c objSO = new SuRF_Opportunity__c(Account_ID__c = acc.id, Partner_Program__c='OEM');
                    insert objSO;
                    SuRF_Portal_Login__c objSPL = new SuRF_Portal_Login__c(Account_ID__c = acc.id);
                    insert objSPL;
                    SuRF_POS__c objSPOS = new SuRF_POS__c(Account_ID__c = acc.id, Partner_Program__c='OEM');
                    insert objSPOS;
                    SuRF_Partner_Performance_Scorecard__c objSPPS = new SuRF_Partner_Performance_Scorecard__c(Account_ID__c = acc.id, Partner_Program__c='OEM');
                    insert objSPPS;
                    NPN_SuRF_Ctrl objNSC = new NPN_SuRF_Ctrl();
                    NPN_SuRF_Ctrl.loadPartnerScorecard('OEM','','','',accIdStr, false);   //String program, String subprogram, String loadPartnerScorecard, String accId, Boolean isTransit
                    NPN_SuRF_Ctrl.loadPartnerContacts('OEM','',accIdStr,false); //String program, String loadPartnerContacts, String accId, Boolean isTransit
                    NPN_SuRF_Ctrl.loadPartnerTraining('OEM','',accIdStr,false); //String program, String subprogram, String accId, Boolean isTransit
                    NPN_SuRF_Ctrl.loadPartnerContactTraining('OEM');
                    NPN_SuRF_Ctrl.loadPartnerContactTrainingDrilldown('OEM','');
                    NPN_SuRF_Ctrl.loadPartnerContactCourseTraining('OEM');
                    NPN_SuRF_Ctrl.loadPartnerContactCourseTrainingDrilldown1('OEM','');
                    NPN_SuRF_Ctrl.loadPartnerContactCourseTrainingDrilldown2('OEM','');
                    NPN_SuRF_Ctrl.loadPartnerContactCourseTrainingDrilldown3('OEM','','');
                    NPN_SuRF_Ctrl.loadPartnerPortalLogin();
                    NPN_SuRF_Ctrl.loadPartnerPortalLoginDrilldown(2014,12);
                    NPN_SuRF_Ctrl.loadPartnerPortalLoginDrilldown2(2014,01,2015,02,1);
                    NPN_SuRF_Ctrl.loadPartnerOpportunity('OEM');
                    NPN_SuRF_Ctrl.loadPartnerLeadManagement();
                    NPN_SuRF_Ctrl.loadPartnerPOSSubmission('OEM');
                    NPN_SuRF_Ctrl.loadPartnerPOS('OEM');
                    NPN_SuRF_Ctrl.getMonths();
            }
       }*/

    static testMethod void testIsTransitFalse() {
        createUser();
        System.runAs(usr) {
            SuRF_Transit__c trans = SuRF_Transit__c.getOrgDefaults();
            trans.isTransit__c = false;
            insert trans;
            SuRF_UpdateTime__c objSUT = new SuRF_UpdateTime__c();
            insert objSUT;
            SuRF_Contacts__c objSC = new SuRF_Contacts__c(Account_ID__c = acc.id);
            insert objSC;
            SuRF_Contacts_and_Training__c objSCT = new SuRF_Contacts_and_Training__c(Account_ID__c = acc.id, Partner_Program__c= program,Partner_SubProgram__c = subprogram);
            insert objSCT;
            SuRF_Lead_Management__c objSLM = new SuRF_Lead_Management__c(Account_ID__c = acc.id);
            insert objSLM;
            SuRF_Opportunity__c objSO = new SuRF_Opportunity__c(Account_ID__c = acc.id, Partner_Program__c= program,Partner_SubProgram__c = subprogram);
            insert objSO;
            SuRF_Portal_Login__c objSPL = new SuRF_Portal_Login__c(Account_ID__c = acc.id);
            insert objSPL;
            SuRF_POS__c objSPOS = new SuRF_POS__c(Account_ID__c = acc.id,Partner_Program__c= program,Partner_SubProgram__c = subprogram);
            insert objSPOS;
            SuRF_Partner_Performance_Scorecard__c objSPPS = new SuRF_Partner_Performance_Scorecard__c(Account_ID__c = acc.id, Partner_Program__c= program,Partner_SubProgram__c = subprogram);
            insert objSPPS;
            SuRF_DGX_HOT_CPL_Contacts__c   objDHTCC = new SuRF_DGX_HOT_CPL_Contacts__c  (
                Account_Id__c = acc.Id,
                Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
                Partner_Program__c  = COMM_Constants.PA_PROGRAM_SP,
                Partner_Training_Compliance__c  = 1
            );            
            insert objDHTCC;
            SuRF_DGX_HOT_Compliance__c  objDHTC = new SuRF_DGX_HOT_Compliance__c  (Account_Id__c = acc.Id,
            Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Flag__c = 1);
            insert objDHTC;
            NPN_SuRF_Ctrl objNSC = new NPN_SuRF_Ctrl();

            isTransit = false;
            String loadPartnerScorecard = 'SELECT Account_Name__c, Competency__c, Level__c, Program_Signed_Date__c, Competency_Signed_Date__c, Region__c, PBM__c, Order__c, Flag__c, Category__c '
                                          +'FROM SuRF_Partner_Performance_Scorecard__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                                          +'ORDER BY Competency__c limit 40000';
            String loadPartnerContacts = 'SELECT Role__c, Phone_Number__c, Contact_Name__c, Email__c '
                                         +'FROM SuRF_Contacts__c WHERE Account_ID__c = accId '
                                         +'ORDER BY Role__c, Contact_Name__c limit 40000';
            String loadPartnerTraining = 'SELECT Competency__c, Type__c, ProductType__c, Curriculum_Title__c, Partner_Training_Compliance__c, Partner_Training_Required__c '
                                         +'FROM SuRF_Contacts_and_Training__c WHERE Partner_Training_Required__c !=\'Min: 0\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c != NULL '
                                         +'ORDER BY Competency__c, Type__c ASC limit 40000';
            String loadPartnerContactTraining = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c,  Partner_Training_Compliance__c,Training_Completion_Status__c '
                                                +'FROM SuRF_Contacts_and_Training__c WHERE Account_ID__c = \''+accIdStr+'\' AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Training_Record_Type__c = \''
                                                +String.escapeSingleQuotes('Curriculum')
                                                +'\' ORDER BY Type__c, Contact_Name__c, Curriculum_Title__c,Training_Completion_Status__c limit 40000';
            String loadPartnerContactTrainingDrilldown = 'SELECT Type__c, Contact_Name__c, Curriculum_Title__c, Training_Completion_Status__c,Partner_Training_Compliance__c '
                                                         +'FROM SuRF_Contacts_and_Training__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                                                         +'AND Curriculum_Title__c = curriculum AND Training_Record_Type__c = '
                                                         +String.escapeSingleQuotes('Curriculum')
                                                         +' ORDER BY Contact_Name__c, Curriculum_Title__c limit 40000';
            String loadPartnerContactCourseTraining = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                                                      +'FROM SuRF_Contacts_and_Training__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Training_Record_Type__c = \''
                                                      +String.escapeSingleQuotes('Course')
                                                      +'\' ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            String loadPartnerContactCourseTrainingDrilldown1 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                                                                +'FROM SuRF_Contacts_and_Training__c WHERE Training_Record_Type__c = \''
                                                                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Contact_Name__c = name '
                                                                +'ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            String loadPartnerContactCourseTrainingDrilldown2 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                                                                +'FROM SuRF_Contacts_and_Training__c WHERE Training_Record_Type__c = \''
                                                                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram AND Curriculum_Title__c = curriculum '
                                                                +'ORDER BY Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            String loadPartnerContactCourseTrainingDrilldown3 = 'SELECT Contact_Name__c, Curriculum_Title__c, Curriculum_Course_Title__c, Training_Completion_Status__c '
                                                                +'FROM SuRF_Contacts_and_Training__c WHERE Training_Record_Type__c = \''
                                                                +String.escapeSingleQuotes('Course')+'\' AND Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
                                                                +'AND Contact_Name__c = name AND Curriculum_Title__c = curriculum ORDER BY Curriculum_Title__c, Curriculum_Course_Title__c limit 40000';
            String loadPartnerPortalLogin = 'SELECT Competency__c, Contact_Name__c, Login_Time__c '
                                            +'FROM SuRF_Portal_Login__c WHERE Account_ID__c = \''+accIdStr+'\' '
                                            +'ORDER BY Login_Time__c DESC, Contact_Name__c, Competency__c limit 40000';
            String loadPartnerPortalLoginDrilldown = 'SELECT Contact_Name__c, Login_Time__c '
                                                     +'FROM SuRF_Portal_Login__c WHERE Account_ID__c = \''+accIdStr+'\' AND Year__c = year AND Month__c = month '
                                                     +'ORDER BY Login_Time__c DESC, Contact_Name__c, Competency__c limit 40000';
            String loadPartnerPortalLoginDrilldown2 = 'SELECT Contact_Name__c, Login_Time__c FROM SuRF_Portal_Login__c '
                                                      +'WHERE Account_ID__c = \''+accIdStr+'\' AND Login_Time__c = LAST_N_DAYS:startTime AND Login_Time__c < LAST_N_DAYS:endTime '
                                                      +'ORDER BY Login_Time__c ASC, Contact_Name__c, Competency__c limit 40000';
            String loadPartnerOpportunity = 'SELECT Competency__c, Level__c, Target__c, Quantity__c, Stage__c, POS_Amount__c, Product__c, Probability__c '
                                            +'FROM SuRF_Opportunity__c WHERE Account_ID__c = accId AND Partner_Program__c = program '
                                            +'ORDER BY Competency__c limit 40000';
            String loadPartnerLeadManagement = 'SELECT Lead_Status__c, Region__c FROM SuRF_Lead_Management__c WHERE Account_ID__c = \''+accIdStr+'\' ORDER BY Lead_Status__c limit 40000';
            String loadPartnerPOSSubmission = 'SELECT Submission_Date__c FROM SuRF_POS_Submission__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram ORDER BY Submission_Date__c DESC limit 40000';
            String loadPartnerPOS = 'SELECT Competency__c, Fiscal_Year_Quarter__c, Product_Code__c, Partner_POS_Revenue__c, POS_Quantity__c, Target__c, Target_Achieved__c '
                                    +'FROM SuRF_POS__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram ORDER BY Competency__c, Fiscal_Year_Quarter__c DESC limit 40000';
            String loadPartnerPrograms = 'SELECT Partner_Program__c, Partner_SubProgram__c FROM SuRF_Partner_Performance_Scorecard__c WHERE Account_ID__c = \''+accIdStr+'\' ORDER BY Partner_Program__c limit 40000';
            String loadPartnerContactCount = 'SELECT Contact_Name__c FROM SuRF_Contacts__c WHERE Account_ID__c = \''+accIdStr+'\' limit 40000';
            String loadDGXHOTComplianceContacts ='SELECT Account_ID__c,Account_Name__c,Competency__c,Contact_Name__c,Curriculum_Course_Title__c,Curriculum_Title__c,Due_Date__c,Email__c,Id,Name,Partner_Program__c,Partner_SubProgram__c,Partner_Training_Compliance__c,Partner_Training_Required__c,Phone_Number__c,ProductType__c,Role__c,Training_Compliance_Status__c,Training_Record_Type__c,Type__c FROM SuRF_DGX_HOT_CPL_Contacts__c WHERE Account_ID__c = accId AND Partner_Program__c = program AND Partner_SubProgram__c = subprogram '
            +'ORDER BY Competency__c limit 40000'; // Added for SDS-3054
            String loadDGXHOTCompliance ='SELECT Category__c,Competency__c,Flag__c,Id,Order__c,Partner_Program_Name__c, Partner_Sub_Program__c FROM SuRF_DGX_HOT_Compliance__c WHERE Account_ID__c = accId AND Partner_Program_Name__c = program AND Partner_Sub_Program__c = subprogram '
            +'ORDER BY Competency__c limit 40000';  // added for SDS-3054

            NPN_SuRF_Ctrl.loadPartnerScorecard(program, subprogram, loadPartnerScorecard,accIdStr, false);
            NPN_SuRF_Ctrl.loadPartnerContacts(program, loadPartnerContacts, accIdStr, false);
            NPN_SuRF_Ctrl.loadPartnerTraining(program, subprogram,accIdStr,false);
            NPN_SuRF_Ctrl.loadPartnerContactTraining(program, subprogram, accIdStr, false);
            NPN_SuRF_Ctrl.loadPartnerContactTrainingDrilldown(program, subprogram,'', accIdStr, false);
            //NPN_SuRF_Ctrl.loadPartnerContactCourseTraining(program, subprogram,loadPartnerContactCourseTraining, accIdStr, false);
            NPN_SuRF_Ctrl.loadPartnerContactCourseTrainingDrilldown1( program,'abcd123 FName', subprogram, loadPartnerContactCourseTrainingDrilldown1, accIdStr, false);
            NPN_SuRF_Ctrl.loadPartnerContactCourseTrainingDrilldown2(program,'xyz', subprogram, loadPartnerContactCourseTrainingDrilldown2, accIdStr, false);
            NPN_SuRF_Ctrl.loadPartnerContactCourseTrainingDrilldown3(program,'abcd123 FName','xyz',subprogram, loadPartnerContactCourseTrainingDrilldown3, accIdStr,false);
            NPN_SuRF_Ctrl.loadPartnerPortalLogin(loadPartnerPortalLogin, false);
            NPN_SuRF_Ctrl.loadPartnerPortalLoginDrilldown(2014,12,loadPartnerPortalLoginDrilldown,false);
            NPN_SuRF_Ctrl.loadPartnerPortalLoginDrilldown2(2014,01,2015,02,1,loadPartnerPortalLoginDrilldown2,false);
            NPN_SuRF_Ctrl.loadPartnerOpportunity(program, loadPartnerOpportunity, accIdStr, false);
            //NPN_SuRF_Ctrl.loadPartnerLeadManagement(loadPartnerContactCourseTraining, false);
            NPN_SuRF_Ctrl.loadPartnerPOSSubmission(program, subprogram, loadPartnerPOSSubmission, accIdStr, false);
            NPN_SuRF_Ctrl.loadPartnerPOS(program,subprogram, loadPartnerPOS, accIdStr, false);
            objNSC.selectedSubProgram = subprogram;
            objNSC.populateSubPrograms();
            objNSC.getMonths();
            NPN_SuRF_Ctrl.loadDGXHOTCompliance(COMM_Constants.PA_PROGRAM_SP,null,loadDGXHOTCompliance, accIdStr,  isTransit);
            NPN_SuRF_Ctrl.loadDGXHOTComplianceContacts(COMM_Constants.PA_PROGRAM_SP, null, loadDGXHOTComplianceContacts, accIdStr, isTransit);
        }
    }
}