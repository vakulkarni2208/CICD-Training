@isTest
global class WebServiceSAPCPQMock implements WebServiceMock{
	
	public static String retrunResponceType;
	
	global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
              SAPCPQIntegration_Functions.RENEWAL_ORDER_Response_element respElement = 
              new SAPCPQIntegration_Functions.RENEWAL_ORDER_Response_element();
           if(retrunResponceType == 'TRUE') {
	           respElement.EV_ORDER = 'Mock response Web Service';
	           response.put('response_x', respElement);
           }
           else if(retrunResponceType == 'FALSE')
           {
	           respElement.EV_ORDER = null;
	           response.put('response_x', respElement);
           }
              
             
   }

}