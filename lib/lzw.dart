import 'illegal_state_exception.dart';

class LZW {
  final int codeSize;
  final List<dynamic> alphabet;

  int _blank;
  int get blank => _blank;

  String _praefix = "";
  String get praefix => _praefix;

  String _symbol = "";
  List<int> _result = [];
  List<int> _output;

  String _outString = "";
  String get decoded => _outString;

  int _nextCodeWord;
  Map<String, dynamic> _codebook;
  Map<String, String> _symbolbook;

  final bool debugEncoding;
  final bool debugDecoding;

  LZW({
    this.alphabet,
    this.codeSize,
    this.debugDecoding = false,
    this.debugEncoding = false,
  }) {
    alphabet.sort((a, b) => a.compareTo(b));
    for (int i = 0; i < alphabet.length - 1; i++) {
      if (alphabet[i] == alphabet[i + 1]) {
        throw new FormatException("no duplicates in alphabet allowed!");
      }
    }

    _blank = alphabet.length;
    _reset();
  }

  int getCodeWord(String pattern) {
    if (alphabet.contains(pattern)) return alphabet.indexOf(pattern);

    if (_codebook.containsKey(pattern)) return _codebook[pattern];

    return null;
  }

  bool _isCodebookFull() {
    return !(_codebook.keys.length < codeSize - (alphabet.length + 1));
  }

  bool _isPatternContainedInCodebook(String pattern) {
    return alphabet.contains(pattern) || _codebook.containsKey(pattern);
  }

  void reset() {
    _reset();
    _outString = "";
  }

  void _reset() {
    _codebook = {};
    _symbolbook = {};
    _nextCodeWord = blank + 1;
  }

  void _addCodeWord(String key, dynamic value) {
    _codebook[key] = value;
    _symbolbook[value.toString()] = key;
  }

  String getInverseCodeWord(dynamic value) {
    if (_symbolbook.containsKey(value.toString())) {
      return _symbolbook[value.toString()];
    }

    return null;
  }

  LZW coder;

  LZW decode(List<int> lzw) {
    if (coder == null) {
      coder = LZW(
        alphabet: alphabet,
        codeSize: codeSize,
        debugEncoding: false,
      );
    }

    for (int i = 0; i < lzw.length; i++) {
      int s = lzw[i];

      if (s < blank) {
        _outString += alphabet[s];
        coder.addInput(alphabet[s]);

        if (debugDecoding) {
          print("$i: found $s -> '${alphabet[s]}' in the alphabet");
        }
      } else if (s > blank) {
        String c = coder.getInverseCodeWord(s);

        if (c != null) {
          _outString += c;
          if (debugDecoding) print("$i: found $s -> '${c}' in the encoder");
          coder.addInput(c);
        } else {
          String sNew = coder.praefix + coder.praefix[0];

          _outString += sNew;
          coder.addInput(sNew);
        }
      }
    }

    return this;
  }

  LZW addInput(String input) {
    for (int i = 0; i < input.length; i++) {
      if (debugEncoding) print("");

      if (!alphabet.contains(input[i])) {
        throw new FormatException(
            "character '${input[i]}' not contained in defined alphabet!");
      }

      _symbol = input[i];

      if (_isPatternContainedInCodebook(_praefix + _symbol)) {
        if (debugEncoding) {
          print("$i: '${_praefix + _symbol}' in codebook");
        }
        _praefix += _symbol;
        continue;
      } else {
        if (debugEncoding) print("$i: '${_praefix + _symbol}' not in codebook");

        int code = getCodeWord(_praefix);
        _result.add(code);
        if (debugEncoding) print("$i: out <- $code");

        _addCodeWord(_praefix + _symbol, _nextCodeWord++);
        _praefix = _symbol;

        if (_isCodebookFull()) {
          if (debugEncoding) print("$i: book is full: $_praefix + $_symbol");
          _result.add(blank);
          _reset();
        }

        if (debugEncoding) print(_codebook);
      }
    }

    return this;
  }

  List<int> finalize() {
    if (_isPatternContainedInCodebook(_praefix)) {
      _result.add(getCodeWord(_praefix));
      _reset();
    } else {
      if (_isCodebookFull()) {
        _result.add(blank);
        _reset();
      }

      _result.add(_nextCodeWord);
      _reset();
    }

    _praefix = "";
    _output = _result;
    _result = [];

    return _output;
  }
}
