//apex to handle sms to an account which is invoked by a record trigger flow 
public class Sendsms {
    @InvocableMethod
    public static void flowtosendsms(List<String> accNames){
        TwilioSendSMS.sendsms(accNames[0]);
    }    
}