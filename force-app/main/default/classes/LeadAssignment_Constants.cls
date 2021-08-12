/*
 * Author: Manideep
 * Description: This class contains all Constants used in all related classes of Lead Assignment Service.
                Used in 'Lead_tgr_cls.cls', 'LeadAssignmentService.cls' and 'LeadAssignmentServiceTest.cls'.
 * Code Coverage for this class is in "leadAssignmentServiceTest.cls".
 
 Changes:    
 * 09/20/2018 : @Manideep - Account's field "Account Class" values 'GRID Lighthouse Account', 'Tesla Lighthouse Account',
                            'DGX Lighthouse Account' are inactivated by the Admin sometime back and replaced them
                            with the new value 'Lighthouse Account' found this issue and updated the same in the code.
 * 11/21/2018 : @Manideep - Individual Country Routing with Industry.
 * 02/14/2020 : @Manideep - Adding new Lead Status '6QL' to the Routing process.
 * 03/31/2020 : @Manideep - SDS-2104: Remove APAC LSID and NPN Nurture Routing Rules.
 * 07/14/2020 : @Manideep - SDS-2049: Reorder 'VGPU' Rules to the top.  
 * 07/14/2020 : @Manideep - SDS-2276: Automotive Lead Routing basing on Product Type 'Automotive'.
 * 07/14/2020 : @Manideep - SDS-2277: Embedded Lead Routing basing on Product Type 'Embedded'.
 * 07/14/2020 : @Manideep - SDS-2278: Replace the Lead Routing based on 'Enterprise Segment' to 'Product Type'.
                            (But left the existing Enterprise Segment based rules as is in the code but deactivated in the custom setting, 
                             so if needed those can be turned back ON easily by simply reactivating or by adding the rows in the custom setting)
 
 *** 02/04/2021: @Manideep - SDS-2795: This Class is ready to Delete, so commenting out as of now because unable to delete due to failures in other test classes in the Org. ***
*/
public class LeadAssignment_Constants {
   
   /*
   // Marketo & !SvcDeploy Users    
   public static final string MKT_OWNER = 'Marketo Sync';
   public static final string svcDeploy_User = '!svcdeploy';
   
   // Lead Status values
   public static final string LEAD_STATUS_MQ = 'Marketing Qualified';       // Leads those qualified through some Scoring method either by the LeadSpace/Marketo  
   public static final string LEAD_STATUS_RC = 'Request Contact';           // Leads those came through Contact Support page on the Portal 
   public static final string LEAD_STATUS_6QL = '6QL';                      // 6Sense Qualifying Lead
   public static final string LEAD_STATUS_AQ = 'Analytics Qualified';
   
   // Picklist values of Account Class field on Lead
   public static final string ACCOUNT_CLASS_NAMED = 'Named Account';
   //public static final string ACCOUNT_CLASS_GRID = 'GRID Lighthouse Account';
   //public static final string ACCOUNT_CLASS_TESLA = 'Tesla Lighthouse Account';
   //public static final string ACCOUNT_CLASS_DGX = 'DGX Lighthouse Account';
   public static final string ACCOUNT_CLASS_LIGHTHOUSE = 'Lighthouse Account';
   public static final string ACCOUNT_CLASS_GENERAL = 'General Account';
   
   // Picklist values of Region field on Lead
   public static final string Region_NALA = 'NALA';
   public static final string Region_EMEAI = 'EMEAI';
   public static final string Region_APAC = 'APAC';
   
   // Profiles/User License
   public static final string USER_LICENSE_SF = 'Salesforce';
   
   // Custom Setting Category Names: Product Type Region
   public static final string PRD_TYPE_REGION = 'PRD_TYPE_REGION';
   
   // Custom Setting Category Names: EMEA NSC
   public static final string EMEA_NSC = 'EMEA_NSC';
    
   // Custom Setting Category Names: Individual Country Routing
   public static final string IndCtryRouting_NonPrdType = 'ICR_NPT';
   public static final string IndCtryRouting_EntrpSeg = 'ICR_ES';    //Conditions- 1.GPU Virtualization or Professional Visualization 2.Accelerated Computing, High Performance Computing or Deep Learning 3.All Others
   public static final string IndCtryRouting2_EntrpSeg = 'ICR2_ES';  //Conditions- 1.GPU Virtualization or Professional Visualization 2.Accelerated Computing, High Performance Computing or Deep Learning 3.All Others
   public static final string IndCtryRouting3_EntrpSeg = 'ICR3_ES';  //Conditions- 1.GPU Virtualization or Professional Visualization 2.Deep Learning 3.Accelerated Computing & High Performance Computing 4.All Others
      
   // Custom Setting Category Names: Individual Country Routing with Industry
   public static final string IndCtryRouting_Industry = 'ICR_Industry';   
   
   // Custom Setting Category Names: Individual Country Routing with States and vGPU
   public static final string IndCtryRouting_States_EntrpSeg_vGPU = 'ICR_States_ES_vGPU';  //Conditions- 1.Professional Visualization or GPU Virtualization 
   
   // Custom Setting Category Names: Individual Country Routing with vGPU
   public static final string IndCtryRouting_Country_EntrpSeg_vGPU = 'ICR_Country_ES_vGPU';  //Conditions- 1.Professional Visualization or GPU Virtualization
   
   // Custom Setting Category Names: Individual Country Routing with States
   public static final string IndCtryRouting_States_EntrpSeg = 'ICR_States_ES';  //Conditions- 1.High Performance Computing or Deep Learning and based on States 3.All Others
   
   // Custom Setting Category Names: Individual Country Routing without States
   public static final string IndCtryRouting_Country_EntrpSeg = 'ICR_Country_ES';  //Conditions- 1.High Performance Computing or Deep Learning and based on States 3.All Others
   
   //-- SDS-2104
    // Custom Setting Categoty Name: NPN Nurture Rules
    public static final string NPN_Nurture = 'NPN_Nurture';
   ---//
   
   // Custom Setting Category Names: Lead Origin Product Type Region
   public static final string LORIGIN_PRD_TYPE_REGION = 'LORIGIN_PRD_TYPE_REGION';
   
   // Custom Setting Category Names: VGPU Product Type and Countries
   public static final string VGPU_PROD_TYPE_REGION_COUNTRY = 'VGPU_PROD_TYPE_REGION_COUNTRY';
   
   // Custom Setting Category Names: Product Type Region
   public static final string PROD_TYPE_REGION_COUNTRY = 'PROD_TYPE_REGION_COUNTRY';
   
   // Custom Setting Category Names: Product Type, Company Type, Region and Country
   public static final string PROD_TYPE_CMPY_TYPE_REGION_COUNTRY = 'PROD_TYPE_CMPY_TYPE_REGION_COUNTRY';
   
   // Custom Setting Category Names: Product Type, Company Type with Region
   public static final string PROD_TYPE_CMPY_TYPE_REGION = 'PROD_TYPE_CMPY_TYPE_REGION';
   
   // Custom Setting Category Name: Default User
   public static final string Default_User = 'Default_User';
   
   // Pre-MQL Custom Setting Region Name: NALA
   public static final string All_Region = 'All_Regions';
   */
   
   // This is a dummy method for the Code Coverage purpose only
   public void ccMethod() {}
         
}