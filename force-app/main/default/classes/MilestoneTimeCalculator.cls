global class MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {   
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        System.debug('inside calculater function');
        Case c = [SELECT Severity__c FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        System.debug('Sevrity =' + c.Severity__c);
        System.debug('Milestone Name =' + mt.Name);
        if (c.Severity__c != null && mt.Name != null){
            System.debug('In side if --> Time = ' + ESP_Utility.getMilestoneSetting(mt.Name, c.Severity__c).Time__c);
        	return Integer.valueOf(ESP_Utility.getMilestoneSetting(mt.Name, c.Severity__c).Time__c);
        }
        return 0;
        /*if (c.Severity__c != null && c.Severity__c.equals('S1:_Catastrophic')){
            System.debug('IN Side S1 function');
            if (mt.Name != null && mt.Name.equals('Assign to NCR/JTP Agent')) { 
                System.debug('IN Side Agent 30 Min');
                return 1;}
            else if (mt.Name != null && mt.Name.equals('First response from Agent')) { 
                System.debug('IN Side First response 47 Min');
                return 60;} 
            else if (mt.Name != null && mt.Name.equals('Case Resolution Provided')) { 
                System.debug('IN Side Case Resolution 36 Min');
                return 360;}
            else if (mt.Name != null && mt.Name.equals('First Response from Designated Engineer')) { 
                System.debug('IN Side Case Resolution 36 Min');
                return 30;}
            else if (mt.Name != null && mt.Name.equals('First Response from Business Critical Support Queue')) { 
                System.debug('First Response from Business Critical Support Queue');
                return 30;}
            else { 
                System.debug('IN Side Else 7 Min');
                return 7; }
        }
        if (c.Severity__c != null && c.Severity__c.equals('S2:_Severe')){
            System.debug('IN Side S1 function');
            if (mt.Name != null && mt.Name.equals('Agent Assigned')) { 
                System.debug('IN Side Agent 30 Min');
                return 60;}
            else if (mt.Name != null && mt.Name.equals('First response from Agent')) { 
                System.debug('IN Side First response 47 Min');
                return 120;} 
            else if (mt.Name != null && mt.Name.equals('Case Resolution Provided')) { 
                System.debug('IN Side Case Resolution 36 Min');
                return 720;}
            else if (mt.Name != null && mt.Name.equals('First Response from Designated Engineer')) { 
                System.debug('IN Side Case Resolution 36 Min');
                return 30;}
            else if (mt.Name != null && mt.Name.equals('First Response from Business Critical Support Queue')) { 
                System.debug('First Response from Business Critical Support Queue');
                return 30;}
            else { 
                System.debug('IN Side Else 7 Min');
                return 7;}
        }
            if (c.Severity__c != null && c.Severity__c.equals('S3: Moderate')){
            System.debug('IN Side S1 function');
            if (mt.Name != null && mt.Name.equals('Agent Assigned')) { 
                System.debug('IN Side Agent 30 Min');
                return 120;}
            else if (mt.Name != null && mt.Name.equals('First response from Agent')) { 
                System.debug('IN Side First response 47 Min');
                return 240;} 
            else if (mt.Name != null && mt.Name.equals('Case Resolution Provided')) { 
                System.debug('IN Side Case Resolution 36 Min');
                return 1440;}
            else if (mt.Name != null && mt.Name.equals('First Response from Designated Engineer')) { 
                System.debug('IN Side Case Resolution 36 Min');
                return 30;}
            else if (mt.Name != null && mt.Name.equals('First Response from Business Critical Support Queue')) { 
                System.debug('First Response from Business Critical Support Queue');
                return 30;}
            else { 
                System.debug('IN Side Else 7 Min');
                return 7; }
            }  
         if (c.Severity__c != null && c.Severity__c.equals('S4: Minor/Cosmetic Defects')){
            System.debug('IN Side S1 function');
            if (mt.Name != null && mt.Name.equals('Agent Assigned')) { 
                System.debug('IN Side Agent 30 Min');
                return 120;}
            else if (mt.Name != null && mt.Name.equals('First response from Agent')) { 
                System.debug('IN Side First response 47 Min');
                return 240;} 
            else if (mt.Name != null && mt.Name.equals('Case Resolution Provided')) { 
                System.debug('IN Side Case Resolution 36 Min');
                return 360;}
            else if (mt.Name != null && mt.Name.equals('First Response from Designated Engineer')) { 
                System.debug('IN Side Case Resolution 36 Min');
                return 30;}
            else if (mt.Name != null && mt.Name.equals('First Response from Business Critical Support Queue')) { 
                System.debug('First Response from Business Critical Support Queue');
                return 30;}
            else { 
                System.debug('IN Side Else 7 Min');
                return 7; }
        }
           return 18;*/
        }                
    }