@isTest(seeAllData=false)
private class NV_Test_LtgCommunitySearchController {

	@IsTest
	static void methodName(){

		Test.startTest();
		NV_LtgCommunitySearchController.CommunitySearchWrapper clsObj = new NV_LtgCommunitySearchController.CommunitySearchWrapper();

		clsObj = NV_LtgCommunitySearchController.CommunitySearchWrapper.search('test');
		System.assert (clsObj != null,'success');
		Test.stopTest();

	}
}