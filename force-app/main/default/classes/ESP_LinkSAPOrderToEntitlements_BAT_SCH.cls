public with sharing class ESP_LinkSAPOrderToEntitlements_BAT_SCH implements Schedulable {
	public integer iBatchSize = 1;
    public void execute(SchedulableContext SC) {
        Id batchJobId = Database.executeBatch(new ESP_LinkSAPOrderToEntitlements_BAT(), iBatchSize);
        system.debug('batchJobId: '+ batchJobId);
	}
}