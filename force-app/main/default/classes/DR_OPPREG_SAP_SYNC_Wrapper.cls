/*
	2018.09.30 - pjena - DR_OPPREG_SAP_SYNC_Batch uses this wrapper class
	
*/
public class DR_OPPREG_SAP_SYNC_Wrapper {
	
	public class OPP_HEADER{
		public string oId{get;set;} //Id of the Opportunity; not used in the callout but used for error logging
		public string Opportunity_ID {get;set;} // = 'O-412203';
        public string Reseller_ID {get;set;} // = '0000800172'; //NPN's SAP Customer Number
        public string PEC_ID{get;set;} // = '0009018742'; //End Customer's SAP Customer Number
        public string Expiry_Date {get;set;} // = '20181231'; //It has to be YYYYMMDD; otherwise SAP throws exception
        public string Status {get;set;} // = 'Approved'; //It can be "A"; check with Muthu what he expects
	}
	
	public class OPP_LINEITEM{
		public string Opportunity_Item_No{get;set;} // = '000001';
        public string Material_Number{get;set;} // = '711-DWS022';
        public string Term{get;set;} // = '12';
        public string Quantity{get;set;} // = '5.0';
	}
	
	public class OPP_APPROVER{
		public string Opportunity_Counter{get;set;} // = '1' or '2';
		public string Name{get;set;} // 'Paresh Jena' - Full name of the Approver
		public string Email_ID{get;set;} //'pjena@nvidia.com' - Email id of the approver
		public string Approved_On{get;set;} //'20181231' - It has to be YYYYMMDD; otherwise SAP throws exception
		public string Approved_At{get;set;} // '232558' - It has to be HHMMSS; otherwise SAP throws exception
	}
	
	public class CALLOUT_RESPONSE{
		public string subjectId{get;set;} //subject being the Record for which the sync initiated e.g., Opportunity
		public string RETURN_SDFCExceptionName{get;set;}
		public string RETURN_SDFCExceptionMsg{get;set;}
		public boolean IsSFDCError{get;set;}
		public string RETURN_CODE{get;set;}
		public string RETURN_TYPE{get;set;}
		public string RETURN_MESSAGE{get;set;}
	}
	
	
	public static CALLOUT_RESPONSE callout_syncOppRegDataToSAP(OPP_HEADER header, list<OPP_APPROVER> lstApprover, list<OPP_LINEITEM> lstLineItem, string namedCredentialEndPoint, integer iCalloutTimeOut){
		system.debug('***Entering callout_syncOppRegDataToSAP method');
		DR_SAPOppRegIntegration.HTTPS_Port request = new DR_SAPOppRegIntegration.HTTPS_Port();
		CALLOUT_RESPONSE oCalloutResponse = new CALLOUT_RESPONSE();
        try{
			//SAP End Point
	        request.endpoint_x = namedCredentialEndPoint; //'callout:SAP_OppReg'
	        request.timeout_x = iCalloutTimeOut; //90000

	        //Opportunity Header
	        DR_SAPOppRegIntegration.Header_element header_x = new DR_SAPOppRegIntegration.Header_element();
	        
	        //Populate Opportunity Header
	        //------------------------------------------------------------------------------------------
	        header_x.Opportunity_ID = header.Opportunity_ID;
	        header_x.Reseller_ID = header.Reseller_ID;
	        header_x.PEC_ID = header.PEC_ID;
	        header_x.Expiry_Date = header.Expiry_Date;
	        header_x.Status = header.Status;
	        //------------------------------------------------------------------------------------------
	        
	        //Populate Approver_element Array
	        //------------------------------------------------------------------------------------------
	        DR_SAPOppRegIntegration.Approver_element[] OPP_APPROVER_Array_x = new DR_SAPOppRegIntegration.Approver_element[]{};
			DR_SAPOppRegIntegration.Approver_element OPP_APPROVER_x;
			
			for (OPP_APPROVER approver : lstApprover){
				OPP_APPROVER_x = new DR_SAPOppRegIntegration.Approver_element();
				OPP_APPROVER_x.Opportunity_Counter = approver.Opportunity_Counter;
				OPP_APPROVER_x.Name = approver.Name;
				OPP_APPROVER_x.Email_ID = approver.Email_ID;
				OPP_APPROVER_x.Approved_On = approver.Approved_On;
				OPP_APPROVER_x.Approved_At = approver.Approved_At;
				OPP_APPROVER_Array_x.add(OPP_APPROVER_x);
			}
			
			//------------------------------------------------------------------------------------------
	        
	        //Opportunity Line Item Element Array
	        //------------------------------------------------------------------------------------------
	        DR_SAPOppRegIntegration.Item_element[] OPP_LINEITEM_Array_x = new DR_SAPOppRegIntegration.Item_element[]{};
			DR_SAPOppRegIntegration.Item_element OPP_LINEITEM_x;
			
	        for (OPP_LINEITEM oli : lstLineItem){
				OPP_LINEITEM_x = new DR_SAPOppRegIntegration.Item_element();
	        	OPP_LINEITEM_x.Material_Number = oli.Material_Number;
	        	OPP_LINEITEM_x.Term = oli.Term;
	        	OPP_LINEITEM_x.Quantity = oli.Quantity;
	        	OPP_LINEITEM_Array_x.add(OPP_LINEITEM_x);
	        }
	        //------------------------------------------------------------------------------------------
	        
	        //Call SAP API
	        //------------------------------------------------------------------------------------------
			DR_SAPOppRegIntegration.RETURN_ITEM_element[] response_x = new DR_SAPOppRegIntegration.RETURN_ITEM_element[]{};
			response_x = request.NvidiaOpportunityRegistration(header_x, OPP_APPROVER_Array_x, OPP_LINEITEM_Array_x); //header, approverlist, lineitemlist
			
			system.debug('***response_x from SAP: ' + response_x);
			oCalloutResponse.subjectId = header.oId; 
			oCalloutResponse.RETURN_CODE = response_x[0].RETURN_CODE;
			oCalloutResponse.RETURN_TYPE = response_x[0].RETURN_TYPE;
			oCalloutResponse.RETURN_MESSAGE = response_x[0].RETURN_MESSAGE;
			//------------------------------------------------------------------------------------------
		
        }catch(Exception ex){
        	oCalloutResponse.subjectId = header.oId; 
        	oCalloutResponse.IsSFDCError = true;
        	oCalloutResponse.RETURN_SDFCExceptionName = ex.getMessage();
        	oCalloutResponse.RETURN_SDFCExceptionMsg = ex.getStackTraceString();
        }
        system.debug('***oCalloutResponse (Includes SFDC Exception if any) : ' + oCalloutResponse);
        system.debug('***Exiting callout_syncOppRegDataToSAP method');
		return oCalloutResponse;
	}
    
}