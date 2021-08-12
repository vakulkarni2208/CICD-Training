global class CPQ_SAP_Schedule_Quote_Line_Sync implements Schedulable {
	global void execute(SchedulableContext sc) {
		CPQ_SAP_Process_Quote_Lines b = new CPQ_SAP_Process_Quote_Lines();
		database.executebatch(b);
	}
}