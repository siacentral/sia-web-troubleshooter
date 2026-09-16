import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:troubleshooter/siascan.dart';

// Captured from the wasm module's scanHost output against a live host.
const _scanned = '''
{"netAddress":{"protocol":"webtransport","address":"s84sb535dfppb5bfbie3vdef5pmublhk5tc0bqj195eqjoc0g1gg.sia.host:9984"},"connected":true,"dialTime":587400000,"handshake":true,"handshakeTime":0,"scanned":true,"scanTime":176400000,"settings":{"protocolVersion":[5,0,2],"release":"hostd v2.8.0","walletAddress":"f0bcd3dde010558faf69452ed0f886214773209fa66cd71f8ccf63a3a105f6396369a335cdde","acceptingContracts":true,"maxCollateral":"34123529023577340437000000000","maxContractDuration":34560,"remainingStorage":0,"totalStorage":214577,"prices":{"contractPrice":"200000000000000000000000","collateral":"759515870360","storagePrice":"379757935180","ingressPrice":"13124434239837","egressPrice":"26248868479674","freeSectorPrice":"3814697265625000000","tipHeight":593131,"validUntil":"2026-09-16T20:58:38Z","signature":"ee1a8f1458802a19588a8a6e4a1e5c7749da223e831bfb32251849101efee960fdd547e787f74db51f10237b9c828401bf1e9035e6c1ec22cc1330315ec84303"}},"errors":[],"warnings":[]}
''';

const _failed = '''
{"netAddress":{"protocol":"webtransport","address":"168.119.135.203:9984"},"connected":false,"dialTime":0,"handshake":false,"handshakeTime":0,"scanned":false,"scanTime":0,"settings":null,"errors":["failed to connect to https://168.119.135.203:9984/sia/rhp/v4: Opening handshake failed. The host may be offline, UDP may be blocked, or the browser may not trust the host's TLS certificate"],"warnings":[]}
''';

void main() {
  group('RHP4Result.fromJson parses wasm scanHost output', () {
    test('scanned host', () {
      final result = RHP4Result.fromJson(
        jsonDecode(_scanned) as Map<String, dynamic>,
      );
      expect(result.netAddress.protocol, 'webtransport');
      expect(
        result.netAddress.address,
        's84sb535dfppb5bfbie3vdef5pmublhk5tc0bqj195eqjoc0g1gg.sia.host:9984',
      );
      expect(result.resolvedAddresses, isEmpty);
      expect(result.connected, isTrue);
      expect(result.handshake, isTrue);
      expect(result.scanned, isTrue);
      expect(result.dialTime, const Duration(microseconds: 587400));
      expect(result.scanTime, const Duration(microseconds: 176400));
      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);

      final settings = result.settings!;
      expect(settings.release, 'hostd v2.8.0');
      expect(settings.acceptingContracts, isTrue);
      expect(settings.maxContractDuration, 34560);
      expect(settings.remainingStorage, 0);
      expect(settings.totalStorage, 214577);
      expect(
        settings.maxCollateral,
        Decimal.parse('34123.529023577340437'),
      );
      expect(
        settings.prices.storagePrice,
        Decimal.parse('0.00000000000037975793518'),
      );
      expect(settings.prices.tipHeight, 593131);
      expect(settings.prices.validUntil, DateTime.utc(2026, 9, 16, 20, 58, 38));
    });

    test('failed connection', () {
      final result = RHP4Result.fromJson(
        jsonDecode(_failed) as Map<String, dynamic>,
      );
      expect(result.netAddress.protocol, 'webtransport');
      expect(result.connected, isFalse);
      expect(result.scanned, isFalse);
      expect(result.settings, isNull);
      expect(result.errors, hasLength(1));
      expect(result.errors.single, startsWith('failed to connect to '));
    });
  });
}
