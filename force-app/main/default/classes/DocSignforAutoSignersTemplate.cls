/*
 * Author: @Manideep
 * Date : 12/4/2018
 * Description: This is a Wrapper class for the Controller class 'DocSignforAutoAccountsCtrl'
 * Code Coverage for this Class is in the Test Class - 'DocSignforAutoAccountsCtrlTest'.
*/

global class DocSignforAutoSignersTemplate {
  
  public Boolean isSignerSelected{get;set;}
  public User usr{get;set;}
    
  public DocSignforAutoSignersTemplate(User usr, Boolean isSignerSelected) {
    this.usr = usr;
    this.isSignerSelected = isSignerSelected;
  }

}