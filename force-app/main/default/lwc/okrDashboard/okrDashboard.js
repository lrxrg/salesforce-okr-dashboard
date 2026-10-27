import { LightningElement, track, wire } from 'lwc';
import getObjectives from '@salesforce/apex/OKRController.getObjectives';
import getUsers from '@salesforce/apex/OKRController.getUsers';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';

export default class OkrDashboard extends NavigationMixin(LightningElement) {
    @track categories = [];
    @track selectedUser = USER_ID;
    @track selectedYear = '2026';
    @track userOptions = [];

    yearOptions = [
        { label: '2025', value: '2025' },
        { label: '2026', value: '2026' },
        { label: '2027', value: '2027' }
    ];

    @wire(getUsers)
    wiredUsers({ data, error }) {
        if (data) {
            this.userOptions = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
        } else if (error) {
            console.error('Error loading users', error);
        }
    }

    @wire(getObjectives, { userId: '$selectedUser', year: '$selectedYear' })
    wiredObjectives({ data, error }) {
        if (data) {
            this.categories = data.map(objective => {
                let cardList = [];

                if (objective.OKR_Key_Results__r && objective.OKR_Key_Results__r.length > 0) {
                    cardList = objective.OKR_Key_Results__r.map(kr => {
                        let metricsList = [];

                        if (kr.Target__c !== null && kr.Target__c !== undefined) {
                            metricsList.push({
                                label: kr.Measure_Type__c || kr.Name,
                                completed: kr.Completed__c !== undefined && kr.Completed__c !== null ? kr.Completed__c : 0,
                                target: kr.Target__c
                            });
                        }

                        if (kr.Reviews__r && kr.Reviews__r.length > 0) {
                            kr.Reviews__r.forEach(rev => {
                                metricsList.push({
                                    label: rev.Name,
                                    completed: rev.Completed__c || 0,
                                    target: rev.Target__c || 0
                                });
                            });
                        }

                        if (kr.Surveys__r && kr.Surveys__r.length > 0) {
                            kr.Surveys__r.forEach(surv => {
                                metricsList.push({
                                    label: surv.Name,
                                    completed: surv.Completed__c || 0,
                                    target: surv.Target__c || 0
                                });
                            });
                        }

                        if (kr.Case_Studies__r && kr.Case_Studies__r.length > 0) {
                            kr.Case_Studies__r.forEach(cs => {
                                metricsList.push({
                                    label: cs.Name,
                                    completed: cs.Completed__c || 0,
                                    target: cs.Target__c || 0
                                });
                            });
                        }

                        if (kr.Google_Reviews__r && kr.Google_Reviews__r.length > 0) {
                            kr.Google_Reviews__r.forEach(gRev => {
                                metricsList.push({
                                    label: gRev.Name,
                                    completed: gRev.Completed__c || 0,
                                    target: gRev.Target__c || 0
                                });
                            });
                        }


                        if (metricsList.length === 0) {
                            metricsList.push({
                                label: 'Progress',
                                completed: kr.Completed__c || 0,
                                target: kr.Target__c || 0
                            });
                        }

                        return {
                            Id: kr.Id,
                            Name: kr.Name,
                            status: 'In progress',
                            metrics: metricsList
                        };
                    });
                }

                return {
                    categoryId: objective.Id,
                    categoryName: objective.Name,
                    cards: cardList
                };
            });
        } else if (error) {
            console.error('Error loading data', error);
        }
    }

    handleYearChange(event) {
        this.selectedYear = event.detail.value;
    }

    handleUserChange(event) {
        this.selectedUser = event.detail.value;
    }

    handleMenuSelect(event) {
        const selectedAction = event.detail.value;
        let targetObject = 'OKR_Objective__c';
        
        if (selectedAction === 'new_key_result') {
            targetObject = 'OKR_Key_Result__c';
        } else if (selectedAction === 'new_review') {
            targetObject = 'Review__c';
        } else if (selectedAction === 'new_survey') {
            targetObject = 'Survey__c';
        } else if (selectedAction === 'new_case_study') {
            targetObject = 'Case_Study__c';
        } else if (selectedAction === 'new_google_review') {
            targetObject = 'Google_Review__c';
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: targetObject,
                actionName: 'new'
            }
        });
    }
}