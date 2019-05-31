public class CON_SetFieldsOnAccount_TDTM_Mutable extends TDTM_RunnableMutable {
  
  public override void run(List<SObject> listNew, List<SObject> listOld,
            TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
            TDTM_Runnable.DmlWrapper dmlWrapper) {
    // cast new contacts
    List<Contact> newRecords = (List<Contact>) listNew;

    if(triggerAction == TDTM_Runnable.Action.AfterInsert) {
      // create collection to hold Account IDs
      Set<Id> accountIds = new Set<Id>();

      // iterate over new records to collect Account IDs
      for(Contact newRecord : newRecords) {
        accountIds.add(newRecord.AccountId);
      }

      // retrieve those accounts
      Map<Id, Account> accounts = getAccounts(accountIds);

      // create a map version of dmlWrapper's objectsToUpdate
      Map<Id, SObject> objectsToUpdateMap = new Map<Id, SObject>(dmlWrapper.objectsToUpdate);

      // iterate over contacts to set each Account's NumberOfEmployees
      for(Contact newRecord : newRecords) {
        if(accounts.containsKey(newRecord.AccountId)) {
          /*
            check whether this account is already in dmlWrapper
              as a record that will receive an update
          */
          Account account;

          if(objectsToUpdateMap.containsKey(newRecord.AccountId)) {
            account = (Account) objectsToUpdateMap.get(newRecord.AccountId);
          } else {
            account = accounts.get(newRecord.AccountId);
          }
          
          // if this is null, initialize to 0
          if(account.NumberOfEmployees == null) {
            account.NumberOfEmployees = 0;
          }

          // increment by 1, as this contact is part of the account
          account.NumberOfEmployees += 1;

          // put this account into the collection of records to update
          objectsToUpdateMap.put(account.Id, account);
        }
      }

      // update dmlWrapper's objectsToUpdate to reflect this collection
      dmlWrapper.objectsToUpdate = objectsToUpdateMap.values();
    }
  }

  public static Map<Id, Account> getAccounts(Set<Id> recordIds) {
    return new Map<Id, Account>([SELECT Id, NumberOfEmployees FROM Account WHERE Id IN :recordIds]);
  }
}