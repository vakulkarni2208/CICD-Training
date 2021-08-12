trigger Dev_Contact_GDPR_tgr on Dev_Contact__c (before update, before insert) {
          
     
     Set<String> piiFields = new Set<String>();
     
     List<FieldDefinition> fields  = [SELECT QualifiedApiName,ComplianceGroup FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Dev_Contact__c'];
        for (FieldDefinition field: fields) {
            if (field.ComplianceGroup != null && field.ComplianceGroup.contains('PII')) {
                piiFields.add(field.QualifiedApiName);
            }
        }

    for (Dev_Contact__c devContact : Trigger.new) {
    
        Boolean isAnonymized = devContact.Anonymized__c;
    
        if (Trigger.isInsert && isAnonymized) {
             devContact.addError('Cannot insert anonymized data.');
        } else if (Trigger.isUpdate) {
        
        
            // Access the "old" and "new" record by its ID in Trigger.xxxMap
            Boolean wasAnonymized = Trigger.oldMap.get(devContact.Id).Anonymized__c;
            
            
            if (wasAnonymized) {
             
               if (!isAnonymized) {
                   devContact.addError('Cannot unanonymize the data.');
               } else {
                   devContact.addError('Cannot update anonymized contact.');
               }
               
            } else if (isAnonymized) {
            
                if (devContact.Anonymization_Reason__c == null) {
                    devContact.addError('Anonymization reason must be provided.');
                } else {
                
                    for (String piiField: piiFields) {
                        if (devContact.get(piiField) != null) {
                            Boolean isEmailField = false;
                            String piiFieldValue = devContact.get(piiField).toString();
                            String emailDomain = null;
                            if ('Email__c'.equals(piiField) || 'Email2__c'.equals(piiField) || 'Email3__c'.equals(piiField)) {
                                isEmailField = true;
                                String[] usernameAndDomain = piiFieldValue.split('@');
                                piiFieldValue = usernameAndDomain[0];
                                emailDomain = usernameAndDomain[1];
                            }
                            
                            //TODO: externalize and secure salt value
                            string hashKey = GDPR_Anonymization_Settings__c.getOrgDefaults().HashKey__c;
                            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashKey + piiFieldValue));
                            
                            String newValue = EncodingUtil.convertToHex(hash);
                            if (isEmailField) {
                                newValue = newValue + '@' + emailDomain;
                            }
                            
                            devContact.put(piiField, newValue);
                        }
                    }
                }
            }
        }
    
    }


}