/*
 * Created Date: 5/10/2017
 * Created By: Manideep
 * Description: This Test class maintains Code Coverage for "LeadAssignemntService.cls" class.
 
 Changes:    
 * 08/28/2017 : @Manideep - 'Region based enhancement for Lead Assignment Process Rules'
                * extend the LSID rules further by filtering accounts based on Lead's region match.
                * added a new method 
 * 04/17/2018 : @Manideep - Replace Product Type 'GRID' with Product Type 'vGPU' for Leads of Individual Country Routing Rules basing on Product Types.
 * 06/13/2018 : @Manideep - Replace the logic based on 'Product Type' with 'Enterprise Segment'.
 * 07/05/2018 : @Manideep - Add Country, State AND Enterprise Segment logic for the individual Country (United States) based rules.
 * 09/12/2018 : @Manideep - Add ProductType, Region and Countries based logic for Lead Routing Rules.
 * 11/21/2018 : @Manideep - Add Country and Industry based Lead Routing Rules.
 * 02/01/2019 - Reorder and Restructure Lead Assignment Rules
                 * vGPU Routing Rules (NEW) – If the State is in the United States AND Enterprise Segment is Professional Visualization or GPU Virtualization, please route to John Li.
                 * Industry Routing Rules
                 * State Routing Rules (Update) – Remove the Enterprise Segment rules for Professional Visualization or GPU Virtualization.
 * 03/14/2019 - Remove Named Account Routing for 'NALA' and 'EMEA'.
                 * Basically skip the routing rules those based out on 'LSID' matching and jump in directly to all other routing rules like Country/State etc., 
 * 02/20/2020 - @Manideep - Add new test methods for US Routing Rules with Enterprise Segment without States.
                          - Add new test methods for Product Type 'DGX'.
                          
 *** 02/04/2021: @Manideep - SDS-2795: This Class is ready to Delete, so commenting out as of now because unable to delete due to failures in other test classes in the Org. ***
 
*/
@isTest
public class LeadAssignmentServiceTest {
  
