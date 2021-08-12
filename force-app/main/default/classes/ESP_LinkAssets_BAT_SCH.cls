public class ESP_LinkAssets_BAT_SCH implements Schedulable {
    public void execute(SchedulableContext SC) {
		Id batchJobId = Database.executeBatch(new ESP_LinkAssets_BAT());
		system.debug('batchJobId: '+ batchJobId);
	}
}