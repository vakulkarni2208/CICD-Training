/******************************************************************************************
Name                : ImageFieldPopulator
Author              : Appirio Offshore(Aslam Bari)
Date                : June 04, 2010
Description         : This class does following functionalities
1. Fetches the default thumbnail and preview documents and create urls
2. Fetches ContentWorkspaceDoc where thumnail or preview is null or default
3. Fetches all Documents for retrieved LatestPublishedVersion.Title 
4. Then apply and updated the document's Thumbnail or Preview field as per following logic:
    a.  If the value in the field is not null or equal to the default image for that field, do not change it.  This field was set directly by a user or by our code on a previous run, and we do not want to modify it.
    b.  If the value in the field is null, and no matching document was found, insert the appropriate default url for that field.
    c.  If the value is the default, and no matching document was found, no change is required.
    d.  If the value is null or the default, and a matching document was found, update that field with the full path to download that document.

2017.11.29 - PJENA - Code Cleanup - ready to be deleted

******************************************************************************************/
public class ImageFieldPopulator{
	public ImageFieldPopulator(){}
	@isTest private static void test_TestHelp(){
    	ImageFieldPopulator obj1 = new ImageFieldPopulator();
	}
}