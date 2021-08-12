global class Customer_Portal_ISV_Login 
{
    public String UID {get; set;}
    public String PWD {get; set;}

    public String orgURL {get; set;}
    public String orgID {get; set;}

    public String PortalID {get; set;}
    public String PortalLoginURL {get; set;}

    public Boolean isValid {get; set;}

    global void login() 
    {
        if (Site.Login(UID, PWD, '/home/home.jsp') != null) 
        {
            isValid = true;
        }
    }
    
    global Customer_Portal_ISV_Login() 
    {
        isValid = false;

        orgID             = [Select Id FROM Organization LIMIT 1].Id;
        orgURL            = Customer_Portal_ISV__c.getOrgDefaults().ORG_URL__c;
        PortalID          = Customer_Portal_ISV__c.getOrgDefaults().ID__c;
        PortalLoginURL    = Customer_Portal_ISV__c.getOrgDefaults().Login_URL__c;
    }
    
    @isTest
    global static void testCustomer_Portal_ISV_Login () 
    {
        Customer_Portal_ISV_Login controller = new Customer_Portal_ISV_Login ();
        controller.UID = 'test@salesforce.com';
        controller.PWD = '123456'; 
        controller.login();                           
    }    
}