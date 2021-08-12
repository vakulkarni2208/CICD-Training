@isTest
private class Test_chartController1 {

    static testMethod void myUnitTest() {
    
        User u = [select Id from User where isActive=true and Profile.Name='System Administrator' limit 1];
        
        //system.runAs(u){                
        RecordType rt = [select Id from RecordType where Name='Partner Lead' and SobjectType='Lead'];
        Lead leadObj = new Lead ();
        leadObj.RecordTypeId = rt.Id;
        leadObj.LastName = 'LeadLastName';
        leadObj.Company = 'CompanyName';
        leadObj.LeadSource  = 'Email';        
        insert leadObj;
        
        Lead leadObj1 = new Lead ();
        leadObj1.RecordTypeId = rt.Id;
        leadObj1.LastName = 'LeadLastName';
        leadObj1.Company = 'CompanyName';
        leadObj1.LeadSource  = 'Email';
        leadObj1.status  = 'Qualified';        
        insert leadObj1;
                                                                
        chartController obj = new chartController ();
        obj.getPieDataLeads();
        obj.getPieDataLeadsByOwner();
        obj.getPieDataOppportuntiesStage();
        //obj.getPieDataOppportuntiesStage1();
        chartController.PieWedgeDataClassOppportuntiesStage objwrap = new  chartController.PieWedgeDataClassOppportuntiesStage('Prospecting',3);
        //chartController.PieWedgeDataClassOpportunitybyOwner objwrap1 =  new chartController.PieWedgeDataClassOpportunitybyOwner('Sushma',3);
        chartController.PieWedgeDataLeadsByOwnerClass wrap2 = new chartController.PieWedgeDataLeadsByOwnerClass('sushma',3);
        chartController.PieWedgeDataClass wrap3 = new chartController.PieWedgeDataClass('Qualified',4);        
        chartController.PieWedgeDataOpportunitybyOwnerClass wrap4 = new chartController.PieWedgeDataOpportunitybyOwnerClass(UserInfo.getUserName(),10);
        obj.getPieDataOpportunitiesByOwner();
        //}
        //chartController.PieWedgeDataClass objPieWedgeDataClass = new chartController.PieWedgeDataClass();
    }
}