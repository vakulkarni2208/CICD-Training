/**
 * This class is a common place to store all Service Cloud Specific Constants.
 * Created: 09/20/2019 - Akhilesh Gupta 
 * 2020.20.26 - Akhilesh Gupta 	- SDS-2064 - Updated Constructor to populate new properties, 
 								- make ServiceCloudSettings public which will avoid having one variable for each Constant
 * Steps to add New Constant:
    //- Create new fields in Metadata "Service_Cloud_Settings__mdt" (e.g. SLA_24x7Support_Label__c)
    //- Update Query: Add newly created field in the query 
    //- if needed add new public property in this class: (CUSTOMER_PROFILES) [SKIP this step for premetive datatypes e.g. SLA_24X7SUPPORT]
    //- 	Add logic to retrieve from metadata in constructor
    //- Example how to use in code: ESP_Utility.ESPConstants.SLA_24X7SUPPORT 
 */
 public class ESP_Constants { 
    public Set<string> CUSTOMER_PROFILES 	= NULL;//new Set<string>{'ESP Community User', 'NVES Community User Non-Admin','NPN Partner Community(LOGIN)','NPN Partner Community(NAMED)','NPN Tegra Jetson Partner Community(LOGIN)'};
    public Set<string> AGENT_PROFILES 		= NULL;//new Set<string>{'Service Cloud Generic User'};
    public Set<string> INTERNAL_USERTYPES 	= NULL;//new Set<string>{'Standard'};
    public string SLA_24X7SUPPORT 			= '24x7 Escalated Remote';
    //public static string SLA_BY_PROD_LINE 	= 'All with same Product Line';
    //public static string SLA_BY_SN 			= 'All with same Serial Number';
     
    public Service_Cloud_Settings__mdt ServiceCloudSettings = NULL;
    public SLA_Settings__mdt SLA_Settings = NULL;
	public Set<string> DESIGN_WIN_CASE_TEAM_ROLES = NULL; 
    //Future Enhancements: Convert below static variables to class variables same as above and update constructor.
    //- Update all the code which is using these static variables 
    //-- ESP_Utility.ESPConstants.SLA_24X7SUPPORT
    public static final boolean ACTIVE_ENTITLEMENTS_ONLY= FALSE;
    public static final string SUPPORT_PORTAL 			= 'Support Portal';
    public static final string LICENSING_PORTAL 		= 'Licensing Portal';
    public static final map<String, String> OBJECT_TO_ACTIVITY_TYPE_MAP 
    													= new map<String, String>{
															'Attachment'			=> 'Attachment', 
															'ContentDocumentLink'	=> 'Attachment', 
															'EmailMessage' 			=> 'Email Message', 
															'CaseComment' 			=> 'Case Comment'
														};
	
	private ESP_Constants(){
        if(ServiceCloudSettings == null)
            ServiceCloudSettings = [SELECT Id, MasterLabel, DeveloperName, TAM_Queue__c, Placeholder_Entitlement_Name__c
            							, Customer_Profile_Names__c, Agent_Profile_Names__c, Internal_User_Types__c
                                    	, SLA_24x7Support_Label__c, Case_Team_Roles_Design_Win__c, Disable_Trigger_Actions__c
                                    	, NVIDIA_Return_Account_ID__c, Default_Asset_Contact_ID__c, Link_All_Assets__c
                                    FROM Service_Cloud_Settings__mdt];
        
        if(SLA_Settings == NULL) 
            SLA_Settings = [SELECT Id, MasterLabel, DeveloperName 
                            	, Entitlement_Process_Name__c, SLA_By_Product_Line_Label__c, SLA_By_SN_Label__c
                            FROM SLA_Settings__mdt];
        
        SLA_24X7SUPPORT = ServiceCloudSettings.SLA_24x7Support_Label__c;
        //if(CUSTOMER_PROFILES == NULL) {
    		CUSTOMER_PROFILES = new Set<string>();
    		String cprofiles = ServiceCloudSettings.Customer_Profile_Names__c;
	    	if(!string.isEmpty(cprofiles))
	    		CUSTOMER_PROFILES.addAll(cprofiles.split(','));
    	//}
        //if(AGENT_PROFILES == NULL) {
    		AGENT_PROFILES = new Set<string>();
    		String aprofiles = ServiceCloudSettings.Agent_Profile_Names__c;
	    	if(!string.isEmpty(aprofiles))
	    		AGENT_PROFILES.addAll(aprofiles.split(','));
    	//}
        //if(INTERNAL_USERTYPES == NULL) {
    		INTERNAL_USERTYPES = new Set<string>();
    		String userTypes = ServiceCloudSettings.Internal_User_Types__c;
	    	if(!string.isEmpty(userTypes))
	    		INTERNAL_USERTYPES.addAll(userTypes.split(','));
    	//}
    	//Design_Win_Case_Team_Roles
    	Design_Win_Case_Team_Roles = new Set<string>();
        String caseRoles = ServiceCloudSettings.Case_Team_Roles_Design_Win__c;
        if(!string.isEmpty(caseRoles))
	    	DESIGN_WIN_CASE_TEAM_ROLES.addAll(caseRoles.split(','));
    }
	
	private static ESP_Constants ESP_Constants_instance = NULL;
    public static ESP_Constants getInstance() {
        
        if (ESP_Constants_instance == null)
            ESP_Constants_instance = new ESP_Constants();
        
        System.debug(ESP_Constants_instance.AGENT_PROFILES);
        System.debug(ESP_Constants_instance.CUSTOMER_PROFILES);
        System.debug(ESP_Constants_instance.INTERNAL_USERTYPES);
        System.debug(ESP_Constants_instance.DESIGN_WIN_CASE_TEAM_ROLES);
  		
        return ESP_Constants_instance;
    }
}