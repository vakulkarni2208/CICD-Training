global class CPQRenewalForecastScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		CPQRenewalForecastBatch b = new CPQRenewalForecastBatch();
		database.executebatch(b,1);
	}
}