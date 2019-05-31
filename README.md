# Example of Using `TDTM_RunnableMutable`

## Use Case

As a user, we expect every Account has an accurate value in the `NumberOfEmployees`, so whenever a Contact is created, we need to increment this field by 1.

While this may seem like a trivial use case, it demonstrates how the TDTM framework cannot be reliably used by subscriber developers, as a conflict will arise if the subscriber's code extending TDTM's `DmlWrapper` will contain a record that NPSP has already staged for update.

NOTE: We also assume that all of NPSP's standard Trigger Handler records are configured and active in the org.

## Using `TDTM_Runnable`

This has been implemented with the class [`CON_SetFieldsOnAccount_TDTM`](src/classes/CON_SetFieldsOnAccount_TDTM.cls).

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

## Using `TDTM_RunnableMutable`

This has been implemented with the class [`CON_SetFieldsOnAccount_TDTM_Mutable`](src/classes/CON_SetFieldsOnAccount_TDTM_Mutable.cls).

1. Ensure that your org has a `Trigger_Handler__c` record set up for the class that implements `TDTM_RunnableMutable`, and also that the previously created Trigger Handler for the class implementing `TDTM_Runnable` is no longer active.
	```apex
	Trigger_Handler__c triggerHandler = new Trigger_Handler__c();
	triggerHandler.Active__c = true;
	triggerHandler.Asynchronous__c = false;
	triggerHandler.Class__c = 'CON_SetFieldsOnAccount_TDTM_Mutable';
	triggerHandler.Load_Order__c = 2;
	triggerHandler.Object__c = 'Contact';
	triggerHandler.Trigger_Action__c = 'AfterInsert';
	insert triggerHandler;

	List<Trigger_Handler__c> runnableVersions = [SELECT Id FROM Trigger_Handler__c WHERE Class__c = 'CON_SetFieldsOnAccount_TDTM' AND Active__c = true];

	for(Trigger_Handler__c record : runnableVersions) {
		record.Active__c = false;
	}

	update runnableVersions;
	```
1. Create a new Contact record via the UI or Apex.
	```apex
	Contact record = new Contact();
	record.FirstName = 'Test';
	record.LastName = 'Person';
	insert record;
	```
1. Observe no error exists, and the Account created reflects `NumberOfEmployees` has a value of 1
	```apex
	Contact mostRecentlyCreatedContact = [SELECT Id, AccountId FROM Contact WHERE CreatedById = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];
	Account verifyRecord = [SELECT Id, NUmberOfEmployees FROM Account WHERE Id = :mostRecentlyCreatedContact.AccountId];
	System.assertEquals(1, verifyRecord.NumberOfEmployees);
	```