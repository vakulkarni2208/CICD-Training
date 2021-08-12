/*
	Common class and methods for NPN Revenue Target automation. Routines called from Partner Attribute trigger class and CRM_NPN_Revenue_Target_Automation scheduled batch apex
	
	2021.01.31 	Rajat	SDS-2724 Added Sub Program in the logic.
*/
public class CRM_NPN_Revenue_Target_Common {

	//This function fetches the Threshold__c with matching Competency, Country, Level and sets the NPN Revenue Targets 	"Minimum Annual Sales Commitment" and finally inserts the records
	public static void createRevenueTargets(list<PartnerAttributeExt> lstPAExt, string currFY){
		system.debug('***Enters createRevenueTargets() with lstPAExt = ' + lstPAExt);
		
		//Collect the list of countries to search the NPN_Revenue_Commitment_Master__c data
		set<string> setBillCountryInPA = new set<string>();
		for (PartnerAttributeExt paExt :  lstPAExt){
			setBillCountryInPA.add(paExt.AccountBillingCountry);
		}
		
		//fetch the NPN Revenue Commitment Maste data for all the Countries
		list<NPN_Revenue_Commitment_Master__c> lstRevCommitMstr = [	Select Program__c, Sub_Program__c, Competency__c, Level__c, Country__r.Name, Threshold__c 
																	From NPN_Revenue_Commitment_Master__c 
																	Where Country__r.Name = :setBillCountryInPA Limit 50000	];

		//make a key value pair from the master data list. key being the combination of competency-level-country; value being the threshold value
		map<string, decimal> mapRevCommitMstr = new map<string, decimal>();
		for (NPN_Revenue_Commitment_Master__c mstrdata : lstRevCommitMstr){
			// Added Sub_Program__c for SDS-2724
			string key = mstrdata.Program__c + '-' + mstrdata.Sub_Program__c + '-' + mstrdata.Competency__c + '-' + mstrdata.Level__c + '-' + mstrdata.Country__r.Name;
			mapRevCommitMstr.put(key.toLowerCase(), mstrdata.Threshold__c);
		}
		system.debug('***mapRevCommitMstr: ' + mapRevCommitMstr);
		
		//get the "No Match - No Revenue Target" flag from NPN_Revenue_Target_Automation_Settings__c, if it is true then skip the revenue targets with no matching Prog Type, Competency, Level and Billing Country
		boolean bNoMatchNoRevTrgtCS = NPN_Revenue_Target_Automation_Settings__c.getOrgDefaults().No_Match_No_Revenue_Target__c;
		system.debug('***bNoMatchNoRevTrgtCS: ' + bNoMatchNoRevTrgtCS);
		
		//from the PA Extension list, make the key and use it to fetch the threshold from mapRevCommitMstr
		list<NPN_Revenue_Targets__c> lstNewRevenueTargets = new list<NPN_Revenue_Targets__c>();
		for (PartnerAttributeExt PAExt : lstPAExt){
			string key = PAExt.Program + '-' + PAExt.SubProgram + '-' + PAExt.Competency + '-' + PAExt.Level + '-' + PAExt.AccountBillingCountry;
			system.debug('***key searched: ' + key.toLowerCase());
			decimal dThreshold = mapRevCommitMstr.get(key.toLowerCase());
			system.debug('***dThreshold: ' + dThreshold);
			if ( dThreshold != null || (dThreshold == null && bNoMatchNoRevTrgtCS == false) ){
				lstNewRevenueTargets.add(new NPN_Revenue_Targets__c(Partner_Attribute__c = PAExt.Id, Year__c = currFY, Minimum_Annual_Sales_Commitment__c = dThreshold));
			}
		}
		
		system.debug('***New Revenue Target details to be inserted: ' + lstNewRevenueTargets);
		//insert the new revenue targets
		if (!lstNewRevenueTargets.isEmpty()){
			database.insert(lstNewRevenueTargets);
		}
			
	}
	
	//User defined class to hold Partner Attribute fields and its Account billing country
	public class PartnerAttributeExt{
		public Id Id;
		public string Program;
		public string SubProgram;		// Added for SDS-2724
		public string Competency;
		public string Level;
		public string AccountBillingCountry;
		
		public PartnerAttributeExt(Id Id, string Program, string SubProgram, string Competency, string Level, string AccountBillingCountry){
			this.Id = Id;
			this.Program = Program;
			this.SubProgram = SubProgram;
			this.Competency = Competency;
			this.Level = Level;
			this.AccountBillingCountry = AccountBillingCountry;
		}
		
	}
	
	//Get Fiscal Year name From FiscalYearSettings based on a Date literal without time part - Partner Attribute trigger
    public static string getFiscalYear(Date dt){
    	FiscalYearSettings currentFiscalYear = [Select  FY.Name from FiscalYearSettings FY where FY.StartDate <=:dt and FY.EndDate >= : dt];
        return currentFiscalYear.Name;
    }
}