  /*
  // Create Custom Setting and its values needed for this test Class.   
  @testSetup static void dataSetup() {
    
    List<Lead_Assignment_Routing__c> larList = new List<Lead_Assignment_Routing__c>(); 
    Lead_Assignment_Routing__c lar;
    
    // This Custom setting record defines whether the Custom Setting should run or don't run.
    lar = new Lead_Assignment_Routing__c(Name = 'Activate_Routing', Activate_Deactivate_Routing__c = true);
    larList.add(lar);
    
    // These below Custom Setting records contains 'Makreto Sync' and '!SvcDeploy' Users 
    lar = new Lead_Assignment_Routing__c(Name = 'Marketo_User', Category__c = 'Config', Category_Description__c = 'This rule contains the Username of the Service user that\'s being used between Marketo and Salesforce (Marketo Sync)',
                                         Marketo_User_Username__c = 'tusrMKTO@example.com');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'SvcDeploy_User', Category__c = 'Config', Category_Description__c = 'This rule contains the Username of the Service User in Salesforce (\'!SvcDeploy\')',
                                         Marketo_User_Username__c = 'tusrSVCDPLY@example.com');
    larList.add(lar);
    
    // The below custom Setting records defines the order and  values for EMEA and Individial Country Routing values and their corresponding Owner Email Id's. 
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 1', Category__c = 'EMEA_NSC', Countries__c = 'Albania;Croatia;Switzerland;Gambia;Liechtenstein;Malawi;Germany;Gambia;Saint Helena;Equatorial Guinea;Mozambique;'
                                         +'Greece;Cyprus;Bulgaria;Angola;Swaziland;Bosnia and Herzegovina;Namibia;Burkina Faso;Togo;Estonia;Benin;Niger;Botswana;',
                                         UserEmail__c = 'tusr1@example.com', Category_Description__c = 'EMEA NSC Countries 1 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 2', Category__c = 'EMEA_NSC', Countries__c = 'Brunei Darussalam;Sierra Leone;Central African Republic;Slovenia;Serbia;Gabon;Ghana;',
                                         UserEmail__c = 'tusr1@example.com', Category_Description__c = 'EMEA NSC Countries 1 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 3', Category__c = 'EMEA_NSC', Countries__c = 'Austria;',
                                         UserEmail__c = 'tusr1@example.com', Category_Description__c = 'EMEA NSC Countries 1 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 4', Category__c = 'EMEA_NSC', Countries__c = 'Aland Islands;Sweden;Andorra;Montenegro;Portugal;Falkland Islands (Malvinas);Malta;Svalbard and Jan Mayen;'
                                         +'Spain;Denmark;Finland;Isle of Man;Guernsey;Faroe Islands;Greenland;Jersey;Nigeria;Ethiopia;South Georgia and the South Sandwich Islands;Burundi;',
                                         UserEmail__c = 'tusr2@example.com', Category_Description__c = 'EMEA NSC Countries 1 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 5', Category__c = 'EMEA_NSC', Countries__c = 'Kenya;Uganda;British Indian Ocean Territory;South Africa;Gibraltar;United Kingdom;Iceland;Macedonia;Ireland;British Virgin Islands;',
                                         UserEmail__c = 'tusr2@example.com', Category_Description__c = 'EMEA NSC Countries 2 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 6', Category__c = 'EMEA_NSC', Countries__c = 'Zimbabwe;',
                                         UserEmail__c = 'tusr2@example.com', Category_Description__c = 'EMEA NSC Countries 2 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 7', Category__c = 'EMEA_NSC', Countries__c = 'Algeria;Belgium;Cameroon;Cape Verde;Comoros;Congo, Democratic Republic of the;Cote D\'Ivoire;France;French Guiana;'
                                         +'French Southern Territories;Guadeloupe;Guinea;Guinea-Bissau;Liberia;Luxembourg;Madagascar;Zambia;The Netherlands;Israel;Mayotte;Monaco;',
                                         UserEmail__c = 'tusr3@example.com', Category_Description__c = 'EMEA NSC Countries 3 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 8', Category__c = 'EMEA_NSC', Countries__c = 'Morocco;New Caledonia;Réunion;Rwanda;Saint Pierre and Miquelon;Saint-Martin (French part);Sao Tome and Principe;'
                                         +'Senegal;Seychelles;Tanzania;Tunisia;Turks and Caicos Islands;Tuvalu;Wallis and Futuna;',
                                         UserEmail__c = 'tusr3@example.com', Category_Description__c = 'EMEA NSC Countries 3 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 9', Category__c = 'EMEA_NSC', Countries__c = 'Norway;',
                                         UserEmail__c = 'tusr3@example.com', Category_Description__c = 'EMEA NSC Countries 3 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 10', Category__c = 'EMEA_NSC', Countries__c = 'Bangladesh;India;Sri Lanka;Mauritius;Maldives;Nepal;Pakistan;',
                                         UserEmail__c = 'tusr4@example.com', Category_Description__c = 'EMEA NSC Countries 4 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 11', Category__c = 'EMEA_NSC', Countries__c = 'Russia;Ukraine;Belarus;Armenia;Azerbaijan;Kazakhstan;Kyrgyzstan;Moldova;Uzbekistan;Georgia;Moldova;Russian Federation;Latvia;'
                                         +'Lithuania;Turkmenistan;Tajikistan;',
                                         UserEmail__c = 'tusr5@example.com', Category_Description__c = 'EMEA NSC Countries 5 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 12', Category__c = 'EMEA_NSC', Countries__c = 'Bahrain;Djibouti;Egypt;Lesotho;Mauritania;Oman;Qatar;Saudi Arabia;Somalia;Yemen;Eritrea;Slovakia;Hungary;'
                                         +'Italy;San Marino;Chad;Mali;Western Sahara;Poland;Vatican City State;Romania;Jordan;Czech Republic;Kuwait;Lebanon;Turkey;Libya;Iraq;',
                                         UserEmail__c = 'tusr6@example.com', Category_Description__c = 'EMEA NSC Countries 6 Owner');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'EMEA NSC Countries 13', Category__c = 'EMEA_NSC', Countries__c = 'Jordan;Czech Republic;Kuwait;Lebanon;Palestinian Territory, Occupied;United Arab Emirates;Syria;',
                                         UserEmail__c = 'tusr6@example.com', Category_Description__c = 'EMEA NSC Countries 6 Owner');
    larList.add(lar);
    //---
    lar = new Lead_Assignment_Routing__c(Name = 'ICR-PT 1', Category__c = 'ICR_PT XXXXXX', Countries__c = 'Malaysia;Thailand;Viet Nam;Vietnam;Singapore;Indonesia;Philippines;',
                                         UserEmail__c = 'ozhan@example.com;terrence.chan@example.com', Category_Description__c = 'Individual Country Routing basing on Product Type. Conditions are 1.GRID 2. QUADRO or TESLA');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR2-PT 1', Category__c = 'ICR2_PT XXXXXX', Countries__c = 'Taiwan;China Republic of (Taiwan);',
                                         UserEmail__c = 'rogerh@example.com;michiu@example.com', Category_Description__c = 'Individual Country Routing basing on Product Type. Conditions are 1.QUADRO or GRID 2.TESLA');
    larList.add(lar);
    ---//
    lar = new Lead_Assignment_Routing__c(Name = 'ICR-NPT 1', Category__c = 'ICR_NPT', Countries__c = 'Korea;Korea, Republic of;',
                                         UserEmail__c = 'tusr7@example.com', Category_Description__c = 'Individual Country Routing basing on Non-Product Type');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR-NPT 2', Category__c = 'ICR_NPT', Countries__c = 'Brazil;Mexico;Argentina;Columbia;Venezuela;Uruguay;Chile;Equador;Barbados;Colombia;Bolivia;Dominican Republic;',
                                         UserEmail__c = 'tusr8@example.com', Category_Description__c = 'Individual Country Routing basing on Non-Product Type');
    larList.add(lar);
    //--
    lar = new Lead_Assignment_Routing__c(Name = 'ICR-NPT 3', Category__c = 'ICR_NPT XXXXXX', Countries__c = 'China;China Hong kong;China.;china, chengdu;'
                                         +'Peoples Republic Of China;beijing,China;PR.China;P. R. China;Shanghai;Hong Kong',
                                         UserEmail__c = 'heguo@example.com', Category_Description__c = 'Individual Country Routing basing on Non-Product Type');
    larList.add(lar); 
    ---//
    lar = new Lead_Assignment_Routing__c(Name = 'ICR-NPT 4', Category__c = 'ICR_NPT', Countries__c = 'Australia;New Zealand;',
                                         UserEmail__c = 'tusr9@example.com', Category_Description__c = 'Individual Country Routing basing on Non-Product Type');
    larList.add(lar);
    //---
    lar = new Lead_Assignment_Routing__c(Name = 'ICR-NPT 5', Category__c = 'ICR_NPT XXXXXX', Countries__c = 'Taiwan;China Republic of (Taiwan)',
                                         UserEmail__c = 'tudasdasd@example.com', Category_Description__c = 'Individual Country Routing basing on Non-Product Type');
    larList.add(lar);
    ---//
    lar = new Lead_Assignment_Routing__c(Name = 'ICR-NPT 6', Category__c = 'ICR_NPT', Countries__c = 'Japan;',
                                         UserEmail__c = 'tusr10@example.com', Category_Description__c = 'Individual Country Routing basing on Non-Product Type');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR-ES 1', Category__c = 'ICR_ES', Countries__c = 'Malaysia;Thailand;Viet Nam;Vietnam;Singapore;Indonesia;Philippines;', UserEmail__c = 'tusr11@example.com;tusr12@example.com;tusr11@example.com;',
                                         Category_Description__c = 'Individual Country Routing basing on Enterprise Segment. Conditions are:- 1) GPU Virtualization or Professional Visualization' 
                                         +'2) Accelerated Computing, High Performance Computing, or Deep Learning 3) Other');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR2-ES 1', Category__c = 'ICR2_ES', Countries__c = 'Taiwan;China Republic of (Taiwan);', UserEmail__c = 'tusr13@example.com;tusr14@example.com;tusr13@example.com;',
                                         Category_Description__c = 'Individual Country Routing basing on Enterprise Segment. Conditions are:- 1) GPU Virtualization or Professional Visualization' 
                                         + '2) Accelerated Computing, High Performance Computing, or Deep Learning 3) Other'); 
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR3-ES 1', Category__c = 'ICR3_ES', Countries__c = 'China;Peoples Republic Of China;Hong Kong;',
                                         UserEmail__c = 'tusr15@example.com;tusr16@example.com;tusr17@example.com;tusr15@example.com;', 
                                         Category_Description__c = 'Individual Country Routing basing on Enterprise Segment. Conditions are:- 1) GPU Virtualization or Professional Visualization' 
                                         +'2) Accelerated Computing, High Performance Computing, or Deep Learning 3) Other');
    larList.add(lar);  
    //industry
    lar = new Lead_Assignment_Routing__c(Name = 'ICR Industry 1', Category__c = 'ICR_Industry', Industry__c = 'Healthcare;Higher Ed/Research;Manufacturing;', Countries__c = 'United States;',
                                         UserEmail__c = 'tusr27@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) basing on Industry for Healthcare;Higher Ed/Research and Manufacturing.');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR Industry 2', Category__c = 'ICR_Industry', Industry__c = 'Media/Entertainment;Retail and CPG;Telecommunications;Logistics & Transportation;', Countries__c = 'United States;',
                                         UserEmail__c = 'tusr28@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) basing on Industry for Media/Entertainment;Retail and CPG;Telecommunications, Logistics & Transportation.');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR Industry 3', Category__c = 'ICR_Industry', Industry__c = 'Public Sector;Financial Services Industry (FSI);Aerospace;', Countries__c = 'United States;',
                                         UserEmail__c = 'tusr29@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) basing on Industry for Public Sector;Financial Services Industry (FSI) and Aerospace');
    larList.add(lar); 
    lar = new Lead_Assignment_Routing__c(Name = 'ICR Industry 4', Category__c = 'ICR_Industry', Industry__c = 'Architecture, Eng and Construction;Automotive;Consumer Internet Company (CICN);IT Services;Oil & Gas/Energy;Strategic Hyperscale;Supercomputing;Other;', Countries__c = 'United States;',
                                         UserEmail__c = 'tusr31@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) basing on Industry for IT Services, AEC, Oil & Gas, Supercomputing, CINC, Automotive and Other and all other industries except Gaming');
    larList.add(lar);   
    lar = new Lead_Assignment_Routing__c(Name = 'ICR States ES 1', Category__c = 'ICR_States_ES', Countries__c = 'United States;',
                                         States__c = 'Alaska;Arizona;Arkansas;California;Colorado;Hawaii;Idaho;Kansas;Louisiana;Montana;Nebraska;Nevada;New Mexico;Oklahoma;Oregon;Texas;Utah;Washington;Wyoming;',
                                         UserEmail__c = 'tusr18@example.com;tusr19@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) With States basing on Enterprise Segment. Conditions are:- ' 
                                                                   + '1) High Performance Computing or Deep Learning and Based on States 2) Other'); 
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR States ES 2', Category__c = 'ICR_States_ES', Countries__c = 'United States;',
                                         States__c = 'Alabama;Connecticut;Delaware;Florida;Georgia;Illinois;Indiana;Iowa;Kentucky;Maine;Maryland;Massachusetts;Michigan;Minnesota;Mississippi;Missouri;New Hampshire;New Jersey;New York;North Carolina;North Dakota;Ohio;Pennsylvania;Rhode Island;South Carolina;',
                                         UserEmail__c = 'tusr20@example.com;tusr19@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) With States basing on Enterprise Segment. Conditions are:- ' 
                                                                   + '1) High Performance Computing or Deep Learning and Based on States 2) Other'); 
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR States ES 3', Category__c = 'ICR_States_ES', Countries__c = 'United States;',
                                         States__c = 'South Dakota;Tennessee;Vermont;Virignia;West Virginia;Wisconsin;',
                                         UserEmail__c = 'tusr20@example.com;tusr19@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) With States basing on Enterprise Segment. Conditions are:- ' 
                                                                   + '1) High Performance Computing or Deep Learning and Based on States 2) Other'); 
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR States ES vGPU 1', Category__c = 'ICR_States_ES_vGPU', Countries__c = 'United States;',
                                         States__c = 'Alaska;Arizona;Arkansas;California;Colorado;Hawaii;Idaho;Kansas;Louisiana;Montana;Nebraska;Nevada;New Mexico;Oklahoma;Oregon;Texas;Utah;Washington;Wyoming;Alabama;Connecticut;Delaware;Florida;Georgia;Illinois;Indiana;Iowa;Kentucky;Maine;Maryland;',
                                         UserEmail__c = 'tusr30@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) With States basing on Enterprise Segment. Conditions are:- ' 
                                                                   + '1) Professional Visualization or GPU Virtualization'); 
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR States ES vGPU 2', Category__c = 'ICR_States_ES_vGPU', Countries__c = 'United States;',
                                         States__c = 'Massachusetts;Michigan;Minnesota;Mississippi;Missouri;New Hampshire;New Jersey;New York;North Carolina;North Dakota;Ohio;Pennsylvania;Rhode Island;South Carolina;South Dakota;Tennessee;Vermont;Virignia;West Virginia;Wisconsin;',
                                         UserEmail__c = 'tusr30@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) With States basing on Enterprise Segment. Conditions are:- ' 
                                                                   + '1) Professional Visualization or GPU Virtualization'); 
    larList.add(lar); 
    //---  
    lar = new Lead_Assignment_Routing__c(Name = 'NPN Rules 1', Category__c = 'NPN_Nurture', Partner_Lead_Owner__c = 'Brian Diamond;Adam Hinckley;Steve Hutton;Al Solorzano;'
                                         +'Bob Allred;Gary Pegoraro;Patrick Coble;Chris Monfet;Brad Thomas;Brad Truman;Brennan Bice;Chris Gambino;Donald Lott;Eric Hutchison;'
                                         +'Fabrice Girerd;Jose Moreno;Kayla Schubert;Mark Chronister;Matt O\'Brien',
                                         Category_Description__c = 'NPN Nurture Rules');
    larList.add(lar);
    ---//
    lar = new Lead_Assignment_Routing__c(Name = 'NPN Rules 2', Category__c = 'NPN_Nurture', Partner_Lead_Owner__c = 'Paul Kunze;Tim Husar',
                                         Category_Description__c = 'NPN Nurture Rules');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'Default User 1', Category__c = 'Default_User', UserEmail__c = 'jlunt@example.com',
                                         Category_Description__c = 'Default User');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'PRD TYPE 1 Region 1 Country 1', Category__c = 'PRD_TYPE_REGION', ProductType__c = 'Quadro', Region__c = 'NALA', Countries__c = '', 
                                         UserEmail__c = 'tusr21@example.com', Category_Description__c = 'Routing Based on Product Type, Region and Countries');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'PRD TYPE 1 Region 1 Country 2', Category__c = 'PRD_TYPE_REGION', ProductType__c = 'Quadro', Region__c = 'NALA', Countries__c = 'United States;', 
                                         UserEmail__c = 'tusr22@example.com', Category_Description__c = 'Routing Based on Product Type, Region and Countries');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'PRD-TYPE 1 Region 2 Country 1', Category__c = 'PRD_TYPE_REGION', ProductType__c = 'Quadro', Region__c = 'EMEAI', Countries__c = '', 
                                         UserEmail__c = 'tusr23@example.com', Category_Description__c = 'Routing Based on Product Type, Region and Countries');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'PRD-TYPE 1 Region 2 Country 2', Category__c = 'PRD_TYPE_REGION', ProductType__c = 'Quadro', Region__c = 'EMEAI', Countries__c = 'United Kingdom;', 
                                         UserEmail__c = 'tusr24@example.com', Category_Description__c = 'Routing Based on Product Type, Region and Countries');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'PRD-TYPE 1 Region 3 Country 1', Category__c = 'PRD_TYPE_REGION', ProductType__c = 'Quadro', Region__c = 'APAC', Countries__c = '',
                                         UserEmail__c = 'tusr25@example.com', Category_Description__c = 'Routing Based on Product Type, Region and Countries');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'PRD-TYPE 1 Region 3 Country 2', Category__c = 'PRD_TYPE_REGION', ProductType__c = 'Quadro', Region__c = 'APAC', Countries__c = 'China;',
                                         UserEmail__c = 'tusr26@example.com', Category_Description__c = 'Routing Based on Product Type, Region and Countries');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'LORIGIN PRD TYPE 1 REGION 1', Category__c = 'LORIGIN_PRD_TYPE_REGION', 
                                         Lead_Origin__c = 'GLOBAL_DL_WF_2018_DL07_DGX Pod Promo Form (PUR);GLOBAL_DL_WF_2017_DGX Station Order Now Form (PUR);GLOBAL_DL_WF_2018_DGX-2 Order Form (Purchase);GLOBAL_DL_WF_2018_DL09_DGX-2 Order Form (PUR);Tesla_DGX-1 Order Form_Web Form_NALA_2016_April;',  
                                         ProductType__c = 'DGX', Region__c = 'NALA', Countries__c = 'Canada;', UserEmail__c = 'tusr32@example.com', 
                                         Category_Description__c = 'Routing Based on Lead Origin, Product Type, Region and with or without Countries');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'LORIGIN PRD TYPE 1 REGION 2', Category__c = 'LORIGIN_PRD_TYPE_REGION', 
                                         Lead_Origin__c = 'GLOBAL_DL_WF_2018_DL07_DGX Pod Promo Form (PUR);GLOBAL_DL_WF_2017_DGX Station Order Now Form (PUR);GLOBAL_DL_WF_2018_DGX-2 Order Form (Purchase);GLOBAL_DL_WF_2018_DL09_DGX-2 Order Form (PUR);Tesla_DGX-1 Order Form_Web Form_NALA_2016_April;',  
                                         ProductType__c = 'DGX', Region__c = 'EMEA', UserEmail__c = 'tusr33@example.com', 
                                         Category_Description__c = 'Routing Based on Lead Origin, Product Type, Region and with or without Countries');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'LORIGIN PRD TYPE 1 REGION 3', Category__c = 'LORIGIN_PRD_TYPE_REGION',  
                                         Lead_Origin__c = 'GLOBAL_DL_WF_2018_DL07_DGX Pod Promo Form (PUR);GLOBAL_DL_WF_2017_DGX Station Order Now Form (PUR);GLOBAL_DL_WF_2018_DGX-2 Order Form (Purchase);GLOBAL_DL_WF_2018_DL09_DGX-2 Order Form (PUR);Tesla_DGX-1 Order Form_Web Form_NALA_2016_April;',  
                                         ProductType__c = 'DGX', Region__c = 'APAC', UserEmail__c = 'tusr34@example.com', 
                                         Category_Description__c = 'Routing Based on Lead Origin, Product Type, Region and with or without Countries');
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'ICR Country ES vGPU 1', Category__c = 'ICR_Country_ES_vGPU', Countries__c = 'United States;', UserEmail__c = 'tusr35@example.com;', 
                                         Category_Description__c = 'Individual Country Routing (USA) basing on Enterprise Segment. Conditions are:- 1) Professional Visualization or GPU Virtualization'); 
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'CR Country ES1', Category__c = 'ICR_Country_ES', Countries__c = 'United States;', UserEmail__c = 'tusr35@example.com;tusr36@example.com', 
                                         Category_Description__c = 'Individual Country Routing (USA) basing on Enterprise Segment. Conditions are:- 1) High Performance Computing or Deep Learning and Based on States 2) Other'); 
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'VGPU ProdType1 Region3 Country5', Category__c = 'VGPU_PROD_TYPE_REGION_COUNTRY', ProductType__c = 'vGPU', Region__c = 'APAC', Countries__c = 'China;Peoples Republic Of China;', UserEmail__c = 'tusr38@example.com', 
                                         Category_Description__c = 'Individual Country Routing (USA) basing on Product Type \'VGPU\' and Region'); 
    larList.add(lar);
    lar = new Lead_Assignment_Routing__c(Name = 'PRDTYPE 1 CMPYTYPE 1 Region 1 Ctry 2', Category__c = 'PROD_TYPE_CMPY_TYPE_REGION_COUNTRY', ProductType__c = 'Automotive', Company_Type__c = 'Engineering Service Vendor: Service Providers', Region__c = 'APAC', Countries__c = 'Japan;', UserEmail__c = 'tusr38@example.com', 
                                         Category_Description__c = 'Routing Based on Product Type, Company Type, Region and Country'); 
    larList.add(lar);
    
    insert larList;
    
    //Create Users
    Id Pid = [Select Id from Profile where Name = 'Sales Profile'].Id;
    Id RoleId = [Select Id From UserRole where Name = 'Sales Rep - Tesla/Quadro/GRID'].Id;
    Id PartnerProfileId = [Select Id from Profile where Name = 'NPN Partner Community(LOGIN)'].Id;
    
    Id MkPrfid = [Select Id from Profile where Name = 'Marketo User Profile'].Id;
    Id MkRoleId = [Select Id From UserRole where Name = 'Sales'].Id;
    Id SAdmPrfid = [Select Id from Profile where Name = 'System Administrator'].Id;
    Id SAdmRoleId = [Select Id From UserRole where Name = 'Administrator'].Id;
    
    Account acc = new Account(Name = 'Test Acc', Automotive_startup__c = 'No');
    insert acc;
    
    Contact ctc = new Contact(FirstName='Brian', LastName = 'Diamond', AccountId = acc.Id);
    insert ctc;
    
    List<User> userList = new List<User>();
    User u;
    
    u = new User(FirstName = 'Marketo', LastName = 'Sync Test', email = 'tusrMKTO@example.com', Username = 'tusrMKTO@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = MkPrfid, UserRoleId = MkRoleId);  
    userList.add(u); 
    u = new User(FirstName = '!svcdeploy2', LastName = 'CRMADMINTest', email = 'tusrSVCDPLY@example.com', Username = 'tusrSVCDPLY@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = SAdmPrfid, UserRoleId = SAdmRoleId);  
    userList.add(u);
    
    u = new User(FirstName = 'test', LastName = 'user 1', email = 'tusr1@example.com', Username = 'tusr1@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 2', email = 'tusr2@example.com', Username = 'tusr2@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 3', email = 'tusr3@example.com', Username = 'tusr3@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 4', email = 'tusr4@example.com', Username = 'tusr4@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 5', email = 'tusr5@example.com', Username = 'tusr5@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 6', email = 'tusr6@example.com', Username = 'tusr6@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 7', email = 'tusr7@example.com', Username = 'tusr7@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 8', email = 'tusr8@example.com', Username = 'tusr8h@example.com', Alias='rh', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 9', email = 'tusr9@example.com', Username = 'tusr9@example.com', Alias='mu', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 10', email = 'tusr10@example.com', Username = 'tusr10@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 11', email = 'tusr11@example.com', Username = 'tusr11@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 12', email = 'tusr12@example.com', Username = 'tusr12@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 13', email = 'tusr13@example.com', Username = 'tusr13@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 14', email = 'tusr14@example.com', Username = 'tusr14@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 15', email = 'tusr15@example.com', Username = 'tusr15@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 16', email = 'tusr16@example.com', Username = 'tusr16@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 17', email = 'tusr17@example.com', Username = 'tusr17@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 18', email = 'tusr18@example.com', Username = 'tusr18@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 19', email = 'tusr19@example.com', Username = 'tusr19@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 20', email = 'tusr20@example.com', Username = 'tusr20@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'Brian', LastName = 'Diamond', email = 'bDiamond@example.com', Username = 'bDiamond@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ContactId = ctc.Id, ProfileId = PartnerProfileId);  
    userList.add(u); 
    u = new User(FirstName = 'Adam', LastName = 'Hinckley', email = 'aHinckley@example.com', Username = 'aHinckley@example.com', Alias='abd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'Steve', LastName = 'Hutton', email = 'sHutton@example.com', Username = 'sHutton@example.com', Alias='sbd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'Al', LastName = 'Solorzano', email = 'aSolorzano@example.com', Username = 'aSolorzano@example.com', Alias='albd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'Bob', LastName = 'Allred', email = 'bAllred@example.com', Username = 'bAllred@example.com', Alias='bbd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'Gary', LastName = 'Pegoraro', email = 'gPegoraro@example.com', Username = 'gPegoraro@example.com', Alias='gbd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'Patrick', LastName = 'Coble', email = 'pCoble@example.com', Username = 'pCoble@example.com', Alias='pbd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'Jason', LastName = 'Lunt', email = 'jLunt@example.com', Username = 'jLunt@example.com', Alias='jbd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 21', email = 'tusr21@example.com', Username = 'tusr21@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 22', email = 'tusr22@example.com', Username = 'tusr22@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 23', email = 'tusr23@example.com', Username = 'tusr23@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 24', email = 'tusr24@example.com', Username = 'tusr24@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 25', email = 'tusr25@example.com', Username = 'tusr25@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 26', email = 'tusr26@example.com', Username = 'tusr26@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 27', email = 'tusr27@example.com', Username = 'tusr27@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 28', email = 'tusr28@example.com', Username = 'tusr28@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 29', email = 'tusr29@example.com', Username = 'tusr29@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 30', email = 'tusr30@example.com', Username = 'tusr30@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 31', email = 'tusr31@example.com', Username = 'tusr31@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 32', email = 'tusr32@example.com', Username = 'tusr32@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 33', email = 'tusr33@example.com', Username = 'tusr33@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 34', email = 'tusr34@example.com', Username = 'tusr34@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 35', email = 'tusr35@example.com', Username = 'tusr35@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 36', email = 'tusr36@example.com', Username = 'tusr36@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 37', email = 'tusr37@example.com', Username = 'tusr37@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 38', email = 'tusr38@example.com', Username = 'tusr38@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 39', email = 'tusr39@example.com', Username = 'tusr39@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
    userList.add(u);
        
    User usr = [Select Id from User where Id = :UserInfo.getUserId()];
    system.runAs(usr) {
      insert userList;
    }       
    
    List<User> usersAdded = [SELECT Id, Name, Email FROM User 
                             WHERE (ProfileId = :Pid or ProfileId = :PartnerProfileId or ProfileId = :MkPrfid or ProfileId = :SAdmPrfid) 
                             AND CreatedDate = Today];
    system.debug('usersAdded---->'+usersAdded);
    
    // Create Country List records.
    Country_List__c ctryLst = new Country_List__c();
    ctryLst.Name = 'United States';
    ctryLst.ISO_Code__c = 'US';
    ctryLst.Region__c = LeadAssignment_Constants.Region_NALA; 
    insert ctryLst;
    
  }
    
  // This is a test Method for 'leadAssignmentMethod()' in Lead_trg_cls.cls invoked by the trigger Lead_tgr.trg
  public static testMethod void LeadAssgnTrgTM() {
    
    List<User> users = [Select Id, Name from User where User.Profile.UserLicense.Name = :LeadAssignment_Constants.USER_LICENSE_SF and isActive = true];
    Map<String, User> UserNameMap = new Map<String, User>();
    
    Map<Id, User> UserIdMap = new Map<Id, User>();
    
    for(User usr: users) {
        UserNameMap.put(usr.Name, usr);
        
        UserIdMap.put(usr.Id, usr);
    }
    
    // pull the Marketo User
    User mkusr = [SELECT Id FROM User WHERE Username = 'tusrMKTO@example.com'];
    
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
        
    List<Account> accts = new List<Account>();
    for(Integer i=1; i<3; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account '+ i;
        acc.RecordTypeId = RT.Id;
        if(i == 1)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_NAMED; 
        else if(i == 2)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_LIGHTHOUSE;   
        acc.OwnerId = users[i].Id;
        acc.LSID__c = strAccLSID + i; 
        acc.Inactive__c = false; 
        acc.Automotive_Startup__c = 'No';
        accts.add(acc);
    }
    insert accts;
        
    List<Contact> contacts = new List<Contact>();
    for(Integer i=1; i<2; i++) {
        Contact ctc = new Contact();
        ctc.FirstName = 'Test';
        ctc.LastName = 'Contact ' + i;
        ctc.Email = 'testCtc' + 'LeadAssgnTrgTM' + i + '@test.com';
        contacts.add(ctc);
    }
    insert contacts;
    
    // run as Marketo User
    system.runAs(mkusr) {
        
    List<Lead> leads = new List<Lead>();
    for(integer i=1; i<2; i++) {
        integer j = i - 1;
        Lead ld = new Lead();
        //ld.OwnerId = UserNameMap.get(LeadAssignment_Constants.MKT_OWNER).Id;
        ld.FirstName = 'Test';
        ld.LastName = 'Lead ' + i;
        ld.Company = 'Test Account ' + i;
        ld.No_Sales_Call__c = false;
        ld.No_Sales_Email__c = false;
        ld.MKTO_Assigned__c = false;
        ld.AccountID__c = accts[j].Id;
        ld.LSID__c = accts[j].LSID__c;
        ld.Status = 'Prospect';
        //ld.Partner_Lead_Owner__c = contacts[j].Id;
        ld.Email = 'test' + 'LeadAssgnTrgTM' + i + '@test.com';
        leads.add(ld);  
    }    
    insert leads;
    
    for(Lead ld: Leads) {
        ld.Status = LeadAssignment_Constants.LEAD_STATUS_MQ;   
    }
    update leads; 
    
    } // end of run as Marketo User
                
  }
  
  /*
   * This is a test Method for LeadAssignmentService.cls
   * LSID-Rule 1: If Lead LSID matches exactly one Account and the account is “NAMED Account” or “LIGHTHOUSE Account” 
  */
  /*
  public static testMethod void LeadAssignementServiceTM1() {
    
    User mkUser = [Select Id from User where Name =:LeadAssignment_Constants.MKT_OWNER];
    List<User> salesUsers = [Select Id, Name from User where profile.Name = 'Sales Profile' and isActive = true];
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    List<Account> accts = new List<Account>();
    for(Integer i=1; i<3; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account '+ i;
        acc.RecordTypeId = RT.Id;
        if(i == 1)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_NAMED; 
        else if(i == 2)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_LIGHTHOUSE;  
        acc.OwnerId = salesUsers[i].Id;
        acc.LSID__c = strAccLSID + i; 
        acc.Inactive__c = false; 
        acc.BillingCountry = 'China';
        acc.Automotive_Startup__c = 'No';
        accts.add(acc);
    }
    insert accts;
    
    List<Contact> contacts = new List<Contact>();
    for(Integer i=1; i<3; i++) {
        Contact ctc = new Contact();
        ctc.FirstName = 'Test';
        ctc.LastName = 'Contact ' + i;
        contacts.add(ctc);
    }
    insert contacts;
    
    List<Lead> leads = new List<Lead>();
    for(integer i=1; i<3; i++) {
        integer j = i - 1;
        Lead ld = new Lead();
        ld.OwnerId = mkUser.Id;
        ld.FirstName = 'Test';
        ld.LastName = 'Lead ' + i;
        ld.Company = 'Test Account ' + i;
        ld.No_Sales_Call__c = false;
        ld.No_Sales_Email__c = false;
        ld.MKTO_Assigned__c = false;
        ld.AccountID__c = accts[j].Id;
        ld.LSID__c = accts[j].LSID__c;
        ld.Status = 'Prospect';
        ld.Partner_Lead_Owner__c = contacts[j].Id;
        ld.Region__c = 'APAC';
        leads.add(ld);  
    }
    insert leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Partner_Lead_Owner__c, 
                          Region__c, Country, Product_Type__c, Timestamp_Request_Contact__c, OwnerId from Lead];                           
    
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.PartnerLeadOwner = ld.Partner_Lead_Owner__c;
        lat.Country = ld.Country;
        lat.ProductType = ld.Product_Type__c;
        lat.OwnerId = ld.OwnerId;
        lat.Region = ld.Region__c;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);  
     
  }
  */
  
