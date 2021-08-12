/*
	PJENA: 2019.08.02 - trigger class for Dev_contact_tgr - Set Region from Country with reference to Country_List__c mapping records
	PJENA: 2019.08.26 - set Mailing Country to full name of the Country in case it is set with 2-letter ISO code
	
*/

public class Dev_Contact_tgr_cls {
    
    /*
    Before Trigger: Set Mailing_Region__c, Mailing_Sub_Region__c, Mailing_Territory__c
    */
	public static void setRegion(list<Dev_Contact__c> lstDevContacts){
		//gather all country names or codes
		set<string> sCountry = new set<string>();
		for (Dev_Contact__c dc : lstDevContacts){
			sCountry.add(dc.Mailing_Country__c);
		}
		
		//Prepare a map of Country Name/ISO Code to Country List
		map<String, Country_List__c> ctryCodeListMap = new map<String, Country_List__c>();
		for(Country_List__c ctryLst : [Select Id, Name, ISO_Code__c, Region__c, Sub_Region__c, Territory__c From Country_List__c Where Name IN :sCountry Or ISO_Code__c IN :sCountry]) {
			ctryCodeListMap.put(ctryLst.Name, ctryLst);
			ctryCodeListMap.put(ctryLst.ISO_Code__c, ctryLst);
		}
		
		//Set the ailing_Region__c, Mailing_Sub_Region__c, Mailing_Territory__c
		for (Dev_Contact__c dc : lstDevContacts){
			dc.Mailing_Country__c =  ctryCodeListMap.get(dc.Mailing_Country__c) != null ? ctryCodeListMap.get(dc.Mailing_Country__c).Name : '';
			dc.Mailing_Region__c =  ctryCodeListMap.get(dc.Mailing_Country__c) != null ? ctryCodeListMap.get(dc.Mailing_Country__c).Region__c : '';
			dc.Mailing_Sub_Region__c =  ctryCodeListMap.get(dc.Mailing_Country__c) != null ? ctryCodeListMap.get(dc.Mailing_Country__c).Sub_Region__c : '';
			dc.Mailing_Territory__c =  ctryCodeListMap.get(dc.Mailing_Country__c) != null ? ctryCodeListMap.get(dc.Mailing_Country__c).Territory__c : '';
		}
		
	}
    
}