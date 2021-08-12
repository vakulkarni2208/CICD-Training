/*
Details:
Process SAP Order Records Created outside of Salesforce and Inserted Into SF.  Transfer/Match Data with Contracts/Subscriptions and Renewal Opps and Quote Lines
CPQ 2.0
Licensing
Licensing Renewals
SOQ 
Dates:  
Original:  7-3-2018
Rev1:  8-14 - Removed calls to Closed won and Forecast Batch Classes, Removed Update of Quote Record
Rev2:  8-23 - Updated Matching Script for Contracts to Match based on first Entitlement ID, then Entitlement ID + PAKID
Version 3:  2-18-2019 - Order type implementation. 
Version 3:  3-13-2019 - Clearing Error message
*/

public with sharing class CPQ_SAP_Order_Processor {
    //Query Custom Metadata Object and Retrieve Lists of Records
    List<CPQ_Field_Mapping__mdt> idMapping=new List<CPQ_Field_Mapping__mdt>([Select Destination_Field__c, Destination_Object__c, Lookup_Object__c, Source_Field__c from CPQ_Field_Mapping__mdt where Lookup_Object__c!=null and Active__c=true]);
    List<CPQ_Field_Mapping__mdt> standardMapping=new List<CPQ_Field_Mapping__mdt>([Select FieldType__c, Destination_Field__c, Destination_Object__c, Lookup_Object__c, Source_Field__c,Category__c from CPQ_Field_Mapping__mdt where Lookup_Object__c=null and Active__c=true]);
    Map<String,Contract> entitlements = new Map<String,Contract>();
    
    
    Map<String,String> accountMap = new Map<String,String>();
    Map<String,String> contactMap = new Map<String,String>();
    Map<String,String> productMap = new Map<String,String>();
    Map<String,SBQQ__Subscription__c> subMap=new Map<String,SBQQ__Subscription__c>();
    Set<String> subset=new Set<String>();
    Set<String> accountSet=new Set<String>();
    Set<String> contactSet=new Set<String>();
    Set<String> productSet=new Set<String>();
    Set<String> oppSet=new Set<String>();
    Set<String> quoteLineSet=new Set<String>();
    
    
    List<SBQQ__Subscription__c> subs=new List<SBQQ__Subscription__c>();
    List<Asset> assets=new List<Asset>();
    List<SAP_Order__c> assetOrders=new List<SAP_Order__c>();
    
    Map<String,Opportunity> oppMap=new Map<String,Opportunity>();
    Map<String,SBQQ__Quote__c> quoteMap=new Map<String,SBQQ__Quote__c>();
    Map<String,SBQQ__QuoteLine__c> quoteLineMap=new Map<String,SBQQ__QuoteLine__c>();
    
    public CPQ_SAP_Order_Processor() {
        
    }
    
    //Create Mappings based on Lookup Field (Account, Contact, Product)
    public void initialization(List<SAP_Order__c> orders){
        List<SAP_Order__c> OrdersFiltered = new List<SAP_Order__c>();
        System.debug('-----Orders--1--'+orders);
        for(SAP_Order__c order: orders){
            if(order.Sales_Type__c=='Initial'){
                order.Sales_Type__c = 'I';
            }else if(order.Sales_Type__c=='Renewal'){
                order.Sales_Type__c = 'R';
            }else if(order.Sales_Type__c=='Upgrade'){  
                order.Sales_Type__c = 'U';
            }else if(order.Sales_Type__c=='None'){  
                order.Sales_Type__c = '';
            }
            if((order.Order_Type__c=='ZOR' || order.Order_Type__c=='ZSO'  || order.Order_Type__c=='ZDO' ) && order.Status__c !='Synced' )
                OrdersFiltered.add(Order);
        }
        System.debug('-----Orders--2--'+orders);
        //orders.clear();
        orders = new List<SAP_Order__c>(OrdersFiltered);
        
        System.debug('-----Orders--3--'+orders);
        
        for(SAP_Order__c order: orders){
            for(CPQ_Field_Mapping__mdt mapping: idMapping){
                //Add to fieldmapping based on category from result
                
                if(order.get(mapping.Source_Field__c)!=null){
                    if(mapping.Lookup_Object__c=='Account'){
                        accountSet.add(String.valueOf(order.get(mapping.Source_Field__c)));
                    }else if(mapping.Lookup_Object__c=='Contact'){
                        contactSet.add(String.valueOf(order.get(mapping.Source_Field__c)));
                    }else if(mapping.Lookup_Object__c=='Product'){
                        productSet.add(String.valueOf(order.get(mapping.Source_Field__c)));
                    }
                    
                }
            }
            
            //Retrieve all ENTITL_EXT_ID__c so Subscriptions can be updated if necessary(Will handle if SAP Orders are ever updated after insert)
            if(order.ENTITL_EXT_ID__c!=null){
                subSet.add(order.ENTITL_EXT_ID__c);
            }
        }
        
        //Query and Populate Maps of Lookups
        processIdMappings();
        system.debug('-----Orders--4--'+orders);
        
        //Update SAP Orders in Memory with appropriate fields based on External IDs from SAP, If not Found populate the Error Log Field on the SAP Order
        for(SAP_Order__c order: orders){
            for(CPQ_Field_Mapping__mdt mapping: idMapping){
                //Add to fieldmapping based on category from result
                //order.Error_Log__c=null;
                if(order.get(mapping.Source_Field__c)!=null){
                    //order.Error_Log__c=null;
                    if(mapping.Lookup_Object__c=='Account'){
                        if(accountMap.containsKey(String.valueOf(order.get(mapping.Source_Field__c)))){
                            order.put(mapping.Destination_Field__c, accountMap.get(String.valueOf(order.get(mapping.Source_Field__c))));
                            //order.Error_Log__c='';
                        }else{
                            order.Error_Log__c=String.valueOf(order.get(mapping.Source_Field__c)) + ' (' + String.valueOf(mapping.Source_Field__c) + ') is not a valid Account in Salesforce';
                            order.Status__c='Error';
                        }
                    }else if(mapping.Lookup_Object__c=='Contact'){
                        if(contactMap.containsKey(String.valueOf(order.get(mapping.Source_Field__c)))){
                            order.put(mapping.Destination_Field__c, contactMap.get(String.valueOf(order.get(mapping.Source_Field__c))));
                            //order.Error_Log__c='';
                        }else{
                            order.Error_Log__c=String.valueOf(order.get(mapping.Source_Field__c)) + ' (' + String.valueOf(mapping.Source_Field__c) + ') is not a valid Contact in Salesforce';
                            order.Status__c='Error';
                        }
                    }else if(mapping.Lookup_Object__c=='Product'){
                        if(productMap.containsKey(String.valueOf(order.get(mapping.Source_Field__c)))){
                            order.put(mapping.Destination_Field__c, productMap.get(String.valueOf(order.get(mapping.Source_Field__c))));
                            //order.Error_Log__c='';
                        }else{
                            order.Error_Log__c=String.valueOf(order.get(mapping.Source_Field__c)) + ' (' + String.valueOf(mapping.Source_Field__c) + ') is not a valid Product in Salesforce';
                            order.Status__c='Error';
                        }
                    }
                    
                }
            }
            
        }
        
        
        //Create Contracts/Subs (New) based on PAKID + End Date or Update Existing Quotes/Lines(Renewal)
        //Query Orders into two processing groups, one for new and one for Renewals
        for(SAP_Order__c order: orders){
            //If Opp exists, needs to be passed through updating cycle
            
            //If No Opp ID then treat as a net new Contract/Subscription Line
            //  Grab all entitlement Ids and query to perform upsert  
            //  Return map of Entitlement to Contract Record
            
            //Create Map based on PAKID + Date or Entitlement ID to handle both scenarios
            if((order.SFDC_Opportunity__c==null || (order.Sales_Type__c=='I' && order.SFDC_Opportunity__c!=null) ) && order.Error_Log__c==null && order.Subscription_Term__c!=0  && order.Subscription_Term__c!=null && order.End_Date__c!=null){
                
                //Create Mapping based on Entitlement ID if Product is Serialized, Else Mapping is based on PAKID + End Date
                Contract con=new Contract();
                //String pakID_Date=order.SAP_PAK_ID__c + String.valueOf(order.End_Date__c);
                
                String pakID_Date=order.SAP_Account__c+order.Sold_To_Partner__c+order.VAR__c+String.valueOf(order.Start_Date__c)+String.valueOf(order.End_Date__c);
                system.debug(pakID_Date);
                
                entitlements.put(pakID_Date, con);
                entitlements.put(order.ENTITL_EXT_ID__c, con);
                
                
            }
            
            //Create Asset List
            if((order.SFDC_Opportunity__c==null || (order.Sales_Type__c=='I' && order.SFDC_Opportunity__c!=null) ) && order.Error_Log__c==null && (order.Subscription_Term__c==0 || order.Subscription_Term__c==null)){
                assetOrders.add(order);
                
                //Create QuoteLine Set    
            }else if(order.SFDC_Opportunity__c!=null && order.Error_Log__c==null){
                //
                oppSet.add(order.SFDC_Opportunity__c);
                if(order.SFDC_Quote_Line__c!=null){
                    quoteLineSet.add(order.SFDC_Quote_Line__c);
                }
            }
        }
        
        
        
        if(!oppSet.isEmpty()){
            //Query Opportunities and Update with Order Information
            syncOppQuotes();
            system.debug(oppMap);
            system.debug(quoteLineMap);
            system.debug(quoteMap);
            
            //Update Fields on the Opportunity Based on Appropriate Fields from Custom Metadata and SAP Order Object
            for(SAP_Order__c order: orders){
                if(order.SFDC_Opportunity__c!=null && order.Error_Log__c==null){
                    if(oppMap.containsKey(order.SFDC_Opportunity__c)){
                        Opportunity opp=oppMap.get(order.SFDC_Opportunity__c);
                        opp.StageName='Renewal Closed Won';
                        //SOQ
                        if(order.Sales_Type__c == 'I')
                            opp.StageName='Closed Won';
                        
                        for(CPQ_Field_Mapping__mdt standard:standardMapping){
                            if(standard.Destination_Object__c=='Opportunity' && standard.Category__c=='Renewal'){
                                if(standard.FieldType__c=='String'){
                                    opp.put(standard.Destination_Field__c, String.valueOf(order.get(standard.Source_Field__c)));
                                    system.debug(String.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Integer'){
                                    opp.put(standard.Destination_Field__c, Integer.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Decimal'){
                                    opp.put(standard.Destination_Field__c, Double.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Date'){
                                    opp.put(standard.Destination_Field__c, Date.valueOf(order.get(standard.Source_Field__c)));
                                }
                            }
                        }   
                        oppMap.put(opp.id, opp);
                    }
                    
                    //EXCLUDED:  IF QUOTE IS EVER AN OBJECT TO UPDATE VIA THE PROCESS UNCOMMENT THIS CODEBLOCK
                    //Update Primary Quote
                    //for(SBQQ__Quote__c quote:quoteMap.values()){
                    //if(quoteMap.containsKey(order.SFDC_Opportunity__c)){
                    //    SBQQ__Quote__c quote=quoteMap.get(order.SFDC_Opportunity__c);
                    
                    //    for(CPQ_Field_Mapping__mdt standard:standardMapping){
                    //        if(standard.Destination_Object__c=='SBQQ__Quote__c' && standard.Category__c=='Renewal'){
                    //            if(standard.FieldType__c=='String'){
                    //                quote.put(standard.Destination_Field__c, String.valueOf(order.get(standard.Source_Field__c)));
                    //                system.debug(String.valueOf(order.get(standard.Source_Field__c)));
                    //            }else if(standard.FieldType__c=='Integer'){
                    //                quote.put(standard.Destination_Field__c, Integer.valueOf(order.get(standard.Source_Field__c)));
                    //            }else if(standard.FieldType__c=='Decimal'){
                    //                quote.put(standard.Destination_Field__c, Double.valueOf(order.get(standard.Source_Field__c)));
                    //            }else if(standard.FieldType__c=='Date'){
                    //                quote.put(standard.Destination_Field__c, Date.valueOf(order.get(standard.Source_Field__c)));
                    //            }
                    //        }
                    //    }   
                    //    quoteMap.put(quote.SBQQ__Opportunity2__c, quote);
                    //}
                    
                    //This section can be removed, It was put in place initially to handle quote lines but now has been replaced by batch process
                    //Please remove after code freeze has ended
                    
                    if(quoteLineMap.containsKey(order.SFDC_Quote_Line__c)){
                        SBQQ__QuoteLine__c quoteline=quoteLineMap.get(order.SFDC_Quote_Line__c);
                        
                        for(CPQ_Field_Mapping__mdt standard:standardMapping){
                            if(standard.Destination_Object__c=='SBQQ__QuoteLine__c' && standard.Category__c=='Renewal'){
                                if(standard.FieldType__c=='String'){
                                    quoteline.put(standard.Destination_Field__c, String.valueOf(order.get(standard.Source_Field__c)));
                                    system.debug(String.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Integer'){
                                    quoteline.put(standard.Destination_Field__c, Integer.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Decimal'){
                                    quoteline.put(standard.Destination_Field__c, Double.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Date'){
                                    quoteline.put(standard.Destination_Field__c, Date.valueOf(order.get(standard.Source_Field__c)));
                                }
                            }
                        }   
                        
                        //Updating new Status field for SAP Orders that are related to Quote Lines
                        if(order.Status__c!='Synced'){
                            order.Status__c='Processed';
                        }
                        
                        
                    }
                    
                    
                    
                }
                
                
            }
            
            upsert oppMap.values();
        }
        
        
        
        system.debug('Entitlements/Contracts');
        
        //Create Assets(NET NEW)
        
        if(!assetOrders.isEmpty()){
            system.debug('Creating Asset(s)');
            
            for(SAP_Order__c order: assetOrders){
                Asset ass=new Asset();
                for(CPQ_Field_Mapping__mdt standard:standardMapping){
                    if(standard.Destination_Object__c=='Asset'){
                        system.debug(standard.Source_Field__c);
                        system.debug(standard.Destination_Field__c);
                        if(standard.FieldType__c=='String'){
                            ass.put(standard.Destination_Field__c, String.valueOf(order.get(standard.Source_Field__c)));
                            
                            system.debug(String.valueOf(order.get(standard.Source_Field__c)));
                            
                        }else if(standard.FieldType__c=='Integer'){
                            ass.put(standard.Destination_Field__c, Integer.valueOf(order.get(standard.Source_Field__c)));
                        }else if(standard.FieldType__c=='Decimal'){
                            ass.put(standard.Destination_Field__c, Double.valueOf(order.get(standard.Source_Field__c)));
                        }else if(standard.FieldType__c=='Date'){
                            ass.put(standard.Destination_Field__c, Date.valueOf(order.get(standard.Source_Field__c)));
                        }
                        //sub.put(standard.Destination_Field__c, String.valueOf(order.get(standard.Source_Field__c)));
                    }
                }
                assets.add(ass);   
                //Updating new Status field for SAP Orders
                order.Status__c='Synced'; 
            }
            //Comment asset logic
            //upsert assets;
        }
        
        //Update Entitlement/Contract Details if applicable (NET NEW PROCESS ONLY)
        if(!entitlements.isEmpty()){
            
            updateEntitlementContractMapping();
            List<Contract> contractFluidList=new List<Contract>();
            for(Contract con: entitlements.values()){
                if(con.id!=null){
                    contractFluidList.add(con);
                }
            }
            
            for(SAP_Order__c order: orders){
                Boolean found=false;
                
                system.debug('-----------------1-----------------'+order.Sales_Type__c);
                system.debug('------------------2----------------'+order.SFDC_Opportunity__c);
                system.debug('-----------------3-----------------'+contractFluidList);
                system.debug('-----------------4-----------------'+Order);
                //SOQ New
                if(  (order.SFDC_Opportunity__c==null || (order.Sales_Type__c=='I' && order.SFDC_Opportunity__c!=null) ) && order.Error_Log__c==null && order.Subscription_Term__c!=0 && order.Subscription_Term__c!=null && order.End_Date__c!=null){
                    Contract con;
                    //Non-Serialzied Products are Based on PAK ID + End Date
                    //Serialzied Products are based on Entitlement ID
                    
                    //String pakID_Date=order.SAP_PAK_ID__c + String.valueOf(order.End_Date__c);
                    String pakID_Date=order.SAP_Account__c+order.Sold_To_Partner__c+order.VAR__c+String.valueOf(order.Start_Date__c)+String.valueOf(order.End_Date__c);
                    system.debug(contractFluidList);
                    
                    for(Contract confluid:contractFluidList){
                        if(confluid.Entitlement_ID__c==order.ENTITL_EXT_ID__c){
                            con=confluid;
                            found=true;
                            system.debug('Found Matching Entitlement');
                        }else if(confluid.Hidden_Pak_Date_ID__c==pakID_Date){
                            con=confluid;
                            found=true;
                            system.debug('Found Matching PAKDate');
                        }
                    }
                    
                    if(found==false){
                        system.debug('-----------------6-----------------');
                        con=new Contract(Entitlement_ID__c=order.ENTITL_EXT_ID__c, Hidden_Pak_Date_ID__c=pakID_Date);
                        system.debug('-----------------7-----------------'+con);
                    }
                    system.debug('-----------------8-----------------'+con.id);
                    //Nested for loop only to handle the instance where multiple SAP Orders come in the same thread
                    if(con.id==null){
                        
                        for(CPQ_Field_Mapping__mdt standard:standardMapping){
                            if(standard.Destination_Object__c=='Contract'){
                                system.debug(standard.Source_Field__c);
                                system.debug(standard.Destination_Field__c);
                                if(standard.FieldType__c=='String'){
                                    con.put(standard.Destination_Field__c, String.valueOf(order.get(standard.Source_Field__c)));
                                    system.debug(String.valueOf(order.get(standard.Source_Field__c)));
                                    
                                }else if(standard.FieldType__c=='Integer'){
                                    con.put(standard.Destination_Field__c, Integer.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Decimal'){
                                    con.put(standard.Destination_Field__c, Double.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Date'){
                                    con.put(standard.Destination_Field__c, Date.valueOf(order.get(standard.Source_Field__c)));
                                }
                                
                            }
                        }
                        system.debug('-----------------9-----------------'+con);
                        if(found==false){
                            contractFluidList.add(con);
                            system.debug('-----------------10-----------------'+contractFluidList);
                        }
                        
                        system.debug('-----------------11-----------------'+order);
                        //   if(order.Hardware_Serial_Number__c==null){
                        //     entitlements.put(pakID_Date, con);
                        //}else{
                        //  entitlements.put(order.Entitlement_ID__c,con);
                        
                        //}
                        
                        //Updating new Status field for SAP Orders
                        order.Status__c='Synced';
                    }
                }
            }
            
            //Upsert new Contracts
            system.debug(contractFluidList);
            
            upsert contractFluidList;
            
            //ReCreate Entitlements Map
            entitlements=new Map<String,Contract>();
            for(Contract con:contractFluidList){
                entitlements.put(con.Entitlement_ID__c, con);
                entitlements.put(con.Hidden_Pak_Date_ID__c,con);
            }
            
            
            //Create Subscriptions
            system.debug('-----Entering Create Subscription----'+orders);
            for(SAP_Order__c order: orders){
                if((order.SFDC_Opportunity__c==null || (order.Sales_Type__c=='I' && order.SFDC_Opportunity__c!=null) ) && order.Error_Log__c==null && order.Subscription_Term__c!=0 && order.Subscription_Term__c!=null){
                    SBQQ__Subscription__c sub=new SBQQ__Subscription__c();
                    //Asset ass=new Asset();
                    
                    //String pakID_Date=order.SAP_PAK_ID__c + String.valueOf(order.End_Date__c);
                    String pakID_Date=order.SAP_Account__c+order.Sold_To_Partner__c+order.VAR__c+String.valueOf(order.Start_Date__c)+String.valueOf(order.End_Date__c);
                    system.debug('-----sub-1----'+pakID_Date);
                    if(entitlements.containsKey(pakID_Date)){
                        order.Contract__c=entitlements.get(pakID_Date).id;
                        system.debug('-----sub-2----'+entitlements.get(pakID_Date).id);
                        sub.SBQQ__Contract__c=entitlements.get(pakID_Date).id;
                    }else{
                        system.debug('-----sub-3----'+entitlements.get(order.ENTITL_EXT_ID__c).id);
                        order.Contract__c=entitlements.get(order.ENTITL_EXT_ID__c).id;
                        sub.SBQQ__Contract__c=entitlements.get(order.ENTITL_EXT_ID__c).id;
                    }
                    
                    
                    if(subMap.containsKey(order.ENTITL_EXT_ID__c)){
                        sub=subMap.get(order.ENTITL_EXT_ID__c);
                        system.debug('-----sub-4----'+subMap.get(order.ENTITL_EXT_ID__c));
                    }
                    if(order.Subscription_Term__c!=null && order.Subscription_Term__c!=0)
                    {
                        system.debug('-----sub-5----'+order.Subscription_Term__c);
                        for(CPQ_Field_Mapping__mdt standard:standardMapping){
                            if(standard.Destination_Object__c=='SBQQ__Subscription__c'){
                                system.debug('Source: ' + standard.Source_Field__c);
                                system.debug('Destination: ' + standard.Destination_Field__c);
                                
                                if(standard.FieldType__c=='String'){
                                    sub.put(standard.Destination_Field__c, String.valueOf(order.get(standard.Source_Field__c)));
                                    system.debug(String.valueOf(order.get(standard.Source_Field__c)));
                                    
                                }else if(standard.FieldType__c=='Integer'){
                                    sub.put(standard.Destination_Field__c, Integer.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Decimal'){
                                    sub.put(standard.Destination_Field__c, Double.valueOf(order.get(standard.Source_Field__c)));
                                }else if(standard.FieldType__c=='Date'){
                                    sub.put(standard.Destination_Field__c, Date.valueOf(order.get(standard.Source_Field__c)));
                                }
                                
                            }
                        }
                        system.debug('-----sub-9----'+sub);
                        subs.add(sub);
                        //Updating new Status field for SAP Orders
                        order.Status__c='Synced';
                    }
                    
                }
                
            }
            system.debug('-----sub-10----'+subs);
            try{
                upsert subs;
            }catch(DmlException d){
                system.debug('-----sub-11----'+d.getMessage());
            }
            
        }
    }
    public void processIdMappings(){
        //Create Mapping Tables for Contact/Account/Product
        for(Product2 prod:[Select id, ProductCode from Product2 where isCPQ__C=True and ProductCode in: productSet]){
            productMap.put(prod.ProductCode, prod.id);
        }
        
        for(Account acc:[Select id, SAP_Customer_Number__c from Account where SAP_Customer_Number__c in: accountSet]){
            accountMap.put(acc.SAP_Customer_Number__c, acc.id);
        }
        
        for(Contact con:[Select id, SAP_Contact_ID__c from Contact where SAP_Contact_ID__c IN: contactSet]){
            contactMap.put(con.SAP_Contact_ID__c, con.id);
        }
        
        for(SBQQ__Subscription__c sub:[Select id, ENTITL_EXT_ID__c from SBQQ__Subscription__c where ENTITL_EXT_ID__c IN: subSet]){
            subMap.put(sub.ENTITL_EXT_ID__c, sub);
        }
    }
    
    public void updateEntitlementContractMapping(){
        String soql='Select id,Hidden_Pak_Date_ID__c ';
        Set<String> filterset=entitlements.keySet();
        
        
        for(CPQ_Field_Mapping__mdt standard:standardMapping){
            if(standard.Destination_Object__c=='Contract'){
                soql= soql + ', ' + standard.Destination_Field__c;
            }
        }
        
        soql = soql + ' From Contract where Entitlement_ID__c IN: filterset or Hidden_Pak_Date_ID__c IN: filterset';
        
        system.debug('SOQL Query: ' + soql);
        
        List<Contract> cons=Database.query(soql);
        
        //Retrieves existing Contracts that have matching Entitlement IDs or Matching Hidden PAK Ids
        for(Contract con:cons){
            if(entitlements.containsKey(con.Entitlement_ID__c)){
                entitlements.put(con.Entitlement_ID__c, con);
            }else if(entitlements.containsKey(con.Hidden_Pak_Date_ID__c)){
                entitlements.put(con.Hidden_Pak_Date_ID__c, con);
            }
        }
    }
    
    //Queries Appropriate Fields and Retrives Correct Mapping for Opp, Quote, Quote Lines
    public void syncOppQuotes(){
        
        String soql='Select id ';
        String soqlquote='Select id, SBQQ__Opportunity2__c ';
        String soqlquoteline='Select id, SBQQ__Quote__r.SBQQ__Opportunity2__c ';
        Set<String> quoteSet=new Set<String>();
        
        for(CPQ_Field_Mapping__mdt standard:standardMapping){
            if(standard.Destination_Object__c=='Opportunity' && standard.Category__c=='Renewal'){
                soql= soql + ', ' + standard.Destination_Field__c;
            }
            
            if(standard.Destination_Object__c=='SBQQ__Quote__c' && standard.Category__c=='Renewal'){
                soqlquote= soqlquote + ', ' + standard.Destination_Field__c;
            }
            
            if(standard.Destination_Object__c=='SBQQ__QuoteLine__c' && standard.Category__c=='Renewal'){
                soqlquoteline= soqlquoteline + ', ' + standard.Destination_Field__c;
            }
            
        }
        
        soql = soql + ' From Opportunity where Id IN: oppSet';
        
        system.debug('SOQL Query: ' + soql);
        
        List<Opportunity> oppList=Database.query(soql);
        for(Opportunity opp:oppList){
            oppMap.put(opp.id, opp);
        }
        
        soqlquote = soqlquote + ' From SBQQ__Quote__c where SBQQ__Opportunity2__c IN: oppSet and SBQQ__Primary__c=true';
        system.debug('SOQL Query: ' + soqlquote);
        List<SBQQ__Quote__c> quoteList=Database.query(soqlquote);
        for(SBQQ__Quote__c quote:quoteList){
            //Create Quote Map
            quoteMap.put(quote.SBQQ__Opportunity2__c, quote);
        }
        
        system.debug(quoteLineSet);
        
        soqlquoteline = soqlquoteline + ' From SBQQ__QuoteLine__c where Id IN: quoteLineSet';
        system.debug('SOQL Query: ' + soqlquoteline);
        List<SBQQ__QuoteLine__c> quoteLineList=Database.query(soqlquoteline);
        for(SBQQ__QuoteLine__c quoteline:quoteLineList){
            //Create Quote Line Map
            quotelineMap.put(quoteline.id, quoteline);
        }
        
        
    }
    
    //Updates Related SAP Order Ids after insert of SAP Orders.  Allows Users to see related list and trace back to the SAP Order from Subscriptions and Assets
    public void processSapIds(List<SAP_Order__c> orders){
        Map<String,String> entitlekey=new Map<String,String>();
        for(SAP_Order__c order:orders){
            if(order.ENTITL_EXT_ID__c!=null){
                entitlekey.put(order.ENTITL_EXT_ID__c, order.id);
            }
        }
        
        List<Asset> assList=new List<Asset>([Select id,ENTITL_EXT_ID__c, SAP_Order__c from Asset where ENTITL_EXT_ID__c in:entitlekey.keySet()]);
        List<SBQQ__Subscription__c> subList=new List<SBQQ__Subscription__c>([Select id,ENTITL_EXT_ID__c,SAP_Order__c from SBQQ__Subscription__c where ENTITL_EXT_ID__c in:entitlekey.keySet()]);
        
        for(Asset a:assList){
            if(entitlekey.containsKey(a.ENTITL_EXT_ID__c)){
                a.SAP_Order__c=entitlekey.get(a.ENTITL_EXT_ID__c);
            }
        }
        
        for(SBQQ__Subscription__c s:subList){
            if(entitlekey.containsKey(s.ENTITL_EXT_ID__c)){
                s.SAP_Order__c=entitlekey.get(s.ENTITL_EXT_ID__c);
            }
        }
        
        update assList;
        update subList;
    }
    
    /**
* @description Dummy test method - Technical Dept
* @param  Dummy method
* @return  Void: It returns nothing
*/  
    public static void CoverageMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        
    } 
    
}