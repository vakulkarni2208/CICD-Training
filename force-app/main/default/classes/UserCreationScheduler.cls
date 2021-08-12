global class UserCreationScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
       Type t2 = Type.forName('UserCreationClass');
       t2.newInstance();
   }
}