  /*
   * This is a test Method for LeadAssignmentService.cls
   * LSID-Rule 1: If Lead LSID matches exactly one Account and the account is "GENERAL Account"
  */
  /*
  public static testMethod void LeadAssignementServiceTM2() {
    
    User mkUser = [Select Id from User where Name =:LeadAssignment_Constants.MKT_OWNER];
    List<User> salesUsers = [Select Id, Name from User where profile.Name = 'Sales Profile' and isActive = true];
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    Account acc = new Account();
    acc.Name = 'Test Account '+ 1;
    acc.RecordTypeId = RT.Id;
    acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_GENERAL;   
    acc.OwnerId = salesUsers[0].Id;
    acc.LSID__c = strAccLSID + 1;  
    acc.Inactive__c = false;
    acc.BillingCountry = 'China';
    acc.Automotive_Startup__c = 'No';
    insert acc;
        
    Contact ctc = new Contact();
    ctc.FirstName = 'Test';
    ctc.LastName = 'Contact ' + 1;
    insert ctc;
    
    Lead led = new Lead();
    led.OwnerId = mkUser.Id;
    led.FirstName = 'Test';
    led.LastName = 'Lead ' + 1;
    led.Company = 'Test Account ' + 1;
    led.No_Sales_Call__c = false;
    led.No_Sales_Email__c = false;
    led.MKTO_Assigned__c = false;
    led.AccountID__c = acc.Id;
    led.LSID__c = acc.LSID__c;
    led.Status = 'Prospect';
    led.Partner_Lead_Owner__c = ctc.Id;
    led.Region__c = 'APAC';
    insert led;
     
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Partner_Lead_Owner__c, 
                          Region__c, Country, Product_Type__c, Timestamp_Request_Contact__c, OwnerId from Lead];                           
    
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.PartnerLeadOwner = ld.Partner_Lead_Owner__c;
        lat.Country = ld.Country;
        lat.ProductType = ld.Product_Type__c;
        lat.OwnerId = ld.OwnerId;
        lat.Region = ld.Region__c;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);  
  }
  */
  
