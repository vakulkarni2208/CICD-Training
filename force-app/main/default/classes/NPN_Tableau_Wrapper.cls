/*
    NPN TABLEAU
    2019.08.13 - pjena - Wrapper class for Tableau Calls
    
*/

public class NPN_Tableau_Wrapper {
    static string apiEndPoint = 'callout:NPN_TABLEAU_Endpoint'; //https://sbx-surf-npn.nvidia.com/api/3.2
    //static string apiEndPoint = 'callout:NPN_TABLEAU_Endpoint_prod'; //For prod testing from stage
    static string token;
    static string siteId;
    public static map<string, string> mapIDMResponseElements = new map<string, string>();
    
    //call syncWithTableau('20190924001@iamai.com', 'Viewer')
    public static void syncWithTableau(string newUser, string siteRole){
        signIn(mapIDMResponseElements);
        system.debug('***mapIDMResponseElements: ' + mapIDMResponseElements);
        token = mapIDMResponseElements.get('credentialstoken');
        siteId = mapIDMResponseElements.get('siteid');
        createTableauUser(newUser, siteRole, siteId, mapIDMResponseElements, token);
        signout(token);
    }
    
    
    public static map<string, string> createTableauUser(string userName, string siteRole, string siteId, map<string, string> mapIDMResponseElements, string authToken){
        Http http = new Http();
        string tableauUserName = userName;
        HttpRequest reqAddUser = new HttpRequest();
        reqAddUser.setEndpoint(apiEndPoint + '/sites/' + siteId + '/users');
        reqAddUser.setMethod('POST');
        reqAddUser.setHeader('Content-Type', 'application/xml;charset=UTF-8');
        reqAddUser.setHeader('X-Tableau-Auth', authToken);
        //Set the body as a JSON object
        string reqBody = '<tsRequest><user name="' + tableauUserName + '" siteRole="' + siteRole + '" authSetting="SAML"/></tsRequest>'; //siteRole=Viewer | SiteAdministratorCreator
        reqAddUser.setBody(reqBody);
        HttpResponse resAddUser = http.send(reqAddUser);
        system.debug(resAddUser.getBody());
    
        if (resAddUser.getStatusCode() == 201){
            system.debug('***The user ' + tableauUserName + ' is added to Tableau site');
            Dom.Document docx = new Dom.Document();
            docx.load(resAddUser.getBody());
            dom.XmlNode xroot = docx.getrootelement() ;
            walkThrough(xroot);
            mapIDMResponseElements.put('statuscode', '201');
            mapIDMResponseElements.put('iserror', 'false');
        }else if (resAddUser.getStatusCode() == 409){
            system.debug('***The user ' + tableauUserName + ' already exists on the site.');
            mapIDMResponseElements.put('statuscode', '409');
            mapIDMResponseElements.put('isexisting', 'true');
            mapIDMResponseElements.put('iserror', 'true');
        }else{
            system.debug('***The user ' + tableauUserName + ' could not be added to Tableau site');
            system.debug(resAddUser.getBody());
            mapIDMResponseElements.put('statuscode', string.valueof(resAddUser.getStatusCode()));
            mapIDMResponseElements.put('iserror', 'true');
        }        
        mapIDMResponseElements.put('responseStr', resAddUser.getBody());
        return mapIDMResponseElements;
    }


    public static map<string, string> getTableauUserId(string userName, string siteId, map<string, string> mapIDMResponseElements, string authToken){
        Http http = new Http();
        HttpRequest reqGetUserId = new HttpRequest();
        reqGetUserId.setEndpoint(apiEndPoint + '/sites/' + siteId + '/users?filter=name:eq:' + userName );
        reqGetUserId.setMethod('GET');
        reqGetUserId.setHeader('X-Tableau-Auth', authToken);
        HttpResponse resGetUserId = http.send(reqGetUserId);
        
        Dom.Document docx = new Dom.Document();
        docx.load(resGetUserId.getBody());
        dom.XmlNode xroot = docx.getrootelement() ;
        walkThrough(xroot);
        string tableauUserId;
        if (mapIDMResponseElements.get('paginationtotalAvailable') == '1'){
            mapIDMResponseElements.put('isexisting', 'true');
            mapIDMResponseElements.put('iserror', 'false');
            //tableauUserId = mapIDMResponseElements.get('userid');
        }
        mapIDMResponseElements.put('responseStr', resGetUserId.getBody());
        return mapIDMResponseElements;
    }
    
