/******************************************************************************************
Name                : UpdateSearchMarketingToolDoc
Author              : Appirio Offshore(Aslam Bari)
Date                : June 04, 2010
Description         : This class does following functionalities
1. Fetches the Lastest updated/added contentworkspace docs
2. Create one xml file with the information of docs
3. Updates the 'SearchMarketingToolOutput_xml' Document with xml data
4. This doc then used in Flash component to show SearchMarketingTool File list
5. This class is being called by Scheduler named 'ScheduleSearchMarketingToolJob'

2017.11.29 - PJENA - Code Cleanup - ready to be deleted

******************************************************************************************/
public class UpdateSearchMarketingToolDoc{
	public UpdateSearchMarketingToolDoc(){}
	
	@isTest private static void test_TestHelp(){
		UpdateSearchMarketingToolDoc obj1 = new UpdateSearchMarketingToolDoc();
	}
}