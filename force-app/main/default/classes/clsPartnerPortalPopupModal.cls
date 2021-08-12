public class clsPartnerPortalPopupModal {     

    public boolean displayPopup {get; set;}     
    
     // Declaring varibale for each text box on visualforce page.
    public string email {get;set;}
    public string subject {get;set;}
    public string body {get;set;}
    
    public clsPartnerPortalPopupModal(){
        //email = 'GRID_VCA_partner@nvidia.com';
        email = 'rgade@nvidia.com';
    }
    
    
    // Method to send email.
    public void sendEmail(){
        try{
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {email};
        mail.setToAddresses(toAddresses);                
        mail.setSubject(subject);
        mail.setBccSender(false);       
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Email sent successfully.'));    
        }Catch(Exception ee){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ee.getMessage()));    
        }
        displayPopup = false;        
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
  }