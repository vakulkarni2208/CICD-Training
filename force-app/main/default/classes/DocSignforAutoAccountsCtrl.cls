/*
 * Author: @Manideep
 * Date : 12/4/2018
 * Description: This is a Controller class for the VF page 'DocSignforAutoAccounts'
 * Code Coverage for this Class is in the Test Class - 'DocSignforAutoAccountsCtrlTest'.
*/

public with sharing class DocSignforAutoAccountsCtrl {
  
  public Id acctID;
  public list<DocSignforAutoContactsTemplate> lstCtcWrapper{get;set;}
  public list<Contact> contactList{get;set;}
  public Contact selectedContact{get;set;}
  public Boolean showSigners{get;set;}
  public list<DocSignforAutoSignersTemplate> lstSignersTemplate{get;set;}
  public list<User> usersList{get;set;}
  public User selectedSigner{get;set;}
  public Boolean showDocSignButton{get;set;}
  public Boolean hideSubmitTheContact{get;set;}
  public Boolean hideSubmitTheSigner{get;set;}
  public Id idCtcSelected{get;set;} // Contact Id seleted from the List
  public Id idSignerSelected{get;set;} // Signer Id seleted from the List
  list<String> signerEmailList = new list<String>();
  string strDST;
  
  public DocSignforAutoAccountsCtrl() {
   
   // fetch the values from the Custom Setting
   Map<String, DosuSign_for_Automotive__c> dSignAutoMap = DosuSign_for_Automotive__c.getAll();
   for(DosuSign_for_Automotive__c dSignAuto: dSignAutoMap.values()) {    	
       // collect the Email Id's
       if(string.isNotBlank(string.valueOf(dSignAuto.Category__c)) && string.valueOf(dSignAuto.Category__c).equalsIgnoreCase('Signer') && string.isNotBlank(string.valueOf(dSignAuto.User_Email__c))) {
    	  signerEmailList.add(string.valueOf(dSignAuto.User_Email__c));
       }
       // collect the DocuSign Template Id
       if(string.isNotBlank(string.valueOf(dSignAuto.Category__c)) && string.valueOf(dSignAuto.Category__c).equalsIgnoreCase('Default_DST') && string.isNotBlank(string.valueOf(dSignAuto.DST__c))) {
       	  strDST = string.valueOf(dSignAuto.DST__c);
       }	  
   }      
   
   hideSubmitTheContact = false;
   hideSubmitTheSigner = false;
   showSigners = false;
   contactList = new List<Contact>();
   lstCtcWrapper = new List<DocSignforAutoContactsTemplate>();
   acctID = ApexPages.currentPage().getParameters().get('accId');
   if(acctID != null) {
      contactList = [SELECT Id, Name, FirstName, LastName, Role__c, Primary_Contact__c, Email, Phone, AccountId FROM Contact WHERE AccountID=:acctID];
      for(Contact ctc: contactList) {
          lstCtcWrapper.add(new DocSignforAutoContactsTemplate(ctc, false));
      }
   } else {
      contactList = null;
   }       
  } 
  
  // invoked by 'Submit the Contact' Button, this button finalizes the Contact 
  public void SubmitTheContact() {
    //selectedContact = new Contact();
    for(DocSignforAutoContactsTemplate ctcWrapperObj: lstCtcWrapper) {
        if(ctcWrapperObj.isContSelected == true) {
           selectedContact = ctcWrapperObj.cont;
           fetchSigners(); // Fetch and display the Signers 
           showSigners = true;
           hideSubmitTheContact = true;
        }
    }  
  }
  
  // Fetch all the Signers
  public void fetchSigners() {
    lstSignersTemplate = new List<DocSignforAutoSignersTemplate>();
    usersList = [SELECT Id, Name, FirstName, LastName, Email from User Where Email IN:signerEmailList];
    if(!usersList.isEmpty()) {
        for(User usr: usersList) {
          lstSignersTemplate.add(new DocSignforAutoSignersTemplate(usr, false));
        }
    } else {
        lstSignersTemplate = null;
    }
  } 
  
  //invoked by 'Submit the Signer' Button, this button finalizes the Signer
  public void SubmitTheSigner() {
    selectedSigner = new User();
    for(DocSignforAutoSignersTemplate usrSignerObj: lstSignersTemplate) {
        if(usrSignerObj.isSignerSelected == true) {
           selectedSigner = usrSignerObj.usr;
           showDocSignButton = true;
           hideSubmitTheSigner = true;
        }
    }  
  }
  
  //Disable Selected Checkbox for Contact list, only one Checkbox can be selected at a time
  public void disableSelectedCheckboxforContact() {
    //Iterate over wrapper/template class and set the checkbox to false 
    for(DocSignforAutoContactsTemplate ctcObj: lstCtcWrapper) {
        if(ctcObj.cont.Id == idCtcSelected && ctcObj.isContSelected){}
        else {
           ctcObj.isContSelected = false;
        }
    }
  }
  
  //Disable Selected Checkbox for Signers list, only one Checkbox can be selected at a time
  public void disableSelectedCheckboxforSigner() {
    //Iterate over wrapper/template class and set the checkbox to false 
    for(DocSignforAutoSignersTemplate sgnObj: lstSignersTemplate) {
        if(sgnObj.usr.Id == idSignerSelected && sgnObj.isSignerSelected){}
        else {
           sgnObj.isSignerSelected = false;
        }
    }
  }
  
  // this method will redirect user to the DocuSign's Visualforce Page
  public PageReference SendwithDocuSign() {
    system.debug('selectedContact--->'+selectedContact);
    system.debug('selectedSigner---->'+selectedSigner);
    PageReference reDirectToDocuSignPage = new PageReference('/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID='+acctID+'&DST='+strDST
                                                             + '&CCRM=Partner User~Partner User;VP~VP;'
                                                             + '&CCTM=Partner User~Signer;VP~Signer;'
                                                             + '&CRL=Email~'+selectedContact.Email+';Role~Partner User;RoutingOrder~1;FirstName~'+selectedContact.FirstName+';LastName~'+selectedContact.LastName+';,Email~'+selectedSigner.Email+';Role~VP;RoutingOrder~2;FirstName~'+selectedSigner.FirstName+';LastName~'+selectedSigner.LastName+';');
    return reDirectToDocuSignPage; 
  }
  
  public PageReference Cancel() {
    PageReference pageRef = new PageReference('/'+acctID);
    return pageRef;  
  }

}