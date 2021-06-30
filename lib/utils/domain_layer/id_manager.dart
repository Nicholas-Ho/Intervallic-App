// An object to manage the id assignment of data
class IdManager {
  Map<String, List<int>> _idMaps;
  Map<String, int> _nextAvailableIDs;

  IdManager(Map<String, List<int>> idMaps) { // Pass in the raw values of the SQL query of Primary Keys in a table
    _idMaps = {};
    _nextAvailableIDs = {};
    idMaps.forEach((key, value) {
      value.sort(); // sort just in case
      _idMaps[key] = value;

      // For the following sorted id list: [1, 2, 3, 6], since when the index = 3, value = 6, which is not index + 1, the next available id is 4
      // For the following sorted id list: [1, 2, 3, 4], since for all values, value = index + 1, the next available id is 5, or length + 1
      int nextAvailableID = value.length + 1;
      for (int i = 0; i < value.length; i++) {
        if(value[i] != i + 1) {
          nextAvailableID = i + 1;
          break;
        }
      }
      _nextAvailableIDs[key] = nextAvailableID;
    });
  }

  int nextAvailableID(String table) {
    int nextAvailableID = _nextAvailableIDs[table]; // current nextAvailableID
    _idMaps[table].insert(nextAvailableID - 1, nextAvailableID);

    int newAvailableID = _idMaps[table].length + 1;
    for (int i = nextAvailableID; i < _idMaps[table].length; i++) { // We only need to check from the current nextAvailableID
      if(_idMaps[table][i] != i + 1) {
        newAvailableID = i + 1;
        break;
      }
    }
    _nextAvailableIDs[table] = newAvailableID;

    return nextAvailableID;
  }

  void removeID(String table, int id) {
    if (_nextAvailableIDs[table] > id) {
      _nextAvailableIDs[table] = id;
    }

    final wasPresent = _idMaps[table].remove(id);
    
    if(!wasPresent) {
      print('ID was not present!');
    }
  }
}