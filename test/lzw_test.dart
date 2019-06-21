import 'dart:convert';

import 'package:test/test.dart';
import 'dart:math';
import 'package:png_hide/lzw.dart';
import 'package:png_hide/png_encoder.dart';

void main() {
  test('alphabet_with_duplicates', () {
    List<String> alphabet = ["a", "a", "c", "d"];

    expect(() => LZW(alphabet: alphabet, codeSize: 256), throwsException);
  });

  test('lzw_simple', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    expect(lzw.blank, 4);

    List<int> result = lzw.addInput("aabcdda").finalizeEncoding();

    expect(result, [0, 0, 1, 2, 3, 3, 0]);
  });

  test('lzw_simple2', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    List<int> result = lzw.addInput("aabcddaa").finalizeEncoding();

    expect(result, [0, 0, 1, 2, 3, 3, 5]);
  });

  test('lzw_simple3', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    List<int> result = lzw.addInput("aabcddaa").finalizeEncoding();

    expect(result, [0, 0, 1, 2, 3, 3, 5]);
  });

  test('lzw_simple_multiple', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    List<int> result = lzw.addInput("aabcddaa").finalizeEncoding();
    List<int> result2 = lzw.addInput("aabcddaa").finalizeEncoding();

    expect(result, [0, 0, 1, 2, 3, 3, 5]);
    expect(result2, [0, 0, 1, 2, 3, 3, 5]);
  });

  test('lzw_simple_decode', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);
    LZW lzw2 = LZW(alphabet: alphabet, codeSize: 256);

    String input = "aabcdda";
    List<int> result = lzw.addInput(input).finalizeEncoding();
    String decoded = lzw2.decode(result).finalizeDecoding();

    expect(input, decoded);
  });

  test('lzw_simple_decode2', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);
    LZW lzw2 = LZW(alphabet: alphabet, codeSize: 256);

    String input = "aabcddaa";
    List<int> result = lzw.addInput(input).finalizeEncoding();

    expect(input, lzw2.decode(result).finalizeDecoding());
  });

  test('test_complex', () {
    List<String> alphabet = [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l"
    ];

    int runs = 500;
    int length = 30000;

    Random rng = new Random();

    for (int i = 0; i < runs; i++) {
      LZW lzw = LZW(alphabet: alphabet, codeSize: 256);
      LZW lzw2 = LZW(alphabet: alphabet, codeSize: 256);

      String input = "";

      for (int j = 0; j < length; j++) {
        input += alphabet[rng.nextInt(alphabet.length)];
      }

      // print("input: $input");

      List<int> result = lzw.addInput(input).finalizeEncoding();
      expect(input, lzw2.decode(result).finalizeDecoding());
    }
  });

  test('test_reset', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 8, debugEncoding: false);

    String input = "ababcbabaaaaad";
    List<int> result = lzw.addInput(input).finalizeEncoding();

    expect(result, [0, 1, 5, 4, 2, 1, 0, 4, 1, 0, 6, 4, 0, 0, 3]);
  });

  test('test_reset2', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(
      alphabet: alphabet,
      codeSize: 8,
    );

    String input = "ababcbabaaaaad";
    List<int> result = lzw.addInput(input).finalizeEncoding();

    expect(input, lzw.decode(result).finalizeDecoding());
  });

  test('test_split', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(
      alphabet: alphabet,
      codeSize: 8,
    );

    String input = "ababcbabaaaaad";
    List<int> result = lzw.addInput(input).finalizeEncoding();

    List<int> dec1 = result.sublist(0, result.length ~/ 2);
    List<int> dec2 = result.sublist((result.length ~/ 2), result.length);

    expect(result.length, dec1.length + dec2.length);

    expect(input, lzw.decode(dec1).decode(dec2).finalizeDecoding());
  });

  test('test_png_alphabet', () {
    LZW lzw = LZW(
      alphabet: PngEncoder.alphabet,
      codeSize: 256,
    );

    String input = "hallo ich bin ein text";

    String b64Input = Base64Codec().encode(Utf8Codec().encode(input)) + "}";

    List<int> result = lzw.addInput(b64Input).finalizeEncoding();

    for (int i = 0; i < result.length; i++) {
      lzw.decode([result[i]]);
    }
    lzw.reset();

    print(lzw.finalizeDecoding());
  });
}
