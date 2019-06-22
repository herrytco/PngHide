class BitData {
  /// stores the assembled integer the bits form
  int _source;

  /// represents the assembled integer
  int get result => _source;

  /// creates a new BitData object with an integer as base.
  BitData(this._source);

  /// returns the bit on [position], starting by 0 (big endian).
  int getBit(int position) {
    return (_source & (1 << position)) >> position;
  }

  /// sets the bit on [position] to [value]
  ///
  /// 'true' ... 1
  /// 'false' ... 0
  void setBit(int pos, bool value) {
    if (value) {
      //set bit to 1
      _source = _source | (1 << pos);
    } else {
      //set bit to 0
      _source = _source & ~(1 << pos);
    }
  }

  /// returns the String representation of the BitData. It contains the binary representation as well as the integer.
  @override
  String toString() {
    List<int> result = [];
    String r = "";

    int temp = _source;

    while (temp > 0) {
      result.add(temp % 2);
      temp = temp ~/ 2;
    }

    int i = 0;

    for (int bit in result.reversed) {
      r += bit.toString();
      i++;

      if (i % 4 == 0) r += " ";
    }

    r += "($_source)";

    return r;
  }
}
