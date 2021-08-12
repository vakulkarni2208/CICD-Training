@isTest
public class Test_clsPartnerPortalXMLDom{
    
    public static testMethod void testunitTest() {  
    
        clsPartnerPortalXMLDom  objXMLD = new clsPartnerPortalXMLDom();
        clsPartnerPortalXMLDom  objXMLD1 = new clsPartnerPortalXMLDom('');
        objXMLD1.getElementByPath('');
        objXMLD1.dumpAll();        
        clsPartnerPortalXMLDom.Element obj = new clsPartnerPortalXMLDom.Element();       
        List<clsPartnerPortalXMLDom.Element> lstElement = new List<clsPartnerPortalXMLDom.Element>();
        objXMLD1.dumpList(lstElement);
        objXMLD1.getElementsByPath('');
        objXMLD1.getElementByTagName('');
        objXMLD1.getElementsByTagName('');
        objXMLD1.ownerDocument();
        objXMLD1.toXmlString();          
        obj.getAttribute('');
        obj.appendChild(obj);
        obj.removeChild(obj);
        obj.getElementByTagName('');
        obj.getValue('');
        obj.firstChild();
        obj.textContent();
        obj.hasChildNodes();
        obj.isEqualNode(obj);
        obj.cloneNode();
        obj.hasAttributes();
        obj.isSameNode(obj);
        obj.dump();
        obj.dump('');
        obj.ownerDocument();
        
    }
    
}