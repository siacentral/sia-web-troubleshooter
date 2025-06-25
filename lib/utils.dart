
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart';
import 'package:troubleshooter/siascan.dart';

var locale = findSystemLocale(); // should probably wait for this to complete, but meh

String formatFileSize(int bytes) {
  if (bytes < 1000) return '$bytes B';

  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  const divisor = 1000;
  var i = 0;
  double value = bytes.toDouble();
  while (value >= divisor && i < suffixes.length - 1) {
    value /= divisor;
    i++;
  }
  return '${value.toStringAsFixed(2)} ${suffixes[i]}';
}

String formatSiacoin(Decimal value) {
  if (value == Decimal.zero) return '0 SC';

  NumberFormat format = NumberFormat();
  return "${format.format(value.toDouble())} SC";
}

Api getApi(String network) {
  switch (network.toLowerCase()) {
    case 'mainnet':
      return Api('https://api.siascan.com');
    case 'zen':
      return Api('https://api.siascan.com/zen');
    default:
      throw ArgumentError('Unknown network: $network');
  }
}