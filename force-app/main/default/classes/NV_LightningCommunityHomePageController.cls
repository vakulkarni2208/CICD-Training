Global without sharing class NV_LightningCommunityHomePageController {

public static boolean isActiveComputeDGX = false;      // Added for SDS-2801
public static List<Partner_Attribute__c> activePAList = new List<Partner_Attribute__c>(); // Added for SDS-2801
public static boolean bIsComplianceOnTableau = false; 

@AuraEnabled
public static InitializationData getInitializationData() {
    system.debug(String.valueof(System.URL.getSalesforceBaseURL().gethost()));

    InitializationData objInitializationData = new InitializationData();
    User usr = getUserInfo();
    if (usr.firstName != null && usr.firstName != '')
        objInitializationData.strUserName = usr.firstName + ' ' + usr.lastName;
    else {
        objInitializationData.strUserName = usr.lastName;
    }
    if (usr.account.EAR_Restricted__c) {
        objInitializationData.bUnRestricted = false;
    } else {
        objInitializationData.bUnRestricted = true;
    }

    getActivePartnerAttributes(usr);       // Added for SDS-2801
    objInitializationData.lstCompetencyData = getCompetencyData(usr);
    objInitializationData.lstHomePageLinks = getHomePageLinks(usr);
    objInitializationData.bIndustryCompetency = hasIndustryCompetency(objInitializationData.lstCompetencyData,usr);
    objInitializationData.objPartnerPerformanceScorecard = loadPartnerScorecard(usr);
    objInitializationData.lstHomePageMessages = getHomePageMessages(usr);
    objInitializationData.currentBaseURL = String.valueof(System.URL.getSalesforceBaseURL().gethost());
    // objInitializationData.objHeaderInfo = new HeaderInfo(NPN_Community_Portal_Header_Text__c.getInstance().Header_Text__c, NPN_Community_Portal_Header_Text__c.getInstance().Sub_Header_Text__c, NPN_Community_Portal_Header_Text__c.getInstance().Button_Lable__c, NPN_Community_Portal_Header_Text__c.getInstance().URL__c);
    objInitializationData.bIsComplianceOnTableau = bIsComplianceOnTableau;
    objInitializationData.objHeaderInfo = new HeaderInfo(NPN_Community_Portal_Header_Text__c.getInstance().Header_Text__c, NPN_Community_Portal_Header_Text__c.getInstance().Sub_Header_Text__c, NPN_Community_Portal_Header_Text__c.getInstance().Button_Lable__c,system.label.NPNHomePageLearnMoreURL);
    system.debug('objInitializationData -> '+objInitializationData);
    return objInitializationData;
}

@AuraEnabled
public static User getUserInfo() {
    User usr = [Select id, firstName, lastName, contactId, contact.Portal_Groups__c, accountId, account.EAR_Restricted__c from user where id = :UserInfo.getUserId()];
    return usr;
}

@AuraEnabled
public static Boolean hasIndustryCompetency(list<Competency_Data__c> lstCompetencyData, User usr) {
    list<String> lstIndustryCompetency = new list<String>();
    for(Competency_Data__c objCD : lstCompetencyData) {
        if(objCD.Vertical_Competency__c) {
            lstIndustryCompetency.add(objCD.name);
        }
    }

    list<Partner_Attribute__c> lstPA = [select id from Partner_Attribute__c where Account_Name__c =:usr.AccountId and Partner_Competency__c in :lstIndustryCompetency limit 1];
    if(lstPA.size() > 0) {
        return true;
    }
    return false;
}

@AuraEnabled
public static String getBaseUrl () {
    if (Network.getNetworkId() != null) {
        system.debug(Network.getNetworkId());
        system.debug(Network.getLogoutUrl(Network.getNetworkId()));
        return Network.getLogoutUrl(Network.getNetworkId());
    }
    return '';
}

@AuraEnabled
public static list<HomePageLinks> getHomePageLinks(User usr) {
    list<PermissionSetAssignment> lstPSA = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
    set<String> setCustomPermissionName = new set<String>();
    set<Id> setParentId = new set<Id>();
    for(PermissionSetAssignment objPSA : lstPSA) {
        setParentId.add(objPSA.PermissionSetId);
    }
    setParentId.add(userinfo.getProfileId());
    map<String, HomePageLinks> mapCPHomePageLinks = new map<String, HomePageLinks>();
    map<Id, String> mapCustomPermissionNamesById = new map<Id, String>();
    list<HomePageLinks> lstHP = new list<HomePageLinks>();
    list<NPN_Community_Home_Page_Link__c> lstHPL = [select id, Link_Label__c, Link_Type__c, Link_URL__c, Button_Label__c, Button_Link__c,  Has_Button__c, order__c, CustomPermissionName__c from NPN_Community_Home_Page_Link__c order by order__c];
    for(NPN_Community_Home_Page_Link__c objHPL : lstHPL) {
        mapCPHomePageLinks.put(objHPL.CustomPermissionName__c, new HomePageLinks(objHPL.Link_URL__c, objHPL.Link_Label__c, objHPL.Link_Type__c, objHPL.Button_Label__c, objHPL.Button_Link__c, objHPL.Has_Button__c, objHPL.order__c));
    }

    // Added for SDS-2801 START
    String strCustPerm = String.isNotBlank(Label.NPNHomePage_Widen_Custom_Permission) ? Label.NPNHomePage_Widen_Custom_Permission : 'SalesTabForCommunityHomePage';
    String redirectURL = String.isNotBlank(Label.NPNHomePage_Compute_DGX_Mktg_Sales_Tab) ? Label.NPNHomePage_Compute_DGX_Mktg_Sales_Tab : '/apex/NPN_WidenRedirectPage?redirect_url=/portals/m3gpmhey/NPNPortal';

    system.debug('--> isActiveComputeDGX '+isActiveComputeDGX);
    if(isActiveComputeDGX) {
        // remove the non Compute DGX Widen link from mapCPHomePageLinks
        mapCPHomePageLinks.get(strCustPerm).strLinkURL = redirectURL;
    }
    system.debug('--> mapCPHomePageLinks.get(strCustPerm).strLinkURL '+mapCPHomePageLinks.get(strCustPerm).strLinkURL);
    // Added for SDS-2801 END

    List<CustomPermission> lstCP = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName IN :mapCPHomePageLinks.keyset()];
    for(CustomPermission objCP : lstCP) {
        mapCustomPermissionNamesById.put(objCP.Id, objCP.DeveloperName);
    }
    List<SetupEntityAccess> lstSE = [SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId in :mapCustomPermissionNamesById.keySet() AND
                                     ParentId IN :setParentId ];
    for(SetupEntityAccess objSE : lstSE) {
        if(mapCustomPermissionNamesById.containsKey(objSE.SetupEntityId) && mapCPHomePageLinks.containsKey(mapCustomPermissionNamesById.get(objSE.SetupEntityId))) {
            if(mapCustomPermissionNamesById.get(objSE.SetupEntityId) == Label.NPNHomePage_Compliance_Tab_Permission) {
                bIsComplianceOnTableau = true;
            }
            if(!setCustomPermissionName.contains(mapCustomPermissionNamesById.get(objSE.SetupEntityId))) {
                lstHP.add(mapCPHomePageLinks.get(mapCustomPermissionNamesById.get(objSE.SetupEntityId)));
            }
            setCustomPermissionName.add(mapCustomPermissionNamesById.get(objSE.SetupEntityId));
            //system.debug('--Label.NPNHomePage_Compliance_Tab_Permission> '+Label.NPNHomePage_Compliance_Tab_Permission);
        }
    }
    lstHP.sort();
    return lstHP;
    
}

