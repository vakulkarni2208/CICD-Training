public class ESP_RollupProductLinesOnAccount_BAT_SCH implements Schedulable {
     public void execute(SchedulableContext SC) {
        Id batchJobId = Database.executeBatch(new ESP_RollupProductLinesOnAccount_BAT(), 1);
        system.debug('batchJobId: '+ batchJobId);
     }
}