  /*
   * This is a test Method for LeadAssignmentService.cls
   * LSID-Rule 2: If Lead LSID matches MULITPLE Accounts and exactly one of the matched account is either “NAMED Account” or “LIGHTHOUSE Account” or "GENERAL Account"
  */
  /*
  public static testMethod void LeadAssignementServiceTM3() {
    
    User mkUser = [Select Id from User where Name =:LeadAssignment_Constants.MKT_OWNER];
    List<User> salesUsers = [Select Id, Name from User where profile.Name = 'Sales Profile' and isActive = true AND CreatedDate = Today];
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    List<Account> accts = new List<Account>();
    for(Integer i=1; i<4; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account '+ i;
        acc.RecordTypeId = RT.Id;
        if(i == 1)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_NAMED; 
        else if(i == 2)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_LIGHTHOUSE; 
        else if(i == 3)   
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_GENERAL;  
        acc.OwnerId = salesUsers[i].Id;
        acc.LSID__c = strAccLSID + i;  
        acc.Inactive__c = false;
        acc.BillingCountry = 'China';
        acc.Automotive_Startup__c = 'No';
        accts.add(acc);
    }
    for(Integer i=4; i<7; i++) {
        integer j = i-3;
        Account acc = new Account();
        acc.Name = 'Test Account '+ i;
        acc.RecordTypeId = RT.Id;
        acc.Account_Class__c = 'Top 1000 Account';     
        acc.OwnerId = salesUsers[j].Id;
        acc.LSID__c = strAccLSID + j;  
        acc.BillingCountry = 'United States';
        acc.Automotive_Startup__c = 'No';
        accts.add(acc);
    }
    insert accts;
    
    List<Contact> contacts = new List<Contact>();
    for(Integer i=1; i<7; i++) {
        Contact ctc = new Contact();
        ctc.FirstName = 'Test';
        ctc.LastName = 'Contact ' + i;
        contacts.add(ctc);
    }
    insert contacts;
    
    List<Lead> leads = new List<Lead>();
    for(integer i=1; i<7; i++) {
        integer j = i - 1;
        Lead ld = new Lead();
        ld.OwnerId = mkUser.Id;
        ld.FirstName = 'Test';
        ld.LastName = 'Lead ' + i;
        ld.Company = 'Test Account ' + i;
        ld.No_Sales_Call__c = false;
        ld.No_Sales_Email__c = false;
        ld.MKTO_Assigned__c = false;
        ld.AccountID__c = accts[j].Id;
        ld.LSID__c = accts[j].LSID__c;
        ld.Status = 'Prospect';
        ld.Partner_Lead_Owner__c = contacts[j].Id;
        ld.Region__c = 'APAC';
        leads.add(ld);  
    }
    insert leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Partner_Lead_Owner__c, 
                          Region__c, Country, Product_Type__c, Timestamp_Request_Contact__c, OwnerId from Lead];                            
    
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.PartnerLeadOwner = ld.Partner_Lead_Owner__c;
        lat.Country = ld.Country;
        lat.ProductType = ld.Product_Type__c;
        lat.OwnerId = ld.OwnerId;
        lat.Region = ld.Region__c;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);  
  }
  */
  
  /*
   * This is a test Method for LeadAssignmentService.cls
   * LSID-Rule 3: If Lead LSID matches to all “NAMED Account” AND “LIGHTHOUSE Account” AND "GENERAL Account" then 
                      LightHouse Account takes precedence
  */
  /*
  public static testMethod void LeadAssignementServiceTM4() {
    
    User mkUser = [Select Id from User where Name =:LeadAssignment_Constants.MKT_OWNER];
    List<User> salesUsers = [Select Id, Name from User where profile.Name = 'Sales Profile' and isActive = true AND CreatedDate = Today];
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
        
    List<Account> accts = new List<Account>();
    for(Integer i=1; i<4; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account '+ i;
        acc.RecordTypeId = RT.Id;
        if(i == 1)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_NAMED; 
        else if(i == 2)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_LIGHTHOUSE;
        else if(i == 3)   
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_GENERAL;  
        acc.OwnerId = salesUsers[i].Id;
        acc.LSID__c = strAccLSID + 1; 
        acc.Inactive__c = false;
        acc.BillingCountry = 'China';
        acc.Automotive_Startup__c = 'No';
        accts.add(acc);
    }
    insert accts;
  
    List<Contact> contacts = new List<Contact>();
    for(Integer i=1; i<4; i++) {
        Contact ctc = new Contact();
        ctc.FirstName = 'Test';
        ctc.LastName = 'Contact ' + i;
        contacts.add(ctc);
    }
    insert contacts;
    
    List<Lead> leads = new List<Lead>();
    for(integer i=1; i<4; i++) {
        integer j = i - 1;
        Lead ld = new Lead();
        ld.OwnerId = mkUser.Id;
        ld.FirstName = 'Test';
        ld.LastName = 'Lead ' + i;
        ld.Company = 'Test Account ' + i;
        ld.No_Sales_Call__c = false;
        ld.No_Sales_Email__c = false;
        ld.MKTO_Assigned__c = false;
        ld.AccountID__c = accts[j].Id;
        ld.LSID__c = accts[j].LSID__c;
        ld.Status = 'Prospect';
        ld.Partner_Lead_Owner__c = contacts[j].Id;
        ld.Region__c = 'APAC';
        leads.add(ld);  
    }
    insert leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Partner_Lead_Owner__c, 
                          Region__c, Country, Product_Type__c, Timestamp_Request_Contact__c, OwnerId from Lead];                         
    
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.PartnerLeadOwner = ld.Partner_Lead_Owner__c;
        lat.Country = ld.Country;
        lat.ProductType = ld.Product_Type__c;
        lat.OwnerId = ld.OwnerId;
        lat.Region = ld.Region__c;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);
    
    // Map of Users with User fields
    Map<string, User> tcUserIdMap = new Map<string, User>();
    for(User usr: [Select Id, Name, Email from User where IsActive = true AND CreatedDate = Today]) {
        tcUserIdMap.put(usr.Id, usr);
    } 
        
    system.assertEquals(accts[1].Id, listAllLATs[1].AccountId);
    //system.assertEquals(accts[1].OwnerId, listAllLATs[1].OwnerId);
    //system.assertEquals(tcUserIdMap.get(accts[1].OwnerId).Name, tcUserIdMap.get(listAllLATs[1].OwnerId).Name);
          
  }
  */
  
  /*
   * This is a test Method for LeadAssignmentService.cls
   * LSID-Rule 3: If Lead LSID matches to all “NAMED Account” AND “LIGHTHOUSE Account” AND "GENERAL Account" then 
                      LightHouse Account takes precedence else Named Account takes precedence 
  */
  /*
  public static testMethod void LeadAssignementServiceTM5() {
    
    User mkUser = [Select Id from User where Name =:LeadAssignment_Constants.MKT_OWNER];
    List<User> salesUsers = [Select Id, Name from User where profile.Name = 'Sales Profile' and isActive = true];
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    List<Account> accts = new List<Account>();
    for(Integer i=1; i<3; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account '+ i;
        acc.RecordTypeId = RT.Id;
        if(i == 1)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_NAMED; 
        else if(i == 2)
           acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_GENERAL;   
        acc.OwnerId = salesUsers[i].Id;
        acc.LSID__c = strAccLSID + 1;  
        acc.Inactive__c = false;
        acc.BillingCountry = 'China';
        acc.Automotive_Startup__c = 'No';
        accts.add(acc);
    }
    insert accts;
    
    List<Contact> contacts = new List<Contact>();
    for(Integer i=1; i<3; i++) {
        Contact ctc = new Contact();
        ctc.FirstName = 'Test';
        ctc.LastName = 'Contact ' + i;
        contacts.add(ctc);
    }
    insert contacts;
    
    List<Lead> leads = new List<Lead>();
    for(integer i=1; i<3; i++) {
        integer j = i - 1;
        Lead ld = new Lead();
        ld.OwnerId = mkUser.Id;
        ld.FirstName = 'Test';
        ld.LastName = 'Lead ' + i;
        ld.Company = 'Test Account ' + i;
        ld.No_Sales_Call__c = false;
        ld.No_Sales_Email__c = false;
        ld.MKTO_Assigned__c = false;
        ld.AccountID__c = accts[j].Id;
        ld.LSID__c = accts[j].LSID__c;
        ld.Status = 'Prospect';
        ld.Partner_Lead_Owner__c = contacts[j].Id;
        ld.Region__c = 'APAC';
        leads.add(ld);  
    }
    insert leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Partner_Lead_Owner__c, 
                          Region__c, Country, Product_Type__c, Timestamp_Request_Contact__c, OwnerId from Lead];                            
    
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.PartnerLeadOwner = ld.Partner_Lead_Owner__c;
        lat.Country = ld.Country;
        lat.ProductType = ld.Product_Type__c;
        lat.OwnerId = ld.OwnerId;
        lat.Region = ld.Region__c;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);
    
    /////////
    // Map of Users with User fields
    Map<string, User> tcUserIdMap = new Map<string, User>();
    for(User usr: [Select Id, Name, Email from User where IsActive = true AND CreatedDate = Today]) {
        tcUserIdMap.put(usr.Id, usr);
    }
    system.assertEquals(tcUserIdMap.get(accts[0].OwnerId).Name, tcUserIdMap.get(listAllLATs[0].OwnerId).Name);
    //////
    system.assertEquals(accts[0].Id, listAllLATs[0].AccountId);
    //system.assertEquals(accts[0].OwnerId, listAllLATs[0].OwnerId);
    
  }
  */
  
