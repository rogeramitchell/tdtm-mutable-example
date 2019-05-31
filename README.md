# Example of Using `TDTM_Mutable`

## Use Case

As a user, we expect every Account has an accurate value in the `NumberOfEmployees`, so whenever a Contact is created, we need to increment this field by 1.

NOTE: We also assume that all of NPSP's standard Trigger Handler records are configured and active in the org.

## Using `TDTM_Runnable`

1. Ensure that your org has a `Trigger_Handler__c` record set up for the class that implements `TDTM_Runnable` that attempts to fulfill this requirement.
	```apex
	Trigger_Handler__c triggerHandler = new Trigger_Handler__c();
	triggerHandler.Active__c = true;
	triggerHandler.Asynchronous__c = false;
	triggerHandler.Class__c = 'CON_SetFieldsOnAccount_TDTM';
	triggerHandler.Load_Order__c = 2;
	triggerHandler.Object__c = 'Contact';
	triggerHandler.Trigger_Action__c = 'AfterInsert';
	insert triggerHandler;
	```
1. Create a new Contact record via the UI or Apex.
	```apex
	Contact record = new Contact();
	record.FirstName = 'Test';
	record.LastName = 'Person';
	insert record;
	```
1. Observe an error message appears.
	> Error: Invalid Data. 
	> Review all error messages below to correct your data.
	> Apex trigger TDTM_Contact caused an unexpected exception, contact your administrator: TDTM_Contact: execution of AfterInsert caused by: System.ListException: Duplicate id in list: 0012E00001t2sSjQAI: Class.UTIL_DMLService.updateRecords: line 202, column 1