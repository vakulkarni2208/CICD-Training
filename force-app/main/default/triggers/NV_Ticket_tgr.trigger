trigger NV_Ticket_tgr on NV_Ticket__c (after insert, after update) {
    NV_Ticket_tgr_cls handler= new NV_Ticket_tgr_cls();
    handler.execute();
}