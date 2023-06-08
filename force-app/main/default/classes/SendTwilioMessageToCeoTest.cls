/*
 * Description: Test class for SendTwilioMessageToCeo or trigger AccountTrigger
 */
@isTest
public class SendTwilioMessageToCeoTest {
    
    @testsetup
    static void dataSetup(){
        Account acc=new Account(Name = 'Test Acc', SMS_Sent__c = false);
        insert acc;
        Opportunity opp=new Opportunity(Name = 'Test Opp', Amount = 49000, AccountId = acc.Id, CloseDate = system.today(), StageName = 'Closed Won');
        insert opp;        
    }
    
    public static testmethod void test1()
    {
        Opportunity aOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opp'];
        aOpportunity.Amount = 50001;
        
        test.startTest();
        update aOpportunity;
        test.stopTest();
        
        System.assertEquals([SELECT Id, SMS_Sent__c FROM Account WHERE Name = 'Test Acc']?.SMS_Sent__c, True);
    }
}