@AuraEnabled
public static list<Competency_Data__c> getCompetencyData(User usr) {

    List<String> excludeCompetencyList = getCompetenciesToExclude(usr);         //SDS-2801
    system.debug('--> excludeCompetencyList '+excludeCompetencyList);
    List<Competency_Data__c> lstCD = new List<Competency_Data__c>();

    //## Commented for SDS-2801
    //list<Competency_Data__c> lstCD = [select id, Name, Static_Resource_Image_Path__c, Vertical_Competency__c, Heading_Link__c, Partner_Home_Page_Image__c, Competency_Long_Description__c, Competency_Short_Description__c,(select Default_Competency__c, Link_Label__c, Link_Url_Text__c from Competency_Data_Links__r order by order__c ASC) from Competency_Data__c order by order__c ASC];

    // Added for SDS-2801
    if(!excludeCompetencyList.isEmpty()) {
        lstCD = [SELECT Id, Name, Static_Resource_Image_Path__c, Vertical_Competency__c, Heading_Link__c, Partner_Home_Page_Image__c, Competency_Long_Description__c, Competency_Short_Description__c,(SELECT Default_Competency__c, Link_Label__c, Link_Url_Text__c from Competency_Data_Links__r order by order__c ASC) FROM Competency_Data__c WHERE Name NOT IN :excludeCompetencyList ORDER BY order__c ASC];
    }else{
        lstCD = [SELECT Id, Name, Static_Resource_Image_Path__c, Vertical_Competency__c, Heading_Link__c, Partner_Home_Page_Image__c, Competency_Long_Description__c, Competency_Short_Description__c,(SELECT Default_Competency__c, Link_Label__c, Link_Url_Text__c from Competency_Data_Links__r order by order__c ASC) FROM Competency_Data__c ORDER BY order__c ASC];
    }

    return lstCD;
}

