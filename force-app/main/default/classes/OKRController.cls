public with sharing class OKRController {

    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [
            SELECT Id, Name 
            FROM User 
            WHERE IsActive = true 
            ORDER BY Name ASC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<OKR_Objective__c> getObjectives(String userId, String year) {
        Id targetUser = String.isBlank(userId) ? UserInfo.getUserId() : (Id)userId;
        Decimal targetYear = String.isBlank(year) ? Date.today().year() : Decimal.valueOf(year);
        
        List<OKR_Objective__c> objectives = [
            SELECT Id, Name, Objective_Year__c, OwnerId, Sort_Order__c,
                (SELECT Id, Name, Target__c, Completed__c, Measure_Type__c, Measure_Filter__c,
                    (SELECT Id, Name, Target__c, Completed__c FROM Reviews__r),
                    (SELECT Id, Name, Target__c, Completed__c FROM Surveys__r),
                    (SELECT Id, Name, Target__c, Completed__c FROM Case_Studies__r),
                    (SELECT Id, Name, Target__c, Completed__c FROM Google_Reviews__r)
                 FROM OKR_Key_Results__r)
            FROM OKR_Objective__c
            WHERE OwnerId = :targetUser 
            AND Objective_Year__c = :targetYear
            ORDER BY Sort_Order__c ASC
        ];

        Integer startYear = Integer.valueOf(targetYear);
        DateTime startDT = DateTime.newInstance(startYear, 1, 1, 0, 0, 0);
        DateTime endDT = DateTime.newInstance(startYear, 12, 31, 23, 59, 59);

        Integer oppCount = [SELECT COUNT() FROM Opportunity WHERE OwnerId = :targetUser AND CreatedDate >= :startDT AND CreatedDate <= :endDT];
        Integer callCount = [SELECT COUNT() FROM Task WHERE OwnerId = :targetUser AND TaskSubtype = 'Call' AND CreatedDate >= :startDT AND CreatedDate <= :endDT];
        Integer contractCount = [SELECT COUNT() FROM Contract WHERE OwnerId = :targetUser AND CreatedDate >= :startDT AND CreatedDate <= :endDT];
        Integer webLeadCount = [SELECT COUNT() FROM Lead WHERE OwnerId = :targetUser AND LeadSource = 'Web' AND CreatedDate >= :startDT AND CreatedDate <= :endDT];

        for (OKR_Objective__c obj : objectives) {
            if (obj.OKR_Key_Results__r != null) {
                for (OKR_Key_Result__c kr : obj.OKR_Key_Results__r) {
                    if (kr.Measure_Type__c == 'Opportunities') {
                        kr.Completed__c = oppCount;
                    } else if (kr.Measure_Type__c == 'Calls') {
                        kr.Completed__c = callCount;
                    } else if (kr.Measure_Type__c == 'Contracts') {
                        kr.Completed__c = contractCount;
                    } else if (kr.Measure_Type__c == 'Web Leads') {
                        kr.Completed__c = webLeadCount;
                    }
                }
            }
        }

        return objectives;
    }
}