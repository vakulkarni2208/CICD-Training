/*
   Constants used in Community (NV Customer/Partner Portal) related classes
   2016.04.01 - Changes for Inception Partners

   2016.08.26 - PJ-25352 - Change of Account record type ACCOUNT_RT_PARTNER_ACCOUNT from Partner Account to Partner Customer Account
   - 2016.08.26: Reverted back to Partner Account after Greg wanted to test the reports.

   2016.08.24: Retrofitting of Opportunity creation with Primary Contact and Contact Role to avoid being caught up with validation rule

   2016.10.03 - Services Subcontractors related changes

   2016.12.14 - Opp Registration TAM - interim change

   2017.01.23 - Workday User Sync related Constants

   2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
   Opp Reg submission types

   2017.03.16 - TAM and Manager Validation

   2017.03.27 - CV to GV changes

   2017.04.07 - DL Changes

   2017.05.24 - PEJNA - Log A Support Problem, Ask A Question subject changes

   2017.06.21 - Test class retrofit during MDF v1/v2 code cleanup

   2018.02.05 - Remove the following logics which does not have any relevance now
   GEO Area logic,
   Setting legacy audit fields, Cloned Opportunity Created Date Bug Fix
   setForecastCategoryName

   2019.03.29 - RKAMBLE - added few values for Test classes optimization.

   2019.06.12 - RKAMBLE - added Industry GG for SDS-1307
   2019-11-15 - RKAMBLE - added string for NFR SW License Request permission set. SDS-1808
   2019.12.06 - PJENA - Licensing 2.0 text class fix. Test_Contact_tgr_cls was failing as the reference to Account record type "NV Customer Account" was not removed while the record type got deleted
   2020-01-09 - RKAMBLE - added string for Entitlements permission set. SDS-1920
   2020-01-13 - RKAMBLE - added string for NPN Submit POS permission set. SDS-1958
   2020-03-13 - RKAMBLE - Changes for PPG & GG values automation

   2020-07-01 - Manideep : SDS-2277 - added new Lead Product Type 'Embedded'.
   2020-07-26 - RKAMBLE	-	SDS-2058 - Competency Rename Changes
   2020-10-05 - RKAMBLE	-	SDS-2707 - Portal Lite Training Only Partners changes
 */

