/**************************************************************************************************
* Name       : genericMock 
* Purpose    : generic mock test class for REST API Service methods
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Venkat G           | 1.0        |  January 8,2019 | Mock response creation for REST API Services
**************************************************************************************************/

@isTest
public class genericMock implements HttpCalloutMock {
        public Integer statusCode;
        public String status;
        public String bodyAsString;
        public Map<String,String> responseHeaders;
        
        /**************************************************************************************************
        * Input Parameters: Integer statusCode, String status, String body,Map<String,String> responseHeaders
        * Output: NO return values   
        * Author : Venkat G
        * Purpose: Constructor to assign values
        ***************************************************************************************************/ 
        
        public genericMock(Integer statusCode, String status, String body,Map<String,String> responseHeaders) {
            this.statusCode = statusCode;
            this.status = status;
            this.bodyAsString = body;
            this.responseHeaders = responseHeaders;
        }
        
        /**************************************************************************************************
        * Input Parameters: HTTPRequest object
        * Output: HttpResponse object   
        * Author : Venkat G
        * Purpose: Return mock response for the REST service
        ***************************************************************************************************/ 
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(statusCode);
            resp.setStatus(status);
            resp.setBody(bodyAsString);
            if (responseHeaders != null) {
                 for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
                 }
            }
            return resp;
        }
}