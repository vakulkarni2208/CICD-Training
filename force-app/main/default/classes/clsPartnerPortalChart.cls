public class clsPartnerPortalChart {
     
    string loginProfileName = ''; 
    String strUser = UserInfo.getUserName();     
    public clsPartnerPortalChart(){
        loginProfileName = [select Name from Profile where Id=:userinfo.getProfileId()].Name;
    }
    
    //Returns leads data grouped by lead status where the logged in user is the owner of the lead records
    //This data is used for pie charts    
    public List<PieWedgeDataClass> getPieDataLeads() {
        Date d = date.newInstance(2012, 1, 1);
        
        //List<AggregateResult> lstLead = [select Status, COUNT(id) Total from Lead where owner.UserName =: strUser and CreatedDate>= :d AND RecordType.Name='Partner Lead' Group by Status];
        List<AggregateResult> lstLead = [select Status, COUNT(id) Total from Lead where owner.UserName =: strUser and CreatedDate>= :d Group by Status];        
        List<PieWedgeDataClass> data = new List<PieWedgeDataClass>();
        for(AggregateResult a : lstLead) {
             data.add(new PieWedgeDataClass(String.valueOf(a.get('Status')) + ': ' + String.valueOf(a.get('Total')) , Integer.valueOf(a.get('Total'))));
        }
        return data;
    }
     
    public class PieWedgeDataClass {
        public String leadStatus { get; set; }
        public Integer leaddata { get; set; }        
    
        public PieWedgeDataClass(String leadStatus, Integer leaddata) {
            this.leadStatus = leadStatus;   
            this.leaddata = leaddata;            
        }
    } 

    //Returns leads data grouped by lead owner for the logged in user's account
    //This data is used for pie charts    
    public List<PieWedgeDataLeadsByOwnerClass> getPieDataLeadsByOwner() {      
        Date d = date.newInstance(2012, 1, 1);
        
        //Returns the account of the current logged in user        
        List<Contact> lstUserAccount = [select accountid from contact where id IN (select user.contactid from user where user.UserName =: strUser) limit 1];
        
        List<User> lstUsers = new List<User>();      
        if (!lstUserAccount.isEmpty()) {
            for (Contact acc : lstUserAccount) {        
               lstUsers = [select id from user where contactid in (select id from contact where accountid =: String.valueOf(acc.get('accountid')))];          
            }
        } 
         
        List<AggregateResult> lstLead = new List<AggregateResult>();    
        
        List<String> lstUserIDs = new List<String>();
        
        if (!lstUsers.isEmpty()) {
            for (User usr : lstUsers) {        
                 lstUserIDs.add(String.valueOf(usr.get('id')));            
            }

            //lstLead = [select Owner.Name OwnerName, COUNT(id) Total from Lead where owner.id in :lstUserIds and CreatedDate>= :d AND RecordType.Name='Partner Lead' Group by Owner.Name];
            lstLead = [select Owner.Name OwnerName, COUNT(id) Total from Lead where owner.id in :lstUserIds and CreatedDate>= :d Group by Owner.Name];            
        } 

        List<PieWedgeDataLeadsByOwnerClass> data = new List<PieWedgeDataLeadsByOwnerClass>();
        for(AggregateResult a : lstLead) {
             data.add(new PieWedgeDataLeadsByOwnerClass(String.valueOf(a.get('OwnerName')) + ': ' + String.valueOf(a.get('Total')) , Integer.valueOf(a.get('Total'))));
        }
        return data;
    }
     
     public class PieWedgeDataLeadsByOwnerClass{
        public String leadOwner { get; set; }
        public Integer leaddata { get; set; }        

        public PieWedgeDataLeadsByOwnerClass(String leadOwner, Integer leaddata) {
            this.leadOwner = leadOwner;
            this.leaddata = leaddata;            
        }
    }      
    
     //Returns opportunity data grouped by stagename where the logged in user is the owner of the lead records
    //This data is used for pie charts 
    public List<PieWedgeDataClassOppportuntiesStage> getPieDataOppportuntiesStage() {
        Date d = date.newInstance(2012, 1, 1);
        //List<AggregateResult> lstOpportunities = [select StageName, Count(id) Total from Opportunity where owner.UserName =: strUser and  CreatedDate>=:d AND RecordType.Name='Tesla Partner Opportunity' Group By StageName Order By StageName DESC];
        List<AggregateResult> lstOpportunities = [select StageName, Count(id) Total from Opportunity where owner.UserName =: strUser and  CreatedDate>=:d Group By StageName Order By StageName DESC];        
        List<PieWedgeDataClassOppportuntiesStage > data = new List<PieWedgeDataClassOppportuntiesStage>();
        for(AggregateResult a : lstOpportunities ) {
             data.add(new PieWedgeDataClassOppportuntiesStage(String.valueOf(a.get('StageName')) + ': ' + String.valueOf(a.get('Total')) , Integer.valueOf(a.get('Total'))));
        }
        return data;
    }
    
    public class PieWedgeDataClassOppportuntiesStage {
        public String stage { get; set; }
        public Integer data { get; set; }        
         public PieWedgeDataClassOppportuntiesStage(String stage, Integer data) {
                this.stage = stage;
                this.data = data; 
         }
     }
     

    //Returns opportunities data grouped by opportunity owner for the logged in user's account
    //This data is used for pie charts    
    public List<PieWedgeDataOpportunityByOwnerClass> getPieDataOpportunitiesByOwner() {      
        Date d = date.newInstance(2012, 1, 1);
        
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

            //lstOpportunities = [select Owner.Name OwnerName, COUNT(id) Total from Opportunity where owner.id in :lstUserIds and CreatedDate>= :d AND RecordType.Name='Tesla Partner Opportunity' Group by Owner.Name];
            lstOpportunities = [select Owner.Name OwnerName, COUNT(id) Total from Opportunity where owner.id in :lstUserIds and CreatedDate>= :d Group by Owner.Name];        } 

        List<PieWedgeDataOpportunitybyOwnerClass> data = new List<PieWedgeDataOpportunitybyOwnerClass >();
        for(AggregateResult a : lstOpportunities){
             data.add(new PieWedgeDataOpportunitybyOwnerClass (String.valueOf(a.get('OwnerName')) + ': ' + String.valueOf(a.get('Total')) , Integer.valueOf(a.get('Total'))));
        }
        return data;
    }
          
     public class PieWedgeDataOpportunitybyOwnerClass {
        public String opportunityOwner{ get; set; }
        public Integer data { get; set; }        
         public PieWedgeDataOpportunitybyOwnerClass (String opportunityOwner, Integer data) {
                this.opportunityOwner= opportunityOwner;
                this.data = data; 
         }
     }
     
}