/******************************************************************************************
Name                : SearchMarketingToolCategory
Author              : Appirio Offshore(Aslam Bari)
Date                : June 07, 2010
Description         : This class does following functionalities
1. Fetches the contentworkspace docs into given workspace
2. Creates one set with unique Asset_Type__c 
3. Creates one map with unique Product_Family__c and thier associated products
4. Create one xml document with the information retrieved
5. Updates the 'SearchMarketingToolCategories_xml' Document with xml data
6. This doc then used in Marketing Tools Browser left side

2017.11.29 - PJENA - Code Cleanup - ready to be deleted

******************************************************************************************/
public class SearchMarketingToolCategory{
	public SearchMarketingToolCategory(){}
	
	@isTest private static void test_TestHelp(){
		SearchMarketingToolCategory obj1 = new SearchMarketingToolCategory();
	}
	
}