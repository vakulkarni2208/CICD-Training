@isTest
public class Test_XMLDom{
    
    public static testMethod void testunitTest() {  
    
        XMLDom  objXMLD = new XMLDom();
        XMLDom  objXMLD1 = new XMLDom('');
        objXMLD1.getElementByPath('');
        objXMLD1.dumpAll();        
        XMLDom.Element obj = new XMLDom.Element();       
        List<XMLDom.Element> lstElement = new List<XMLDom.Element>();
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