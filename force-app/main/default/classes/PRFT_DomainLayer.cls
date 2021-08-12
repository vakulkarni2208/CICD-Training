/**
 * A domain class to process queries.
 * Author - Santoshi (Perficient)
 */
public virtual without sharing class PRFT_DomainLayer {
	public static final string WEB_SERVICE_CALLOUT = 'WebService Callout';
    public static final string SALESFORCE = 'Salesforce'; 
    public PRFT_DomainLayer() {
		
	}

	// Class processing query.
    public class QueryEditor{
        public String QUERY_WHERE {get;private set;}
        public string objName {get; private set;}
        public string QUERY_FIELDS {get; private set;}
        public string QUERY_SELECT {get;private set;}
        public string QUERY_FROM {get;private set;}
        public List<SObject> ResultSet { get; private set;}
        public QueryEditor(String obName , String whereQuery , String querySelect){
            objName = obName;
            QUERY_WHERE = whereQuery;
            QUERY_SELECT = 'Select ';
            QUERY_FROM = ' FROM ';
            ResultSet = executeQuery();
        } 
        
        public QueryEditor(String obName , String whereQuery , String qs, boolean hasRelationFields){
            objName = obName;
            QUERY_WHERE = whereQuery;
            QUERY_SELECT = 'Select ';
            QUERY_FROM = ' FROM ';
            if(hasRelationFields){
                QUERY_SELECT = qs;
            }
            ResultSet = executeQuery();
        } 
        
        public QueryEditor(String obName , String whereQuery , String querySelect, String queryFields){
            objName = obName;
            QUERY_WHERE = whereQuery;
            QUERY_FIELDS  = queryFields;
            QUERY_SELECT = 'Select ';
            QUERY_FROM = ' FROM ';
            ResultSet = executeQueryWithFields();
        } 
        
        // Retrievs the field definition for a given object.
        public List<Schema.DescribeFieldResult> getFieldMap(){
            List<Schema.DescribeFieldResult> fields = new List<Schema.DescribeFieldResult>();
            SObjectType accountType = Schema.getGlobalDescribe().get(objName);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            for(Schema.SObjectField sof : mfields.values())
            {
                fields.add(sof.getDescribe());
            } 
            return fields;
        }
        
        //Build the Query String
        private String buildQueryAllString()
        {
            String query = QUERY_SELECT;
            List<Schema.DescribeFieldResult> queryFields = getFieldMap();
            for(Schema.DescribeFieldResult dfr : queryFields)
            {
                query = query + dfr.getName() + ',';
            }
            query = query.subString(0,query.length() - 1);
            query = query + QUERY_FROM + ' ';
            query = query + objName + ' ';
            query = query + QUERY_WHERE;
            system.debug('Build Query == ' + query);
            return query;
        }
        
        //Build the Query String
        private String buildQueryFields()
        {
            String query = QUERY_SELECT;
            query = query + QUERY_FIELDS;  
            query = query.subString(0,query.length() - 1);
            query = query + QUERY_FROM + ' ';
            query = query + objName + ' ';
            query = query + QUERY_WHERE;
            system.debug('Build Query == ' + query);
            return query;
        }
        
        //Build the Query String
        private List<SObject> executeQuery()
        {
            datetime dt = System.now()-1;  
            List<SObject> recList =  Database.query(buildQueryAllString());
            return recList;
        }
        
        //Build the Query String
        private List<SObject> executeQueryWithFields()
        {  
            List<SObject> recList =  Database.query(buildQueryFields());
            return recList;
        }
    }

   /**
    * Queries database
    * 
    * @return List<Sobject>
    */
	 public static List<sObject> queryObj(String objName , String whereClause){
	      List<sObject> objectList = new List<sObject>();
	      QueryEditor qr = new QueryEditor(objName ,whereClause ,'');
	      objectList =  qr.resultSet; 
	      return objectList ;
	  } 

	  /**
    * Queries database
    * 
    * @return List<Sobject>
    */
	 public static List<sObject> queryObj(String objName , String whereClause,string selectClause){
	      List<sObject> objectList = new List<sObject>();
	      QueryEditor qr = new QueryEditor(objName ,whereClause ,selectClause,true);
	      objectList =  qr.resultSet; 
	      return objectList ;
	  } 

	/**
	 * Retrieves Field Information.
	 */
	public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
	{
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
	    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

	    system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

	    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

	    //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
	    System.debug('fieldSetMemberList ====>' + fieldSetObj.getFields());  
	    return fieldSetObj.getFields(); 
	}    
    
    /**
	 * Retrieves Picklist Values
	 */
    public static list<SelectOption> getPicklistValues(SObject ObjectName, String field){
        list<SelectOption> options = new list<SelectOption>();
        Schema.sObjectType objType = ObjectName.getSObjectType(); 
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        list<Schema.PicklistEntry> values = fieldMap.get(field).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values)
        { 
            options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }
        return options;
    }

    //Class to process http request
    public class PRFT_Http{
        public String endpoint{get;private set;}
        public String body {get;private set;}
        public String contentType {get;private set;}
        public String method {get;private set;}
        public String credentials {get;private set;}
        public HTTPResponse res { get; private set;}
        public String responseBody { get; private set;}
        public String errorMessage { get; private set;}
        public Integer statusCode { get; private set;}
        public Boolean doNotEncode {get;private set;}
        Boolean parseSingleField;
        public  PRFT_Http(){
            
        }
        public  PRFT_Http(String endp,String bdy,String contentT, String meth,String accessT){
            endpoint = endp;
            body = bdy;
            contentType = contentT;
            method = meth;
            credentials= accessT;
            parseSingleField = false;
            doNotEncode = true;
            res = getHttpResponse();
            
        }
       
      public  HTTPResponse getHttpResponse(){
            try{
                HttpRequest req = new HttpRequest();
                           
                endpoint = endpoint;    
                req.setEndpoint(endpoint);
                req.setMethod(method);
               // req.setHeader('Authorization', credentials);
                req.setHeader('Content-Type',contentType);
                req.setTimeout(120000);
                req.setBody(body); 
                Http http = new Http();
                System.debug('Final Request Endpoint Before Callout: ' + req.getEndpoint());
                System.debug('Final Request Body Before Callout: ' + req.getBody());
                System.debug('Headers  ' + req.getHeader('Authorization'));
                res = http.send(req);
                system.debug(Logginglevel.INFO,'Callout Exception logging res---'+res);
                responseBody= (String) res.getBody();
                errorMessage = 'Error:-'+res.getStatusCode()+'-'+res.getStatus();
                statusCode =  res.getStatusCode();
                
                
                if(res.getStatusCode() > 300){
                  //  String description = parseString(true,responseBody,'description');
                  //  errorMessage = errorMessage + '-Details-'+description;
                    PRFT_Error err = new PRFT_Error(endpoint,body,errorMessage,responseBody);
                  system.debug(Logginglevel.INFO,'Callout Exception logging responseBody---'+responseBody);
                } 
            } catch(Exception e){
                system.debug(Logginglevel.INFO,'Callout Exception logging error logs---'+e+'---'+e.getStacktraceString());
                PRFT_Error err = new PRFT_Error(endpoint,body,errorMessage,responseBody);
            }
            return res;
        }
        
        
    }

     // public class Error Class
   public class PRFT_Error {
        public String endpoint_URL{get;private set;}
        public String requestBody {get;private set;}
        public String errorType {get;private set;}
        public String errorCode {get;private set;}
        public String recordURL {get;private set;}
        public String responseMessage {get;private set;} 
        public String functionality {get;private set;}
        public String stackTrace {get;private set;} 
        
        public PRFT_Error(String endpointURL,String request, String errorMessage, String response,String errorTypeStr){
            endpoint_URL = endpointURL;
            requestBody = request;
            errorCode = errorMessage;
            errorType = errorTypeStr;
            responseMessage = response;
            insertLogs();  
        }
        
        public PRFT_Error(String endpointURL,String request, String errorMessage, String response){
            endpoint_URL = endpointURL;
            requestBody = request;
            errorCode = errorMessage;
            //response = EncodingUtil.URLENCODE(response,'UTF-8');
            responseMessage = response;
            insertBackEndExceptionLogs();
        }
        
        
        
        public PRFT_Error(String functionalityName,String description, String errorMessage, String recURL,Boolean salesforce){
            functionality = functionalityName;
            stackTrace = description;
            errorCode = errorMessage;
            if(!String.isblank(recURL)){
                recURL = System.Url.getSalesforceBaseURL().toExternalForm() +'/'+ recURL;
            }
            recordURL = recURL;
            insertSalesforceExceptionLogs();
        }
        
        
        public void insertLogs(){
            if(errorType == WEB_SERVICE_CALLOUT)
                insertBackEndExceptionLogs();
            else if(errorType == SALESFORCE){
                insertSalesforceExceptionLogs();
            }
        }
        public void insertBackEndExceptionLogs(){
            try{
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.allowFieldTruncation = true;
                Service_Cloud_Error_Log__c errorLog = new Service_Cloud_Error_Log__c(Callout_Request__c = requestBody, 
                                                                                                   Error_Code__c = errorCode, Response__c = responseMessage, EndPointURL__c = endpoint_URL,Error_Type__c = WEB_SERVICE_CALLOUT);
                errorLog.setOptions(dml);
                if(!System.isBatch())
                insert errorLog;
            } catch (Exception e){
                System.debug('Error in inserting error records ..'+e);
                System.debug(LOGGINGLEVEL.INFO,'Error in inserting error records ..'+e);
            }
        } 
        
        public void insertSalesforceExceptionLogs(){ 
            try{
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.allowFieldTruncation = true;
                Service_Cloud_Error_Log__c errorLog = new Service_Cloud_Error_Log__c(  Functionality_Name__c = functionality, 
                                                                                                   Error_Code__c = errorCode, Error_Description__c = stackTrace,   Record_URL__c = recordURL,Error_Type__c = SALESFORCE);
                errorLog.setOptions(dml);
                 if(!System.isBatch())
                insert errorLog; 
                
            } catch (Exception e){ 
                System.debug('Error in inserting error records ..'+e);
                System.debug(LOGGINGLEVEL.INFO,'Error in inserting error records ..'+e); 
            }
        } 
        
    }  

    //Build the Query String
        public static String buildQueryFields(String objName , String QUERY_WHERE , String QUERY_SELECT)
        {
            String query = QUERY_SELECT;
            String QUERY_FROM = ' FROM ';
            List<Schema.DescribeFieldResult> queryFields = getFieldMap(objName);
            for(Schema.DescribeFieldResult dfr : queryFields)
            {
                query = query + dfr.getName() + ',';
            }
            query = query.subString(0,query.length() - 1);
            query = query + QUERY_FROM + ' ';
            query = query + objName + ' ';
            query = query + QUERY_WHERE;
            system.debug('Build Query == ' + query);
            return query;
            
        }

        // Retrievs the field definition for a given object.
        public static List<Schema.DescribeFieldResult> getFieldMap(String objName){
            List<Schema.DescribeFieldResult> fields = new List<Schema.DescribeFieldResult>();
            SObjectType accountType = Schema.getGlobalDescribe().get(objName);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            for(Schema.SObjectField sof : mfields.values())
            {
                fields.add(sof.getDescribe());
            } 
            return fields;
        }
}