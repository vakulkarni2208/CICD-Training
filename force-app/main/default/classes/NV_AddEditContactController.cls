/**
 *  @name :     NV_AddEditContactController
 *  @description :      Controller of apex page NV_AddEditContact
                                Created for SDS-741
 */
global without sharing class NV_AddEditContactController {

private final Id acctId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].accountId;
public contact objContact;
private String strEmail;
private String strFirstName;
private String strLastName;
private String strName;

Set<String> picklistValues { get; set;}
public List<String> leftSelected {get; set;}
public List<String> rightSelected {get; set;}
Set<String> leftValues = new Set<String>();
Set<String> rightValues = new Set<String>();
public String objStr {get; set;}

/**
 *  @description : Initialization
 *  @param  : ApexPages.StandardController
 *  @return :
 */
public NV_AddEditContactController(ApexPages.StandardController stdCnt) {
	this.objContact = (Contact) stdCnt.getRecord();

	Set<String> picklistValues = new Set<String>();
	String excludedValues = 'MDF,POS,Compliance';
	for(Schema.PicklistEntry f : Contact.Role__c.getDescribe().getPicklistValues()) {
		if(!excludedValues.containsIgnoreCase(f.getValue())) {
			picklistValues.add(f.getValue());
		}
	}

	leftSelected = new List<String>();
	rightSelected = new List<String>();

	leftValues.addAll(picklistValues);
	if(objContact != null && objContact.Role__c != null) {
		for(String s : objContact.Role__c.split(';')) {
			leftValues.remove(s);
			rightValues.add(s);
		}
	}

	System.debug('--> Original objContact.Role__c '+objContact.Role__c);

	/*if(objContact != null) {
	        objStr = objContact.Role__c;
	   }*/

}

/**
 *  @description : This method creates a new temp contact request if contact new or existing contact does not have temp contact
                    record and sends it for approval.
                    If the contact exists along with the temp contact record, then it updates the existing temp contact record and
                    sends it for approval.
 *  @return : PageReference
 */
