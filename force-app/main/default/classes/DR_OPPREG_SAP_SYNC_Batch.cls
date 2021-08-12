/*
    DR_OPPREG_SAP_SYNC_Batch
    2018.09.30 - pjena - Batch class to to Sync OPP REG data to SAP
    It needs to be scheduled manually from Dev Console for the first time and afterwards it will run from the configuration present in Custom Settings named OPPREG_SAP_SYNC_Settings__c
    DR_SAP_SYNC_Settings__c.BATCHJOB_LKBK_TIME__c - Defines the lookback time in minutes. 
                    All Users that got created or modified from this lookback time till current time are processed by this job
    DR_SAP_SYNC_Settings__c.BATCHJOB_RECUR__c - Defines recurring frequency in minutes. 
                    The job repeats execution based on this time gap.
    DR_SAP_SYNC_Settings__c.BATCHJOB_ENABLE_SCHDULED_JOB__c - Flag to enable or disable the job.
                    This is an automatic way to abort the scheduled job. Once it is aborted the job needs to be sc manually thru the Dev Console.
    DR_SAP_SYNC_Settings__c.BATCHJOB_BATCH_SIZE__c - Number of records processed in each batch.
                    If the callout takes more time then reduce the batch size.
                    
    Commad to schedule the apex through Developer Console
    
    DR_OPPREG_SAP_SYNC_Batch p = new DR_OPPREG_SAP_SYNC_Batch();
    DateTime currDT = DateTime.now().addMinutes(2);
    integer sec = currDT.second();
    integer min = currDT.minute();
    String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
    system.debug('sch: ' + sch);
    system.schedule('Exec of DR_OPPREG_SAP_SYNC_Batch', sch, p);
    
*/

public class DR_OPPREG_SAP_SYNC_Batch implements Database.Batchable<SObject>, System.Schedulable, Database.AllowsCallouts{
    
    //Lookback Time and recurrig time in Minutes
    private decimal dRecurTime;
    private decimal dLookBackTime;
    private decimal dBatchSize;
    private boolean isJobEnabled = true;
    private decimal dCalloutTimeOut;
    private string namedCredentialEndPoint;
    private string dealRegApprovalProcessPDId; //Approval Process > Process Definition Id
    
    private integer iRecurTime;
    private DateTime dtLookBackTime;
    private integer iBatchSize;
    private integer iCalloutTimeOut;
    
    private static final string OPP_TYPE = 'Deal Registration';
    
    //Constructor accepting next execution time in minutes and the lookback time
    public DR_OPPREG_SAP_SYNC_Batch(){
        system.debug('********Begin: Constructor: DR_OPPREG_SAP_SYNC_Batch()**************');
        try{
            dRecurTime  = DR_SAP_SYNC_Settings__c.getOrgDefaults().BATCHJOB_RECUR__c ; //in minutes
            dLookBackTime  = DR_SAP_SYNC_Settings__c.getOrgDefaults().BATCHJOB_LKBK_TIME__c ; //in minutes
            dBatchSize = DR_SAP_SYNC_Settings__c.getOrgDefaults().BATCHJOB_BATCH_SIZE__c;
            isJobEnabled = DR_SAP_SYNC_Settings__c.getOrgDefaults().BATCHJOB_ENABLE_SCHDULED_JOB__c;
            namedCredentialEndPoint = DR_SAP_SYNC_Settings__c.getOrgDefaults().NamedCredentialEndPoint__c;
            dCalloutTimeOut = DR_SAP_SYNC_Settings__c.getOrgDefaults().CalloutTimeout__c;
            dealRegApprovalProcessPDId = DR_SAP_SYNC_Settings__c.getOrgDefaults().DR_ApprovalProcessDefId__c;

            //set the global variable
            iRecurTime = integer.valueOf(dRecurTime);
            dtLookBackTime = DateTime.now().addMinutes(integer.valueOf(-dLookBackTime));
            iBatchSize = integer.valueOf(dBatchSize);
            iCalloutTimeOut = integer.valueOf(dCalloutTimeOut);
        } catch(Exception ex){
            system.debug('***Value could not be set from parameters, so setting the default lookback to 1 hour and recurrence to every 60 minutes');
            system.debug('***Exception: ' + ex);
            
            //set the default lookback to 1 hour and recurrence to every 30 minutes
            iRecurTime = 30; //30 minutes
            dtLookBackTime = DateTime.now().addHours(-1);
            iBatchSize = 25;
            isJobEnabled = true; //always on for test execution
        }
        
        system.debug('***Value from Settings: dRecurTime (BATCHJOB__RECUR__c) = ' + dRecurTime);
        system.debug('***Value from Settings: dLookBackTime (BATCHJOB_LKBK_TIME__c) = ' + dLookBackTime);
        system.debug('***Value from Settings: dBatchSize (BATCHJOB_BATCH_SIZE__c) = ' + iBatchSize);
        system.debug('***Value from Settings: isJobEnabled (BATCHJOB_ENABLE_SCHDULED_JOB__c) = ' + isJobEnabled);
        
        system.debug('***Value set to iRecurTime = ' + iRecurTime);
        system.debug('***Value set to dtLookBackTime = ' + dtLookBackTime);
        system.debug('***Value set to iBatchSize = ' + iBatchSize);
        system.debug('********End: Constructor: DR_OPPREG_SAP_SYNC_Batch()**************');
    }
    
