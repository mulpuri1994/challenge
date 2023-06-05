public class TwilioSendSMS {   
    Public static String accountSid;
    Public static String token;
    Public static String fromPhNumber;
    Public static String Version;
    Public static String smsBody;
    Public static String phNumber;
    Public static String twilioUrl;
    @future(callout=true)
    public static void sendSms(String AccName){  
        try{
            setVariablesForCallout();
            String smsBody = 'Greatnews!A customer has hit Gold. '+AccName+'Will get VIP Treatment';        
            HttpRequest req = new HttpRequest();        
            req.setEndpoint(twilioUrl+ '/2010-04-01/Accounts/'+accountSid+'/SMS/Messages.json');        
            req.setMethod('POST');        
            req.setHeader('X-Twilio-Client', 'salesforce-' + Version);        
            req.setHeader('User-Agent', 'twilio-salesforce/' + Version);       
            req.setHeader('Accept', 'application/json');        
            req.setHeader('Accept-Charset', 'utf-8');        
            req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));        
            req.setBody('To='+EncodingUtil.urlEncode(phNumber,'UTF-8')+'&From='+EncodingUtil.urlEncode(fromPhNumber,'UTF-8')+'&Body='+smsBody);        
            Http http = new Http();        
            HTTPResponse res = http.send(req);        
            System.debug(res.getBody());        
            if(res.getStatusCode()==201) 
                System.Debug('Message sending Successful');        
            else{            
                System.Debug('Message sending Unsuccessful');
            }     
        }catch(Exception e){
            system.debug('===Exception ===>'+e.getStackTraceString());
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
        phNumber = twilioDetails.CEO_Number__c;
    }
}