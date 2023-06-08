/*
 * Description: To trigger the SMS Send when the account is Updated
 */
trigger AccountTrigger on Account (before update) {
    if(trigger.isUpdate && trigger.isBefore){
        SendTwilioMessageToCeo.processRecords(trigger.new); 
    }
}