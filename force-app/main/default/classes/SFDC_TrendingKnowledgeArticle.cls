/*
Class name : SFDC_TrendingKnowledgeArticle
Type : WebService
Description : This class will send Trending articles to external systems
Date        Version        Modified By        Description of change
--------------------------------------------------------------------------------------------------------------------
17/09/19    1.0            Nilesh Adkar        SDS-1695:Service: Trending Knowledge Article API for Enterprise Support Webpage

*/
@RestResource(urlMapping='/KnowledgeArticles/TrendingKnowledgeArticle/*')
global with sharing class SFDC_TrendingKnowledgeArticle{

@HttpGet
global static List<Knowledge__kav> getTrendingArticles(){
    RestRequest req = RestContext.request;
    RestResponse res = new RestResponse();
    RestContext.response = res;
    List<Knowledge__ViewStat> lstKnowledgeViewStat = [SELECT ParentId FROM Knowledge__ViewStat ORDER BY NormalizedScore DESC NULLS LAST LIMIT 20];
    List<Knowledge__kav> lstKnowledgeKav = new List<Knowledge__kav>();
    List<Id> lstIds = new List<Id>();
    if(lstKnowledgeViewStat.isEmpty() && !Test.isRunningTest())
        return null;
    else{
        for(Knowledge__ViewStat tmpViewStat : lstKnowledgeViewStat ){
            lstIds.add(tmpViewStat.ParentId );
        }
        lstKnowledgeKav = [SELECT Title,Answer__c,ArticleNumber,ArticleTotalViewCount,Customer_URL__c,LastPublishedDate,Summary,UrlName FROM Knowledge__kav where KnowledgeArticleId in :lstIds and PublishStatus = 'Online'];
        res.responseBody = Blob.valueOf(JSON.serialize(lstKnowledgeKav ));
        return lstKnowledgeKav;
    }    
  }  
}