    public static map<string, string> removeTableauUser(string tableauUserId, string siteId, map<string, string> mapIDMResponseElements, string authToken){
        Http http = new Http();
        HttpRequest reqDeleteUser = new HttpRequest();
        reqDeleteUser.setEndpoint(apiEndPoint + '/sites/' + siteId + '/users/' + tableauUserId);
        reqDeleteUser.setMethod('DELETE');
        reqDeleteUser.setHeader('X-Tableau-Auth', authToken);
        HttpResponse resDeleteUser = http.send(reqDeleteUser);
        
        if(resDeleteUser.getBody()!='' && resDeleteUser.getBody()!= null) {        
            Dom.Document docx = new Dom.Document();
            docx.load(resDeleteUser.getBody());
            dom.XmlNode xroot = docx.getrootelement() ;
            walkThrough(xroot);
        }
        if (resDeleteUser.getStatusCode() == 204){
            mapIDMResponseElements.put('iserror', 'false');
        }else{
            mapIDMResponseElements.put('iserror', 'true');
        }
        mapIDMResponseElements.put('responseStr', resDeleteUser.getBody());
        return mapIDMResponseElements;
    }
    
    public static map<string, string> signIn(map<string, string> mapIDMResponseElements){
        Http http = new Http();
        HttpRequest reqSignin = new HttpRequest();
        reqSignin.setEndpoint(apiEndPoint + '/auth/signin');
        reqSignin.setMethod('POST');
        reqSignin.setHeader('Content-Type', 'application/xml;charset=UTF-8');
        //Set the body as a JSON object
        string reqBody = '<tsRequest><credentials name="'+ '{!$Credential.UserName}' + '"' + ' password="' + '{!$Credential.Password}' + '"><site contentUrl="" /></credentials></tsRequest>';
        reqSignin.setBody(reqBody);
    
        HttpResponse resSignin = http.send(reqSignin);
        
        //Parse the Callout Response
        Dom.Document docx = new Dom.Document();
        docx.load(resSignin.getBody());
        dom.XmlNode xroot = docx.getrootelement() ;
        walkThrough(xroot);
        
        if (resSignin.getStatusCode() == 200){
            mapIDMResponseElements.put('iserror', 'false');
        }
        //mapIDMResponseElements.put('responseStr', resSignin.getBody());
        
        return mapIDMResponseElements;
    
    }
    

    public static void signout(string authToken){
        Http http = new Http();
        HttpRequest reqSignout = new HttpRequest();
        reqSignout.setEndpoint(apiEndPoint + '/auth/signout');
        reqSignout.setMethod('POST');
        reqSignout.setHeader('Content-Length', '0');
        reqSignout.setHeader('X-Tableau-Auth', authToken);
        HttpResponse resSignout = http.send(reqSignout);
        system.debug(resSignout.getBody());
        if (resSignout.getStatusCode() == 204){
            system.debug('***Sign out succssful');
        }else{
            system.debug('***Sign out failed');
            system.debug(resSignout.getBody());
        }
    }

    //Parsing of IDM API Response
    public static void walkThrough(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            string nodeName = node.getName();
    
            //Nodes
            if (node.getText().trim() != '') {
                string nodeText = node.getText().trim();
                mapIDMResponseElements.put(nodeName, nodeText);
            }
    
            //Attributes in Node
            if (node.getAttributeCount() > 0) {
                for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
                    system.debug('***' + nodeName + node.getAttributeKeyAt(i) + ' = ' + node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
                    mapIDMResponseElements.put(nodeName + node.getAttributeKeyAt(i), node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)) );
                } 
            }
    
            for (Dom.XMLNode child: node.getChildElements()) {
                walkThrough(child);
            }
        }
    }
}