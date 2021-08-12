function GetRelContentIDs(curObjID)
	{
		var relContElem = curObjID + "_ContentDocumentRelatedList_body";
		var rc = "";
		var relatedContentElem = document.getElementById(relContElem);
	
		if (relatedContentElem != null)
		{
			var aList = relatedContentElem.getElementsByTagName("a");
			for (var i = 0; i < aList.length; i++)
            		{
		                var alink = aList[i].getAttribute("href");
		                if ( (alink !=null) && (alink != undefined) && ( (alink.indexOf("/068") === 0) || (alink.indexOf("javascript:srcUp(%27%2F068")) === 0)  )
		                {   
		                    rc = rc + alink.substr(alink.indexOf("068"), 15) + ",";
		                }
            		}
			if (rc.indexOf("068") > -1)
			{
				rc = rc.substring(0, rc.lastIndexOf(","));
			}
		}
		return rc;
	}
	
	function DSGetPageIDFromHref()
	{
		var r=window.location.href;
		var qm = r.indexOf("?");
		if (qm > -1)
		{
		   r = r.substr(0, qm);
		}
		r = r.substr(r.lastIndexOf("/")+1);
		return r;
	}
	
	function DSNS()
	{
	    var dsns_="dsfs__";
	    if (typeof(DSDevEnv)!="undefined")
	    {
	        if (DSDevEnv=="true")
	        {
	            dsns_ = "";
	        }
	    }
	    return dsns_
	}
	
	function getDnbLogo(){
		return "/resource/1478846183000/dsfs__DNB";
	}
	
	function getDnbCross(){
		return "/resource/1478846183000/dsfs__Cross";
	}
	
	function getjQueryUI(){
		return "/resource/1478846183000/dsfs__jqueryui";
	}
	
	function inIframe () {
	    try {
	        return window.self !== window.top;
	    } catch (e) {
	        return true;
	    }
	}
	
	function DocuSign_CreateEnvelope()
	{
		var sourceId = DSGetPageIDFromHref();
		var rc = GetRelContentIDs(sourceId);
		if(inIframe()){
			window.open("/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID="+sourceId+"&rc="+rc+"&nw=1", "Popup", "location=1, status=1, scrollbars=1, resizable=1, directories=1, toolbar=1, titlebar=1, width=1200");
		} else {
			window.location.href = "/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID="+sourceId+"&rc="+rc;
		}
	}
	
	function DocuSign_GetVerifyWithDnb(objectType)
	{
		var sourceId = DSGetPageIDFromHref();
		var rc = GetRelContentIDs(sourceId);
		var endPoint = "/apex/dsfs__DocuSign_VerifyWithDnb?SourceID="+sourceId+"&objectType="+objectType;
		
		return endPoint;
	}