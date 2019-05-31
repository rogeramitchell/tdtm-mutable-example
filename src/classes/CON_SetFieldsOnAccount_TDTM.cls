public class CON_SetFieldsOnAccount_TDTM extends TDTM_Runnable {
  
  public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld,
            TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

    // create returnable collection
    TDTM_Runnable.dmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

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

      // iterate over contacts to set each Account's NumberOfEmployees
      for(Contact newRecord : newRecords) {
        if(accounts.containsKey(newRecord.AccountId)) {
          Account account = accounts.get(newRecord.AccountId);
          
          // if this is null, initialize to 0
          if(account.NumberOfEmployees == null) {
            account.NumberOfEmployees = 0;
          }

          // increment by 1, as this contact is part of the account
          account.NumberOfEmployees += 1;

          accounts.put(account.Id, account);
        }
      }

      // throw all of these accounts into dmlWrapper's collection to update
      dmlWrapper.objectsToUpdate.addAll(accounts.values());
    }

    return dmlWrapper;
  }

  public static Map<Id, Account> getAccounts(Set<Id> recordIds) {
    return new Map<Id, Account>([SELECT Id, NumberOfEmployees FROM Account WHERE Id IN :recordIds]);
  }
}