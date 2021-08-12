trigger CPQ_Customer_Classification_Trigger on SBQQ__Quote__c (
    before insert, before update, after insert, after update) {

        if (Trigger.isBefore) {
            //call your handler.before method

            //Query Quote Ids
            Map<ID,String> quoteidsMap=new Map<ID,String>();
            Map<ID,String> quoteidsMapAccount=new Map<ID,String>();
            Map<ID,String> quoteidsSoldTo=new Map<ID,String>();
            String renewalNotifyRecId='';

            renewalNotifyRecId=[Select id,Name from RecordType where SObjectType='SBQQ__Quote__c' and Name='Renewal Notification'].id;
                
            

            for(SBQQ__Quote__c quote: Trigger.new){
                quoteidsMap.put(quote.SBQQ__Opportunity2__c,null);
                quoteidsMapAccount.put(quote.SBQQ__Account__c,null);
                quoteidsSoldTo.put(quote.Sold_To__c,null);
                system.debug(quote.SBQQ__Opportunity2__c);
                system.debug(quote.SBQQ__Account__c);

            }

            if(Trigger.isInsert){
                for(Opportunity opp:[Select SBQQ__RenewedContract__c,SBQQ__RenewedContract__r.Customer_Classification__c from Opportunity where id IN: quoteidsMap.keySet()]){
                    system.debug('Renewed Contract Class: ' + opp.SBQQ__RenewedContract__r.Customer_Classification__c);
                    system.debug('Renewed Contract Class2: ' + opp.SBQQ__RenewedContract__c);

                    //if(quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Customer_Classification__c!=null){
                    //  quoteidsMap.put(quote.SBQQ__Opportunity2__c, quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Customer_Classification__c);
                    //}else{
                    //  quoteidsMap.put(quote.SBQQ__Opportunity2__c,quote.SBQQ__Account__r.CPQ_Customer_Classification__c);
                    //}
                    quoteIdsMap.put(opp.id, opp.SBQQ__RenewedContract__r.Customer_Classification__c);
                }

                for(Account acc:[Select id, CPQ_Customer_Classification__c from Account where id IN: quoteidsMapAccount.keySet()]){
                    system.debug('Renewed Contract Class Account: ' + acc.CPQ_Customer_Classification__c);

                    quoteidsMapAccount.put(acc.id, acc.CPQ_Customer_Classification__c);
                }
            }
            

            for(Account acc:[Select id, CPQ_Price_List_Code__c from Account where id IN: quoteidsSoldTo.keySet()]){
                system.debug('Sold to Price Code: ' + acc.CPQ_Price_List_Code__c);

                quoteidsSoldTo.put(acc.id, acc.CPQ_Price_List_Code__c);
            }

            for(SBQQ__Quote__c quote:Trigger.new){
                    if(Trigger.isInsert){
                        if(quote.Customer_Classification__c=='' || quote.Customer_Classification__c==null){
                            if(quoteidsMap.get(quote.SBQQ__Opportunity2__c)!=null && quoteidsMap.get(quote.SBQQ__Opportunity2__c)!=''){
                                quote.Customer_Classification__c=quoteidsMap.get(quote.SBQQ__Opportunity2__c);
                            }else{
                                quote.Customer_Classification__c=quoteidsMapAccount.get(quote.SBQQ__Account__c);
                            }
                        }
                    }
                    

                    if(quote.RecordTypeId==renewalNotifyRecId){
                        quote.CPQRecordTypeCategory__c='P1';
                    }else if(quote.Sold_To__c!=null){
                        quote.CPQRecordTypeCategory__c=quoteidsSoldTo.get(quote.Sold_To__c);
                    }
        
            }

        } else if (Trigger.isAfter) {
            //call handler.after method
            List<id> RecalQuoteList =  new List<id>();
            for(SBQQ__Quote__c QQ:Trigger.new){
                //QQ.Recalculate_Pricing__c= true;
                
                //RecalQuoteList.add(QQ.id);
                
            }
            //QuoteRecalculate.updateQuotes(RecalQuoteList);
            //Update RecalQuoteList;
        
        }
}