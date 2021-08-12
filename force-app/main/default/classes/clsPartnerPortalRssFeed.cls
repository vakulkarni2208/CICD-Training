/*  
 * read from a feed, return a list of feed entry records
 2016.03.21 - Code fix as the RSS feed structure got changed and the thumbnail node was not found. Method getSummaryImage() got changed
 */
public class clsPartnerPortalRssFeed {
    //public rssFeedController() { system.debug('rssFeedController constructor'); }
    Integer entriesCountd = 5; // provide a default for this 
    public integer getentriesToShow() { return entriesCountd; }
    public void setentriesToShow(integer i) { entriesCountd = i;}
    integer debug = 2;
    string feedURLd;
    
    //public void setFeedURL(String u) { 
    //      system.debug('set feed url '); 
    //      feedURLd=u; }
    public void setCompFeedURL(String u) { 
            system.debug('set feed url '); 
            feedURLd=u; }
    public String getCompFeedURL() { return feedURLd; }
    public String getFeedURL() { return feedURLd; }
         
    transient HttpResponse res = null;
    public  HttpResponse getResponse() { return this.res; }
    transient  XMLDom dom;

    public string feedcachename { get;set ;}
    
    public  RssEntry[] getfeedcontentfromCache() {
        RssEntry[] ret = new RssEntry[]{};
        Document d = null; 
        try { 
            d = [Select d.Body From Document d where name = :feedcachename limit 1];
        } catch(exception e) { 
            return ret; 
        }
    
        dom = new XMLDom(d.body.tostring());
        if (debug> 5) dom.dumpAll();
        integer i=1;
  
        for( xmldom.element e: dom.getElementsByTagName('entry')) {
            ret.add( new RssEntry( e , i++) );  
            if ( i> entriesCountd) break;
        }   

        if (ret.size() == 0 ) {  // look at alt formats
            list<xmldom.element> items  = dom.getElementsByTagName('item');
            // deal with different formats
            // example, community.salesforce.com has 
            // rss -> channel -> item list ( title, link, description pubDate, date, guid)         
            for( xmldom.element e:items ) {  
                if (debug > 0) { e.dumpAll(); }
                ret.add( new RssEntry( e , i++) );  
                if ( i> entriesCountd) break;
            }
        }
                
        return ret;
    } 
    public  RssEntry[] getfeedcontent() { 
    	system.debug('***Begin: Calls getfeedcontent()');
    	
    	system.debug('***Begin: Calls makeRequest()');
        makeRequest(getCompFeedURL());
        system.debug('***End: Calls makeRequest()');
        
        //if(res==null){return null;}
        string body;
        if(!test.isRunningTest()) {
            body = res.getBody();
        }else {
            body = 'test';
        }                
        system.debug( '***length :'+body.length());
 
        if (debug> 3) system.debug('****body' + body);
        
        RssEntry[] ret = new RssEntry[]{};
       //  return ret;
        dom = new XMLDom(body);
        if (debug> 3) dom.dumpAll(); 
           
        integer i=1;
  
        for( xmldom.element e: dom.getElementsByTagName('entry')) {
            ret.add( new RssEntry( e , i++) );  
            if ( i> entriesCountd) break;
        }   

        if (ret.size() == 0 ) {  // look at alt formats
            list<xmldom.element> items  = dom.getElementsByTagName('item');
            // deal with different formats
            // example, community.salesforce.com has 
            // rss -> channel -> item list ( title, link, description pubDate, date, guid)         
            for( xmldom.element e:items ) {  
                if (debug > 0) { 
                	system.debug('***Begin: Dump of all Elements: ');
                	e.dumpAll(); 
                	system.debug('***End: Dump of all Elements: ');
                }
                ret.add( new RssEntry( e , i++) );  
                if ( i > entriesCountd) break;
            }
        }
        system.debug('***End: Calls getfeedcontent()');  
        return ret;
    }
  
    public class RssEntry {
            
        public RssEntry(Xmldom.Element ein, integer index) { 
            e = ein; idx = index;
        }
        
        // some feeds return <date...
        // others return <created... parse both
       public string getDate2() { 
            try { 
                Pattern p = Pattern.compile('[TZ]'); // cleanup the feed provided datetime
                Matcher m = p.matcher(e.getValue('date'));
                Datetime t = Datetime.valueof( m.replaceAll(' ') ); 
                return '(' + t.format('MMMM d') + ')';  // format it
            } catch ( exception ex) {           
                // also parse this type of date string 
                // Wed, 30 Jan 2008 12:00:00 GMT
                return e.getValue('date');
            }
        } 
        
