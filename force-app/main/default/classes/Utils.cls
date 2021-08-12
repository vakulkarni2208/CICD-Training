/*
 *	Custom Utility functions for NVIDIA
 *
 *	Created: Summer 2010, by OpFocus
 *
*/
global class Utils {
	
	global static Map<String, Id> mapRecordTypeIDsByName;	
	
	global static Map<String, Id> GetAllRecordTypeIdsByName() {
		//	GetAllRecordTypeIdsByName() takes a string 'sObjectName / RecordType Name' 
		//	and returns the corresponding Salesforce Id
		
		//	If the map is empty, populate it; if not, return it directly
		if (mapRecordTypeIDsByName == null) {
			mapRecordTypeIDsByName = new Map<String, ID>();
			for (RecordType rt : [Select Id, sObjectType, Name From RecordType]) {
				mapRecordTypeIDsByName.put(rt.SObjectType + ' / ' + rt.Name, rt.Id);
			}
		}		
		return mapRecordTypeIDsByName;		
	}	
	
	global static Id getRecordTypeId(String name) {
		return GetAllRecordTypeIdsByName().get(name);
	}

	// Given an Object, return a List<> of all its RecordTypes
    global static List<String> recordTypesForObject(String sObjectName) {
          List<String> recordTypeNames;
          List<RecordType> rts = 
            [Select Name 
             From   RecordType
             Where  SObjectType = :sObjectName];
             
          for (RecordType rt : rts) {
          	recordTypeNames.add(rt.Name);
          }
          return recordTypeNames;
    }
  
	
	// Given an SObject, returns information about all of its possible Record Types
	public static Map<String, Schema.RecordTypeInfo> getRecordTypeInfosForSObject(SObject so) {

		Schema.SObjectType sot = so.getSObjectType();
	
		Schema.DescribeSObjectResult res = Opportunity.SObjectType.getDescribe();
		Map<String, Schema.RecordTypeInfo> mapRTIs = res.getRecordTypeInfosByName();
		
		return mapRTIs;
	}


	// Given an SObject, returns information about all of its possible Record Types
	// that are available for the current User
	public static Map<String, Schema.RecordTypeInfo> getAccessibleRecordTypeInfosForSObject(SObject so) {

		Map<String, Schema.RecordTypeInfo> mapRTIs = getRecordTypeInfosForSObject(so);		
		Map<String, Schema.RecordTypeInfo> mapReturn = new Map<String, Schema.RecordTypeInfo>();
		
		for (String key : mapRTIs.keyset()) {
			if (mapRTIs.get(key).isAvailable())
				mapReturn.put(key, mapRTIs.get(key));
		}
		return mapReturn;
		
	}

	// Given an SObject, returns the names of all of its possible Record Types
	// that are available for the current User
	public static List<String> getAccessibleRecordTypeNamesForSObject(SObject so) {
		Map<String, Schema.RecordTypeInfo> mapRTIs = getAccessibleRecordTypeInfosForSObject(so);
		return new List<String>(mapRTIs.keyset());
	}
		
	// Given an Object, return a Map<> of RecordType IDs, indexed by Name
	public static Map<String, Id> mapRecordTypeIdsByName(String sObjectName) {
		
		Map<String, Id> mapRTIsByName = new Map<String, Id>();
		List<RecordType> rts = 
		  [Select Id, Name
		   From   RecordType
		   Where  SObjectType = :sObjectName];
		   
		for (RecordType rt : rts) {
			mapRTIsByName.put(rt.Name, rt.Id);
		}
		return mapRTIsByName;
	}


	// Returns true if the given list of strings contains the given string
	public static Boolean listContainsString(List<String> lst, String str) {
		for (String s : lst) {
			if (s == str) return true;
		}
		return false;
	}

	// Given a list of strings, joins them together into a single string, separated by strJoin
    public static String join(List<String> lstStrings, String strJoin) {
          String newStr = '';
          for (String str : lstStrings) {
                 newStr += str + strJoin;
          }
          newStr = RemoveTrailing(newStr, strJoin);
          return newStr;
    }

	// If the given main string ends with the given substring, remove it.
	public static String RemoveTrailing(String strMain, String strTrailing) {
		if (strMain.endsWith(strTrailing)) strMain = strMain.substring(0, strMain.length()-strTrailing.length());
		return strMain;     
	}
	


	// Returns a list of all the Fiscal Quarters defined in the org
	public static List<Period> lstFiscalQuarters{
		get {
			if (lstFiscalQuarters == null) {
				// Get the Fiscal Quarters defined in the system
				lstFiscalQuarters =
				  [select StartDate, EndDate, Number, FiscalYearSettings.Name
				   from   Period
				   where  Type = 'Quarter'
				   order by StartDate];
			}
			return lstFiscalQuarters;
		}
	} 

	// Returns the fiscal quarter for the given date, in the format Qx-FYyyyy
	public static String getFiscalQuarterForDate(Date d) {
		for (Period quarter : Utils.lstFiscalQuarters) {
			if (d >= quarter.StartDate && d <= quarter.EndDate) {
				return 'Q' + quarter.Number + '-FY' + quarter.FiscalYearSettings.Name;
			}
		}
		return null;
	}
	
	// Returns true if D1 is 3 or more quarters before d2
	public static Boolean dateIsThreeFiscalQuartersBeforeDate(Date d1, Date d2) {
		// Get D1's FQ
		String fqD1 = getFiscalQuarterForDate(d1);
		String fqD2 = getFiscalQuarterForDate(d2);
		
		return quarterIsThreeFiscalQuartersBeforeQuarter(fqD1, fqD2);
	}
		
	public static Boolean quarterIsThreeFiscalQuartersBeforeQuarter(String q1, String q2) {

		// Get the FQ 3 quarters before q2
		String fqThreeQuartersAgo = getPreviousQuarter(q2);
		fqThreeQuartersAgo = getPreviousQuarter(fqThreeQuartersAgo);
		fqThreeQuartersAgo = getPreviousQuarter(fqThreeQuartersAgo);

		// Fiscal Quarters are formatted like:  Qx-FYyyyy
		// We can compare them if we change them to:  FYyyyy-Qx
		String q1swapped = swapFiscalDateSections(q1);
		String fqThreeQuartersAgoSwapped = swapFiscalDateSections(fqThreeQuartersAgo);
		return (q1swapped <= fqThreeQuartersAgoSwapped);
	}
	
	public static String swapFiscalDateSections(String strFQ) {
		String[] parts = strFQ.split('-');
		return parts[1] + '-' + parts[0];
	}
	
	public static String getNextQuarter(String fq) {
		String strQuarter = fq.substring(1, 2);
		String strYear = fq.substring(5, 9);
		if (strQuarter == '1') return 'Q2-FY' + strYear;		
		if (strQuarter == '2') return 'Q3-FY' + strYear;		
		if (strQuarter == '3') return 'Q4-FY' + strYear;		
		if (strQuarter == '4') return 'Q1-FY' + (Integer.valueOf(strYear)+1);	
		return null;	
	}
	
	public static String getPreviousQuarter(String fq) {
		String strQuarter = fq.substring(1, 2);
		String strYear = fq.substring(5, 9);
		if (strQuarter == '1') return 'Q4-FY' + (Integer.valueOf(strYear)-1);
		if (strQuarter == '2') return 'Q1-FY' + strYear;		
		if (strQuarter == '3') return 'Q2-FY' + strYear;		
		if (strQuarter == '4') return 'Q3-FY' + strYear;		
		return null;	
	}
	
	public static String getThreeFiscalQuartersAgo(Date d) {
		// Get the FQ for the given Date
		String fq = getFiscalQuarterForDate(d);
		
		String strQuarter = fq.substring(1, 2);
		String strYear = fq.substring(5, 9);
		Integer intYear = Integer.valueOf(strYear);
		
		if (strQuarter == '1') {
			strQuarter = '2';
			strYear = String.valueOf(intYear-1);
		}
		else
		if (strQuarter == '2') {
			strQuarter = '3';
			strYear = String.valueOf(intYear-1);
		}
		else
		if (strQuarter == '3') {
			strQuarter = '4';
			strYear = String.valueOf(intYear-1);
		}
		else
		if (strQuarter == '4') {
			strQuarter = '1';
			strYear = String.valueOf(intYear);
		}
		
		return 'Q' + strQuarter + '-FY' + strYear;
		
	}
						
}