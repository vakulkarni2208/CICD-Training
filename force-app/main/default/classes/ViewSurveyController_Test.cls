@istest
private class ViewSurveyController_Test{
    //------------------------------------------------------------------------------//
    //------------------------------------------------------------------------------//
    private static Testmethod void testViewSurveyController() {
        
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc); 
        vsc.init();
        System.assert(vsc.allQuestionsSize == 4);
        System.assert(tu.surveyId != null);


        vsc.submitResults();
        for (SFQuestion q : vsc.allQuestions)
        {
            q.selectedOption = String.valueof(2);
            q.choices = String.valueof(2);
            q.selectedOptions = new List<String>();
            q.selectedOptions.add(String.valueof(2));
            vsc.submitResults();
        }
        //System.assertEquals(true, vsc.thankYouRendered);
        vsc.getResponses();
        vsc.resultPage();
        vsc.refreshQuestionList();
        String qn = vsc.questionName;
        List<SelectOption> optList = vsc.singleOptions;
        List<String> l = vsc.responses;
        Boolean q = vsc.qRequired;
        String type = vsc.questionType;
        Boolean b = vsc.questionRequired;
        new ViewSurveyController(new viewShareSurveyComponentController());
        //test something
    }


    private static Testmethod void testUpdateSurveyName() {
    
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyName = 'new name';
        vsc.resultPage();
        vsc.refreshQuestionList();
        Survey_Question__c question = new Survey_Question__c();
        question.Required__c = true;
        ViewSurveyController.checkRequired(Null, question);
        system.assert(vsc.updateSurveyName() == null);

    }


    private static Testmethod void testupdateSurveyThankYouAndLink() {
    
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);
        Apexpages.Standardcontroller stc;
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyThankYouText = 'new stuff';
        vsc.surveyThankYouURL = 'more new stff';
        system.assert(vsc.updateSurveyThankYouAndLink()==null);
    }


}