public PageReference saveContact() {
	strEmail = objContact.Email;
	strFirstName = objContact.FirstName;
	strLastName = objContact.LastName;
	strName = strFirstName + ' ' + strLastName;

	list<Contact> lstContact = [select id,name,AddEditTempContactID__c from Contact where (email =:strEmail or name = :strName) and accountId =:acctId and Id !=:objContact.Id];

	if(lstContact.size() > 0) {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Duplicate contact already exists:'+ lstContact[0].Name));
		return null;
	}

	else{
		objContact.accountId = acctId;

		String roles ='';

		System.debug('--> Original objContact.Role__c '+objContact.Role__c);

		for(String s : rightValues) {
			roles += s+';';
		}

		System.debug('--> roles  '+roles);
		if(String.isBlank(roles)) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The contact must have at least one role.'));
			return null;
		}
		// The contact exists without the temp contact record.
		if(objContact.Id != null && String.isBlank(objContact.AddEditTempContactID__c)) {

			Contact oldContact = [SELECT Id, FirstName, LastName, Phone, Role__c, Title, Community_User__c FROM Contact WHERE Id = :objContact.Id];

			Temporary_Contact__c objTemporaryContact = new Temporary_Contact__c();
			objTemporaryContact.First_Name__c = objContact.FirstName;
			objTemporaryContact.Last_Name__c = objContact.LastName;
			objTemporaryContact.Email__c = objContact.Email;
			objTemporaryContact.Phone__c = objContact.Phone;
			objTemporaryContact.Account_ID__c = acctId;
			objTemporaryContact.Role__c = roles;
			objTemporaryContact.Title__c= objContact.Title;
			objTemporaryContact.Status__c = 'Pending';
			objTemporaryContact.ContactId__c = objContact.Id;
			objTemporaryContact.Requested_By__c = UserInfo.getUserId();
			objTemporaryContact.OwnerId = UserInfo.getUserId();
			objTemporaryContact.Partner_User__c = oldContact.Community_User__c;
			objTemporaryContact.Reason_for_Deactivation_Deletion__c = '';

			objTemporaryContact.Action_requested__c = '';
			if(oldContact.FirstName != objContact.FirstName || oldContact.LastName != objContact.LastName) {
				objTemporaryContact.Action_requested__c = 'Update - (Name';
			}

			if (oldContact.Phone != objContact.Phone) {
				if(objTemporaryContact.Action_requested__c != null && objTemporaryContact.Action_requested__c.contains('Update -')) {
					objTemporaryContact.Action_requested__c += ', Phone';
				}else{ objTemporaryContact.Action_requested__c = 'Update - (Phone';    }
			}

			boolean flg = false;
			if((String.isBlank(oldContact.Role__c) && String.isNotBlank(roles)) ||
			   (String.isNotBlank(oldContact.Role__c) && String.isBlank(roles))) {
				flg = true;
			}

			if ((String.isNotBlank(oldContact.Role__c) && String.isNotBlank(roles))) {
				if(oldContact.Role__c.split(';').size() != roles.split(';').size()) {
					flg = true;
				}else {
					for(String rStr : oldContact.Role__c.split(';')) {
						if(!roles.contains(rStr)) {
							flg = true;
						}
					}
				}
			}

			if(flg) {
				if(objTemporaryContact.Action_requested__c != null && objTemporaryContact.Action_requested__c.contains('Update -')) {
					objTemporaryContact.Action_requested__c += ', Role';
				} else { objTemporaryContact.Action_requested__c = 'Update - (Role';     }
			}

			if (oldContact.Title != objContact.Title) {
				if(objTemporaryContact.Action_requested__c != null && objTemporaryContact.Action_requested__c.contains('Update -')) {
					objTemporaryContact.Action_requested__c += ', Title';
				} else { objTemporaryContact.Action_requested__c = 'Update - (Title'; }
			}

			if(String.isNotBlank(objTemporaryContact.Action_requested__c)) {
				objTemporaryContact.Action_requested__c += ')';

				insert objTemporaryContact;
				submitForApproval(objTemporaryContact.id);
			} else{
				//objTemporaryContact.Action_requested__c = 'Update';
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No changes are made to the contact'));
				return null;
			}
		}

		// The contact and its temp contact record both exist.
		else if(objContact.Id != null && !String.isBlank(objContact.AddEditTempContactID__c) ) {

			// if the temp contact record is already in approval process throw an error.
			Temporary_Contact__c tempCont = [SELECT Id, Status__c FROM Temporary_Contact__c WHERE Id = :Id.valueOf(objContact.AddEditTempContactID__c)];
			if('Pending'.equalsIgnoreCase(tempCont.Status__c)) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Contact edit request is already in process'));
				return null;
			}

			Contact oldContact = [SELECT Id, FirstName, LastName, Phone, Role__c, Title, Community_User__c FROM Contact WHERE Id = :objContact.Id];

			Temporary_Contact__c objTemporaryContact = new Temporary_Contact__c();
			objTemporaryContact.First_Name__c = objContact.FirstName;
			objTemporaryContact.Last_Name__c = objContact.LastName;
			objTemporaryContact.Email__c = objContact.Email;
			objTemporaryContact.Phone__c = objContact.Phone;
			objTemporaryContact.Role__c = roles;
			objTemporaryContact.Title__c= objContact.Title;
			objTemporaryContact.Status__c = 'Pending';
			objTemporaryContact.Id = Id.valueOf(objContact.AddEditTempContactID__c);

			objTemporaryContact.Requested_By__c = UserInfo.getUserId();
			objTemporaryContact.OwnerId = UserInfo.getUserId();
			objTemporaryContact.Partner_User__c = oldContact.Community_User__c;
			objTemporaryContact.Reason_for_Deactivation_Deletion__c = '';

			objTemporaryContact.Action_requested__c = '';
			if(oldContact.FirstName != objContact.FirstName || oldContact.LastName != objContact.LastName) {
				objTemporaryContact.Action_requested__c = 'Update - (Name';
			}

			if (oldContact.Phone != objContact.Phone) {
				if(objTemporaryContact.Action_requested__c != null && objTemporaryContact.Action_requested__c.contains('Update -')) {
					objTemporaryContact.Action_requested__c += ', Phone';
				}else{ objTemporaryContact.Action_requested__c = 'Update - (Phone';    }
			}

			boolean flg = false;
			if((String.isBlank(oldContact.Role__c) && String.isNotBlank(roles)) ||
			   (String.isNotBlank(oldContact.Role__c) && String.isBlank(roles))) {
				flg = true;
			}

			if ((String.isNotBlank(oldContact.Role__c) && String.isNotBlank(roles))) {
				if(oldContact.Role__c.split(';').size() != roles.split(';').size()) {
					flg = true;
				}else {
					for(String rStr : oldContact.Role__c.split(';')) {
						if(!roles.contains(rStr)) {
							flg = true;
						}
					}
				}
			}

			if(flg) {
				if(objTemporaryContact.Action_requested__c != null && objTemporaryContact.Action_requested__c.contains('Update -')) {
					objTemporaryContact.Action_requested__c += ', Role';
				} else { objTemporaryContact.Action_requested__c = 'Update - (Role';     }
			}

			if (oldContact.Title != objContact.Title) {
				if(objTemporaryContact.Action_requested__c != null && objTemporaryContact.Action_requested__c.contains('Update -')) {
					objTemporaryContact.Action_requested__c += ', Title';
				} else { objTemporaryContact.Action_requested__c = 'Update - (Title'; }
			}

			if(String.isNotBlank(objTemporaryContact.Action_requested__c)) {
				objTemporaryContact.Action_requested__c += ')';

				update objTemporaryContact;
				submitForApproval(objTemporaryContact.id);
			}else{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No changes are made to the contact'));
				return null;
			}
			//}
		} else {
			// Create new contact
			Temporary_Contact__c objTemporaryContact = new Temporary_Contact__c();
			objTemporaryContact.First_Name__c = objContact.FirstName;
			objTemporaryContact.Last_Name__c = objContact.LastName;
			objTemporaryContact.Email__c = objContact.Email;
			objTemporaryContact.Phone__c = objContact.Phone;
			objTemporaryContact.Account_ID__c = acctId;
			objTemporaryContact.Role__c = roles;
			objTemporaryContact.Title__c= objContact.Title;
			objTemporaryContact.Status__c = 'Pending';
			objTemporaryContact.Action_requested__c = 'New';
			objTemporaryContact.Requested_By__c = UserInfo.getUserId();
			objTemporaryContact.OwnerId = UserInfo.getUserId();

			insert objTemporaryContact;
			submitForApproval(objTemporaryContact.id);
		}
		return new PageReference('/apex/NV_ListPartnerContacts');
	}
}

