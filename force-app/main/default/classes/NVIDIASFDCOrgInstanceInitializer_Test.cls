/*
	2019.08.14 - Test class for Sandbox Initializer "NVIDIASFDCOrgInstanceInitializer" - runs automatic after the completion of sandbox referesh
		
 */
@isTest(SeeAllData=false)
private class NVIDIASFDCOrgInstanceInitializer_Test {

   @isTest static void testMySandboxPrep(){
        // Insert logic here to create records of the objects that the class you’re testing
        // manipulates.

        Test.startTest();

        Test.testSandboxPostCopyScript(
            new NVIDIASFDCOrgInstanceInitializer(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());

        Test.stopTest();

        // Insert assert statements here to check that the records you created above have
        // the values you expect.
    }
}