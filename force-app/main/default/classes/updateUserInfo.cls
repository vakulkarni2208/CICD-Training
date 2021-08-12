public class updateUserInfo {

    public string email {get;set;}
    public string phone {get;set;}
    public string firstname {get;set;}
    public string lastname {get;set;}  
    public string title {get;set;}  
    User u ;
    
    public updateUserInfo(){
        u = [select FirstName,LastName,Title,Email,Phone from user where Id =:UserInfo.getuserId()];
        email = u.Email;
        firstname = u.FirstName;
        lastName = u.LastName;
        phone = u.Phone; 
        title = u.Title;
    }
    
        
    public void updateUserDetail(){
        try{
        if(firstname!=''){
            u.FirstName = firstname;
        }
        if(lastname!=''){
            u.LastName = lastname;
        }if(title!=''){
        u.Title = title;
        }
        if(email!=''){
            u.Email = email;
        }
        if(phone!=''){
            u.Phone = phone;
        }    
                    
        update u;
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm, 'Your information updated successfully.');
         ApexPages.addMessage(myMsg);
        }
        Catch(Exception ee){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, ee.getMessage());
             ApexPages.addMessage(myMsg);
        }
        
    }

}