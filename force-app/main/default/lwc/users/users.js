/* eslint-disable array-callback-return */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { api, LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import checkAllocatedResources from "@salesforce/apex/AllocationFilterController.checkAllocatedResources";
import insertResourceAllocations from "@salesforce/apex/ResourceAllocationController.insertResourceAllocations";

const SUCCESS_TITLE = "Success";
const SUCCESS_MESSAGE = "Resource allocated in this Project!";
const SUCCESS_VARIANT = "success";
const ERROR_TITLE = "Error";
const ERROR_VARIANT = "error";

export default class Users extends LightningElement {
  @api role;
  @api project;
  @api totalCoverage;
  @api requiredRoleObjId;
  @api totalCovered;

  data;
  @api wiredResult;

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
    this.loadData();
  }

  @api loadData() {
    console.log(JSON.parse(JSON.stringify(this.totalCoverage)));

    this.totalCovered = JSON.parse(JSON.stringify(this.totalCoverage)).filter(
      // eslint-disable-next-line consistent-return
      (coverage) => {
        if (coverage.role === this.role) return coverage;
      }
    )[0];

    console.log("TOTAL COVERED",this.totalCovered);
  }

  @wire(checkAllocatedResources, { projectID: "$project", roleName: "$role" })
  // eslint-disable-next-line no-unused-vars
  availableUsers(result) {
    this.wiredResult = result;
    if (result.data && result.data.length > 0) {
      console.log(result.data);
      this.data = result.data;
    }
  }

  handleSave(event) {
    let listObject = JSON.parse(JSON.stringify(event.detail.draftValues));

    console.log("OBJECTLIST", listObject);
    insertResourceAllocations({
      allocationData: listObject,
      requiredRoleId: this.requiredRoleObjId
    })
      .then(() => {
        const success = new ShowToastEvent({
          title: SUCCESS_TITLE,
          message: SUCCESS_MESSAGE,
          variant: SUCCESS_VARIANT
        });
        this.dispatchEvent(success);
        this.template.querySelector("lightning-datatable").draftValues = [];
        this.dispatchEvent(new CustomEvent("refresh"));
        return refreshApex(this.wiredResult);
      })
      .catch((err) => {
        console.log(err.body.message);
        let errors = "";
        if (err.body.message) {
          errors = err.body.message;
        } else {
          err.body.pageErrors.forEach((error) => {
            errors += error.message + ". ";
          });
        }

        const error = new ShowToastEvent({
          title: ERROR_TITLE,
          message: errors,
          variant: ERROR_VARIANT
        });
        this.dispatchEvent(error);
      });
  }
}
