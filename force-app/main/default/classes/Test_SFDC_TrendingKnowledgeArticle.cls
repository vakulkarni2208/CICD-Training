@isTest(seeAllData=false)
global class Test_SFDC_TrendingKnowledgeArticle {

@isTest
static void testCallout() {
    Knowledge__kav kb = new Knowledge__kav(Title='title', urlName='google');
    insert kb;
    kb = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :kb.Id];    
    KbManagement.PublishingService.publishArticle(kb.KnowledgeArticleId, true);
    Test.startTest();
    RestRequest request = new RestRequest();
    request.requestUri = Url.getOrgDomainUrl().toExternalForm()+ '/services/apexrest/KnowledgeArticles/TrendingKnowledgeArticle';
    request.httpMethod = 'GET';
    RestContext.request = request;
    List<Knowledge__kav> lstKw = SFDC_TrendingKnowledgeArticle.getTrendingArticles();    
    Test.stopTest();
}

}