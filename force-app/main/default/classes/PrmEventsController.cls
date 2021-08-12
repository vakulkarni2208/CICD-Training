/**
 * Returns PRM_Training_And_Events__c that should appear on a customized partner
 * portal homepage.
 *
 * @author tschulte@appirio.com
 * @date 06-08-2010
 */
public class PrmEventsController 
{
	public List<PRM_Training_and_Events__c> getEvents() 
	{
		return [SELECT Id, External_URL__c, Name, Date_Display__c, Location__c, Description__c, Html__c, Use_Html__c, Use_Description__c, Use_Image__c, Image__c
					  FROM PRM_Training_and_Events__c 
					  WHERE Sort_Order__c != null 
					  ORDER BY Sort_Order__c];
	}
 
 	@isTest
 	public static void testGetEvents() 
 	{
 		PrmEventsController controller = new PrmEventsController();
 		controller.getEvents();		
 	}
}