global class CPQ_SAP_Schedule_Legacy_Renewal_Quoted implements Schedulable {
	global void execute(SchedulableContext sc) {
		CPQ_SAP_Legacy_Renewal_Quoted_Batch b = new CPQ_SAP_Legacy_Renewal_Quoted_Batch();
		database.executebatch(b,1);
	}
}