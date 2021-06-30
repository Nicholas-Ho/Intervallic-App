import 'package:flutter_test/flutter_test.dart';

import 'package:intervallic_app/utils/domain_layer/id_manager.dart';

void main() {
  group('Test with simple datatable.', () {
    IdManager idManager;

    setUp(() {
      Map<String, List<int>> idMaps = {'datatable_1': [1, 2, 3, 4]};

      idManager = IdManager(idMaps);
    });

    tearDown(() {}); // TearDown not required as idManager is reinitialised in setUp

    test('Test for nextAvailableID function.', () {
      var results = [];
      for(int i = 0; i < 5; i++) {
        results.add(idManager.nextAvailableID('datatable_1')); // Get a list of the next 5 values returned by nextAvailableID
      }

      expect(results, [5, 6, 7, 8, 9]);
    });

    test('Test for removeID function.', () {
      idManager.removeID('datatable_1', 3);

      var results = [];
      for(int i = 0; i < 5; i++) {
        results.add(idManager.nextAvailableID('datatable_1')); // Get a list of the next 5 values returned by nextAvailableID
      }

      expect(results, [3, 5, 6, 7, 8]);
    });
  });

  group('Test with complex datatable.', () { // Data table for testing is 'datatable_2'
    IdManager idManager;
    
    setUp(() {
      Map<String, List<int>> idMaps = {
        'datatable_1': [1],
        'datatable_2': [1, 2, 5, 6, 9, 11]
      };

      idManager = IdManager(idMaps);
    });

    tearDown(() {}); // TearDown not required as idManager is reinitialised in setUp

    test('Test for nextAvailableID function.', () {
      var results = [];
      for(int i = 0; i < 5; i++) {
        results.add(idManager.nextAvailableID('datatable_2')); // Get a list of the next 5 values returned by nextAvailableID
      }

      expect(results, [3, 4, 7, 8, 10]);
    });

    test('Test for removeID function.', () {
      idManager.removeID('datatable_2', 3); // Should have no effect and print warning
      idManager.removeID('datatable_2', 5);
      idManager.removeID('datatable_2', 2);
      // Remaining IDs should be [1, 6, 9, 11]

      var results = [];
      for(int i = 0; i < 5; i++) {
        results.add(idManager.nextAvailableID('datatable_2')); // Get a list of the next 5 values returned by nextAvailableID
      }

      expect(results, [2, 3, 4, 5, 7]);
    });

    test('Final, complex test.', () {
      idManager.removeID('datatable_2', 3); // Should have no effect and print warning
      idManager.removeID('datatable_2', 5);
      idManager.removeID('datatable_2', 2);
      // Remaining IDs should be [1, 6, 9, 11]

      var results = [];

      results.add(idManager.nextAvailableID('datatable_2'));
      results.add(idManager.nextAvailableID('datatable_2'));
      // Remaining IDs should be [1, 2, 3, 6, 9, 11]
      
      expect(results, [2, 3]);

      idManager.removeID('datatable_2', 2);
      // Remaining IDs should be [1, 3, 6, 9, 11]

      for(int i = 0; i < 5; i++) {
        results.add(idManager.nextAvailableID('datatable_2')); // Get a list of the next 5 values returned by nextAvailableID
      }

      expect(results, [2, 3, 2, 4, 5, 7, 8]);
    });
  });
}