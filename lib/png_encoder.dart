import 'dart:convert';
import 'dart:io';
import 'lzw.dart';
import 'bit_data.dart';
import 'package:image/image.dart';

/// Instance of an encoder, which is used to hide texts in PNG images.
class PngEncoder {
  /// is the base-image used for encoding. it will NOT be changed.
  File sourceImage;
  /// The target image, where the encoded result will be stored. Will be overwritten if existing.
  File targetImage;

  /// The alphabet used. Contains the 65 Base64 symbols together with the '}' symbol as stopword.
  static final List<String> alphabet = const [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '+',
    '/',
    '=',
    '}',
  ];

  /// Creates a new instance of the PngEncoder. 
  PngEncoder(this.sourceImage, this.targetImage);

  /// copies [sourceImage] to [targetImage] and encodes the String into the target.
  void encode(String text) {
    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    String b64Input = Base64Codec().encode(Utf8Codec().encode(text)) + "}";
    List<int> encodedInput = lzw.addInput(b64Input).finalizeEncoding();

    if (targetImage.existsSync()) targetImage.delete();
    sourceImage.copySync(targetImage.path);

    Image img = readPng(targetImage.readAsBytesSync());

    int height = img.height;
    int width = img.width;
    int i = 0;

    for (int x = 0; x < width && i < encodedInput.length; x++) {
      for (int y = 0; y < height && i < encodedInput.length; y++) {
        int byte = encodedInput[i++];

        int b1 = (byte & 192) >> 6;
        int b2 = (byte & 48) >> 4;
        int b3 = (byte & 12) >> 2;
        int b4 = (byte & 3);

        BitData pixel = BitData(img.getPixel(x, y));

        pixel.setBit(25, b4 >= 2);
        pixel.setBit(24, b4 == 1 || b4 == 3);

        pixel.setBit(17, b3 >= 2);
        pixel.setBit(16, b3 == 1 || b3 == 3);

        pixel.setBit(9, b2 >= 2);
        pixel.setBit(8, b2 == 1 || b2 == 3);

        pixel.setBit(1, b1 >= 2);
        pixel.setBit(0, b1 == 1 || b1 == 3);

        img.setPixel(x, y, pixel.result);

        print("${pixel.result} ($byte) ($b1 $b2 $b3 $b4)");
      }
    }

    targetImage.writeAsBytesSync(writePng(img));
  }

  /// tries to decode [targetImage] and returns the String hidden in it.
  String decode() {
    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    Image img = readPng(targetImage.readAsBytesSync());
    bool decoded = false;

    List<int> bytes = [];

    for (int x = 0; x < img.width && !decoded; x++) {
      for (int y = 0; y < img.height && !decoded; y++) {
        BitData pixel = BitData(img.getPixel(x, y));

        int b1 = pixel.getBit(0) | (pixel.getBit(1) << 1);
        int b2 = pixel.getBit(8) | (pixel.getBit(9) << 1);
        int b3 = pixel.getBit(16) | (pixel.getBit(17) << 1);
        int b4 = pixel.getBit(24) | (pixel.getBit(25) << 1);

        //int byte = b4 | (b2 << 2) | (b3 << 4) | (b1 << 6);
        int byte = b4 | (b3 << 2) | (b2 << 4) | (b1 << 6);

        //print("${pixel.result} ($byte) ($b1 $b2 $b3 $b4)");

        bytes.add(byte);

        lzw.decode([byte]);

        decoded =
            lzw.temporaryDecodeResult[lzw.temporaryDecodeResult.length - 1] ==
                "}";
      }
    }

    String b64Decoded = lzw.finalizeDecoding();
    b64Decoded = b64Decoded.substring(0, b64Decoded.length - 1);
    
    String message = Utf8Codec().decode(Base64Codec().decode(b64Decoded));

    return message;
  }
}
