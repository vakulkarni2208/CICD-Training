/*
 * Author: Manideep
 * CreatedDate: 2/17/2017
 * Description: This is a Service Class. The method getTAMs() can be invoked by any trigger/batch class etc. It will return
                appropriate "Terrotory Account Manager (TAM)" for each Account/Opportunity that is passed as input to this method.                 
*/

global class CRM_TAM_Utility {
  
  //Method that accepts the list of TAMSObjectRecTemplate and returns the same list by setting its TAMId field
  public static List<TAMSObjectRecTemplate> getTAMs(List<TAMSObjectRecTemplate> lstTAMRT) {
    	
     system.debug('***Begin: CRM_TAM_Utility > getTAMs()');
     system.debug('=======================================================================');
    	
	 list<Territory_Mapping__c> listTM;
     map<Id, string> allfieldsMap = new Map<Id, string>();
     
     //fetch all the Territoriers from the Territory Mapping object and build the in-memory map
     //----------------------------------------------------------------------------------------
     map<string, Id> mapTAMMatrix = new map<string, Id>();
     listTM = [Select Id, Territory_Account_Manager__c, All_fields__c, Region__c, Country__r.Name, State__c, City__c, Industry__c
               From Territory_Mapping__c Where Region__c != null And Country__c != null];
     system.debug('***listTM---->' + listTM);
		
	 if(!lstTAMRT.isEmpty() && !listTM.isEmpty()) {
		for(Territory_Mapping__c tm: listTM) {
            string strAllFields = tm.All_fields__c.toUpperCase();
            mapTAMMatrix.put(strAllFields, tm.Territory_Account_Manager__c);    
        }
	 }
	 system.debug('***mapTAMMatrix---->' + mapTAMMatrix);
	 //----------------------------------------------------------------------------------------\
		
	 string strProposedKey;
	 if(!mapTAMMatrix.isEmpty()) {
		//For each records, evaluate and set the TAM
		for(TAMSObjectRecTemplate tort: lstTAMRT) {
			string region;
			string country;
			string state;
			string city;
			string industry;
			
			// assign field values for all variables if not blank
			if(string.isNotBlank(tort.Region))
			   region = tort.Region.toUpperCase();
			else   
			   region = COMM_Constants.TAM_STRING;
			   
		    if(string.isNotBlank(tort.Country))	  
		       country = tort.Country.toUpperCase();
		    else
		       country = COMM_Constants.TAM_STRING; 
		       
		    if(string.isNotBlank(tort.State))   
		       state = tort.State.toUpperCase();
		    else
		       state = COMM_Constants.TAM_STRING; 
		       
		    if(string.isNotBlank(tort.City))
		       city = tort.City.toUpperCase();
		    else
		       city = COMM_Constants.TAM_STRING;
		       
		    if(string.isNotBlank(tort.Industry))
		       industry = tort.Industry.toUpperCase(); 
		    else             
			   industry = COMM_Constants.TAM_STRING;
			   
			// set the proposed key to null for each record
			strProposedKey = null;   
			   
			if(mapTAMMatrix.containsKey(region + country + state + city + industry)) {
			   strProposedKey = region + country + state + city + industry;
			   tort.TAMId = mapTAMMatrix.get(strProposedKey);
			   tort.allFields = strProposedKey;
			   system.debug('***tort.allFields (Region, Country, State, City, Industry)---->' + tort.allFields + ' > ' + tort.TAMId);
			} else if(mapTAMMatrix.containsKey(region + country + state + industry)) {
			        strProposedKey = region + country + state + industry;
			        tort.TAMId = mapTAMMatrix.get(strProposedKey);
			        tort.allFields = strProposedKey;
			        system.debug('***tort.allFields (Region, Country, State, Industry)---->' + tort.allFields + ' > ' + tort.TAMId);
			} else if(mapTAMMatrix.containsKey(region + country + city + industry)) {
					strProposedKey = region + country + city + industry;
					tort.TAMId = mapTAMMatrix.get(strProposedKey);
					tort.allFields = strProposedKey;
					system.debug('***tort.allFields (Region, Country, City, Industry)---->' + tort.allFields + ' > ' + tort.TAMId);
			} else if(mapTAMMatrix.containsKey(region + country + industry)) {
					strProposedKey = region + country + industry;
					tort.TAMId = mapTAMMatrix.get(strProposedKey);
					tort.allFields = strProposedKey;
					system.debug('***tort.allFields (Region, Country, Industry)---->' + tort.allFields + ' > ' + tort.TAMId);
			} else if(mapTAMMatrix.containsKey(region + country + state + city)) {
					strProposedKey = region + country + state + city;
					tort.TAMId = mapTAMMatrix.get(strProposedKey);
					tort.allFields = strProposedKey;
					system.debug('***tort.allFields (Region, Country, State, City)---->' + tort.allFields + ' > ' + tort.TAMId);
			} else if(mapTAMMatrix.containsKey(region + country + state)) {
					strProposedKey = region + country + state;
					tort.TAMId = mapTAMMatrix.get(strProposedKey);
					tort.allFields = strProposedKey;
					system.debug('***tort.allFields (Region, Country, State)---->' + tort.allFields + ' > ' + tort.TAMId);
			} else if(mapTAMMatrix.containsKey(region + country + city)) {
					strProposedKey = region + country + city;
					tort.TAMId = mapTAMMatrix.get(strProposedKey);
					tort.allFields = strProposedKey;
					system.debug('***tort.allFields (Region, Country, City)---->' + tort.allFields + ' > ' + tort.TAMId);
			} else if(mapTAMMatrix.containsKey(region + country)) {
				  strProposedKey = region + country;
				  tort.TAMId = mapTAMMatrix.get(strProposedKey);
				  tort.allFields = strProposedKey;
				  system.debug('***tort.allFields (Region, Country)---->' + tort.allFields + ' > ' + tort.TAMId);  
			}
				
			// Final checkup: If still the TAMId is not deduced, then set the error message
			if(string.isBlank(tort.TAMId)) {
			   tort.errMsg = 'Error: There is no Mapping TAM found for the combinations (Region, Country, State, City, Industry) = (' + tort.Region + ', ' + tort.Country + ', ' + tort.State + ', ' + tort.City + ', ' + tort.Industry + ')';
			} else {
			   system.debug('***TAM Mapping found : (Region, Country, State, City, Industry) > TAM = (' + tort.Region + ', ' + tort.Country + ', ' + tort.State + ', ' + tort.City + ', ' + tort.Industry + ') > ' + tort.TAMId);
			}
				
		}
	 }
	 system.debug('***CRM_TAM_Utility > getTAMs > lstTAMRT --->' + lstTAMRT);
		
	 system.debug('=============================================================================');
		
   	 return lstTAMRT;
  }
  
}