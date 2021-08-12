/**************************************************************************************************
* Name       : TestCalloutMock
* Purpose    : Mock class for WebService Callouts
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/16/2017       | Initial Draft
*Perficient         | 1.0        | 1/17/2017       | Final Draft
**************************************************************************************************/
@isTest
public class TestCalloutMock implements HttpCalloutMock{
    
    protected String msgType;
    public TestCalloutMock(String msgType){
        this.msgType = msgType;
    }
    
    public HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        if(msgType.equals('SUCCESS'))
            res.setBody('<?xml version="1.0" encoding="UTF-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://tews6/wsdl" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.xmlsoap.org/soap/envelope/ http://schemas.xmlsoap.org/soap/envelope/" >     <soapenv:Body>         <ImsStatus version="6.0" >             <transactionId>f1985d43-6cc4a4e9-9d5e5bfd-eb90f</transactionId>         </ImsStatus>     </soapenv:Body> </soapenv:Envelope> ');
        else if(msgType.equals('RMA')){
        system.debug('***response mock**');
            RMA__c rma = [SELECT Id FROM RMA__c][0];
            res.setBody('<SOAP:Envelope xmlns:SOAP=\'http://schemas.xmlsoap.org/soap/envelope/\'><SOAP:Header/><SOAP:Body><crmcomplaintproxyresponse xmlns:prx=\'urn:sap.com:proxy:CRD:/1SAI/TASE7DBB4492DF587A674C5:740\'><RMA><SFDC_CASE_NUMBER>5003D00000244nMQAQ</SFDC_CASE_NUMBER><SFDC_RMA_NUMBER>'+
                        rma.Id
                        +'</SFDC_RMA_NUMBER><CRM_COMPLAINT_NUMBER>0065017647</CRM_COMPLAINT_NUMBER><CRM_RMA_NUMBER>100</CRM_RMA_NUMBER><COMPLAINT_DATE/><RMA_STATUS>SUCCESS</RMA_STATUS><RMA_CRDATE/><RESHIP_PART_NUMBER/><MATERIAL_SERIAL_NUMBER/><FORWARDER_SHIPPER_NAME/><SHIPMENT_TRACKING_NUMBER/><SHIPMENT_TRACKING_NUMBER_URL/><PLANNED_SHIP_OUT_DATE/><ACUTAL_SHIPPED_OUT_DATE/><REJECTION_REASON/><REP_SERIAL_NUMBER/><ACTUAL_RETURN_SERIAL_NUMBER/><RETURN_DELIVERY/><ACTUAL_RETURN_PRODUCT/><Message_TYPE>XML</Message_TYPE><Message_ID/><Message_TEXT>Message</Message_TEXT></RMA></crmcomplaintproxyresponse></SOAP:Body></SOAP:Envelope> ');
            
        }
            
        else
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tews="http://tews6/wsdl" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.xmlsoap.org/soap/envelope/ http://schemas.xmlsoap.org/soap/envelope/" >    <soapenv:Body>        <soapenv:Fault>            <faultcode>soapenv:Client</faultcode>            <faultstring>Error performing operation.</faultstring>            <detail>                <tews:ImsException version="6.0" >                    <tews:exception>                        <tews:name>ServiceCloudDGXAPI</tews:name>                        <tews:code>500</tews:code>                        <tews:description>                            <![CDATA[isActive value should be either T or F. ]]>                        </tews:description>                        <tews:transaction>dd93fd58-c0c9b21c-7b479cf1-78d012</tews:transaction>                    </tews:exception>                </tews:ImsException>            </detail>        </soapenv:Fault>    </soapenv:Body></soapenv:Envelope> ');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}