/**
 *  @description    : Redirects to NV_ListPartnerContacts page
 *  @return : PageReference
 */
public PageReference cancelContact() {
	return new PageReference('/apex/NV_ListPartnerContacts');
}

/**
 * @name :      submitForApproval
 *  @description    : Submits the temporary contact record for approval
 *  @param : Id
 *  @return : void
 */
public static void submitForApproval(Id tempContactID) {
	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
	req1.setObjectId(tempContactID);
	Approval.ProcessResult result = Approval.process(req1);
}


/****** ********** Code snippet for multiselect picklist    ************************* */
/**
 * @ name getSelect
 * @return   PageReference
 */
public PageReference getSelect(){
	rightSelected.clear();
	for(String s : leftSelected) {
		leftValues.remove(s);
		if(!rightValues.contains(s)) {
			rightValues.add(s);
		}

	}
	return null;
}

/**
 * @name    getDeselect
 * @return  PageReference
 */
public PageReference getDeselect() {
	leftSelected.clear();
	for(String s : rightSelected) {
		rightValues.remove(s);
		leftValues.add(s);
		if(objContact != null) {
			objStr = objContact.Role__c;
			if(!String.isBlank(objStr)) {
				objContact.Role__c = objStr.remove(s);
			}
		}
	}
	return null;
}

/**
 * @name        getDeselectedValues
 * @return   List<SelectOption>
 */
public List<SelectOption> getDeselectedValues() {
	List<SelectOption> options = new List<SelectOption>();
	List<String> objList = new List<String>();
	set<String> objSet = new set<String>();

	objSet.addAll(leftValues);
	objList.addAll(objSet);
	objList.sort();
	for(String s : objList) {
		options.add(new SelectOption(s,s));
	}
	return options;
}

/**
 * @name    getSelectedValues
 * @return  List<SelectOption>
 */
public List<SelectOption> getSelectedValues() {
	List<SelectOption> options = new List<SelectOption>();
	List<String> objList = new List<String>();
	set<String> objSet = new set<String>();
	List<String> existingValues = new List<String>();

	objSet.addAll(rightvalues);

	if(objList.isEmpty() && !existingValues.isEmpty()) {
		objList.addAll(existingValues);
	}

	objList.addAll(objSet);
	objList.sort();
	for(String s : objList) {
		options.add(new SelectOption(s,s));
	}
	return options;
}
}