import 'dart:io';
import 'package:png_hide/png_encoder.dart';

void encodeSample() {
  File input = File("assets/input.png");

  // output file ... does NOT have to exist yet
  File output = File("assets/output.png");

  PngEncoder pngEncoder = PngEncoder(input, output);

  String text = "When the war of the beasts brings about the world's end, The goddess descends from the sky Wings of light and dark spread afar She guides us to bliss, her gift everlasting.";

  //encode the String into the source image
  pngEncoder.encode(text);
}

void decodeSample() {
  File input = File("assets/input.png");

  // output file ... does NOT have to exist yet
  File output = File("assets/output.png");

  PngEncoder pngEncoder = PngEncoder(input, output);

  //get the text back from the output image
  String text = pngEncoder.decode();

  //outputs: "When the war of the beasts brings about the world's end, The goddess descends from the sky Wings of light and dark spread afar She guides us to bliss, her gift everlasting."
  print(text);
}

void main() {
  encodeSample();
  decodeSample();
}