import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quicksort test', () {
    final data = [1, 3, 5, 2, 4];

    expect(_quicksort(data), [1, 2, 3, 4, 5]);
  });

  group('Binary sort (add to sorted list) tests', () {
    test('Simple test - middle', () {
      final data = [1, 2, 4, 5];

      expect(_addToSortedList(data, 3), [1, 2, 3, 4, 5]);
    });

    test('Simple test - near end', () {
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 10];

      expect(_addToSortedList(data, 9), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('Simple test - end', () {
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9];

      expect(_addToSortedList(data, 10), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('Simple test - near start', () {
      final data = [1, 3, 4, 5, 6, 7, 8, 9, 10];

      expect(_addToSortedList(data, 2), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('Simple test - start', () {
      final data = [2, 3, 4, 5, 6, 7, 8, 9, 10];

      expect(_addToSortedList(data, 1), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('Duplicated test', () {
      final data = [1, 2, 2, 3, 4, 5];

      expect(_addToSortedList(data, 3), [1, 2, 2, 3, 3, 4, 5]);
    });
  });

  test('Binary search with ID', () {
    var list = [
      for(int i = 0; i < 7; i++)
        PendingNotificationRequest(31 + i, null, null, (i+1).toString())
    ];

    print([
      for(int i = 0; i < list.length; i++)
        list[i].id
    ]);

    final resultList = list;
    final element_1 = PendingNotificationRequest(41, null, null, 1.toString());
    resultList.insert(1, element_1);
    print([
      for(int i = 0; i < resultList.length; i++)
        resultList[i].id
    ]);

    final element_2 = PendingNotificationRequest(42, null, null, 2.toString());
    resultList.insert(3, element_2);
    print([
      for(int i = 0; i < resultList.length; i++)
        resultList[i].id
    ]);

    list = _addToScheduledNotificationsList(list, element_1);

    expect(_addToScheduledNotificationsList(list, element_2), resultList);
  });
}

// Quicksorting
List<int> _quicksort(List<int> list) {
  int process(int data) {
    return data;
  }

  int partition() {
    final pivot = list[list.length - 1]; // Use the last element as the pivot
    final pivotPayload = process(pivot);

    int i = -1;

    print("Original: $list");
    print("Pivot: $pivot");

    for(int j = 0; j < list.length - 1; j++) {
      print('First: ${list[j]}, Pivot: $pivotPayload');
      if(process(list[j]) < pivotPayload) {
        i++;
        
        // Swap list[j] and list[i]
        final tempNotif = list[j];
        list[j] = list[i];
        list[i] = tempNotif;
      }
      print(list);
    }

    // Swap pivot and list[i+1]
    list[list.length - 1] = list[i+1];
    list[i+1] = pivot;

    return i+1;
  }

  if(list.length > 1) {
    final pivotIndex = partition();
    
    return _quicksort(list.sublist(0, pivotIndex)) + [list[pivotIndex]] + _quicksort(list.sublist(pivotIndex+1));
  } else {
    return list;
  }
}

List<int> _addToSortedList(List<int> list, int element) {
  int process(int element) {
    return element;
  }

  if(list.isNotEmpty) {
    final index = _findIndex(list, 0, list.length - 1, element, process);
    list.insert(index, element);
  } else {
    list.add(element);
  }

  return list;
}

// Binary search algorithm to find the index to insert Request
int _findIndex(List<dynamic> list, int min, int max, dynamic x, Function process) {
  final xData = process(x);

  if(min == max) {
    // If list[min] is earlier than xDate, return index to the right
    if(process(list[min]) < xData) {
      return min + 1;
    } else {
      // Or else return current index
      return min;
    }
  } else {
    // Checking if (mid + 1) is suitable to insert
    final mid = ((min + max) / 2).floor();

    // If list[mid] is later than xDate, repeat with left half of remaining list
    if(process(list[mid]) > xData) {
      return _findIndex(list, min, mid, x, process);
    } else if(process(list[mid + 1]) < xData) {
      // If list[mid + 1] is earlier than xDate, repeat with right half of remaining list
      return _findIndex(list, mid + 1, max, x, process);
    } else {
      return mid + 1;
    }
  }
}

// Add Pending Notification Request into sorted Scheduled Notifications List
List<PendingNotificationRequest> _addToScheduledNotificationsList(List<PendingNotificationRequest> list, PendingNotificationRequest request) {
  // Binary search algorithm to find the index to insert Request (compares ID if values are equal)
  int _findIndex(List<dynamic> list, int min, int max, dynamic x, Function process) {
    final xData = process(x);

    if(min == max) {
      final listMin = process(list[min]);
      // If list[min] is smaller than xData, return index to the right
      if(listMin < xData) {
        return min + 1;
      } else if(listMin > xData) {
        // If list[min] is greater than xData, return current index
        return min;
      } else {
        // If they are equal, compare IDs
        if(list[min].id < x.id) {
          return min + 1;
        } else {
          return min;
        }
      }
    } else {
      // Checking if (mid + 1) is suitable to insert
      final mid = ((min + max) / 2).floor();

      // If list[mid] is greater than xData (or they are equal but list[mid] has a greater ID), repeat with left half of remaining list
      if(process(list[mid]) > xData || (process(list[mid]) == xData && list[mid].id > x.id)) {
        return _findIndex(list, min, mid, x, process);
      } else if(process(list[mid + 1]) < xData || (process(list[mid + 1]) == xData && list[mid + 1].id < x.id)) {
        // If list[mid + 1] is smaller than xData (or they are equal but list[mid] has a smaller ID), repeat with right half of remaining list
        return _findIndex(list, mid + 1, max, x, process);
      } else {
        return mid + 1;
      }
    }
  }

  int process(PendingNotificationRequest data) {
    return int.parse(data.payload!);
  }

  if(list.isNotEmpty) {
    final index = _findIndex(list, 0, list.length - 1, request, process);
    list.insert(index, request);
  } else {
    list.add(request);
  }

  return list;
}

  