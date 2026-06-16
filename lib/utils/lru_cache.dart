class LruCache<K, V> {
  final int maxSize;
  final Map<K, V> _map = {};

  LruCache({this.maxSize = 100});

  V? get(K key) {
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value;
    }
    return value;
  }

  void put(K key, V value) {
    _map.remove(key);
    if (_map.length >= maxSize) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }

  V? operator [](K key) => get(key);

  void operator []=(K key, V value) => put(key, value);

  void clear() => _map.clear();

  int get length => _map.length;
}
