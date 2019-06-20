class BitData {
  int _source;
  int get result => _source;

  BitData(this._source);

  int getBit(int pos) {
    return (_source & (1 << pos)) >> pos;
  }

  void setBit(int pos, bool value) {
    if (value) {
      //set bit to 1
      _source = _source | (1 << pos);
    } else {
      //set bit to 0
      _source = _source & ~(1 << pos);
    }
  }

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
