/******************************************************************************************
Name                : HomePageTasksController
Author              : Appirio Offshore(Vinod Kumar)
Date                : June 04, 2010
Description         : This class does following functionalities
1. Fetches the Selected Task List
2. This class is being called by Contreller named 'HomePageTasksController'
******************************************************************************************/
public class HomePageTasksController{
    public String selectedTime{get;set;}
    public List<SelectOption> timeSelection{get;set;}
    public List<Task>seletedtask{get;set;}
    public HomePageTasksController(){
        getTimeSelection();
        generateTasks();
    }
   public pagereference generateTasks(){
        string userid = UserInfo.getUserId();
        date today = Date.today();
        date tomarrow = Date.today().addDays(1);
        date nextSevenDays= Date.today().addDays(7);
        date thisMonth= Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        String strquery = 'SELECT Id, ActivityDate, WhatId, WhoId, What.Name, Who.Name, Subject, Status FROM Task WHERE OwnerId =:userid AND IsClosed = false and IsArchived = false ';
        
        if(selectedTime == null || selectedTime == 'All Open'){
            
            strquery += ' LIMIT 10';            
        }
        else if (selectedTime == 'Overdue'){
           
           strquery += 'And ActivityDate <: today  LIMIT 10';
        }
        else if (selectedTime == 'Today'){
           
            strquery += 'And ActivityDate =: today  LIMIT 10';                
        }
        else if (selectedTime== 'Today + Overdue'){
           
           strquery += 'And ActivityDate <=: today  LIMIT 10';             
        }
        else if (selectedTime== 'Tomorrow'){
           
           strquery += 'And ActivityDate =: tomarrow LIMIT 10';              
        }
        else if (selectedTime== 'Next 7 Days'){
        
          strquery += 'And ActivityDate >=: today And ActivityDate <=: nextSevenDays LIMIT 10';             
        }
        else if (selectedTime== 'Next 7 Days + Overdue'){
           
            strquery += 'And ActivityDate <=: nextSevenDays LIMIT 10';              
        }
        else if (selectedTime== 'This Month'){
           
            strquery += 'And ActivityDate >=: today  And ActivityDate <: thisMonth LIMIT 10';            
        }
        seletedtask = Database.Query(strquery);
        return null;
    }
    
    public PageReference CreateNewTask()
    {
      return  new PageReference('/00T/e');
    }
    // to get time selection option
    void getTimeSelection()
    {
        timeSelection= new List<SelectOption>();
        timeSelection.add(new SelectOption('All Open','All Open'));
        timeSelection.add(new SelectOption('Overdue','Overdue'));
        timeSelection.add(new SelectOption('Today','Today'));
        timeSelection.add(new SelectOption('Today + Overdue','Today + Overdue'));
        timeSelection.add(new SelectOption('Tomorrow','Tomorrow'));
        timeSelection.add(new SelectOption('Next 7 Days','Next 7 Days'));
        timeSelection.add(new SelectOption('Next 7 Days + Overdue','Next 7 Days + Overdue'));
        timeSelection.add(new SelectOption('This Month','This Month'));    
    }
    
    @isTest
    public static void testAll()
    {
    	HomePageTasksController controller = new HomePageTasksController();
    }
}