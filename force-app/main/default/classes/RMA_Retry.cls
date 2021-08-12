/*
 *  This is a batch job that attempts to sync the RMA record (Custom record - RMA__c) via an external callout
 *  Following RMA records are eligible for sync
 *  - RMA records that do not have the SAP RMA Number populated yet (i.e. SAP_RMA_Number__c = null )
 *  This batch job may be instantiated in a couple of ways
 *  - a single argument constuctor with a specific RMA record identifier,
 *    for which the SAP RMA Number is required from the External System
 *  - a no argument constructor where all RMA records with a blank SAP Number that have not been processed yet
 *  Akhilesh Gupta     | 04/07/2019      | Comment Code related to RMA Retry Job
 -- Known Issues: 
 --- Query should look only for certain time period 
 --- Error Logging is not correct.
 */ 
global class RMA_Retry {
//implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global RMA_Retry() {}
    /*	public final static String DATE_FORMAT = 'yyyyMMdd';
	String query;
  List<RMA__c> RMAList = new List<RMA__c>();
  public string MESSAGE_TEXT {get;set;}
  public string MESSAGE_TYPE {get;set;}
   global RMA_Retry(String RMAID){
    query = PRFT_DomainLayer.buildQueryFields('RMA__c',' Where Id = \''+RMAID+'\'','Select ');
    System.debug('Checking query constructor--'+query);
  }
  // Retrieve all the blank RMAs
	global RMA_Retry() {
		query = PRFT_DomainLayer.buildQueryFields('RMA__c',' Where  SAP_RMA_Number__c = null ','Select ');
		System.debug('Checking query--'+query);
	}
	
  // Query the RMAs
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('checking query---'+query);
		return Database.getQueryLocator(query);
	}
	
	*/
  // Execute the batch apex to resync them due to batch limits it is ideal to set the batch size as 10.
 /*
  * This the main method of execution within the Batch class
  * Input:  BC (Database.BatchableContext) - the context object for this batchable process
  *         scope - A list of custom RMA__c records to be prcoessed for SAP RMA Number
  *               [Note: the list size should ideally be restricted to 10 to avoid governor limits w.r.t external callouts]
  * Output: None
  * Desc:   Before the execution of the external callout, 
  *           prepare a collection of the following and store the necessary information
  *         For each RMA record,
  *         - Store the Case Number from the Case record associated with the RMA record
  *         - Store the Entitlement start date from the Entitlement record associated with the RMA record
  *         Next, construct the 'crmcomplaintproxy' SOAP for the external call. Use the RMA information to populate
  *         - Shipping Instructions
  *         - Sold to Address
  *         - Ship to Address
  *         - Contact information
  *         - Quantity and Order information
  *         Invoke the RMA external callout and parse the response for success/failure
  *         Update and persist the response info to the RMA__c custom object
  */
 /*	global void execute(Database.BatchableContext BC, List<RMA__c> scope) {
		Map<String,List<RMA__c>> caseVsRMA = new Map<String,List<RMA__c>> ();
    Set<Id> entiIdSet = new Set<Id>();
    Set<Id> caseIdSet = new Set<Id>();
    Map<Id,Entitlement> entiMap = new Map<Id,Entitlement>();
    Map<Id,Case> caseMap = new Map<Id,Case>();
    for(RMA__c rmaObj : scope){
        entiIdSet.add(rmaObj.Entitlement__c);
        caseIdSet.add(rmaObj.Case__c);
    }
    if(!entiIdSet.isEmpty()){
        for(Entitlement enti : [SELECT StartDate FROM Entitlement]){
            entiMap.put(enti.Id, enti);
        }
    }
    if(!caseIdSet.isEmpty()){
        for(Case c : [SELECT CaseNumber FROM Case]){
            caseMap.put(c.Id, c);
        }
    }
		integer i =0;
		for(RMA__c rmaObj : scope){
			if(i > 10)
			break;
			crmcomplaintproxy.CrmComplaintProxy_element comElement = new crmcomplaintproxy.CrmComplaintProxy_element();
      String EXTERNAL_REFERENCE_NUMBER = rmaObj.case__c;
      String SFDC_CASE_INCIDENT_NUMBER = caseMap.get(rmaObj.case__c)==null?'':caseMap.get(rmaObj.case__c).CaseNumber;
      String SPECIAL_SHIPPING_INSTRUCTIONS = rmaObj.Special_Instructions_to_RMA_Team__c;
      if(SPECIAL_SHIPPING_INSTRUCTIONS == null){
          SPECIAL_SHIPPING_INSTRUCTIONS = '';
      }
      crmcomplaintproxy.SoldToAddress_element SoldToAddress = new crmcomplaintproxy.SoldToAddress_element();
      SoldToAddress.SOLD_NAME1 = rmaObj.ShipTo_Name1__c==null?'':rmaObj.ShipTo_Name1__c; 
      SoldToAddress.SOLD_NAME2 = rmaObj.ShipTo_Name2__c==null?'':rmaObj.ShipTo_Name2__c;
      SoldToAddress.SOLD_COUNTRY = rmaObj.Country__c==null?'':rmaObj.Country__c;
      SoldToAddress.SOLD_STREET = rmaObj.Street__c==null?'':rmaObj.Street__c;        
      SoldToAddress.SOLD_CITY1 = rmaObj.City__c==null?'':rmaObj.City__c;
      SoldToAddress.SOLD_POST_CODE1 =rmaObj.Zip_Code__c==null?'':rmaObj.Zip_Code__c;
      SoldToAddress.SOLD_REGION = rmaObj.Region__c==null?'':rmaObj.Region__c;
      SoldToAddress.SOLD_EMAIL = rmaObj.ShipTo_Email__c==null?'':String.valueOf(rmaObj.ShipTo_Email__c);
      SoldToAddress.SOLD_TEL_NUMBER = rmaObj.Ship_Tel_Phone__c==null?'':rmaObj.Ship_Tel_Phone__c;
      SoldToAddress.SOLD_HOUSE_NUM1 = rmaObj.Equipment_Location_Address2__c==null?'':rmaObj.Equipment_Location_Address2__c;
      SoldToAddress.SOLD_STR_SUPPL3 = rmaObj.Street_3__c==null?'':rmaObj.Street_3__c; 
      SoldToAddress.SOLD_LOCATION = rmaObj.Street_4__c==null?'':rmaObj.Street_4__c;
      SoldToAddress.LANGUAGE = 'EN';
      // Initialise ship to addresses
      crmcomplaintproxy.ShipToAddress_element ShipToAddress = new crmcomplaintproxy.ShipToAddress_element();
      ShipToAddress.SHIP_NAME1 = rmaObj.ShipTo_Name1__c;
      ShipToAddress.SHIP_NAME2 = rmaObj.ShipTo_Name2__c==null?'':rmaObj.ShipTo_Name2__c;
      ShipToAddress.SHIP_COUNTRY = rmaObj.Country__c==null?'':rmaObj.Country__c;
      ShipToAddress.SHIP_STREET = rmaObj.Street__c==null?'':rmaObj.Street__c;       
      ShipToAddress.SHIP_CITY1 = rmaObj.City__c==null?'':rmaObj.City__c;
      ShipToAddress.SHIP_POST_CODE1 = rmaObj.Zip_Code__c==null?'':rmaObj.Zip_Code__c;
      ShipToAddress.SHIP_REGION = rmaObj.Region__c==null?'':rmaObj.Region__c;
      ShipToAddress.SHIP_EMAIL = rmaObj.ShipTo_Email__c==null?'':String.valueOf(rmaObj.ShipTo_Email__c);
      ShipToAddress.SHIP_TEL_NUMBER = rmaObj.Ship_Tel_Phone__c==null?'':rmaObj.Ship_Tel_Phone__c;
      ShipToAddress.SHIP_HOUSE_NUM1 = rmaObj.Equipment_Location_Address2__c==null?'':rmaObj.Equipment_Location_Address2__c;
      ShipToAddress.SHIP_STR_SUPPL3 = rmaObj.Street_3__c==null?'':rmaObj.Street_3__c;
      ShipToAddress.SHIP_LOCATION = rmaObj.Street_4__c==null?'':rmaObj.Street_4__c;
      String[] ADD_EMAIL = new String[]{};
      
      crmcomplaintproxy.OnSiteContact_element[] OnSiteContact = new List<crmcomplaintproxy.OnSiteContact_element>();
      crmcomplaintproxy.OnSiteContact_element contactElement = new crmcomplaintproxy.OnSiteContact_element();
      contactElement.Name = rmaObj.On_site_Contact1_Name__c;
      contactElement.Phone = String.valueOf(rmaObj.On_site_Contact1_Phone__c);
      contactElement.Email = String.valueOf(rmaObj.On_site_Contact1_Email__c);
      OnSiteContact.add(contactElement);
        
        // second onsite contact
        if(!String.isBlank(rmaObj.On_site_Contact2_Name__c)){
            crmcomplaintproxy.OnSiteContact_element contactElement1 = new crmcomplaintproxy.OnSiteContact_element();
            contactElement1.Name = rmaObj.On_site_Contact2_Name__c;
            contactElement1.Phone = String.valueOf(rmaObj.On_site_Contact2_Phone__c);
            contactElement1.Email = String.valueOf(rmaObj.Onsite_Contact2_Email__c);
             OnSiteContact.add(contactElement1);
        }
        comElement.ADD_EMAIL = new List<String>();
        if(!string.isblank(rmaObj.Additional_Email_Addresses__c)){
            if(rmaObj.Additional_Email_Addresses__c.contains(',')){
                ADD_EMAIL = rmaObj.Additional_Email_Addresses__c.split(',');
            } else if(rmaObj.Additional_Email_Addresses__c.contains('\n')){
                ADD_EMAIL = rmaObj.Additional_Email_Addresses__c.split('\n');
            }else if(rmaObj.Additional_Email_Addresses__c.contains(';')){
                ADD_EMAIL = rmaObj.Additional_Email_Addresses__c.split(';');
            }else{
                ADD_EMAIL.add(rmaObj.Additional_Email_Addresses__c);
            }
        }
        else 
        ADD_EMAIL.add('');
        crmcomplaintproxy.RmaItemInformation_element[] RmaItemInformation = new crmcomplaintproxy.RmaItemInformation_element[]{};
  		  crmcomplaintproxy.RmaItemInformation_element rmaElement = new crmcomplaintproxy.RmaItemInformation_element();
        String ReplacementType =getReplacementString(rmaObj.Replacement_Type__c);
        System.debug('checking repoption--'+ReplacementType);
        DateTime poDateSolddt = null;
        if(rmaObj.Entitlement__c != null 
            && entiMap.get(rmaObj.Entitlement__c)!=null 
            && entiMap.get(rmaObj.Entitlement__c).StartDate != null){
            poDateSolddt = DateTime.newInstance(entiMap.get(rmaObj.Entitlement__c).StartDate, Time.newInstance(0,0,0,0));
        }
        rmaElement.SFDC_CASE_ITEM_NUMBER = rmaObj.Id; 
        System.debug('checking rma item---'+rmaObj.NVIDIA_Part_Number__c);
        rmaElement.ORDERED_PROD = rmaObj.NVIDIA_Part_Number__c;
        rmaElement.QUANTITY = '1';
        rmaElement.REPOPTION = ReplacementType; // Retrieves replacement code from custom setting
        rmaElement.PO_DATE_SOLD = poDateSolddt==null?'':poDateSolddt.format(DATE_FORMAT);//rmaObj.Entitlement__c; // Passing PO_Date_Sold as Entitlement Start Date
        String doa = '';
        if(rmaObj.DEAD_ON_ARRIVAL__c == 'Yes'){
            doa = 'X';
        }
        rmaElement.DEAD_ON_ARRIVAL = doa;
        rmaElement.ADDITIONAL_INFORMATION = rmaObj.ADDITIONAL_INFORMATION__c;
        rmaElement.ITMSTATE = 'New';
        rmaElement.KBETR = '0.01';
        rmaElement.ORDERNUM = null;
        rmaElement.ORDERLINNUM= null;
        rmaElement.PROBLEM_DESCRIPTION = rmaObj.PROBLEM_DESCRIPTION__c;
        rmaElement.SPECIAL_INSTRUCTIONS = rmaObj.Special_Instructions_to_RMA_Team__c;
        rmaElement.WAERS ='USD';
        rmaElement.ZCRMT_SERIAL_NUMBER = String.valueOf(rmaObj.Serial_Number__c);
        RmaItemInformation.add(rmaElement);
        nvidiaServicecloud.HTTPS_Port port = new nvidiaServicecloud.HTTPS_Port();
        port.inputHttpHeaders_x =new Map<String,String>();
        String xbody =    nvidiaServicecloud.createSoapRequest(EXTERNAL_REFERENCE_NUMBER,
                                   SFDC_CASE_INCIDENT_NUMBER,
                                   SPECIAL_SHIPPING_INSTRUCTIONS,
                                   SoldToAddress,
                                   ShipToAddress,
                                   ADD_EMAIL,
                                   OnSiteContact,
                                   RmaItemInformation );
       String res = RMA_IDM_Callouts.invokeStaticRMACallout(xbody);
        Boolean gotResponse = false;
        if(!res.Contains('Callout Exception')){
            XmlStreamReader xsr = new XmlStreamReader(res);
            DOM.Document doc=new DOM.Document();
            doc.load(res);
            DOM.XmlNode rootNode=doc.getRootElement();
            RMAList = new List<RMA__c>();
            MESSAGE_TEXT = '';
            MESSAGE_TYPE = '';
            parseXML(rootNode);
            System.debug('checking RMAList size--'+RMAList.size()+'---'+RMAList);
       } else {
         rmaObj.SAP_CalloutMessage__c = res;
         RMAList.add(rmaObj);
       }
         i++;
	}
 if(!RMAList.isEmpty()){
       Database.update(RMAList,false);
   }

	}
	*/
  // Final Method checks if all the records have been executed or not.
/*	global void finish(Database.BatchableContext BC) {
		// calling final
    System.debug('With in final.');
    if(System.label.ExecuteRMASync == 'true'){
       query = PRFT_DomainLayer.buildQueryFields('RMA__c',' Where  SAP_RMA_Number__c = null ','Select ');
      List<RMA__c> rmaList= Database.query(query);
      if(rmaList != null && !rmaList.isEmpty()){
        RMA_Retry rma = new RMA_Retry();
           if(!Test.isRunningTest())
        Id batchJobId = Database.executebatch(rma,10);
      }
    } 
	}

  // Get the id for the Replacement Type
	 public string getReplacementString(String repl){
        List<RMA_ReplacementMapping__c> replaceList = (List<RMA_ReplacementMapping__c>) PRFT_DomainLayer.queryObj('RMA_ReplacementMapping__c','WHERE Name ='+'\''+repl+'\'');
        if(replaceList != null && !replaceList.isEmpty()){
           return replaceList[0].Replacement_Code__c;
        }
        return '';
    }

    // Parse the webservice response.
    private void parseXML(DOM.XMLNode node) {
      if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
      system.debug('---checking node name---'+node.getName());
      if(node.getName()=='RMA'){
          DOM.XMLNode[] tempNode = node.getChildElements();
          RMA__c rmRes = new RMA__c();
          for(Dom.XMLNode RMAchild: tempNode){
            system.debug('---checking RMAchild name---'+RMAchild.getName());
            if(RMAchild.getName() == 'SFDC_RMA_NUMBER'){
                String RMAID= RMAchild.getText().trim();
                System.debug('get test-RMAchild--'+RMAchild.getText());
            if(!String.isBlank(RMAID)){
                        rmRes.Id = RMAID;
                    }
             }
            if(RMAchild.getName() == 'CRM_COMPLAINT_NUMBER'){
                 System.debug('get test---'+RMAchild.getText());
                 rmRes.Crm_Complaint_Number__c = RMAchild.getText().trim();
                  System.debug('get CRM_COMPLAINT_NUMBER---'+RMAchild.getText());
             }
            if(RMAchild.getName() == 'RMA_STATUS'){
                  System.debug('get test---'+RMAchild.getText());
                   rmRes.RMA_Status__c = RMAchild.getText().trim();
                        System.debug('get RMA_STATUS---'+RMAchild.getText());
                   
            }
           if(RMAchild.getName() == 'CRM_RMA_NUMBER'){
                  System.debug('get test---'+RMAchild.getText());
                  rmRes.SAP_RMA_Number__c = RMAchild.getText().trim();
                  System.debug('get CRM_RMA_NUMBER---'+RMAchild.getText());
            }if(RMAchild.getName() == 'MESSAGE_TYPE'){
                  System.debug('get MESSAGE_TYPE---'+RMAchild.getText());
                  MESSAGE_TYPE = RMAchild.getText().trim();
                  if(!String.isBlank(MESSAGE_TYPE)){
                        rmRes.SAP_Message_Type__c = MESSAGE_TEXT;
                    }
             }if(RMAchild.getName() == 'MESSAGE_TEXT'){
                   System.debug('get MESSAGE_TEXT---'+RMAchild.getText());
                    MESSAGE_TEXT = RMAchild.getText().trim();
                    if(!String.isBlank(MESSAGE_TEXT)){
                        rmRes.SAP_CalloutMessage__c = MESSAGE_TEXT;
                    }
                 }
                  node.removeChild(RMAchild);
               }
            if(!String.isBlank(rmRes.Id)){
                 RMAList.add(rmRes);
               }
            }
          for (Dom.XMLNode child: node.getChildElements()) {
            parseXML(child);
          }
       }
    }*/
}