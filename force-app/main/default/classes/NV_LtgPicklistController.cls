public class NV_LtgPicklistController {
    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
        set<String> competencySet = getCurrentUserCompetencies();
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(competencySet.contains(pickListVal.getLabel())) {
                pickListValuesList.add(pickListVal.getLabel());
            }
        }     
        return pickListValuesList;
    }
    
    public static Set<String> getCurrentUserCompetencies(){
        set<String> competencySet = new set<String>();
        User currentUser = [select id,name,accountId from User where id=:UserInfo.getUserId()];
        list<Partner_Attribute__c> lstPA = [select id, name, Partner_Competency__c from Partner_Attribute__c where Account_Name__c=:currentUser.AccountID and Date_Competency_Terminated__c=null];
        for(Partner_Attribute__c PA : lstPA) {
            competencySet.add(PA.Partner_Competency__c);
        }
        return competencySet;
    }
}