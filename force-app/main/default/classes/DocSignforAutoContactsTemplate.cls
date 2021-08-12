/*
 * Author: @Manideep
 * Date : 12/4/2018
 * Description: This is a Wrapper class for the Controller class 'DocSignforAutoAccountsCtrl'
 * Code Coverage for this Class is in the Test Class - 'DocSignforAutoAccountsCtrlTest'.
*/

global class DocSignforAutoContactsTemplate {
  
  public Boolean isContSelected {get;set;}
  public Contact cont{get;set;}
    
  public DocSignforAutoContactsTemplate(Contact cont, Boolean isContSelected) {
    this.cont = cont;
    this.isContSelected = isContSelected;
  }

}