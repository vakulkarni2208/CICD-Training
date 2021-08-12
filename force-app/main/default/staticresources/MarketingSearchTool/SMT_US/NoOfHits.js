function callFunctionFromFlex(filename,itemthumbnail,downloadurl,documentType)
{
	var sys_url = "https://crm.nvidia.com/sap/bc/webdynpro/sap/z_portal_track_download";
	var crm_url = sys_url+"?app_group=CPI&FILE_NAME="+escape(filename)+"&FILE_PATH="+escape(downloadurl.trim())+"&FILE_THUMBNAIL="+escape(itemthumbnail.trim())+"&document_type="+documentType;
	frameCall(crm_url);
}
function frameCall(crm_url) 
{ 
	ifrm = document.createElement("IFRAME"); 
	ifrm.setAttribute("src", crm_url); 
	ifrm.style.display = "none";
	document.body.appendChild(ifrm); 
}


String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
}
