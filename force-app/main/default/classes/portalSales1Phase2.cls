public class portalSales1Phase2 {

Public portalSales1Phase2()
{
}
//Variable for report an email thing
    
   /* public string email {get;set;} 
    public string subject {get;set;}
    public string body {get;set;}    
    public boolean displayPopup {get; set;}
    public blob Attach {get;set;} 
    public string problemType {get;set;}
    public string companyName {get;set;}  
    public string timeandDate {get;set;}
    public string contactName {get;set;}
    public string phoneNumber {get;set;}  
    public string problemDescription {get;set;}
    public string shortDescription {get;set;}       
    public string steptoReproduceProblem {get;set;}    
    public String FileName_Upload {get; set;}
    public boolean isReportAProblem {get;set;}    
    
       
    public void sendEmail(){     
        boolean flag = false;              
        try{       
        /*
        if(!email.contains('@')){      
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Email Id is not valid !'));
            return ;
        }  
        if(phoneNumber.length()!=10){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Phone number must contain 10 digits !'));
            return ;     
                    }   
        
        if(email=='' && contactName=='' && phoneNumber==''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'You must enter atleast one value either email or Name or phone!'));
            return ;
        }     
        */
        /*List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();    
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
        html += '<td>'+email+'</td></tr>';
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
        }Catch(Exception ee){
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ee.getMessage()));    
        }
        displayPopup = false;        
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;
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
    
    public string instanceMessage {get;set;}
    public List<wrapper> lstWrapper {get;set;}
    public List<CustomWrap> lst_CustomWrap{get;set;}
    public string tabName {get;set;}  
    public boolean isLogATicket {get;set;}
      
    public portalSales1Phase2 (){
           
        tabName = ApexPages.CurrentPage().getParameters().get('tab');
        lstWrapper = new List<wrapper>();
        lst_CustomWrap = new List<CustomWrap>();
        //if(!test.isRunningTest())
        init();
        showInstanceMessage();   
        
        string profileName = '';
        If(!Test.isRunningTest())        
            profileName = [select  Id,Profile.Name from user where Id =:UserInfo.getUserId()].Profile.Name;         
        if(profileName != null && profileName != '')
        {
            GRID_Portal_Profiles__c objGridPortalProfile = [select Profile_Categories__c from GRID_Portal_Profiles__c where Name=:profileName];
        
            if(objGridPortalProfile.Profile_Categories__c == 'Support'){
                isLogATicket = true;
            }else{   
                isLogATicket = false;
            }
            
            if(objGridPortalProfile.Profile_Categories__c =='Support' || objGridPortalProfile.Profile_Categories__c=='Technical'){
                isReportAProblem = true;
            }  else {
                isReportAProblem = false;
            }
        }        
        
    }     
        public class wrapper{
        public integer serialNo {get;set;}
        public string label {get;set;}
        public boolean isBullet {get;set;}
        public List<wrapperData> lstwrapperData {get;set;}
        public wrapper(){
              lstwrapperData = new List<wrapperData>();
              serialNo = 0;          
        }
    }
    public class wrapperData{
        public string Value {get;set;}
        public string url {get;set;} 
        public string displayPageWindow {get;set;}
        public integer srno {get;set;}
        public string contentJustification {get;set;}
        public boolean IsLink{get;set;}      
        public boolean displayBullet {get;set;}
    }
    
    // Creating this map for each label and list of record with respect to that label.
    
   /* Map<string,List<GRID_Portal_Values__c>> mapLebelListOfRecord = new Map<string,List<GRID_Portal_Values__c>>();    */
   /* Map<string,List<Partner_Portal_Links__c>> mapLebelListOfRecordUpdated = new Map<string,List<Partner_Portal_Links__c>>();    
    public void init(){ 

        // Creating map from new Sobjects.
        Map<Id,Partner_Portal_Tab__c> mapIdandTabs = new Map<Id,Partner_Portal_Tab__c>([select Id,Name,Partner_PortalName__c from Partner_Portal_Tab__c where Name=:tabName AND Partner_PortalName__c =:[select Id from Partner_Portal__c where Name='GRID_VCA_Partner Portal' limit 1].Id]);
        
        // Get only those boxes which are part of assiged permission.
        // Adding a filter based on Box permission sets
        
        set<string> boxPermissionSets = new set<string>();
        for(PermissionSetAssignment psa :[SELECT AssigneeId,Id,PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment where AssigneeId=:UserInfo.getUserId()]){
             if(psa.PermissionSet.Name.contains('Box'))
             boxPermissionSets.add(psa.PermissionSet.Name);        
        }
        system.debug('-----------'+boxPermissionSets);
        set<Id> customPermissionSets = new set<Id>(); 
        for(Portal_Permission_Sets__c pms :[select Id,Name from Portal_Permission_Sets__c where Name in :boxPermissionSets]){
            customPermissionSets.add(pms.Id);
        }                
        system.debug('&&&&&&&&&&&'+customPermissionSets);        
        // List of those boxes which are assigned to the current user.
        Map<Id,Partner_Portal_Label__c> mapIdandLabels = new Map<Id,Partner_Portal_Label__c>([select Id,Name,Portal_Tab__c from Partner_Portal_Label__c where Permission_Set__c In:customPermissionSets]);
        system.debug('check----------'+mapIdandLabels);
        
        Map<Id,set<string>> boxIdAndSetOfTabs = new Map<Id,set<string>>();
        for(Partner_Portal_Label__c box :mapIdandLabels.values()){
            if(box.Portal_Tab__c != null){
                set<string> tabs = new set<string>();
                for(string val : box.Portal_Tab__c.split(';')){
                   tabs.add(val); 
                }   
                boxIdAndSetOfTabs.put(box.Id,tabs); 
            }
        }
        
        /*                
        for(Partner_Portal_Tab__c tabs :[select Id,Name,Partner_Portal_Box__c from Partner_Portal_Tab__c  where Partner_Portal_Box__c in :mapIdandLabels.keyset()]){
            if(boxIdAndSetOfTabs.get(tabs.Partner_Portal_Box__c)==null){
                boxIdAndSetOfTabs.put(tabs.Partner_Portal_Box__c,new set<string>());
            }boxIdAndSetOfTabs.get(tabs.Partner_Portal_Box__c).add(tabs.Name);
        }
        */
        
      /*  List<Partner_Portal_Links__c> lstPartner_Portal_Links = new List<Partner_Portal_Links__c>([select id,Name,Content_Justification__c,Display_Bullet__c,Is_Link__c ,Portal_Link_Name__c,Display_Page__c,Link_Serial_Number__c,Partner_Portal_Label__c,URL__c,URL1__c,
                                                                                                 Partner_Portal_Label__r.Name,Partner_Portal_Label__r.Display_Bullet__c,Partner_Portal_Label__r.Label_Serial_Number__c from Partner_Portal_Links__c
                                                                                                where Partner_Portal_Label__c In:mapIdandLabels.keySet() and Partner_Portal_Label__c in :boxIdAndSetOfTabs.keyset()]);        
                                                          
        system.debug('check list size'+lstPartner_Portal_Links.size());   
        system.debug('check list size'+lstPartner_Portal_Links);
        for(Partner_Portal_Links__c objGrid :lstPartner_Portal_Links){
                // Adding a check if the box is related to the current tab only then box will be display for that tab
                system.debug('Box Name-----'+objGRID.Partner_Portal_Label__r.Name+'check set-----'+boxIdAndSetOfTabs);
                if(boxIdAndSetOfTabs.get(objGRID.Partner_Portal_Label__c).contains(tabName)){                
                    if(mapLebelListOfRecordUpdated.get(objGRID.Partner_Portal_Label__r.Name)==null){
                        mapLebelListOfRecordUpdated.put(objGRID.Partner_Portal_Label__r.Name,new List<Partner_Portal_Links__c>());            
                    }mapLebelListOfRecordUpdated.get(objGRID.Partner_Portal_Label__r.Name).add(objGRID);        
                
                }                
        }system.debug('check------mapLebelListOfRecordUpdated'+mapLebelListOfRecordUpdated);                                           
        for(string label :mapLebelListOfRecordUpdated.keyset()){
            List<wrapperData> lstwrapperDataToSort = new List<wrapperData>();                   
            wrapper w = new wrapper();
            w.label = label.toUpperCase();                      
            List<Partner_Portal_Links__c> lstRecord = mapLebelListOfRecordUpdated.get(label);
            w.serialNo = integer.valueOf(lstRecord[0].Partner_Portal_Label__r.Label_Serial_Number__c);
            w.isBullet = lstRecord[0].Partner_Portal_Label__r.Display_Bullet__c;            
            for(Partner_Portal_Links__c gd :lstRecord){
               wrapperData wd = new wrapperData();
               wd.Value = gd.Portal_Link_Name__c;
               wd.displayPageWindow = gd.Display_Page__c;
               //wd.url = gd.URL__c;
               wd.url = gd.URL1__c;               
               wd.srno = integer.valueof(gd.Link_Serial_Number__c);
               wd.contentJustification  = gd.Content_Justification__c;
               wd.IsLink= gd.Is_Link__c ;
               wd.displayBullet = gd.Display_Bullet__c;
               lstwrapperDataToSort.add(wd);
               //w.lstwrapperData.add(wd); 
            }
            w.lstwrapperData =  sorting(lstwrapperDataToSort);                // Adding list of data which comes inside a box using sorting. 
            lstWrapper.add(w);            
        }    
        Integer num=0;
         
        
        // Return the list of wrapper class by sorting based on serialno.
        
        List<Wrapper> newSortedListWrapper = sorting(lstWrapper);        
        
        system.debug('newSortedListWrapper----------'+newSortedListWrapper);
        
        
        for(Integer idx=0; idx<newSortedListWrapper.size();idx++){
                                                                         
            List<Wrapper> lst_wrap = new List<Wrapper>();
            if(num!=idx){
                idx = num;
            }                                                                                  
            for(Integer j=0;j<3;j++){
               system.debug('Check index size'+idx+'check num'+num);                                                                         
               if(num<=idx && idx<newSortedListWrapper.size()){                                                            
                    lst_wrap.add(newSortedListWrapper[idx]);                        // Adding 3 record for each single row.                    
                    idx++;                    
                    num++;                                                     
                }                                                    
            }            
            lst_CustomWrap.add(new CustomWrap(lst_wrap));
            system.debug('Check last index'+idx);
            if(newSortedListWrapper.size()-idx==1){
                idx--; 
            }                                     
        }
        
    }
    
    
   
    // Method to show instance messages.    
    public void showInstanceMessage(){
        instanceMessage = '';
        List<GRID_VCA_Instant_Message__c>  lstInstanceMessage =  [SELECT Expiration_Date__c,Message__c,Start_Date__c FROM GRID_VCA_Instant_Message__c where Expiration_Date__c>today Order by Expiration_Date__c ASC limit 2];
        for(GRID_VCA_Instant_Message__c grMsg :lstInstanceMessage){        
            instanceMessage = instanceMessage+grMsg.Message__c;   
        }
        
    }
    
    // Wrapper class to pass all the data on visualforce page throught a list.  
    public class CustomWrap{
        public List<wrapper> lst_wrapper{get;set;}
        public CustomWrap(List<wrapper> lst_wrap){
            lst_wrapper = new List<wrapper>();
            lst_wrapper = lst_wrap;
        }
    }
    
    
    // Using this method to sort the wrapper class list based on the sequence number enter in records.    
     public list<Wrapper> sorting(list<Wrapper> currlist){
            integer j = 0;          
            Wrapper tmp = new Wrapper();  
            if(currlist.size()>1){           
                for(integer i=0;i<currlist.size();i++){
                    j = i;
                    system.debug('---currlist-----'+currlist[i]);
                    for(integer k = i;k<currlist.size();k++){               
                        if(currlist[j].serialNo  > currlist[k].serialNo){   
                            j = k;
                        }
                    }                    
                    tmp = currlist[i];
                    currlist[i] = currlist[j];
                    currlist[j] = tmp;
                }                
            }
            return currlist;  
    }
    
    // Using this method to sort the wrapperData class list based on the sequence number entered in records.    
     public list<WrapperData> sorting(list<WrapperData> currlist){
            integer j = 0;          
            WrapperData tmp = new WrapperData();  
            if(currlist.size()>1){           
                for(integer i=0;i<currlist.size();i++){
                    j = i;
                    system.debug('---currlist-----'+currlist[i]);
                    for(integer k = i;k<currlist.size();k++){               
                        if(currlist[j].srno  > currlist[k].srno){   
                            j = k;
                        }
                    }                    
                    tmp = currlist[i];
                    currlist[i] = currlist[j];
                    currlist[j] = tmp;
                }                
            }
            return currlist;
    }*/
 

}