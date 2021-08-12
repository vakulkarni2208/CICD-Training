/*
	2017.11.29 - PJENA - Deal Registration - Controller class for vf DR_CreateDR
	2018.02.03 - PJENA - Bug fix - correct state was not getting passed to TAM logic
	2018.02.16 - PJENA - Set DR_PBM User (DR_Partner_Sales_Rep_Company__c Owner)
	2018.07.20 - PJENA - SDS-587 (All NALA deal registrations to route to Anish Dave instead of following the Territory Alignment logic)
	
*/

public without sharing class DR_CreateDR_cls {
	
	//properties
	public boolean isError{get;set;}
	public boolean showError{get;set;}
	string dealRegId;
    public Lead oDealReg{get;set;}
	
	//default constructor
	public DR_CreateDR_cls(){
		oDealReg = new Lead();
	}
	
	//save process
	public pageReference saveDR(){
		Database.SaveResult oDealRegToSave = null;
        PageReference pageRef = null;
        try{
        	
			//automation logic
        	//1. Get the config details from DR Settings
        	string drsLeadDRRecTypeName = DR_Settings__c.getOrgDefaults().Lead_RecordTypeName_For_Deal_Reg__c;
        	string drsLeadStaus_IR = DR_Settings__c.getOrgDefaults().Lead_Status_IR__c;
        	string drsLeadLeadSource = DR_Settings__c.getOrgDefaults().Lead_Source__c;
        	string drsLeadType = DR_Settings__c.getOrgDefaults().Lead_Type__c;
        	//2018.07.20 - PJENA - SDS-587 (All NALA deal registrations to route to Anish Dave instead of following the Territory Alignment logic)
        	string drsNALA_TAM = DR_Settings__c.getOrgDefaults().DR_NALA_TAM_User_Id__c;
        	
        	map<string, Id> mapLeadDRID = COMM_Utility.getRTsByName('Lead', drsLeadDRRecTypeName);
        	oDealReg.RecordTypeId = mapLeadDRID.get(drsLeadDRRecTypeName); //set the record type to Deal Reg
        	oDealReg.LeadSource = drsLeadLeadSource; //'Deal Registration';
        	oDealReg.DR_Lead_Type__c = drsLeadType; //'Deal Registration';
        	oDealReg.Status = drsLeadStaus_IR; //'In Review';
        	
        	//2: Set the Partner User Reference fields
        	User currPartnerUser = [Select Contact.AccountId, Contact.Account.OwnerId, Contact.Account.BillingCountry, Contact.Id, ContactId From User u where id = :userInfo.getUserId()];
        	oDealReg.DR_Partner_Sales_Rep_Name__c = currPartnerUser.Contact.Id;
        	oDealReg.DR_Partner_Sales_Rep_Company__c = currPartnerUser.Contact.AccountId;
        	//2018.02.16 - PJENA - Set DR_PBM User (DR_Partner_Sales_Rep_Company__c Owner)
        	oDealReg.DR_PBM__c = currPartnerUser.Contact.Account.OwnerId;
        	
        	//3. set the additional team member contact
        	if (string.isNotBlank(oDealReg.DR_Additional_Team_Member_Email__c)){
        		list<Contact> lstAdditionalContacts = [	Select Id, email 
        												From Contact 
        												Where email = :oDealReg.DR_Additional_Team_Member_Email__c 
        													And AccountId = :currPartnerUser.Contact.AccountId
        												];
        		if (!lstAdditionalContacts.isEmpty()){
        			oDealReg.DR_Additional_Team_Member__c = lstAdditionalContacts[0].Id;
        		}
        	}
        	
        	//Find the region__c from the lead country
        	string strCountryName, strRegion;
        	string strStateName = '';
        	list<Country_List__c> lstCountryList = [Select Region__c, Name, ISO_Code__c, ISO_Code_3__c, 
        												(Select Name, ISO_Code__c From States__r) 
        											From Country_List__c 
        											Where ISO_Code__c = :oDealReg.CountryCode];
        	if (!lstCountryList.isEmpty()){
				strCountryName = lstCountryList[0].Name;
				strRegion = lstCountryList[0].Region__c;
				//oDealReg.Region__c = strRegion;
				system.debug('***Country Name: ' + strCountryName);
				system.debug('***Region Name: ' + strRegion);
				//2018.07.20 - PJENA - SDS-587 (All NALA deal registrations to route to Anish Dave instead of following the Territory Alignment logic)
				/*
				if (!lstCountryList[0].States__r.isEmpty()){
					for (State_List__c st : lstCountryList[0].States__r){
						if (st.ISO_Code__c == oDealReg.StateCode){
							strStateName =  st.Name; //lstCountryList[0].States__r[0].Name;
							system.debug('***strStateName: ' +strStateName) ;
							break;
						}
					}
					
				}
				*/
				//End: //2018.07.20 - PJENA - SDS-587 (All NALA deal registrations to route to Anish Dave instead of following the Territory Alignment logic)
        	}
        	
        	//2018.07.20 - PJENA - SDS-587 (All NALA deal registrations to route to Anish Dave instead of following the Territory Alignment logic)
        	//As the TAM is only for NALA and all the NALA deal registrations are going to Anish, we no longer need the TAM logic
        	
        	/*
        	//4. change ownership based on the TAM/PBM logic
        	//Call the TAM service with Partner's Customer Region, Country, State/Province, City, Industry (Partner's Customer = Lead here).
			//-------------------------------------------------------------------------------------------------------------------------------
			boolean bTAMFound = false;
			if (!bTAMFound){
				system.debug('***1. Find TAM from TAM service with  Partner\'s Customer Region, Country, State/Province, City, Industry (Partner\'s Customer = Lead here).');
				List<TAMSObjectRecTemplate> lstTSRT = new List<TAMSObjectRecTemplate>();
				TAMSObjectRecTemplate TSRT = new TAMSObjectRecTemplate();
				//TSRT.Id = lstOpps[0].AccountId; 
				TSRT.Region = strRegion; //oDealReg.Region__c;
				TSRT.Country = strCountryName; //oDealReg.Country;
				TSRT.State = strStateName; //oDealReg.State;
				TSRT.City = oDealReg.City;
				TSRT.Industry = oDealReg.Industry;
				lstTSRT.add(TSRT);
				
				system.debug('***Input lstTSRT: ' + lstTSRT);
				system.debug('***Invoke method CRM_TAM_Utility > getTAMs()');
				lstTSRT = CRM_TAM_Utility.getTAMs(lstTSRT);
				system.debug('***End: Invoke method CRM_TAM_Utility > getTAMs()');
				system.debug('***Output lstTSRT: ' + lstTSRT);
				
				//check if the TAMId gets populated from CRM_TAM_Utility Service
				if (string.isNotBlank(lstTSRT[0].TAMId)){
					oDealReg.OwnerId = lstTSRT[0].TAMId;
					bTAMFound = true;
					system.debug('***Checked TAM Matrix > bTAMFound: ' + bTAMFound);
				}
			}
			//End: Call the TAM service with Partner's Customer Region, Country, State/Province, City, Industry (Partner's Customer = Lead here).
			//-------------------------------------------------------------------------------------------------------------------------------
			*/
			//4. change ownership of NALA Deal Registrations to Anish
			boolean bTAMFound = false;
			if (string.isNotBlank(strRegion) && strRegion == COMM_Constants.ADDRESS_REGION_NALA && string.isNotBlank(drsNALA_TAM)){
				system.debug('***1. Regions = NALA, TAM is set to ' + drsNALA_TAM);
				bTAMFound = true;
				oDealReg.OwnerId = drsNALA_TAM;
			}
			
			//If TAM logic does not give any value, the PBM (oppty.Account.OwnerId) is the Owner of this Lead.
			//-------------------------------------------------------------------------------------------------------------------------------
			if (!bTAMFound){
				system.debug('***2. If Step 1 does not give any value, the PBM (oppty.Account.OwnerId) is the TAM.');
				oDealReg.OwnerId = currPartnerUser.Contact.Account.OwnerId;
				bTAMFound = true;
				system.debug('***Checked PBM > bTAMFound: ' + bTAMFound); 
			}
			//-------------------------------------------------------------------------------------------------------------------------------
			
			
        	//5. Set the Channel Admin based on the Opp Reg process
        	oDealReg.DR_ChannelAdmin__c = getChannelAdmin(currPartnerUser.Contact.Account.BillingCountry);
        	
        	//6. prepare the Deal Registration record for submission through code
        	oDealReg.DR_Is_Submitted_via_Btn_Click__c = true;

            //7. Insert the lead
            oDealRegToSave = Database.insert(oDealReg);
			
        	//8. Submit for Approval.
			system.debug('***Deal Registration Submitted for Approval.');
			Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
			//psr.setComments('Registered Deal Submitted for Approval');
			psr.setComments(system.label.CRM_DR_RGSTR_DEAL_SUBMITTED);
			psr.setObjectId(oDealRegToSave.id);
			Approval.ProcessResult result = Approval.process(psr);
        	
			//9. Unlock the Deal Reg lead record
			list<lead> lstLeads = [Select Id From Lead Where Id = :oDealRegToSave.Id];
			list<Approval.UnlockResult> urList = Approval.unlock(lstLeads, false);
			
			// Iterate through each returned result
			for(Approval.UnlockResult ur : urList) {
			    if (ur.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        System.debug('***Successfully locked Lead with ID: ' + ur.getId());
			    }
			    else {
			        // Operation failed, so get all errors                
			        for(Database.Error err : ur.getErrors()) {
			            System.debug('***The following error has occurred.');                    
			            System.debug('***' + err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('***Lead fields that affected this error: ' + err.getFields());
			        }
			    }
			}
			
            
            //10. Confirmation Redirection
            pageRef = new PageReference('/apex/DR_CreateDRConfirm');
            //End: Confirmation Redirection
        }catch(exception ex){
        	//exception logic
        	system.debug('***Exception: ' + ex);
        	string errMsg = ex.getMessage();
        	showError = true;
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
        }   
        return pageRef;
    }
	
    //cancel process
    public pageReference cancelDR(){
    	PageReference pageRef = null;
        pageRef = new PageReference('/apex/DR_CreateDRCancel');
        return pageRef;
    }
	
	
    //Get SalesOpsApprover user Id from Custom Settings based on Partner Account Country
	//===========================================================================================
	/*
	The sample structure of data
	1. United States; Canada => pjena@nvidia.com
	2. India => ghardy@nvidia.com
	3. OTHERS => mnagatani@nvidia.com
	*/
	//===========================================================================================
	private static Id getChannelAdmin(string countryName){ //Partner User > Contact > Account > BillingCountry
		system.debug('***Enters getChannelAdmin with country name: ' + countryName);
		//build the countryname-channeladminUsername map
		Map<string, string> mapCountryNameAdminUserName = new Map<String, string>();
		Map<string, DR_SalesOps_Admins__c> allDRSalesOpsAdmins = DR_SalesOps_Admins__c.getAll();
		for (DR_SalesOps_Admins__c cs : allDRSalesOpsAdmins.Values() ){
			string strCountryList = cs.DR_Billing_Country_s__c;
			if (strCountryList != null){
				list<string> lstCountry = strCountryList.split(';');
				for (string strCountry : lstCountry){
					string strCountrySpaceTrimmed = strCountry.trim();
					if (strCountrySpaceTrimmed != '' && mapCountryNameAdminUserName.get(strCountrySpaceTrimmed) == null){
						//add it to the map mapCountryNameAdminUserName
						mapCountryNameAdminUserName.put(strCountrySpaceTrimmed.toLowerCase(), cs.DR_Admin_Username__c);
					}
				}
			}
		}
		//End: build the countryname-channeladminUsername map
		
		string ChannelAdminUserName;
		Id ChannelAdminUserSFDCId;
		list<User> lstSalesOpsAdminUser;
		
		//find the ChannelAdmin User Name
		if (string.isNotBlank(countryName)){
			ChannelAdminUserName = mapCountryNameAdminUserName.get(countryName.toLowerCase());
			system.debug('***ChannelAdminUserName: ' + ChannelAdminUserName);
			//if there is Admin for a country check for the existence of OTHERS admin user. If present use it, otherewise give up
			if (string.isBlank(ChannelAdminUserName)){
				string DRConstant_Others = DR_Settings__c.getOrgDefaults().DR_Constant_Others__c; // This is like a Constant but instead stored in Custom Settings
				system.debug('***DRConstant_Others: ' + DRConstant_Others);
				if (string.isNotBlank(DRConstant_Others)){
					ChannelAdminUserName = mapCountryNameAdminUserName.get(DRConstant_Others.toLowerCase());
					system.debug('***ChannelAdminUserName - Other: ' + ChannelAdminUserName);
				}
						
			}
		}
		//End: find the ChannelAdmin User Name
		
		//Get the ChannelAdminUser Id
		if (string.isNotBlank(ChannelAdminUserName)){
			lstSalesOpsAdminUser = [Select Id From User Where username = :ChannelAdminUserName and IsActive = true];
			if(lstSalesOpsAdminUser != null && !lstSalesOpsAdminUser.isEmpty()){
				ChannelAdminUserSFDCId = lstSalesOpsAdminUser[0].Id;
			}
		}
		//End: Get the ChannelAdminUser Id
		system.debug('***lstSalesOpsAdminUser: ' + lstSalesOpsAdminUser);
		system.debug('***Exits getChannelAdmin with country name: ' + countryName);
		return ChannelAdminUserSFDCId;
	}
	//============================================================================================
    
}