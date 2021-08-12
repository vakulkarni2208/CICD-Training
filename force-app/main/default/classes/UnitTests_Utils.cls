/*
** Class:  UnitTests_Utils
** Created by OpFocus on 02/07/2010
** Description: Unit tests for methods in the Utils class that aren't tested elsewhere.
*/	
@isTest
private class UnitTests_Utils {

	static boolean runTest_FiscalQuarters = true;

    static testMethod void test_FiscalQuarters() {
    	
    	System.assert(runTest_FiscalQuarters, 'Test disabled');
    	
    	System.assertEquals('Q1-FY2011', Utils.getFiscalQuarterForDate(Date.newInstance(2010,  2,  1)));
    	System.assertEquals('Q2-FY2011', Utils.getFiscalQuarterForDate(Date.newInstance(2010,  5,  3)));
    	System.assertEquals('Q3-FY2011', Utils.getFiscalQuarterForDate(Date.newInstance(2010,  8,  2)));
    	System.assertEquals('Q4-FY2011', Utils.getFiscalQuarterForDate(Date.newInstance(2010, 11,  1)));
    	System.assertEquals('Q4-FY2011', Utils.getFiscalQuarterForDate(Date.newInstance(2011,  1, 30)));

    	System.assertEquals('Q2-FY2010', Utils.getThreeFiscalQuartersAgo(Date.newInstance(2010,  2,  1)));
    	System.assertEquals('Q3-FY2010', Utils.getThreeFiscalQuartersAgo(Date.newInstance(2010,  5,  3)));
    	System.assertEquals('Q4-FY2010', Utils.getThreeFiscalQuartersAgo(Date.newInstance(2010,  8,  2)));
    	System.assertEquals('Q1-FY2011', Utils.getThreeFiscalQuartersAgo(Date.newInstance(2010, 11,  1)));
    	System.assertEquals('Q1-FY2011', Utils.getThreeFiscalQuartersAgo(Date.newInstance(2011,  1, 30)));

		System.assert( Utils.dateIsThreeFiscalQuartersBeforeDate(Date.newInstance(2010, 2, 1), Date.newInstance(2011, 2, 1)));
		System.assert( Utils.dateIsThreeFiscalQuartersBeforeDate(Date.newInstance(2010, 2, 1), Date.newInstance(2010, 11, 1)));
		System.assert(!Utils.dateIsThreeFiscalQuartersBeforeDate(Date.newInstance(2010, 2, 1), Date.newInstance(2010, 7, 1)));
		System.assert(!Utils.dateIsThreeFiscalQuartersBeforeDate(Date.newInstance(2010, 2, 1), Date.newInstance(2009, 11, 1)));

		System.assertEquals('Q2-FY2010', Utils.getNextQuarter('Q1-FY2010'));
		System.assertEquals('Q3-FY2010', Utils.getNextQuarter('Q2-FY2010'));
		System.assertEquals('Q4-FY2010', Utils.getNextQuarter('Q3-FY2010'));
		System.assertEquals('Q1-FY2011', Utils.getNextQuarter('Q4-FY2010'));

		System.assertEquals('Q2-FY2010', Utils.getPreviousQuarter('Q3-FY2010'));
		System.assertEquals('Q3-FY2010', Utils.getPreviousQuarter('Q4-FY2010'));
		System.assertEquals('Q4-FY2010', Utils.getPreviousQuarter('Q1-FY2011'));
		System.assertEquals('Q1-FY2011', Utils.getPreviousQuarter('Q2-FY2011'));

    }
}