// SDS-2801 START
public static void getActivePartnerAttributes(User usr){
    activePAList = [SELECT Id,Account_Name__c, Date_Competency_Signed__c, Date_Competency_Terminated__c, Partner_Competency__c FROM Partner_Attribute__c WHERE Account_Name__c =:usr.AccountId AND Date_Competency_Terminated__c = NULL];
}

public static list<String> getCompetenciesToExclude(User usr) {

    List<String> excludeCompetencyList = new List<String>();
    String dgxCompetencyStr = String.isNotBlank(Label.NPNHomePage_DGX_CompetencyName) ? Label.NPNHomePage_DGX_CompetencyName : 'DGX';
    for(NPN_Active_Competency_List__mdt acObj : [SELECT MasterLabel, DeveloperName FROM NPN_Active_Competency_List__mdt]) {
        excludeCompetencyList.add(acObj.MasterLabel);
    }

    system.debug('--> excludeCompetencyList '+excludeCompetencyList);
    system.debug('--> activePAList '+activePAList);
    if(!excludeCompetencyList.isEmpty() && !activePAList.isEmpty()) {
        for(Partner_Attribute__c pa : activePAList) {
            if(pa.Date_Competency_Signed__c != Date.valueOf('2099-12-31') && excludeCompetencyList.contains (pa.Partner_Competency__c)) {

                Integer j = excludeCompetencyList.indexOf(pa.Partner_Competency__c);
                excludeCompetencyList.remove(j);

                if(dgxCompetencyStr.equalsIgnoreCase(pa.Partner_Competency__c) ||(COMM_Constants.TEST_PORTAL_COMPETENCY_DL.equalsIgnoreCase(pa.Partner_Competency__c)) ) {
                    isActiveComputeDGX = true;
                    if(excludeCompetencyList.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_DL)) {
                        Integer k = excludeCompetencyList.indexOf(COMM_Constants.TEST_PORTAL_COMPETENCY_DL);
                        excludeCompetencyList.remove(k);
                    }
                }
            }
        }
    }
    system.debug('--> isActiveComputeDGX '+isActiveComputeDGX);
    return excludeCompetencyList;
}
// SDS-2801 END

@AuraEnabled
public static list<HomePageMessage> getHomePageMessages(User usr) {
    list<HomePageMessage> lstHomePageMessage = new list<HomePageMessage>();
    list<String> lstPortalGroups = usr.contact.Portal_Groups__c!=null ? usr.contact.Portal_Groups__c.split(';') : new list<String> {''};
    string strAllPSGrpNames = '';
    String HPMessageQuery;
    for (string strPSGrpName : lstPortalGroups) {
        if (strPSGrpName != null && strPSGrpName.trim() != '') {
            strAllPSGrpNames += '\'' + strPSGrpName + '\'' + ', ';
        }
    }
    //remove the last comma
    if (strAllPSGrpNames.trim().length() != 0) {
        strAllPSGrpNames = strAllPSGrpNames.substring(0, strAllPSGrpNames.lastIndexOf(','));
        HPMessageQuery = 'select URL__c, Portal_Message__c from NPN_Community_Home_Page_Message__c where (start_date__c <= today OR start_date__c =null) AND (end_date__c =null OR end_date__c >= today) and (portal_groups__c INCLUDES ('+strAllPSGrpNames+')) limit 5';
        list<NPN_Community_Home_Page_Message__c> lstHPMessages = Database.Query(HPMessageQuery);        //[select URL__c, Portal_Message__c from NPN_Community_Home_Page_Message__c where ((start_date__c <= today OR start_date__c =null) AND (end_date__c =null OR end_date__c >= today) and (portal_groups__c INCLUDES (:lstPortalGroups))) limit 5];
        system.debug(lstHPMessages);
        for(NPN_Community_Home_Page_Message__c objHPMessages : lstHPMessages) {
            lstHomePageMessage.add(new HomePageMessage(objHPMessages.URL__c, objHPMessages.Portal_Message__c));
        }
        return lstHomePageMessage;
    }
    return lstHomePageMessage;
}