public class COMM_Constants {

//LEAD Origins
public static final string LEAD_ORIGIN_EMEAI_TRAINING_WEB_FORM = 'EMEAI Training Web Form';
public static final string LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM = 'NPN Community Web Form';
public static final string LEAD_ORIGIN_NPN_APPLICATION = 'NPN Application';

//ACCOUNT Record Types
public static final string ACCOUNT_RT_NPN_COMMUNITY = 'NPN Community Account';
public static final string ACCOUNT_RT_EMEAI_TRAINING = 'EMEAI Training Account';
public static final string ACCOUNT_RT_NV_PPA = 'NPN Account Registry';   //used in test class //NV Partner Program Account
public static final string ACCOUNT_RT_NV_CUSTOMER = 'New Customer Account';   //used in test class //NV Customer Account
public static final string ACCOUNT_RT_NPN_ACCOUNT_REGISTRY = 'NPN Account Registry';
public static final string ACCOUNT_RT_PARTNER_ACCOUNT =  'Partner Account';  //used in test class
public static final string ACCOUNT_RT_NEW_CUSTOMER = 'New Customer Account';

//LEAD Record Types
public static final string LEAD_RT_EMEAI_TRAINING = 'EMEAI Training';
public static final string LEAD_RT_NPN_WEB_ONBOARD_FORM = 'NPN Web Onboard Form';
public static final string LEAD_RT_PARTNER_LEAD = 'Partner Lead';   //user in test class Test_Opportunity_tgr_cls
public static final string LEAD_RT_TESLA_SALES_LEAD = 'Tesla Sales Lead';   //user in test class Test_Lead_Tgr_cls
public static final string LEAD_RT_ENTERPRISE_CUSTOMER_LEAD = 'Enterprise Customer Lead';   //user in test class Test_Lead_Tgr_cls
public static final string LEAD_RT_PREMQL_LEAD = 'Pre-MQL Lead';   //used in Lead trigger for Leadspace L2A
public static final string LEAD_RT_Automotive_LEAD = 'Automotive Lead';   // used in Lead trigger for Automotive validaiton

//CONTACT Record Types
public static final string CONTACT_RT_PARTNER_CONTACT = 'Partner Contact';
public static final string CONTACT_RT_SALES_CONTACT = 'Sales Contact';

//OPPTY Recoprd Types
public static final string OPPTY_RT_TESLA_PARTER_OPPTY = 'Tesla Partner Opportunity';
public static final string OPPTY_RT_GRID_PARTER_OPPTY = 'GRID Partner Opportunity';
public static final string OPPTY_RT_QUADRO_PARTER_OPPTY = 'Quadro Partner Opportunity';
public static final string OPPTY_RT_TESLA_INTERNAL_OPPTY = 'Tesla Sales Opportunity';
public static final string OPPTY_RT_GRID_INTERNAL_OPPTY = 'GRID Sales Opportunity';
public static final string OPPTY_RT_QUADRO_INTERNAL_OPPTY = 'Quadro Sales Opportunity';
public static final string OPPTY_RT_ES_INTERNAL_OPPTY = 'Enterprise Sales Opportunity';
public static final string OPPTY_RT_AUTOMOTIVE_INTERNAL_OPPTY = 'Automotive Opportunity';
public static final string OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY = 'Tegra Embedded Partner Opportunity';

//Deal Registration: OPPTY Record Types
public static final string OPPTY_RT_GRID_PARTNER_DEAL = 'GRID Partner Deal';
public static final string OPPTY_RT_QUADRO_PARTNER_DEAL = 'QUADRO Partner Deal';
public static final string OPPTY_RT_TESLA_PARTNER_DEAL = 'TESLA Partner Deal';


//Embedded Entertainment Opportunity
public static final string OPPTY_RT_EMB_ENT_OPPTY = 'Embedded Entertainment Opportunity';

//Oppty Stages
public static final string OPPTY_STAGE_QUAL = 'Qualification';
public static final string OPPTY_STAGE_PROSPECTING = 'Prospecting';
public static final string OPPTY_STAGE_CLOSEDWON = 'Closed Won';
public static final string OPPTY_STAGE_CLOSEDLOST = 'Closed Lost';

//Opportunity Price Books
public static final string PB_GRID_PARTNER = 'GRID Partner Price Book';
public static final string PB_TESLA_INTERNAL = 'Tesla Price Book';
public static final string PB_EMB_ENT = 'Embedded Entertainment Price Book';


//CONTACT GPU_Genius_Groups__c field options
public static final string CON_GPUGNS_GRP_LJETSON = 'Learning Jetson:5879418';   //Added by Rajat for PPG and GG values automation.
//public static final string CON_GPUGNS_GRP_LIND = 'Learning Industry:5877534'; //Commented by Rajat for PPG and GG values automation.
public static final string CON_GPUGNS_GRP_LNPNCOMM = 'Learning NPN Community:4997879';
public static final string CON_GPUGNS_GRP_LEMEAINVEMP = 'Learning EMEAI NVEP:4995860';
public static final string CON_GPUGNS_GRP_LDPLRN = 'Learning DGX:5753092';
public static final string CON_GPUGNS_GRP_LTPP = 'Learning TPP:3200491';
public static final string CON_GPUGNS_GRP_LNPNACS = 'NPN High Performance Computing Sales:5642753';
public static final string CON_GPUGNS_GRP_LNPNACT = 'NPN High Performance Computing Technical:5642754';
public static final string CON_GPUGNS_GRP_LNPNCVS = 'NPN Cloud Virtualization Sales:5642755';
public static final string CON_GPUGNS_GRP_LNPNCVT = 'NPN Cloud Virtualization Sales:5642755';
public static final string CON_GPUGNS_GRP_LNPNPVS = 'NPN Professional Visualization Sales:5642757';
public static final string CON_GPUGNS_GRP_LNPNPVT = 'NPN Professional Visualization Technical:5642758';
public static final string CON_GPUGNS_GRP_LGRD = 'Learning GRID:2965513';
public static final string CON_GPUGNS_GRP_LQDRO = 'Learning Quadro:4320588';

//Default Content Type for Contact
public static final string CON_DEFAULT_CONTENT_TYPE_NPN = 'Community';
public static final string CON_DEFAULT_CONTENT_TYPE_EMEAI = 'NVEP';

//Portal Lite user Permission Set group name
public static final string CON_PSANDGROUP_NVEP = 'NVEP';
public static final string CON_PSANDGROUP_COMMUNITY = 'Community';
public static final string CON_PSANDGROUP_PORTAL_LITE = 'Portal Lite';
public static final string CON_PSANDGROUP_INCEPTION_PARTNERS = 'IP Portal Lite';
public static final string CON_PSANDGROUP_MDFV2 = 'MDF';
public static final string CON_PSANDGROUP_MDFV3 = 'MDFV3';
//2016.10.03 - Services Subcontractors related changes
public static final string CON_PSANDGROUP_SERVICESSUBCONTRACTORS = 'Services Subcontractor';
public static final string CON_PSANDGROUP_TRAINING_ONLY = 'Portal Lite Training Only';	// Added for SDS-2707

//USER name extensions
public static final string USRNAME_EXTN_EMEAI_TRAIN = '.nvemeaitrain';
public static final string USRNAME_EXTN_NPN_COMM = '.nvnpncomm';

//PROFILES
//public static final string PROF_CP_QPP_GENERIC = 'QPP Customer Portal Profile(Generic)';
public static final string PROF_CP_QPP_GENERIC = 'Community Lite Profile';

//2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
//All the earlier partner profiles will no longer exist, so all these constants are set with one of the available partner community profiles [NPN Partner Community(LOGIN) or NPN Partner Community(NAMED)]
//public static final string PROF_PP_TPP_GENERIC = 'Tesla Partner Portal Profile(Generic)'; //used in test class
//public static final string PROF_PP_VCA_GENERIC = 'GRID VCA Partner Portal Profile(Generic)'; //used in test class
//public static final string PROF_PP_VGX_GENERIC = 'GRID VGX Partner Portal Profile(Generic)'; //used in test class
public static final string PROF_PP_TPP_GENERIC = 'NPN Partner Community(LOGIN)';   //used in test class
public static final string PROF_PP_VCA_GENERIC = 'NPN Partner Community(LOGIN)';   //used in test class
public static final string PROF_PP_VGX_GENERIC = 'NPN Partner Community(LOGIN)';   //used in test class

public static final string PROF_INT_PARTNER_ADMIN = 'Sales Profile - Partner Admin';   //used in test class
public static final string PROF_INT_NVINTERNALCRMGENERIC = 'NVInternalCRMGeneric';   //2017.01.23 - Workday User Sync related Constant - used in test class

//SFDC User attributes
public static final string USER_ALIAS = 'Training';
public static final string USER_EMAILENCODEKEY = 'UTF-8';
public static final string USER_LANGLOCALEKEY = 'en_US';
public static final string USER_LOCALESIDKEY = 'en_US';
public static final string USER_TZSIDKEY = 'America/Los_Angeles';

//PUBLIC GROUPs
public static final string PG_EMEAI_TRAINING_USERS = 'EMEAI Training Users';
public static final string PG_COMM_CONTENT = 'Community Content';

//SObject Names
public static final string SOBJECT_ACCOUNT = 'Account';
public static final string SOBJECT_CONTACT = 'Contact';
public static final string SOBJECT_LEAD = 'Lead';
public static final string SOBJECT_OPPORTUNITY = 'Opportunity';

//Portal Permission Sets
public static final string PS_PORTAL_NV_CONTACTS_BOX = 'PP_NV_CONTACTS_BOX';
public static final string PS_PORTAL_PP_QPP_HOME_TAB = 'PP_COMM_LITE_HOME_TAB';
public static final string PS_PORTAL_PP_QPP_SALES_TOOLS_BOX = 'PP_QPP_SALES_TOOLS_BOX';
public static final string PS_PORTAL_PP_QPP_NPN_RESOURCES = 'PP_COMM_LITE_NPN_RESOURCES';
public static final string PS_PORTAL_PP_NPN_NFR_Request = 'PP_NPN_NFR_Request';   // Added for SDS-1808
public static final string PS_PORTAL_PP_Channel_Portal_Access = 'PP_Channel_Portal_Access';   // Added for SDS-1920
public static final string PS_PORTAL_PP_NPN_Submit_POS = 'PP_NPN_Submit_POS';   // Added for SDS-1958

//MDF Permission Sets
public static final string PS_MKTG_MDF_PORTAL_READ_CHANNEL = 'MKTG_MDF_Portal_READ_CHANNEL';
public static final string PS_MKTG_MDF_PORTAL_UPDATE = 'MKTG_MDF_Portal_UPDATE';
public static final string PS_MKTG_MDFV3_VIEWER = 'MKTG_MDFV3_VIEWER';

//Lead Converted Status
public static final string LEAD_CONVERTED_STATUS_CTA = 'Convert to Account';

//Brainshark URL - Better to be put in a Custom Settings
//public static final string BRAINSHARK_URL = 'https://staging.brainshark.com/portal/psapis/api/psSession.aspx';
//public static final string BRAINSHARK_URL = 'https://www.brainshark.com/portal/psapis/api/psSession.aspx'; //Custom Settings

public static final string CON_PPG_COMMUNITY = 'Community';   //used in the test class
public static final integer NUM_RECS_TO_TEST = 10;   //used in the test classs. It can be anything. Higher the number, longer the test classes takes to complete


//User Licenses
public static final string USERLICENSE_CP_OCPMC = 'Overage Customer Portal Manager Custom';
public static final string USERLICENSE_PP_GP = 'Gold Partner';

//Partner Portal Home Page related Constants
public static final string EMAILID_GRID_VCA_PARTNER_NV = 'GRID_VCA_partner@nvidia.com';
public static final string PROFILE_CATEGORY_SALES = 'Sales';
public static final string PROFILE_CATEGORY_TECHNICAL = 'Technical';
public static final string PROFILE_CATEGORY_MARKETING = 'Marketing';
public static final string PROFILE_MANAGER = 'Manager';

public static final string PP_MANAGER_CHARTS = 'PP_MANAGER_CHARTS';
public static final string PP_OWNER_CHARTS = 'PP_OWNER_CHARTS';

//Portal Instance Messages related

//public static final string PIM_PSG_SPCVP = 'SP Graphics Virtualization Preferred'; //used in testing
//2017.06.21 - Test class retrofit during MDF v1/v2 code cleanup
//public static final string PIM_PSG_SPCVP = 'SP GPU Virtualization Preferred'; //used in testing  /// COMMENTED BY RAJAT
public static final string PIM_PSG_SPCVP = 'SP vGPU Preferred';   // Added by RAJAT
public static final string PIM_COUNTRY_US = 'United States';   //used in testing
public static final string PIM_COUNTRY_INVALID = 'United States of Invalids';   //just an invalid country name for testing

public static final string PP_GRID_VCA_NAME = 'GRID_VCA_Partner Portal';   //only one Partner Portal has so far in Parnter_Portal__c
public static final string BOX_REPORTAPROBLEMBTN = 'REPORT A PROBLEM BUTTON';
public static final string TAB_SUPPORT = 'Support';
public static final string BOX_PRESENTAIONTYPE_NVIDIA_CONTACTS = 'NVIDIA CONTACTS';

//Localization related
public static final string USER_LANG_DEFAULT_ENGLISH = 'ENGLISH';

//Content Filter related
public static final string SOBJECT_CONTENTVERSION = 'CONTENTVERSION';
public static final string CONTENTVERSION_LANGUAGE_FIELD_NAME = 'Language_Region';
public static final string CONTENT_SEARCH_URLTOKEN = 'sfc/#search';
public static final string CONTENT_SEARCH_FILTER_PARAMETER_KEY = 'searchProperties';

//Lead field 'Industry' options
public static final string LEAD_Industry_HC = 'Healthcare';
public static final string LEAD_Industry_HRED = 'Higher Ed/Research';
public static final string LEAD_Industry_ME = 'Media/Entertainment';
public static final string LEAD_Industry_MFG = 'Manufacturing';
public static final string LEAD_Industry_TCS = 'Telecommunications';
public static final string LEAD_Industry_RET = 'Retail/Etail';

//Lead field 'Product Type' Options
public static final string LEAD_PRODUCT_TYPE_TESLA = 'Tesla';
public static final string LEAD_PRODUCT_TYPE_GRID = 'vGPU';
public static final string LEAD_PRODUCT_TYPE_QUADRO = 'Quadro';
public static final string LEAD_PRODUCT_TYPE_AUTOMOTIVE = 'Automotive';
public static final string LEAD_PRODUCT_TYPE_vGPU = 'vGPU';
public static final string LEAD_PRODUCT_TYPE_DGX = 'DGX';
public static final string LEAD_PRODUCT_TYPE_Embedded = 'Embedded';

//Lead field 'Enterprise Segment' options
public static final string LEAD_ENTERPRISE_SEGMENT_DL = 'Deep Learning';
public static final string LEAD_ENTERPRISE_SEGMENT_HPC = 'High Performance Computing';
public static final string LEAD_ENTERPRISE_SEGMENT_GPUV = 'GPU Virtualization';
public static final string LEAD_ENTERPRISE_SEGMENT_PV = 'Professional Visualization';

public static final string PORTAL_TYPE_LITE = 'Lite';
public static final string PORTAL_TYPE_FULL = 'Full';

public static final string SUPPORT_REQTYPE_ASK_A_QUESTION = 'Ask A Question';
public static final string SUPPORT_REQTYPE_LOG_A_SUPPORT_REQ = 'Log A Support Request';

//public static final string TEST_PORTAL_COMPETENCY_AC = 'Tesla';
public static final string TEST_PORTAL_COMPETENCY_AC = 'Compute';               // Added for SDS-2058
public static final string TEST_PORTAL_COMPETENCY_CV = 'GPU Virtualization';
//public static final string TEST_PORTAL_COMPETENCY_GV = 'vGPU';
public static final string TEST_PORTAL_COMPETENCY_GV = 'Virtualization';         // Added for SDS-2058
public static final string TEST_PORTAL_COMPETENCY_CV_SPC = 'GPU Virtualization';
//public static final string TEST_PORTAL_COMPETENCY_PV = 'Quadro';
public static final string TEST_PORTAL_COMPETENCY_PV = 'Visualization';   // Added for SDS-2058
//public static final string TEST_PORTAL_COMPETENCY_DL = 'DGX';
public static final string TEST_PORTAL_COMPETENCY_DL = 'Compute DGX';   // Added for SDS-2058
//public static final string TEST_PORTAL_COMPETENCY_Jetson = 'Jetson';
public static final string TEST_PORTAL_COMPETENCY_Jetson = 'Embedded Edge';     // Added for SDS-2058

//Deal Registration: Permission Sets Label
public static final string DR_PS_CRM_PARTNER_DEAL_EDITOR = 'CRM : PARTNER DEAL : EDITOR';

//Generic: Trigger Events
public static final string TGR_BEFOREINSERT = 'BEFORE INSERT';
public static final string TGR_AFTERINSERT = 'AFTER INSERT';
public static final string TGR_BEFOREUPDATE = 'BEFORE UPDATE';
public static final string TGR_AFTERUPDATE = 'AFTER UPDATE';
public static final string TGR_BEFOREDELETE = 'BEFORE DELETE';
public static final string TGR_AFTERDELETE = 'AFTER DELETE';
public static final string TGR_AFTERUNDELETE = 'AFTER UNDELETE';

//Partner Attributes : PROGRAM Names
public static final string PA_PROGRAM_SP = 'Solution Provider';
public static final string PA_PROGRAM_OEM = 'OEM';
public static final string PA_PROGRAM_CSP = 'Cloud Service Provider';
public static final string PA_PROGRAM_TE = 'Tegra Embedded';
public static final string PA_PROGRAM_SA = 'Solution Advisor';
public static final string PA_PROGRAM_SIP = 'Solutions Integration Partner';
public static final string PA_PROGRAM_SDP = 'Service Delivery Partner';
public static final string PA_PROGRAM_DIST = 'Distributor';
public static final string PA_PROGRAM_IP = 'Inception Partner';

//Partner Attributes : Levels
public static final string PA_LEVEL_ELITE = 'Elite';
public static final string PA_LEVEL_PREF = 'Preferred';

//Contact Role default value
public static final string OCR_DEFAULT_SALES_CONTACT = 'Sales Contact';

//Billing Address/Mailing Address used in test methods
public static final string ADDRESS_STREET = 'The NVIDIA Way';
public static final string ADDRESS_CITY = 'Santa Clara';
public static final string ADDRESS_STATE = 'California';
public static final string ADDRESS_COUNTRY = 'United States';
public static final string ADDRESS_ZIP = '95050';
//2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
public static final string ADDRESS_REGION_NALA = 'NALA';
public static final string ADDRESS_REGION_EMEA = 'EMEA';
public static final string ADDRESS_SUBREGION_LA = 'LA';
public static final string ADDRESS_TERRITORY_LA = 'LA';
public static final string ADDRESS_US_ISO2 = 'US';
public static final string ADDRESS_US_ISO3 = 'USA';

//2016.10.03 - Services Subcontractors related changes

//2016.12.14 - Opp Registration TAM - interim change
public static final string USER_USERTYPE_POWERPARTNER = 'PowerPartner';
public static final string USER_USERTYPE_INTERNAL = 'Standard';

//product family - test class requirement
public static final string PROD_FAMILY_TESLAHW = 'Tesla HW Family';
public static final string PROD_FAMILY_EMB_ENT = 'Embedded Entertainment';

//2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
//used in the CRM_DR_Utility.cls to check the submission eligibility
public static final string OPPREG_SUBMITTYPE_APPROVAL = 'APPROVAL';
public static final string OPPREG_SUBMITTYPE_EXTNAPPROVAL = 'EXTNAPPROVAL';
public static final string OPPREG_SUBMITTYPE_CLAIMAPPROVAL = 'CLAIMAPPROVAL';

// 2017.03.16 - Account Tags, used in "Account_tgr" for TAM assignment
public static final string Account_TAG_1 = 'Enterprise Customer';
public static final string Account_TAG_2 = 'Assigned Account';
public static final string TAM_STRING = 'Blank';

// 2017.04.20 - Lead - Out for Approval - Docusign
public static final string LEAD_OUT_FOR_APPROVAL = 'Out for Approval';
public static final string CONTRACT_PACKET_SENT = 'Contracts Packet Sent';
public static final string SENT = 'Sent';
public static final string COMPLETED = 'Completed';

//2017.05.24 - Log A Support Problem, Ask A Question subject changes
public static final string LOG_A_SUPPORT_SUBJECT = 'Problem Submitted by ';
public static final string ASK_A_QUESTION_SUBJECT = 'Ask a Question: ';
}