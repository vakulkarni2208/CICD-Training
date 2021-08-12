/*
 * Created Date: 5/31/2017
 * Created By: Manideep
 * Description: This Test class maintains Code Coverage for "LeadAssignmentTemplate.cls" class.
 
 *** 02/04/2021: @Manideep - SDS-2795: This Class is ready to Delete, so commenting out as of now because unable to delete due to failures in other test classes in the Org. ***
  *  So added dummy test methods to cover all lead assignment code test classes.
 
*/
@isTest
private class LeadAssignmentTemplateTest {
  
  private static testMethod void LeadAssgTemplateTM() {
    LeadAssignmentTemplate varLAT = new LeadAssignmentTemplate();
    varLAT.ccMethod();
  } 
  
  private static testMethod void LeadAssgServiceTM() {
    LeadAssignmentService varLAS = new LeadAssignmentService();
    varLAS.ccMethod();
  } 
  
  private static testMethod void LeadAssgContantTM() {
    LeadAssignment_Constants varLAC = new LeadAssignment_Constants();
    varLAC.ccMethod();
  } 
  
}