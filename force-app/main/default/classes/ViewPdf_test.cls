@isTest(seeAllData=false)
private class ViewPdf_test {
	@isTest static void testViewPdf(){

		ContentVersion cv = new ContentVersion();
		cv.title = 'test content trigger';
		cv.PathOnClient ='test';
		cv.VersionData = Blob.valueOf('beforeblob');
		cv.IsMajorVersion = true;
		insert cv;

		ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
		test.startTest();

		PageReference pageRef = Page.ViewPdf;
		Test.setCurrentPageReference(pageRef);
		ApexPages.currentPage().getParameters().put('id',document.Id);
		ViewPdf ctlr = new ViewPdf();
		ContentVersion cvObj = ctlr.att;
		String strPdf = ctlr.pdf;
		test.stopTest();

	}
}