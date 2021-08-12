/*----------------------------------------------------------------------------------------------------------------------------------------------------
Class Name : NGC_Registry_Helper. Related to object DGX_Registry_Container__c
Description : This class contains all the methods that will operate on DGX_Registry_Container__c () NGC_Registry

Date        Version    Modified by        Change details
-------     -------    -------------      --------------------------------------------------------
21-5-2019     1.0      Nilesh Adkar        SDS-1415 : Helper methods for trigger to associate Contact and Account to NGC Registry.
  
------------------------------------------------------------------------------------------------------------------------------------------------------
*/

public class NGC_Registry_Helper{

// SDS-1415
public static void associateContactAndAccountWithNGC_Registry(List<DGX_Registry_Container__c> lstNewReg){
    set<string> setEmails = new set<string>();
    set<string> setSerialNo = new set<string>();
    for(DGX_Registry_Container__c tmp : lstNewReg){
        if(tmp.Email_Address__c !=null)  
            setEmails.add(tmp.Email_Address__c);
        if(tmp.Hardware_Serial_Number_PAK_Id__c !=null)
            setSerialNo.add(tmp.Hardware_Serial_Number_PAK_Id__c);
    }
    
    List<Entitlement> lstEnt = [select AccountId, Hardware_Serial_Number__c,PAK_ID__c from Entitlement where Hardware_Serial_Number__c in :setSerialNo or PAK_ID__c in :setSerialNo ORDER BY CreatedDate desc];
    Map<string, String> mapSerialAccount = new Map<string, String>(); 
    Map<string, String> mapSerialEntitlement = new Map<string, String>(); 
    for(Entitlement tmpEnt : lstEnt){
        if(tmpEnt.Hardware_Serial_Number__c !=null){
            mapSerialAccount.put(tmpEnt.Hardware_Serial_Number__c,tmpEnt.AccountId);
            if(mapSerialEntitlement!=null && !mapSerialEntitlement.containsKey(tmpEnt.Hardware_Serial_Number__c))
                mapSerialEntitlement.put(tmpEnt.Hardware_Serial_Number__c,tmpEnt.id);
            system.debug('***' + mapSerialEntitlement);
        }
        if(tmpEnt.PAK_ID__c !=null){
            mapSerialAccount.put(tmpEnt.PAK_ID__c,tmpEnt.AccountId);
            if(mapSerialEntitlement!=null && !mapSerialEntitlement.containsKey(tmpEnt.PAK_ID__c))
                mapSerialEntitlement.put(tmpEnt.PAK_ID__c,tmpEnt.id);
            system.debug('***' + mapSerialEntitlement);
        }
    }

    List<Contact> lstContacts = [select id, email,AccountId from Contact where email in :setEmails order by lastmodifieddate desc];
    Id ContactRecordTypeId = [SELECT DeveloperName,Id,SobjectType FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'SalesContact' limit 1].id;
    Map<string, Contact> mapEmailContact = new Map<string, Contact>();
    for(Contact tmpCon : lstContacts){
        if(mapEmailContact !=null && tmpCon.email !=null && !mapEmailContact.containsKey(tmpCon.email))
            mapEmailContact.put(tmpCon.email,tmpCon );
    }
    
    List<Contact> lstNewContacts = new List<Contact>();
    List<DGX_Registry_Container__c> lstNewRegNoContact = new List<DGX_Registry_Container__c>();
    
    Boolean isContactAssociated = false;
    system.debug('***' + mapSerialEntitlement);
    for(DGX_Registry_Container__c tmpReg : lstNewReg){
        if(tmpReg.Hardware_Serial_Number_PAK_Id__c !=null && mapSerialEntitlement!=null && mapSerialEntitlement.get(tmpReg.Hardware_Serial_Number_PAK_Id__c)!=null){
            tmpReg.Entitlement__c = mapSerialEntitlement.get(tmpReg.Hardware_Serial_Number_PAK_Id__c);
        }
        if(mapEmailContact!=null && tmpReg.Email_Address__c!=null && mapEmailContact.get(tmpReg.Email_Address__c)!=null){
            if(tmpReg.Contact__c == null){
                tmpReg.Contact__c = mapEmailContact.get(tmpReg.Email_Address__c).id;
                isContactAssociated = true;
            }    
            if(tmpReg.Account__c == null && mapEmailContact.get(tmpReg.Email_Address__c).AccountId !=null  && tmpReg.Hardware_Serial_Number_PAK_Id__c ==null )
                tmpReg.Account__c = mapEmailContact.get(tmpReg.Email_Address__c).AccountId;
            else if(tmpReg.Account__c == null && tmpReg.Hardware_Serial_Number_PAK_Id__c !=null && mapSerialAccount!=null && mapSerialAccount.get(tmpReg.Hardware_Serial_Number_PAK_Id__c)!=null)
                tmpReg.Account__c = mapSerialAccount.get(tmpReg.Hardware_Serial_Number_PAK_Id__c);                
        }
        else if(isContactAssociated == false && tmpReg.Contact__c == null && !Trigger.isUpdate){
            Contact con = new Contact();
            con.email = tmpReg.Email_Address__c;
            con.Phone= tmpReg.Phone_Number__c;
            con.firstName = tmpReg.FirstName__c;
            con.lastName = tmpReg.Last_Name__c;
            con.RecordTypeId = ContactRecordTypeId;
            if(tmpReg.Account__c == null && tmpReg.Hardware_Serial_Number_PAK_Id__c !=null && mapSerialAccount!=null && mapSerialAccount.get(tmpReg.Hardware_Serial_Number_PAK_Id__c)!=null)
                con.accountId = mapSerialAccount.get(tmpReg.Hardware_Serial_Number_PAK_Id__c);
            lstNewContacts.add(con);
            lstNewRegNoContact.add(tmpReg);
        }
    }
    insert lstNewContacts;
    for(Contact tmpCon : lstNewContacts){
        mapEmailContact.put(tmpCon.email,tmpCon );
    }
    for(DGX_Registry_Container__c tmpReg : lstNewRegNoContact){
        if(mapEmailContact!=null && tmpReg.Email_Address__c!=null && mapEmailContact.get(tmpReg.Email_Address__c)!=null){
            tmpReg.Contact__c = mapEmailContact.get(tmpReg.Email_Address__c).id;
            tmpReg.Account__c = mapEmailContact.get(tmpReg.Email_Address__c).AccountId;
        }
    }
    
}

}