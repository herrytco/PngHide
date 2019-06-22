import 'illegal_state_exception.dart';

/// A Codec which can en- and decode messages.
class LZW {
  /// represents how big the total codebook is, including alphabet and blank character
  final int codeSize;

  /// the input characters come from this alphabet. An exception is thrown if an invaid character is found during encoding.
  final List<dynamic> alphabet;

  /// blank byte.
  int _blank;

  /// blank byte. Is written if the codebook is full and marks the reset moment.
  int get blank => _blank;

  /// Current praefix.
  String _praefix = "";

  /// Current praefix. Contains the longest pattern found in the codebook during encoding.
  String get praefix => _praefix;

  /// Current treated symbol in the input.
  String _symbol = "";

  /// Current encoding result. Contains values between 0 (included) and [codeSize] (excluded).
  List<int> _result = [];

  /// The final encoding result. Contains values between 0 (included) and [codeSize] (excluded).
  List<int> _output;

  /// Current decoding result.
  String _outString = "";

  /// Contains the current decoding result. It only contains characters defined in [alphabet].
  String get temporaryDecodeResult => _outString;

  /// Points to the next codeword. Between 0 (included) and [codeSize] excluded.
  int _nextCodeWord;

  /// Maps a String to its codeword.
  Map<String, dynamic> _codebook;

  /// Maps a codeword back to its String.
  Map<String, String> _symbolbook;

  /// Should debug-messages during encoding be printed into console?
  final bool debugEncoding;

  /// Should debug-messages during decoding be printed into console?
  final bool debugDecoding;

  /// Is the algorithm in Encoding-state?
  bool _isEncoding = false;

  /// Is the algorithm in Dencoding-state?
  bool _isDecoding = false;

  /// Instantiates a new LZW object.
  ///
  /// [alphabet] is a list of symbols the input string can contain. No duplicates are allowed in this value.
  /// [codeSize] is the number of codewords allowed. cannot be smaller than [alphabet.length + 2]
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

  /// Returns the decoded String and resets the algorithm.
  String finalizeDecoding() {
    String out = _outString;
    reset();
    _outString = "";

    return out;
  }

  /// Treats the remaining [_praefix] if existing and returns the encoded numbers and resets the algorithm.
  List<int> finalizeEncoding() {
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

  /// get the codeWord for a String. The value will be < [alphabet.length] if the String is found in the
  /// alphabet, > [alphabet.length] otherwise. If the given String does not exist in the codebook, null
  /// will be returned.
  int getCodeWord(String pattern) {
    if (alphabet.contains(pattern)) return alphabet.indexOf(pattern);

    if (_codebook.containsKey(pattern)) return _codebook[pattern];

    return null;
  }

  /// is there no more space in the codebook?
  bool _isCodebookFull() {
    return !(_codebook.keys.length < codeSize - (alphabet.length + 1));
  }

  /// is the given String either in the codebook or in the alphabet?
  bool _isPatternContainedInCodebook(String pattern) {
    return alphabet.contains(pattern) || _codebook.containsKey(pattern);
  }

  /// resets the algorithm. Clears the output String, empties the codebook and clears
  /// [_praefix] and [_symbol]
  void reset() {
    _reset();
    _outString = "";
  }

  /// empties the codebook and clears [_praefix] and [_symbol]
  void _reset() {
    _codebook = {};
    _symbolbook = {};
    _nextCodeWord = blank + 1;
  }

  /// adds a new codeword to the encoder. Fills both [_codebook] and [_symbolbook] as they
  /// form a bimap together.
  void _addCodeWord(String key, dynamic value) {
    _codebook[key] = value;
    _symbolbook[value.toString()] = key;
  }

  /// get the String to a codeword. Used for decoding.
  String getInverseCodeWord(dynamic value) {
    if (_symbolbook.containsKey(value.toString())) {
      return _symbolbook[value.toString()];
    }

    return null;
  }

  /// LZW instance used for decoding as an encoding step will be performed parallel.
  LZW coder;

  /// feeds a list of numbers into the decoder. This can be done as many times as needed. To finalize, 
  /// the method [finalizeDecoding()] has to be called.
  LZW decode(List<int> lzw) {
    if (_isEncoding) throw IllegalStateException("still encoding.");
    _isDecoding = true;

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


  /// feeds a String into the encoder. This can be done as many times as needed. To finalize, 
  /// the method [finalizeEncoding()] has to be called.
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
}
