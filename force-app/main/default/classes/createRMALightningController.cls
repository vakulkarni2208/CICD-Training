/**************************************************************************************************
* Name       : createRMALightningController
* Purpose    : Controller class for CreateRMAForm page 
***************************************************************************************************
* Author              | Version    | Created Date    | Description
***************************************************************************************************
* Perficient          | 1.0        | 11/15/2017      | Initial Draft
* Perficient          | 2.0        | 11/30/2017      | Design changes
* Manideep Patchava   | 3.0        | 02/25/2019      | RMA enhancements 1.0
* Nilesh Adkar        | 3.1        | 07/25/2019      | SDS-593 : 1. Do not populate part number field when the RMA is first created. When the Special Instruction field is populated, 
                                                        Append Serial Number as a prefix to the "Special Instruction to RMA Team" field before sending to SAP
                                                       SDS-1594 : Update error notifications to be more relevant on RMA
                                                       SDS-1632 : Only Orderable parts will show for RMAs Added 'Orderable__c=true in parts query
* Nilesh Adkar        | 3.2        | 09/06/2019      | SDS-1485 : Do not create RMA in sfdc for call out errors                                                    
* Nilesh Adkar        | 3.3        | 09/30/2019      | SDS-1687: Service: Auto-populate Additional email address on RMA
* Nilesh Adkar        | 3.4        | 11/27/2019      | SDS-1859 : Service: Requires Part for an RMA Integration   
* Nilesh Adkar        | 3.5        | 04/24/2020      | SDS-2203 : Service: RMA Validation for NVBug Number and DOA Flag   
* Nilesh Adkar        | 3.6        | 06/08/2020      | SDS-2422, SDS-2249 USER_EMAIL,USER_FULLNAME,CHASSIS_NUMBER,ACTUAL_RETURN_SERIAL_NUMBER,RETURN_DELIVERY,ACTUAL_RETURN_PRODUCT
* Akhilesh Gupta      | 4.0        | 06/08/2020      | SDS-2455: Updated code to consider address from Asset and associate Asset with RMA
* Nilesh Adkar        | 4.1        | 06/10/2020      | Epic SDS-1686 CE Dispatch flow -> SDS-2230, SDS-2119, SDS-2231, SDS-2232, SDS-2233, SDS-2234 CE Dispatch
* Nilesh Adkar        | 4.2        | 10/19/2020      | SDS-2765 Service: Post Production Changes for CE Dispatch Request
* Nilesh Adkar        | 4.3        | 05/12/2021      | SDS-3141 Added Part_Name_Number_formula__c in Parts query and in select options of Parts
**************************************************************************************************/
public class createRMALightningController extends RMA_IDM_Callouts { 
    public final static String DATE_FORMAT = 'yyyyMMdd';
    public Case cas {get;set;}
    public Id id {get;set;}
    public List < RMAWrapper > lstRMA {get;set;}
    public List < RMA__c > rma = new List < RMA__c > ();
    public String sNo {get;set;}
    public String street1 {get;set;}
    public String street2 {get;set;}
    public String city {get;set;}
    public String state {get;set;}
    public String entCountry {get;set;}
    public String entProdFamily {get;set;}
    public RMA__c rmaObj {get;set;}
    public string MESSAGE_TEXT {get;set;}
    public string MESSAGE_TYPE {get;set;}
    public Integer QuantitySeleceted {get;set;}
    List < RMA__c > RMAList = new List < RMA__c > ();
    List < Entitlement > entitleList = new List < Entitlement > ();
    public Map < String, Entitlement > SerialNumberVsEntitlements {get;set;}
    public Id entitlementId {get;set;}
    public String entitlementName {get;set;}
    public Boolean itemErrors {get;set;}
    public Boolean inputError {get;set;}
    public Boolean isInstallDetail{get;set;}     //SDS-1686
    public Boolean isUpdateShippingInAsset{get;set;}     //SDS-2690
    public Boolean isUpdateShippingInEntitlement{get;set;}     //SDS-2690
    public Boolean isUpdateInstallInAsset{get;set;}     //SDS-2690
    public Boolean isInstallDetailInEntitlement{get;set;}     //SDS-2690
    public Entitlement ent {get;set;}
    public Asset asst {get;set;}
    /*
     *   A default single argument constructor for the Custom Extension controller
     *   Case record identifier is retrieved from the Standard Controller object and stored as a local variable 
     *
     */
    public createRMALightningController(ApexPages.StandardController controller) {
        inputError = false;
        isInstallDetail= false;    //SDS-1686
        isUpdateShippingInAsset = false;
        isUpdateShippingInEntitlement = false;
        isUpdateInstallInAsset = false;
        isInstallDetailInEntitlement = false;
        id = controller.getId();
        System.debug('---in cons-----sNo-------' + sNo);
    }
    /*
     *   The init method is invoked by the CreateRMAFormLightning VF Page. This is a page onload initialization
     *   The following information is initialized for RMA processing
     *   - Retrieval of Case details using the Case record identifier available on the VF Satndard Controller object
     *   - Validation is peformed such as
     *       1. Entitlement Id must be valid (i.e. a Entitlement must be selected for the Case)
     *       2. Product Family must be valid (i.e. a valid Product Family must be selected for the Case) 
     *   - Hardware Serial Number is retrieved for the Entitlement
     *   - RMA Object (RMA__c) is intialized and populated with
     *       1. Onsite Contact
     *       2. Ship To Address
     */
    public void init() {
        itemErrors = false;
        isInstallDetail= false;    //SDS-1686
        isUpdateShippingInAsset = false;
        isUpdateShippingInEntitlement = false;
        isUpdateInstallInAsset = false;
        isInstallDetailInEntitlement = false;
        QuantitySeleceted = 1;
        List<Case> casList = (List<Case>) queryObj('Case','WHERE Id ='+'\''+id+'\'', 'Select Case.Entitlement.AssetId, Case.Entitlement.Asset.ProductFamily, Case.Account.Billing_Region__c,Case.Owner.email,Case.Account.Name, Case.Contact.Email,Case.Contact.FirstName,Case.Contact.Phone,Case.Contact.LastName, ');  // SDS-1687 Added Case.Account.Billing_Region__c,Case.Owner.email
        cas = new Case();
        if(casList != null && !casList.isEmpty()){
            cas = casList[0];
        }

        if (!String.isBlank(cas.EntitlementId)) {
            entitlementId = cas.EntitlementId;
        } else {
            //String msgText = 'Please select Entitlement first before creating RMA.';
            String msgText = System.Label.Service_Cloud_RMA_Error_Message_1;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msgText));
            return;
        }
        if (String.isBlank(cas.Product_Family__c)) {
            //String msgText = 'List of serial numbers cannot be displayed as Product Family is blank. Please add Product Family in case and then try again.';
            String msgText = System.Label.Service_Cloud_RMA_Error_Message_2;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msgText));
            return;
        }
        getSerialNumber();
        //Start: SDS-2455
        //

        if(cas != null && cas.EntitlementId != null && cas.Entitlement.AssetId != null)
            asst = getAssetDetails(cas.Entitlement.AssetId);
        system.debug('20200725 11 EntID: '+ cas.EntitlementId);
        system.debug('20200725 12 AssetID: '+ cas.Entitlement.AssetId);
        system.debug('20200725 13 Asset: '+ asst);
        if(asst != null){
            entProdFamily   = asst.ProductFamily;
            sNo             = asst.SerialNumber;
        }
        if(entitleList != null && !entitleList.isEmpty()){
            if(entitlementId != null){
                for(Entitlement ent : entitleList){
                    if(ent.Id == entitlementId){
                        entProdFamily = ent.Product_Family__c;
                        sNo = ent.Hardware_Serial_Number__c;
                    }
                }
            }
        }
        //End: SDS-2455
        //
        system.debug('entitlementId-->'+entitlementId);
        system.debug('entitleList-->'+entitleList);
        system.debug('sNo-->'+sNo);
        if(entitlementId != null){
            List<Entitlement> tmpList = [SELECT Name FROM Entitlement WHERE Id =: entitlementId];
            if(tmpList.size() >0){
                entitlementName = tmpList[0].Name;
            }
        }
        if (entitleList.isEmpty()) {
            // SDS-1594 : Updated error message in label Service_Cloud_RMA_Error_Message_3_Split_1
            String msgText = System.Label.Service_Cloud_RMA_Error_Message_3_Split_1; // + ' ' + cas.Product_Family__c + ' ' + System.Label.Service_Cloud_RMA_Error_Message_3_Split_2;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msgText));
        } else if (!entitleList.isEmpty() && String.isBlank(sNo)) {
            //String msgText = 'The hardware serial number is blank for the Entitlement retrieved -'+ entitlementName +' Please update the entitlement record with serial number to proceed further';
            String msgText = System.Label.Service_Cloud_RMA_Error_Message_4_Split_1 + ' ' + entitlementName + ' ' + System.Label.Service_Cloud_RMA_Error_Message_4_Split_2;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msgText));

        } //else 
        /*
        if(String.isBlank(sNo)){
              //String msgText = 'The hardware serial number is blank for the Entitlement retrieved -'+ entitlementName +' Please update the entitlement record with serial number to proceed further';
              String msgText = 'No Serial Number found. Please check Entitlement selected on Case is active and has a Serial Number.';
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,msgText));
        }*/
        if (entProdFamily != null) {
            List < Part__c > parts = [SELECT Id FROM Part__c WHERE Product_Family__c =: entProdFamily];
            if (parts.isEmpty()) {
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Part record found, please select other Entitlement or check with administrator.'));
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Service_Cloud_RMA_Error_Message_5));
            }
        }

        // SDS-1594 : Updated error message in label Service_Cloud_RMA_Error_Message_3_Split_2 and added else condition
        else if (entProdFamily == null && !entitleList.isEmpty()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Service_Cloud_RMA_Error_Message_3_Split_2));
        }
        rmaObj = new RMA__c();
        rmaObj.Create_FA_Bug__c= true;
        lstRMA = new List < RMAWrapper > ();
        lstRMA.add(new RMAWrapper(new RMA__c(), 1, entProdFamily));
        rmaObj.Organization_Name__c = cas.Account.Name;
        ent = SerialNumberVsEntitlements.get(sNo);
        //Asset asst;
        //if(ent != null)
            //asst = getAssetDetails(ent.AssetId);
        rmaObj.ShipTo_Name1__c = cas.Account.Name;    
        if(cas.Contact != null){
            //cas.Contact.FirstName+' '+cas.Contact.LastName;           
            rmaObj.ShipTo_Name2__c = cas.Contact.FirstName+' '+cas.Contact.LastName; 
            rmaObj.ShipTo_Email__c = cas.Contact.Email;
            rmaObj.On_site_Contact1_Name__c = cas.Contact.FirstName + ' ' + cas.Contact.LastName;
            rmaObj.On_site_Contact1_Phone__c = cas.Contact.Phone;
            rmaObj.On_site_Contact1_Email__c = cas.Contact.Email;
            rmaObj.Ship_Tel_Phone__c = cas.Contact.Phone;
        }        
        if(asst != null){ //SDS-2455: Service: Link RMAs to an Asset
            rmaObj.Street__c    = asst.Street_1__c;
            rmaObj.Equipment_Location_Address2__c = asst.Street_2__c;
            rmaObj.Street_3__c = asst.Street_3__c;
            rmaObj.Street_4__c = asst.Street_4__c;
            rmaObj.City__c      = asst.City__c;
            rmaObj.State__c     = asst.State__c;
            rmaObj.Region__c    = asst.State__c;
            rmaObj.Country__c   = asst.Country__c;
            if(asst.Installation_Address_1__c !=null || asst.Installation_Address_2__c !=null
                || asst.Installation_City_Province__c !=null || asst.Installation_Country__c !=null
                || asst.Installation_State__c !=null || asst.Installation_Zip_Postal_Code__c !=null){
                rmaObj.Installation_Address_1__c  = asst.Installation_Address_1__c  ;
                rmaObj.Installation_Address_2__c  = asst.Installation_Address_2__c  ;
                rmaObj.Installation_City_Province__c  = asst.Installation_City_Province__c  ;
                rmaObj.Installation_Country__c  = asst.Installation_Country__c  ;
                rmaObj.Installation_State__c  = asst.Installation_State__c  ;
                rmaObj.Installation_Zip_Postal_Code__c  = asst.Installation_Zip_Postal_Code__c  ;
                isInstallDetail= true;
                rmaObj.Location_IF_different_from_ShipTo__c = true;
            }  
            rmaObj.Installation_Country__c   = asst.Country__c;  
            entCountry          = asst.Country__c;  
            rmaObj.Zip_Code__c  = asst.Postal_Code__c;
            entProdFamily       = asst.ProductFamily; 
            rmaObj.PAK_ID__c    = asst.PAKID__c;
            rmaObj.Asset__c     = asst.Id;
            rmaObj.Serial_Number__c = asst.SerialNumber;
            system.debug('asst.PAK_ID__c------>'+asst.PAKID__c);
            system.debug('rmaObj.PAK_ID__c------>'+rmaObj.PAK_ID__c);
        } else if(ent!=null){
            rmaObj.Street__c = ent.Street_1__c;
            rmaObj.Equipment_Location_Address2__c = ent.Street_2__c;
            rmaObj.Street_3__c = ent.Street_3__c;
            rmaObj.Street_4__c = ent.Street_4__c;
            rmaObj.City__c = ent.City__c;
            rmaObj.State__c = ent.State__c;
            rmaObj.Region__c = ent.State__c;
            rmaObj.Country__c = ent.Country__c;
            rmaObj.Host_Name__c = ent.Hostname__c;    // SDS-2765
            rmaObj.Installation_Country__c = ent.Country__c;    //SDS-1686
            entCountry = ent.Country__c;
            rmaObj.Zip_Code__c = ent.Zip_Postal_Code__c;
            entProdFamily = ent.Product_Family__c;
            rmaObj.PAK_ID__c = ent.PAK_ID__c; // RMA enhancements 1.0
            system.debug('ent.PAK_ID__c------>' + ent.PAK_ID__c);
            system.debug('rmaObj.PAK_ID__c------>' + rmaObj.PAK_ID__c);
        }

        rmaObj.Country__c = 'US';
        //rmaObj.Dead_on_Arrival__c = 'No';
        // SDS-1687 Start
        if (cas.Account.Billing_Region__c == 'JAPAN') {
            rmaObj.Additional_Email_Addresses__c = label.Service_Cloud_Japan_Region_Email + ',' + (Cas.Owner.email != null ? Cas.Owner.email : '') + ',';
        } else {
            rmaObj.Additional_Email_Addresses__c = label.Service_Cloud_Other_than_Japan_email + ',' + (Cas.Owner.email != null ? Cas.Owner.email : '') + ',';
        }
        // SDS-1687 End
    }

    public Asset getAssetDetails(Id assetId) {
        list<Asset> asstList = (List<Asset>) queryObj('Asset','WHERE Id ='+'\''+assetId+'\'');
        if(asstList != null && asstList.size() > 0)
            return asstList[0];
        return null;
    }
    
    //List of countries to be added
    public List < SelectOption > countries {
        get {
            List < SelectOption > options = new List < SelectOption > ();
            List < RMA_SapCountryCode__c > countList = (List < RMA_SapCountryCode__c > ) queryObj('RMA_SapCountryCode__c', ' ORDER BY Name');
            if (countList != null && !countList.isEmpty()) {
                for (RMA_SapCountryCode__c sapCC: countList) {
                    options.add(new SelectOption(sapCC.Country_Code__c, sapCC.Name));
                }
            }

            return options;
        }
        set;
    }
    public String selectedCountry {get;set;}
    public String zipCode {get;set;}

    //quantity SelectList - Current values 1-5
    public List < SelectOption > quantity {
        get {
            List < SelectOption > options = new List < SelectOption > ();
            for (Integer i = 1; i <= 5; i++) {
                options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
            }
            return options;
        }
        set;
    }
    /**
     * Added by Santoshi on 12/1/2017 to retrieve list of serial numbers based on the product family
     * match between Case and Entitlements.
     */
    public List < SelectOption > getSerialNumber() {

        List < SelectOption > srList = new List < SelectOption > ();
        SerialNumberVsEntitlements = new Map < String, Entitlement > ();
        entitleList = (List < Entitlement > ) queryObj('Entitlement', 'WHERE AccountId =' + '\'' + cas.AccountId + '\' and Id=' + '\'' + cas.EntitlementId + '\' and status=\'Active\'');
        for (Entitlement ent: entitleList) {
            if (ent.Hardware_Serial_Number__c != null) {
                SerialNumberVsEntitlements.put(ent.Hardware_Serial_Number__c, ent);
                srList.add(new SelectOption(ent.Hardware_Serial_Number__c, ent.Hardware_Serial_Number__c));
            }
        }
        return srList;
    }

    /*
     *   RMA Collection size is expanded by 1
     *
     */
    public void AddRMArows() {
        Integer size;
        if(lstRMA==null)
            lstRMA = new List < RMAWrapper > ();
        if(lstRMA!=null)
        size = lstRMA.size();
        lstRMA.add(new RMAWrapper(new RMA__c(), size + 1, entProdFamily));
    }

    /*
     *   RMA Collection size is reset to a single object
     *
     */
    public void resetRMArows() {
        if(lstRMA!=null)
        lstRMA.clear();
        if(lstRMA==null)
            lstRMA = new List < RMAWrapper > ();
        lstRMA.add(new RMAWrapper(new RMA__c(), 1, entProdFamily));
    }

    /*
     *   RMA Collection size is reduced by 1
     *
     */
    //Deleting Row upon commandButton click
    public void deleteRow() {
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        system.debug('deleteRow-->rowIndex:' + rowIndex);
        RMA__c rmaRemove = new RMA__c();
        if (lstRMA.size() > 1) {
            Integer count = 0;
            for (RMAWrapper wrapper: lstRMA) {
                if (wrapper.rowNum == rowIndex) {
                    rmaRemove = wrapper.rma;
                    break;
                }
                count++;
            }
            lstRMA.remove(count);
            if (!String.isBlank(rmaRemove.Id)) {
                delete rmaRemove;
            }
        }
        validateReturnReshipDates();
    }

    /*
     *   Adding the part number and quantity information for a specific RMA record within the RMA Collection
     *
     */
    //Changing quantity 
    public void addQuantity() {
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        List < RMAWrapper > lstRMATmp = new List < RMAWrapper > ();
        Integer size = lstRMA.size();
        for (RMAWrapper wrapper: lstRMA) {
            if (wrapper.rowNum == rowIndex) {
                Integer qty = wrapper.Quantity;
                wrapper.Quantity = 1;
                for (Integer i = 1; i < qty; i++) {
                    RMA__c wrapperClone = wrapper.rma.clone(false, true, false, false);
                    RMAWrapper wrp = new RMAWrapper(wrapperClone, size + 1, entProdFamily);
                    wrp.parentRowIndex = rowIndex;
                    wrp.parentQty = qty;
                    wrp.selectedPart = wrapper.selectedPart;
                    system.debug('checking size wrapper.selectedPartp--' + wrapper.DescriptionPart);
                    wrp.firstPart = false;
                    //wrp.DescriptionPart = wrapper.DescriptionPart;
                    wrp.partNumber = wrapper.partNumber;
                    wrp.FruCru = wrapper.FruCru;
                    wrp.partNumberOverride = wrapper.partNumberOverride;
                    system.debug('checking size wrapper.selectedPartp--' + wrp.DescriptionPart);
                    wrp.returnDate = wrapper.returnDate; // RMA enhancements 1.0
                    wrp.reshipDate = wrapper.reshipDate; // RMA enhancements 1.0
                    size++;
                    lstRMATmp.add(wrp);
                }
            }
        }
        system.debug('checking size lstRMATmp--' + lstRMATmp.size());
        if (!lstRMATmp.isEmpty()) {
            lstRMA.addAll(lstRMATmp);
        }
    }

    /*
     *   Adding the replacement part number information for a specific RMA record within the RMA Collection
     *
     */
    //Changing description 
    public void addDescription() {
        Integer rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));

        for (RMAWrapper wrapper: lstRMA) {
            if (wrapper.rowNum == rowIndex) {
                //Part__c part = wrapper.partNumberVsPart.get(wrapper.selectedPart);
                Part__c part = wrapper.partDesVsPart.get(wrapper.selectedPart);
                system.debug('selected Part-->' + part);
                system.debug('checking id---->' + wrapper.rma.Id);
                //wrapper.DescriptionPart = part.Description__c;
                if (part != null) {
                    wrapper.partNumber = part.Part_Number__c;
                    wrapper.FruCru = part.FRU_CRU__c;
                    Wrapper.partNumberOverride = '';
                    if (!String.isblank(part.Replacement_Type__c))
                        wrapper.rma.Replacement_Type__c = part.Replacement_Type__c;
                }
                // SDS-593: Start - Clear Part and FRu when None is selected.
                else {
                    wrapper.partNumber = '';
                    wrapper.FruCru = '';
                    wrapper.rma.Replacement_Type__c = '';
                    Wrapper.partNumberOverride = '';
                    Wrapper.reshipDate = null;
                    Wrapper.returnDate = null;
                }
                // SDS-593: End
            }
        }
    }

    /*
     * Prepare for the RMA external callout
     * Desc:   Before the execution of the external callout, 
     *           prepare a collection of the following and store the necessary information
     *         For the RMA record,
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
    public PageReference rmaCallout() {
        system.debug('**rmaCallout**');
        system.debug('**cas**' + cas.id);
        try {
            //Case contactCase = [SELECT Id, contactId FROM Case where Id=:Id];
            Id contactId = cas.ContactId;
            Contact contact = new Contact();
            List < Contact > conList = [SELECT id, Name, MailingAddress FROM Contact where Id =: contactId];
            if (!conList.isEmpty()) {
                contact = conList[0];
            }

            crmcomplaintproxy.CrmComplaintProxy_element complainProxyElement = new crmcomplaintproxy.CrmComplaintProxy_element();
            String EXTERNAL_REFERENCE_NUMBER = cas.Id;
            String SFDC_CASE_INCIDENT_NUMBER = cas.CaseNumber;
            String PAKID = rmaObj.PAK_ID__c; //RMA enhancements 1.0
            system.debug('rmaObj.PAK_ID__c---in Callout----->' + rmaObj.PAK_ID__c);
            String SPECIAL_SHIPPING_INSTRUCTIONS;
            string USER_EMAIL = UserInfo.getUserEmail();
            string USER_FULLNAME = UserInfo.getName();
            // SDS-593 Start
            if (rmaObj != null && rmaObj.Special_Instructions_to_RMA_Team__c != null)
                SPECIAL_SHIPPING_INSTRUCTIONS = 'Serial Number# ' + sNo + '\n' + rmaObj.Special_Instructions_to_RMA_Team__c;
            else
                SPECIAL_SHIPPING_INSTRUCTIONS = '';
            system.debug('**' + SPECIAL_SHIPPING_INSTRUCTIONS);
            // SDS-593 End
            //// Initialise Sold to addresses
            crmcomplaintproxy.SoldToAddress_element SoldToAddress = new crmcomplaintproxy.SoldToAddress_element();
            SoldToAddress.SOLD_NAME1 = (rmaObj.ShipTo_Name1__c == null) ? '' : rmaObj.ShipTo_Name1__c;
            SoldToAddress.SOLD_NAME2 = (rmaObj.ShipTo_Name2__c == null) ? '' : rmaObj.ShipTo_Name2__c;
            SoldToAddress.SOLD_COUNTRY = (rmaObj.Country__c == null) ? '' : rmaObj.Country__c;
            SoldToAddress.SOLD_STREET = (rmaObj.Street__c == null) ? '' : rmaObj.Street__c;
            SoldToAddress.SOLD_CITY1 = (rmaObj.City__c == null) ? '' : rmaObj.City__c;
            SoldToAddress.SOLD_POST_CODE1 = (rmaObj.Zip_Code__c == null) ? '' : rmaObj.Zip_Code__c;
            SoldToAddress.SOLD_REGION = (rmaObj.Region__c == null) ? '' : rmaObj.Region__c;
            SoldToAddress.SOLD_EMAIL = (rmaObj.ShipTo_Email__c == null) ? '' : String.valueOf(rmaObj.ShipTo_Email__c);
            SoldToAddress.SOLD_TEL_NUMBER = (rmaObj.Ship_Tel_Phone__c == null) ? '' : rmaObj.Ship_Tel_Phone__c;
            SoldToAddress.SOLD_HOUSE_NUM1 = rmaObj.Equipment_Location_Address2__c == null ? '' : rmaObj.Equipment_Location_Address2__c;
            SoldToAddress.SOLD_STR_SUPPL3 = (rmaObj.Street_3__c == null) ? '' : rmaObj.Street_3__c;
            SoldToAddress.SOLD_LOCATION = (rmaObj.Street_4__c == null) ? '' : rmaObj.Street_4__c;
            SoldToAddress.LANGUAGE = 'EN';

            // Initialise ship to addresses
            crmcomplaintproxy.ShipToAddress_element ShipToAddress = new crmcomplaintproxy.ShipToAddress_element();
            ShipToAddress.SHIP_NAME1 = rmaObj.ShipTo_Name1__c;
            ShipToAddress.SHIP_NAME2 = (rmaObj.ShipTo_Name2__c == null) ? '' : rmaObj.ShipTo_Name2__c;
            ShipToAddress.SHIP_COUNTRY = (rmaObj.Country__c == null) ? '' : rmaObj.Country__c;
            ShipToAddress.SHIP_STREET = (rmaObj.Street__c == null) ? '' : rmaObj.Street__c;
            ShipToAddress.SHIP_CITY1 = (rmaObj.City__c == null) ? '' : rmaObj.City__c;
            ShipToAddress.SHIP_POST_CODE1 = (rmaObj.Zip_Code__c == null) ? '' : rmaObj.Zip_Code__c;
            ShipToAddress.SHIP_REGION = (rmaObj.Region__c == null) ? '' : rmaObj.Region__c;
            ShipToAddress.SHIP_EMAIL = (rmaObj.ShipTo_Email__c == null) ? '' : String.valueOf(rmaObj.ShipTo_Email__c);
            ShipToAddress.SHIP_TEL_NUMBER = (rmaObj.Ship_Tel_Phone__c == null) ? '' : rmaObj.Ship_Tel_Phone__c;
            ShipToAddress.SHIP_HOUSE_NUM1 = (rmaObj.Equipment_Location_Address2__c == null) ? '' : rmaObj.Equipment_Location_Address2__c;
            ShipToAddress.SHIP_STR_SUPPL3 = (rmaObj.Street_3__c == null) ? '' : rmaObj.Street_3__c;
            ShipToAddress.SHIP_LOCATION = (rmaObj.Street_4__c == null) ? '' : rmaObj.Street_4__c;
            String[] ADD_EMAIL = new String[] {};

            //Initiate Onsite Contacts list
            crmcomplaintproxy.OnSiteContact_element[] OnSiteContactList = new List < crmcomplaintproxy.OnSiteContact_element > ();

            crmcomplaintproxy.OnSiteContact_element contactElement = new crmcomplaintproxy.OnSiteContact_element();
            contactElement.Name = rmaObj.On_site_Contact1_Name__c;
            contactElement.Phone = String.valueOf(rmaObj.On_site_Contact1_Phone__c);
            contactElement.Email = String.valueOf(rmaObj.On_site_Contact1_Email__c);

            OnSiteContactList.add(contactElement);
            // second onsite contact
            if (!String.isBlank(rmaObj.On_site_Contact2_Name__c)) {
                crmcomplaintproxy.OnSiteContact_element contactElement1 = new crmcomplaintproxy.OnSiteContact_element();
                contactElement1.Name = rmaObj.On_site_Contact2_Name__c;
                contactElement1.Phone = String.valueOf(rmaObj.On_site_Contact2_Phone__c);
                contactElement1.Email = String.valueOf(rmaObj.Onsite_Contact2_Email__c);
                OnSiteContactList.add(contactElement1);
            }

            //Initiate Additional Email details:
            complainProxyElement.ADD_EMAIL = new List < String > ();
            if (!string.isblank(rmaObj.Additional_Email_Addresses__c)) {
                if (rmaObj.Additional_Email_Addresses__c.contains(',')) {
                    ADD_EMAIL = rmaObj.Additional_Email_Addresses__c.split(',');
                } else if (rmaObj.Additional_Email_Addresses__c.contains('\n')) {
                    ADD_EMAIL = rmaObj.Additional_Email_Addresses__c.split('\n');
                } else if (rmaObj.Additional_Email_Addresses__c.contains(';')) {
                    ADD_EMAIL = rmaObj.Additional_Email_Addresses__c.split(';');
                } else {
                    ADD_EMAIL.add(rmaObj.Additional_Email_Addresses__c);
                }
            } else
                ADD_EMAIL.add('');

            //Initiate RMA Item Information
            crmcomplaintproxy.RmaItemInformation_element[] RmaItemInformation = new crmcomplaintproxy.RmaItemInformation_element[] {};
            for (RMA__c rmaItem: rma) {
                crmcomplaintproxy.RmaItemInformation_element rmaElement = new crmcomplaintproxy.RmaItemInformation_element();
                String ReplacementType = getReplacementString(rmaItem.Replacement_Type__c);
                System.debug('checking repoption--' + ReplacementType);
                DateTime poDateSolddt = DateTime.newInstance(SerialNumberVsEntitlements.get(sNo).StartDate, Time.newInstance(0, 0, 0, 0));
                rmaElement.SFDC_CASE_ITEM_NUMBER = rmaItem.Id;
                rmaElement.ORDERED_PROD = rmaItem.NVIDIA_Part_Number__c;
                rmaElement.QUANTITY = '1';
                rmaElement.REPOPTION = ReplacementType; // Retrieves replacement code from custom setting
                if (SerialNumberVsEntitlements.get(sNo) != null)
                    //rmaElement.PO_DATE_SOLD = String.valueOf(SerialNumberVsEntitlements.get(sNo).StartDate); // Passing PO_Date_Sold as Entitlement Start Date
                    rmaElement.PO_DATE_SOLD = poDateSolddt.format(DATE_FORMAT);

                String doa = '';
                if (rmaObj.DEAD_ON_ARRIVAL__c == 'Yes') {
                    doa = 'X';
                }

                rmaElement.DEAD_ON_ARRIVAL = doa;
                rmaElement.ICFA_NO = rmaObj.NVBug_ID__c == null ? '' : rmaObj.NVBug_ID__c;

                // RMA enhancements 1.0 - Populate 'RETURN_PICKUP_DATE' from 'Return Date'
                system.debug('rmaItem.Return_Date__c------->' + rmaItem.Return_Date__c);
                Date returnDate = rmaItem.Return_Date__c;
                string strReturnDate;
                if (returnDate != null)
                    strReturnDate = DateTime.newInstance(returnDate.year(), returnDate.month(), returnDate.day()).format(DATE_FORMAT);
                else
                    strReturnDate = '00000000'; //yyyymmdd 
                rmaElement.RETURN_PICKUP_DATE = strReturnDate;

                // RMA enhancements 1.0 - Populate 'RESHIP_DEL_DATE' from 'Reship Date'    
                system.debug('rmaItem.Reship_Date__c------->' + rmaItem.Reship_Date__c);
                Date reshipDate = rmaItem.Reship_Date__c;
                string strReshipDate;
                if (reshipDate != null)
                    strReshipDate = DateTime.newInstance(reshipDate.year(), reshipDate.month(), reshipDate.day()).format(DATE_FORMAT);
                else
                    strReshipDate = '00000000'; //yyyymmdd  
                rmaElement.RESHIP_DEL_DATE = strReshipDate;

                system.debug('rmaElement.RETURN_PICKUP_DATE---in Callout---->' + rmaElement.RETURN_PICKUP_DATE);
                system.debug('rmaElement.RESHIP_DEL_DATE---in Callout---->' + rmaElement.RESHIP_DEL_DATE);

                rmaElement.ADDITIONAL_INFORMATION = rmaObj.ADDITIONAL_INFORMATION__c == null ? '' : rmaObj.ADDITIONAL_INFORMATION__c;
                rmaElement.ITMSTATE = 'New';
                rmaElement.KBETR = '0.01';
                rmaElement.ORDERNUM = '';
                rmaElement.ORDERLINNUM = '';
                rmaElement.PROBLEM_DESCRIPTION = rmaObj.PROBLEM_DESCRIPTION__c == null ? '' : rmaObj.PROBLEM_DESCRIPTION__c;
                rmaElement.SPECIAL_INSTRUCTIONS = rmaObj.Special_Instructions_to_RMA_Team__c == null ? '' : rmaObj.Special_Instructions_to_RMA_Team__c;
                rmaElement.WAERS = 'USD';
                rmaElement.ZCRMT_SERIAL_NUMBER = String.valueOf(sNo);
                rmaElement.CHASSIS_NUMBER = rmaItem.Serial_Number__c;
                RmaItemInformation.add(rmaElement);
            }
            // SDS-1859 - start
            if (RmaItemInformation != null && RmaItemInformation.isEmpty()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, label.Service_Cloud_RMA_Error_Product_Required));
                return null;
            }
            // SDS-1859 - End
            nvidiaServicecloud.HTTPS_Port port = new nvidiaServicecloud.HTTPS_Port();
            port.inputHttpHeaders_x = new Map < String, String > ();
            String xbody = nvidiaServicecloud.createSoapRequest(
                EXTERNAL_REFERENCE_NUMBER,
                SFDC_CASE_INCIDENT_NUMBER,
                PAKID,
                USER_EMAIL,
                USER_FULLNAME,
                SPECIAL_SHIPPING_INSTRUCTIONS,
                SoldToAddress,
                ShipToAddress,
                ADD_EMAIL,
                OnSiteContactList,
                RmaItemInformation
            );
            system.debug('**xbody**' + xbody);
            String res = invokeRMACallout(xbody);
            system.debug('**res**' + res);
            if (!res.Contains('Callout Exception')) {
                XmlStreamReader xsr = new XmlStreamReader(res);
                DOM.Document doc = new DOM.Document();

                /*  res='<?xml version="1.0" encoding="UTF-8"?>
                    <SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">
                       <SOAP:Header />
                       <SOAP:Body>
                          <CrmComplaintProxyResponse xmlns:prx="urn:sap.com:proxy:CRD:/1SAI/TASE7DBB4492DF587A674C5:740">
                             <RMA>
                                <SFDC_CASE_NUMBER>5003D0000023GAIQAI</SFDC_CASE_NUMBER>
                                <SFDC_RMA_NUMBER>a4J3D0000008iISUAY</SFDC_RMA_NUMBER>
                                <CRM_COMPLAINT_NUMBER>0065017556</CRM_COMPLAINT_NUMBER>
                                <CRM_RMA_NUMBER />
                                <COMPLAINT_DATE>20171226</COMPLAINT_DATE>
                                <RMA_STATUS>OPEN</RMA_STATUS>
                                <RMA_CRDATE>20171226</RMA_CRDATE>
                                <RESHIP_PART_NUMBER />
                                <MATERIAL_SERIAL_NUMBER />
                                <FORWARDER_SHIPPER_NAME>FedEx Ground</FORWARDER_SHIPPER_NAME>
                                <SHIPMENT_TRACKING_NUMBER />
                                <SHIPMENT_TRACKING_NUMBER_URL>https://www.fedex.com/fedextrack/?tracknumbers=</SHIPMENT_TRACKING_NUMBER_URL>
                                <PLANNED_SHIP_OUT_DATE>00000000</PLANNED_SHIP_OUT_DATE>
                                <ACUTAL_SHIPPED_OUT_DATE>00000000</ACUTAL_SHIPPED_OUT_DATE>
                                <REJECTION_REASON />
                                <REP_SERIAL_NUMBER />
                                <MESSAGE_TYPE>S</MESSAGE_TYPE>
                                <MESSAGE_ID />
                                <MESSAGE_TEXT />
                             </RMA>
                          </CrmComplaintProxyResponse>
                       </SOAP:Body>
                    </SOAP:Envelope>'; */

                doc.load(res);
                DOM.XmlNode rootNode = doc.getRootElement();
                RMAList = new List < RMA__c > ();

                parseXML(rootNode);
                System.debug('checking RMAList size--' + RMAList.size() + '---' + RMAList);

                if (!RMAList.isEmpty()) {
                    upsert RMAList;
                    /*Case cse = new Case();
                    cse.RMA_CRM_Complaint_Number__c = RMAList.get(0).CRM_Complaint_Number__c;
                    update cse;*/
                }
                if (MESSAGE_TYPE == 'E' && !String.isBlank(MESSAGE_TEXT)) {
                    System.debug('**ERROR**' + MESSAGE_TEXT);
                    // SDS-1485 Start
                    delete rma;
                    for (RMAWrapper rmawrapperItem: lstRMA) {
                        if (rmawrapperItem != null && rmawrapperItem.rma != null && rmawrapperItem.rma.id != null)
                            rmawrapperItem.rma.id = null;
                    }
                    // SDS-1485 End
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, MESSAGE_TEXT));
                    return null;
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, res));
                // SDS-1485 Start
                NV_Error_Log__c nvError = new NV_Error_Log__c();
                nvError.Error_Description__c = JSON.Serialize(rma).left(255);
                nvError.Error_Message__c = res.left(255);
                nvError.Functionality__c = 'Create RMA On Case';
                insert nvError;
                delete rma;
                for (RMAWrapper rmawrapperItem: lstRMA) {
                    if (rmawrapperItem != null && rmawrapperItem.rma != null && rmawrapperItem.rma.id != null)
                        rmawrapperItem.rma.id = null;
                }
                // SDS-1485 End          
                return null;
            }
            // SDS-2765 : Start
            system.debug('***' + rmaObj.host_name__c+ '***' + ent.hostname__c);
            if(rmaObj.host_name__c!=null && rmaObj.host_name__c != ent.hostname__c){
                ent.hostname__c = rmaObj.host_name__c; 
                update ent;
            }    
            // SDS-2765 : End
            return new PageReference('/' + id);
        } catch (Exception e) {
            ApexPages.addmessages(e);
            String errorMessage = e.getMessage();
            System.debug(LOGGINGLEVEL.INFO + 'Logged error in Integration Object' + e.getStackTraceString());
            System.debug('get stak trace..' + e.getStackTraceString());
            PRFT_Error err = new PRFT_Error('RMA Update Error', e.getStackTraceString(), String.valueof(e), Id, true);
        }

        return null;
    }
    /*
     *   Parse the SOAP response xml information for the following RMA information
     *   - CRM Complaint Number
     *   - RMA Status
     *   - CRM RMA Number
     *   - Shipment Tracking Number
     *   - Actual Shipped Out Date
     *   - Replacement Serial Number
     *   - Rejection Reason
     *   - Planned Shipped Out Date
     *   - Shipment Tracking Number URL
     *   - External System message type and message description
     *
     */
    private void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug('---checking node name---' + node.getName());
            if (node.getName() == 'RMA') {
                DOM.XMLNode[] tempNode = node.getChildElements();
                RMA__c rmRes = new RMA__c();
                for (Dom.XMLNode RMAchild: tempNode) {
                    system.debug('---checking RMAchild name---' + RMAchild.getName());
                    if (RMAchild.getName() == 'SFDC_RMA_NUMBER') {
                        String RMAID = RMAchild.getText().trim();
                        System.debug('get test-RMAchild--' + RMAchild.getText());
                        if (!String.isBlank(RMAID)) {
                            rmRes.Id = RMAID;
                        }
                        // RMA__c rmRes = new RMA__c(id='')
                    }
                    if (RMAchild.getName() == 'CRM_COMPLAINT_NUMBER') {
                        rmRes.Crm_Complaint_Number__c = RMAchild.getText().trim();
                        System.debug('get CRM_COMPLAINT_NUMBER---' + RMAchild.getText());

                    }
                    if (RMAchild.getName() == 'RMA_STATUS') {
                        rmRes.RMA_Status__c = RMAchild.getText().trim();
                        System.debug('get RMA_STATUS---' + RMAchild.getText());
                    }

                    if (RMAchild.getName() == 'CRM_RMA_NUMBER') {
                        rmRes.SAP_RMA_Number__c = RMAchild.getText().trim();
                        System.debug('get CRM_RMA_NUMBER---' + RMAchild.getText());

                    }
                    if (RMAchild.getName() == 'SHIPMENT_TRACKING_NUMBER') {
                        rmRes.Tracking_Number__c = RMAchild.getText().trim();
                        System.debug('get SHIPMENT_TRACKING_NUMBER---' + RMAchild.getText());
                    }
                    if (RMAchild.getName() == 'ACUTAL_SHIPPED_OUT_DATE') {
                        rmRes.Actual_Shippedout_Date__c = convertToDate(RMAchild.getText().trim());
                        System.debug('get ACUTAL_SHIPPED_OUT_DATE---' + RMAchild.getText());
                    }
                    if (RMAchild.getName() == 'REP_SERIAL_NUMBER') {
                        rmRes.Replacement_Serial_Number__c = RMAchild.getText().trim();
                        System.debug('get REP_SERIAL_NUMBER---' + RMAchild.getText());
                    }
                    if (RMAchild.getName() == 'REJECTION_REASON') {
                        rmRes.Reason_ForRejection__c = RMAchild.getText().trim();
                        System.debug('get REJECTION_REASON---' + RMAchild.getText());
                    }
                    if (RMAchild.getName() == 'PLANNED_SHIP_OUT_DATE') {
                        rmRes.Planned_ShipoutDate__c = convertToDate(RMAchild.getText().trim());
                        System.debug('get PLANNED_SHIP_OUT_DATE---' + RMAchild.getText());
                    }
                    if (RMAchild.getName() == 'SHIPMENT_TRACKING_NUMBER_URL') {
                        rmRes.Shipment_TrackingNumber_Url__c = RMAchild.getText().trim();
                        System.debug('get SHIPMENT_TRACKING_NUMBER_URL---' + RMAchild.getText());
                    }
                    if (RMAchild.getName() == 'ACTUAL_RETURN_SERIAL_NUMBER') {
                        rmRes.Returned_Serial_Number__c = RMAchild.getText().trim();
                        System.debug('get Returned_Serial_Number__c ---' + RMAchild.getText());
                    }
                    if (RMAchild.getName() == 'RETURN_DELIVERY') {
                        rmRes.Delivery_Number__c = RMAchild.getText().trim();
                        System.debug('get Delivery_Number__c---' + RMAchild.getText());
                    }
                    if (RMAchild.getName() == 'ACTUAL_RETURN_PRODUCT') {
                        rmRes.Actual_Return_Part_Number__c = RMAchild.getText().trim();
                        System.debug('get Actual_Return_Part_Number__c ---' + RMAchild.getText());
                    }
                    if (RMAchild.getName() == 'MESSAGE_TYPE') {
                        System.debug('get MESSAGE_TYPE---' + RMAchild.getText());
                        MESSAGE_TYPE = RMAchild.getText().trim();
                        if (!String.isBlank(MESSAGE_TYPE)) {
                            rmRes.SAP_Message_Type__c = MESSAGE_TEXT;
                        }

                    }
                    if (RMAchild.getName() == 'MESSAGE_TEXT') {
                        System.debug('get MESSAGE_TEXT---' + RMAchild.getText());
                        MESSAGE_TEXT = RMAchild.getText().trim();
                        if (!String.isBlank(MESSAGE_TEXT)) {
                            rmRes.SAP_CalloutMessage__c = MESSAGE_TEXT;
                        }

                    }
                    node.removeChild(RMAchild);
                }

                if (!String.isBlank(rmRes.Id)) {
                    RMAList.add(rmRes);
                }


            }
            for (Dom.XMLNode child: node.getChildElements()) {
                parseXML(child);
            }
        }
    }


    public string getReplacementString(String repl) {
        List < RMA_ReplacementMapping__c > replaceList = (List < RMA_ReplacementMapping__c > ) queryObj('RMA_ReplacementMapping__c', 'WHERE Name =' + '\'' + repl + '\'');
        if (replaceList != null && !replaceList.isEmpty()) {
            return replaceList[0].Replacement_Code__c;
        }
        return '';
    }

    private Date convertToDate(String s) {
        if (String.isBlank(s) || s.length() != 8) {
            return null;
        }
        try {
            Date d = Date.valueOf(s.left(4) + '-' + s.mid(4, 2) + '-' + s.right(2));
            return d;
        } catch (Exception e) {}
        return null;
    }
    /*
     *   Save (upsert) the RMA Collection of records to the RMA__c custom object
     *
     */
    //Save RMA
    public void SaveRMA() {
        system.debug('***' + rmaObj.Country__c + '***' + rmaObj.State__c);
        system.debug('*********' + rmaObj.Create_FA_Bug__c);
        inputError = false;
        if (rmaObj.Country__c == 'CN' && rmaObj.State__c == null) {
            inputError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, label.Service_Cloud_China_Region));
            return;
        }
        if (rmaObj.Country__c == 'CA' && rmaObj.Zip_Code__c != null && rmaObj.Zip_Code__c.trim().indexOf(' ') != 3) {
            inputError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, label.Service_Cloud_Canada_Pincode));
            return;
        }
        // SDS-2203-- start
        if (rmaObj.NVBug_ID__c != null && !rmaObj.NVBug_ID__c.isNumeric()) {
            inputError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, label.NVBug_ID_should_be_Numeric));
            return;
        }
        else {
            List<NV_Ticket__c> lstnvticket = [select id,case__C from NV_Ticket__c where Name=:rmaObj.NVBug_ID__c];
            boolean isCaseLinkedToNVbug = false;
            for(NV_Ticket__c tmpnvticket : lstnvticket){
                if(tmpnvticket.case__C == cas.id){
                    isCaseLinkedToNVbug=true;
                }
            }        
            if(isCaseLinkedToNVbug==false){
                NV_Ticket__c nvticket = new NV_Ticket__c();
                nvticket.Bug_no_in_NVBug_Not_in_SFDC__c = rmaObj.NVBug_ID__c;
                nvticket.Type__c = 'NVBug';
                List<RecordType> lstRecType = [SELECT id FROM RecordType WHERE SobjectType = 'nv_ticket__c' AND DeveloperName = 'NVBug' limit 1];
                nvticket.RecordTypeId = lstRecType.get(0).id;
                nvticket.case__C = cas.id;
                string strNVTicket= JSON.serialize(nvticket);
                NVBugOperations.LinkBug(strNVTicket);
            }
        }
        // SDS-2203-- End
        rmaObj.Region__c = rmaObj.State__c;
        
        if(asst!=null && isUpdateShippingInAsset){
            asst.Street_1__c    = rmaObj.Street__c;
            asst.Street_2__c = rmaObj.Equipment_Location_Address2__c;
            asst.Street_3__c    = rmaObj.Street_3__c;
            asst.Street_4__c    = rmaObj.Street_4__c;
            asst.City__c     = rmaObj.City__c ;
            asst.State__c     = rmaObj.State__c;
            asst.State__c    = rmaObj.Region__c;
            asst.Country__c   = rmaObj.Country__c;
            asst.Postal_Code__c  = rmaObj.Zip_Code__c;
        }    
        if(asst!=null && isUpdateInstallInAsset){
            asst.Installation_Address_1__c =  rmaObj.Installation_Address_1__c  ;
            asst.Installation_Address_2__c  = rmaObj.Installation_Address_2__c  ;
            asst.Installation_City_Province__c  = rmaObj.Installation_City_Province__c  ;
            asst.Installation_Country__c  = rmaObj.Installation_Country__c  ;
            asst.Installation_State__c  = rmaObj.Installation_State__c  ;
            asst.Installation_Zip_Postal_Code__c  = rmaObj.Installation_Zip_Postal_Code__c  ;
        }
        if(asst!=null && (isUpdateShippingInAsset || isUpdateInstallInAsset))
            update asst;
              
        if(isUpdateShippingInAsset){
            ent.Street_1__c = rmaObj.Street__c;
            ent.Street_2__c = rmaObj.Equipment_Location_Address2__c;
            ent.Street_3__c = rmaObj.Street_3__c;
            ent.Street_4__c = rmaObj.Street_4__c;
            ent.City__c = rmaObj.City__c;
            ent.State__c = rmaObj.State__c;
            ent.State__c = rmaObj.Region__c;
            ent.Country__c = rmaObj.Country__c;
            ent.Zip_Postal_Code__c = rmaObj.Zip_Code__c;
        }
        if(ent!=null && isUpdateShippingInAsset)
            update ent;

        rma = new List < RMA__c > ();
        for (RMAWrapper rmawrapperItem: lstRMA) {
            {
                if (rmawrapperItem.selectedPart == '--None--') {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Part Description can not be None.'));
                    return;
                }

                //Creating RMA's based on quantity selected
                Integer qty = Integer.ValueOf(rmawrapperItem.rma.Quantity__c);
                //  for(Integer i =0; i< qty; i++){
                rmawrapperItem.rma = initialistExistingRMAFields(rmawrapperItem.rma);
                rmawrapperItem.rma.Create_FA_Bug__c = rmaObj.Create_FA_Bug__c;
                rmawrapperItem.rma.host_name__c = rmaObj.host_name__c;
                rmawrapperItem.rma.Case__c = id;
                if (SerialNumberVsEntitlements != null && SerialNumberVsEntitlements.get(sNo) != null)
                    if (SerialNumberVsEntitlements.get(sNo) != null) {
                        rmawrapperItem.rma.Entitlement__c = SerialNumberVsEntitlements.get(sNo).Id;
                        System.debug('checking selected part---' + SerialNumberVsEntitlements.get(sNo));
                    }
                System.debug('checking selected part---' + rmawrapperItem.selectedPart);
                System.debug('checking id after initialise---->' + rmawrapperItem.rma.Id);
                rmawrapperItem.rma.NVIDIA_Part_Number__c    = rmawrapperItem.partNumber;
                rmawrapperItem.rma.FRU_CRU__c               = rmawrapperItem.FruCru;
                rmawrapperItem.rma.Serial_Number__c         = sNo;
                rmawrapperItem.rma.Quantity__c              = 1;
                rmawrapperItem.rma.Region__c                = rmaObj.State__c;
                rmawrapperItem.rma.State__c                 = rmaObj.State__c;
                rmawrapperItem.rma.Asset__c                 = rmaObj.Asset__c;
                rmawrapperItem.rma.Additional_Email_Addresses__c = rmaObj.Additional_Email_Addresses__c;
                        system.debug('**isInstallDetail**' + isInstallDetail);
                // SDS-1686 start        
                if(isInstallDetail==false){
                    rmawrapperItem.rma.Installation_Address_1__c = rmaObj.Street__c;
                    rmawrapperItem.rma.Installation_Address_2__c = rmaObj.Equipment_Location_Address2__c ;
                    rmawrapperItem.rma.Installation_Address_3__c = rmaObj.Street_3__c + '\n'+ rmaObj.Street_4__c;
                    rmawrapperItem.rma.Installation_state__c = rmaObj.State__c;
                    rmawrapperItem.rma.Installation_City_Province__c = rmaObj.City__c;
                    rmawrapperItem.rma.Installation_Country__c = rmaObj.Country__c;
                    rmawrapperItem.rma.Installation_Zip_Postal_Code__c = rmaObj.Zip_Code__c;
                }else{
                    rmawrapperItem.rma.Installation_Address_1__c = rmaObj.Installation_Address_1__c ;
                    rmawrapperItem.rma.Installation_Address_2__c = rmaObj.Installation_Address_2__c ;                    
                    rmawrapperItem.rma.Installation_state__c = rmaObj.Installation_state__c ;
                    rmawrapperItem.rma.Installation_City_Province__c = rmaObj.Installation_City_Province__c ;
                    rmawrapperItem.rma.Installation_Country__c = rmaObj.Installation_Country__c ;
                    rmawrapperItem.rma.Installation_Zip_Postal_Code__c = rmaObj.Installation_Zip_Postal_Code__c ;
                }
                // SDS-1686 End
                system.debug('rmaObj AssetID: '+ rmaObj.Asset__c);
                
                // RMA Enhancements 1.0
                system.debug('rmawrapperItem.returnDate------>' + rmawrapperItem.returnDate);
                system.debug('rmawrapperItem.reshipDate------>' + rmawrapperItem.reshipDate);
                rmawrapperItem.rma.Return_Date__c = rmawrapperItem.returnDate;
                rmawrapperItem.rma.Reship_Date__c = rmawrapperItem.reshipDate;
                // SDS-593 Start
                if (rmaObj != null && rmaObj.Special_Instructions_to_RMA_Team__c != null)
                    rmawrapperItem.rma.Special_Instructions_to_RMA_Team__c = 'Serial Number# ' + sNo + '\n' + rmaObj.Special_Instructions_to_RMA_Team__c;
                else
                    rmawrapperItem.rma.Special_Instructions_to_RMA_Team__c = '';
                // SDS-593 End
                system.debug('rmawrapperItem.rma.Return_Date__c------>' + rmawrapperItem.rma.Return_Date__c);
                system.debug('rmawrapperItem.rma.Reship_Date__c------>' + rmawrapperItem.rma.Reship_Date__c);

                //if(rmawrapperItem.partDesVsPart != null && !rmawrapperItem.partNumberVsPart.isEmpty() && rmawrapperItem.partNumberVsPart.get(rmawrapperItem.selectedPart) != null){
                //if(rmawrapperItem.partNumberVsPart != null && !rmawrapperItem.partNumberVsPart.isEmpty() && rmawrapperItem.partNumberVsPart.get(rmawrapperItem.selectedPart) != null){
                //  String selectedPartName =  rmawrapperItem.partNumberVsPart.get(rmawrapperItem.selectedPart).Part_Number__c;
                //  if(!String.isBlank(selectedPartName))
                //rmawrapperItem.rma.Line_Number_on_Sales_Order__c = rmawrapperItem.selectedPartName; //Order Line Num
                //}

                if (!String.isBlank(rmawrapperItem.partNumberOverride)) {
                    rmawrapperItem.rma.NVIDIA_Part_Number__c = rmawrapperItem.partNumberOverride;
                }

                rma.add(rmawrapperItem.rma);
                //}
            }
        }

        Set < String > partNumberSet = new Set < String > ();
        for (RMA__c rmaItem: rma) {
            partNumberSet.add(rmaItem.NVIDIA_Part_Number__c);
            system.debug('**partNumberSet**' + partNumberSet);
        }
        Map < String, Part__c > partMapping = new Map < String, Part__c > ();
        for (Part__c p: [SELECT Part_Number__c, Part_Name_Number_formula__c, Description__c, Service_Instructions__c FROM Part__c WHERE Part_Number__c IN: partNumberSet]) {  //  SDS-1686 Added Service_Instructions__c   SDS-3141 Added Part_Name_Number_formula__c
            partMapping.put(p.Part_Number__c, p);
            system.debug('**partMapping**' + partMapping);
        }
        for (RMA__c rmaItem: rma) {
            if (partMapping.containsKey(rmaItem.NVIDIA_Part_Number__c)) {
                system.debug('**partMapping.get(rmaItem.NVIDIA_Part_Number__c).Description__c**' + partMapping.get(rmaItem.NVIDIA_Part_Number__c).Description__c);
                rmaItem.NVIDIA_Part_Description__c = partMapping.get(rmaItem.NVIDIA_Part_Number__c).Description__c;
                system.debug('**partMapping.get(rmaItem.NVIDIA_Part_Number__c).Service_Instructions__c**' + partMapping.get(rmaItem.NVIDIA_Part_Number__c).Service_Instructions__c);
                rmaItem.Service_Instructions__c = partMapping.get(rmaItem.NVIDIA_Part_Number__c).Service_Instructions__c;    //  SDS-1686
                system.debug('**partMapping.get(rmaItem.NVIDIA_Part_Number__c).Id**' + partMapping.get(rmaItem.NVIDIA_Part_Number__c).Id);
                rmaItem.Part__c = partMapping.get(rmaItem.NVIDIA_Part_Number__c).Id;

            }
        }
        system.debug('rma- before--->' + rma);
        upsert rma;

        system.debug('rma---->' + rma);
    }


    /*
     *   Cancel the page request and return to the Case detail page
     *
     */
    // Return to case Detail Page
    public PageReference Cancel() {
        return new PageReference('/' + id);
    }
    /*
     *   A RMA Wrapper object (Custom Apex Inner Class) to store
     *   - the individual RMA record
     *   - and the extended RMA information for supporting the RMA related User Interface elements
     *
     */
    // RMA Wrapper Class    
    public class RMAWrapper {
        public String entProdFamily { get;set;}
        public RMA__c rma { get;set;}
        public Integer rowNum { get;set;}
        public Integer quantity { get;set;}
        public String partNameNumber { get;set;}
        public String partNumber { get;set;}
        public String partNumberOverride { get;set;}
        public String DescriptionPart { get;set;}
        public String FruCru { get;set;}
        public Map < String, Part__c > partNumberVsPart { get;set;}
        public Map < String, Part__c > partDesVsPart { get;set;}
        public boolean firstPart = true;
        public Integer parentRowIndex = 0;
        public Integer parentQty = 1;
        public Date returnDate { get;set;}
        public Date reshipDate { get;set;}
        public List < SelectOption > lstPart {
            get {
                List < SelectOption > options = new List < SelectOption > ();
                List < Part__c > parts = new List < Part__c > ();

                system.debug('entProdFamily-->' + entProdFamily);
                //partNumberVsPart = new Map<String,Part__c>();
                partDesVsPart = new Map < String, Part__c > ();

                // SDS-593 : Start
                partDesVsPart.put('--None--', null);
                options.add(new SelectOption('--None--', '--None--'));
                // SDS-593 : End

                if (entProdFamily != null)
                    parts = [SELECT Id, Part_Name_Number_formula__c, Part_Number__c, Description__c, Replacement_Type__c, Component_Part_Name__c, FRU_CRU__c FROM Part__c WHERE Product_Family__c =: entProdFamily and Orderable__c = true order by Part_Name_Number_formula__c asc]; // SDS-1632: Added 'Orderable__c=true' SDS-3141 Added Part_Name_Number_formula__c
                system.debug('parts-->' + parts);
                for (Part__c part: parts) {
                    //if(part.Part_Number__c !=null)
                    if (part.Description__c != null) {
                        /*if(firstPart){
                           //DescriptionPart = part.Description__c;
                           partNumber = part.Part_Number__c;
                           FruCru = part.FRU_CRU__c;
                           if(!String.isblank(part.Replacement_Type__c)){
                               rma.Replacement_Type__c = part.Replacement_Type__c;
                           }
                           firstPart = false;
                        }*/
                        //options.add(new SelectOption(part.Part_Number__c, part.Part_Number__c));
                        //partNumberVsPart.put(part.Part_Number__c,part);
                        options.add(new SelectOption(part.Part_Name_Number_formula__c, part.Part_Name_Number_formula__c)); // SDS-3141
                        partDesVsPart.put(part.Part_Name_Number_formula__c, part);
                    }
                }
                return options;
            }
            set;
        }
        public String selectedPart { get;set;}
        public boolean manualEntry { get;set;}
        public RMAWrapper(RMA__c rmaa, Integer rowNum, String entProdFamily) {
            this.rma = rmaa;
            this.rowNum = rowNum;
            this.entProdFamily = entProdFamily;
            manualEntry = false;
            rma.Quantity__c = 1;
            partNumberOverride = '';
        }
    }

    /**
     * Initialises field and saves the value entered from the page.
     */
    public RMA__c initialistExistingRMAFields(RMA__c rmaInstance) {

        Sobject RMASobj = rmaInstance;
        system.debug('checking id after initialise 111 befire---->' + rmaInstance.Id);
        system.debug('***isinstalldetail**' + isinstalldetail);

        // Left FieldSet
        for (Schema.FieldSetMember f: readFieldSet('RMA_FieldSetsLeft', 'RMA__c')) {
            // query += f.getFieldPath() + ', ';
            RMASobj.put(f.getFieldPath(), rmaObj.get(f.getFieldPath()));
        }

        // Right FieldSet
        for (Schema.FieldSetMember f: readFieldSet('RMA_FieldSetsRight', 'RMA__c')) {
            // query += f.getFieldPath() + ', ';
            RMASobj.put(f.getFieldPath(), rmaObj.get(f.getFieldPath()));
        }
        //  SDS-1686 start
        if(isInstallDetail==true){
            for (Schema.FieldSetMember f: readFieldSet('RMA_Installation_Contact', 'RMA__c')) {
                // query += f.getFieldPath() + ', ';
                RMASobj.put(f.getFieldPath(), rmaObj.get(f.getFieldPath()));
            }
            for (Schema.FieldSetMember f: readFieldSet('RMA_Installation_Address_Details', 'RMA__c')) {
                // query += f.getFieldPath() + ', ';
                RMASobj.put(f.getFieldPath(), rmaObj.get(f.getFieldPath()));
            }
        }
        //  SDS-1686 End
        rmaInstance = (RMA__c) RMASobj;
        //rmaInstance.Dead_on_Arrival__c = 'No';
        system.debug('checking id after initialise 111 after---->' + rmaInstance.Id);
        return rmaInstance;
    }

    /**
     * Initialises field and saves the value entered from the page.
     */
    public RMA__c initialistRMAFields() {
        RMA__c rmaInstance;
        if (rmaObj == null) {
            rmaInstance = new RMA__c();
            return rmaInstance;
        }
        Sobject RMASobj = new RMA__c();

        // Left FieldSet
        for (Schema.FieldSetMember f: readFieldSet('RMA_FieldSetsLeft', 'RMA__c')) {
            // query += f.getFieldPath() + ', ';
            RMASobj.put(f.getFieldPath(), rmaObj.get(f.getFieldPath()));
        }

        // Right FieldSet
        for (Schema.FieldSetMember f: readFieldSet('RMA_FieldSetsRight', 'RMA__c')) {
            // query += f.getFieldPath() + ', ';
            RMASobj.put(f.getFieldPath(), rmaObj.get(f.getFieldPath()));
        }
        //  SDS-1686 start
        if(isInstallDetail==true){
            for (Schema.FieldSetMember f: readFieldSet('RMA_Installation_Contact', 'RMA__c')) {
                // query += f.getFieldPath() + ', ';
                RMASobj.put(f.getFieldPath(), rmaObj.get(f.getFieldPath()));
            }
            for (Schema.FieldSetMember f: readFieldSet('RMA_Installation_Address_Details', 'RMA__c')) {
                // query += f.getFieldPath() + ', ';
                RMASobj.put(f.getFieldPath(), rmaObj.get(f.getFieldPath()));
            }
        }
        //  SDS-1686 End        
        rmaInstance = (RMA__c) RMASobj;
        //rmaInstance.Dead_on_Arrival__c = 'No';
        return rmaInstance;
    }

    // RMA Enhancements 1.0
    public void validateReturnReshipDates() {
        integer i = 0;
        for (RMAWrapper rmawrapperItem: lstRMA) {
            i = i + 1;
            // Check if the current time is before/after Noon in local timezone of the context User.
            String ReturnReshipDate_ErrMsg2;

            // Validate 'Reship Date'
            // SDS-1805  : Hours modfied to 15          
            Date rsdate = rmawrapperItem.reshipDate;
            if (system.now().hour() >= 15 && rsdate != null && System.today().daysBetween(rsdate) <= 1) {
                //String ReshipDate_ErrMsg = 'Please enter RESHIP DATE ' + ReturnReshipDate_ErrMsg2 + ' Next Business Day in the below row NO ' + i;
                String ReshipDate_ErrMsg = System.Label.Service_Cloud_RMA_Error_Message_6_Split_1 + ' ' + i; // + ' ' + ReturnReshipDate_ErrMsg2 + ' ' + System.Label.Service_Cloud_RMA_Error_Message_5_Split_2 + ' ' + i;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ReshipDate_ErrMsg));
                itemErrors = true;
            }

            // Validate 'Return Date'
            // SDS-1805  : Hours modfied to 15 
            Date rtdate = rmawrapperItem.returnDate;
            if (system.now().hour() >= 15 && rtdate != null && System.today().daysBetween(rtdate) <= 1) {
                //String ReturnDate_ErrMsg = 'Please enter RETURN DATE ' + ReturnReshipDate_ErrMsg2 + ' Next Business Day in the below row NO ' + i;
                String ReturnDate_ErrMsg = System.Label.Service_Cloud_RMA_Error_Message_5_Split_1 + ' ' + i; // + ' ' + ReturnReshipDate_ErrMsg2 + ' ' + System.Label.Service_Cloud_RMA_Error_Message_5_Split_2 + ' ' + i;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ReturnDate_ErrMsg));
                itemErrors = true;
            }

            if (system.now().hour() <= 15 && (rsdate > Date.Today()) && (rtdate > Date.Today())) {
                itemErrors = false;
            }
        }
    }
//  SDS-1686 start    
    public void differentInstallAddress(){
       system.debug('*********' + isInstallDetail);
       if(isInstallDetail == false){
           isInstallDetail = true;
           if (rmaObj!=null)
               rmaObj.Installation_Country__c =rmaObj.Country__c;
       }    
       else
           isInstallDetail = false;
           if (rmaObj!=null)
               rmaObj.Location_IF_different_from_ShipTo__c = isInstallDetail;  
    }    
//  SDS-1686 End        
      

}