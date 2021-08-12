@isTest
private class NV_TriggerHandler_test {
    
    @isTest
    static void test_TriggerHandler() {
      NV_TriggerHandler th = new NV_TriggerHandler();
        th.init();
        th.beforeInsert();
        th.beforeUpdate();
        th.afterInsert();
        th.afterUpdate();
        th.beforeDelete();
        th.afterDelete();
        th.afterUnDelete();
        //th.execute();
    }
}