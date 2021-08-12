@isTest(seeAllData=false)
private class NV_Test_LtgPicklistController {

	@isTest
	static void picklistTest() {
		NV_LtgPicklistController.getPickListValuesIntoList('Account','AccountSource');
	}
}