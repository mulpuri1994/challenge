/*
 * Description: The mock class is used as the mock for Twilio REST API
 * Main class: SendTwilioMessageToCeo
 */
@isTest
global class ExampleCalloutMock implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){ 
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"sid": "SM5a32267480b84fb9aeab06b7eed05772", "date_created": "Fri, 04 Mar 2022 08:07:12 +0000", "date_updated": "Fri, 04 Mar 2022 08:07:12 +0000", "date_sent": null, "account_sid": "AC65e568b5e1b779cc8443b48b40a82254", "to": "+19043273278", "from": "+17204594655", "body": "Code is 123", "status": "queued", "direction": "outbound-api", "api_version": "2010-04-01", "price": null, "price_unit": "USD", "uri": "/2010-04-01/Accounts/AC65e568b5e1b779cc8443b48b40a82254/SMS/Messages/SM5a32267480b84fb9aeab06b7eed05772.json", "num_segments": "1"}');
      res.setStatusCode(201);
      return res;
  }
}