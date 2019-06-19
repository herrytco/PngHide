import 'package:test/test.dart';
import 'dart:math';
import 'package:png_hide/lzw.dart';

void main() {
  test('alphabet_with_duplicates', () {
    List<String> alphabet = ["a", "a", "c", "d"];

    expect(() => LZW(alphabet: alphabet, codeSize: 256), throwsException);
  });

  test('lzw_simple', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    expect(lzw.blank, 4);

    List<int> result = lzw.addInput("aabcdda").finalize();

    expect(result, [0, 0, 1, 2, 3, 3, 0]);
  });

  test('lzw_simple2', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    List<int> result = lzw.addInput("aabcddaa").finalize();

    expect(result, [0, 0, 1, 2, 3, 3, 5]);
  });

  test('lzw_simple34', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    List<int> result = lzw.addInput("aabcddaa").addInput("cdcba").finalize();

    expect(result, [0, 0, 1, 2, 3, 3, 5]);
  });

  test('lzw_simple_multiple', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);

    List<int> result = lzw.addInput("aabcddaa").finalize();
    List<int> result2 = lzw.addInput("aabcddaa").finalize();

    expect(result, [0, 0, 1, 2, 3, 3, 5]);
    expect(result2, [0, 0, 1, 2, 3, 3, 5]);
  });

  test('lzw_simple_decode', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);
    LZW lzw2 = LZW(alphabet: alphabet, codeSize: 256);

    String input = "aabcdda";
    List<int> result = lzw.addInput(input).finalize();
    String decoded = lzw2.decode(result);

    expect(input, decoded);
  });

  test('lzw_simple_decode2', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);
    LZW lzw2 = LZW(alphabet: alphabet, codeSize: 256);

    String input = "aabcddaa";
    List<int> result = lzw.addInput(input).finalize();
    String decoded = lzw2.decode(result);

    expect(input, decoded);
  });

  test('test_complex', () {
    List<String> alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 256);
    LZW lzw2 = LZW(alphabet: alphabet, codeSize: 256);

    int runs = 100;
    int length = 200;

    Random rng = new Random();

    for (int i = 0; i < runs; i++) {
      String input = "";

      for (int j = 0; j < length; j++) {
        input += alphabet[rng.nextInt(alphabet.length)];
      }

      List<int> result = lzw.addInput(input).finalize();
      expect(input, lzw2.decode(result));
    }
  });

  test('test_reset', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(alphabet: alphabet, codeSize: 8, debugEncoding: true);

    String input = "ababcbabaaaaad";
    List<int> result = lzw.addInput(input).finalize();

    print(result);

    expect(result, [0, 1, 5, 4, 2, 1, 0, 4, 1, 0, 6, 4, 0, 0, 3]);
  });

  test('test_reset2', () {
    List<String> alphabet = ["a", "b", "c", "d"];

    LZW lzw = LZW(
      alphabet: alphabet,
      codeSize: 8,
      debugDecoding: false,
    );

    String input = "ababcbabaaaaad";
    List<int> result = lzw.addInput(input).finalize();

    expect(input, lzw.decode(result));
  });
}
