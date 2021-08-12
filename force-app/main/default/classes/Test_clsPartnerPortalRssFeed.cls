@isTest
public class Test_clsPartnerPortalRssFeed{
    
    public static testMethod void testunitTest() {  
        clsPartnerPortalRssFeed  objclsPartnerPortalRssFeed  = new clsPartnerPortalRssFeed ();
        objclsPartnerPortalRssFeed.setentriesToShow(1);
        objclsPartnerPortalRssFeed.setCompFeedURL('');
        objclsPartnerPortalRssFeed.getentriesToShow();
        objclsPartnerPortalRssFeed.getCompFeedURL();
        objclsPartnerPortalRssFeed.getFeedURL();
        objclsPartnerPortalRssFeed.getResponse();
        document d = new document(Name='doc_Name',body=blob.valueOf('blob value'),FolderId=userInfo.getUserId());
        insert d;
        objclsPartnerPortalRssFeed.feedcachename = d.Name;
        objclsPartnerPortalRssFeed.getfeedcontentfromCache();
        objclsPartnerPortalRssFeed.getfeedcontent();
        Xmldom.Element dom = new Xmldom.Element();
        clsPartnerPortalRssFeed.RssEntry objRssEntry = new clsPartnerPortalRssFeed.RssEntry(dom,1);
        objRssEntry.getDate2();
        objRssEntry.getDate();
        objRssEntry.getIndex();
        objRssEntry.getContent();
        objRssEntry.getSummary();
        objRssEntry.getSummaryImage();
        objRssEntry.getTitle();
        objRssEntry.getAuthor();
    }
    
}