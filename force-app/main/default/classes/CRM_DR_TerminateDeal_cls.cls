/*
	Controller class for CRM_DR_TerminateDeal page
	
	Change List:
	2016.12.14 - Opp Registration TAM - interim change
	
	2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
		- Remove the record type flip (from Deal Reg to original Partner Opportunity type) as we allow the direct creation of Opp Regs
		
	2017.11.29 - PJENA - Deal Registration - only allow Deal Registration types to be terminated
	
*/
public class CRM_DR_TerminateDeal_cls {
	public Opportunity oppty{get;set;}
	private string opptyId{get;set;}
	public string reasonForTermination{get;set;}
	public boolean isDealRegType{get;set;}
	public boolean IsAuthorizedToTerminateDeal{get;set;}
	public boolean isDealRegTerminable{get;set;}
	public boolean showSaveAction{get;set;}
	//constructor
	public CRM_DR_TerminateDeal_cls(ApexPages.StandardController sc){
		isDealRegType = false;
		IsAuthorizedToTerminateDeal = false;
		isDealRegTerminable = false;
		showSaveAction = false;
		
		opptyId = ApexPages.CurrentPage().getParameters().get('Id');
		oppty = [Select DR_SalesOps_Approver__c, DR_PBM_User__c, OwnerId, IsClosed, DR_Is_Terminated__c, DR_Reason_For_Termination__c, Type From Opportunity Where Id = :opptyId];
		
		//check if the oppty type is Deal Registration
		isDealRegType = oppty.Type == DR_Settings__c.getOrgDefaults().Lead_Type__c ? true : false;
		system.debug('***isDealRegType: ' + isDealRegType);
		
		//get the current logged on user
		Id currUserId = userinfo.getUserId();
		system.debug('***currUserId: ' + currUserId);
		
		system.debug('***: oppty.DR_SalesOps_Approver__c = ' + oppty.DR_SalesOps_Approver__c + ', oppty.DR_PBM_User__c = ' + oppty.DR_PBM_User__c + ', oppty.OwnerId = ' + oppty.OwnerId);
		if (currUserId == oppty.DR_SalesOps_Approver__c ||  currUserId == oppty.DR_PBM_User__c || currUserId == oppty.OwnerId){
			IsAuthorizedToTerminateDeal = true;
			system.debug('***IsAuthorizedToTerminateDeal: ' + IsAuthorizedToTerminateDeal);
		}
		
		//get the oppty termination status
		system.debug('***: oppty.IsClosed = ' + oppty.IsClosed + ', oppty.DR_Is_Terminated__c = ' + oppty.DR_Is_Terminated__c );
		if (oppty.IsClosed == false && oppty.DR_Is_Terminated__c != true){
			isDealRegTerminable = true;
			system.debug('***isDealRegTerminable: ' + isDealRegTerminable);
		}
		
		if (isDealRegType && IsAuthorizedToTerminateDeal && isDealRegTerminable){
			showSaveAction = true;
			system.debug('***showSaveAction: ' + showSaveAction);
		}else{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.label.CRM_DR_TERM_INVALID_OPPTYPE_MSG);
			ApexPages.addMessage(myMsg);
		}
	}
	
	//VF Page Action method.
	public PageReference terminateDeal(){
		system.debug('***reasonForTermination: ' + reasonForTermination);
		if (reasonForTermination != null && reasonForTermination != '' ){
			//kick-in termination process
			list<opportunity> lstOppty = [	Select  DR_Is_Terminated__c, DR_Termination_Date__c, DR_Deal_Terminated_By__c
												From Opportunity
												Where id = :opptyId];
			if (lstOppty != null && !lstOppty.isEmpty()){
				oppty = lstOppty[0];
				oppty.Id = opptyId;
					
				//set the DR_Is_Terminated__c, DR_Terminated_Date__c, DR_Deal_Terminated_By__c, RecordTypeId fields
				oppty.DR_Is_Terminated__c = true;
				oppty.DR_Termination_Date__c = Datetime.now();
				oppty.DR_Deal_Terminated_By__c = userinfo.getUserId();
				//revert it back to its original Opprty record type
				//oppty.RecordTypeId =  lstOppty[0].DR_Initial_Oppty_Record_Type_Id__c;
				oppty.DR_Reason_For_Termination__c = reasonForTermination;
				update oppty;
			}
			return new PageReference('/' + opptyId ).setRedirect(true);
		} else {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.label.CRM_DR_TERM_REASON_MSG);
			ApexPages.addMessage(myMsg);             
			return null;
		}
	}
	
	public PageReference cancelDealTermination(){
		return new PageReference('/' + opptyId ).setRedirect(true);
	}
}