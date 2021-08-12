/*
    SOQ_CreateQuote_BAT_SCH
    2020.09.24 - pjena - Batch class to create Quote
                        Note: Quote Lines will be created with another chained batch job due to CPQ queable job restrictions - can have only 1 queuebale job to recalculate the amount

    It needs to be scheduled manually from Dev Console for the first time and afterwards it will run from the configuration present in Custom Settings named SOQ_QuoteCreation_Settings__c
    SOQ_QuoteCreation_Settings__c.BATCHJOB_RECUR__c - Defines recurring frequency in minutes. 
                    The job repeats execution based on this time gap.
    SOQ_QuoteCreation_Settings__c.BATCHJOB_BATCH_SIZE__c - Number of records processed in each batch.
                    If the transaction takes more time then reduce the batch size.
    SOQ_QuoteCreation_Settings__c.BATCHJOB_OppCreationCutOffDateTime__c - Only auto create quote and quote line item for Opp Regs created since this cutoff date/time.
                    
    Commad to schedule the apex through Developer Console
    
    SOQ_CreateQuote_BAT_SCH p = new SOQ_CreateQuote_BAT_SCH();
    DateTime currDT = DateTime.now().addMinutes(2);
    integer sec = currDT.second();
    integer min = currDT.minute();
    String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
    system.debug('sch: ' + sch);
    system.schedule('Exec of SOQ_CreateQuote_BAT_SCH', sch, p);

    Please note the batch size needs to be always 1 for avoiding QueueableCalculatorService error SBQQ:Too many queueable jobs added to the queue: 2 

    2020.04.05 - Set Quote Owner from Opportunity Owner
    
*/
public class SOQ_CreateQuote_BAT_SCH implements Database.Batchable<SObject>, System.Schedulable, Database.RaisesPlatformEvents {
    
    private decimal dRecurTime;
    private decimal dBatchSize;
    private DateTime dtLookBackTime;
    private integer iRecurTime;
    private integer iBatchSize;
    
    
    private Id QuoteRTID{get;set;}
    private string initialQuoteStatus{get;set;}
    private string OppRegProgDiscType{get;set;}
    private string QuoteProcessId{get;set;}
    private string QuoteType{get;set;}
    private string CustomerClassification{get;set;}

    private string OPP_TYPE = 'Deal Registration';

    //Structures to pass on to SOQ_CreateQuoteLine_Bat
    list<Opportunity> lstOppRegs = new  list<Opportunity>();
    map<Id, SBQQ__Quote__c> oppQuoteMap = new map<Id, SBQQ__Quote__c>();
    map<string, string> customerClassificationMap = new map<string, string>();
    
