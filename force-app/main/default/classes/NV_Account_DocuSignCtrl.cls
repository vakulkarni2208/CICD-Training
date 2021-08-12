/*
 * Author: @Manideep
 * Date : 12/4/2018
 * Description: This is a Controller class for the VF page 'NV_Account_DocuSign'
 * Code Coverage for this Class is in the Test Class - 'NV_Account_DocuSignCtrlTest'.
*/

public class NV_Account_DocuSignCtrl {

  public final Account acct;  
  private Id userId;
  private Id profileId;
  list<String> profileList = new list<String>();
  list<String> permissionSetList = new list<String>();
  string noAccessPageMessage;
  
  public NV_Account_DocuSignCtrl(ApexPages.StandardController stdController) {  
    this.acct = (Account)stdController.getRecord(); 
    userId = UserInfo.getUserId();
    profileId = UserInfo.getProfileId();    
  }
  
  public pageReference invokeVFPage() {  
    
    pageReference pageRef;
    
    // fetch the values from the Custom Setting
    Map<String, DosuSign_for_Automotive__c> dSignAutoMap = DosuSign_for_Automotive__c.getAll();
    for(DosuSign_for_Automotive__c dSignAuto: dSignAutoMap.values()) {      
        // Collect the Permission Set Names
        if(string.isNotBlank(string.valueOf(dSignAuto.Category__c)) && string.valueOf(dSignAuto.Category__c).equalsIgnoreCase('Permission_Set') && string.isNotBlank(string.valueOf(dSignAuto.Permission_Set_Name__c))) {
           permissionSetList.add(string.valueOf(dSignAuto.Permission_Set_Name__c));
        } 
        // Collect the Profile Names
        if(string.isNotBlank(string.valueOf(dSignAuto.Category__c)) && string.valueOf(dSignAuto.Category__c).equalsIgnoreCase('Profile') && string.isNotBlank(string.valueOf(dSignAuto.Profile_Name__c))) {
           profileList.add(string.valueOf(dSignAuto.Profile_Name__c));
        } 
        // Collect the Page Message
        if(string.isNotBlank(string.valueOf(dSignAuto.Category__c)) && string.valueOf(dSignAuto.Category__c).equalsIgnoreCase('Page_Message_NA') && string.isNotBlank(string.valueOf(dSignAuto.Page_Message__c))) {
           noAccessPageMessage = string.valueOf(dSignAuto.Page_Message__c);	
        } 
    }      
    
    // check if the User has allowed Permission Set
    list<PermissionSetAssignment> psetAssgnList = [SELECT Id, AssigneeId, Assignee.Name, PermissionSetId, PermissionSet.Name, PermissionSet.Label
                                                   FROM PermissionSetAssignment 
                                                   WHERE PermissionSet.Name IN:permissionSetList
                                                   AND AssigneeId =:userId];
    
    // check if the User belongs to allowed Profile                                             
    list<Profile> profileAssgnList = [SELECT Id, Name 
                                      FROM Profile 
                                      WHERE Id =:profileId 
                                      AND Name =:profileList];
                                                   
    if(!psetAssgnList.isEmpty() || !profileAssgnList.isEmpty()) {
    	pageRef = new PageReference('/apex/DocSignforAutoAccounts?accid='+acct.Id);
        pageRef.setRedirect(true);
    } else {
    	//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'You do not have permission to access the DocuSign.'));
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, noAccessPageMessage));
    	pageRef = null;
    }
    
    return pageRef;    
  }

}