@isTest
public class Test_RssFeed{
    
    public static testMethod void testunitTest() {  
        RssFeed  objRssFeed  = new RssFeed ();
        objRssFeed.setentriesToShow(1);
        objRssFeed.setCompFeedURL('');
        objRssFeed.getentriesToShow();
        objRssFeed.getCompFeedURL();
        objRssFeed.getFeedURL();
        objRssFeed.getResponse();
        document d = new document(Name='doc_Name',body=blob.valueOf('blob value'),FolderId=userInfo.getUserId());
        insert d;
        objRssFeed.feedcachename = d.Name;
        objRssFeed.getfeedcontentfromCache();
        objRssFeed.getfeedcontent();
        Xmldom.Element dom = new Xmldom.Element();
        RssFeed.RssEntry objRssEntry = new RssFeed.RssEntry(dom,1);
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