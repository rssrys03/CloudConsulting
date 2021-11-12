import { api, LightningElement, wire } from "lwc";
import getRequiredRoles from "@salesforce/apex/AllocationFilterController.getRequiredRoles";
export default class ResourceAllocation extends LightningElement {
  @api recordId; //projectId
  @api totalVSCoveredHours = [];
  requiredRoleNames;
  projectDates;

  @wire(getRequiredRoles, { projectID: "$recordId" })
  // eslint-disable-next-line no-unused-vars
  rolesObject({ error, data }) {
    if (data) {
      this.requiredRoleNames = data.map((role) => {

        this.totalVSCoveredHours.push({
          role: role.Role__c,
          requiredHours: role.Quantity__c,
          totalCovered: role.TotalCoverage__c
        });
        return {nameRole : role.Role__c, requiredRoleObjId: role.Id};
      });
      this.projectDates = `Project starts from ${data[0].Project__r.Start_Date__c} until ${data[0].Project__r.End_Date__c}`;
      console.log(this.totalVSCoveredHours);
    }
  }
}