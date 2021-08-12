/**
 * The class is used to invoke callouts in IDM and RMA contexts.
 * @author - Santoshi (Perficient)
 *
 * ***************************************************************************************************
 * Moon (Perficient) | 02/12/2018      | If Country is not US or CA, use 'NA' for state.
 * Moon (Perficient) | 03/07/2018      | remove wsdl:_BAR_gridEval_BAR_.
 * Moon (Perficient) | 03/15/2018      | As it may cause problem in IDM, we put 'NA' for all countries and states.
 *                                       Also we do not send company name and account name.
 * Moon (Perficient) | 03/28/2018      | Added stripCDATA() method to strip CDATA tag to get exact error message. 
 * PJENA (NVIDIA)    | 4/8/2018        | Add CDATA section to the request XMLs so escape sepcial characters in Contact.Account.Name like &
 */
public virtual without sharing class RMA_IDM_Callouts extends PRFT_DomainLayer {
  public String TransactionId = '';
    public RMA_IDM_Callouts() {
        
    }

    /**
     * Invokes RMA Callouts when RMA is saved
     */
    public String invokeRMACallout(String xbody){
        System.debug('checking request body--'+xbody);
       PRFT_Http htp = new PRFT_Http('callout:SAP_RMA',
            xbody,'text/xml','POST','');
       System.debug('checking response--'+htp.responseBody);
       if(htp.statusCode >=200 && htp.statusCode<400){
         return htp.responseBody;
       } else {
         return 'Callout Exception:'+htp.errorMessage;
       }
    }

  /**
   * Invokes RMA Callouts when RMA is saved
   */
  public static String invokeStaticRMACallout(String xbody){
    System.debug('checking request body--'+xbody);
       PRFT_Http htp = new PRFT_Http('callout:SAP_RMA',
            xbody,'text/xml','POST','');
       System.debug('checking response--'+htp.responseBody);
       if(htp.statusCode >=200 && htp.statusCode<400){
         return htp.responseBody;
       } else {
         return 'Callout Exception:'+htp.errorMessage;
       }
    }

  /**
   * Invokes callouts to create DGX user
   */
  public String invokeIDMDGXUserCreationCallout(String contactId,String Language,String userId){
       Contact con = getContact(contactId);
       Language = 'en';
       // creates request string dgx registration.
       String xbody = createXMLRequestForDGXRegistration(con,Language,'1',userId);
       PRFT_Http htp = new PRFT_Http('callout:IDM_Endpoint',
            xbody,'application/xml','POST','');
       System.debug('checking response--'+htp.responseBody);
       if(htp.statusCode >=200 && htp.statusCode<400){
         return parseResponse(htp.responseBody);
       } else {
         return 'Callout Exception:'+htp.errorMessage;
       }
    }


  /**
   * Invokes callouts to deactivate DGX user
   */
  public String invokeIDMDGXUserDeactivationCallout(String contactId,String Language,String userId){
    Contact con = getContact(contactId);
    Language = 'en';
       // creates request string dgx registration.
    String xbody = createXMLRequestForDGXRegistration(con,Language,'0', userId);
    System.debug('checking request body--'+xbody);
       PRFT_Http htp = new PRFT_Http('callout:IDM_Endpoint',
            xbody,'application/xml','POST','');
       System.debug('checking response--'+htp.responseBody);
       if(htp.statusCode >=200 && htp.statusCode<400){
        return parseResponse(htp.responseBody);
        // return htp.responseBody;
       } else {
         return 'Callout Exception:'+htp.errorMessage;
       }
    }


  /**
   * Invokes Callouts to activate Grid User
   */
  public String invokeIDMGridUserCreationCallout(String contactId,String Language,String userId){
      Contact con = getContact(contactId);
      Language = 'en';
      // Registers service cloud role for grid
       String xbody = createXMLRequestForGridRegistration(con,Language,'T',userId);
    System.debug('checking request body--'+xbody);
       PRFT_Http htp = new PRFT_Http('callout:IDM_Endpoint',
            xbody,'application/xml','POST','');
       System.debug('checking response--'+htp.responseBody);
       if(htp.statusCode >=200 && htp.statusCode<400){
         return parseResponse(htp.responseBody);
       } else {
         return 'Callout Exception:'+htp.errorMessage;
       }
    }

  /**
   * Invokes callout to deactivate Grid user
   */
  public String invokeIDMGridUserDeactivationCallout(String contactId,String Language,String UserId){
        Contact con = getContact(contactId);
        Language = 'en';
      // Registers service cloud role for grid
       String xbody = createXMLRequestForGridRegistration(con,Language,'F',UserId); 
       System.debug('checking request body--'+xbody);
       PRFT_Http htp = new PRFT_Http('callout:IDM_Endpoint',
            xbody,'application/xml','POST','');
       System.debug('checking response--'+htp.responseBody);
       if(htp.statusCode >=200 && htp.statusCode<400){
         return parseResponse(htp.responseBody);
       } else {
         return 'Callout Exception:'+htp.errorMessage;
       }
    }

  /**
   * Invokes callout to deactivate Grid user
   */
  public String invokeIDMCommunityUserDeactivationCallout(string strEmail){
    // Registers service cloud role for grid
    String xbody = createCommunityUserDeactivationRequest(strEmail); 
    System.debug('checking request body--'+xbody);
    PRFT_Http htp = new PRFT_Http('callout:IDM_Endpoint',
          xbody,'application/xml','POST','');
    System.debug('checking response--'+htp.responseBody);
    if(htp.statusCode >=200 && htp.statusCode<400){
      return parseResponse(htp.responseBody);
    } else {
      return 'Callout Exception:'+htp.errorMessage;
    }
  }   
    private static string createCommunityUserDeactivationRequest(string strEmail){
      string xbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsdl="http://tews6/wsdl">' + 
      '<soapenv:Header/>' + 
      '<soapenv:Body>' + 
         '<wsdl:DeProvisioningRole>' + 
            '<wsdl:DeProvisioningRoleSearch>' + 
           '<Filter index="0">' + 
             '<Field>%USER_ID%</Field>' + 
             '<Op>EQUALS</Op>' + 
             '<Value>' + strEmail +'</Value>' + 
           '</Filter>' + 
            '</wsdl:DeProvisioningRoleSearch>' + 
            '<wsdl:DeProvisioningRoleProfileTab/>' + 
            '<wsdl:DeProvisioningRoleUserAccessRolesTab>' + 
               '<wsdl:UserMemberAccessRoles>' + 
                  '<wsdl:remove index="0">' + 
                     '<wsdl:Name>ServiceCloudAccessRole</wsdl:Name>' + 
                  '</wsdl:remove>' + 
               '</wsdl:UserMemberAccessRoles>' + 
            '</wsdl:DeProvisioningRoleUserAccessRolesTab>' + 
         '</wsdl:DeProvisioningRole>' + 
      '</soapenv:Body>' + 
   '</soapenv:Envelope>';
      return xbody;
    }    
    /**
     * Creates request String for DGX Registration
     * 2/12/2018 If Country is not US or CA, use 'NA' for state.
     */
    public String createXMLRequestForDGXRegistration(Contact con,String Language,String activateFlag,String userId){
          if(String.isBlank(con.IDM_CountryCode__c) || con.IDM_CountryCode__c.length()>2){
            con.IDM_CountryCode__c = con.MailingCountryCode;
            System.debug('Setting country code--');
          }
          String stateCode = con.MailingStateCode;
          if(con.IDM_CountryCode__c != 'US' && con.IDM_CountryCode__c != 'CA'){
              stateCode = 'NA';
          }
         String xbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">    <soapenv:Header/>    <soapenv:Body>  ';    
          xbody += ' <wsdl:DGXServiceCloudUserRegAPI> <wsdl:DGXServiceCloudUserRegAPIObjectProfileTab>' ;
          xbody += '<wsdl:_BAR_country_BAR_>' + 'NA' +'</wsdl:_BAR_country_BAR_>';
          xbody += '<wsdl:_BAR_postalCode_BAR_>' +con.MailingPostalCode+'</wsdl:_BAR_postalCode_BAR_>';
          xbody += '<wsdl:_BAR_jobRole_BAR_>' +'Other'+'</wsdl:_BAR_jobRole_BAR_>';
          xbody += '<wsdl:_BAR_industry_BAR_>' +'Other'+'</wsdl:_BAR_industry_BAR_>';
          xbody += '<wsdl:_BAR_state_BAR_>' +'NA'+'</wsdl:_BAR_state_BAR_>';
          xbody += '<wsdl:_BAR_eMailAddress_BAR_>' +con.Email+'</wsdl:_BAR_eMailAddress_BAR_>';
          xbody += '<wsdl:_BAR_firstName_BAR_>' +con.firstName+'</wsdl:_BAR_firstName_BAR_>';
          xbody += '<wsdl:_BAR_lastName_BAR_>' +con.lastName +'</wsdl:_BAR_lastName_BAR_>';
          xbody += '<wsdl:_BAR_company_BAR_><![CDATA[' +con.Account.Name +']]></wsdl:_BAR_company_BAR_>';
        //  xbody += '<wsdl:_BAR_gridEval_BAR_>' + con.CompanyName__c +'</wsdl:_BAR_gridEval_BAR_>';
          
          xbody += '<wsdl:_BAR_phone_BAR_>' +con.Phone+'</wsdl:_BAR_phone_BAR_>';
          xbody += '<wsdl:_BAR_street1_BAR_><![CDATA[' +con.MailingStreet +']]></wsdl:_BAR_street1_BAR_>';
          xbody += '<wsdl:_BAR_street2_BAR_><![CDATA[' +con.Mailing_Street_2__c+']]></wsdl:_BAR_street2_BAR_>';
          xbody += '<wsdl:_BAR_city_BAR_><![CDATA[' +con.MailingCity+']]></wsdl:_BAR_city_BAR_>';
          xbody += '<wsdl:_BAR_termCondFlag_BAR_>' +'1'+'</wsdl:_BAR_termCondFlag_BAR_>';
          xbody += '<wsdl:_BAR_userID_BAR_>' +con.Email+'</wsdl:_BAR_userID_BAR_>';
          xbody += '<wsdl:_BAR_key_BAR_>' +'NA'+'</wsdl:_BAR_key_BAR_>';
          xbody += '<wsdl:_BAR_companyIntrawareID_BAR_>' +'NA'+'</wsdl:_BAR_companyIntrawareID_BAR_>';
          xbody += '<wsdl:_BAR_active_BAR_>' +activateFlag+'</wsdl:_BAR_active_BAR_>';
          xbody += '<wsdl:_BAR_emailTemplate_BAR_>' +Label.IDM_DGX_Template+'</wsdl:_BAR_emailTemplate_BAR_>';
          xbody += '<wsdl:_BAR_preferredLanguage_BAR_>' +Language+'</wsdl:_BAR_preferredLanguage_BAR_>';
          xbody += '<wsdl:_BAR_serviceCloudUserID_BAR_>' +userId+'</wsdl:_BAR_serviceCloudUserID_BAR_>';
          xbody += '  </wsdl:DGXServiceCloudUserRegAPIObjectProfileTab> </wsdl:DGXServiceCloudUserRegAPI>' ;
          xbody += '  </soapenv:Body> </soapenv:Envelope>';
        return xbody;
    }


     /**
     * Creates request String for Grid Registration
     * 2/12/2018 If Country is not US or CA, use 'NA' for state.
     */
    public String createXMLRequestForGridRegistration(Contact con,String Language,String activateFlag,String userId){
          if(String.isBlank(con.IDM_CountryCode__c) || con.IDM_CountryCode__c.length()>2){
              con.IDM_CountryCode__c = con.MailingCountryCode;
              System.debug('Setting country code--');
          }
          String stateCode = con.MailingStateCode;
          if(con.IDM_CountryCode__c != 'US' && con.IDM_CountryCode__c != 'CA'){
            stateCode = 'NA';
          }
         String xbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">    <soapenv:Header/>    <soapenv:Body>  ';    
          xbody += ' <wsdl:GRIDServiceCloudUserRegAPI> <wsdl:GRIDServiceCloudUserRegAPIObjectProfileTab>' ;
          xbody += '<wsdl:_BAR_eMailAddress_BAR_>' +con.Email+'</wsdl:_BAR_eMailAddress_BAR_>';
          xbody += '<wsdl:_BAR_firstName_BAR_>' +con.firstName+'</wsdl:_BAR_firstName_BAR_>';
          xbody += '<wsdl:_BAR_lastName_BAR_>' +con.lastName +'</wsdl:_BAR_lastName_BAR_>';
          xbody += '<wsdl:_BAR_company_BAR_><![CDATA[' +con.Account.Name +']]></wsdl:_BAR_company_BAR_>';
          xbody += '<wsdl:_BAR_industry_BAR_>' +'Other'+'</wsdl:_BAR_industry_BAR_>';
          xbody += '<wsdl:_BAR_country_BAR_>' + 'NA' +'</wsdl:_BAR_country_BAR_>';
          xbody += '<wsdl:_BAR_postalCode_BAR_>' +con.MailingPostalCode+'</wsdl:_BAR_postalCode_BAR_>';
          xbody += '<wsdl:_BAR_jobRole_BAR_>' +'Other'+'</wsdl:_BAR_jobRole_BAR_>';
          xbody += '<wsdl:_BAR_key_BAR_>' +'NA'+'</wsdl:_BAR_key_BAR_>';
        //  xbody += '<wsdl:_BAR_gridEval_BAR_>' +con.CompanyName__c +'</wsdl:_BAR_gridEval_BAR_>';
          xbody += '<wsdl:_BAR_userID_BAR_>' +con.Email+'</wsdl:_BAR_userID_BAR_>';
          xbody += '<wsdl:_BAR_state_BAR_>' + 'NA' +'</wsdl:_BAR_state_BAR_>';
          xbody += '<wsdl:_BAR_phone_BAR_>' +con.Phone+'</wsdl:_BAR_phone_BAR_>';
          xbody += '<wsdl:_BAR_city_BAR_><![CDATA[' +con.MailingCity+']]></wsdl:_BAR_city_BAR_>';
          xbody += '<wsdl:_BAR_companyIntrawareID_BAR_>' +'NA'+'</wsdl:_BAR_companyIntrawareID_BAR_>'; 
          
          
          xbody += '<wsdl:_BAR_street1_BAR_><![CDATA[' +con.MailingStreet +']]></wsdl:_BAR_street1_BAR_>';
          xbody += '<wsdl:_BAR_street2_BAR_><![CDATA[' +con.Mailing_Street_2__c+']]></wsdl:_BAR_street2_BAR_>';
          xbody += '<wsdl:_BAR_termCondFlag_BAR_>' +'true'+'</wsdl:_BAR_termCondFlag_BAR_>';
          xbody += '<wsdl:_BAR_active_BAR_>' +activateFlag+'</wsdl:_BAR_active_BAR_>';
          xbody += '<wsdl:_BAR_emailTemplate_BAR_>' +Label.IDM_Grid_Template+'</wsdl:_BAR_emailTemplate_BAR_>';
          xbody += '<wsdl:_BAR_language_BAR_>' +Language+'</wsdl:_BAR_language_BAR_>';
          xbody += '<wsdl:_BAR_serviceCloudUserID_BAR_>' +UserId+'</wsdl:_BAR_serviceCloudUserID_BAR_>';
          xbody += '<wsdl:HistoryEntry> <wsdl:Message> </wsdl:Message>  <wsdl:StakeHolder> </wsdl:StakeHolder></wsdl:HistoryEntry>';
          xbody += '  </wsdl:GRIDServiceCloudUserRegAPIObjectProfileTab> </wsdl:GRIDServiceCloudUserRegAPI>' ;
          xbody += '  </soapenv:Body> </soapenv:Envelope>';
        return xbody;
    }
   /* 
    * Retrieve the Contact record information. 
    * This information is used to populate the callout request prior to the external call
    */
     public Contact getContact(String conId){
      Contact con = new Contact();
        List<Contact> conList = (List<Contact>) queryObj('Contact','WHERE Id ='+'\''+conId+'\'', 'Select Account.Name, ');
        if(!conList.isEmpty()){
          con = conList[0];

        }
        return con;
     }

   /* 
    * CDATA is stripped to read the text information
    */
    private String stripCDATA(String str){
        str = str.replaceAll('\n','');
        System.debug('>>remove cr>>'+str); 
        Pattern p = Pattern.compile('<!\\[CDATA\\[(.*?)\\]\\]>');
        Matcher m = p.matcher(str);
        while(m.find()) {
            str = str.replace(m.group(), m.group(1).escapeXml());
        }
        System.debug('>>remove CDATA>>'+str);      
        return str;  
    } 
   /* 
    * Parse the callout response
    */
     private String parseResponse(String res){
        res = stripCDATA(res);
        XmlStreamReader xsr = new XmlStreamReader(res);
        DOM.Document doc=new DOM.Document();
        doc.load(res);
        DOM.XmlNode rootNode=doc.getRootElement();
        String resp = parseXMLIDM(rootNode);
        System.debug('Checking parsed response--'+resp);
        return resp;
     }
   /* 
    * Parse the XML IDM response for transaction Id
    */
     private String parseXMLIDM(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug('---checking node name---'+node.getName());
            if(node.getName() == 'faultcode'){
                TransactionId = TransactionId + 'Callout Exception ';
                system.debug('---checking TransactionId fault code--'+TransactionId);
            }  
            if(node.getName()=='ImsStatus'){
                DOM.XMLNode[] tempNode = node.getChildElements();
                RMA__c rmRes = new RMA__c();
                for(Dom.XMLNode RMAchild: tempNode){
                    system.debug('---checking RMAchild name---'+RMAchild.getName());
                    if(RMAchild.getName() == 'transactionId'){
                        TransactionId = 'Success - ' + RMAchild.getText().trim();
                        return TransactionId;             
                    }
                    node.removeChild(RMAchild);
                }
            }
            if(node.getName()=='exception'){
                DOM.XMLNode[] tempNode = node.getChildElements();
                RMA__c rmRes = new RMA__c();
                for(Dom.XMLNode RMAchild: tempNode){
                    {
                        TransactionId = TransactionId+ RMAchild.getName() + '- ' + RMAchild.getText()+' ';
                        system.debug('---checking TransactionId---'+RMAchild.getText());
                    }
                    node.removeChild(RMAchild);
                }
            }
            for (Dom.XMLNode child: node.getChildElements()) {
                parseXMLIDM(child);
            }
        }
        return TransactionId;
    }
}