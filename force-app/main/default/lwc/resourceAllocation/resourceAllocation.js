import { api, LightningElement, wire } from "lwc";
import getRequiredRoles from "@salesforce/apex/AllocationFilterController.getRequiredRoles";
import { refreshApex } from "@salesforce/apex";

export default class ResourceAllocation extends LightningElement {
  @api recordId; //projectId
  @api requiredRoleData; // array de Data por rol

  projectDates;
  wiredResult;

  @wire(getRequiredRoles, { projectID: "$recordId" })
  // eslint-disable-next-line no-unused-vars
  rolesObject(result) {
    this.wiredResult = result;
    this.totalVSCoveredHours = [];
    if (result.data) {
      this.requiredRoleData = result.data.map((role) => {
        return {
          role: role.Role__c,
          requiredHours: role.Quantity__c,
          totalCovered: role.TotalCoverage__c,
          nameRole: role.Role__c,
          requiredRoleObjId: role.Id
        };
      });
      this.projectDates = `Project starts from ${result.data[0].Project__r.Start_Date__c} until ${result.data[0].Project__r.End_Date__c}`;
    }
  }

  async refresh() {
    await refreshApex(this.wiredResult);
    this.template
      .querySelectorAll("c-users")
      .forEach((tabset) => tabset.loadData());
  }
}