    //Constructor to initialize the global variables
    public SOQ_CreateQuote_BAT_SCH() {
        system.debug('********Begin: Constructor: SOQ_CreateQuote_BAT_SCH()**************');
        try{
            dRecurTime  = SOQ_QuoteCreation_Settings__c.getOrgDefaults().BATCHJOB_RECUR__c ; //in minutes
            dtLookBackTime  = SOQ_QuoteCreation_Settings__c.getOrgDefaults().BATCHJOB_OppCreationCutOffDateTime__c ; // DateTime
            dBatchSize = SOQ_QuoteCreation_Settings__c.getOrgDefaults().BATCHJOB_BATCH_SIZE__c;
            //set the global variable
            iRecurTime = integer.valueOf(dRecurTime);
            iBatchSize = integer.valueOf(dBatchSize);

            //Set Quote default values from Custom Settings
            QuoteRTID  = SOQ_QuoteCreation_Settings__c.getOrgDefaults().RecordTypeId__c;
            initialQuoteStatus  = SOQ_QuoteCreation_Settings__c.getOrgDefaults().Initial_Status__c;
            OppRegProgDiscType = SOQ_QuoteCreation_Settings__c.getOrgDefaults().OppReg_Prog_Disc_Type__c;
            QuoteProcessId = SOQ_QuoteCreation_Settings__c.getOrgDefaults().Quote_Process_Id__c;
            QuoteType = SOQ_QuoteCreation_Settings__c.getOrgDefaults().Quote_Type_c__c;
            CustomerClassification = SOQ_QuoteCreation_Settings__c.getOrgDefaults().Customer_Classification__c; 
            
            //Input string Education=>GX Opp Reg EDU,vGPU SW Opp Reg EDU,Parabricks Opp Reg EDU;Inception=>DGX Opp Reg Inception
            //Output - build the customerClassificationMap as {GX Opp Reg EDU => Education, vGPU SW Opp Reg EDU=>Education, Parabricks Opp Reg EDU=>Education, DGX Opp Reg Inception=>Inception}
            list<string> lstCustClassTypes = CustomerClassification.split(';'); //Education=>GX Opp Reg EDU,vGPU SW Opp Reg EDU,Parabricks Opp Reg EDU
            for (string custClassType : lstCustClassTypes){
                list<string> lstCustClass = custClassType.split('=>'); //[0]Education, [1]GX Opp Reg EDU,vGPU SW Opp Reg EDU,Parabricks Opp Reg EDU 
                string classificationVal = lstCustClass[0]; //Education
                list<string> lstProgramTypes = lstCustClass[1].split(',');//[0]GX Opp Reg EDU [1]vGPU SW Opp Reg EDU [2]Parabricks Opp Reg EDU 
                for (string progType : lstProgramTypes){
                    customerClassificationMap.put(progType, classificationVal); //{GX Opp Reg EDU => Education, vGPU SW Opp Reg EDU=>Education, Parabricks Opp Reg EDU=>Education}
                }

            }

            
        } catch(Exception ex){
            system.debug('***Value could not be set from parameters, so setting the default lookback to 1 hour and recurrence to every 60 minutes');
            system.debug('***Exception: ' + ex);
            
            //set the default lookback to 24 hour and recurrence to every 60 minutes
            iRecurTime = 60; //60 minutes
            dtLookBackTime = DateTime.now().addHours(-24);
            iBatchSize = 1;
        }
        
        system.debug('***Value from Settings: dRecurTime (BATCHJOB__RECUR__c) = ' + dRecurTime);
        system.debug('***Value from Settings: dLookBackTime (BATCHJOB_OppCreationCutOffDateTime__c) = ' + dtLookBackTime);
        system.debug('***Value from Settings: dBatchSize (BATCHJOB_BATCH_SIZE__c) = ' + iBatchSize);
        
        system.debug('***Value set to iRecurTime = ' + iRecurTime);
        system.debug('***Value set to iBatchSize = ' + iBatchSize);
        system.debug('********End: Constructor: SOQ_CreateQuote_BAT_SCH()**************');
    }

