import 'package:test/test.dart';
import 'package:png_hide/bit_data.dart';

void main() {
  
  test('test_set_1', () {
    BitData bit = BitData(0);

    bit.setBit(0, true);
    bit.setBit(1, true);
    bit.setBit(2, true);
    bit.setBit(3, true);
    bit.setBit(4, true);

    expect(31, bit.result);
  });
  test('test_get_1', () {
    BitData bit = BitData(63);

    expect(1, bit.getBit(0));
    expect(1, bit.getBit(1));
    expect(1, bit.getBit(2));
    expect(1, bit.getBit(3));
    expect(1, bit.getBit(4));
    expect(1, bit.getBit(5));
  });

}
