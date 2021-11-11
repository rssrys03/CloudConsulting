import { api, LightningElement, wire } from "lwc";
import checkAllocatedResources from "@salesforce/apex/AllocationFilterController.checkAllocatedResources";

export default class Users extends LightningElement {
  @api role;
  @api project;
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

  @wire(checkAllocatedResources, { projectID: "$project", roleName: "$role" })
  availableUsers({ error, data }) {
    console.log(this.role, this.projectId);
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
