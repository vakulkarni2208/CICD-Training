public interface NV_TriggerHandlerInterface {
    void init();
    void beforeInsert();
    void beforeUpdate();
    
    void afterInsert();
    void afterUpdate();
}