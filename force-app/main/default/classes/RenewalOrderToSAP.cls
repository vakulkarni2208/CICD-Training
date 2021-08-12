/**
* ==================================================================================
*    Version        Date                          Comment
* ==================================================================================
*    v1.1       19-7-2017
*
*
*/

global class RenewalOrderToSAP
{
    static final string SUCCESS = 'S';
    static final string WARNING = 'W';
    static final string FAILURE = 'F';
    static final string DATE_FORMAT = 'yyyyMMdd';

    public static Boolean disable {get;set;}
    public static Order objOrder {get; set;}
    public static String strResult {get; set;}
    public static final string STR_SUCCESS = System.Label.Success;//'Success'
    public static final string STR_WARNING = System.Label.Warning;//'Warning'
    public static final string STR_FAILURE = System.Label.Failure;//'Failure'
    public static final string STR_NO_MSG = System.Label.No_Message_Found;//'No message found'
    public static final string STR_THE_ORDER = System.Label.The_Order;//'The order'
    public static final string STR_SUBMITTED_SUCCESSFULLY = System.Label.Successfully_Sent;//'has been successfully sent to SAP';
    public static final string STR_SUBMISSION_FAILED = System.Label.Submission_Failed;//'The order submission failed and will be automatically resubmitted.'
    public static final string STR_SUBMITTED_WITH_WARNING = System.Label.Submitted_With_Warnings;//'The order was submitted to SAP with warnings. Review the CPQ export log for details.'

    webservice static RequestDetailsWrapper CreateOrderData(String ID) // you can pass parameters
    {

        // Retreive data from sf
        List<Order> orderList = new List<Order>();
        List<OrderItem> orderItemList = new List<OrderItem>();
        for(Order orderObj : [SELECT   Id,
                              Purchase_Order_Number__c,
                              PO_Date__c,
                              SBQQ__Quote__r.Name,
                              Account.Name,
                              Account.CPQ_Currency__c,
                              Account.RecordType.Name,
                              Account.SAP_Customer_Number__c,
                              SBQQ__Quote__r.SBQQ__Opportunity2__c, 
                              SBQQ__Quote__r.End_Customer_Contact__r.SAP_Contact_ID__c,
                              SBQQ__Quote__r.Reseller_Account__r.SAP_Customer_Number__c,
                              SBQQ__Quote__r.Reseller_Contact__r.SAP_Contact_ID__c,
                              SBQQ__Quote__r.Sold_To__r.SAP_Customer_Number__c,
                              Sales_Organization__c,
                              (SELECT id,
                               SBQQ__QuoteLine__r.SBQQ__Number__c,
                               Quantity,
                               SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c,
                               SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c,
                               SBQQ__QuoteLine__r.Renewed_Entitlement_ID__c,
                               SBQQ__QuoteLine__r.Renewed_PAK_ID__c,
                               SBQQ__QuoteLine__r.SBQQ__NetPrice__c,
                               SBQQ__QuoteLine__r.Hardware_Serial_Number__c,
                               SBQQ__QuoteLine__r.Condition_Type__c,
                               SBQQ__QuoteLine__r.SBQQ__ProductCode__c,
                               SBQQ__QuoteLine__r.CPQ_Price_List__c,
                               SBQQ__QuoteLine__r.Customer_Classification__c,
                               SBQQ__QuoteLine__r.Sales_Type_Code__c,
                               SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c
                               FROM OrderItems)
                              FROM    Order
                              WHERE   Id =:ID]) {

                                  orderList.add(orderObj);

                                  for(OrderItem orderLineObj: orderObj.OrderItems) {
                                      orderItemList.add(orderLineObj);
                                      system.debug('OrderItem'+orderLineObj);
                                      system.debug('Order'+orderObj);
                                  }

                                  system.debug('Order LIst'+orderList);
                                  system.debug('Order ITem LIst'+orderItemList);
                                  //system.debug('order item::::::::::::'+orderItemLst);
                              }

        // construct the wsdl object

        // Set password and headers here
        SAPCPQIntegration.HTTPS_Port request=new SAPCPQIntegration.HTTPS_Port();
        // request.clientCertName_x = 'svccpq';
        // request.clientCertPasswd_x = 'a.?UvxK9`Jq/N';
        request.inputHttpHeaders_x = new Map<String, String>();
        request.timeout_x = 90000;

        List<CPQ_Settings__c> cpqSettings = CPQ_Settings__c.getAll().values();
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(cpqSettings[0].UserName__c + ':' + cpqSettings[0].Password__c));

        //request.inputHttpHeaders_x.put('Accept', '*');
        request.inputHttpHeaders_x.put('Authorization', authorizationHeader);

        //request.timeout_x=180;

        SAPCPQIntegration_Functions.RENEWAL_ORDER_Response_element response =
            new SAPCPQIntegration_Functions.RENEWAL_ORDER_Response_element();

        //Order Header
        SAPCPQIntegration_Functions.ORDER_HEADER_element ORDER_HEADER =
            new SAPCPQIntegration_Functions.ORDER_HEADER_element();

        // set default values for results in case order list is empty
        String[] result = new String[3];
        result[0] = 'Warning';
        result[1] = 'Order not found';
        result[2] = '';

        RequestDetailsWrapper objRequestDetailsWrapper = new RequestDetailsWrapper();

        if(!orderList.isEmpty()) {

            //Order Partner Element
            SAPCPQIntegration_Functions.ORDER_PARTNERS_element ORDER_PARTNERS =
                new SAPCPQIntegration_Functions.ORDER_PARTNERS_element();
            SAPCPQIntegration_Functions.OrderPartnerItem ORDER_PARTNER_ITEM  =
                new SAPCPQIntegration_Functions.OrderPartnerItem();
            ORDER_PARTNERS.item = new SAPCPQIntegration_Functions.OrderPartnerItem[]{};

            for(Order orderToBeSent : orderList) {

                // Populate order header
                ORDER_HEADER.SALES_ORG_C = orderToBeSent.Sales_Organization__c;
                ORDER_HEADER.PURCH_NO_C  = orderToBeSent.Purchase_Order_Number__c;
                ORDER_HEADER.REF_1 = orderToBeSent.SBQQ__Quote__r.Name;
                ORDER_HEADER.PURCH_DATE  = getFormattedDate(orderToBeSent.PO_Date__c); // Will need to be string first
                ORDER_HEADER.SFDCID_OPTY=orderToBeSent.SBQQ__Quote__r.SBQQ__Opportunity2__c;    //Adding Opportunity ID to Mapping
                //ORDER_HEADER.ACCT_RTYPE = orderToBeSent.Account.RecordType.Name; // requested this be added, not in current WSDL

                // Populate order partners

                // -- Add End Customer Account only if it has a value (Account)
                if (!String.isEmpty(orderToBeSent.Account.SAP_Customer_Number__c)) {
                    ORDER_PARTNER_ITEM.ITM_NUMBER = '000000';
                    ORDER_PARTNER_ITEM.PARTN_ROLE = 'ZC';
                    ORDER_PARTNER_ITEM.PARTN_NUMB = leftZeroPadString(orderToBeSent.Account.SAP_Customer_Number__c,10);
                    ORDER_PARTNERS.item.add(ORDER_PARTNER_ITEM);
                    ORDER_PARTNER_ITEM = new SAPCPQIntegration_Functions.OrderPartnerItem();
                }

                // -- Add End Customer Contact only if it has a value (End_Customer_Contact__r)
                if (!String.isEmpty(orderToBeSent.SBQQ__Quote__r.End_Customer_Contact__r.SAP_Contact_ID__c)) {
                    ORDER_PARTNER_ITEM.ITM_NUMBER = '000000';
                    ORDER_PARTNER_ITEM.PARTN_ROLE = 'Y1';
                    ORDER_PARTNER_ITEM.PARTN_NUMB = leftZeroPadString(orderToBeSent.SBQQ__Quote__r.End_Customer_Contact__r.SAP_Contact_ID__c,10);
                    ORDER_PARTNERS.item.add(ORDER_PARTNER_ITEM);
                    ORDER_PARTNER_ITEM = new SAPCPQIntegration_Functions.OrderPartnerItem();
                }

                // -- Sold To Account is always populated (Sold_To__c)
                if (!String.isEmpty(orderToBeSent.SBQQ__Quote__r.Sold_To__r.SAP_Customer_Number__c)) {
                    ORDER_PARTNER_ITEM.ITM_NUMBER = '000000';
                    ORDER_PARTNER_ITEM.PARTN_ROLE = 'AG';
                    ORDER_PARTNER_ITEM.PARTN_NUMB = leftZeroPadString(orderToBeSent.SBQQ__Quote__r.Sold_To__r.SAP_Customer_Number__c,10);
                    ORDER_PARTNERS.item.add(ORDER_PARTNER_ITEM);
                    ORDER_PARTNER_ITEM = new SAPCPQIntegration_Functions.OrderPartnerItem();
                }

                // -- Add Reseller Account only if it has a value (Reseller_Account__r)
                if (!String.isEmpty(orderToBeSent.SBQQ__Quote__r.Reseller_Account__r.SAP_Customer_Number__c)) {
                    ORDER_PARTNER_ITEM.ITM_NUMBER = '000000';
                    ORDER_PARTNER_ITEM.PARTN_ROLE = 'ZR';
                    ORDER_PARTNER_ITEM.PARTN_NUMB = leftZeroPadString(orderToBeSent.SBQQ__Quote__r.Reseller_Account__r.SAP_Customer_Number__c,10);
                    ORDER_PARTNERS.item.add(ORDER_PARTNER_ITEM);
                    ORDER_PARTNER_ITEM = new SAPCPQIntegration_Functions.OrderPartnerItem();
                }

                // -- Add Reseller Contact only if it has a value (Reseller_Contact__r)
                if (!String.isEmpty(orderToBeSent.SBQQ__Quote__r.Reseller_Contact__r.SAP_Contact_ID__c)) {
                    ORDER_PARTNER_ITEM.ITM_NUMBER = '000000';
                    ORDER_PARTNER_ITEM.PARTN_ROLE = 'Y2';
                    ORDER_PARTNER_ITEM.PARTN_NUMB = leftZeroPadString(orderToBeSent.SBQQ__Quote__r.Reseller_Contact__r.SAP_Contact_ID__c,10);
                    ORDER_PARTNERS.item.add(ORDER_PARTNER_ITEM);
                    ORDER_PARTNER_ITEM = new SAPCPQIntegration_Functions.OrderPartnerItem();
                }

            }

            //Order Item Element
            SAPCPQIntegration_Functions.ORDER_ITEMS_element ORDER_ITEMS =
                new SAPCPQIntegration_Functions.ORDER_ITEMS_element();
            SAPCPQIntegration_Functions.OrderItemData OrderItemData=
                new SAPCPQIntegration_Functions.OrderItemData();
            ORDER_ITEMS.item = new SAPCPQIntegration_Functions.OrderItemData[]{};

            // Order Conditions
            SAPCPQIntegration_Functions.ORDER_CONDITIONS_element ORDER_CONDITIONS =
                new SAPCPQIntegration_Functions.ORDER_CONDITIONS_element();
            SAPCPQIntegration_Functions.OrderConditionItem OrderConditionItem =
                new SAPCPQIntegration_Functions.OrderConditionItem();
            ORDER_CONDITIONS.item = new SAPCPQIntegration_Functions.OrderConditionItem[]{};

            // Serial Numbers
            SAPCPQIntegration_Functions.SERIAL_NUMBERS_element SERIAL_NUMBERS =
                new SAPCPQIntegration_Functions.SERIAL_NUMBERS_element();
            SAPCPQIntegration_Functions.SerialNumberItem SerialNumberItem =
                new SAPCPQIntegration_Functions.SerialNumberItem();
            SERIAL_NUMBERS.item = new SAPCPQIntegration_Functions.SerialNumberItem[]{};

            for(OrderItem orderItemToBeSent : orderItemList) {

                OrderConditionItem.ITM_NUMBER =
                    String.valueOf(orderItemToBeSent.SBQQ__QuoteLine__r.SBQQ__Number__c * 10);
                OrderConditionItem.COND_TYPE = orderItemToBeSent.SBQQ__QuoteLine__r.Condition_Type__c;
                OrderConditionItem.COND_VALUE =
                    String.valueOf(orderItemToBeSent.SBQQ__QuoteLine__r.SBQQ__NetPrice__c);
                OrderConditionItem.CURRENCY_x = String.valueOf(orderList.get(0).Account.CPQ_Currency__c);

                OrderItemData.ITM_NUMBER =
                    String.valueOf(orderItemToBeSent.SBQQ__QuoteLine__r.SBQQ__Number__c*10);
                OrderItemData.ZZPLSKU =
                    orderItemToBeSent.SBQQ__QuoteLine__r.SBQQ__ProductCode__c +
                    '+' +
                    orderItemToBeSent.SBQQ__QuoteLine__r.CPQ_Price_List__c +
                    orderItemToBeSent.SBQQ__QuoteLine__r.Customer_Classification__c +
                    orderItemToBeSent.SBQQ__QuoteLine__r.Sales_Type_Code__c +
                    leftZeroPadString(String.valueOf(orderItemToBeSent.SBQQ__QuoteLine__r.SBQQ__SubscriptionTerm__c),2);
                OrderItemData.TARGET_QTY = String.valueOf(orderItemToBeSent.Quantity);
                OrderItemData.VBEGDAT = getFormattedDate(orderItemToBeSent.SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c);
                system.debug('SAP OrderItemData.VBEGDAT'+OrderItemData.VBEGDAT);
                OrderItemData.VENDDAT = getFormattedDate(orderItemToBeSent.SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c);
                system.debug('SAP OrderItemData.VENDDAT'+OrderItemData.VENDDAT);
                OrderItemData.ZZRENEWEID =
                    String.valueOf(orderItemToBeSent.SBQQ__QuoteLine__r.Renewed_Entitlement_ID__c);
                system.debug('SAP OrderItemData.ZZRENEWEID'+OrderItemData.ZZRENEWEID);
                OrderItemData.ZZRENEWPID =
                    String.valueOf(orderItemToBeSent.SBQQ__QuoteLine__r.Renewed_PAK_ID__c);
                system.debug('SAP OrderItemData.ZZRENEWPID'+OrderItemData.ZZRENEWPID);
                system.debug('SAP Order Data'+OrderItemData);

                OrderItemData.SFDCID_QTLINE =
                    String.valueOf(orderItemToBeSent.SBQQ__QuoteLine__c);
                system.debug('SAP OrderItemData.SFDCID_QTLINE'+OrderItemData.SFDCID_QTLINE);
                system.debug('SAP Order Data'+OrderItemData);

                SerialNumberItem.SERNR =
                    String.valueOf(orderItemToBeSent.SBQQ__QuoteLine__r.Hardware_Serial_Number__c);
                SerialNumberItem.POSNR = String.valueOf(orderItemToBeSent.SBQQ__QuoteLine__r.SBQQ__Number__c * 10);


                ORDER_ITEMS.item.add(OrderItemData);
                OrderItemData = new SAPCPQIntegration_Functions.OrderItemData();
                system.debug('Order Item Array '+ORDER_ITEMS);
                ORDER_CONDITIONS.item.add(OrderConditionItem);
                OrderConditionItem = new SAPCPQIntegration_Functions.OrderConditionItem();
                // don't add serial block if it is blank
                if(!String.isBlank(SerialNumberItem.SERNR))
                    SERIAL_NUMBERS.item.add(SerialNumberItem);
                SerialNumberItem = new SAPCPQIntegration_Functions.SerialNumberItem();
            }

            System.debug('ORDER_HEADER:'+ORDER_HEADER);
            System.debug('ORDER_CONDITIONS:'+ORDER_CONDITIONS);
            System.debug('ORDER_ITEMS:'+ORDER_ITEMS);
            System.debug('ORDER_PARTNERS:'+ORDER_PARTNERS);
            System.debug('SERIAL_NUMBERS:'+SERIAL_NUMBERS);

            try {

                response = request.RenewalOrder_OB_SYNC(ORDER_HEADER,ORDER_CONDITIONS,ORDER_ITEMS,ORDER_PARTNERS,SERIAL_NUMBERS);

                if (response.EV_ORDER != null && response.EV_ORDER != '') {

                    result[0] = SUCCESS;
                    result[1] = STR_THE_ORDER + ' ['+ response.EV_ORDER +'] ' + STR_SUBMITTED_SUCCESSFULLY;
                    result[2] = response.EV_ORDER;

                } else {
                    System.debug('response type---' + response.MESSAGES.item[0].TYPE_x);
                    result[0] = ( response.MESSAGES.item[0].TYPE_x == 'W' ) ? WARNING : FAILURE;
                    result[1] = response.MESSAGES.item[0].MESSAGE;

                }

            } catch (Exception e) {

                result[0] = FAILURE;
                result[1] = e.getMessage();

            }


            objRequestDetailsWrapper.STR_ORDER_HEADER = ORDER_HEADER;
            objRequestDetailsWrapper.STR_ORDER_CONDITIONS = ORDER_CONDITIONS;
            objRequestDetailsWrapper.STR_ORDER_ITEMS = ORDER_ITEMS;
            objRequestDetailsWrapper.STR_ORDER_PARTNERS = ORDER_PARTNERS;
            objRequestDetailsWrapper.STR_SERIAL_NUMBERS = SERIAL_NUMBERS;
            objRequestDetailsWrapper.str_request = request;
            objRequestDetailsWrapper.result = result;


        }

    return objRequestDetailsWrapper;

    }

    private static String getFormattedDate(Date d){
        // ES Validation
        if(d == null) {
          return null;
        }

        return DateTime.newInstance(d.year(),d.month(),d.day()).format(DATE_FORMAT);
    }

    @InvocableMethod
    public static void SubmitOrder(List<Id> lstOrderIds) {
        if(lstOrderIds <> null && !lstOrderIds.IsEmpty())
            SubmitOrderFuture(lstOrderIds);//String.valueOf(
    }

    @future(callout=true)
    public static void SubmitOrderFuture(List<Id> lstOrderIds) {
        SubmitOrder(lstOrderIds[0],true);//String.valueOf(
    }

    public static String SubmitOrder(String orderId, Boolean isRetry) {
        //isRetry = true;
        disable = true;
        objOrder = new Order(Id=orderId);
        if (orderId != null && String.isNotBlank(orderId)) {
            RequestDetailsWrapper objRequestDetailsWrapper = RenewalOrderToSAP.CreateOrderData(orderId);
            List<String> lstResult = objRequestDetailsWrapper.result;

            if(lstResult != null && !lstResult.IsEmpty()) {
              CPQExportLogWrapper objWrapper = new CPQExportLogWrapper();
              String strOrderNumber;
              objWrapper.isRetry = isRetry;
              objWrapper.intRetryCount = 0;
              if(lstResult.size() > 1)
                objWrapper.strMsg = lstResult[1];
              else
                objWrapper.strMsg = STR_NO_MSG;
              if(lstResult[0] == SUCCESS) {
                if(lstResult.size() > 2)
                  strOrderNumber = lstResult[2];
                else
                  strOrderNumber = '';
                strResult = STR_THE_ORDER + ' ['+ strOrderNumber +'] ' + STR_SUBMITTED_SUCCESSFULLY;
                objWrapper.strPicklistResult = STR_SUCCESS;
                createCPQExportLog(objWrapper, objRequestDetailsWrapper);
              }
              else if(lstResult[0] == WARNING) {
                strResult = STR_SUBMITTED_WITH_WARNING;
                objWrapper.strPicklistResult = STR_WARNING;
                createCPQExportLog(objWrapper, objRequestDetailsWrapper);
              }
              else if(lstResult[0] == FAILURE){
                strResult = STR_SUBMISSION_FAILED;
                objWrapper.strPicklistResult = STR_FAILURE;
                objWrapper.intRetryCount = Integer.valueOf(SAP_Integration_Settings__c.getOrgDefaults().Retry_Count__c);
                createCPQExportLog(objWrapper, objRequestDetailsWrapper);
              }
            }
        }
        return strResult;
    }

    /**
     * Method to insert CPQ Export Log
     */
    public static void createCPQExportLog(CPQExportLogWrapper objWrapper, RequestDetailsWrapper objRequestDetailsWrapper) {

        CPQ_Export_Log__c objCPQExportLog = new CPQ_Export_Log__c();
        objCPQExportLog.Message__c = objWrapper.strMsg;
        objCPQExportLog.Order__c = objOrder.Id;
        objCPQExportLog.Result__c = objWrapper.strPicklistResult;
        objCPQExportLog.Retry_Count__c = objWrapper.intRetryCount;

        objCPQExportLog.Order_Conditions_Request__c = JSON.serialize(objRequestDetailsWrapper.STR_ORDER_CONDITIONS);
        objCPQExportLog.Order_Header_Request__c = JSON.serialize(objRequestDetailsWrapper.STR_ORDER_HEADER);
        objCPQExportLog.Order_Items_Request__c = JSON.serialize(objRequestDetailsWrapper.STR_ORDER_ITEMS);
        objCPQExportLog.Order_Partners_Request__c = JSON.serialize(objRequestDetailsWrapper.STR_ORDER_PARTNERS);
        objCPQExportLog.Serial_Numbers_Request__c = JSON.serialize(objRequestDetailsWrapper.STR_SERIAL_NUMBERS);
        objCPQExportLog.Complete_Request__c = JSON.serialize(objRequestDetailsWrapper.str_request);

        System.debug('--- objCPQExportLog --- ' + objCPQExportLog);


        if(objWrapper.isRetry){
            for(CPQ_Export_Log__c objExportLog: [Select Id, Retry_Count__c From CPQ_Export_Log__c Where Order__c =: objOrder.Id limit 1]){
                objCPQExportLog.Id = objExportLog.Id;
                if(objWrapper.strPicklistResult == STR_FAILURE)
                    objCPQExportLog.Retry_Count__c = objExportLog.Retry_Count__c - 1;
            }
        } else{
            objOrder.Submitted_to_SAP__c = true;
            update objOrder;
        }
        if(objCPQExportLog.Retry_Count__c <> null && objCPQExportLog.Retry_Count__c > 0)
            objCPQExportLog.Resubmit__c = true;
        upsert objCPQExportLog;
    }

    public static String leftZeroPadString(String s, Integer targetWidth){
        // ES Validations
        if(s == null) {
          return s;
        }

        while(s.length() < targetWidth){
            s = '0'+s;
        }
        return s;
    }

    public class CPQExportLogWrapper {
        public Boolean isRetry {get; set;}
        public String strMsg {get; set;}
        public String strPicklistResult {get; set;}
        public Integer intRetryCount {get; set;}
    }

    /**
     * Wrapper class for web service request details.
     */
    global class RequestDetailsWrapper {
        public SAPCPQIntegration_Functions.ORDER_HEADER_element STR_ORDER_HEADER {get; set;}
        public SAPCPQIntegration_Functions.ORDER_CONDITIONS_element STR_ORDER_CONDITIONS {get; set;}
        public SAPCPQIntegration_Functions.ORDER_ITEMS_element STR_ORDER_ITEMS {get; set;}
        public SAPCPQIntegration_Functions.ORDER_PARTNERS_element STR_ORDER_PARTNERS {get; set;}
        public SAPCPQIntegration_Functions.SERIAL_NUMBERS_element STR_SERIAL_NUMBERS {get; set;}
        public SAPCPQIntegration.HTTPS_Port str_request {get; set;}
        public String[] result {get; set;}
    }

}