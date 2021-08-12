public with sharing class Constants {

    /* MDF Error Messages */
    
    public static final String FUND_PREFIX = 'sf';
    public static final String ACTIVITY_PREFIX = 'si';
    public static final String ACCRUAL_PROCESS_POSTING = 'A';  
    public static final String ACCRUAL_PROCESS_REVERSAL = 'R';
    public static final String CLAIM_PROCESS_POSTING = 'C';
    public static final String REVERSAL_SCHEDULABLE_NAME = 'Reversal Job '; 
    public static final String POSTING_SCHEDULABLE_NAME = 'Posting Job ';
        
    // Error Strings    
    public static final String CONTACT_DUPLICATE_MDF_ERROR = 'Only one Contact can be designated as the MDF Primary for each Account.  ';   
    public static final String FUND_DATE_ERROR = 'Start Date not within the Budget Period. ' +
                                                 'Please edit the Start Date so that it falls within the Start Date and End Date ' + 
                                                 'designated on the Budget Period related to the Budget of this record.';                                                          
    public static final String ACTIVITY_DATE_ERROR = 'Start Date and/or End Date not within the Fund period.  ' +
                                                     'Please edit the Start Date and/or End Date so that it falls within the Start Date and End Date ' + 
                                                     'designated on the Fund related to this record.';
    public static final String BUDGET_AMT_OVER_PARENT_ERROR = 'Budget amount exceeds available amount in the parent.  ' +
                                                                 'Please edit the amount of this Budget accordingly. ';
    public static final String ACTIVITY_AMT_OVER_BUDGET_ERROR = 'Activity amount exceeds available amount in related Budget.  ' +
                                                                'Please edit the amount of this Activity accordingly. ';
    public static final String WBS_ELEMENT_MESSAGE_TYPE_ERROR = 'Invalid message passed to WBS Element creation interface.  ' +
                                                                'Expecting type MDFMessageWBS.';
    public static final String ACCRUAL_ELEMENT_MESSAGE_TYPE_ERROR = 'Invalid message passed to Accrual posting interface.  ' +
                                                                    'Expecting type MDFMessageAccrual.';    
    public static final String CLAIM_ELEMENT_MESSAGE_TYPE_ERROR = 'Invalid message passed to Claim posting interface.  ' +
                                                                  'Expecting type MDFMessageClaim.';
    public static final String PI_NO_RESPONSE_RECEIVED_ERROR = 'No response received from SAP / Callout errored before receiving a response.';                                                          
    // Budget Record Types 
    public static final String COOP_BUDGET_RT = 'Co-Op Budget';                                                         
    public static final String DISC_GLOBAL_BUDGET_RT = 'Discretionary Global Budget';
    public static final String DISC_REGIONAL_BUDGET_RT = 'Discretionary Regional Budget';
    public static final String DISC_SUB_REGIONAL_BUDGET_RT = 'Discretionary Sub-Regional Budget';
    public static final String OEM_GLOBAL_BUDGET_RT = 'OEM Global Budget';
    public static final String OEM_REGIONAL_BUDGET_RT = 'OEM Regional Budget';
    public static final String OEM_SUB_REGIONAL_BUDGET_RT = 'OEM Sub-Regional Budget';
    // Fund Record Types
    public static final String DISC_FUND_RT = 'Discretionary Fund';
    public static final String FUND_LOCKED_WITH_ACTIVITY_RT = 'Fund Locked with Activities - SYSTEM USE ONLY';
    public static final String FUND_PARTNER_APPROVAL_PROCESS_RT = 'Partner Fund Approval Process - SYSTEM USE ONLY';
    public static final String FUND_PARTNER_APPROVAL_PROCESS_COMPLETED_RT = 'Partner Fund Approval Process Completed - SYSTEM USE ONLY'; // added 12-20-10
    public static final String COOP_FUND_RT = 'Co-Op Fund';
    public static final String COOP_LOCKDOWN_FUND_RT = 'Co-Op Lockdown - SYSTEM USE ONLY';
    public static final String COOP_LOCKDOWN_WITH_ACT_FUND_RT = 'Co-Op Locked with Activities - SYSTEM USE ONLY';
    // Activity Record Types
    public static final String COOP_ACTIVITY_RT = 'Co-Op Activity';
    public static final String COOP_ACTIVITY_LOCKDOWN_RT = 'Co-Op Activity Lock - SYSTEM USE ONLY';
    public static final String COOP_ACTIVITY_COMPLETED_RT = 'Completed Co-Op Activity';
    // Claim Record Types
    public static final String COOP_CLAIM_SUBMISSION_RT = 'Co-Op Claim Submission';
    public static final String COOP_CLAIM_SUBMITTED_RT = 'Submitted Co-Op Claim - SYSTEM USE ONLY';
    // Account Record Types
    public static final String ACC_MDF_RT = 'MDF Account';
    // Fund Statuses
    public static final String FUND_CREATE_WBS_STATUS = 'WBS Creation in SAP';
    public static final String FUND_WBS_ERROR_STATUS = 'WBS Element Creation Error';
    public static final String FUND_CREATED_STATUS = 'Created';
    public static final String FUND_APPROVED_STATUS = 'Fund Approved';
    public static final String FUND_PARTNER_ACCEPTED = 'Accepted by Partner';
    public static final String FUND_PARTNER_REJECTED = 'Fund Rejected by Partner';
    public static final String FUND_NVIDIA_REJECTED = 'Fund Rejected by Nvidia';
    public static final String FUND_MDF_ADMIN_REJECTED = 'Fund Rejected by MDF Admin';
    public static final String FUND_PENDING_APPROVAL = 'Fund Pending Nvidia Approval';
    public static final String FUND_SENT_FOR_PARTNER_APPROVAL = 'Sent to Partner for Approval';
    public static final String FUND_RELEASED_TO_PARTNER = 'Released to Partner';
    //Rohit
    public static final String FUND_SUBMITTED = 'Submitted for Approval';
    public static final String FUND_SUBMITTED_TO_NVIDIA = 'Submitted to Nvidia';
    public static final String FUND_UNDER_NEGO = 'Submitted for Approval - Under Nego.';
    public static final String FUND_ACCRUED = 'Accrued';
    // Activity Statuses
    public static final String ACTIVITY_CREATED_STATUS = 'Created';
    public static final String ACTIVITY_CREATE_WBS_STATUS = 'WBS Creation in SAP';
    public static final String ACTIVITY_REJECTED_STATUS = 'Rejected by Nvidia';
    public static final String ACTIVITY_PARTNER_REJECTED = 'Rejected by Partner';
    public static final String ACTIVITY_APPROVED_STATUS = 'Initiative Approved';
    public static final String ACTIVITY_CLAIM_READY_STATUS = 'Ready for Claims';
    public static final String ACTIVITY_WBS_ERROR_STATUS = 'WBS Element Creation Error';
    public static final String ACTIVITY_ACCRUAL_ERROR_STATUS = 'Accrual Posting Error';
    public static final String ACTIVITY_REVERSAL_STATUS = 'Reversal of Accrual';
    public static final String ACTIVITY_ACCRUAL_TO_SAP_STATUS = 'Accrual Submitted to SAP';
    public static final String ACTIVITY_EXPIRED_STATUS = 'Expired';
    //Rohit
    public static final String ACTIVITY_SUBMITTED_TO_NVIDIA = 'Submitted to Nvidia';
    public static final String ACTIVITY_ACCRUED = 'Activity Accrued';

    // Claim Statuses
    public static final String CLAIM_SENT_TO_SAP_STATUS  = 'Claim Sent to SAP';
    public static final String CLAIM_REJECTED_STATUS  = 'Claim Rejected';                                                                                                    
    public static final String CLAIM_APPROVED_STATUS  = 'Claim Posted for Payment';
    public static final String CLAIM_ERROR_STATUS  = 'Claim Posting Error';
    public static final String CLAIM_PAID_STATUS  = 'Claim Paid';
    public static final String CLAIM_SUBMITTED_FOR_APPROVAL = 'Claim Submitted for Approval';
    public static final String CLAIM_SUBMITTED_TO_NVIDIA = 'Claim Submitted to Nvidia';
    public static final String CLAIM_APPROVED = 'Claim Approved';
    public static final String CLAIM_CREATED = 'Claim Created';

    
    // Integration Error Web Service Call
    public static final String WS_CALL_CREATE_WBS_ELEMENT = 'Create WBS Element';
    public static final String WS_CALL_ACCRUAL = 'Accrual';
    public static final String WS_CALL_REVERSE_ACCRUAL = 'Reverse Accrual';
    public static final String WS_CALL_COOP_CLAIM = 'Coop Claim';
    public static final String WS_CALL_COOP_CLAIM_REVERSE_ACCRUAL = 'CO-OP Reversal';
    public static final String WS_CALL_CLAIM_POSTING = 'Claim Posting';
    

    // Custom Setting Names
    public static final String CLAIM_EXPIRY = 'ClaimExpiry';
    public static final String PARTNER_ACCEPT_PERIOD = 'PartnerAcceptancePeriod';
    
    // Number constants
    public static final Integer DEFAULT_CLAIM_EXPIRY = 90;
    //ROhit
    public static final Integer DEFAULT_PARTNER_ACCEPT_PERIOD = 30;  //30;
    
    // Recursive trigger firing
    public static Boolean IN_FUTURE_CALLOUT_TO_SAP = false; // prevents firing a future method from within a future method
    public static Boolean FIRE_WBS_UPDATE = false; // overrides recursive flags so WBS Elements can be updated no matter what
    public static Boolean Fund_AddApproversToFundRunning = false; // prevents Claim_AddApproversToClaim from firing when Fund_AddApproversToFund updates claims;
    public static Boolean IN_CLAIM_PAID_TRIGGER = false;  // prevents firing of itself and 11 other triggers when activity and fund atatus are updated to "Completed" 
    
    //User Profile
    public static final String SYSTEM_ADMINISTRATOR_PROFILE  = 'System Administrator';
    
    //MDF TYPE
    public static final String FUND_TYPE_QPB  = 'QPB';
    public static final String FUND_TYPE_LASER  = 'Laser'; 
    //Claim Type
    public static final String CO_OP = 'Co-Op'; 
}