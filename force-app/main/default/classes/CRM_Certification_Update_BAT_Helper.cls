/*
 * Batch Helper Class for the 'Certification' object.
 * Author: Manideep
 * Created Date: 12/01/2020
 * JIRA # SDS-2793
 * Description: This Batch Helper Class is being invoked by the Batch/Scheduler Class 'CRM_Certification_Update_BAT_SCH.cls' 
                * This is created as for the project 'DLI/DMS 2.0: Display Certified instructor Active/Inactive at Contact & Certification level'.
                * Only the Certificaitons that have mismatching between the two fields 'isCertification_Active__c' and 'is_Certification_Active_Formula__c' are 
                  considered for processing through this Batch Class and update the 'isCertification_Active__c' with the checkbox value in 'is_Certification_Active_Formula__c'.
                  
 * 5/28/2021: Using the same ticket SDS-2793: Did a Batch job failure fix.
*/
public class CRM_Certification_Update_BAT_Helper {  
    
  public static void executeBatch_Helper(list<Certifications__c> certificationScopeList) {
    
    list<Certifications__c> updateCertificaitonsList = new list<Certifications__c>();
    system.debug('certificationScopeList------>'+certificationScopeList);
    
    for(Certifications__c certf: certificationScopeList) {
        if(certf.isCertification_Active__c != certf.is_Certification_Active_Formula__c) {
           certf.isCertification_Active__c = certf.is_Certification_Active_Formula__c;
           updateCertificaitonsList.add(certf);  
        }      
    }
    system.debug('updateCertificaitonsList------>'+updateCertificaitonsList);
    
    if(!updateCertificaitonsList.isEmpty()) {
        // Update the remaining records in the batch even if there are some failures
        //Database.update(updateCertificaitonsList, false);
        
        // Update the remaining records in the batch even if there are some failures and create errors in the error log object
        list<Database.SaveResult> results = Database.update(updateCertificaitonsList, false);
         
        // Error log tracking object
        list<NV_Error_Log__c> nvErrLogUpdateCertificationList = new list<NV_Error_Log__c>();
        
        // loop through all errors
        for(Integer i = 0; i < results.size(); i++ ) {
            String errorMessage = '';
            if(!results.get(i).isSuccess()) {
                errorMessage = 'CRM_Certification_Update_BAT_SCH --> ' ;
                errorMessage += updateCertificaitonsList[i];
                errorMessage += 'Errors:\n';
                for(Database.Error theError : results.get(i).getErrors()) {
                    NV_Error_Log__c nvErrLogUpdateCertification = new NV_Error_Log__c(Error_Description__c = errorMessage + theError.getStatusCode(), Error_Message__c = theError.getMessage(), Functionality__c = 'CRM_Certification_Update_BAT_SCH');
                    nvErrLogUpdateCertificationList.add(nvErrLogUpdateCertification); 
                    
                }
            }
        }  
        insert nvErrLogUpdateCertificationList;
             
    }
    
  } // end of executeBatch_Helper()  
    
}