import { LightningElement,track } from 'lwc';
import getQPBs from '@salesforce/apex/NPN_LWCQPBStatementsController.getQPBStatements';

const columnList = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Account Name', fieldName: 'Account_Name__c' },
    { label: 'Region', fieldName: 'Region__c' },
    { label: 'Fiscal Year', fieldName: 'Fiscal_Year__c' },
    { label: 'Quarter', fieldName: 'Quarter__c' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true, typeAttributes: {  
        day: 'numeric',  
        month: 'short',  
        year: 'numeric',  
        hour: '2-digit',  
        minute: '2-digit',  
        second: '2-digit',  
        hour12: true} 
    },
    { label: 'Attachment Uploaded', fieldName: 'Attachment_Uploaded__c', type:'boolean' },
    { label: 'Documents Upload', type: 'fileUpload', fieldName: 'Id', typeAttributes: { acceptedFileFormats: '.jpg,.jpeg,.pdf,.png',fileUploaded:{fieldName: 'Attachment_Uploaded__c'} } }
];

export default class QPBStatementUpload extends LightningElement {
    @track data = [];
    _allData = [];
    @track columns = columnList;
    connectedCallback() {
        getQPBs().then(res => { 
            console.log('res:'+res);
            this._allData = res; 
            this.data = [...this._allData];
        }
        ).catch(err => console.error('err:'+err));
        console.log('columns => ', columnList);
    }
    handleUploadFinished(event) {
        event.stopPropagation();
        console.log('data => ', JSON.stringify(event.detail.data));
        this._allData.forEach(function (value) {
            console.log(value);
            if(value.Id == event.detail.data.recordId) {
                value.Attachment_Uploaded__c = true;
            }
        });
        this.data = [...this._allData];
        
        /*this.data.forEach(function (value) {
            console.log(value);
            if(value.Id == event.detail.data.recordId) {
                value.Attachment_Uploaded__c = true;
            }
        });
        this.data = [...this.data];
        */
        this.updateResults();
    }
    updateSearch(event) {
        //console.log(event.target.value);
        //var regex = new RegExp(event.target.value,'gi')
       //this.data = this._allData.filter(
            //row => regex.test(row.Region__c)
        //);
        const inputValue = event.target.value[0];
        console.log('inputValue', inputValue);

        const regex = new RegExp(`^${inputValue}`, 'i');     
        this.data = this._allData.filter(row => regex.test(row.Region__c));

        if (!event.target.value) {
            this.data = [...this._allData];
        }
    }

    updateResults() {
        var inp=this.template.querySelector("lightning-input");
        console.log(inp.value);
        
        const inputValue = inp.value[0];
        console.log('inputValue', inputValue);

        const regex = new RegExp(`^${inputValue}`, 'i');     
        this.data = this._allData.filter(row => regex.test(row.Region__c));
        if (!inp.value) {
            this.data = [...this._allData];
        }
    }
}