/*
    2021.04.01 - PJENA - Test class for Opp_NPNOEMODMDISTI_Event_Tracker_Bat
*/

@isTest(SeeAllData=true)
public class Opp_NPNOEMODMDISTI_Evnt_Tracker_Bat_Test {
    
    static testMethod void testCreateOppty(){
        //Delete all records from tracker
        string EVENTNAME = 'NPNOEMODMDISTI';
        List<Platform_Event_Tracker_Processor__c> lstEventsToDel =  [SELECT Id
                                                                        FROM Platform_Event_Tracker_Processor__c
                                                                        WHERE EventName__c = :EVENTNAME];
        database.delete(lstEventsToDel, false);


        //Create new Oppotunity
        Opportunity oppReg = SOQ_OppReg_Test_Factory.createOpportunity('OppRegForNPNSharing');
        
        Test.startTest();
            Opp_NPNOEMODMDISTI_Event_Tracker_Bat p = new Opp_NPNOEMODMDISTI_Event_Tracker_Bat();
            Database.BatchableContext     bc;
            Database.QueryLocator ql = p.start(bc);
            DateTime currDT = DateTime.now().addMinutes(2);
            integer sec = currDT.second();
            integer min = currDT.minute();
            string sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
            system.debug('sch: ' + sch);
            system.schedule('Exec of Opp_NPNOEMODMDISTI_Event_Tracker_Bat', sch, p);                
        Test.stopTest();            
    }
}