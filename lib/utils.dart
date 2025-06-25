
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart';
import 'package:troubleshooter/siascan.dart';

var locale = findSystemLocale(); // should probably wait for this to complete, but meh

String formatBlockTime(int blocks) {
  if (blocks < 1) return '0 minutes';

  final denoms = Map<String, int>.unmodifiable({
    'month': 4320,
    'week': 1008,
    'day': 144,
    'hour': 6,
    'minute': 10,
  });

  final format = NumberFormat();
  for (final denom in denoms.entries) {
    if (blocks < denom.value) continue;

    String suffix = denom.key;
    final value = blocks / denom.value;
    
    if (value > 1) suffix += 's';

    return '${format.format(value)} $suffix';
  }

  return '0 minutes';
}

String formatNumeric(int value) {
  return NumberFormat().format(value);
}

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
  final format = NumberFormat();
  return '${format.format(value)} ${suffixes[i]}';
}

String formatSiacoin(Decimal value) {
  if (value == Decimal.zero) return '0 SC';

  final format = NumberFormat();
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