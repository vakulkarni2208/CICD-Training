@isTest
private class TestSchedulers
{
	@isTest
	static void test_UpdatePermissionSet()
	{
		String CRON_EXP = '0 0 1 * * ?';

		Test.startTest();
			String jobId = System.schedule('Schedule_UpdatePermissionSet', CRON_EXP, new Schedule_UpdatePermissionSet());
			CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
							  FROM CronTrigger
							  WHERE Id = :jobId];
			System.assertEquals(CRON_EXP,ct.CronExpression);
			System.assertEquals(0,ct.TimesTriggered);
			String todayStr = String.valueOf(Date.today().addDays(1));
			System.assertEquals(todayStr + ' 01:00:00',String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}

	@isTest
	static void test_Retry()
	{
		String CRON_EXP = '0 0 1 * * ?';

		Test.startTest();
			String jobId = System.schedule('Schedule_Retry', CRON_EXP, new Schedule_Retry());
			CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
							  FROM CronTrigger
							  WHERE Id = :jobId];
			System.assertEquals(CRON_EXP,ct.CronExpression);
			System.assertEquals(0,ct.TimesTriggered);
			String todayStr = String.valueOf(Date.today().addDays(1));
			System.assertEquals(todayStr + ' 01:00:00',String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}

	@isTest
	static void test_Schedule_DesyncRetry()
	{
		String CRON_EXP = '0 0 1 * * ?';

		Test.startTest();
			String jobId = System.schedule('Schedule_DesyncRetry', CRON_EXP, new Schedule_DesyncRetry());
			CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
							  FROM CronTrigger
							  WHERE Id = :jobId];
			System.assertEquals(CRON_EXP,ct.CronExpression);
			System.assertEquals(0,ct.TimesTriggered);
			String todayStr = String.valueOf(Date.today().addDays(1));
			System.assertEquals(todayStr + ' 01:00:00',String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}
}