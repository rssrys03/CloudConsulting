import { api, LightningElement, wire } from "lwc";
import getRequiredRoles from "@salesforce/apex/AllocationFilterController.getRequiredRoles";
import getResourcesInProject from "@salesforce/apex/AllocationFilterController.getResourcesInProject";
import { refreshApex } from "@salesforce/apex";

export default class ResourceAllocation extends LightningElement {
  @api recordId; //projectId
  @api totalVSCoveredHours;
  @api requiredRoleNames;
  changeSquadLead = true;
  actualSquadLead;
  squadOptions;
  projectDates;
  wiredResult;


  connectedCallback(){
    this.loadData();
  }

  loadData() {
    getResourcesInProject({ projectId: this.recordId }).then(
      (squadLeadOptions) => {
        this.squadOptions = squadLeadOptions.map((object) => {
          return {
            label: `${object.Resources__r.FirstName} ${object.Resources__r.LastName}`,
            value: object.Resources__r.Id
          };
        });
        console.log('SQUADDD',this.squadOptions);
      }
    );
  }

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
    this.template
      .querySelectorAll("c-users")
      .forEach((tabset) => tabset.loadData());
  }
}
