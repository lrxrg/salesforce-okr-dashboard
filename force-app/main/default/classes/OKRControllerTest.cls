@isTest
private class OKRControllerTest {

    @TestSetup
    static void setupTestData() {
        OKR_Objective__c obj = new OKR_Objective__c(
            Name = 'Q1 Sales Objective',
            Objective_Year__c = 2026,
            Sort_Order__c = 1,
            OwnerId = UserInfo.getUserId()
        );
        insert obj;

        List<OKR_Key_Result__c> keyResults = new List<OKR_Key_Result__c>{
            new OKR_Key_Result__c(
                Name = 'KR - Opportunities',
                Objective__c = obj.Id,
                Measure_Type__c = 'Opportunities',
                Target__c = 10,
                Completed__c = 0
            ),
            new OKR_Key_Result__c(
                Name = 'KR - Calls',
                Objective__c = obj.Id,
                Measure_Type__c = 'Calls',
                Target__c = 50,
                Completed__c = 0
            ),
            new OKR_Key_Result__c(
                Name = 'KR - Contracts',
                Objective__c = obj.Id,
                Measure_Type__c = 'Contracts',
                Target__c = 5,
                Completed__c = 0
            ),
            new OKR_Key_Result__c(
                Name = 'KR - Web Leads',
                Objective__c = obj.Id,
                Measure_Type__c = 'Web Leads',
                Target__c = 20,
                Completed__c = 0
            )
        };
        insert keyResults;

        OKR_Key_Result__c krForChildren = keyResults[0];

        insert new Review__c(
            Name = 'Review Test',
            OKR_Key_Result__c = krForChildren.Id,
            Target__c = 5,
            Completed__c = 2
        );

        insert new Survey__c(
            Name = 'Survey Test',
            OKR_Key_Result__c = krForChildren.Id,
            Target__c = 10,
            Completed__c = 4
        );

        insert new Case_Study__c(
            Name = 'Case Study Test',
            OKR_Key_Result__c = krForChildren.Id,
            Target__c = 3,
            Completed__c = 1
        );

        insert new Google_Review__c(
            Name = 'Google Review Test',
            OKR_Key_Result__c = krForChildren.Id,
            Target__c = 5,
            Completed__c = 3
        );

        insert new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            OwnerId = UserInfo.getUserId()
        );

        insert new Task(
            Subject = 'Call Client',
            TaskSubtype = 'Call',
            Status = 'Completed',
            OwnerId = UserInfo.getUserId()
        );

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        insert new Contract(
            AccountId = acc.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12,
            OwnerId = UserInfo.getUserId()
        );

        insert new Lead(
            LastName = 'Lead Test',
            Company = 'Test Co',
            LeadSource = 'Web',
            OwnerId = UserInfo.getUserId()
        );
    }

    @isTest
    static void testGetUsers() {
        Test.startTest();
        List<User> users = OKRController.getUsers();
        Test.stopTest();

        System.assert(users.size() > 0, 'Should return active users in the org');
    }

    @isTest
    static void testGetObjectivesWithParameters() {
        String currentUserId = UserInfo.getUserId();
        String currentYear = String.valueOf(Date.today().year());

        Test.startTest();
        List<OKR_Objective__c> results = OKRController.getObjectives(currentUserId, currentYear);
        Test.stopTest();

        System.assert(results.size() > 0, 'Should return objectives for the given user and year');
        System.assertEquals('Q1 Sales Objective', results[0].Name, 'Objective name should match test data');

        System.assert(results[0].OKR_Key_Results__r.size() > 0, 'Should retrieve child Key Results');
        for (OKR_Key_Result__c kr : results[0].OKR_Key_Results__r) {
            if (kr.Measure_Type__c == 'Opportunities') {
                System.assertEquals(1, kr.Completed__c, 'Completed Opportunities count should match created test records');
            } else if (kr.Measure_Type__c == 'Calls') {
                System.assertEquals(1, kr.Completed__c, 'Completed Calls count should match created test records');
            } else if (kr.Measure_Type__c == 'Contracts') {
                System.assertEquals(1, kr.Completed__c, 'Completed Contracts count should match created test records');
            } else if (kr.Measure_Type__c == 'Web Leads') {
                System.assertEquals(1, kr.Completed__c, 'Completed Web Leads count should match created test records');
            }
        }
    }

    @isTest
    static void testGetObjectivesWithBlankParameters() {
        Test.startTest();
        List<OKR_Objective__c> results = OKRController.getObjectives(null, '');
        Test.stopTest();

        System.assert(results.size() > 0, 'Blank parameters should fallback and return user objectives');
    }
}