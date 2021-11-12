/* eslint-disable array-callback-return */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { api, LightningElement, wire } from "lwc";
import checkAllocatedResources from "@salesforce/apex/AllocationFilterController.checkAllocatedResources";

export default class Users extends LightningElement {
  @api role;
  @api project;
  @api totalCoverage;
  data;
  columns = [
    { label: "First Name", fieldName: "FirstName" },
    { label: "Last Name", fieldName: "LastName" },
    {
      label: "Start Date",
      fieldName: "StartDate",
      editable: true,
      type: "date-local",
      typeAttributes: {
        day: "2-digit",
        month: "2-digit",
        year: "numeric"
      }
    },
    {
      label: "End Date",
      fieldName: "EndDate",
      editable: true,
      type: "date-local",
      typeAttributes: {
        day: "2-digit",
        month: "2-digit",
        year: "numeric"
      }
    }
  ];

  connectedCallback() {
    this.totalCoverage = JSON.parse(JSON.stringify(this.totalCoverage)).filter(
      // eslint-disable-next-line consistent-return
      (coverage) => {
        if (coverage.role === this.role) return coverage;
      }
    );
    this.totalCoverage = this.totalCoverage[0];
    console.log("COVERAGE2", this.totalCoverage);
  }

  @wire(checkAllocatedResources, { projectID: "$project", roleName: "$role" })
  // eslint-disable-next-line no-unused-vars
  availableUsers({ error, data }) {
    console.log(data);
    if (data) {
      console.log(data);
      this.data = data;
    }
  }

  handleSave(event) {
    console.log(JSON.parse(JSON.stringify(event.detail.draftValues)));
  }
}