@AuraEnabled
public static PartnerPerformanceScorecard loadPartnerScorecard(User usr) {

    String accId, contactId, loadPartnerScorecard;
    Set<String> competencySet = new Set<String>();
    list<String> lstPartnerProgramName = new list<String>();
    map<String, set<String> > mapCompetencySetCategory = new map<String, set<String> >();
    Boolean isTransit = SuRF_Transit__c.getOrgDefaults().isTransit__c;
    Boolean isInProgress = false;
    accId = usr.AccountId;
    contactId = usr.ContactId;
    list<Contact> lstContact = [select id, Portal_User_Content_Type__c from Contact where id=:contactId];
    list<SURF_Program_Type__mdt> lstSurfProgramType = [select Program_Type__c from SURF_Program_Type__mdt];
    for(SURF_Program_Type__mdt objSurfProgramType : lstSurfProgramType) {
        lstPartnerProgramName.add(objSurfProgramType.Program_Type__c);
    }
    if(isTransit) {
        loadPartnerScorecard = 'SELECT Account_Name__c, Competency__c, Partner_Program__c, Level__c, Program_Signed_Date__c, Competency_Signed_Date__c, Region__c, PBM__c, Order__c, Flag__c, Category__c '
                               +'FROM SuRF_Partner_Performance_Scorecard_Trans__c WHERE Category__c in (\'Training Compliance\',\'POS Submission\') AND Account_ID__c = \''+accId+'\' '
                               +'ORDER BY Competency__c limit 40000';
        for(SuRF_Partner_Performance_Scorecard_Trans__c objPPS : Database.query(loadPartnerScorecard)) {
            if(objPPS.Flag__c == 0) {
                isInProgress = true;
            }
            if(mapCompetencySetCategory.containsKey(objPPS.Partner_Program__c+objPPS.Competency__c)) {
                mapCompetencySetCategory.get(objPPS.Partner_Program__c+objPPS.Competency__c).add(objPPS.Category__c);
            } else {
                mapCompetencySetCategory.put(objPPS.Partner_Program__c+objPPS.Competency__c, new Set<String> {objPPS.Category__c});
            }
        }
    } else {
        loadPartnerScorecard = 'SELECT Account_Name__c, Competency__c, Partner_Program__c, Level__c, Program_Signed_Date__c, Competency_Signed_Date__c, Region__c, PBM__c, Order__c, Flag__c, Category__c '
                               +'FROM SuRF_Partner_Performance_Scorecard__c WHERE Category__c in (\'Training Compliance\',\'POS Submission\') AND Account_ID__c = \''+accId+'\' '
                               +'ORDER BY Competency__c limit 40000';
        for(SuRF_Partner_Performance_Scorecard__c objPPS : Database.query(loadPartnerScorecard)) {
            if(objPPS.Flag__c == 0) {
                isInProgress = true;
            }
            if(mapCompetencySetCategory.containsKey(objPPS.Partner_Program__c+objPPS.Competency__c)) {
                mapCompetencySetCategory.get(objPPS.Partner_Program__c+objPPS.Competency__c).add(objPPS.Category__c);
            } else {
                mapCompetencySetCategory.put(objPPS.Partner_Program__c+objPPS.Competency__c, new Set<String> {objPPS.Category__c});
            }
        }
    }
    list<Partner_Attribute__c> lstPA = [select id, Partner_Program_Name__c, Partner_Competency__c from Partner_Attribute__c where Account_Name__c = :accId and (Not Partner_Program_Name__c like '%Industry%') and Date_Competency_Signed__c!=2099-12-31 and Date_Competency_Terminated__c = null and Date_Program_Terminated__c = null and Partner_Program_Name__c in :lstPartnerProgramName ];
    if(lstPA.size() > 0) {
        for(Partner_Attribute__c objPA : lstPA) {
            competencySet.add(objPA.Partner_Program_Name__c + objPA.Partner_Competency__c);
        }
    }
    system.debug(mapCompetencySetCategory);
    if(competencySet.size() > mapCompetencySetCategory.keyset().size()) {
        return new PartnerPerformanceScorecard(null, null,lstContact[0].Portal_User_Content_Type__c, false, isInProgress);
    } else {
        for(String competencyStr : mapCompetencySetCategory.keyset()) {
            if(mapCompetencySetCategory.get(competencyStr).size() < 2) {
                return new PartnerPerformanceScorecard(null, null,lstContact[0].Portal_User_Content_Type__c, false, isInProgress);
            }
        }
    }
    return new PartnerPerformanceScorecard(null, null, lstContact[0].Portal_User_Content_Type__c, true, isInProgress);
}