    //Schedulable interface method implementation. 
    //When you schedule the class DR_OPPREG_SAP_SYNC_Batch to run at a specific interval, it will run the this execute method which in turn will call the batch apex methods
    public void execute(SchedulableContext sc){
        
        //Run the code if the Job is enabled else abort the job
        //--------------------------------------------------------------------------------------------
        if (isJobEnabled){
            system.debug('---------Start: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
            //Invoke the batch job
            DR_OPPREG_SAP_SYNC_Batch oDR_OPPREG_SAP_SYNC_Batch = new DR_OPPREG_SAP_SYNC_Batch();
            database.executeBatch(oDR_OPPREG_SAP_SYNC_Batch, iBatchSize);
            system.debug('---------End: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
        
            //------------------Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
            system.debug('------------------Start: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
            DateTime nextScheduleTime = system.now().addMinutes(iRecurTime);
            string minute = string.valueof(nextScheduleTime.minute());
            string second = string.valueof(nextScheduleTime.second ());
            string cronValue = second + ' ' + minute + ' * * * ?' ;
            string jobName = 'DR_OPPREG_SAP_SYNC_Batch - ' + nextScheduleTime.format('hh:mm');
     
            DR_OPPREG_SAP_SYNC_Batch oSchCls = new DR_OPPREG_SAP_SYNC_Batch();
            system.schedule(jobName, cronValue , oSchCls);
     
            system.debug('------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
            
            // this section of code will abort the current schedule job
            system.abortJob(sc.getTriggerId());
            //------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
            
        }else{
            //---------------------Abort the Job. Need to restart the job manually--------------------------------------
            system.debug('***Abrorting the Job as the Flag DR_SAP_SYNC_Settings__c.getOrgDefaults().BATCHJOB_ENABLE_SCHDULED_JOB__c is set to Off');
            system.debug('***Admin has to set this flag to true in custom settings and run the following script in developer console');
            system.debug('DR_OPPREG_SAP_SYNC_Batch p = new DR_OPPREG_SAP_SYNC_Batch()');
            system.debug('system.schedule(\'Exec of DR_OPPREG_SAP_SYNC_Batch\', \'0 2 * ? * *\' , p)');
            
            system.abortJob(sc.getTriggerId());
            //---------------------End: Abort the Job. Need to schdeule the job manually--------------------------------------
        }
        
    }

    //*************************************************************************************************************************
    //  BATCH METHODs
    //*************************************************************************************************************************
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('*******Enters Batch Start Method');
        system.debug('***dtLookBackTime: ' + dtLookBackTime);
        //And (isClosed = false or (isClosed = True And IsWon = True)) //No Closed Lost Deal Regs
        return Database.getQueryLocator([   Select Id, Lead_Id_For_Opportunity__c, Opportunity_Number__c, NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c, 
                                                DR_Expiration_Date__c, DR_Deal_Status__c, Account.SAP_Customer_Number__c, IsClosed, IsWon, 
                                                (Select Opp_Line_Number__c, Base_SKU__c, Term__c, Quantity From OpportunityLineItems Where Base_SKU__c != null) 
                                            From Opportunity
                                            Where Type = :OPP_TYPE
                                            And Amount > 0
                                            And LastModifiedDate >= :dtLookBackTime
                                        ]);
    }

    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('---------Entering Batch Job execute method-------------------');
        list<DR_OPPREG_SAP_SYNC_Wrapper.CALLOUT_RESPONSE> lstOppRegSyncResponses = new list<DR_OPPREG_SAP_SYNC_Wrapper.CALLOUT_RESPONSE>();
        if (scope != null && !scope.isEmpty()){
            try{
                list<Opportunity> lstOppRegs = (List<Opportunity>) scope;
                system.debug('***lstOppRegs > ' + lstOppRegs);
                for (Opportunity oppReg : lstOppRegs){
                    system.debug('oppReg.Opportunity_Number__c > ' + oppReg.Opportunity_Number__c);
                    system.debug('oppReg.NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c > ' + oppReg.NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c);
                    system.debug('oppReg.Account.SAP_Customer_Number__c > ' + oppReg.Account.SAP_Customer_Number__c);
                    system.debug('ppReg.DR_Expiration_Date__c > ' + oppReg.DR_Expiration_Date__c);
                    system.debug('oppReg.DR_Deal_Status__c > ' + oppReg.DR_Deal_Status__c);
                    
                    //Header Information
                    //-----------------------------------------------------------------------------------------------------------------------
                    DR_OPPREG_SAP_SYNC_Wrapper.OPP_HEADER oppHeader = new DR_OPPREG_SAP_SYNC_Wrapper.OPP_HEADER();
                    oppHeader.oId = oppReg.Id; //Id of the Opportunity; not used in the callout but used for error logging
                    oppHeader.Opportunity_ID = oppReg.Opportunity_Number__c; // O-412203, auto generated opportunity number O-{NNNNNN} ;
                    oppHeader.Reseller_ID = oppReg.NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c; //NPN's SAP Customer Number
                    oppHeader.PEC_ID = oppReg.Account.SAP_Customer_Number__c; //End Customer's SAP Customer Number
                    oppHeader.Expiry_Date = DateTime.newInstance(oppReg.DR_Expiration_Date__c, Time.newInstance(0,0,0,0)).format('yyyyMMdd'); //It has to be YYYYMMDD; otherwise SAP throws exception
                    //If the Opp Reg status is either Terminated or Closed Lost then send the status as Inactive otherwise status is Active
                    oppHeader.Status = oppReg.DR_Deal_Status__c.containsIgnoreCase('Terminated') || (oppReg.isClosed == true && oppReg.IsWon == false) ? 'I' : 'A' ; //For Terminated or Closed Lost Opp Regs it is 'I' (Inactive) otherwise 'A' Active
                    //-----------------------------------------------------------------------------------------------------------------------
                    
                    //Opportunity Approvers
                    //-----------------------------------------------------------------------------------------------------------------------
                    list<DR_OPPREG_SAP_SYNC_Wrapper.OPP_APPROVER> lstApprovers = new list<DR_OPPREG_SAP_SYNC_Wrapper.OPP_APPROVER>();
                    list<ProcessInstance> lstPI = new list<ProcessInstance>();
                    //For certain opp reg leads, their may be resubmits after rejection; so get the latest record to check the approval status
                    lstPI = [   Select Id, (Select LastActor.Name, LastActor.Email, CompletedDate, ProcessNodeName From Nodes order by CreatedDate) From ProcessInstance
                                Where TargetObjectId = :oppReg.Lead_Id_For_Opportunity__c 
                                And ProcessDefinitionId = :dealRegApprovalProcessPDId
                                Order by CreatedDate Desc ];
                                
                    if (!lstPI.isEmpty()){
                        list<ProcessInstanceNode> lstPIN = lstPI[0].Nodes;
                        if (!lstPIN.IsEmpty()){
                            //integer i = 1;
                            for (ProcessInstanceNode PIN : lstPIN){
                                DR_OPPREG_SAP_SYNC_Wrapper.OPP_APPROVER drApprover = new DR_OPPREG_SAP_SYNC_Wrapper.OPP_APPROVER();
                                //drApprover.Opportunity_Counter = string.valueOf(i);
                                drApprover.Opportunity_Counter = PIN.ProcessNodeName.abbreviate(50); //ex: 'Channel Admin Approval' or 'Sales Rep Approval';
                                drApprover.Name = PIN.LastActor.Name; //ex: 'Paresh Jena' - Full name of the Approver for the Approval Step
                                drApprover.Email_ID = PIN.LastActor.Email; //ex: 'pjena@nvidia.com' - Email id of the approver
                                drApprover.Approved_On = PIN.CompletedDate.format('yyyyMMdd'); //ex: '20181231' - It has to be YYYYMMDD; otherwise SAP throws exception
                                drApprover.Approved_At = PIN.CompletedDate.format('hhmmss'); //ex: '232558' - It has to be HHMMSS; otherwise SAP throws exception
                                lstApprovers.add(drApprover);
                                //i = i+1;
                            }
                        }
                    }
                    //-----------------------------------------------------------------------------------------------------------------------
                    
                    //Opportunity Line Items
                    //-----------------------------------------------------------------------------------------------------------------------
                    list<OpportunityLineItem> lstOLI = new list<OpportunityLineItem> ();
                    lstOLI = oppReg.OpportunityLineItems;
                    
                    list<DR_OPPREG_SAP_SYNC_Wrapper.OPP_LINEITEM> lstOppLineItems = new list<DR_OPPREG_SAP_SYNC_Wrapper.OPP_LINEITEM>();
                    for (OpportunityLineItem oppRegOLI : lstOLI){
                        DR_OPPREG_SAP_SYNC_Wrapper.OPP_LINEITEM oppLineItem = new DR_OPPREG_SAP_SYNC_Wrapper.OPP_LINEITEM();
                        oppLineItem.Opportunity_Item_No = oppRegOLI.Opp_Line_Number__c; //ex: OLI-412203, auto generated opportunity Line Item Number OLI-{NNNNNN} ;
                        oppLineItem.Material_Number = oppRegOLI.Base_SKU__c;  //ex:'711-DWS022' Base SKU of the Opp Reg Product, if a product has multiple Base SKUs it is set with a ";" separator
                        oppLineItem.Term = oppRegOLI.Term__c; //ex: '12', for Hardware/GRID perpetual SKUs it is set as '00', for SW SKUs it can be 12,24,36,48,60
                        oppLineItem.Quantity = oppRegOLI.Quantity.toPlainString(); //ex: '5.0', quantify at the line item level
                        lstOppLineItems.add(oppLineItem);
                    }
                    //-----------------------------------------------------------------------------------------------------------------------
                    
                    //Make the Callout
                    //-----------------------------------------------------------------------------------------------------------------------
                    system.debug('***Begin Callout for Opportunity Number# ' + oppReg.Opportunity_Number__c + '--------------------');
                    system.debug('***oppHeader = ' + oppHeader);
                    system.debug('***DR Approvers = ' + lstApprovers);
                    system.debug('***opp Line Items = ' + lstOppLineItems);
                    DR_OPPREG_SAP_SYNC_Wrapper.CALLOUT_RESPONSE calloutResponse = DR_OPPREG_SAP_SYNC_Wrapper.callout_syncOppRegDataToSAP(oppHeader, lstApprovers, lstOppLineItems, namedCredentialEndPoint, iCalloutTimeOut);
                    system.debug('***calloutResponse: ' + calloutResponse);
                    system.debug('***End Callout for Opportunity Number# ' + oppReg.Opportunity_Number__c + '--------------------');
                    
                    //add the respoinses to the list
                    lstOppRegSyncResponses.add(calloutResponse);
                    
                    //-----------------------------------------------------------------------------------------------------------------------
                }

            } catch(Exception ex){
                DR_OPPREG_SAP_SYNC_Wrapper.CALLOUT_RESPONSE errorResponse = new DR_OPPREG_SAP_SYNC_Wrapper.CALLOUT_RESPONSE();
                errorResponse.IsSFDCError = true;
                errorResponse.RETURN_SDFCExceptionName = ex.getMessage();
                errorResponse.RETURN_SDFCExceptionMsg = ex.getStackTraceString();
                lstOppRegSyncResponses.add(errorResponse);
                system.debug('***exception: ' + ex);
            }
            
            //push the sync status to Opportunity_SAP_Integration_Status__c
            if (!lstOppRegSyncResponses.isEmpty()){
                list<Opportunity_SAP_Integration_Status__c> lstSAPIntegrationStatus = new list<Opportunity_SAP_Integration_Status__c>();
                for (DR_OPPREG_SAP_SYNC_Wrapper.CALLOUT_RESPONSE calloutResponse : lstOppRegSyncResponses){
                    
                    Opportunity_SAP_Integration_Status__c oIntegrationSatus = new Opportunity_SAP_Integration_Status__c();
                    oIntegrationSatus.IsSFDCError__c = (calloutResponse.IsSFDCError == true ? true : false) ;
                    oIntegrationSatus.SDFCExceptionName__c = calloutResponse.RETURN_SDFCExceptionName;
                    oIntegrationSatus.SDFCExceptionMsg__c = calloutResponse.RETURN_SDFCExceptionMsg;
                    oIntegrationSatus.OpportunityId__c = calloutResponse.subjectId;
                    oIntegrationSatus.Return_Type__c = calloutResponse.RETURN_TYPE;
                    oIntegrationSatus.Return_Code__c = calloutResponse.RETURN_CODE;
                    oIntegrationSatus.Return_Message__c = calloutResponse.RETURN_MESSAGE;
                    
                    lstSAPIntegrationStatus.add(oIntegrationSatus);
                    
                }
                
                database.insert(lstSAPIntegrationStatus, false);
            }
            //end: push the sync status to Opportunity_SAP_Integration_Status__c
            
        }
        system.debug('---------Exiting Batch Job execute method-------------------');
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('---------Entering Batch Job finish method-------------------');
        
        system.debug('---------Exiting Batch Job finish method-------------------');
    }
    
    //*************************************************************************************************************************
    //  End: BATCH METHODs
    //*************************************************************************************************************************
}