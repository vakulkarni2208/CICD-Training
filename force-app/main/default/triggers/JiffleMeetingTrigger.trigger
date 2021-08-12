trigger JiffleMeetingTrigger on jiffle__Meeting__c (after insert, after update) {
    try {
        list<MeetingQAs__c> lstMeetQA = new list<MeetingQAs__c>();
        list<ID> lstMeetingID = new list<ID>();
        set<String> setMeetingQestions = new set<String>();
        map<String, ID> mapQestionID = new map<String, ID>();
        for(jiffle__Meeting__c objMeet : Trigger.new) {
            if((Trigger.isInsert && objMeet.jiffle__JN_Custom_fields__c != '' && objMeet.jiffle__JN_Custom_fields__c != NULL) || (Trigger.isUpdate && objMeet.jiffle__JN_Custom_fields__c != '' && objMeet.jiffle__JN_Custom_fields__c != NULL && objMeet.jiffle__JN_Custom_fields__c != Trigger.oldMap.get(objMeet.id).jiffle__JN_Custom_fields__c )) {
                if(objMeet.jiffle__JN_Custom_fields__c != NULL) {
                    String[] questionAnswerArray = objMeet.jiffle__JN_Custom_fields__c.split('<br><br>');
                    for(String questionAnswerObj : questionAnswerArray) {
                        setMeetingQestions.add(questionAnswerObj.split(':')[0].trim());
                    }
                }
            }
        }
        list<MeetingQuestions__c> lstQuestions = [select ID, Question__c from MeetingQuestions__c where Question__c in :setMeetingQestions];
        if(lstQuestions.size() > 0) {
            for(MeetingQuestions__c objQuestion : lstQuestions) {
                if(setMeetingQestions.contains(objQuestion.Question__c)) {
                   setMeetingQestions.remove(objQuestion.Question__c); 
                }
                mapQestionID.put(objQuestion.Question__c, objQuestion.ID);
            }
        }
        lstQuestions.clear();
        if(setMeetingQestions.size() > 0) {
            for(String strQuestion : setMeetingQestions) {
                MeetingQuestions__c objQuestion = new MeetingQuestions__c(Question__c=strQuestion);
                lstQuestions.add(objQuestion);
            }
        }
        if(lstQuestions.size() > 0) {
            insert lstQuestions;
            for(MeetingQuestions__c objQuestion : lstQuestions) {
                mapQestionID.put(objQuestion.Question__c, objQuestion.ID);
            }
        }            
        for(jiffle__Meeting__c objMeet : Trigger.new) {
            if((Trigger.isInsert && objMeet.jiffle__JN_Custom_fields__c != '' && objMeet.jiffle__JN_Custom_fields__c != NULL) || (Trigger.isUpdate && objMeet.jiffle__JN_Custom_fields__c != '' && objMeet.jiffle__JN_Custom_fields__c != NULL && objMeet.jiffle__JN_Custom_fields__c != Trigger.oldMap.get(objMeet.id).jiffle__JN_Custom_fields__c )) {
                if(objMeet.jiffle__JN_Custom_fields__c != NULL) {
                    String[] questionAnswerArray = objMeet.jiffle__JN_Custom_fields__c.split('<br><br>');
                    for(String questionAnswerObj : questionAnswerArray) {
                        String[] questionVsAnswer = questionAnswerObj.split(':');
                        MeetingQAs__c objMeetQA = new MeetingQAs__c();
                        objMeetQA.MeetingId__c = objMeet.id;
                        //objMeetQA.Question__c = questionVsAnswer[0];
                        objMeetQA.QuestionID__c = mapQestionID.get(questionVsAnswer[0].trim());
                        questionVsAnswer.remove(0);
                        if(questionVsAnswer.size() > 0) {
                            objMeetQA.Answer__c = String.join(questionVsAnswer,':');
                        }
                        lstMeetQA.add(objMeetQA);
                        lstMeetingID.add(objMeet.id);
                    }
                }
            }
        }
        //Delete any existing QA for the meetings 
        list<MeetingQAs__c> lstExistingMeetQA = [select id from MeetingQAs__c where MeetingId__c in :lstMeetingID];
        if(lstExistingMeetQA.size() > 0) 
            delete lstExistingMeetQA;
        if(lstMeetQA.size() > 0) 
            insert lstMeetQA;
    } catch(Exception ex) {
        //log the error
    }
}