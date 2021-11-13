import { api, LightningElement, wire } from "lwc";
import getRequiredRoles from "@salesforce/apex/AllocationFilterController.getRequiredRoles";
import { refreshApex } from "@salesforce/apex";

export default class ResourceAllocation extends LightningElement {
  @api recordId; //projectId
  @api totalVSCoveredHours;
  @api requiredRoleNames;
  projectDates;
  @api wiredResult;

  @wire(getRequiredRoles, { projectID: "$recordId" })
  // eslint-disable-next-line no-unused-vars
  rolesObject(result) {
    this.wiredResult = result;
    this.totalVSCoveredHours = [];
    if (result.data) {
      this.requiredRoleNames = result.data.map((role) => {
        this.totalVSCoveredHours.push({
          role: role.Role__c,
          requiredHours: role.Quantity__c,
          totalCovered: role.TotalCoverage__c
        });
        return { nameRole: role.Role__c, requiredRoleObjId: role.Id };
      });
      this.projectDates = `Project starts from ${result.data[0].Project__r.Start_Date__c} until ${result.data[0].Project__r.End_Date__c}`;
    }
  }
  @api async refresh() {
    await refreshApex(this.wiredResult);
    this.template.querySelectorAll("c-users").forEach(tabset => tabset.loadData());
  }
}
