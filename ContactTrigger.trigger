/*************************************************************************************
 * @Name         : ContactTrigger.trigger
 * @Description  : if the Account already has a Primary Contact set a new one cannot be added
 * and when contact is set as primary, the Primary Contact Phone should be updated to all Contacts related to the same account.
 * @Created By   : Deniz
 * @Created Date : 31.08.2021
 *************************************************************************************/
trigger ContactTrigger on Contact (before insert,before update,after insert,after update){
  if(Trigger.isBefore) {
    if(Trigger.isInsert) {
      ContactTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    if(Trigger.isUpdate) {
      ContactTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
  }
  if(Trigger.isAfter) {
    if(Trigger.isInsert) {
      ContactTriggerHandler.handleAfterInsert(Trigger.new);
    }
    if(Trigger.isUpdate) {
      ContactTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
  }
}