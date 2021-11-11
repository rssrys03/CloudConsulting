import { api, LightningElement, } from 'lwc';
import {filterUserByRole} from '@salesforce/apex/AllocationFilter.filterUserByRole';

export default class ResourceAllocation extends LightningElement {
    @api projectId;
    @api requiredRoleNames; // array de role names
    @api roleName;

    connectedCallback() {
       this.roleName = this.template.querySelector("lightning-tabset").activeTabValue;
    }


}