/*
    ChangeList:
    2016.12.13 - PJENA - Opp Reg - TAM ownership
    2017.07.19 - PJENA - Show Opptys to Alt Partnner Owner in Views and Google Chart

*/
global with sharing class clsPartnerPortalChartGoogle{
     
    string loginProfileName = ''; 
    string strUser = UserInfo.getUserName();
    string idOwnerLeadsReport;
    string idAccountLeadsReport;     
    
    public clsPartnerPortalChartGoogle(){
        loginProfileName = [select Name from Profile where Id=:userinfo.getProfileId()].Name;
    }

    @RemoteAction 
    //owner leads for charting
    global static AggregateResult[] loadLeadsByStatus() {
        Date d = date.newInstance(2009, 1, 1);
        String strUser = UserInfo.getUserName();
        //strUser = 'eliote@microway.com.tempstage2';
        return[select Status, COUNT(id) Total from Lead where ownerId = :UserInfo.getUserId() and CreatedDate>= :d and isConverted = false Group by Status];
        //return null;
    }
    
    @RemoteAction
    //owner opportunities for charting
    global static AggregateResult[] loadOpportunitiesByStage() {
        Date d = date.newInstance(2009, 1, 1);
        String strUser = UserInfo.getUserName();
        //strUser = 'eliote@microway.com.tempstage2';
        //2016.12.13 - PJENA - Opp Reg - TAM ownership
        //2017.07.19 - PJENA - Show Opptys to Alt Partnner Owner in Views and Google Chart
        return[select StageName, Count(id) Total from Opportunity where ownerId = :UserInfo.getUserId() and  CreatedDate>=:d Group By StageName Order By StageName DESC];
    }
    
    @RemoteAction 
    //account leads for charting
    global static AggregateResult[] loadLeadsByOwner() {
        Date d = date.newInstance(2009, 1, 1);
        String strUser = UserInfo.getUserName();
        string idReportID;
        //strUser = 'eliote@microway.com.tempstage2';
        
        //Returns the report ID to link the pir chart slice to
        List<Partner_Portal_Reports__c> lstAccountLeadsReport = [select Report_ID__c from Partner_Portal_Reports__c Where Report_Name__c = 'Account Leads by Status' limit 1];
        if  (!lstAccountLeadsReport.isEmpty()) {
            for (Partner_Portal_Reports__c rpt : lstAccountLeadsReport) {
                 idReportID = String.valueOf(rpt.get('Report_ID__c'));
            }
        }
        
        //Returns the account of the current logged in user        
        List<Contact> lstUserAccount = [select accountid from contact where id IN (select user.contactid from user where user.UserName =: strUser) limit 1];
        
        List<User> lstUsers = new List<User>();      
        if (!lstUserAccount.isEmpty()) {
            for (Contact acc : lstUserAccount) {        
               lstUsers =[select id from user where contactid in (select id from contact where accountid =: String.valueOf(acc.get('accountid')))];          
            }
        } 
         
        List<AggregateResult> lstLead = new List<AggregateResult>();    
        
        List<String> lstUserIDs = new List<String>();
        
        if (!lstUsers.isEmpty()) {
            for (User usr : lstUsers) {
                 lstUserIDs.add(String.valueOf(usr.get('id')));
            }
            lstLead = [select Owner.Name OwnerName, COUNT(id) Total from Lead where owner.id in :lstUserIds and CreatedDate>= :d and isConverted = false Group by Owner.Name];
        }
        //return[select Owner.Name OwnerName, COUNT(id) Total from Lead where owner.id in :lstUserIds and CreatedDate>= :d Group by Owner.Name];
        //Get the leads by owner report name for opening the report on click of the chart
        return lstLead;
        
    }
    
   
    
    @RemoteAction
    //account opportunities for charting
    global static AggregateResult[] loadOpportunitiesByOwner() {
        Date d = date.newInstance(2009, 1, 1);
        String strUser = UserInfo.getUserName();
        //strUser = 'eliote@microway.com.tempstage2';
        //Returns the account of the current logged in user        
        List<Contact> lstUserAccount = [select accountid from contact where id IN (select user.contactid from user where user.UserName =: strUser) limit 1];
        
        List<User> lstUsers = new List<User>();      
        if (!lstUserAccount.isEmpty()) {
            for (Contact acc : lstUserAccount) {        
               lstUsers = [select id from user where contactid in (select id from contact where accountid =: String.valueOf(acc.get('accountid')))];          
            }
        } 
         
        List<AggregateResult> lstOpportunities = new List<AggregateResult>();    
        
        List<String> lstUserIDs = new List<String>();
        
        if (!lstUsers.isEmpty()) {
            for (User usr : lstUsers) {        
                 lstUserIDs.add(String.valueOf(usr.get('id')));            
            }
        }
        //2016.12.13 - PJENA - Opp Reg - TAM ownership - change criteria from Owner to Creator
        return[select Owner.Name OwnerName, COUNT(id) Total from Opportunity where owner.id in :lstUserIds and CreatedDate>= :d Group by Owner.Name];
        //return[select CreatedBy.Name OwnerName, COUNT(id) Total from Opportunity where CreatedBy.id in :lstUserIds and CreatedDate>= :d Group by CreatedBy.Name];
   } 
}