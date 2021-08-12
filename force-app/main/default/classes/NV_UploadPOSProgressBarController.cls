public class NV_UploadPOSProgressBarController {
    public Id accountId {get;set;}
    public NV_UploadPOSProgressBarController() {
        accountId = [select contact.accountId from User where id=:UserInfo.getUserId()].contact.accountId;
        system.debug(accountId);
    }
}