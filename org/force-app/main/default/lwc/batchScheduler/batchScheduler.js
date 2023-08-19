import { LightningElement, api, track } from "lwc";
import getScheduledJobStatus from '@salesforce/apex/JobSchedulerService.getJobStatus';
import scheduleJob from '@salesforce/apex/JobSchedulerService.schedule';
import abortJob from '@salesforce/apex/JobSchedulerService.abort';
import runBatchJob from '@salesforce/apex/BatchJobStarterService.executeBatchJob';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import {
  subscribe,
  unsubscribe,
  onError,
} from "lightning/empApi";

const BUTTON_VARIANT = {
  destructive: "destructive",
  brand: "brand"
};

const BUTTON_LABEL = {
  destructive: "Abort Batch",
  brand: "Schedule batch"
};

export default class BatchScheduler extends LightningElement {
  @api
  componentTitle
  @api
  componentDescriptionText
  @api
  batchableClassName;
  @api
  schedulableClassName;

  channelName = "/event/AsyncJobChangeEvent__e";
  subscription = {};
  jobName = "Lwc Scope Job";
  jobScheduled = false;
  cronTip = "Example: CronExpression<0 15 10 * * ? 2005> Fire at 10:15 AM every day during the year 2005";
  cron = ""
  
  scheduleButtonVariant = BUTTON_VARIANT.brand;
  scheduleButtonLabel = BUTTON_LABEL.brand;

  connectedCallback() {
    this.jobName = `Lwc Scope Job Of Class "${this.schedulableClassName}"`;
    this.refineSchedulingJobStatus();

    subscribe(this.channelName, -1, (message) => {
      console.log(message);
      let name = message.data.payload.JobName__c;
      let type = message.data.payload.JobType__c;

      if (name === this.jobName && type === 'ScheduledApex') {
        this.refineSchedulingJobStatus();
      }
    }).then((response) => {
      this.subscription = response;
      console.log("Subscription request sent to: " + JSON.stringify(response.channel));
    });

    onError((error) => {
      console.log(error);

      this.dispatchEvent(new ShowToastEvent({
        title: 'Server Error',
        message: 'Error: ' + error.body.message,
        variant: 'error'
      }));
    });
  }

  disconnectedCallback() {
    unsubscribe(this.subscription, (response) => {
      console.log("Unsubscribe response: " + JSON.stringify(response));
    });
  }

  setButtonScheduling(scheduling) {
    if (scheduling) {
      this.scheduleButtonVariant = BUTTON_VARIANT.destructive;
      this.scheduleButtonLabel = BUTTON_LABEL.destructive;
    } else {
      this.scheduleButtonVariant = BUTTON_VARIANT.brand;
      this.scheduleButtonLabel = BUTTON_LABEL.brand;
    }
  }

  scheduleJob() {
    console.log(this.cron);

    scheduleJob({
      jobName: this.jobName,
      cron: this.cron,
      schedulableClassName: this.schedulableClassName
    }).then((result) => {
      this.jobScheduled = true;
      this.setButtonScheduling(true);

      this.dispatchEvent(new ShowToastEvent({
        title: 'Job scheduled successfuly',
        message: `Job of class "${this.batchableClassName}" was scheduled.`,
        variant: 'success'
      }));
    }).catch((error) => {
      console.log(error);
      this.dispatchEvent(new ShowToastEvent({
        title: 'Fail to schedule',
        message: 'Error: ' + error.body.message,
        variant: 'error'
      }));
    });
  }

  abortJob() {
    abortJob({
      jobName: this.jobName
    }).then((result) => {
      this.jobScheduled = false;
      this.setButtonScheduling(false);

      this.dispatchEvent(new ShowToastEvent({
        title: 'Info',
        message: `Job of class "${this.batchableClassName}" was aborted.`,
        variant: 'info'
      }));
    }).catch((error) => {
      this.dispatchEvent(new ShowToastEvent({
        title: 'Fail to abort job',
        message: 'Error: ' + error.body.message,
        variant: 'error'
      }));
    });
  }

  refineSchedulingJobStatus() {
    getScheduledJobStatus({
      jobName: this.jobName
    }).then((asyncJobStatus) => {
      this.jobScheduled = false;

      if (asyncJobStatus == null) {
        this.cron = ""
        return;
      }

      let state = asyncJobStatus.CronTrigger.State;
      this.cron = asyncJobStatus.CronTrigger.CronExpression;

      if ('COMPLETE' !== state && 'DELETED' !== state) {
        this.jobScheduled = true;       
      } else {
        this.abortJob();
      }

      this.setButtonScheduling(this.jobScheduled);
    }).catch((error) => {
      console.log(error);
    });
  }

  handleScheduleButton(event) {
    event.target?.blur();

    if (!this.jobScheduled) {
      this.scheduleJob();
    } else {
      this.abortJob();
    }
  }

  handleRunOnceButton(event) {
    event.target?.blur();
    const button = event.target;
    button.disabled = true;

    runBatchJob({
      batchableClassName: this.batchableClassName
    }).then((result) => {
      this.dispatchEvent(new ShowToastEvent({
        title: 'Batch job was started successfuly',
        message: `Batch job of class "${this.batchableClassName}" has run.`,
        variant: 'success'
      }));

      button.disabled = false;
    }).catch((error) => {
      this.dispatchEvent(new ShowToastEvent({
        title: 'Fail to execute batch',
        message: 'Error: ' + error.body.message,
        variant: 'error'
      }));

      button.disabled = false;
    });
  }

  inputChange(event) {
    this.cron = event.target.value;
  }
}
