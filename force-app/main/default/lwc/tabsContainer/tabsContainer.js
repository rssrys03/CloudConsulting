import { api, LightningElement, wire } from 'lwc';
import getRequiredRoles from "@salesforce/apex/AllocationFilter.getRequiredRoles";
import { getRecord } from 'lightning/uiRecordApi';

export default class TabsContainer extends LightningElement {
    @api recordId; //projectId
    requiredRoleNames;

    @wire (getRequiredRoles, {projectID: "$recordId"})
    rolesObject({error, data}){
        if(data){
            this.requiredRoleNames = data.map(role => {
                return role.Role__c;
            })
        }
    }
}