@isTest(seeAllData=false)
private class Test_UserCreationSchedulableClass {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';
   
   public static void createTestData() {
       Account acc = new Account();
       acc.name = 'Test';
       insert acc;
       
       Contact con = new Contact();
       con.firstName = 'Test FName';
       con.lastName = 'Test LName';
       con.email = 'a@b.com';
       con.accountId = acc.id;
       con.create_User__c = true;
       insert con;
       
       Contact con1 = new Contact();
       con1.firstName = 'Test1 FNam1e';
       con1.lastName = 'Test1 LNam1e';
       con1.email = 'a1@b1.com';
       con1.accountId = acc.id;
       con1.mailingCountry = 'India';
       con1.create_User__c = true;
       insert con1;
       
       Community_Settings__c cs = new Community_Settings__c();
       cs.ERROR_EMAILS__c = 'vakulkarni@nvidia.com';
       insert cs;
   }

   static testmethod void test() {
       
       createTestData();
      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new UserCreationScheduler());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      Test.stopTest();

   }
}