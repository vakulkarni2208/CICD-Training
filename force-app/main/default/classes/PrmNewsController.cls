/**
 * Returns PRM_Recent_News__c  that should appear on a customized partner
 * portal homepage.
 *
 * @author tschulte@appirio.com
 * @date 06-08-2010
 */
public class PrmNewsController 
{
	public List<PRM_Recent_News__c> getNews() 
	{
		return [SELECT Id, Image__c, News_Text__c FROM PRM_Recent_News__c WHERE Sort_Order__c != null ORDER BY Sort_Order__c ASC];
	}

	@isTest
	public static void testGetNews()
	{
		PrmNewsController controller = new PrmNewsController();
		controller.getNews();
	}
}