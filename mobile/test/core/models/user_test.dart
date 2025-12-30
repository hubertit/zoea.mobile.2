import 'package:flutter_test/flutter_test.dart';
import 'package:zoea2/core/models/user.dart';

void main() {
  group('UserPreferences - UX-First Data Collection', () {
    test('should create UserPreferences with new fields', () {
      final preferences = UserPreferences(
        language: 'en',
        currency: 'RWF',
        countryOfOrigin: 'RW',
        userType: UserType.resident,
        visitPurpose: VisitPurpose.leisure,
        ageRange: AgeRange.range26_35,
        gender: Gender.male,
        lengthOfStay: LengthOfStay.fourToSevenDays,
        travelParty: TravelParty.couple,
        interests: ['adventure', 'culture'],
      );

      expect(preferences.countryOfOrigin, 'RW');
      expect(preferences.userType, UserType.resident);
      expect(preferences.visitPurpose, VisitPurpose.leisure);
      expect(preferences.ageRange, AgeRange.range26_35);
      expect(preferences.gender, Gender.male);
      expect(preferences.lengthOfStay, LengthOfStay.fourToSevenDays);
      expect(preferences.travelParty, TravelParty.couple);
      expect(preferences.interests, ['adventure', 'culture']);
    });

    test('should serialize UserPreferences to JSON with new fields', () {
      final preferences = UserPreferences(
        countryOfOrigin: 'RW',
        userType: UserType.visitor,
        visitPurpose: VisitPurpose.business,
        ageRange: AgeRange.range36_45,
        gender: Gender.female,
        lengthOfStay: LengthOfStay.oneToTwoWeeks,
        travelParty: TravelParty.family,
        dataCollectionFlags: {'ageAsked': true, 'genderAsked': true},
      );

      final json = preferences.toJson();

      expect(json['countryOfOrigin'], 'RW');
      expect(json['userType'], 'visitor');
      expect(json['visitPurpose'], 'business');
      expect(json['ageRange'], '36-45');
      expect(json['gender'], 'female');
      expect(json['lengthOfStay'], '1-2 weeks');
      expect(json['travelParty'], 'family');
      expect(json['dataCollectionFlags'], {'ageAsked': true, 'genderAsked': true});
    });

    test('should deserialize UserPreferences from JSON with new fields', () {
      final json = {
        'language': 'en',
        'currency': 'RWF',
        'countryOfOrigin': 'US',
        'userType': 'visitor',
        'visitPurpose': 'mice',
        'ageRange': '26-35',
        'gender': 'prefer_not_to_say',
        'lengthOfStay': '4-7 days',
        'travelParty': 'solo',
        'interests': ['adventure'],
        'dataCollectionFlags': {'countryAsked': true},
      };

      final preferences = UserPreferences.fromJson(json);

      expect(preferences.countryOfOrigin, 'US');
      expect(preferences.userType, UserType.visitor);
      expect(preferences.visitPurpose, VisitPurpose.mice);
      expect(preferences.ageRange, AgeRange.range26_35);
      expect(preferences.gender, Gender.preferNotToSay);
      expect(preferences.lengthOfStay, LengthOfStay.fourToSevenDays);
      expect(preferences.travelParty, TravelParty.solo);
      expect(preferences.interests, ['adventure']);
      expect(preferences.dataCollectionFlags['countryAsked'], true);
    });

    test('should check if mandatory data is complete', () {
      // Complete mandatory data
      final complete = UserPreferences(
        countryOfOrigin: 'RW',
        userType: UserType.resident,
        visitPurpose: VisitPurpose.leisure,
        language: 'en',
      );
      expect(complete.isMandatoryDataComplete, true);

      // Missing country
      final missingCountry = UserPreferences(
        userType: UserType.resident,
        visitPurpose: VisitPurpose.leisure,
        language: 'en',
      );
      expect(missingCountry.isMandatoryDataComplete, false);

      // Missing user type
      final missingUserType = UserPreferences(
        countryOfOrigin: 'RW',
        visitPurpose: VisitPurpose.leisure,
        language: 'en',
      );
      expect(missingUserType.isMandatoryDataComplete, false);
    });

    test('should calculate profile completion percentage', () {
      // Empty profile
      final empty = UserPreferences();
      expect(empty.profileCompletionPercentage, 0);

      // Partially complete
      final partial = UserPreferences(
        countryOfOrigin: 'RW',
        userType: UserType.resident,
        visitPurpose: VisitPurpose.leisure,
        language: 'en',
        ageRange: AgeRange.range26_35,
      );
      expect(partial.profileCompletionPercentage, 50);

      // Complete profile
      final complete = UserPreferences(
        countryOfOrigin: 'RW',
        userType: UserType.resident,
        visitPurpose: VisitPurpose.leisure,
        language: 'en',
        currency: 'RWF',
        ageRange: AgeRange.range26_35,
        gender: Gender.male,
        lengthOfStay: LengthOfStay.fourToSevenDays,
        travelParty: TravelParty.couple,
        interests: ['adventure'],
      );
      expect(complete.profileCompletionPercentage, 100);
    });

    test('should create copy with updated fields', () {
      final original = UserPreferences(
        countryOfOrigin: 'RW',
        userType: UserType.resident,
      );

      final updated = original.copyWith(
        countryOfOrigin: 'US',
        ageRange: AgeRange.range26_35,
      );

      expect(updated.countryOfOrigin, 'US');
      expect(updated.userType, UserType.resident); // Unchanged
      expect(updated.ageRange, AgeRange.range26_35);
    });
  });

  group('Enums - Extensions', () {
    test('UserType should have correct display names and API values', () {
      expect(UserType.resident.displayName, 'Resident');
      expect(UserType.visitor.displayName, 'Visitor');
      expect(UserType.resident.apiValue, 'resident');
      expect(UserType.visitor.apiValue, 'visitor');
      
      expect(UserTypeExtension.fromString('resident'), UserType.resident);
      expect(UserTypeExtension.fromString('visitor'), UserType.visitor);
      expect(UserTypeExtension.fromString('invalid'), null);
    });

    test('VisitPurpose should have correct display names and API values', () {
      expect(VisitPurpose.leisure.displayName, 'Leisure');
      expect(VisitPurpose.business.displayName, 'Business');
      expect(VisitPurpose.mice.displayName, 'MICE');
      
      expect(VisitPurposeExtension.fromString('leisure'), VisitPurpose.leisure);
      expect(VisitPurposeExtension.fromString('mice'), VisitPurpose.mice);
    });

    test('AgeRange should have correct display names and API values', () {
      expect(AgeRange.range18_25.displayName, '18-25');
      expect(AgeRange.range56Plus.displayName, '56+');
      
      expect(AgeRangeExtension.fromString('18-25'), AgeRange.range18_25);
      expect(AgeRangeExtension.fromString('56+'), AgeRange.range56Plus);
    });

    test('Gender should have correct display names and API values', () {
      expect(Gender.male.displayName, 'Male');
      expect(Gender.preferNotToSay.displayName, 'Prefer not to say');
      
      expect(GenderExtension.fromString('male'), Gender.male);
      expect(GenderExtension.fromString('prefer_not_to_say'), Gender.preferNotToSay);
    });

    test('LengthOfStay should have correct display names and API values', () {
      expect(LengthOfStay.oneToThreeDays.displayName, '1-3 days');
      expect(LengthOfStay.twoWeeksPlus.displayName, '2+ weeks');
      
      expect(LengthOfStayExtension.fromString('1-3 days'), LengthOfStay.oneToThreeDays);
      expect(LengthOfStayExtension.fromString('2+ weeks'), LengthOfStay.twoWeeksPlus);
    });

    test('TravelParty should have correct display names and API values', () {
      expect(TravelParty.solo.displayName, 'Solo');
      expect(TravelParty.family.displayName, 'Family');
      
      expect(TravelPartyExtension.fromString('solo'), TravelParty.solo);
      expect(TravelPartyExtension.fromString('family'), TravelParty.family);
    });
  });
}

