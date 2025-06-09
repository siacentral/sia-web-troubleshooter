import 'package:test/test.dart';
import 'package:troubleshooter/utils.dart';

void main() {
  group('formatFileSize', () {
    test('zero bytes', () {
      expect(formatFileSize(0), '0 B');
    });

    test('less than 1KiB', () {
      expect(formatFileSize(500), '500 B');
    });

    test('kilobytes', () {
      expect(formatFileSize(1500), '1.50 KB');
    });

    test('megabytes', () {
      expect(formatFileSize(1500000), '1.50 MB');
    });

    test('gigabytes', () {
      expect(formatFileSize(1500000000), '1.50 GB');
    });

    test('terabytes', () {
      expect(formatFileSize(1500000000000), '1.50 TB');
    });
  });
}