import { api, LightningElement, wire } from 'lwc';
import getRequiredRoles from "@salesforce/apex/AllocationFilterController.getRequiredRoles";
export default class ResourceAllocation extends LightningElement {
    @api recordId; //projectId
    requiredRoleNames
    projectDates;

    @wire (getRequiredRoles, {projectID: "$recordId"})
    rolesObject({error, data}){
        if(data){
            this.requiredRoleNames = data.map(role => {
                return role.Role__c;
            })
            this.projectDates = `Project starts from ${data[0].Project__r.Start_Date__c} until ${data[0].Project__r.End_Date__c}`;
        }
    }
}