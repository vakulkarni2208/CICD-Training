public with sharing class ESP_LinkSubToEntitlements_BAT_SCH implements Schedulable {
	public void execute(SchedulableContext SC) {
		Id batchJobId = Database.executeBatch(new ESP_LinkSubToEntitlements_BAT());
		system.debug('batchJobId: '+ batchJobId);
	}
}