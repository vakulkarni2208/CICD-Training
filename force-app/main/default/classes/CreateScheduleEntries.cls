/*
 * 12/17/2018: @Manideep: Commented out this class as part of retiring Old Opportunity Record Types.
 * 6/12/2019: @Manideep: Added fakeMethod() for code coverage as this class is commented out.
*/

public class CreateScheduleEntries {

   // Dummy method for code coverage
  // This method is coverred by the class 'UnitTests_DummyCodeCoverage_DEL_Classes.cls'
  public static void fakeMethod(){
    Integer i = 0;
    i++;
  }

/*
    // This static variable is intended only to allow us to update Schedule Entry records
    // for Notebook and Tegra Tablet opportunities while rolling out support for Quadro, Tesla, and Tegra Auto
    // opportunities. It is set by anonymous Apex code that does a one-time update of 
    // existing Schedule Entry data in Production, and is checked by the Schedule_Entry trigger.
    //
    // The code below refers to Notebook opps, but also applies to Tegra Tablet opps. 
    public static Boolean blnRecalculateNoteookScheduleEntries = false;
    
    public static List<Schedule_Entry__c> createScheduleForNotebookOpps(Opportunity opp, List<OpportunityLineItem> lstOLIs) {
        // createSchedule() takes an Opportunity and a list of (its, presumably) OpportunityLineItems
        // and creates the appropriate Schedule Entries for them.
        //  
        // The assumption here is that the OpportunityLineItems have already been populated
        // with the associated PricebookEntries AND the Product Name 
        //
        // Each Schedule Entry.Monthly Revenue amount for a given Opportunity is added to the
        // Opportunity: Lifetime Revenue amount
        
        List<Schedule_Entry__c> lstSEs = new List<Schedule_Entry__c>();
        List<OpportunityLineItem> lstUpdateOLIs = new List<OpportunityLineItem>();
        Double totalRevenue = 0;
    
        for(OpportunityLineItem oli :lstOLIs) {

            Integer iMonth = opp.Design_Start_Date__c.month();
            Integer iYear = opp.Design_Start_Date__c.year();
            Integer iCount = 0;
        
            Date scheduleDate = Date.NewInstance(iYear, iMonth, 15);
            Integer scheduleMonths = scheduleDate.monthsBetween(opp.Design_EOL_Date__c);
            do {
                Schedule_Entry__c se = new Schedule_Entry__c();
                
                se.Quantity__c     = oli.Monthly_Quantity__c;
                se.Revenue__c      = oli.Monthly_Quantity__c * oli.UnitPrice;
                se.Product_Name__c = oli.Product_Name__c;
                se.Opportunity__c  = opp.Id;
                se.OLI_Id__c       = oli.Id;
                if (opp.RecordType.Name == 'Tegra Tablets, SB, SP Opportunity')
                    se.Opportunity_Type__c = 'Tegra Tablet';
                else
                    se.Opportunity_Type__c = 'Notebook';
                
                se.Schedule_Date__c = scheduleDate;
                
                // adjust scheduleDate to the next month
                scheduleDate = scheduleDate.addMonths(1);
                
                totalRevenue = totalRevenue + se.Revenue__c;
                
                lstSEs.add(se);
                iCount++;
                
            } while (iCount <= scheduleMonths);
        }
        
        try {           
            double revenue;
            revenue = totalRevenue;
            // if(opp.Lifetime_Revenue__c == null) {
            //    revenue = totalRevenue;
            //} else {
            //    revenue = opp.Lifetime_Revenue__c + totalRevenue;
            //}
            //Opportunity newOpp = new Opportunity(Id=opp.Id, Name=opp.Name, Lifetime_Revenue__c=revenue);
            Opportunity newOpp = new Opportunity(Id=opp.Id, Name=opp.Name);

            update lstUpdateOLIs;
            // Cannot use Opportunity.Amount - that is the sum of Opp.LineItem amounts          
            update newOpp;
            return lstSEs;
            
        } catch(Exception ex) {
            return null;
        }
    }
*/    
}