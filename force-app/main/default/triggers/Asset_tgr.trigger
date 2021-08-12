trigger Asset_tgr on Asset (before insert, before update) {
    
    Asset_tgr_cls helper = new Asset_tgr_cls(); 
    helper.execute();
    /*if(trigger.isbefore){
        if(trigger.isinsert || trigger.isupdate) {
            Asset_tgr_cls.updateEntitlement(trigger.new);
        }
    }*/
}