        public string getDate() { 
            try { 
                Pattern p = Pattern.compile('[TZ]'); // cleanup the feed provided datetime
                //Matcher m = p.matcher(e.getValue('created'));
                //Matcher m = p.matcher(e.getValue('published'));
                Matcher m = p.matcher(e.getValue('pubDate'));
                Datetime t = Datetime.valueof( m.replaceAll(' ') ); 
                return t.format('MMMM dd, yyyy');  // format it
                //return '(' + t.format('MMMM d') + ')</b>';  // format it
            } catch ( exception ex) {           
                // also parse this type of date string 
                // Wed, 30 Jan 2008 12:00:00 GMT
                //return e.getValue('created');
                system.debug('***Ex: ' + ex);
                return e.getValue('pubDate');
            }
        } 
        
        // some feeds differ in these details
        public integer getIndex() { return idx; }
        public string getContent() { 
            string ret = e.getValue('content'); 
            return ret;
        }
        
        //returns summary text without images
        public string getSummary() {
            string ret ;
            if(!test.isRunningTest()){ 
                ret = e.getValue('summary');
                //pjena
	            if (ret == null){
	            	 ret = e.getValue('description');
	            }
	            //end
            }else {ret = '';}
            
            
            
            //regular expression to match all HTML/XML tags
            
            string HTML_IMG_PATTERN = '<img.*? />';

            // compile the pattern     
            pattern myPattern = pattern.compile(HTML_IMG_PATTERN);

            // get your matcher instance
            matcher myMatcher = myPattern.matcher(ret);

            if (myMatcher.find()) 
            {
               //remove the tags     
               ret = myMatcher.replaceAll('');
            }
            return ret;
        }
        
        //returns image from summary text
        public string getSummaryImage() { 
            string ret = '';
            if(!test.isRunningTest()){
                XMLDOM.Element contentElement = e.getElementByTagName('thumbnail');
                if (contentElement != null) ret = contentElement.getAttribute('url');
            }else{
                ret = '';
            }
            
            /*
            //regular expression to match all HTML/XML tags
            
            string HTML_IMG_PATTERN = '<img.*? />';
            
            string HTML_IMG_HEIGHT_PATTERN = 'height="[0-9]*"';
            string HTML_IMG_WIDTH_PATTERN = 'width="[0-9]*"';
            
            string HTML_IMG_END_PATTERN = '/>';


            // compile the patterns
            pattern myPattern = pattern.compile(HTML_IMG_PATTERN);
            pattern myPatternHeight = pattern.compile(HTML_IMG_HEIGHT_PATTERN );
            pattern myPatternWidth = pattern.compile(HTML_IMG_WIDTH_PATTERN );
            pattern myPatternEnd = pattern.compile(HTML_IMG_END_PATTERN );

            // get your matcher instance
            matcher myMatcher = myPattern.matcher(ret);
            
            if (myMatcher.find()) 
            {
               //image tag
               ret = myMatcher.group(0);
               
               // resize height
               matcher myMatcherHeight = myPatternHeight.matcher(ret);
               ret = myMatcherHeight.replaceAll('height="115"');
               
               // resize width
               matcher myMatcherWidth = myPatternWidth.matcher(ret);
               ret = myMatcherWidth.replaceAll('width="179"'); 
               
               //matcher myMatcherEnd = myPatternEnd.matcher(ret);
               //ret = myMatcherWidth.replaceAll('class="thumb" />'); 
               
            }
            else {
                ret = '';
            }
            */
            return ret;
        }
        
        public string getTitle() { return e.getValue('title'); } 
        public string getHref() { 
            string ret = e.getValue('origLink'); 
            if ( ret == null ) ret   = e.getValue('link'); 
            return ret; 
        }  
        public string getAuthor() { 
            string ret = e.getValue('name'); 
            if ( ret == null ) ret   = e.getValue('creator'); 
            return ret;  
        }    

        Xmldom.Element e; 
        integer idx;    
    }        

    public void makeRequest(string url)  { // leaves result in res instance member
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('GET');    
        /* avoid getting more than we can process on the callout
         * max is 32000, more will throw an exception from the server
         * we could go back for a second range, but this will give ~10 normal blog entries
         */
        req.setHeader('Range','bytes=0-30000');  // not all feeds respect this
        req.setCompressed(true);
        //system.debug(req);
        try {
            Http http = new Http();
            res = http.send(req);
                        
			// below here is not tested by test methods, this is expected since tests stop at http.send();          
            
            if (res.getStatusCode() != 200 ) {
                //system.debug(res.toString());
                System.debug('***STATUS:'+res.getStatus());
                System.debug('***STATUS_CODE:'+res.getStatusCode());
                System.debug('***BODY: '+res.getBody());
            }
            
        } catch( System.Exception e) {
            System.debug('***ERROR: '+ e);
        }
    }
  
}