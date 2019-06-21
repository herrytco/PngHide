# PngHide

# Overview

A Dart library to hide text in PNG images. The procedure for encoding is the following:

1. The input gets encoded into Base64 format

2. The encoded input gets compressed, using the LZW algorithm

3. The resuting bytes are hidden in the source-image, 1 Byte / Pixel

# Samples

## Encode text into a copy of input.png and save it to output.png

```
String text = "hallo ich bin ein text";

File input = File("assets/input.png");
File output = File("assets/output.png");

PngEncoder encoder = PngEncoder(input, output);
encoder.encode(text);
```
