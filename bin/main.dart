import 'package:png_hide/png_encoder.dart';
import 'dart:io';

main(List<String> arguments) {
  String text = "hallo ich bin ein text";

  File input = File("assets/input.png");
  File output = File("assets/output.png");

  PngEncoder encoder = PngEncoder(input, output);
  //encoder.encode(text);
  encoder.decode();
}
