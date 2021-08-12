trigger BatchApexErrorEvent_tgr on BatchApexErrorEvent (after insert) {
	BatchApexErrorEvent_tgr_cls handler = new BatchApexErrorEvent_tgr_cls(); 
    handler.execute();
}