@isTest
private class Test_clsPartnerPortalChart {

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
                                                                
        clsPartnerPortalChart obj = new clsPartnerPortalChart ();
        obj.getPieDataLeads();
        obj.getPieDataLeadsByOwner();
        obj.getPieDataOppportuntiesStage();
        //obj.getPieDataOppportuntiesStage1();
        clsPartnerPortalChart.PieWedgeDataClassOppportuntiesStage objwrap = new  clsPartnerPortalChart.PieWedgeDataClassOppportuntiesStage('Prospecting',3);
        //chartController.PieWedgeDataClassOpportunitybyOwner objwrap1 =  new chartController.PieWedgeDataClassOpportunitybyOwner('Sushma',3);
        clsPartnerPortalChart.PieWedgeDataLeadsByOwnerClass wrap2 = new clsPartnerPortalChart.PieWedgeDataLeadsByOwnerClass('sushma',3);
        clsPartnerPortalChart.PieWedgeDataClass wrap3 = new clsPartnerPortalChart.PieWedgeDataClass('Qualified',4);        
        clsPartnerPortalChart.PieWedgeDataOpportunitybyOwnerClass wrap4 = new clsPartnerPortalChart.PieWedgeDataOpportunitybyOwnerClass(UserInfo.getUserName(),10);
        obj.getPieDataOpportunitiesByOwner();
        //}
        //chartController.PieWedgeDataClass objPieWedgeDataClass = new chartController.PieWedgeDataClass();
    }
}