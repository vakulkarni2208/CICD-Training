/**
 *  @name           :   NV_NPN_TestDataFactory
 *  @description    :   This class is used to insert all the custom settings' data for test methods.
                        These custom settings are mostly related to NPN portal
 *  @author         :   rkamble
 */

@isTest
public class NV_NPN_TestDataFactory {

    public static void setupCustomSettings(){


        /************************ Lite_Portal_Competency__c Starts*****************************/
        list<Lite_Portal_Competency__c> listLite_Portal_Competency= new list<Lite_Portal_Competency__c> ();

        Lite_Portal_Competency__c Li1= new Lite_Portal_Competency__c ();
        Li1.name= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        Li1.ask_a_question_recipients__c= 'pjena@nvidia.com.invalid';
        Li1.log_a_support_request_recipients__c= 'pjena@nvidia.com.invalid';

        listLite_Portal_Competency.add(Li1);
        Lite_Portal_Competency__c Li2= new Lite_Portal_Competency__c ();
        Li2.name= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        Li2.ask_a_question_recipients__c= 'pjena@nvidia.com.invalid';
        Li2.log_a_support_request_recipients__c= 'pjena@nvidia.com.invalid';

        listLite_Portal_Competency.add(Li2);
        Lite_Portal_Competency__c Li3= new Lite_Portal_Competency__c ();
        Li3.name= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        Li3.ask_a_question_recipients__c= 'pjena@nvidia.com.invalid';
        Li3.log_a_support_request_recipients__c= 'pjena@nvidia.com.invalid';

        listLite_Portal_Competency.add(Li3);
        Lite_Portal_Competency__c Li4= new Lite_Portal_Competency__c ();
        Li4.name= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        Li4.ask_a_question_recipients__c= 'pjena@nvidia.com.invalid';
        Li4.log_a_support_request_recipients__c= 'pjena@nvidia.com.invalid';

        listLite_Portal_Competency.add(Li4);

        insert listLite_Portal_Competency;
        /************************ Lite_Portal_Competency__c Ends*****************************/

        /************************ NPN_Onboarding_GPU_Genius_Map__c Starts*****************************/
        list<NPN_Onboarding_GPU_Genius_Map__c> listNPN_Onboarding_GPU_Genius_Map= new list<NPN_Onboarding_GPU_Genius_Map__c> ();
        NPN_Onboarding_GPU_Genius_Map__c NPG1= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG1.name= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NPG1.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NPG1.gpu_genius_group__c= COMM_Constants.CON_GPUGNS_GRP_LTPP;
        NPG1.role__c= null;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG1);
        NPN_Onboarding_GPU_Genius_Map__c NPG2= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG2.name= 'Tesla Sales';
        NPG2.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NPG2.gpu_genius_group__c= 'NPN Tesla Sales:5642753';
        NPG2.role__c= COMM_Constants.PROFILE_CATEGORY_SALES;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG2);
        NPN_Onboarding_GPU_Genius_Map__c NPG3= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG3.name= 'Tesla Technical';
        NPG3.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NPG3.gpu_genius_group__c= 'NPN Tesla Technical:5642754';
        NPG3.role__c= COMM_Constants.PROFILE_CATEGORY_TECHNICAL;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG3);
        NPN_Onboarding_GPU_Genius_Map__c NPG4= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG4.name= 'DL';
        NPG4.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NPG4.gpu_genius_group__c= 'Learning Deep Learning:5753092';
        NPG4.role__c= null;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG4);
        NPN_Onboarding_GPU_Genius_Map__c NPG5= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG5.name= 'DL Sales';
        NPG5.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NPG5.gpu_genius_group__c= 'NPN Deep Learning Sales:5765886';
        NPG5.role__c= COMM_Constants.PROFILE_CATEGORY_SALES;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG5);
        NPN_Onboarding_GPU_Genius_Map__c NPG6= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG6.name= 'DL Technical';
        NPG6.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NPG6.gpu_genius_group__c= 'NPN Deep Learning Technical:5765889';
        NPG6.role__c= COMM_Constants.PROFILE_CATEGORY_TECHNICAL;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG6);
        NPN_Onboarding_GPU_Genius_Map__c NPG7= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG7.name= 'GV';
        NPG7.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NPG7.gpu_genius_group__c= COMM_Constants.CON_GPUGNS_GRP_LGRD;
        NPG7.role__c= null;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG7);
        NPN_Onboarding_GPU_Genius_Map__c NPG8= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG8.name= 'GV Sales';
        NPG8.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NPG8.gpu_genius_group__c= 'NPN GPU Virtualization Sales:5642755';
        NPG8.role__c= COMM_Constants.PROFILE_CATEGORY_SALES;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG8);
        NPN_Onboarding_GPU_Genius_Map__c NPG9= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG9.name= 'GV Technical';
        NPG9.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NPG9.gpu_genius_group__c= 'NPN GPU Virtualization Technical:5642756';
        NPG9.role__c= COMM_Constants.PROFILE_CATEGORY_TECHNICAL;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG9);
        NPN_Onboarding_GPU_Genius_Map__c NPG10= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG10.name= 'PV';
        NPG10.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NPG10.gpu_genius_group__c= COMM_Constants.CON_GPUGNS_GRP_LQDRO;
        NPG10.role__c= null;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG10);
        NPN_Onboarding_GPU_Genius_Map__c NPG11= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG11.name= 'PV Sales';
        NPG11.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NPG11.gpu_genius_group__c= COMM_Constants.CON_GPUGNS_GRP_LNPNPVS;
        NPG11.role__c= COMM_Constants.PROFILE_CATEGORY_SALES;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG11);
        NPN_Onboarding_GPU_Genius_Map__c NPG12= new NPN_Onboarding_GPU_Genius_Map__c ();
        NPG12.name= 'PV Technical';
        NPG12.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NPG12.gpu_genius_group__c= COMM_Constants.CON_GPUGNS_GRP_LNPNPVT;
        NPG12.role__c= COMM_Constants.PROFILE_CATEGORY_TECHNICAL;

        listNPN_Onboarding_GPU_Genius_Map.add(NPG12);


        insert listNPN_Onboarding_GPU_Genius_Map;

        /************************ NPN_Onboarding_GPU_Genius_Map__c Ends*****************************/

        /************************ NPN_Competency_Permissions_Group_Map__c Starts*****************************/

        list<NPN_Competency_Permissions_Group_Map__c> listNCPGMN_Competency_Permissions_Group_Map= new list<NPN_Competency_Permissions_Group_Map__c> ();

        NPN_Competency_Permissions_Group_Map__c NCPGM3= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM3.name= 'POS for Compliance Tab';
        NCPGM3.competency__c= null;
        NCPGM3.permissions_and_group__c= 'NPN Compliance Tab';
        NCPGM3.program_level__c= null;
        NCPGM3.program_type__c= null;
        NCPGM3.sub_program_type__c= null;
        NCPGM3.role__c= 'POS';

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM3);
        NPN_Competency_Permissions_Group_Map__c NCPGM4= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM4.name= 'POS';
        NCPGM4.competency__c= null;
        NCPGM4.permissions_and_group__c= 'Submit POS';
        NCPGM4.program_level__c= null;
        NCPGM4.program_type__c= null;
        NCPGM4.sub_program_type__c= null;
        NCPGM4.role__c= 'POS';

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM4);
        NPN_Competency_Permissions_Group_Map__c NCPGM5= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM5.name= 'Partner Primary Contact';
        NCPGM5.competency__c= null;
        NCPGM5.permissions_and_group__c= 'NPN Compliance Tab';
        NCPGM5.program_level__c= null;
        NCPGM5.program_type__c= null;
        NCPGM5.sub_program_type__c= null;
        NCPGM5.role__c= 'Partner Primary Contact';

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM5);
        NPN_Competency_Permissions_Group_Map__c NCPGM6= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM6.name= 'SIP_PV_E';
        NCPGM6.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NCPGM6.permissions_and_group__c= 'SIP Professional Visualization Elite';
        NCPGM6.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM6.program_type__c= COMM_Constants.PA_PROGRAM_SIP;
        NCPGM6.sub_program_type__c= null;
        NCPGM6.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM6);
        NPN_Competency_Permissions_Group_Map__c NCPGM7= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM7.name= 'PV_SP_P';
        NCPGM7.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NCPGM7.permissions_and_group__c= 'SP Professional Visualization Preferred';
        NCPGM7.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM7.program_type__c= COMM_Constants.PA_PROGRAM_SP;
        NCPGM7.sub_program_type__c= null;
        NCPGM7.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM7);
        NPN_Competency_Permissions_Group_Map__c NCPGM8= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM8.name= 'PV_SP_E';
        NCPGM8.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NCPGM8.permissions_and_group__c= 'SP Professional Visualization Elite';
        NCPGM8.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM8.program_type__c= COMM_Constants.PA_PROGRAM_SP;
        NCPGM8.sub_program_type__c= null;
        NCPGM8.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM8);
        NPN_Competency_Permissions_Group_Map__c NCPGM9= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM9.name= 'DL_OEM_P';
        NCPGM9.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NCPGM9.permissions_and_group__c= 'OEM Deep Learning Preferred';
        NCPGM9.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM9.program_type__c= COMM_Constants.PA_PROGRAM_OEM;
        NCPGM9.sub_program_type__c= null;
        NCPGM9.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM9);
        NPN_Competency_Permissions_Group_Map__c NCPGM10= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM10.name= 'DL_SP_P';
        NCPGM10.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NCPGM10.permissions_and_group__c= 'SP Deep Learning Preferred';
        NCPGM10.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM10.program_type__c= COMM_Constants.PA_PROGRAM_SP;
        NCPGM10.sub_program_type__c= null;
        NCPGM10.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM10);
        NPN_Competency_Permissions_Group_Map__c NCPGM11= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM11.name= 'GV_SP_P';
        NCPGM11.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NCPGM11.permissions_and_group__c= 'SP GPU Virtualization Preferred';
        NCPGM11.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM11.program_type__c= COMM_Constants.PA_PROGRAM_SP;
        NCPGM11.sub_program_type__c= null;
        NCPGM11.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM11);
        NPN_Competency_Permissions_Group_Map__c NCPGM12= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM12.name= 'Tesla_OEM_E';
        NCPGM12.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM12.permissions_and_group__c= 'OEM Tesla Elite';
        NCPGM12.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM12.program_type__c= COMM_Constants.PA_PROGRAM_OEM;
        NCPGM12.sub_program_type__c= null;
        NCPGM12.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM12);
        NPN_Competency_Permissions_Group_Map__c NCPGM13= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM13.name= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM13.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM13.permissions_and_group__c= 'Tesla Leads & Opportunities';
        NCPGM13.program_level__c= null;
        NCPGM13.program_type__c= null;
        NCPGM13.sub_program_type__c= null;
        NCPGM13.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM13);
        NPN_Competency_Permissions_Group_Map__c NCPGM14= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM14.name= 'Tesla_OEM_P';
        NCPGM14.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM14.permissions_and_group__c= 'OEM Tesla Preferred';
        NCPGM14.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM14.program_type__c= COMM_Constants.PA_PROGRAM_OEM;
        NCPGM14.sub_program_type__c= null;
        NCPGM14.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM14);
        NPN_Competency_Permissions_Group_Map__c NCPGM15= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM15.name= 'GV_SP_E';
        NCPGM15.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NCPGM15.permissions_and_group__c= 'SP GPU Virtualization Elite';
        NCPGM15.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM15.program_type__c= COMM_Constants.PA_PROGRAM_SP;
        NCPGM15.sub_program_type__c= null;
        NCPGM15.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM15);
        NPN_Competency_Permissions_Group_Map__c NCPGM16= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM16.name= 'PV';
        NCPGM16.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NCPGM16.permissions_and_group__c= 'PV Leads & Opportunities';
        NCPGM16.program_level__c= null;
        NCPGM16.program_type__c= null;
        NCPGM16.sub_program_type__c= null;
        NCPGM16.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM16);
        NPN_Competency_Permissions_Group_Map__c NCPGM17= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM17.name= 'GV';
        NCPGM17.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NCPGM17.permissions_and_group__c= 'GV Leads & Opportunities';
        NCPGM17.program_level__c= null;
        NCPGM17.program_type__c= null;
        NCPGM17.sub_program_type__c= null;
        NCPGM17.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM17);
        NPN_Competency_Permissions_Group_Map__c NCPGM18= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM18.name= 'Tesla_SP_P';
        NCPGM18.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM18.permissions_and_group__c= 'SP Tesla Preferred';
        NCPGM18.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM18.program_type__c= COMM_Constants.PA_PROGRAM_SP;
        NCPGM18.sub_program_type__c= null;
        NCPGM18.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM18);
        NPN_Competency_Permissions_Group_Map__c NCPGM19= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM19.name= 'GV_OEM_P';
        NCPGM19.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NCPGM19.permissions_and_group__c= 'OEM GPU Virtualization Preferred';
        NCPGM19.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM19.program_type__c= COMM_Constants.PA_PROGRAM_OEM;
        NCPGM19.sub_program_type__c= null;
        NCPGM19.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM19);
        NPN_Competency_Permissions_Group_Map__c NCPGM20= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM20.name= 'DL';
        NCPGM20.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NCPGM20.permissions_and_group__c= 'DL Leads & Opportunities';
        NCPGM20.program_level__c= null;
        NCPGM20.program_type__c= null;
        NCPGM20.sub_program_type__c= null;
        NCPGM20.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM20);
        NPN_Competency_Permissions_Group_Map__c NCPGM21= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM21.name= 'DL_OEM_E';
        NCPGM21.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NCPGM21.permissions_and_group__c= 'OEM Deep Learning Elite';
        NCPGM21.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM21.program_type__c= COMM_Constants.PA_PROGRAM_OEM;
        NCPGM21.sub_program_type__c= null;
        NCPGM21.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM21);
        NPN_Competency_Permissions_Group_Map__c NCPGM22= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM22.name= 'GV_OEM_E';
        NCPGM22.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NCPGM22.permissions_and_group__c= 'OEM GPU Virtualization Elite';
        NCPGM22.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM22.program_type__c= COMM_Constants.PA_PROGRAM_OEM;
        NCPGM22.sub_program_type__c= null;
        NCPGM22.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM22);
        NPN_Competency_Permissions_Group_Map__c NCPGM23= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM23.name= 'Tesla_SP_E';
        NCPGM23.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM23.permissions_and_group__c= 'SP Tesla Elite';
        NCPGM23.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM23.program_type__c= COMM_Constants.PA_PROGRAM_SP;
        NCPGM23.sub_program_type__c= null;
        NCPGM23.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM23);
        NPN_Competency_Permissions_Group_Map__c NCPGM24= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM24.name= 'DL_SP_E';
        NCPGM24.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NCPGM24.permissions_and_group__c= 'SP Deep Learning Elite';
        NCPGM24.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM24.program_type__c= COMM_Constants.PA_PROGRAM_SP;
        NCPGM24.sub_program_type__c= null;
        NCPGM24.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM24);
        NPN_Competency_Permissions_Group_Map__c NCPGM25= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM25.name= 'PV_OEM_P';
        NCPGM25.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NCPGM25.permissions_and_group__c= 'OEM Professional Visualization Preferred';
        NCPGM25.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM25.program_type__c= COMM_Constants.PA_PROGRAM_OEM;
        NCPGM25.sub_program_type__c= null;
        NCPGM25.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM25);
        NPN_Competency_Permissions_Group_Map__c NCPGM26= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM26.name= 'PV_OEM_E';
        NCPGM26.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NCPGM26.permissions_and_group__c= 'OEM Professional Visualization Elite';
        NCPGM26.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM26.program_type__c= COMM_Constants.PA_PROGRAM_OEM;
        NCPGM26.sub_program_type__c= null;
        NCPGM26.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM26);
        NPN_Competency_Permissions_Group_Map__c NCPGM27= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM27.name= 'SIP_Tesla_P';
        NCPGM27.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM27.permissions_and_group__c= 'SIP Tesla Preferred';
        NCPGM27.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM27.program_type__c= COMM_Constants.PA_PROGRAM_SIP;
        NCPGM27.sub_program_type__c= null;
        NCPGM27.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM27);
        NPN_Competency_Permissions_Group_Map__c NCPGM28= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM28.name= 'DL_SA_E';
        NCPGM28.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NCPGM28.permissions_and_group__c= 'SA Deep Learning Elite';
        NCPGM28.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM28.program_type__c= COMM_Constants.PA_PROGRAM_SA;
        NCPGM28.sub_program_type__c= null;
        NCPGM28.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM28);
        NPN_Competency_Permissions_Group_Map__c NCPGM29= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM29.name= 'DL_SA_P';
        NCPGM29.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NCPGM29.permissions_and_group__c= 'SA Deep Learning Preferred';
        NCPGM29.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM29.program_type__c= COMM_Constants.PA_PROGRAM_SA;
        NCPGM29.sub_program_type__c= null;
        NCPGM29.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM29);
        NPN_Competency_Permissions_Group_Map__c NCPGM30= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM30.name= 'GV_CSP_E';
        NCPGM30.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NCPGM30.permissions_and_group__c= 'CSP GPU Virtualization Elite';
        NCPGM30.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM30.program_type__c= COMM_Constants.PA_PROGRAM_CSP;
        NCPGM30.sub_program_type__c= null;
        NCPGM30.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM30);
        NPN_Competency_Permissions_Group_Map__c NCPGM31= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM31.name= 'GV_CSP_P';
        NCPGM31.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NCPGM31.permissions_and_group__c= 'CSP GPU Virtualization Preferred';
        NCPGM31.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM31.program_type__c= COMM_Constants.PA_PROGRAM_CSP;
        NCPGM31.sub_program_type__c= null;
        NCPGM31.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM31);
        NPN_Competency_Permissions_Group_Map__c NCPGM32= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM32.name= 'GV_SA_E';
        NCPGM32.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NCPGM32.permissions_and_group__c= 'SA GPU Virtualization Elite';
        NCPGM32.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM32.program_type__c= COMM_Constants.PA_PROGRAM_SA;
        NCPGM32.sub_program_type__c= null;
        NCPGM32.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM32);
        NPN_Competency_Permissions_Group_Map__c NCPGM33= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM33.name= 'GV_SA_P';
        NCPGM33.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NCPGM33.permissions_and_group__c= 'SA GPU Virtualization Preferred';
        NCPGM33.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM33.program_type__c= COMM_Constants.PA_PROGRAM_SA;
        NCPGM33.sub_program_type__c= null;
        NCPGM33.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM33);
        NPN_Competency_Permissions_Group_Map__c NCPGM34= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM34.name= 'Tesla_SA_E';
        NCPGM34.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM34.permissions_and_group__c= 'SA Tesla Elite';
        NCPGM34.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM34.program_type__c= COMM_Constants.PA_PROGRAM_SA;
        NCPGM34.sub_program_type__c= null;
        NCPGM34.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM34);
        NPN_Competency_Permissions_Group_Map__c NCPGM35= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM35.name= 'Tesla_SA_P';
        NCPGM35.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM35.permissions_and_group__c= 'SA Tesla Preferred';
        NCPGM35.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM35.program_type__c= COMM_Constants.PA_PROGRAM_SA;
        NCPGM35.sub_program_type__c= null;
        NCPGM35.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM35);
        NPN_Competency_Permissions_Group_Map__c NCPGM36= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM36.name= 'PV_SA_E';
        NCPGM36.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NCPGM36.permissions_and_group__c= 'SA Professional Visualization Elite';
        NCPGM36.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM36.program_type__c= COMM_Constants.PA_PROGRAM_SA;
        NCPGM36.sub_program_type__c= null;
        NCPGM36.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM36);
        NPN_Competency_Permissions_Group_Map__c NCPGM37= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM37.name= 'PV_SA_P';
        NCPGM37.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NCPGM37.permissions_and_group__c= 'SA Professional Visualization Preferred';
        NCPGM37.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM37.program_type__c= COMM_Constants.PA_PROGRAM_SA;
        NCPGM37.sub_program_type__c= null;
        NCPGM37.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM37);
        NPN_Competency_Permissions_Group_Map__c NCPGM38= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM38.name= COMM_Constants.PA_PROGRAM_SDP;
        NCPGM38.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NCPGM38.permissions_and_group__c= 'SDP Deep Learning Preferred';
        NCPGM38.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM38.program_type__c= COMM_Constants.PA_PROGRAM_SDP;
        NCPGM38.sub_program_type__c= null;
        NCPGM38.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM38);
        NPN_Competency_Permissions_Group_Map__c NCPGM39= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM39.name= 'SIP_Tesla_E';
        NCPGM39.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NCPGM39.permissions_and_group__c= 'SIP Tesla Elite';
        NCPGM39.program_level__c= COMM_Constants.PA_LEVEL_ELITE;
        NCPGM39.program_type__c= COMM_Constants.PA_PROGRAM_SIP;
        NCPGM39.sub_program_type__c= null;
        NCPGM39.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM39);
        NPN_Competency_Permissions_Group_Map__c NCPGM40= new NPN_Competency_Permissions_Group_Map__c ();
        NCPGM40.name= 'SIP_PV_P';
        NCPGM40.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NCPGM40.permissions_and_group__c= 'SIP Professional Visualization Preferred';
        NCPGM40.program_level__c= COMM_Constants.PA_LEVEL_PREF;
        NCPGM40.program_type__c= COMM_Constants.PA_PROGRAM_SIP;
        NCPGM40.sub_program_type__c= null;
        NCPGM40.role__c= null;

        listNCPGMN_Competency_Permissions_Group_Map.add(NCPGM40);

        insert listNCPGMN_Competency_Permissions_Group_Map;

        /************************ NPN_Competency_Permissions_Group_Map__c Ends*****************************/

        /************************ Org_Constants__c Starts*****************************/

        list<Org_Constants__c> listOrg_Constants= new list<Org_Constants__c> ();

        Org_Constants__c Or1= new Org_Constants__c ();
        Or1.name= 'OrgUrl';
        Or1.values__c= 'https://na87.salesforce.com';

        listOrg_Constants.add(Or1);

        Org_Constants__c Or2= new Org_Constants__c ();
        Or2.name= 'Marketing_Search';
        Or2.values__c= 'https://c.na87.visual.force.com/apex/MarketingSearchTool?sfdc.tabName=01r40000000EJ9q';

        listOrg_Constants.add(Or2);
        Org_Constants__c Or3= new Org_Constants__c ();
        Or3.name= 'PRMPortalId';
        Or3.values__c= '06040000000D7uX';

        listOrg_Constants.add(Or3);
        Org_Constants__c Or4= new Org_Constants__c ();
        Or4.name= 'PrmPortalLoginUrl';
        Or4.values__c= 'https://nvidia.secure.force.com/partners';

        listOrg_Constants.add(Or4);
        Org_Constants__c Or5= new Org_Constants__c ();
        Or5.name= 'SAPUrl';
        Or5.values__c= 'https://prdapp1.nvb2b.nvidia.com';

        listOrg_Constants.add(Or5);
        Org_Constants__c Or6= new Org_Constants__c ();
        Or6.name= 'PrmPortalForgotPWDURL';
        Or6.values__c= 'https://nvidia.secure.force.com/partners/apex/ForgotPassword';

        listOrg_Constants.add(Or6);
        Org_Constants__c Or7= new Org_Constants__c ();
        Or7.name= 'Login_Err_Msg';
        Or7.values__c= 'Your login attempt has failed. Make sure your username and password are correct.';

        listOrg_Constants.add(Or7);
        Org_Constants__c Or8= new Org_Constants__c ();
        Or8.name= 'PrmPortalForgotUserNameURL';
        Or8.values__c= 'https://nvidia.secure.force.com/partners/apex/COMM_ForgotUsername';

        listOrg_Constants.add(Or8);
        Org_Constants__c Or9= new Org_Constants__c ();
        Or9.name= 'CommunityForgotPWDURL';
        Or9.values__c= '/apex/NV_ForgotPassword';

        listOrg_Constants.add(Or9);
        Org_Constants__c Or10= new Org_Constants__c ();
        Or10.name= 'CommunityForgotUserNameURL';
        Or10.values__c= '/apex/NV_ForgotUsernamePage';

        listOrg_Constants.add(Or10);
        Org_Constants__c Or11= new Org_Constants__c ();
        Or11.name= 'CommunityLoginURL';
        Or11.values__c= '/NV_PartnerCommunityLogin';

        listOrg_Constants.add(Or11);


        insert listOrg_Constants;

        /************************Org_Constants__c Ends*****************************/

        /************************NV_Permissions_and_PCL_Mapping__c Starts*****************************/
        list<NV_Permissions_and_PCL_Mapping__c> listNV_Permissions_and_PCL_Mapping= new list<NV_Permissions_and_PCL_Mapping__c> ();

        NV_Permissions_and_PCL_Mapping__c NV1= new NV_Permissions_and_PCL_Mapping__c ();
        NV1.name= 'SDPPSDGXPreferred';
        NV1.combination__c= 'SDP PS DGX Preferred';
        NV1.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV1.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV1.program_name__c= COMM_Constants.PA_PROGRAM_SDP;
        NV1.sub_program__c= 'Professional Services';

        listNV_Permissions_and_PCL_Mapping.add(NV1);
        NV_Permissions_and_PCL_Mapping__c NV2= new NV_Permissions_and_PCL_Mapping__c ();
        NV2.name= 'SA DGX Preferred';
        NV2.combination__c= 'SA DGX Preferred';
        NV2.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV2.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV2.program_name__c= COMM_Constants.PA_PROGRAM_SA;
        NV2.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV2);
        NV_Permissions_and_PCL_Mapping__c NV3= new NV_Permissions_and_PCL_Mapping__c ();
        NV3.name= 'SA Quadro Preferred';
        NV3.combination__c= 'SA Quadro Preferred';
        NV3.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        NV3.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV3.program_name__c= COMM_Constants.PA_PROGRAM_SA;
        NV3.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV3);
        NV_Permissions_and_PCL_Mapping__c NV4= new NV_Permissions_and_PCL_Mapping__c ();
        NV4.name= 'SOEM HP Inc Elite';
        NV4.combination__c= 'SOEM HP Inc Elite';
        NV4.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NV4.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV4.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV4.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV4);
        NV_Permissions_and_PCL_Mapping__c NV5= new NV_Permissions_and_PCL_Mapping__c ();
        NV5.name= 'SOEM Portal Lite';
        NV5.combination__c= 'SOEM Portal Lite';
        NV5.competency__c= COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
        NV5.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV5.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV5.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV5);
        NV_Permissions_and_PCL_Mapping__c NV6= new NV_Permissions_and_PCL_Mapping__c ();
        NV6.name= 'SA Tesla Preferred';
        NV6.combination__c= 'SA Tesla Preferred';
        NV6.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV6.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV6.program_name__c= COMM_Constants.PA_PROGRAM_SA;
        NV6.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV6);
        NV_Permissions_and_PCL_Mapping__c NV7= new NV_Permissions_and_PCL_Mapping__c ();
        NV7.name= 'Industry Focus Healthcare';
        NV7.combination__c= 'Industry Focus Healthcare';
        NV7.competency__c= 'Healthcare';
        NV7.level__c= null;
        NV7.program_name__c= 'Industry Focus';
        NV7.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV7);
        NV_Permissions_and_PCL_Mapping__c NV8= new NV_Permissions_and_PCL_Mapping__c ();
        NV8.name= 'CSP Tesla Elite';
        NV8.combination__c= 'CSP Tesla Elite';
        NV8.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV8.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV8.program_name__c= COMM_Constants.PA_PROGRAM_CSP;
        NV8.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV8);
        NV_Permissions_and_PCL_Mapping__c NV9= new NV_Permissions_and_PCL_Mapping__c ();
        NV9.name= 'CSP Tesla Preferred';
        NV9.combination__c= 'CSP Tesla Preferred';
        NV9.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV9.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV9.program_name__c= COMM_Constants.PA_PROGRAM_CSP;
        NV9.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV9);
        NV_Permissions_and_PCL_Mapping__c NV10= new NV_Permissions_and_PCL_Mapping__c ();
        NV10.name= 'SP Tesla Elite';
        NV10.combination__c= 'SP Tesla Elite';
        NV10.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV10.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV10.program_name__c= COMM_Constants.PA_PROGRAM_SP;
        NV10.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV10);
        NV_Permissions_and_PCL_Mapping__c NV11= new NV_Permissions_and_PCL_Mapping__c ();
        NV11.name= 'IP Tesla Preferred';
        NV11.combination__c= 'IP Tesla Preferred';
        NV11.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV11.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV11.program_name__c= COMM_Constants.PA_PROGRAM_IP;
        NV11.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV11);
        NV_Permissions_and_PCL_Mapping__c NV12= new NV_Permissions_and_PCL_Mapping__c ();
        NV12.name= 'SP Quadro Elite';
        NV12.combination__c= 'SP Quadro Elite';
        NV12.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        NV12.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV12.program_name__c= COMM_Constants.PA_PROGRAM_SP;
        NV12.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV12);
        NV_Permissions_and_PCL_Mapping__c NV13= new NV_Permissions_and_PCL_Mapping__c ();
        NV13.name= COMM_Constants.CON_PPG_COMMUNITY;
        NV13.combination__c= COMM_Constants.CON_PPG_COMMUNITY;
        NV13.competency__c= COMM_Constants.CON_PPG_COMMUNITY;
        NV13.level__c= null;
        NV13.program_name__c= COMM_Constants.CON_PPG_COMMUNITY;
        NV13.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV13);
        NV_Permissions_and_PCL_Mapping__c NV14= new NV_Permissions_and_PCL_Mapping__c ();
        NV14.name= 'OEM Tesla Elite';
        NV14.combination__c= 'OEM Tesla Elite';
        NV14.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV14.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV14.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV14.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV14);
        NV_Permissions_and_PCL_Mapping__c NV15= new NV_Permissions_and_PCL_Mapping__c ();
        NV15.name= 'SP vGPU Elite';
        NV15.combination__c= 'SP vGPU Elite';
        NV15.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NV15.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV15.program_name__c= COMM_Constants.PA_PROGRAM_SP;
        NV15.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV15);
        NV_Permissions_and_PCL_Mapping__c NV16= new NV_Permissions_and_PCL_Mapping__c ();
        NV16.name= 'IP Tesla Elite';
        NV16.combination__c= 'IP Tesla Elite';
        NV16.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV16.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV16.program_name__c= COMM_Constants.PA_PROGRAM_IP;
        NV16.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV16);
        NV_Permissions_and_PCL_Mapping__c NV17= new NV_Permissions_and_PCL_Mapping__c ();
        NV17.name= 'SP Tesla Preferred';
        NV17.combination__c= 'SP Tesla Preferred';
        NV17.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV17.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV17.program_name__c= COMM_Constants.PA_PROGRAM_SP;
        NV17.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV17);
        NV_Permissions_and_PCL_Mapping__c NV18= new NV_Permissions_and_PCL_Mapping__c ();
        NV18.name= 'SP vGPU Preferred';
        NV18.combination__c= 'SP vGPU Preferred';
        NV18.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NV18.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV18.program_name__c= COMM_Constants.PA_PROGRAM_SP;
        NV18.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV18);
        NV_Permissions_and_PCL_Mapping__c NV19= new NV_Permissions_and_PCL_Mapping__c ();
        NV19.name= 'OEM Tesla Preferred';
        NV19.combination__c= 'OEM Tesla Preferred';
        NV19.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV19.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV19.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV19.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV19);
        NV_Permissions_and_PCL_Mapping__c NV20= new NV_Permissions_and_PCL_Mapping__c ();
        NV20.name= 'SP Quadro Preferred';
        NV20.combination__c= 'SP Quadro Preferred';
        NV20.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        NV20.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV20.program_name__c= COMM_Constants.PA_PROGRAM_SP;
        NV20.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV20);
        NV_Permissions_and_PCL_Mapping__c NV21= new NV_Permissions_and_PCL_Mapping__c ();
        NV21.name= 'DISTI Tesla Preferred';
        NV21.combination__c= 'DISTI Tesla Preferred';
        NV21.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV21.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV21.program_name__c= COMM_Constants.PA_PROGRAM_DIST;
        NV21.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV21);
        NV_Permissions_and_PCL_Mapping__c NV22= new NV_Permissions_and_PCL_Mapping__c ();
        NV22.name= 'DISTI Quadro Preferred';
        NV22.combination__c= 'DISTI Quadro Preferr';
        NV22.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        NV22.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV22.program_name__c= COMM_Constants.PA_PROGRAM_DIST;
        NV22.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV22);
        NV_Permissions_and_PCL_Mapping__c NV23= new NV_Permissions_and_PCL_Mapping__c ();
        NV23.name= 'DISTI Tesla Elite';
        NV23.combination__c= 'DISTI Tesla Elite';
        NV23.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV23.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV23.program_name__c= COMM_Constants.PA_PROGRAM_DIST;
        NV23.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV23);
        NV_Permissions_and_PCL_Mapping__c NV24= new NV_Permissions_and_PCL_Mapping__c ();
        NV24.name= 'DISTI Quadro Elite';
        NV24.combination__c= 'DISTI Quadro Elite';
        NV24.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        NV24.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV24.program_name__c= COMM_Constants.PA_PROGRAM_DIST;
        NV24.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV24);
        NV_Permissions_and_PCL_Mapping__c NV25= new NV_Permissions_and_PCL_Mapping__c ();
        NV25.name= 'DISTI vGPU Preferred';
        NV25.combination__c= 'DISTI vGPU Preferred';
        NV25.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NV25.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV25.program_name__c= COMM_Constants.PA_PROGRAM_DIST;
        NV25.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV25);
        NV_Permissions_and_PCL_Mapping__c NV26= new NV_Permissions_and_PCL_Mapping__c ();
        NV26.name= 'DISTI vGPU Elite';
        NV26.combination__c= 'DISTI vGPU Elite';
        NV26.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NV26.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV26.program_name__c= COMM_Constants.PA_PROGRAM_DIST;
        NV26.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV26);
        NV_Permissions_and_PCL_Mapping__c NV27= new NV_Permissions_and_PCL_Mapping__c ();
        NV27.name= 'DISTI DGX Elite';
        NV27.combination__c= 'DISTI DGX Elite';
        NV27.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV27.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV27.program_name__c= COMM_Constants.PA_PROGRAM_DIST;
        NV27.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV27);
        NV_Permissions_and_PCL_Mapping__c NV28= new NV_Permissions_and_PCL_Mapping__c ();
        NV28.name= 'DISTI DGX Preferred';
        NV28.combination__c= 'DISTI DGX Preferred';
        NV28.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV28.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV28.program_name__c= COMM_Constants.PA_PROGRAM_DIST;
        NV28.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV28);
        NV_Permissions_and_PCL_Mapping__c NV29= new NV_Permissions_and_PCL_Mapping__c ();
        NV29.name= 'SP DGX Elite';
        NV29.combination__c= 'SP DGX Elite';
        NV29.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV29.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV29.program_name__c= COMM_Constants.PA_PROGRAM_SP;
        NV29.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV29);
        NV_Permissions_and_PCL_Mapping__c NV30= new NV_Permissions_and_PCL_Mapping__c ();
        NV30.name= 'SP DGX Preferred';
        NV30.combination__c= 'SP DGX Preferred';
        NV30.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV30.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV30.program_name__c= COMM_Constants.PA_PROGRAM_SP;
        NV30.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV30);
        NV_Permissions_and_PCL_Mapping__c NV31= new NV_Permissions_and_PCL_Mapping__c ();
        NV31.name= 'CSP DGX Elite';
        NV31.combination__c= 'CSP DGX Elite';
        NV31.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV31.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV31.program_name__c= 'Cloud Solution Provider';
        NV31.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV31);
        NV_Permissions_and_PCL_Mapping__c NV32= new NV_Permissions_and_PCL_Mapping__c ();
        NV32.name= 'CSP DGX Preferred';
        NV32.combination__c= 'CSP DGX Preferred';
        NV32.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV32.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV32.program_name__c= 'Cloud Solution Provider';
        NV32.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV32);
        NV_Permissions_and_PCL_Mapping__c NV33= new NV_Permissions_and_PCL_Mapping__c ();
        NV33.name= 'OEM DGX Preferred';
        NV33.combination__c= 'OEM DGX Preferred';
        NV33.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV33.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV33.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV33.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV33);
        NV_Permissions_and_PCL_Mapping__c NV34= new NV_Permissions_and_PCL_Mapping__c ();
        NV34.name= 'OEM DGX Elite';
        NV34.combination__c= 'OEM DGX Elite';
        NV34.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV34.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV34.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV34.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV34);
        NV_Permissions_and_PCL_Mapping__c NV35= new NV_Permissions_and_PCL_Mapping__c ();
        NV35.name= 'SDPDGXPreferred';
        NV35.combination__c= 'SDP Edu DGX Preferred';
        NV35.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        NV35.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV35.program_name__c= COMM_Constants.PA_PROGRAM_SDP;
        NV35.sub_program__c= 'Educational Services';

        listNV_Permissions_and_PCL_Mapping.add(NV35);
        NV_Permissions_and_PCL_Mapping__c NV36= new NV_Permissions_and_PCL_Mapping__c ();
        NV36.name= 'SIP Tesla Preferred';
        NV36.combination__c= 'SIP Tesla Preferred';
        NV36.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV36.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV36.program_name__c= COMM_Constants.PA_PROGRAM_SIP;
        NV36.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV36);
        NV_Permissions_and_PCL_Mapping__c NV37= new NV_Permissions_and_PCL_Mapping__c ();
        NV37.name= 'SIP Tesla Elite';
        NV37.combination__c= 'SIP Tesla Elite';
        NV37.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        NV37.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV37.program_name__c= COMM_Constants.PA_PROGRAM_SIP;
        NV37.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV37);
        NV_Permissions_and_PCL_Mapping__c NV38= new NV_Permissions_and_PCL_Mapping__c ();
        NV38.name= 'SIP Quadro Preferred';
        NV38.combination__c= 'SIP Quadro Preferred';
        NV38.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        NV38.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV38.program_name__c= COMM_Constants.PA_PROGRAM_SIP;
        NV38.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV38);
        NV_Permissions_and_PCL_Mapping__c NV39= new NV_Permissions_and_PCL_Mapping__c ();
        NV39.name= 'SIP Quadro Elite';
        NV39.combination__c= 'SIP Quadro Elite';
        NV39.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        NV39.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV39.program_name__c= COMM_Constants.PA_PROGRAM_SIP;
        NV39.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV39);
        NV_Permissions_and_PCL_Mapping__c NV40= new NV_Permissions_and_PCL_Mapping__c ();
        NV40.name= 'SA vGPU Preferred';
        NV40.combination__c= 'SA vGPU Preferred';
        NV40.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NV40.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV40.program_name__c= COMM_Constants.PA_PROGRAM_SA;
        NV40.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV40);
        NV_Permissions_and_PCL_Mapping__c NV41= new NV_Permissions_and_PCL_Mapping__c ();
        NV41.name= 'TE Leads & Opportunities';
        NV41.combination__c= 'TE Leads & Opportunities';
        NV41.competency__c= 'Embedded';
        NV41.level__c= null;
        NV41.program_name__c= COMM_Constants.PA_PROGRAM_TE;
        NV41.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV41);
        NV_Permissions_and_PCL_Mapping__c NV42= new NV_Permissions_and_PCL_Mapping__c ();
        NV42.name= 'Marketing Partners GeForce Content';
        NV42.combination__c= null;
        NV42.competency__c= null;
        NV42.level__c= null;
        NV42.program_name__c= null;
        NV42.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV42);
        NV_Permissions_and_PCL_Mapping__c NV43= new NV_Permissions_and_PCL_Mapping__c ();
        NV43.name= 'OEM vGPU Preferred';
        NV43.combination__c= 'OEM vGPU Preferred';
        NV43.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NV43.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV43.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV43.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV43);
        NV_Permissions_and_PCL_Mapping__c NV44= new NV_Permissions_and_PCL_Mapping__c ();
        NV44.name= 'OEM vGPU Elite';
        NV44.combination__c= 'OEM vGPU Elite';
        NV44.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NV44.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV44.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV44.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV44);
        NV_Permissions_and_PCL_Mapping__c NV45= new NV_Permissions_and_PCL_Mapping__c ();
        NV45.name= 'OEM Quadro Preferred';
        NV45.combination__c= 'OEM Quadro Preferred';
        NV45.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        NV45.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV45.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV45.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV45);
        NV_Permissions_and_PCL_Mapping__c NV46= new NV_Permissions_and_PCL_Mapping__c ();
        NV46.name= 'OEM Quadro Elite';
        NV46.combination__c= 'OEM Quadro Elite';
        NV46.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        NV46.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV46.program_name__c= COMM_Constants.PA_PROGRAM_OEM;
        NV46.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV46);
        NV_Permissions_and_PCL_Mapping__c NV47= new NV_Permissions_and_PCL_Mapping__c ();
        NV47.name= 'CSP vGPU Preferred';
        NV47.combination__c= 'CSP vGPU Preferred';
        NV47.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NV47.level__c= COMM_Constants.PA_LEVEL_PREF;
        NV47.program_name__c= COMM_Constants.PA_PROGRAM_CSP;
        NV47.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV47);
        NV_Permissions_and_PCL_Mapping__c NV48= new NV_Permissions_and_PCL_Mapping__c ();
        NV48.name= 'CSP vGPU Elite';
        NV48.combination__c= 'CSP vGPU Elite';
        NV48.competency__c= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        NV48.level__c= COMM_Constants.PA_LEVEL_ELITE;
        NV48.program_name__c= COMM_Constants.PA_PROGRAM_CSP;
        NV48.sub_program__c= null;

        listNV_Permissions_and_PCL_Mapping.add(NV48);


        insert listNV_Permissions_and_PCL_Mapping;
        /************************NV_Permissions_and_PCL_Mapping__c ENDS*****************************/

        /************************Community_User_Local_Settings__c Starts*****************************/

        list<Community_User_Local_Settings__c> listCommunity_User_Local_Settings= new list<Community_User_Local_Settings__c> ();

        Community_User_Local_Settings__c Co1= new Community_User_Local_Settings__c ();
        Co1.name= 'Polish';
        Co1.contact_gpugenius_group__c= 'ELITE_PL:4565571';
        Co1.country_list__c= 'POLAND';
        Co1.user_alias__c= 'Training';
        Co1.user_emailencodekey__c= 'UTF-8';
        Co1.user_langlocalekey__c= 'pl';
        Co1.user_language__c= 'Polish';
        Co1.user_localesidkey__c= 'pl_PL';
        Co1.user_tzsidkey__c= 'America/Los_Angeles';
        Co1.region__c= 'EMEA';
        Co1.localized_portal__c= true;

        listCommunity_User_Local_Settings.add(Co1);
        Community_User_Local_Settings__c Co2= new Community_User_Local_Settings__c ();
        Co2.name= 'Spanish';
        Co2.contact_gpugenius_group__c= 'ELITE_ES:4565563';
        Co2.country_list__c= 'SPAIN';
        Co2.user_alias__c= 'Training';
        Co2.user_emailencodekey__c= 'UTF-8';
        Co2.user_langlocalekey__c= 'es';
        Co2.user_language__c= 'Spanish';
        Co2.user_localesidkey__c= 'es_ES';
        Co2.user_tzsidkey__c= 'America/Los_Angeles';
        Co2.region__c= 'EMEA';
        Co2.localized_portal__c= true;

        listCommunity_User_Local_Settings.add(Co2);
        Community_User_Local_Settings__c Co3= new Community_User_Local_Settings__c ();
        Co3.name= 'Turkish';
        Co3.contact_gpugenius_group__c= 'ELITE_TR:5118539';
        Co3.country_list__c= 'TURKEY';
        Co3.user_alias__c= 'Training';
        Co3.user_emailencodekey__c= 'UTF-8';
        Co3.user_langlocalekey__c= 'tr';
        Co3.user_language__c= 'Turkish';
        Co3.user_localesidkey__c= 'tr_TR';
        Co3.user_tzsidkey__c= 'America/Los_Angeles';
        Co3.region__c= 'EMEA';
        Co3.localized_portal__c= true;

        listCommunity_User_Local_Settings.add(Co3);
        Community_User_Local_Settings__c Co4= new Community_User_Local_Settings__c ();
        Co4.name= 'French';
        Co4.contact_gpugenius_group__c= 'ELITE_FR:4565545';
        Co4.country_list__c= 'FRANCE';
        Co4.user_alias__c= 'Training';
        Co4.user_emailencodekey__c= 'UTF-8';
        Co4.user_langlocalekey__c= 'fr';
        Co4.user_language__c= 'French';
        Co4.user_localesidkey__c= 'fr_FR';
        Co4.user_tzsidkey__c= 'America/Los_Angeles';
        Co4.region__c= 'EMEA';
        Co4.localized_portal__c= true;

        listCommunity_User_Local_Settings.add(Co4);
        Community_User_Local_Settings__c Co5= new Community_User_Local_Settings__c ();
        Co5.name= 'English';
        Co5.contact_gpugenius_group__c= 'ELITE_UK:4565542';
        Co5.country_list__c= 'BELGIUM, BULGARIA, CROATIA, DENMARK, FINLAND, GREECE, HUNGARY, ISRAEL, NORWAY, PORTUGAL, SWEDEN, THE NETHERLANDS, UNITED KINGDOM';
        Co5.user_alias__c= 'Training';
        Co5.user_emailencodekey__c= 'UTF-8';
        Co5.user_langlocalekey__c= 'en_GB';
        Co5.user_language__c= 'English';
        Co5.user_localesidkey__c= 'en_GB';
        Co5.user_tzsidkey__c= 'America/Los_Angeles';
        Co5.region__c= 'EMEA';
        Co5.localized_portal__c= true;

        listCommunity_User_Local_Settings.add(Co5);
        Community_User_Local_Settings__c Co6= new Community_User_Local_Settings__c ();
        Co6.name= 'Italian';
        Co6.contact_gpugenius_group__c= 'ELITE_IT:4565568';
        Co6.country_list__c= 'ITALY';
        Co6.user_alias__c= 'Training';
        Co6.user_emailencodekey__c= 'UTF-8';
        Co6.user_langlocalekey__c= 'it';
        Co6.user_language__c= 'Italian';
        Co6.user_localesidkey__c= 'it_IT';
        Co6.user_tzsidkey__c= 'America/Los_Angeles';
        Co6.region__c= 'EMEA';
        Co6.localized_portal__c= true;

        listCommunity_User_Local_Settings.add(Co6);
        Community_User_Local_Settings__c Co7= new Community_User_Local_Settings__c ();
        Co7.name= 'Czech';
        Co7.contact_gpugenius_group__c= 'ELITE_CZ:5118534';
        Co7.country_list__c= 'CZECH, SLOVAKIA';
        Co7.user_alias__c= 'Training';
        Co7.user_emailencodekey__c= 'UTF-8';
        Co7.user_langlocalekey__c= 'cs';
        Co7.user_language__c= 'Czech';
        Co7.user_localesidkey__c= 'cs_CZ';
        Co7.user_tzsidkey__c= 'America/Los_Angeles';
        Co7.region__c= 'EMEA';
        Co7.localized_portal__c= false;

        listCommunity_User_Local_Settings.add(Co7);
        Community_User_Local_Settings__c Co8= new Community_User_Local_Settings__c ();
        Co8.name= 'German';
        Co8.contact_gpugenius_group__c= 'ELITE_DE:4565552';
        Co8.country_list__c= 'GERMANY, SWITZERLAND';
        Co8.user_alias__c= 'Training';
        Co8.user_emailencodekey__c= 'UTF-8';
        Co8.user_langlocalekey__c= 'de';
        Co8.user_language__c= 'German';
        Co8.user_localesidkey__c= 'de_DE';
        Co8.user_tzsidkey__c= 'America/Los_Angeles';
        Co8.region__c= 'EMEA';
        Co8.localized_portal__c= true;

        listCommunity_User_Local_Settings.add(Co8);
        Community_User_Local_Settings__c Co9= new Community_User_Local_Settings__c ();
        Co9.name= 'Japanese';
        Co9.contact_gpugenius_group__c= COMM_Constants.CON_GPUGNS_GRP_LEMEAINVEMP;
        Co9.country_list__c= 'JAPAN';
        Co9.user_alias__c= 'Training';
        Co9.user_emailencodekey__c= 'UTF-8';
        Co9.user_langlocalekey__c= 'ja';
        Co9.user_language__c= 'Japanese';
        Co9.user_localesidkey__c= 'ja';
        Co9.user_tzsidkey__c= 'Asia/Tokyo';
        Co9.region__c= null;
        Co9.localized_portal__c= false;

        listCommunity_User_Local_Settings.add(Co9);
        Community_User_Local_Settings__c Co10= new Community_User_Local_Settings__c ();
        Co10.name= 'Taiwanese';
        Co10.contact_gpugenius_group__c= COMM_Constants.CON_GPUGNS_GRP_LEMEAINVEMP;
        Co10.country_list__c= 'TAIWAN';
        Co10.user_alias__c= 'Training';
        Co10.user_emailencodekey__c= 'UTF-8';
        Co10.user_langlocalekey__c= 'zh_TW';
        Co10.user_language__c= 'Taiwanese';
        Co10.user_localesidkey__c= 'zh_TW';
        Co10.user_tzsidkey__c= 'Asia/Taipei';
        Co10.region__c= null;
        Co10.localized_portal__c= false;

        listCommunity_User_Local_Settings.add(Co10);
        Community_User_Local_Settings__c Co11= new Community_User_Local_Settings__c ();
        Co11.name= 'Chinese';
        Co11.contact_gpugenius_group__c= COMM_Constants.CON_GPUGNS_GRP_LEMEAINVEMP;
        Co11.country_list__c= 'CHINA';
        Co11.user_alias__c= 'Training';
        Co11.user_emailencodekey__c= 'UTF-8';
        Co11.user_langlocalekey__c= 'zh_CN';
        Co11.user_language__c= 'Chinese';
        Co11.user_localesidkey__c= 'zh_CN';
        Co11.user_tzsidkey__c= 'Asia/Shanghai';
        Co11.region__c= null;
        Co11.localized_portal__c= false;

        listCommunity_User_Local_Settings.add(Co11);
        Community_User_Local_Settings__c Co12= new Community_User_Local_Settings__c ();
        Co12.name= 'Korean';
        Co12.contact_gpugenius_group__c= COMM_Constants.CON_GPUGNS_GRP_LEMEAINVEMP;
        Co12.country_list__c= 'SOUTH KOREA';
        Co12.user_alias__c= 'Training';
        Co12.user_emailencodekey__c= 'UTF-8';
        Co12.user_langlocalekey__c= 'ko';
        Co12.user_language__c= 'Korean';
        Co12.user_localesidkey__c= 'ko_KR';
        Co12.user_tzsidkey__c= 'Asia/Seoul';
        Co12.region__c= null;
        Co12.localized_portal__c= false;

        listCommunity_User_Local_Settings.add(Co12);


        insert listCommunity_User_Local_Settings;

        /************************Community_User_Local_Settings__c Ends*****************************/

        /************************Portal_Toggles__c Starts*****************************/

        list<Portal_Toggles__c> listPortal_Toggles= new list<Portal_Toggles__c> ();

        Portal_Toggles__c Po1= new Portal_Toggles__c ();
        Po1.name= COMM_Constants.TEST_PORTAL_COMPETENCY_AC;
        Po1.ask_a_question_email__c= 'npnaskaquestion@nvidia.com.invalid';
        Po1.log_a_support_request_email__c= 'enterprisesupport@nvidia.com.invalid';
        Po1.GPU_Genius_Training_Email__c= 'gpugeniusadmin@nvidia.com.invalid';
        Po1.toggle_description__c= 'This Competency focuses on parallel computing, Tesla, and other accelerated computing markets such as big data processing/analytics. It encompasses NVIDIA Tesla®, NVLink™, CUDA®, and PGI products and technologies.';

        listPortal_Toggles.add(Po1);
        Portal_Toggles__c Po2= new Portal_Toggles__c ();
        Po2.name= COMM_Constants.TEST_PORTAL_COMPETENCY_GV;
        Po2.ask_a_question_email__c= 'npnaskaquestion@nvidia.com.invalid';
        Po2.log_a_support_request_email__c= 'enterprisesupport@nvidia.com.invalid';
        Po2.GPU_Genius_Training_Email__c= 'gpugeniusadmin@nvidia.com.invalid';
        Po2.toggle_description__c= 'This Competency services markets that capitalize on graphics in the cloud. With NVIDIA GRID™ technologies, you\'ll focus on the markets that are benefiting from graphics-accelerated desktop and application virtualization.';

        listPortal_Toggles.add(Po2);
        Portal_Toggles__c Po3= new Portal_Toggles__c ();
        Po3.name= COMM_Constants.TEST_PORTAL_COMPETENCY_PV;
        Po3.ask_a_question_email__c= 'npnaskaquestion@nvidia.com.invalid';
        Po3.log_a_support_request_email__c= 'enterprisesupport@nvidia.com.invalid';
        Po3.GPU_Genius_Training_Email__c= 'gpugeniusadmin@nvidia.com.invalid';
        Po3.toggle_description__c= 'Quadro encompasses professional graphics, rendering, and scalable visual solutions for products like NVIDIA Quadro®, NVS™, and NVIDIA® VCA.';

        listPortal_Toggles.add(Po3);
        Portal_Toggles__c Po4= new Portal_Toggles__c ();
        Po4.name= COMM_Constants.TEST_PORTAL_COMPETENCY_DL;
        Po4.ask_a_question_email__c= 'npnaskaquestion@nvidia.com.invalid';
        Po4.log_a_support_request_email__c= 'enterprisesupport@nvidia.com.invalid';
        Po4.GPU_Genius_Training_Email__c= 'gpugeniusadmin@nvidia.com.invalid';
        Po4.toggle_description__c= 'DGX is about using the power of GPUs to enable computers to learn from data and write software to solve some of the most complex problems in computer science.';

        listPortal_Toggles.add(Po4);


        insert listPortal_Toggles;


        /************************Portal_Toggles__c Ends*****************************/

    }

}