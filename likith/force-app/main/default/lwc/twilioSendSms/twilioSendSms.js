import { LightningElement ,api, track} from 'lwc';

import sendsmsApex from '@salesforce/apex/Sendmessagecontroller.sendsms';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class TwilioSendSms extends LightningElement {
    @api recordId;
    resetpage = false;
    @track message;
    handleClick(event){
        var inp=this.template.querySelector("lightning-input");
        this.message=inp.value;
        console.log(inp.value);
        sendsmsApex({accountid:this.recordId,messagebody:this.message})
        .then(result=>{
            this.resetpage=true;
            this.dispatchEvent(
                new ShowToastEvent( {
                    title: 'SMS',
                    message: 'SMS sent successfully',
                    variant: 'success',
                    mode: 'sticky'
                } )
            );
            if(this.resetpage== true){
                this.handleReset();
            }
        })
        .catch(error=>{
        });
    }
    handleReset() {
        this.resetpage=false;
        this.template.querySelector('lightning-input[data-name="smsmessage"]').value = null;    

     }

}