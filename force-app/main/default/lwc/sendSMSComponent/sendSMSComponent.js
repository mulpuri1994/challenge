import { LightningElement, api, wire } from 'lwc';
import sendSMS from '@salesforce/apex/SendTwilioMessageToCeo.sendSMS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SendSMSComponent extends LightningElement {

    smsBody;
    @api recordId;
    handleInputChange(event){
        this.smsBody = event.target.value;
        console.log('Body is '+this.smsBody);
    }

    sendSMS(){
        console.log('Record Id is '+this.recordId);
        sendSMS({smsBody: this.smsBody, accountId: this.recordId})
            .then(result => {
                    const evt = new ShowToastEvent({
                        title: 'SMS Sent Successfully',
                        message: 'SMS Sent to ' + this.recordId,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.smsBody = '';
            })
            .catch(error =>{
                const evt = new ShowToastEvent({
                    title: 'SMS Sent Failed',
                    message: error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
    }
}