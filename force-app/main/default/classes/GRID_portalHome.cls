public class GRID_portalHome {
public GRID_portalHome(){
}
    /*
    public string instanceMessage {get;set;}
    public boolean displayPopup {get; set;}        
    
     // Declaring varibale for each text box on visualforce page.
    public string email {get;set;}
    public string emailReportAProblem {get;set;} 
    public string subject {get;set;}
    public string body {get;set;} 
      
    public string ContactName {get;set;}  
    public Contact contactDetail {get;set;}       
       
       
       //Variable for report an email thing
    
   //  public string email {get;set;} 
    //public string subject {get;set;}
     
    public boolean displayPopup1 {get; set;}
    public blob Attach {get;set;}       
    public string problemType {get;set;}
    public string companyName {get;set;}   
    public string timeandDate {get;set;}
  // public string contactName {get;set;}
    public string phoneNumber {get;set;}    
    public string problemDescription {get;set;}
    public string shortDescription {get;set;}       
    public string steptoReproduceProblem {get;set;}    
    public String FileName_Upload {get; set;}    
    public boolean isReportAProblem {get;set;}  
    
       
    public void sendEmail1(){   
        boolean flag = false;                
        try{   
        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(FileName_Upload);
        if(Attach!=null){
            efa.setBody(Attach);
            fileAttachments.add(efa);   
        }              
        system.debug('check attachment '+Attach);
        String[] toAddresses = new String[] {'sgurrala@nvidia.com'}; //
        mail.setToAddresses(toAddresses);                
        DateTime d = System.now();        
        mail.setSubject('Problem Submitted by '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+' on '+d.month()+'/'+d.day()+'/'+d.year()+' on '+problemType);
        mail.setBccSender(false); 
        if(fileAttachments.size()>0){    
            mail.setFileAttachments(fileAttachments);
        }        
        string html = '<table width="100%"><tr><td width="30%"><b>VAR Contact Name</b></td>';
        html += '<td>'+contactName+'</td></tr>';        
        html += '<tr><td><b>Short Description</b></td>';
        html += '<td>'+problemType+'</td></tr>';
        html += '<tr><td><b>VAR Contact Email Address</b></td>';
        html += '<td>'+emailReportAProblem+'</td></tr>';
       html += '<tr><td><b>VAR Company Name</b></td>';
        html += '<td>'+companyName+'</td></tr>';
        html += '<tr><td><b>Time and Date</b></td>';
        html += '<td>'+timeandDate+'</td></tr>';
        html += '<tr><td><b>VAR Contact Phone Number</b></td>';
        html += '<td>'+phoneNumber+'</td></tr>';
        html += '<tr><td><b>Problem Description</b></td>';
        html += '<td>'+problemDescription+'</td></tr>';
        html += '<tr><td><b>Steps to Reproduce Problem</b></td>';
        html += '<td>'+steptoReproduceProblem+'</td></tr></table>';      
        mail.setHtmlbody(html);      
       //mail.setPlainTextBody('This is the test email body. Html format will create later on !');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Email sent successfully.'));    
        } 
        Catch(Exception ee){
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ee.getMessage()));    
        }
        displayPopUp = false;        
    } 
    
    public void closePopup1() {        
        displayPopup1 = false;    
    }     
    public void showPopup1() {        
        displayPopup1 = true;
        Attach = null;
        email = '';
        contactName = '';
        phoneNumber = '';   
        problemType = '';
        problemDescription = '';
        companyName = '';
        timeandDate = '';           
    }
         // Finish here
         
        public List<wrapperMain> lstMainWrapper {get;set;}
        public class wrapperMain{
                public string presentation_Type{get;set;}
                public List<wrapper> lstW {get;set;}
                public wrapperMain(){
                        lstW = new List<wrapper>();
                }
        }   
       
                
         
        public List<wrapper> lstWrapper {get;set;}
        public class wrapper{
                public string presentation_Name {get;set;}
                public string presentation_URL{get;set;}
                public string image_URL{get;set;}
        }   
       
    
    public boolean isGettingStarted {get;set;} //Done
    public boolean isNvidiaContacts {get;set;} //Done
    public boolean isAccountCharts {get;set;} //Done
    public boolean isOwnerCharts {get;set;}   //Done
    public boolean isNewTechnicalPresentations {get;set;}  //Done
    public boolean isNewPresentations {get;set;} //Done
    public boolean isNewCustomerPresentations {get;set;}
    public boolean isNewTrainingPresentations {get;set;}   
    public boolean isNewMarketingPresentations {get;set;}
    public boolean isLogATicketImage {get;set;} 
    public boolean isNewTechnicalTraining {get;set;}
      
          
    public GRID_portalHome(){
        try{
        lstMainWrapper = new List<wrapperMain>();
        lstWrapper = new List<Wrapper>();
        showInstanceMessage();
        email = 'GRID_VCA_partner@nvidia.com';
        //email = 'rgade@nvidia.com';
        system.debug('**************');
        generatePresentationBoxes();
        system.debug('&&&&&&&&&&&&&&');
        string contactId = [select ContactId from user where Id=:UserInfo.getUserId()].ContactId;
        system.debug('check current user contact id'+contactId);
        if(!test.isRunningTest()){
            if(contactId!=null){
                contactDetail = [select Id,FirstName,LastName,Email,Account.Owner.Name,Account.Owner.email,Account.Owner.Phone,
                                    Account.Marketing_Manager_Name__c,Account.Marketing_Manager_Contact_Number__c,Account.Marketing_Manager_Email__c,
                                    Account.Support_Manager_Name__c,Account.Support_Manager_Contact_Number__c,Account.Support_Manager_Email__c from Contact where Id =:contactId];
            }
        }
        //system.debug('Check contact detail :'+contactDetail.Account.Marketing_Manager_Name__c);
        //system.debug('Check contact detail :'+contactDetail.Account.Owner.Name);
        //system.debug('Check contact detail :'+contactDetail.Account.Owner.email);
        //system.debug('Check contact detail :'+contactDetail.Account.Support_Manager_Contact_Number__c);
                       
        string profileName = [select  Id,Profile.Name from user where Id =:UserInfo.getUserId()].Profile.Name;  
        GRID_Portal_Profiles__c objGridPortalProfile = [select Profile_Categories__c from GRID_Portal_Profiles__c where Name=:profileName];
        
        if(objGridPortalProfile.Profile_Categories__c == 'Sales' || objGridPortalProfile.Profile_Categories__c == 'Marketing' || objGridPortalProfile.Profile_Categories__c == 'Manager'){
            isGettingStarted = true;
        }else{
            isGettingStarted = false;
        }
        
        system.debug('check---------------'+objGridPortalProfile.Profile_Categories__c);
        if(objGridPortalProfile.Profile_Categories__c =='Support' || objGridPortalProfile.Profile_Categories__c=='Technical'){
            isReportAProblem = true;
        }  else {
            isReportAProblem = false;
        }
        
        // Here set variable values true false based on assigned permission set for Account chart and Owner chart.
        set<string> chartPermissionSets = new set<string>();
        for(PermissionSetAssignment psa :[SELECT AssigneeId,Id,PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment where AssigneeId=:UserInfo.getUserId()]){
             if(psa.PermissionSet.Name.contains('Charts'))
             chartPermissionSets.add(psa.PermissionSet.Name);        
        }
        
        if(chartPermissionSets.contains('Sales_Partner_Portal_Manager_Charts')){
            isAccountCharts = true;
            isOwnerCharts = true;
        }else {isAccountCharts = false; }
        
        if(chartPermissionSets.contains('Sales_Partner_Portal_Owner_Charts')){
            isOwnerCharts = true;
            
        }else{isOwnerCharts = false;}
      
        
            
        if(objGridPortalProfile.Profile_Categories__c == 'Support' || objGridPortalProfile.Profile_Categories__c == 'Manager'){
            isNewPresentations = true;
        }else{
            isNewPresentations = false;
        }
        if(objGridPortalProfile.Profile_Categories__c == 'Technical' || objGridPortalProfile.Profile_Categories__c == 'Manager' || objGridPortalProfile.Profile_Categories__c == 'Marketing' || objGridPortalProfile.Profile_Categories__c == 'Sales' || objGridPortalProfile.Profile_Categories__c == 'Support'){
            isNewTechnicalPresentations = true;
        }else{
            isNewTechnicalPresentations = false;
        }
       if(objGridPortalProfile.Profile_Categories__c == 'Sales' || objGridPortalProfile.Profile_Categories__c == 'Manager'){
            isNewCustomerPresentations = true;
        }else{
            isNewCustomerPresentations = false;
        }  
        if(objGridPortalProfile.Profile_Categories__c == 'Sales' || objGridPortalProfile.Profile_Categories__c == 'Manager'){
            isNewTrainingPresentations = true;
        }else{
            isNewTrainingPresentations = false;
        } 
        if(objGridPortalProfile.Profile_Categories__c == 'Marketing' || objGridPortalProfile.Profile_Categories__c == 'Manager'){
            isNewMarketingPresentations = true;
        }else{
            isNewmarketingPresentations = false;
        }  
        if(objGridPortalProfile.Profile_Categories__c == 'Marketing' || objGridPortalProfile.Profile_Categories__c == 'Manager' || objGridPortalProfile.Profile_Categories__c == 'Sales' || objGridPortalProfile.Profile_Categories__c == 'Support' || objGridPortalProfile.Profile_Categories__c == 'Technical'){
            isNewTechnicalTraining = true;
        }else{
            isNewTechnicalTraining = false;
        }
        
        }
        Catch(Exception ee){
        
        } 
             
    }  
       
    public void showInstanceMessage(){
        instanceMessage = '';
        List<GRID_VCA_Instant_Message__c>  lstInstanceMessage =  [SELECT Expiration_Date__c,Message__c,Start_Date__c FROM GRID_VCA_Instant_Message__c where Expiration_Date__c>today Order by Expiration_Date__c ASC limit 2];
        for(GRID_VCA_Instant_Message__c grMsg :lstInstanceMessage){        
            instanceMessage = instanceMessage+grMsg.Message__c;
        }
        
    }
        
        Map<string,List<Portal_Presentation__c>> mapPresentationType = new Map<string,List<Portal_Presentation__c>>();                  
        public void generatePresentationBoxes(){          
                string loginProfileName = [select Name from Profile where Id=:userinfo.getProfileId()].Name;
                List<Portal_Presentation__c> lstPortal_Presentation = [select Id,Name,Image_URL__c,Portal_Profile__c,Presentation_Type__c,Presentation_URL__c from Portal_Presentation__c];
                system.debug('lstPortal_Presentation-------'+lstPortal_Presentation);
                for(Portal_Presentation__c presentation : lstPortal_Presentation){                      
                        If(presentation.Portal_Profile__c.contains(loginProfileName)){
                                if(mapPresentationType.get(presentation.Presentation_Type__c)==null){
                                        mapPresentationType.put(presentation.Presentation_Type__c,new List<Portal_Presentation__c>());                                            
                                }                               
                                mapPresentationType.get(presentation.Presentation_Type__c).add(presentation);                           
                        }                       
                }
                system.debug('Check Map'+mapPresentationType);
                for(string presentationType:mapPresentationType.keyset()){
                        wrapperMain w = new wrapperMain();
                        w.presentation_Type = presentationType;
                        for(Portal_Presentation__c presentation :mapPresentationType.get(presentationType)){
                                wrapper ww = new wrapper();                     
                                ww.presentation_URL = presentation.Presentation_URL__c;
                                ww.image_URL = presentation.Image_URL__c;
                                ww.presentation_Name = presentation.Name;
                                w.lstW.add(ww);
                        }
                        lstMainWrapper.add(w);
                }
                system.debug('Check-----lstMainWrapper'+lstMainWrapper);        
        }

 // Method to send email.
    public void sendEmail(){
        try{
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'GRID_VCA_partner@nvidia.com'};        //email
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
        subject = '';
        body = '';    
    }
    */
}