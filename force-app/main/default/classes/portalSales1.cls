public class portalSales1 {   
    
    public string instanceMessage {get;set;}
    public List<wrapper> lstWrapper {get;set;}
    public List<CustomWrap> lst_CustomWrap{get;set;}
    public string tabName {get;set;}
    public boolean isLogATicket {get;set;}
    
    public portalSales1(){
        tabName = ApexPages.CurrentPage().getParameters().get('tab');
        lstWrapper = new List<wrapper>();
        lst_CustomWrap = new List<CustomWrap>();
        //if(!test.isRunningTest())
        init();
        showInstanceMessage();
                
        string profileName = [select  Id,Profile.Name from user where Id =:UserInfo.getUserId()].Profile.Name;  
        GRID_Portal_Profiles__c objGridPortalProfile = [select Profile_Categories__c from GRID_Portal_Profiles__c where Name=:profileName];
        
        if(objGridPortalProfile.Profile_Categories__c == 'Support'){
            isLogATicket = true;
        }else{
            isLogATicket = false;
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
    }
    
    // Creating this map for each label and list of record with respect to that label.
    
   /* Map<string,List<GRID_Portal_Values__c>> mapLebelListOfRecord = new Map<string,List<GRID_Portal_Values__c>>();    */
    Map<string,List<Partner_Portal_Links__c>> mapLebelListOfRecordUpdated = new Map<string,List<Partner_Portal_Links__c>>();    
    public void init(){ 

        // Creating map from new Sobjects.
        Map<Id,Partner_Portal_Tab__c> mapIdandTabs = new Map<Id,Partner_Portal_Tab__c>([select Id,Name,Partner_PortalName__c from Partner_Portal_Tab__c where Name=:tabName AND Partner_PortalName__c =:[select Id from Partner_Portal__c where Name='GRID_VCA_Partner Portal' limit 1].Id]);
        Map<Id,Partner_Portal_Label__c> mapIdandLabels = new Map<Id,Partner_Portal_Label__c>([select Id,Name,Partner_Portal_Tab__c from Partner_Portal_Label__c where Partner_Portal_Tab__c In:mapIdandTabs.keyset()]);
        
        
        
        List<Partner_Portal_Links__c> lstPartner_Portal_Links = new List<Partner_Portal_Links__c>([select id,Name,Portal_Link_Name__c,Display_Page__c,Link_Serial_Number__c,Partner_Portal_Label__c,URL__c,
                                                                                                Partner_Portal_Label__r.Name,Partner_Portal_Label__r.Display_Bullet__c,Partner_Portal_Label__r.Label_Serial_Number__c from Partner_Portal_Links__c
                                                                                                where Partner_Portal_Label__c In:mapIdandLabels.keySet() AND 
                                                                                                (Partner_Portal_Label__r.GRID_Portal_Profile__r.Name=:[select Name from Profile where Id=:userinfo.getProfileId()].Name)]);        
          
             
        
        system.debug('check list size'+lstPartner_Portal_Links.size());
                system.debug('check list size'+lstPartner_Portal_Links);
        for(Partner_Portal_Links__c objGrid :lstPartner_Portal_Links){
                if(mapLebelListOfRecordUpdated.get(objGRID.Partner_Portal_Label__r.Name)==null){
                    mapLebelListOfRecordUpdated.put(objGRID.Partner_Portal_Label__r.Name,new List<Partner_Portal_Links__c>());            
                }mapLebelListOfRecordUpdated.get(objGRID.Partner_Portal_Label__r.Name).add(objGRID);        
        }
        
        
        // Using two object to maintain the dynamic box         
        /*
        List<GRID_Portal_Values__c> lstGRID_Portal_Values = new List<GRID_Portal_Values__c>([select Id,Name,GRID_Portal_Tabs__c,Display_Page__c,GRID_Portal_Tabs__r.GRID_Label_Name__c,GRID_Portal_Tabs__r.GRID_label_Serial_Number__c,GRID_Portal_Tabs__r.GRID_Portal_Profile__r.Name,GRID_Value_Serial_Number__c,Value_URL__c from GRID_Portal_Values__c where GRID_Portal_Tabs__r.Name=:tabName and GRID_Portal_Tabs__r.GRID_Portal_Profile__r.Name=:[select Name from Profile where Id=:userinfo.getProfileId()].Name]);        
        system.debug('Check values'+lstGRID_Portal_Values);               
        for(GRID_Portal_Values__c objGRID :lstGRID_Portal_Values){            
            if(mapLebelListOfRecord.get(objGRID.GRID_Portal_Tabs__r.GRID_Label_Name__c)==null){
                mapLebelListOfRecord.put(objGRID.GRID_Portal_Tabs__r.GRID_Label_Name__c,new List<GRID_Portal_Values__c>());            
            }mapLebelListOfRecord.get(objGRID.GRID_Portal_Tabs__r.GRID_Label_Name__c).add(objGRID);
        }
        */
        
               
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
               wd.url = gd.URL__c;
               wd.srno = integer.valueof(gd.Link_Serial_Number__c);
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
    }
    

}