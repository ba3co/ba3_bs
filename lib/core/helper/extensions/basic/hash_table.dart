import 'package:flutter/cupertino.dart';

///
/// HashTable Implementation
///
/// 1. Infrastructure (Array)
/// 2. Operations:
///    - set
///    - get
///    - remove
///    - resize
///    - size
///
class HashTable<K, V> {
  late int initialSize;
  late int entriesCount;
  List<KeyValuePair?> entries = [];

  HashTable() {
    this.initialSize = 3;
    this.entriesCount = 0;
    this.entries = List.filled(initialSize, null);
  }

  void resizeOrNot() {
    if (entriesCount < entries.length) {
      return;
    }

    int newSize = entries.length * 2;

    debugPrint('resize from ${entries.length} to $newSize');

    List<KeyValuePair?> entriesCopy = List.filled(entries.length, null);

    for (int i = 0; i < entries.length; i++) {
      entriesCopy[i] = entries[i];
    }

    entries = List.filled(newSize, null);

    for (int i = 0; i < entriesCopy.length; i++) {
      if (entriesCopy[i] == null) continue;
      addToEntries(entriesCopy[i]?.key, entriesCopy[i]?.getValue);
    }
  }

  void addToEntries(K key, V value) {
    int hash = _hash(key);

    if (entries[hash] != null && entries[hash]!.key != key) {
      hash = _collisionHandling(key, hash, _HashTableOperations.set);
    }

    if (hash == -1) {
      throw Exception('No space in hash table');
    }

    if (entries[hash] == null) {
      KeyValuePair newKeyValuePair = KeyValuePair(key, value);
      entries[hash] = newKeyValuePair;
      entriesCount++;
    } else if (entries[hash]!.key == key) {
      entries[hash]!.value = value;
    } else {
      throw Exception('No space in hash table');
    }
  }

  /// FNV-1a hash function (32-bit)
  /// Converts a key into a valid array index.
  ///
  /// - **Input:** K key
  /// - **Output:** Hashed index within the array range
  int _hash(K key) {
    const int fnvOffsetBasis = 0x811c9dc5;
    const int fnvPrime = 0x01000193;

    int hash = fnvOffsetBasis;
    List<int> data = key.toString().codeUnits;

    for (int i = 0; i < data.length; i++) {
      hash ^= data[i];
      hash *= fnvPrime;
      hash &= 0xffffffff; // Keep within 32-bit range
    }

    return hash % entries.length; // Ensure index fits within table size
  }

  /// Handles collisions using **linear probing**.
  ///
  /// - **Input:** K key, int hash, _HashTableOperations operation
  /// - **Output:** New index for insertion/search, or -1 if not found.
  int _collisionHandling(K key, int hash, _HashTableOperations operation) {
    for (int i = 1; i < entries.length - 1; i++) {
      int probeIndex = (hash + i) % entries.length;

      if (operation == _HashTableOperations.set) {
        if (entries[probeIndex] == null || entries[probeIndex]?.key == key) {
          return probeIndex;
        }
      } else if (operation == _HashTableOperations.get) {
        if (entries[probeIndex]?.key == key) {
          return probeIndex;
        }
      }
    }

    return -1; // No available slot or key not found
  }
}

class KeyValuePair<K, V> {
  KeyValuePair(this._key, this._value);

  final K _key;
  V _value;

  K get key => _key;

  V get getValue => _value;

  set value(V value) => _value = value;
}

enum _HashTableOperations { set, get, remove, resize, size }
