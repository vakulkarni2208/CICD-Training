public class XMLFetch {



    public String getmyxml() 
    {
         Document ds = [SELECT Body FROM Document where id =:ApexPages.currentPage().getParameters().get('id')][0];
         
         return ds.Body.toString();
    }
}