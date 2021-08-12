/*
** Class:  OpportunityReport_Controller
** Created by OpFocus on 02/24/2011
** Description: Controller for the OpportunityReport page
**
**	This page and controller construct a report (in either HTML or CSV formats) that 
**	displays lots of columns of data for the Opportunities in the selected list view. 
**	
**	All Opps in the list view must be of the same record type. Only Quadro, Tesla, and 
**	Tegra Auto/Emb record types are supported.
**	
**	The page uses a custom setting (OpportunityReportPreferences__c) to store the 
**	user's most recent list view selection and output format selection, so we can 
**	display it the next time the page is loaded.
**	
**	When written in the most straightforward way, this controller frequently encountered 
**	governor limits when called with a list view that identified few hundred or more 
**	Opps. So we had to write it in a less straightforward way, in order to avoid governor 
**	limits. The general logic to generate a report is:
**	
**	Pre-Processing - when the user selects a list view, we collect the Opp Ids for that 
**	list view, verify that the Opps are of the correct record type, and display the 
**	count for the user.
**	
**	Part 1 - Fetch the Ids of the Opps, their OLI data, and their Schedule Entries.
**	
**	Part 2 - For a limited number of those Opps, fetch the full set of Opp fields, 
**	then generate the output for those Opps. The page uses AJAX to call the controller 
**	multiple times until all the Opps have been processed.
**	
**	Part 3 - Return the results to the browser.
**
* @Manideep: 5/8/2019 - This code is commented as its not being used and in the process of Opportunity RecordType Cleanup.
*/    
public with sharing class OpportunityReport_Controller {

  // Dummy method for code coverage
  // This method is coverred by the class 'UnitTests_DummyCodeCoverage_DEL_Classes.cls'
  public static void fakeMethod(){
    Integer i = 0;
    i++;
  }

/*
	ApexPages.StandardSetController stdController;

	public List<Id> lstOppIds = new List<Id>();
	
	public String  format         {get; set;}  // browser or csv
	public Boolean repeatData     {get; set;}
	public OpportunityReportPreferences__c prefs {get; set;}

	public Integer numOpps        {get; private set;}
	public Integer numRecordTypes {get; private set;}
	public String  recordTypeName {get; private set;}
	public Boolean pageError      {get; private set;}
	public Boolean recordTypeOk   {get; private set;}

	public Integer numRows        {get; private set;}
	public Integer currentRowNum  {get; private set;}
	public Boolean doneWithOpps   {get; private set;}
	public String  lastPartDone   {get; private set;}  // '', '1', '2', or '3'

	public String  strPartialResults {get; private set;}
	public String  strResults        {get; private set;}

	public List<String>       lstQuarters             {get; private set;}
	public List<SelectOption> lstQuarterSelectOptions {get; private set;}
	public String             startingQuarter         {get; set;}
	public String             endingQuarter           {get; set;}
	
	public Boolean showIdField = false;

	// Initialized in runReportPart1, and used in runReportPart*:
	List<Opportunity> lstOpportunities;
	List<RowData>     lstRowData;
	List<String> lstQuartersToShow;
	List<String> lstFieldsAndLabels;

	
	public Boolean renderAsCsv {
		get {
			Boolean ret = (format == 'csv') && (lastPartDone == '3');
			return ret;
		}
	}


	public OpportunityReport_Controller(ApexPages.StandardSetController stdController) {
		this.stdController = stdController;
		pageError = false;
		doneWithOpps = false;
		lastPartDone = '';
		strResults = '';
		strPartialResults = '';

		// If the user has any saved preferences, load them
		prefs = getSavedPreferences();
		stdController.setFilterId(prefs.FilterId__c);
		format = prefs.Format__c;
		repeatData = prefs.Show_Repeated_Data__c;
		startingQuarter = prefs.Starting_Quarter__c;
		endingQuarter = prefs.Ending_Quarter__c;
		
		// Pretend the user just selected a List View
		selectListView();
	}
	
	
	// The user has selected a new List View
	public PageReference selectListView() {
		
		doneWithOpps = false;
		recordTypeOk = false;
		
		// Get all of the Opps for the list view
		List<Opportunity> lstOpps = new List<Opportunity>();
		lstOppIds = new List<Id>();
		Boolean blnFirst = true;
		stdController.first();
		do {
			if (!blnFirst) stdController.next(); 
			lstOpps.addAll((List<Opportunity>)stdController.getRecords());
			blnFirst = false;
		} while (stdController.getHasNext());

		// If we're running in the context of a unit test, get only specific opps
		if (Test.isRunningTest()) {
			lstOpps = [select id from Opportunity where RecordType.Name = 'Quadro Sales Opportunity' limit 10];
		}

		// Remember all the Opp Ids
		for (Opportunity opp : lstOpps) lstOppIds.add(opp.id);

		numOpps = lstOpps.size();
		
		// Make sure all of the Opps are of the same record type, and that it's a 
		// supported record type
		List<AggregateResult> lstARs =
		  [select count(id) cnt, RecordTypeId from Opportunity where id in :lstOppIds group by RecordTypeId];
		  
		numRecordTypes = lstARs.size();
		if (numOpps == 0) {
			pageError = true;
			String str = 'The list view you selected does not include any Opportunities. ' +
			             'Please select another list view.';
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
			ApexPages.addMessage(msg);					
			return null;
		}
		else if (numRecordTypes > 1) {
			pageError = true;
			String str = 'The list view you selected includes more than one type of Opportunity. ' +
			             'Please select another list view.';
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
			ApexPages.addMessage(msg);					
			return null;
		}

		// Remember the Record Type
		recordTypeName = 
		  [select Name from RecordType 
		   where  SObjectType = 'Opportunity' 
		   and    Id = :(String)lstARs[0].get('RecordTypeId')].Name;
		  
		if (recordTypeName != 'Quadro Sales Opportunity' &&
		    recordTypeName != 'Tesla Sales Opportunity' &&
		    recordTypeName != 'Tegra Auto and Emb Opportunity') {
			pageError = true;
			String str = 'The list view you selected includes "' + recordTypeName + '" Opportunities, which are not supported by this report. ' +
			             'Please select another list view.';
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
			ApexPages.addMessage(msg);					
			return null;
		}
		
		recordTypeOk = true;

		// Get the starting and ending quarters
		String startingQuarterSwapped; 
		String endingQuarterSwapped;
		
		try {
			startingQuarterSwapped = 
			  [select Display_Quarter_Sortable__c from Schedule_Entry__c 
			   where  Opportunity__c in :lstOppIds order by Display_Quarter_Sortable__c      
			   limit  1].Display_Quarter_Sortable__c;
			endingQuarterSwapped   = 
			  [select Display_Quarter_Sortable__c from Schedule_Entry__c 
			   where  Opportunity__c in :lstOppIds order by Display_Quarter_Sortable__c DESC 
			   limit 1].Display_Quarter_Sortable__c;
		}
		catch (Exception ex) {
			// This list view's Opps don't have any Schedule Entries
			// Make up a starting quarter that's after the ending quarter
			startingQuarterSwapped = 'FY2010-Q2';
			endingQuarterSwapped   = 'FY2010-Q1';
		}
		
		lstQuarters = new List<String>();
		lstQuarterSelectOptions = new List<SelectOption>();
		for (String strQuarterSwapped = startingQuarterSwapped; 
		            strQuarterSwapped <= endingQuarterSwapped; 
		            strQuarterSwapped = Utils.swapFiscalDateSections(Utils.getNextQuarter(Utils.swapFiscalDateSections(strQuarterSwapped)))) {
		     lstQuarters.add(Utils.swapFiscalDateSections(strQuarterSwapped));
		     lstQuarterSelectOptions.add(new SelectOption(Utils.swapFiscalDateSections(strQuarterSwapped), Utils.swapFiscalDateSections(strQuarterSwapped)));
		}
		
		if (prefs.Starting_Quarter__c != null && prefs.Starting_Quarter__c != '' &&
		    prefs.Ending_Quarter__c   != null && prefs.Ending_Quarter__c   != '') {
			String prefsStartingQuarterSwapped = Utils.swapFiscalDateSections(prefs.Starting_Quarter__c);
			String prefsEndingQuarterSwapped = Utils.swapFiscalDateSections(prefs.Ending_Quarter__c);
			
			if (prefsStartingQuarterSwapped >= startingQuarterSwapped &&
			    prefsStartingQuarterSwapped <= endingQuarterSwapped)
				startingQuarterSwapped = prefsStartingQuarterSwapped;
			
			if (prefsEndingQuarterSwapped >= startingQuarterSwapped &&
			    prefsEndingQuarterSwapped <= endingQuarterSwapped)
				endingQuarterSwapped = prefsEndingQuarterSwapped;
		}
				
		startingQuarter = Utils.swapFiscalDateSections(startingQuarterSwapped);
		endingQuarter = Utils.swapFiscalDateSections(endingQuarterSwapped);
		pageError = false;

		lstRowData = new List<RowData>();
		strResults = '';
		strPartialResults = '';
		lastPartDone = '';
		
		return null;
	}
	
	
	public PageReference runReport() {
		runReportPart1();
		runReportPart2();
		return runReportPart3();	
	}
	

	// --------------------------------------------------------------------------------
	// Begin generating the report - get the data, and generate the report labels
	public PageReference runReportPart1() {
		
		pageError = false;
		numRows = 0;
		currentRowNum = 0;
		doneWithOpps = false;
		lastPartDone = '';
		strResults = '';
		strPartialResults = '';

		lstOpportunities = null;
		lstRowData = null;
		lstQuartersToShow = null;
		
		if (recordTypeOk == false) {
			pageError = true;
			String str = 'The List View you selected is invalid for this report. Please select another List View.';
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
			ApexPages.addMessage(msg);					
			return null;
		}
		
		// Make sure they selected a valid range
		if (startingQuarter != null && endingQuarter != null) {
			if (Utils.swapFiscalDateSections(startingQuarter) > Utils.swapFiscalDateSections(endingQuarter)) {
				pageError = true;
				String str = 'The starting quarter must be on or before the ending quarter.';
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
				ApexPages.addMessage(msg);					
				return null;
			}
		}
		
		Map<String, List<String>> mapFieldsByRecordTypeName = new Map<String, List<String>>();
		mapFieldsByRecordTypeName.put('Quadro Sales Opportunity',       lstFieldsAndLabels_Quadro);
		mapFieldsByRecordTypeName.put('Tesla Sales Opportunity',        lstFieldsAndLabels_Tesla);
		mapFieldsByRecordTypeName.put('Tegra Auto and Emb Opportunity', lstFieldsAndLabels_TegraAuto);

		// Get the list of Fields and Labels for the Record Type we're given
		lstFieldsAndLabels = mapFieldsByRecordTypeName.get(recordTypeName);
		if (lstFieldsAndLabels == null) {
			pageError = true;
			String str = 'The list view you selected includes "' + recordTypeName + '" Opportunities, which are not supported by this report. ' +
			             'Please select another list view.';
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
			ApexPages.addMessage(msg);					
			return null;
		}
		
		// Save the user's preferences for the next time they visit this page
		savePreferences();

		// Construct a SOQL query that gets the fields we care about
		String soql = constructSOQL(false, 'lstOppIds');
		lstOpportunities = Database.query(soql);

		lstRowData = new List<RowData>();
		for (Opportunity opp : lstOpportunities) { 
			if (opp.OpportunityLineItems.size() == 0) 
				lstRowData.add(new RowData(opp, null));
			else
				for (OpportunityLineItem oli : opp.OpportunityLineItems)
					lstRowData.add(new RowData(opp, oli));
		}

		// Clean up some data we don't need to bother including in the view state
		lstOpportunities = null;
				
		// Determine which quarters we're going to show
		lstQuartersToShow = new List<String>();
		for (String qtr : lstQuarters){
			String qtrSwapped = Utils.swapFiscalDateSections(qtr);
			if (qtrSwapped >= Utils.swapFiscalDateSections(startingQuarter) && qtrSwapped <= Utils.swapFiscalDateSections(endingQuarter)) 
				lstQuartersToShow.add(qtr);
		}
		

		// --------------------------------------------------------------------------------
		// Construct the row for the labels
		strPartialResults = displayDocStart();
		
		String strLabels = '';
		strPartialResults += displayRowStart();	
		
		if (showIdField) strLabels += displayColHeader('Opp Id');
		
		for (Integer i=0; i<lstFieldsAndLabels.size(); i++) {
			List<String> nameAndLabel = lstFieldsAndLabels[i].split('//');
			String fldName = nameAndLabel[0];
			String fldLabel = nameAndLabel[1];
			if (fldLabel != 'PRODUCT_FIELDS') {
				strLabels += displayColHeader(fldLabel);
			}
			else {
				strLabels += displayColHeader('Product');
				for (String strQuarter : lstQuartersToShow) {
					strLabels += displayColHeader(strQuarter + '<br/>Units');
					strLabels += displayColHeader(strQuarter + '<br/>Revenue');
				}
				strLabels += displayColHeader('Total Revenue');
			}
		}
		strLabels += displayRowEnd();
		strPartialResults += strLabels;
		
		doneWithOpps = false;
		currentRowNum = 0;
		numRows = lstRowData.size();
		previousOppId = null;
		lastPartDone = '1';
		
		
		return null;
	}
	
	// --------------------------------------------------------------------------------
	// Generate the report's data
	Id previousOppId;
	public PageReference runReportPart2() {

		Map<String, List<String>> mapFieldsByRecordTypeName = new Map<String, List<String>>();
		mapFieldsByRecordTypeName.put('Quadro Sales Opportunity',       lstFieldsAndLabels_Quadro);
		mapFieldsByRecordTypeName.put('Tesla Sales Opportunity',        lstFieldsAndLabels_Tesla);
		mapFieldsByRecordTypeName.put('Tegra Auto and Emb Opportunity', lstFieldsAndLabels_TegraAuto);

		// Get the list of Fields and Labels for the Record Type we're given
		List<String> lstFieldsAndLabels = mapFieldsByRecordTypeName.get(recordTypeName);

		// Get detailed opp data for the opps we'll process
		List<Id> lstIdsForOppsFullData = new List<Id>();
		for (Integer rowNum=currentRowNum; rowNum<lstRowData.size(); rowNum++) {
			lstIdsForOppsFullData.add(lstRowData[rowNum].opp.id);
		}
		Map<Id, Opportunity> mapOppsFullData = 
			new Map<Id, Opportunity>((List<Opportunity>)Database.query(constructSOQL(true, 'lstIdsForOppsFullData'))); 

		// Get the Schedule Entries for the opps we'll process
		List<Schedule_Entry__c> lstSEs =
		  [select  id, Opportunity__c, Opportunity_Type__c, OLI_Id__c, Product_Name__c, 
			           Display_Quarter__c, Display_Quarter_Sortable__c, Quantity__c,
			           ASP__C
		   from    Schedule_Entry__c
		   where Opportunity__c in :lstIdsForOppsFullData
		   and   Display_Quarter_Sortable__c >= :Utils.swapFiscalDateSections(startingQuarter)
		   and   Display_Quarter_Sortable__c <= :Utils.swapFiscalDateSections(endingQuarter)
		   order by Opportunity__c, Display_Quarter_Sortable__c];
		
		// Construct a map of Schedule Entries, indexed by OLI ID / Quarter.
		Map<String, Schedule_Entry__c> mapScheduleEntries = new Map<String, Schedule_Entry__c>();
		for (Schedule_Entry__c se : lstSEs) {
			mapScheduleEntries.put(se.OLI_Id__c + '/' + se.Display_Quarter__c, se);
		} 
		

		
		// --------------------------------------------------------------------------------
		// Construct the output
		// The actual row data
		Integer MAXPERITERATION = 150;
		Integer numThisIteration = 0;
		doneWithOpps = false;
		
		for (Integer rowNum=currentRowNum; rowNum<lstRowData.size(); rowNum++) {

			if (numThisIteration >= MAXPERITERATION) {
				break;
			}
			currentRowNum = rowNum;
			numThisIteration++;
			
			RowData rowdata = lstRowData[rowNum];
			Opportunity opp = mapOppsFullData.get(rowdata.opp.id);
			OpportunityLineItem oli = rowdata.oli;

			if (opp == null) continue;
			
			String strRow = displayRowStart();
			if (showIdField) strRow += displayCell(opp.id);
			for (Integer i=0; i<lstFieldsAndLabels.size(); i++) {
				List<String> nameAndLabel = lstFieldsAndLabels[i].split('//');
				String fldName = nameAndLabel[0];
				String fldLabel = nameAndLabel[1];
				if (fldLabel != 'PRODUCT_FIELDS') {
					if (!repeatData && (previousOppId==opp.id))
						strRow += displayCell('');
					else {
						System.debug('===== field name = ' + fldName);
						if (fldLabel == 'Amount' && opp.get(fldName)!=null) 
							strRow += displayCell(((Decimal)opp.get(fldName)).format());
						else
						if (fldLabel == 'Opportunity Owner') 
							strRow += displayCell(opp.Owner.Name);
						else
						if (fldName == 'Name' && format == 'browser') {
							String str = displayCell(blankValue(opp.get(fldName)));
							str = str.replace('<td class="td">', '<td class="td"><a target="newwin" href="/' + opp.id + '">');
							str = str.replace('</td>', '</a></td>');
							strRow += str;
						}
						else
						if (fldName == 'AccountName__c' && format == 'browser') {
							String str = displayCell(blankValue(opp.get(fldName)));
							str = str.replace('<td class="td">', '<td class="td"><a target="newwin" href="/' + opp.AccountId + '">');
							str = str.replace('</td>', '</a></td>');
							strRow += str;
						}
						else
							strRow += displayCell(blankValue(opp.get(fldName))); 
					}
				} 
				else {
					if (oli == null) {
						strRow += displayCell('');
						strRow += displayCell('');
						for (String strQuarter : lstQuartersToShow) {
							strRow += displayCell('');
							strRow += displayCell('');
						}
					}
					else {
						// Show the Product-specific fields
						strRow += displayCell(blankValue(oli.PricebookEntry.Product2.Name));
						Decimal revenue = 0;
						for (String strQuarter : lstQuartersToShow) {
							Schedule_Entry__c se = mapScheduleEntries.get(oli.id + '/' + strQuarter);
							if (se == null) {
								strRow += displayCell('0');
								strRow += displayCell('$0');
							}
							else {
								if (se.ASP__c == null) se.ASP__c = 0;
								strRow += displayCell(se.Quantity__c.format());
								strRow += displayCell('$' + (se.Quantity__c * se.ASP__c).format());
								revenue += (se.Quantity__c * se.ASP__c);
							}
						}
						strRow += displayCell('$' + revenue.format());
					}
				}
			}
			previousOppId = opp.id;
			strRow += displayRowEnd();
			strPartialResults += strRow;
			
			// We've just processed a row. No need to keep it around chewing up valuable
			// view state space.
			lstRowData[rowNum] = null;
		}
		
		currentRowNum++;
		if (currentRowNum >= lstRowData.size()) 
			doneWithOpps = true;
		else
			doneWithOpps = false; 

		lastPartDone = '2';
		return null;
	}


	// --------------------------------------------------------------------------------
	// Generate the end of the report
	public PageReference runReportPart3() {
		strPartialResults += displayDocEnd();
		
		pageError = false;

		// Clean up some data we don't need to bother including in the view state
		lstOpportunities = null;
		lstRowData = new List<RowData>();
		lstQuartersToShow = null;
		
		doneWithOpps = true;
		strResults = strPartialResults;
		strPartialResults = '';
		lastPartDone = '3';

		if (renderAsCSV) {
			PageReference pgCSV = Page.OpportunityReportCSV;
			return pgCSV;
		}
		else {
			return null;
		}
	}


	// --------------------------------------------------------------------------------
	// Helper methods
	// --------------------------------------------------------------------------------

	// These "display" methods return strings with the appropriate row and cell formattting,
	// depending on whether the user wants the results displayed in a "browser" or "csv" format.
	
	private String displayDocStart() {
		if (format=='browser') return '<table class="table">';
		else
		if (format=='csv')     return '';
		return '';
	}
	
	private String displayDocEnd() {
		if (format=='browser') return '</table>';
		else
		if (format=='csv')     return '';
		return '';
	}
	
	private String displayRowStart() {
		if (format=='browser') return '<tr class="tr">';
		else
		if (format=='csv')     return '';
		return '';
	}

	private String displayRowEnd() {
		if (format=='browser') return '</tr>';
		else
		if (format=='csv')     return '\n';
		return '';
	}
	
	private String displayColHeader(String str) {
		if (format=='browser') return '<th class="th">' + str + '</th>';
		else
		if (format=='csv')     return '"' + str.replace('<br/>',' ') + '",';
		return '';
	}

	private String displayCell(String str) {
		String ret = '';
		if (str == 'true') str = 'Yes';
		if (str == 'false') str = '';
		if (format=='browser') {
			str = str.replace('&nbsp;','NONBREAKINGSPACE');
			str = str.replace('&','&amp;');
			str = str.replace('NONBREAKINGSPACE', '&nbsp;');
			ret += '<td class="td">' + (str=='' ? '&nbsp;' : str) + '</td>';
		}
		else
		if (format=='csv') {
			str = str.replace('\n', ' ');
			str = str.replace('\r', ' ');
			str = str.replace('"', '\'');
			ret += '"' + str + '",';
		}
		return ret;
	}
		

	private String blankValue(Object fld) {
		if (format=='browser') {		
			if (String.valueOf(fld) == null) 
				return '&nbsp;';
			else 
				return String.valueOf(fld);
		}
		else
		if (format=='csv') {
			if (String.valueOf(fld) == null) 
				return '';
			else 
				return String.valueOf(fld);
		}
		return '';
	}


	private List<String> lstFieldsAndLabels_Quadro = new List<String>{
		'AccountName__c//Account Name',
		'Name//Opportunity Name',
		'Owner.Name//Opportunity Owner',
		'Industry__c//Industry',
		'GEO_Area__c//GEO Area',
		'Country__c//Country',
		'StageName//Stage',
		'Probability//Probability (%)',
		'Opportunity_Class__c//Opportunity Class',
		'System_Type__c//System Type',
		'TPP__c//TPP',
		'OEM_or_Channel_Account_Contact__c//OEM or Channel Account Contact',
		'Amount//Amount',
		'PRODUCT_FIELDS//PRODUCT_FIELDS',
		'At_Risk_Level__c//At Risk Level',
		'Competition__c//Competition',
		'Additional_Partners__c//Application Partners',
		'Prefered_Partner__c//Prefered OEM/Channel Partners',
		'Status_Next_Step__c//Status:  Next Step',
		'LastModifiedDate//Last Modified Date',
		'CloseDate//Close Date',
		'CreatedDate//Created Date',
//		'Sales_Lead__c//NV Secondary Salesperson',
		'Blocking_Issues__c//Blocking Issues / Help Needed',
		'Status_Last_Step__c//Status:  Last Step',
//		'Description//Description',
		'Reason_for_Close__c//Reason for Closed Lost?',
		'Closed_Lost_Comments__c//Closed Lost Comments ',
		'Critical_Priority_1_Software_Apps__c//ISV Software Apps',
		'Fermi_Adoption_Status__c//Fermi Adoption Status',
		'Quadro_Opportunity_Solution__c//Quadro Opportunity Solution',
		'Quadro_Software_Applications__c//Quadro Software Applications',
		'Product_Line__c//Product Line',
//		'What_generated_this_Opportunity__c//What started this Opportunity?',
//		'LeadSource//Lead Source',
		'X1_OEM_CUDA_GPU_Technical_Training__c//1. OEM CUDA/GPU Technical Training',
		'X2_Vertical_Solution_Training__c//2. Vertical Solution Training',
		'X3_Joint_Sales_Call__c//3. Joint Sales Call',
		'X4_Joint_Event_Lead_Generation__c//4. Joint Event/Lead Generation',
		'X5_Proof_of_Concept__c//5. Proof of Concept',
		'X6_OEM_Sales_Tools__c//6. OEM Sales Tools'
	};

	private List<String> lstFieldsAndLabels_Tesla = new List<String>{
		'AccountName__c//Account Name',
		'Name//Opportunity Name',
		'Owner.Name//Opportunity Owner',
		'Industry__c//Industry',
		'GEO_Area__c//GEO Area',
		'Country__c//Country',
		'StageName//Stage',
		'Probability//Probability (%)',
		'Product_Line__c//Product Line',
		'Opportunity_Class__c//Opportunity Class',
		'System_Type__c//System Type',
		'TPP__c//TPP',
		'OEM_or_Channel_Account_Contact__c//OEM or Channel Account Contact',
		'Amount//Amount',
		'PRODUCT_FIELDS//PRODUCT_FIELDS',
		'Top_500_Rank__c//Top 500 Rank',
		'At_Risk_Level__c//At Risk Level',
		'Competition__c//Competition',
		'Additional_Partners__c//Application Partners',
		'Prefered_Partner__c//Prefered OEM/Channel Partners',
		'Status_Next_Step__c//Status:  Next Step',
		'LastModifiedDate//Last Modified Date',
		'CloseDate//Close Date',
		'CreatedDate//Created Date',
//		'Sales_Lead__c//NV Secondary Salesperson',
		'Blocking_Issues__c//Blocking Issues / Help Needed',
		'Status_Last_Step__c//Status:  Last Step',
//		'Description//Description',
		'Reason_for_Close__c//Reason for Closed Lost?',
		'Closed_Lost_Comments__c//Closed Lost Comments ',
		'Critical_Priority_1_Software_Apps__c//ISV Software Apps',
		'Critical_Priority_2_Software_Apps__c//Research Code Applications',
//		'LeadSource//Lead Source',
		'X1_OEM_CUDA_GPU_Technical_Training__c//1. OEM CUDA/GPU Technical Training',
		'X2_Vertical_Solution_Training__c//2. Vertical Solution Training',
		'X3_Joint_Sales_Call__c//3. Joint Sales Call',
		'X4_Joint_Event_Lead_Generation__c//4. Joint Event/Lead Generation',
		'X5_Proof_of_Concept__c//5. Proof of Concept',
		'X6_OEM_Sales_Tools__c//6. OEM Sales Tools'
	};


	private List<String> lstFieldsAndLabels_TegraAuto = new List<String>{
		'AccountName__c//Account Name',
		'Name//Opportunity Name',
		'Owner.Name//Opportunity Owner',
		'Sales_Lead__c//NV Secondary Salesperson',
		'At_Risk_Level__c//At Risk Level',
		'Type_of_Device__c//Type of Device',
		'ODM__c//ODM',
		'Distributor__c//Distributor',
		'System_Integrator__c//System Integrator',
		'Operating_System_Type__c//Operating System Type',
		'StageName//Stage',
		'Probability//Probability (%)',
		'Blocking_Issues__c//Blocking Issues / Help Needed',
		'CloseDate//Close Date',
		'Code_Name_Auto__c//Code Name (Auto)',
		'Amount//Amount',
		'Status_Last_Step__c//Status:  Last Step',
		'Status_Next_Step__c//Status:  Next Step',
		'GEO_Area__c//GEO Area',
		'Country__c//Country',
		'Competition__c//Competition',
		'Description//Description',
		'Reason_for_Close__c//Reason for Closed Lost?',
		'Closed_Lost_Comments__c//Closed Lost Comments ',
		'PRODUCT_FIELDS//PRODUCT_FIELDS'
	};


	public class RowData {
		public Opportunity opp;
		public OpportunityLineItem oli;
		public RowData(Opportunity opp, OpportunityLineItem oli) {
			this.opp = opp;
			this.oli = oli;
		}
	}

	public OpportunityReportPreferences__c getSavedPreferences() {
		OpportunityReportPreferences__c customSetting = OpportunityReportPreferences__c.getValues(UserInfo.getUserId());
		if (customSetting == null) {
			customSetting = OpportunityReportPreferences__c.getValues(UserInfo.getProfileId());
			if (customSetting == null) {
				customSetting = OpportunityReportPreferences__c.getOrgDefaults();
				if (customSetting == null) {
					customSetting = new OpportunityReportPreferences__c();
				}
			}
		}
		
		if (customSetting.FilterId__c == null || customSetting.FilterId__c == '') customSetting.FilterId__c = stdController.getFilterId();
		if (customSetting.Format__c == null || customSetting.Format__c == '') customSetting.Format__c   = 'browser';
		if (customSetting.Starting_Quarter__c == null || customSetting.Starting_Quarter__c == '') customSetting.Starting_Quarter__c = startingQuarter;
		if (customSetting.Ending_Quarter__c == null   || customSetting.Ending_Quarter__c == '')   customSetting.Ending_Quarter__c   = endingQuarter;
		
		return customSetting;
	}

	public void savePreferences() {
		OpportunityReportPreferences__c customSetting = OpportunityReportPreferences__c.getValues(UserInfo.getUserId());
		if (customSetting == null) customSetting = new OpportunityReportPreferences__c(setupownerid=UserInfo.getUserId());
		customSetting.FilterId__c = stdController.getFilterId();
		customSetting.Format__c   = format;
		customSetting.Show_Repeated_Data__c = repeatData;
		customSetting.Starting_Quarter__c = startingQuarter;
		customSetting.Ending_Quarter__c = endingQuarter;
		upsert customSetting;
	}

	// Construct a SOQL query that gets the fields we care about
	private String constructSOQL(Boolean includeAllFields, String strOppListVariableName) {
		String strSoql = '';
		if (includeAllFields) {
			strSOQL = 'select Id, Owner.Name, AccountId, ';
			for (Integer i=0; i<lstFieldsAndLabels.size(); i++) {
				List<String> nameAndLabel = lstFieldsAndLabels[i].split('//');
				String fldName = nameAndLabel[0];
				String fldLabel = nameAndLabel[1];
				if (fldLabel != 'PRODUCT_FIELDS' && fldLabel != 'Opportunity Owner') {
					strSoql += fldName + ', ';
				}
			}
		}
		else {
			strSOQL = 'select Id, ';
		}
		strSoql += '\n';
		strSoql += '(select ASP__c, Quantity, PricebookEntry.Product2.Name ';
		strSoql += ' from   OpportunityLineItems order by Product_Name__c) ';
		strSoql += 'from Opportunity ';
		strSoql += 'where  Id in :' + strOppListVariableName + ' ';
		strSoql += 'order by Account.Name, Name ';
		return strSoql;
	}
*/			

}