    //Schedulable interface method implementation. 
    //When you schedule the class SOQ_CreateQuote_BAT_SCH to run at a specific interval, it will run the this execute method which in turn will call the batch apex methods
    public void execute(SchedulableContext sc){

            system.debug('---------Start: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
            //Invoke the batch job
            SOQ_CreateQuote_BAT_SCH oSOQ_CreateQuote_BAT_SCH = new SOQ_CreateQuote_BAT_SCH();
            database.executeBatch(oSOQ_CreateQuote_BAT_SCH, 1); //iBatchSize 
            system.debug('---------End: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
        
            //------------------Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
            system.debug('------------------Start: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
            DateTime nextScheduleTime = system.now().addMinutes(iRecurTime);
            string minute = string.valueof(nextScheduleTime.minute());
            string second = string.valueof(nextScheduleTime.second ());
            string cronValue = second + ' ' + minute + ' * * * ?' ;
            string jobName = 'SOQ_CreateQuote_BAT_SCH - ' + nextScheduleTime.format('hh:mm');
     
            SOQ_CreateQuote_BAT_SCH oSchCls = new SOQ_CreateQuote_BAT_SCH();
            system.schedule(jobName, cronValue , oSchCls);
     
            system.debug('------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
            
            //this section of code will abort the current schedule job
            system.abortJob(sc.getTriggerId());
            //------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
        
    }

    //*************************************************************************************************************************
    //  BATCH METHODs
    //*************************************************************************************************************************
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('*******Enters Batch Start Method');
        system.debug('***dtLookBackTime: ' + dtLookBackTime);
        return Database.getQueryLocator([   Select Id, OwnerId, AccountId, Account.CPQ_Customer_Classification__c, DR_Customer_Contact__c, Program_Type__c, 
                                                NPN_Solution_Provider_VAR__c, DR_Partner_Sales_Rep_Company__c, DR_Partner_Sales_Rep_Name__c, NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c,
                                                SBQQ__PrimaryQuote__c
                                            From Opportunity
                                            Where Type = :OPP_TYPE
                                                And IsClosed = false
                                                And DR_Deal_Status__c = 'Approved'
                                                And SBQQ__PrimaryQuote__c = null
                                                And CreatedDate >= :dtLookBackTime
                                            Order By LastModifiedDate desc
                                        ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('---------Entering Batch Job SOQ_CreateQuote_BAT_SCH execute method-------------------');
        if (scope != null && !scope.isEmpty()){
                lstOppRegs = (List<Opportunity>) scope;
                system.debug('***lstOppRegs > ' + lstOppRegs);
                map<Id, Opportunity> mapIdOppRegOpp = new map<Id, Opportunity>();
                list<string> oppRegProdNames = new list<string>();
                list<SOQ_OppReg_Product_Map__c> lstSOQOppRegProducts = new list<SOQ_OppReg_Product_Map__c>();
                oppQuoteMap = new map<Id, SBQQ__Quote__c>();

                for (Opportunity oppReg : lstOppRegs){
                    system.debug('oppReg.NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c > ' + oppReg.NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c);

                    //Build the map of Opp Id and Opportunity
                    mapIdOppRegOpp.put(oppReg.Id, oppReg);

                    //Create quote from opportunity
                    system.debug('*******Begin: Call CreateQuotesFromOpportunities Method');
                    oppQuoteMap = CreateQuotesFromOpportunities(mapIdOppRegOpp);
                    system.debug('*******End: Call CreateQuotesFromOpportunities Method');
                    //End: Create quote from opportunity
                }
            
        }
        system.debug('---------Exiting Batch Job SOQ_CreateQuote_BAT_SCH execute method-------------------');
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('---------Entering Batch Job finish method-------------------');
        system.debug('---------Chains SOQ_CreateQuoteLine_BAT to create quote lines-------------------');
        if(!Test.isRunningTest()){
            Id batchJobId = Database.executeBatch(new SOQ_CreateQuoteLine_BAT(), iBatchSize);
        }
        system.debug('---------Exiting Batch Job finish method-------------------');
    }
    
    //*************************************************************************************************************************
    //  End: BATCH METHODs
    //*************************************************************************************************************************

    //*************************************************************************************************************************
    //  Quote and Quote Line helper METHODs
    //*************************************************************************************************************************
    private Map<Id, SBQQ__Quote__c> CreateQuotesFromOpportunities(map<Id, Opportunity> mapIdOppRegOpp) {
        system.debug('---------Entering CreateQuotesFromOpportunities method-------------------');
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote;
        Map<Id, SBQQ__Quote__c> oqMap = new Map<Id, SBQQ__Quote__c>();
        
        for (Id key : mapIdOppRegOpp.keySet()) {
            quote = new SBQQ__Quote__c();

            Opportunity oppReg =  mapIdOppRegOpp.get(key);

            //quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Primary__c = True;
            quote.SBQQ__Type__c = QuoteType; //"Quote"
            quote.SBQQ__Opportunity2__c = key;
            quote.RecordTypeId = QuoteRTID;
            quote.SBQQ__QuoteProcessId__c = QuoteProcessId;
            quote.SBQQ__Status__c = initialQuoteStatus;
            quote.Programmatic_Disc_Type__c = OppRegProgDiscType;
            quote.SBQQ__Account__c = oppReg.AccountId; //End Customer Account
            quote.SBQQ__SalesRep__c = oppReg.OwnerId;
            quote.OwnerId = oppReg.OwnerId; //2020.04.05 - Set Quote Owner from Opportunity Owner
            quote.End_Customer_Contact__c = oppReg.DR_Customer_Contact__c;
            quote.Reseller_Account__c = oppReg.NPN_Solution_Provider_VAR__c;
            quote.Reseller_Contact__c = oppReg.DR_Partner_Sales_Rep_Name__c;

            //quote.Customer_Classification__c = '';//Done through trigger but ask Maaza
            //2021.03.08 - UAT86-Opp Reg quotes need to set the Customer Classification based on the Opp > Program Types; Other program types will still follow the Account > CPQ Customer Classification
            if (customerClassificationMap.get(oppReg.Program_Type__c) != null){
                quote.Customer_Classification__c = customerClassificationMap.get(oppReg.Program_Type__c);
            }else{
                quote.Customer_Classification__c = oppReg.Account.CPQ_Customer_Classification__c;
            }

            quotes.add(quote);
        }
        
        insert quotes;
        
        // convert these quotes into a map based upon opportunity -> this is used in the next step to create quote line items
        for (SBQQ__Quote__c qt :quotes) {
            oqMap.put(qt.SBQQ__Opportunity2__c, qt);
        }
        system.debug('---------Exiting CreateQuotesFromOpportunities method-------------------');
        return oqMap;
    }

    
}