  /*
   * This is a test Method for LeadAssignmentService.cls
   * Rule 4: NPN Nurture Rules 
  */
  /*
  public static testMethod void LeadAssignementServiceTM6() {
    
    String strAccLSID = 'TESTLSIDTEMPU34X';
    
    Contact ctc = [Select Id, Name from Contact WHERE Name = 'Brian Diamond'];
    
    Lead led = new Lead();
    led.FirstName = 'Test';
    led.LastName = 'Lead ' + 1;
    led.Company = 'Test Account ' + 1;
    led.No_Sales_Call__c = false;
    led.No_Sales_Email__c = false;
    led.MKTO_Assigned__c = false;
    led.LSID__c = strAccLSID + 1;
    led.Status = 'Prospect';
    led.Partner_Lead_Owner__c = ctc.Id;
    led.Region__c = 'NALA';
    insert led;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Partner_Lead_Owner__c, 
                                Country, Product_Type__c, Timestamp_Request_Contact__c, OwnerId from Lead];                           
    
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.PartnerLeadOwner = ld.Partner_Lead_Owner__c;
        lat.Country = ld.Country;
        lat.ProductType = ld.Product_Type__c;
        lat.OwnerId = ld.OwnerId;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);
    
    User usr = [Select Id, Name from User where IsPortalEnabled = true and Email = 'bdiamond@example.com'];
    system.assertEquals(usr.Id, listAllLATs[0].OwnerId);  
  }
  ---//    
  
  // This is a test Method for LeadAssignmentService.cls
  // Rule 5: To EMEA NSC Based on Territories 
  public static testMethod void LeadAssignementServiceTM7() {
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    List<Lead> leads = new List<Lead>();
    for(integer i=0; i<5; i++) {
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'Lead ' + i;
        led.Company = 'Test Account';
        led.No_Sales_Call__c = false;
        led.No_Sales_Email__c = false;
        led.MKTO_Assigned__c = false;
        //led.LSID__c = strAccLSID + i;
        led.Status = 'Prospect';
        leads.add(led);
    }    
    insert leads;
    
    leads[0].Country = 'Angola';
    leads[1].Country = 'Andorra';
    leads[2].Country = 'Belgium';
    leads[3].Country = 'Nepal';
    leads[4].Country = 'Ukraine';
    update leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Country, State, Product_Type__c, OwnerId from Lead]; 
                                                              
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        //lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.Country = ld.Country;
        lat.State = ld.State;
        lat.ProductType = ld.Product_Type__c;
        lat.OwnerId = ld.OwnerId;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);
        
    List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
    Map<String, User> UserEmailMap = new Map<String, User>();
    for(User usr: users) {
        UserEmailMap.put(usr.Email, usr);
    }
    
    system.assertEquals(UserEmailMap.get('tusr1@example.com').Id, listAllLATs[0].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr2@example.com').Id, listAllLATs[1].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr3@example.com').Id, listAllLATs[2].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr4@example.com').Id, listAllLATs[3].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr5@example.com').Id, listAllLATs[4].OwnerId);
  } 
  
  //---
   * This is a test Method for LeadAssignmentService.cls
   * Rule 6: Individual Country Routing - based on Enterprise Segment, Not based on Enterprise Segment, Null Enterprise Segment.
  ---//
  public static testMethod void LeadAssignementServiceTM8() {
    
    List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
    Map<String, User> UserEmailMap = new Map<String, User>();
    Map<String, User> UserIdMap = new Map<String, User>();
    for(User usr: users) {
        UserEmailMap.put(usr.Email, usr);
        UserIdMap.put(usr.Id, usr);
    }
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    List<Lead> leads = new List<Lead>();
    for(integer i=0; i<18; i++) {
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'Lead ' + i;
        led.Company = 'Test Account';
        led.No_Sales_Call__c = false;
        led.No_Sales_Email__c = false;
        led.MKTO_Assigned__c = false;
        //led.LSID__c = strAccLSID + i;
        led.Status = 'Prospect';
        led.Product_Type__c = 'vGPU';
        leads.add(led);
    }    
    insert leads;
    
    // Individual Country routing
    leads[0].Country = 'Korea, Republic of';
    leads[1].Country = 'Brazil';
    leads[2].Country = 'New Zealand';
    leads[3].Country = 'Australia';
    leads[4].Country = 'Japan';
    
    // Country routing based on Enterprise Segment
    leads[5].Enterprise_Segment__c = 'GPU Virtualization';
    leads[5].Country = 'Malaysia';
    leads[6].Enterprise_Segment__c = 'High Performance Computing';
    leads[6].Country = 'Thailand';
    leads[7].Enterprise_Segment__c = 'dummy value';  
    leads[7].Country = 'Singapore';
    leads[8].Enterprise_Segment__c = '';  // Null Enterprise Segment
    leads[8].Country = 'Indonesia';
    
    // Country routing based on Enterprise Segment
    leads[9].Enterprise_Segment__c = 'Professional Visualization';
    leads[9].Country = 'Taiwan';
    leads[10].Enterprise_Segment__c = 'High Performance Computing';
    leads[10].Country = 'Taiwan';
    leads[11].Enterprise_Segment__c = 'dummy value';  
    leads[11].Country = 'Taiwan';
    leads[12].Enterprise_Segment__c = '';  // Null Enterprise Segment
    leads[12].Country = 'Taiwan';
    
    // Country routing based on Enterprise Segment
    leads[13].Enterprise_Segment__c = 'GPU Virtualization';
    leads[13].Country = 'China';
    leads[14].Enterprise_Segment__c = 'Deep Learning';
    leads[14].Country = 'China';
    leads[15].Enterprise_Segment__c = 'High Performance Computing';
    leads[15].Country = 'China';
    leads[16].Enterprise_Segment__c = 'dummy value';  
    leads[16].Country = 'China';
    leads[17].Enterprise_Segment__c = '';  // Null Enterprise Segment
    leads[17].Country = 'Hong Kong';
    
    update leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Country, State, Product_Type__c, Enterprise_Segment__c, OwnerId from Lead]; 
    system.debug('leadlst--->'+leadlst);
                                                          
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        //lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.Country = ld.Country;
        lat.State = ld.State;
        lat.ProductType = ld.Product_Type__c;
        lat.EnterpriseSegment = ld.Enterprise_Segment__c;
        lat.OwnerId = ld.OwnerId;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);
    system.debug('listAllLATs--in tc--->'+listAllLATs);
    
    // Validate assertions from Service Class context.
    system.assertEquals(UserEmailMap.get('tusr7@example.com').Id, listAllLATs[0].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr8@example.com').Id, listAllLATs[1].OwnerId); 
    system.assertEquals(UserEmailMap.get('tusr9@example.com').Id, listAllLATs[2].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr9@example.com').Id, listAllLATs[3].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr10@example.com').Id, listAllLATs[4].OwnerId);
    
    system.assertEquals(UserEmailMap.get('tusr11@example.com').Id, listAllLATs[5].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr12@example.com').Id, listAllLATs[6].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr11@example.com').Id, listAllLATs[7].OwnerId);
    //system.assertEquals(UserEmailMap.get('tusr11@example.com').Email, UserIdMap.get(listAllLATs[7].OwnerId).Email);
    system.assertEquals(UserEmailMap.get('tusr11@example.com').Id, listAllLATs[8].OwnerId);
    //system.assertEquals(UserEmailMap.get('tusr11@example.com').Email, UserIdMap.get(listAllLATs[8].OwnerId).Email);
    
    system.assertEquals(UserEmailMap.get('tusr13@example.com').Id, listAllLATs[9].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr14@example.com').Id, listAllLATs[10].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr13@example.com').Id, listAllLATs[11].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr13@example.com').Id, listAllLATs[12].OwnerId);
    
    system.assertEquals(UserEmailMap.get('tusr15@example.com').Id, listAllLATs[13].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr16@example.com').Id, listAllLATs[14].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr17@example.com').Id, listAllLATs[15].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr15@example.com').Id, listAllLATs[16].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr15@example.com').Id, listAllLATs[17].OwnerId);
    
    // validate assertions from the Trigger context
    List<Lead> testLeadLt = new List<Lead>();
    for(Lead ld: leadlst) {
        for(LeadAssignmentTemplate lat: listAllLATs) {
            if(ld.Id == lat.LeadId) {   
               ld.OwnerId = lat.OwnerId;
               ld.AccountID__c = lat.AccountId;
               testLeadLt.add(ld);
            }   
         }         
    }
    update testLeadLt;
    
    /*
    Lead l1 = [Select Id, OwnerId from Lead where Product_Type__c = 'vGPU' and Country = 'Malaysia'];
    system.assertEquals(UserEmailMap.get('ozhan@example.com').Id, l1.OwnerId);
    Lead l2 = [Select Id, OwnerId from Lead where Product_Type__c = 'Tesla' and Country = 'Thailand'];
    system.assertEquals(UserEmailMap.get('terrence.chan@example.com').Id, l2.OwnerId);
    Lead l3 = [Select Id, OwnerId from Lead where Country = 'Korea, Republic of'];
    system.assertEquals(UserEmailMap.get('man@example.com').Id, l3.OwnerId);
    Lead l4 = [Select Id, OwnerId from Lead where Country = 'Brazil'];
    system.assertEquals(UserEmailMap.get('marcio.aguiar@example.com').Id, l4.OwnerId);
    Lead l5 = [Select Id, OwnerId from Lead where Country = 'China'];
    system.assertEquals(UserEmailMap.get('heguo@example.com').Id, l5.OwnerId);
    Lead l6 = [Select Id, OwnerId from Lead where Country = 'Australia'];
    system.assertEquals(UserEmailMap.get('mpatane@example.com').Id, l6.OwnerId);
    //Lead l7 = [Select Id, OwnerId from Lead where Country = 'Taiwan'];
    //system.assertEquals(UserEmailMap.get('erchangm@example.com').Id, l7.OwnerId);
    Lead l8 = [Select Id, OwnerId from Lead where Country = 'Japan'];
    system.assertEquals(UserEmailMap.get('khayashi@example.com').Id, l8.OwnerId);
    Lead l9 = [Select Id, OwnerId from Lead where Country = 'Taiwan' and Product_Type__c = 'Quadro'];
    system.assertEquals(UserEmailMap.get('rogerh@example.com').Id, l9.OwnerId);
    Lead l10 = [Select Id, OwnerId from Lead where Country = 'Taiwan' and Product_Type__c = 'Tesla'];
    system.assertEquals(UserEmailMap.get('michiu@example.com').Id, l10.OwnerId); 
    --//
  } 
    
  //---
   * This is a test Method for LeadAssignmentService.cls
   * Rule 7: NSC Default
  --//
  public static testMethod void LeadAssignementServiceTM9() {
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    List<Lead> leads = new List<Lead>();
    for(integer i=0; i<11; i++) {
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'Lead ' + i;
        led.Company = 'Test Account';
        led.No_Sales_Call__c = false;
        led.No_Sales_Email__c = false;
        led.MKTO_Assigned__c = false;
        //led.LSID__c = strAccLSID + i;
        led.Status = 'Prospect';
        leads.add(led);
    }    
    insert leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Country, State, Product_Type__c, OwnerId from Lead]; 
                                                          
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        //lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.Country = ld.Country;
        lat.State = ld.State;
        //lat.ProductType = ld.Product_Type__c;
        lat.OwnerId = ld.OwnerId;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);
    
    User usr = [Select Id, Name from User where Email = 'jlunt@example.com'];
    system.assertEquals(usr.Id, listAllLATs[0].OwnerId);
  } 
  
  //---
   * Date: 7/05/2018
   * This is a test Method for LeadAssignmentService.cls
   * Rule 6: Individual Country Routing - based on Country, State and Enterprise Segment, Null/Blank Enterprise Segment.
  ---//
  public static testMethod void LeadAssignementServiceCountryStateEntrpSegmentUS() {
    
    List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
    Map<String, User> UserEmailMap = new Map<String, User>();
    for(User usr: users) {
        UserEmailMap.put(usr.Email, usr);
    }
    
    Map<String, User> UserIdMap = new Map<String, User>();
    for(User usr: users) {
        UserEmailMap.put(usr.Email, usr);
        UserIdMap.put(usr.Id, usr);
    }
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    List<Lead> leads = new List<Lead>();
    for(integer i=0; i<6; i++) {
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'Lead ' + i;
        led.Company = 'Test Account';
        led.No_Sales_Call__c = false;
        led.No_Sales_Email__c = false;
        led.MKTO_Assigned__c = false;
        //led.LSID__c = strAccLSID + i;
        led.Status = 'Prospect';
        led.Product_Type__c = 'vGPU';
        led.Country = 'United States';
        leads.add(led);
    }    
    insert leads;
        
    // State routing based on Enterprise Segment
    leads[0].State = 'Alaska';
    leads[0].Enterprise_Segment__c = COMM_Constants.LEAD_ENTERPRISE_SEGMENT_HPC;
    leads[1].State = 'Alaska';
    leads[1].Enterprise_Segment__c = COMM_Constants.LEAD_ENTERPRISE_SEGMENT_PV;
    leads[2].State = 'Alabama';
    leads[2].Enterprise_Segment__c = COMM_Constants.LEAD_ENTERPRISE_SEGMENT_DL;
    leads[3].State = 'Alabama';
    leads[3].Enterprise_Segment__c = COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV;
    leads[4].State = 'North Dakota';
    leads[4].Enterprise_Segment__c = 'dummy value'; 
    leads[5].State = 'Tennessee';
    leads[5].Enterprise_Segment__c = '';  // Null Enterprise Segment        
    update leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Country, State, Product_Type__c, Enterprise_Segment__c, OwnerId from Lead]; 
    system.debug('leadlst--->'+leadlst);
                                                          
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        //lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.Country = ld.Country;
        lat.State = ld.State;
        lat.ProductType = ld.Product_Type__c;
        lat.EnterpriseSegment = ld.Enterprise_Segment__c;
        lat.OwnerId = ld.OwnerId;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);
        
    // Validate assertions from Service Class context.    
    system.assertEquals(UserEmailMap.get('tusr18@example.com').Id, listAllLATs[0].OwnerId);    
    system.assertEquals(UserEmailMap.get('tusr30@example.com').Id, listAllLATs[1].OwnerId); 
    //system.assertEquals(UserEmailMap.get('tusr20@example.com').Id, listAllLATs[2].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr20@example.com').Email, UserIdMap.get(listAllLATs[2].OwnerId).Email);
    system.assertEquals(UserEmailMap.get('tusr30@example.com').Id, listAllLATs[3].OwnerId);
    //system.assertEquals(UserEmailMap.get('tusr19@example.com').Id, listAllLATs[4].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr19@example.com').Email, UserIdMap.get(listAllLATs[4].OwnerId).Email);
    //system.assertEquals(UserEmailMap.get('tusr19@example.com').Id, listAllLATs[5].OwnerId);
    system.assertEquals(UserEmailMap.get('tusr19@example.com').Email, UserIdMap.get(listAllLATs[5].OwnerId).Email);
        
    // validate assertions from the Trigger context
    List<Lead> testLeadLt = new List<Lead>();
    for(Lead ld: leadlst) {
        for(LeadAssignmentTemplate lat: listAllLATs) {
            if(ld.Id == lat.LeadId) {   
               ld.OwnerId = lat.OwnerId;
               ld.AccountID__c = lat.AccountId;
               testLeadLt.add(ld);
            }   
         }         
    }
    update testLeadLt;
  }  
  
  //---
   * Date: 7/05/2018
   * This is a test Method for LeadAssignmentService.cls
   * Rule 6: Individual Country Routing - based on Country, State and Enterprise Segment, Null/Blank Enterprise Segment.
             - Passing the first/only Lead with Enterprise Segment 'GPU Virtualization', so that it will be first record in the Map 'indvCtryStateEmailMap' of class 'LeadAssignmentService.cls'  
  ---//
  public static testMethod void LeadAssignementServiceCountryStateEntrpSegmentUS2() {
    
    List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
    Map<String, User> UserEmailMap = new Map<String, User>();
    for(User usr: users) {
        UserEmailMap.put(usr.Email, usr);
    }
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    List<Lead> leads = new List<Lead>();
    for(integer i=0; i<1; i++) {
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'Lead ' + i;
        led.Company = 'Test Account';
        led.No_Sales_Call__c = false;
        led.No_Sales_Email__c = false;
        led.MKTO_Assigned__c = false;
        //led.LSID__c = strAccLSID + i;
        led.Status = 'Prospect';
        led.Product_Type__c = 'vGPU';
        led.Country = 'United States';
        leads.add(led);
    }    
    insert leads;
        
    // State routing based on Enterprise Segment
    leads[0].State = 'Alaska';
    leads[0].Enterprise_Segment__c = COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV;
    update leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Country, State, Product_Type__c, Enterprise_Segment__c, OwnerId from Lead]; 
                                                          
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        //lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.Country = ld.Country;
        lat.State = ld.State;
        lat.ProductType = ld.Product_Type__c;
        lat.EnterpriseSegment = ld.Enterprise_Segment__c;
        lat.OwnerId = ld.OwnerId;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);
                
    // validate assertions from the Trigger context
    List<Lead> testLeadLt = new List<Lead>();
    for(Lead ld: leadlst) {
        for(LeadAssignmentTemplate lat: listAllLATs) {
            if(ld.Id == lat.LeadId) {   
               ld.OwnerId = lat.OwnerId;
               ld.AccountID__c = lat.AccountId;
               testLeadLt.add(ld);
            }   
         }         
    }
    update testLeadLt;
  }  
  
  //---
   * Date: 7/05/2018
   * This is a test Method for LeadAssignmentService.cls
   * Rule 6: Individual Country Routing - based on Country, State and Enterprise Segment, Null/Blank Enterprise Segment.
             - Passing non-exist picklist value for "Enterprise Segment" field for a Lead
  ---//
  public static testMethod void LeadAssignementServiceCountryStateEntrpSegmentUS3() {
    
    List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
    Map<String, User> UserEmailMap = new Map<String, User>();
    for(User usr: users) {
        UserEmailMap.put(usr.Email, usr);
    }
    
    String strAccLSID = 'TESTLSIDTEMPU1234X';
    
    List<Lead> leads = new List<Lead>();
    for(integer i=0; i<1; i++) {
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'Lead ' + i;
        led.Company = 'Test Account';
        led.No_Sales_Call__c = false;
        led.No_Sales_Email__c = false;
        led.MKTO_Assigned__c = false;
        led.LSID__c = strAccLSID + i;
        led.Status = 'Prospect';
        led.Product_Type__c = 'vGPU';
        led.Country = 'United States';
        leads.add(led);
    }    
    insert leads;
        
    // State routing based on Enterprise Segment
    leads[0].State = 'Alaska';
    leads[0].Enterprise_Segment__c = 'dummy value';
    update leads;
    
    List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Country, State, Product_Type__c, Enterprise_Segment__c, OwnerId from Lead]; 
                                                          
    List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
    for(Lead ld: leadlst) {
        LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
        lat.LeadId = ld.Id; 
        //lat.LeadLSID = ld.LSID__c;
        lat.AccountId = ld.AccountID__c;
        lat.Country = ld.Country;
        lat.State = ld.State;
        lat.ProductType = ld.Product_Type__c;
        lat.EnterpriseSegment = ld.Enterprise_Segment__c;
        lat.OwnerId = ld.OwnerId;
        listAllLATs.add(lat);
    }
    listAllLATs = LeadAssignmentService.leadService(listAllLATs);
                
    // validate assertions from the Trigger context
    List<Lead> testLeadLt = new List<Lead>();
    for(Lead ld: leadlst) {
        for(LeadAssignmentTemplate lat: listAllLATs) {
            if(ld.Id == lat.LeadId) {   
               ld.OwnerId = lat.OwnerId;
               ld.AccountID__c = lat.AccountId;
               testLeadLt.add(ld);
            }   
         }         
    }
    update testLeadLt;
  }  
      
  //---
   * @Manideep - 9/12/2018
   * "ProductType, Region and Countries based logic for Lead Routing Rules"
   * This covers code coverage in 'Lead_tgr_cls.cls' and 'LeadAssignmentService.cls'
  ---//
  public static testMethod void LeadAssignementServiceProductTypeRegionCountryRules() {
    
    List<User> users = [Select Id, Name from User where User.Profile.UserLicense.Name = :LeadAssignment_Constants.USER_LICENSE_SF and isActive = true];
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    User mktoSyncUser = [Select Id, Name from User where Name = 'Marketo Sync' and isActive = true];
    
    List<Account> accts = new List<Account>();
    for(Integer i=1; i<7; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account '+ i;
        acc.RecordTypeId = RT.Id;
        acc.Inactive__c = false; 
        acc.Automotive_Startup__c = 'No';
        accts.add(acc);
    }
    insert accts;
        
    List<Lead> leads = new List<Lead>();
    for(integer i=0; i<6; i++) {
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'Lead ' + i;
        led.Company = 'Test Account';
        led.No_Sales_Call__c = false;
        led.No_Sales_Email__c = false;
        led.MKTO_Assigned__c = false;
        led.Status = 'Prospect';
        led.Product_Type__c = 'Quadro';
        //---
        if(i == 0) {
           led.Region__c = 'NALA';
        } else if(i == 1) {
           led.Region__c = 'NALA';
           led.Country = 'United States';   
        } else if(i == 2) {
           led.Region__c = 'EMEAI';
        } else if(i == 3) {
           led.Region__c = 'EMEAI';
           led.Country = 'United Kingdom';  
        } else if(i == 4) {
           led.Region__c = 'APAC';
        } else if(i == 5) {
           led.Region__c = 'APAC';
           led.Country = 'China';
        }
        ---//
        led.Region__c = 'APAC';
        led.Country = 'China';
        led.OwnerId = mktoSyncUser.Id;
        leads.add(led);
    }    
    insert leads;
    
    for(Lead ld: leads) {
        ld.status = 'Marketing Qualified';
    }
    update leads;  
    
    // Map of Users with User fields
    Map<string, User> tcUserEmailMap = new Map<string, User>();
    Map<string, User> tcUserIdMap = new Map<string, User>();
    for(User usr: [Select Id, Name, Email from User where IsActive = true AND CreatedDate = Today]) {
        tcuserEmailMap.put(usr.Email, usr);
        tcUserIdMap.put(usr.Id, usr);
    } 
        
    // Lead Ownership should have assigned to Users as per the Lead's Product Type, Region and Country
    List<Lead> leadsList = [Select Id, Name, OwnerId, Region__c FROM Lead WHERE Id IN:leads ORDER BY Name ASC];
    /*
    system.assertEquals(tcUserEmailMap.get('tusr21@example.com').Name, tcUserIdMap.get(leadsList[0].OwnerId).Name);
    system.assertEquals(tcUserEmailMap.get('tusr22@example.com').Name, tcUserIdMap.get(leadsList[1].OwnerId).Name);
    system.assertEquals(tcUserEmailMap.get('tusr23@example.com').Name, tcUserIdMap.get(leadsList[2].OwnerId).Name);
    system.assertEquals(tcUserEmailMap.get('tusr24@example.com').Name, tcUserIdMap.get(leadsList[3].OwnerId).Name);
    system.assertEquals(tcUserEmailMap.get('tusr25@example.com').Name, tcUserIdMap.get(leadsList[4].OwnerId).Name);
    system.assertEquals(tcUserEmailMap.get('tusr26@example.com').Name, tcUserIdMap.get(leadsList[5].OwnerId).Name);
    ---//
    
  } 
  
  //---
   * @Manideep - 9/12/2018
   * "ProductType, Region and Countries based logic for Lead Routing Rules"
   * This covers code coverage in 'Lead_tgr_cls.cls' and 'LeadAssignmentService.cls'
  ---//
  public static testMethod void LeadAssignementServiceIndustryRules() {
    
    List<User> users = [Select Id, Name from User where User.Profile.UserLicense.Name = :LeadAssignment_Constants.USER_LICENSE_SF and isActive = true];
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    User mktoSyncUser = [Select Id, Name from User where Name = 'Marketo Sync' and isActive = true];
    
    List<Account> accts = new List<Account>();
    List<Lead> leads = new List<Lead>();
    
    // Create the Leads as 'Marketo Sync' user
    system.runAs(mktoSyncUser) {
    
     for(Integer i=1; i<5; i++) {
         Account acc = new Account();
         acc.Name = 'Test Account '+ i;
         acc.RecordTypeId = RT.Id;
         acc.Inactive__c = false; 
         acc.Automotive_Startup__c = 'No';
         acc.BillingStreet = '500 Epic Way';
         acc.BillingCity = 'San Jose';
         acc.BillingState = 'California';
         acc.BillingCountry = 'United States';
         acc.BillingPostalCode = '95134';
         accts.add(acc);
     }
     insert accts;
        
     for(integer i=0; i<4; i++) {
         Lead led = new Lead();
         led.FirstName = 'Test';
         led.LastName = 'Lead ' + i;
         led.Company = 'Test Account';
         led.Email = 'test@test.com';
         led.No_Sales_Call__c = false;
         led.No_Sales_Email__c = false;
         led.MKTO_Assigned__c = false;
         led.Status = 'Prospect';
         led.Country = 'United States';
         if(i == 0) {
            led.Industry = 'Healthcare';
         } else if(i == 1) {
            led.Industry = 'Higher Ed/Research';    
         } else if(i == 2) {
            led.Industry = 'Manufacturing';
         } else if(i == 3) {
            led.Industry = 'Telecommunications';
         } 
         led.OwnerId = mktoSyncUser.Id;
         leads.add(led);
     }    
     insert leads;
    
     for(Lead ld: leads) {
        ld.status = 'Marketing Qualified';
     }
     update leads; 
    
    } 
    
    // Map of Users with User fields
    Map<string, User> tcUserEmailMap = new Map<string, User>();
    Map<string, User> tcUserIdMap = new Map<string, User>();
    for(User usr: [Select Id, Name, Email from User where IsActive = true AND CreatedDate = Today]) {
        tcuserEmailMap.put(usr.Email, usr);
        tcUserIdMap.put(usr.Id, usr);
    } 
        
    // Lead Ownership should have assigned to Users as per the Lead's Product Type, Region and Country
    List<Lead> leadsList = [Select Id, Name, OwnerId, Region__c FROM Lead WHERE Id IN:leads ORDER BY Name ASC];
    //system.assertEquals(tcUserEmailMap.get('tusr27@example.com').Name, tcUserIdMap.get(leadsList[0].OwnerId).Name);
    //system.assertEquals(tcUserEmailMap.get('tusr28@example.com').Name, tcUserIdMap.get(leadsList[1].OwnerId).Name);
    //system.assertEquals(tcUserEmailMap.get('tusr29@example.com').Name, tcUserIdMap.get(leadsList[2].OwnerId).Name);
    //system.assertEquals(tcUserEmailMap.get('tusr31@example.com').Name, tcUserIdMap.get(leadsList[3].OwnerId).Name);
        
  }
  
  /*
 * This is a test Method for LeadAssignmentService.cls
 * LSID-Rule 2: If Lead LSID matches MULITPLE Accounts and exactly one of the matched account is either “NAMED Account” or “LIGHTHOUSE Account” or "GENERAL Account"
 */
 /*
    public static testMethod void LeadAssignementServiceTM31() {

        User mkUser = [Select Id from User where Name =:LeadAssignment_Constants.MKT_OWNER];
        List<User> salesUsers = [Select Id, Name from User where profile.Name = 'Sales Profile' and isActive = true AND CreatedDate = Today];
        RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
        Id EntrCustRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD).getRecordTypeId();

        String strAccLSID = 'TESTLSIDTEMPU1234X';

        List<Account> accts = new List<Account>();
        for(Integer i=1; i<4; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account '+ i;
            acc.RecordTypeId = RT.Id;
            if(i == 1)
                acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_NAMED;
            else if(i == 2)
                acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_LIGHTHOUSE;
            else if(i == 3)
                acc.Account_Class__c = LeadAssignment_Constants.ACCOUNT_CLASS_GENERAL;
            acc.OwnerId = salesUsers[i].Id;
            acc.LSID__c = strAccLSID + i;
            acc.Inactive__c = false;
            acc.BillingCountry = 'China';
            acc.Automotive_Startup__c = 'No';
            acc.Billing_Region__c = 'APAC';
            accts.add(acc);
        }
        for(Integer i=4; i<7; i++) {
            integer j = i-3;
            Account acc = new Account();
            acc.Name = 'Test Account '+ i;
            acc.RecordTypeId = RT.Id;
            acc.Account_Class__c = 'Top 1000 Account';
            acc.OwnerId = salesUsers[j].Id;
            acc.LSID__c = strAccLSID + j;
            acc.BillingCountry = 'United States';
            acc.Automotive_Startup__c = 'No';
            acc.Billing_Region__c = 'APAC';
            accts.add(acc);
        }
        insert accts;

        List<Contact> contacts = new List<Contact>();
        for(Integer i=1; i<7; i++) {
            Contact ctc = new Contact();
            ctc.FirstName = 'Test';
            ctc.LastName = 'Contact ' + i;
            contacts.add(ctc);
        }
        insert contacts;

        List<Lead> leads = new List<Lead>();
        for(integer i=1; i<7; i++) {
            integer j = i - 1;
            Lead ld = new Lead();
            ld.OwnerId = mkUser.Id;
            ld.FirstName = 'Test';
            ld.LastName = 'Lead ' + i;
            ld.Company = 'Test Account ' + i;
            ld.No_Sales_Call__c = false;
            ld.No_Sales_Email__c = false;
            ld.MKTO_Assigned__c = false;
            ld.AccountID__c = accts[j].Id;
            ld.LSID__c = accts[j].LSID__c;
            ld.Status = 'Prospect';
            ld.Partner_Lead_Owner__c = contacts[j].Id;
            ld.Region__c = 'APAC';
            leads.add(ld);
        }
        insert leads;

        List<Lead> leadlst = [Select Id, Name, LSID__c, MKTO_Assigned__c, AccountID__c, Partner_Lead_Owner__c,
                            Region__c, Country, Product_Type__c, Timestamp_Request_Contact__c, OwnerId from Lead];

        List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
        for(Integer i=0; i < leadlst.size(); i++){
            Lead ld = leadlst[i];
        ///////}
        for(Lead ld: leadlst) {///////
            LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
            lat.LeadId = ld.Id;
            lat.LeadLSID = ld.LSID__c;
            lat.AccountId = ld.AccountID__c;
            lat.PartnerLeadOwner = ld.Partner_Lead_Owner__c;
            lat.Country = 'China';
            lat.ProductType = COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO;
            lat.OwnerId = ld.OwnerId;
            lat.Region = 'APAC';
            lat.RecordTypeId = EntrCustRT;
            if(Math.mod(i, 2) == 0){
                lat.Industry = COMM_Constants.LEAD_Industry_HRED;
            }else if(Math.mod(i,3) == 0){
                lat.Industry = COMM_Constants.LEAD_Industry_HC;
            }else{
                lat.Industry = COMM_Constants.LEAD_Industry_TCS;
            }
            
            listAllLATs.add(lat);
        }
        listAllLATs = LeadAssignmentService.leadService(listAllLATs);
    }
    ---//
    
    //----
     * Date: 02/20/2020
     * This is a test Method for LeadAssignmentService.cls
     * Rule: Individual Country Routing - based on Country and Enterprise Segment 'Professional Visualization or GPU Virtualization'
             - Passing the first/only Lead with Enterprise Segment 'GPU Virtualization', so that it will be first record in the Map 'indvCtryEmailMap' of class 'LeadAssignmentService.cls'  
    ---//
    public static testMethod void LeadAssignementServiceCountryEntrpSegmentUSvGPU() {
    
      List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
      Map<String, User> UserEmailMap = new Map<String, User>();
      for(User usr: users) {
          UserEmailMap.put(usr.Email, usr);
      }
    
      String strAccLSID = 'TESTLSIDTEMPU1234X';
    
      List<Lead> leads = new List<Lead>();
      for(integer i=0; i<1; i++) {
          Lead led = new Lead();
          led.FirstName = 'Test';
          led.LastName = 'Lead ' + i;
          led.Company = 'Test Account';
          led.No_Sales_Call__c = false;
          led.No_Sales_Email__c = false;
          led.MKTO_Assigned__c = false;
          //led.LSID__c = strAccLSID + i;
          led.Status = 'Prospect';
          led.Product_Type__c = 'vGPU';
          leads.add(led);
      }    
      insert leads;
        
      // Country routing based on Enterprise Segment
      leads[0].Country = 'United States';
      leads[0].Enterprise_Segment__c = COMM_Constants.LEAD_ENTERPRISE_SEGMENT_GPUV;
      update leads;
    
      List<Lead> leadlst = [Select Id, Name, LSID__c, AccountID__c, Country, State, Product_Type__c, Enterprise_Segment__c, OwnerId from Lead]; 
                                                          
      List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
      for(Lead ld: leadlst) {
          LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
          lat.LeadId = ld.Id; 
          //lat.LeadLSID = ld.LSID__c;
          lat.AccountId = ld.AccountID__c;
          lat.Country = ld.Country;
          lat.State = ld.State;
          lat.ProductType = ld.Product_Type__c;
          lat.EnterpriseSegment = ld.Enterprise_Segment__c;
          lat.OwnerId = ld.OwnerId;
          listAllLATs.add(lat);
      }
      listAllLATs = LeadAssignmentService.leadService(listAllLATs);
                    
    } // end of LeadAssignementServiceCountryEntrpSegmentUSvGPU() 
    
    //---
     * Date: 02/20/2020
     * This is a test Method for LeadAssignmentService.cls
     * Rule: Individual Country Routing - based on Country and Enterprise Segment 'High Performance Computing or Deep Learning''
             - Passing the first/only Lead with Enterprise Segment 'GPU Virtualization', so that it will be first record in the Map 'indvCtryEmailMap' of class 'LeadAssignmentService.cls'  
    ----//
    public static testMethod void LeadAssignementServiceCountryEntrpSegmentUS1() {
    
      List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
      Map<String, User> UserEmailMap = new Map<String, User>();
      for(User usr: users) {
          UserEmailMap.put(usr.Email, usr);
      }
    
      String strAccLSID = 'TESTLSIDTEMPU1234X';
    
      List<Lead> leads = new List<Lead>();
      for(integer i=0; i<1; i++) {
          Lead led = new Lead();
          led.FirstName = 'Test';
          led.LastName = 'Lead ' + i;
          led.Company = 'Test Account';
          led.No_Sales_Call__c = false;
          led.No_Sales_Email__c = false;
          led.MKTO_Assigned__c = false;
          led.LSID__c = strAccLSID + i;
          led.Status = 'Prospect';
          leads.add(led);
      }    
      insert leads;
        
      // Country routing based on Enterprise Segment
      leads[0].Country = 'United States';
      leads[0].Enterprise_Segment__c = COMM_Constants.LEAD_ENTERPRISE_SEGMENT_HPC;
      update leads;
    
      List<Lead> leadlst = [Select Id, Name, LSID__c, AccountID__c, Country, Enterprise_Segment__c, OwnerId from Lead]; 
                                                          
      List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
      for(Lead ld: leadlst) {
          LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
          lat.LeadId = ld.Id; 
          //lat.LeadLSID = ld.LSID__c;
          lat.AccountId = ld.AccountID__c;
          lat.Country = ld.Country;
          lat.EnterpriseSegment = ld.Enterprise_Segment__c;
          lat.OwnerId = ld.OwnerId;
          listAllLATs.add(lat);
      }
      listAllLATs = LeadAssignmentService.leadService(listAllLATs);
                    
    } // end of LeadAssignementServiceCountryEntrpSegmentUS1()
    
    //---
     * Date: 02/20/2020
     * This is a test Method for LeadAssignmentService.cls
     * Rule: Individual Country Routing - based on Country and Enterprise Segment 'High Performance Computing or Deep Learning''
             - Passing the first/only Lead with Enterprise Segment 'GPU Virtualization', so that it will be first record in the Map 'indvCtryEmailMap' of class 'LeadAssignmentService.cls'  
    ---//
    public static testMethod void LeadAssignementServiceCountryEntrpSegmentUS2() {
    
      List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
      Map<String, User> UserEmailMap = new Map<String, User>();
      for(User usr: users) {
          UserEmailMap.put(usr.Email, usr);
      }
    
      String strAccLSID = 'TESTLSIDTEMPU1234X';
    
      List<Lead> leads = new List<Lead>();
      for(integer i=0; i<1; i++) {
          Lead led = new Lead();
          led.FirstName = 'Test';
          led.LastName = 'Lead ' + i;
          led.Company = 'Test Account';
          led.No_Sales_Call__c = false;
          led.No_Sales_Email__c = false;
          led.MKTO_Assigned__c = false;
          led.LSID__c = strAccLSID + i;
          led.Status = 'Prospect';
          leads.add(led);
      }    
      insert leads;
        
      // Country routing based on Enterprise Segment
      leads[0].Country = 'United States';
      leads[0].Enterprise_Segment__c = COMM_Constants.LEAD_ENTERPRISE_SEGMENT_DL;
      update leads;
    
      List<Lead> leadlst = [Select Id, Name, LSID__c, AccountID__c, Country, Enterprise_Segment__c, OwnerId from Lead]; 
                                                          
      List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
      for(Lead ld: leadlst) {
          LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
          lat.LeadId = ld.Id; 
          //lat.LeadLSID = ld.LSID__c;
          lat.AccountId = ld.AccountID__c;
          lat.Country = ld.Country;
          lat.EnterpriseSegment = ld.Enterprise_Segment__c;
          lat.OwnerId = ld.OwnerId;
          listAllLATs.add(lat);
      }
      listAllLATs = LeadAssignmentService.leadService(listAllLATs);
                    
    } // end of LeadAssignementServiceCountryEntrpSegmentUS2()  
    
    //---
     * @Manideep - 02/20/2020
     * "Lead Origin, Product Type, Region and with Country based logic for Lead Routing Rules"
     * This covers code coverage in 'Lead_tgr_cls.cls' and 'LeadAssignmentService.cls'
    ---//
    public static testMethod void LeadAssignementServiceLeadOriginProductTypeRegionCountryRules() {
            
      List<Lead> leads = new List<Lead>();
      for(integer i=0; i<1; i++) {
          Lead led = new Lead();
          led.FirstName = 'Test';
          led.LastName = 'Lead ' + i;
          led.Company = 'Test Account';
          led.No_Sales_Call__c = false;
          led.No_Sales_Email__c = false;
          led.MKTO_Assigned__c = false;
          led.Status = 'Prospect';
          led.Lead_Orgin__c = 'GLOBAL_DL_WF_2018_DL07_DGX Pod Promo Form (PUR)';
          led.Product_Type__c = 'DGX';
          led.Region__c = 'NALA';
          led.Country = 'Canada';
          leads.add(led);
       }    
       insert leads;
        
       leads[0].status = 'Marketing Qualified';
       update leads;
    
       List<Lead> leadlst = [Select Id, Name, AccountID__c, Country, Lead_Orgin__c, Product_Type__c, Region__c, OwnerId from Lead]; 
                                                          
       List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
       for(Lead ld: leadlst) {
           LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
           lat.LeadId = ld.Id; 
           lat.AccountId = ld.AccountID__c;
           lat.Country = ld.Country;
           lat.LeadOrigin = ld.Lead_Orgin__c;
           lat.ProductType = ld.Product_Type__c;
           lat.Region = ld.Region__c;
           lat.OwnerId = ld.OwnerId;
           listAllLATs.add(lat);
         }
         
         listAllLATs = LeadAssignmentService.leadService(listAllLATs);
               
    }  // LeadAssignementServiceLeadOriginProductTypeRegionCountryRules
    
    //----
     * @Manideep - 02/20/2020
     * "Lead Origin, Product Type, Region and without Country based logic for Lead Routing Rules"
     * This covers code coverage in 'Lead_tgr_cls.cls' and 'LeadAssignmentService.cls'
    ---//
    public static testMethod void LeadAssignementServiceLeadOriginProductTypeRegionEMEARule() {
            
      List<Lead> leads = new List<Lead>();
      for(integer i=0; i<1; i++) {
          Lead led = new Lead();
          led.FirstName = 'Test';
          led.LastName = 'Lead ' + i;
          led.Company = 'Test Account';
          led.No_Sales_Call__c = false;
          led.No_Sales_Email__c = false;
          led.MKTO_Assigned__c = false;
          led.Status = 'Prospect';
          led.Lead_Orgin__c = 'GLOBAL_DL_WF_2018_DL07_DGX Pod Promo Form (PUR)';
          led.Product_Type__c = 'DGX';
          led.Region__c = 'EMEA';
          leads.add(led);
       }    
       insert leads;
        
       leads[0].status = 'Marketing Qualified';
       update leads;
    
       List<Lead> leadlst = [Select Id, Name, AccountID__c, Country, Lead_Orgin__c, Product_Type__c, Region__c, OwnerId from Lead]; 
                                                          
       List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
       for(Lead ld: leadlst) {
           LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
           lat.LeadId = ld.Id; 
           lat.AccountId = ld.AccountID__c;
           lat.Region = ld.Region__c;
           lat.Country = ld.Country;
           lat.LeadOrigin = ld.Lead_Orgin__c;
           lat.ProductType = ld.Product_Type__c;
           lat.OwnerId = ld.OwnerId;
           listAllLATs.add(lat);
         }
         
         listAllLATs = LeadAssignmentService.leadService(listAllLATs);
               
    } // end of LeadAssignementServiceLeadOriginProductTypeRegionEMEARule()
    
    //---
     * Date: 07/31/2020
     * This is a test Method for LeadAssignmentService.cls
     * Rule: 'vGPU' Product Type, Region and Country Rule 
    ---//
    public static testMethod void LeadAssignementServicevGPUPrdTypRegCtry() {
    
      List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
      Map<String, User> UserEmailMap = new Map<String, User>();
      for(User usr: users) {
          UserEmailMap.put(usr.Email, usr);
      }
    
      String strAccLSID = 'TESTLSIDTEMPU1234X';
    
      List<Lead> leads = new List<Lead>();
      for(integer i=0; i<1; i++) {
          Lead led = new Lead();
          led.FirstName = 'Test';
          led.LastName = 'Lead ' + i;
          led.Company = 'Test Account';
          //led.LSID__c = strAccLSID + i;
          led.Status = 'Prospect';
          led.Region__c = 'APAC';
          leads.add(led);
      }    
      insert leads;
        
      // vGPU Product Type Region and Country based routing
      leads[0].Country = 'China';
      leads[0].Product_Type__c = 'vGPU';
      update leads;
    
      List<Lead> leadlst = [Select Id, Name, LSID__c, AccountID__c, Region__c, Country, State, Product_Type__c, Enterprise_Segment__c, OwnerId from Lead]; 
                                                          
      List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
      for(Lead ld: leadlst) {
          LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
          lat.LeadId = ld.Id; 
          //lat.LeadLSID = ld.LSID__c;
          lat.AccountId = ld.AccountID__c;
          lat.Region = ld.Region__c;
          lat.Country = ld.Country;
          lat.State = ld.State;
          lat.ProductType = ld.Product_Type__c;
          //lat.EnterpriseSegment = ld.Enterprise_Segment__c;
          lat.OwnerId = ld.OwnerId;
          listAllLATs.add(lat);
      }
      listAllLATs = LeadAssignmentService.leadService(listAllLATs);
                    
    } // end of LeadAssignementServicevGPUPrdTypRegCtry() 
    
    //---
     * Date: 07/31/2020
     * This is a test Method for LeadAssignmentService.cls
     * Rule: Based on Product Type, Company Type, Region and Country
    ---//
    public static testMethod void LeadAssignementServicevPrdTypCmpyTypRegCtry() {
    
      List<User> users = [Select Id, Email from User where isActive = true and FirstName = 'test'];
      Map<String, User> UserEmailMap = new Map<String, User>();
      for(User usr: users) {
          UserEmailMap.put(usr.Email, usr);
      }
    
      String strAccLSID = 'TESTLSIDTEMPU1234X';
    
      List<Lead> leads = new List<Lead>();
      for(integer i=0; i<1; i++) {
          Lead led = new Lead();
          led.FirstName = 'Test';
          led.LastName = 'Lead ' + i;
          led.Company = 'Test Account';
          //led.LSID__c = strAccLSID + i;
          led.Status = 'Prospect';
          led.Region__c = 'APAC';
          leads.add(led);
      }    
      insert leads;
        
      // vGPU Product Type Region and Country based routing
      leads[0].Country = 'Japan';
      leads[0].Product_Type__c = 'Automotive';
      leads[0].Company_Type__c = 'Engineering Service Vendor: Service Providers';
      update leads;
    
      List<Lead> leadlst = [Select Id, Name, LSID__c, AccountID__c, Region__c, Country, State, Product_Type__c, Enterprise_Segment__c, Company_Type__c, OwnerId from Lead]; 
                                                          
      List<LeadAssignmentTemplate> listAllLATs = new List<LeadAssignmentTemplate>();
      for(Lead ld: leadlst) {
          LeadAssignmentTemplate lat = new LeadAssignmentTemplate();
          lat.LeadId = ld.Id; 
          //lat.LeadLSID = ld.LSID__c;
          lat.AccountId = ld.AccountID__c;
          lat.Country = ld.Country;
          lat.State = ld.State;
          lat.ProductType = ld.Product_Type__c;
          //lat.EnterpriseSegment = ld.Enterprise_Segment__c;
          lat.Region = ld.Region__c;
          lat.CompanyType = ld.Company_Type__c;
          lat.OwnerId = ld.OwnerId;
          listAllLATs.add(lat);
      }
      listAllLATs = LeadAssignmentService.leadService(listAllLATs);
                    
    } // end of LeadAssignementServicevPrdTypCmpyTypRegCtry() 
    
    /*\/---
     * This is a test method for "LeadAssignment_Constants.cls"
    ---//
    private static testMethod void LeadAssgTemplateTM() {
      LeadAssignment_Constants varLAC = new LeadAssignment_Constants();
      varLAC.ccMethod();
    } 
    
    */
    
}