public class PartnerPerformanceScorecard {

@AuraEnabled public list<SuRF_Partner_Performance_Scorecard__c> lstPPS { get; set; }
@AuraEnabled public String strProgramName { get; set; }
@AuraEnabled public String defaultCompetency { get; set; }
@AuraEnabled public Boolean overallCompliant { get; set; }
@AuraEnabled public Boolean isInProgress { get; set; }

// Trivial constructor, for server-side Apex -> client-side JavaScript
public PartnerPerformanceScorecard(list<SuRF_Partner_Performance_Scorecard__c> lstPPS, String strProgramName, String defaultCompetency, Boolean overallCompliant, Boolean isInProgress) {
    this.lstPPS = lstPPS;
    this.strProgramName = strProgramName;
    this.defaultCompetency = defaultCompetency;
    this.overallCompliant = overallCompliant;
    this.isInProgress  = isInProgress;
}

// Default, no-arg constructor, for client-side -> server-side
public PartnerPerformanceScorecard() {
}

}

global class HomePageLinks implements Comparable {
@AuraEnabled public String strLinkURL { get; set; }
@AuraEnabled public String strLinkLabel { get; set; }
@AuraEnabled public String strLinkType { get; set; }
@AuraEnabled public Decimal order { get; set; }
@AuraEnabled public String strButtonLabel { get; set; }
@AuraEnabled public String strButtonLink { get; set; }
@AuraEnabled public Boolean hasButton {get; set;}
public HomePageLinks(String strLinkURL, String strLinkLabel, String strLinkType, String strButtonLabel, String strButtonLink, Boolean hasButton, Decimal order) {
    this.strLinkURL = strLinkURL;
    this.order = order;
    this.strLinkLabel = strLinkLabel;
    this.strLinkType = strLinkType;
    this.strButtonLink = strButtonLink;
    this.strButtonLabel = strButtonLabel;
    this.hasButton = hasButton;

}

global Integer compareTo(Object compareTo) {
    HomePageLinks hpl = (HomePageLinks)compareTo;
    if(order == hpl.order) return 0;
    if(order > hpl.order) return 1;
    return -1;
}
}

public class CompetencyData {
@AuraEnabled public String strLinkURL { get; set; }
@AuraEnabled public String strLinkLabel { get; set; }
@AuraEnabled public String strLinkType { get; set; }
public CompetencyData(String strLinkURL, String strLinkLabel, String strLinkType) {
    this.strLinkURL = strLinkURL;
    this.strLinkLabel = strLinkLabel;
    this.strLinkType = strLinkType;
}
}

public class HeaderInfo {
@AuraEnabled public String strHeaderText { get; set; }
@AuraEnabled public String strSubheaderText { get; set; }
@AuraEnabled public String strButtonText { get; set; }
@AuraEnabled public String strButtonLink { get; set; }
public HeaderInfo(String strHeaderText, String strSubheaderText, String strButtonText, String strButtonLink) {
    this.strHeaderText = strHeaderText;
    this.strSubheaderText = strSubheaderText;
    this.strButtonText = strButtonText;
    this.strButtonLink = strButtonLink;
}
}

public class HomePageMessage {
@AuraEnabled public String strURL { get; set; }
@AuraEnabled public String strMessage { get; set; }
public HomePageMessage(String strURL, String strMessage) {
    this.strMessage = strMessage;
    this.strURL = strURL;
}
}

public class InitializationData {
@AuraEnabled public Boolean bIndustryCompetency {get; set;}
@AuraEnabled public Boolean bIsComplianceOnTableau {get; set;}
@AuraEnabled public Boolean bUnRestricted {get; set;}
@AuraEnabled public String strUserName {get; set;}
@AuraEnabled public list<Competency_Data__c> lstCompetencyData {get; set;}
@AuraEnabled public list<HomePageLinks> lstHomePageLinks {get; set;}
@AuraEnabled public PartnerPerformanceScorecard objPartnerPerformanceScorecard {get; set;}
@AuraEnabled public HeaderInfo objHeaderInfo {get; set;}
@AuraEnabled public list<HomePageMessage> lstHomePageMessages {get; set;}
@AuraEnabled public String currentBaseURL {get; set;}

}

}