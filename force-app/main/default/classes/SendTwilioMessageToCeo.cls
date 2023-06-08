/*
* Class: SendTwilioMessageToCeo
* Description: Used as a trigger handler to send a SMS to the CEO. Also used by the LWC component to send the custom message
*              to CEO for only GOLD Accounts
* Author: Sunil
* Date: 19th October 2022
*/

public class SendTwilioMessageToCeo {
    
    Public static String accountSid;
    Public static String token;
    Public static String fromPhNumber;
    Public static String Version;
    Public static String smsBody;
    Public static String twilioUrl;
    
    /*
* Description: This function is used by Trigger handler to process the account records to which the SMS has to be sent. 
*/
    public static void processRecords(List<Account> listOfAccounts){
        smsBody = system.Label.SMS_Body; //Get the SMS body from the custom label
        //String concatenatedAccountNames; THIS CODE IS WRITTEN FOR THE BELOW RESOLUTION (SEE AT THE END OF THE CODE)
        for(Account eachAccount : listOfAccounts){
            if(!eachAccount.SMS_Sent__c && eachAccount.Customer_classification__c == 'GOLD'){//Check if the SMS has to be sent to this account
                smsBody = smsBody.replaceAll('<AccountName>', eachAccount.Name); //Replace the generic '<AccountName>' with the original Account name
                //concatenatedAccountNames = concatenatedAccountNames + ', '+ eachAccount.Name; THIS CODE IS WRITTEN FOR THE BELOW RESOLUTION (SEE AT THE END OF THE CODE)
                //smsBody = smsBody.replaceAll('<AccountName>', concatenatedAccountNames); THIS CODE IS WRITTEN FOR THE BELOW RESOLUTION (SEE AT THE END OF THE CODE)
                sendSMSAsync(smsBody, eachAccount.Id);//Send an SMS for this Account
            }
        }
    }
    /*
* Description: This class is used to initialize all the variables required for the callout to the Twilio. The details for the
* 				API are stored in the custom metadata called 'Twilio_Details'.
*/
    Public static void setVariablesForCallout(){
        Twilio__mdt twilioDetails = Twilio__mdt.getInstance('Twilio_Details');//Get the instance of the metadata and initialize the variables
        accountSid = twilioDetails.AccountSid__c;
        token = twilioDetails.Auth_Token__c;
        fromPhNumber = twilioDetails.From_Phone_Number__c;
        Version = twilioDetails.Version__c;
        twilioUrl = twilioDetails.Twilio_URL__c;
    }
    /*
* Description: This function is used to initiate the async process for the case of trigger. This function is called by processRecords
* 				that is called by trigger.
*/
    @future(callout = true)
    Public static void sendSMSAsync(string smsBody, string accountId){
        sendSMS(smsBody, accountId);//Call the Send SMS functionality using the Asynchronous process
    }
    
    /*
* Description: This function serves the dual purpose: 
* 				1) To send an SMS to the CEO whenever the account is updated to the GOLD for the very first time
* 				2) This function is also leveraged by the LWC component to send the SMS to the end user if the account is GOLD.
*/
    @AuraEnabled
    Public static void sendSMS(string smsBody, String accountId){
        setVariablesForCallout();//Prepare the variables so that the callout can be done.
        HttpRequest req = new HttpRequest();
        req.setEndpoint(twilioUrl + '/2010-04-01/Accounts/'+accountSid+'/Messages.json');
        req.setMethod('POST');
        req.setHeader('X-Twilio-Client', 'salesforce-' + Version);
        req.setHeader('User-Agent', 'twilio-salesforce/' + Version);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Accept-Charset', 'utf-8');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
        req.setBody('To='+EncodingUtil.urlEncode(system.Label.Ceo_Phone_number,'UTF-8')+'&From='+EncodingUtil.urlEncode(fromPhNumber,'UTF-8')+'&Body='+smsBody);
        Http http = new Http();
        HttpResponse res = http.send(req);//Make a callout
        //Throw an error if the twilio is not responding with 201 status
        if(res.getStatusCode() != 201){ 
            CalloutException e = new CalloutException();
            e.setMessage(res.getBody());
            throw e;
        } else {//If successful, update the account so that the SMS is not sent the next time.
            update new Account(Id = accountId, SMS_Sent__c = true);
        }
    }
}

/* 
 * MAJOR IMPROVEMENTS THAT CAN BE DONE:
 * 1) In the challenge, it was mentioned that the SMS has to be sent to the end user whenever the account has been updated to the
 *    'GOLD' status for the first time. If this is the case, a seperate TWILIO callout has to be done for each and every Account
 * 	  that has been triggered/updated to GOLD status for the first time. This is a obvious matter of concern if the multiple Accounts
 *    are getting updated using import wizards/Data loaders.
 * 	  
 * 	  Resolution:
 *    The process of sending a seperate messages for seperate accounts can be changed to a process in which all the Account names will
 * 	  be concatenated in a Single Message body.
 * 	  For example: If the accounts called Salesforce, LeadInvest, Google are updated to GOLD status for the first time, the SMS has to 
 * 	  be changed to: 'Great news!  customers have hit the Gold. Salesforce, LeadInvest, Google accounts will get VIP treatment'.
 * 		
 * 	  If the SMS in the above fashion is sent, the number of callouts and the number of async jobs gets decreased to 1.
 * 	  This improves our system and CPU to a very greater extent.
 * 
 * 	  The below 
 * 	  public static void processRecords(List<Account> listOfAccounts){
        smsBody = system.Label.SMS_Body; //Get the SMS body from the custom label
		List<Id> AccountIds = new List<Id>();
        String concatenatedAccountNames; 
        for(Account eachAccount : listOfAccounts){
            if(!eachAccount.SMS_Sent__c && eachAccount.Customer_classification__c == 'GOLD'){//Check if the SMS has to be sent to this account
                concatenatedAccountNames = concatenatedAccountNames + ', '+ eachAccount.Name; 
				AccountIds.add(eachAccount.Id);
                sendSMSAsync(smsBody, eachAccount.Id);//Send an SMS for this Account
            }
        }
		smsBody = smsBody.replaceAll('<AccountName>', concatenatedAccountNames);
		sendSMSAsync(smsBody, AccountIds);//Send an SMS for this Account
    }
 * 
 */