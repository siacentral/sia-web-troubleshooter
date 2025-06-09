import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;


Decimal _toSiacoins(String str) {
  final value = Decimal.parse(str);
  return value.shift(-24);
}

class _SearchHostsRequest {
  final List<String> publicKeys;
  final List<String> netAddresses;

  _SearchHostsRequest({
    required this.publicKeys,
    required this.netAddresses,
  });

  Map<String, dynamic> toJson() {
    return {
      'v2': true,
      'publicKeys': publicKeys,
      'netAddresses': netAddresses,
    };
  }
}

class V2NetAddress {
  final String protocol;
  final String address;

  V2NetAddress({
    required this.protocol,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'protocol': protocol,
      'address': address,
    };
  }

  factory V2NetAddress.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      { 'protocol': String protocol, 'address': String address } => V2NetAddress(
          protocol: protocol,
          address: address,
        ),
      _ => throw Exception('Invalid V2NetAddress JSON: $json'),
    };
  }
}

class Location {
  final String countryCode;
  final double latitude;
  final double longitude;

  Location({
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      { 'countryCode': String countryCode, 'latitude': double latitude, 'longitude': double longitude } => Location(
          countryCode: countryCode,
          latitude: latitude,
          longitude: longitude,
        ),
      _ => throw Exception('Invalid Location JSON: $json'),
    };
  }
}

class ExplorerHost {
  final String publicKey;
  final List<V2NetAddress> v2NetAddresses;
  final Location location;

  ExplorerHost({
    required this.publicKey,
    required this.v2NetAddresses,
    required this.location,
  });

  factory ExplorerHost.fromJson(Map<String, dynamic> json) {
    final publicKey = json['publicKey'] as String;
    final List<dynamic> netAddressesJson = json['v2NetAddresses'] as List<dynamic>;
    final v2NetAddresses = netAddressesJson.map((e) => V2NetAddress.fromJson(e as Map<String, dynamic>)).toList();
    final locationJson = Location.fromJson(json['location'] as Map<String, dynamic>);
    return ExplorerHost(
      publicKey: publicKey,
      v2NetAddresses: v2NetAddresses,
      location: locationJson,
    );
  }
}

class _TroubleshootRequest {
  final String publicKey;
  final List<V2NetAddress> rhp4NetAddresses;

  _TroubleshootRequest({
    required this.publicKey,
    required this.rhp4NetAddresses,
  });

  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'rhp4NetAddresses': rhp4NetAddresses.map((e) => e.toJson()).toList(),
    };
  }
}

class RHP4Prices {
  final Decimal contractPrice;
  final Decimal collateral;
  final Decimal storagePrice;
  final Decimal ingressPrice;
  final Decimal egressPrice;
  final Decimal freeSectorPrice;
  final int tipHeight;
  final DateTime validUntil;
  final String signature;

  RHP4Prices({
    required this.contractPrice,
    required this.collateral,
    required this.storagePrice,
    required this.ingressPrice,
    required this.egressPrice,
    required this.freeSectorPrice,
    required this.tipHeight,
    required this.validUntil,
    required this.signature,
  });

  factory RHP4Prices.fromJson(Map<String, dynamic> json) {
    return RHP4Prices(
      contractPrice: _toSiacoins(json['contractPrice'] as String),
      collateral: _toSiacoins(json['collateral'] as String),
      storagePrice: _toSiacoins(json['storagePrice'] as String),
      ingressPrice: _toSiacoins(json['ingressPrice'] as String),
      egressPrice: _toSiacoins(json['egressPrice'] as String),
      freeSectorPrice: _toSiacoins(json['freeSectorPrice'] as String),
      tipHeight: json['tipHeight'] as int,
      validUntil: DateTime.parse(json['validUntil'] as String),
      signature: json['signature'] as String,
    );
  }
}

class RHP4Settings {
  final String release;
  final String walletAddress;
  final bool acceptingContracts;
  final Decimal maxCollateral;
  final int maxContractDuration;
  final int remainingStorage;
  final int totalStorage;
  final RHP4Prices prices;

  RHP4Settings({
    required this.release,
    required this.walletAddress,
    required this.acceptingContracts,
    required this.maxCollateral,
    required this.maxContractDuration,
    required this.remainingStorage,
    required this.totalStorage,
    required this.prices,
  });
  factory RHP4Settings.fromJson(Map<String, dynamic> json) {
    return RHP4Settings(
      release: json['release'] as String,
      walletAddress: json['walletAddress'] as String,
      acceptingContracts: json['acceptingContracts'] as bool,
      maxCollateral: _toSiacoins(json['maxCollateral'] as String),
      maxContractDuration: json['maxContractDuration'] as int,
      remainingStorage: json['remainingStorage'] as int,
      totalStorage: json['totalStorage'] as int,
      prices: RHP4Prices.fromJson(json['prices'] as Map<String, dynamic>),
    );
  }
}

class RHP4Result {
  final V2NetAddress netAddress;
  final List<String> resolvedAddresses;
  final bool connected;
  final Duration dialTime;
  final bool handshake;
  final Duration handshakeTime;
  final bool scanned;
  final Duration scanTime;
  final RHP4Settings? settings;
  final List<String> errors;
  final List<String> warnings;

  RHP4Result({
    required this.netAddress,
    required this.resolvedAddresses,
    required this.connected,
    required this.dialTime,
    required this.handshake,
    required this.handshakeTime,
    required this.scanned,
    required this.scanTime,
    required this.settings,
    required this.errors,
    required this.warnings,
  });

  factory RHP4Result.fromJson(Map<String, dynamic> json) {
    return RHP4Result(
      netAddress: V2NetAddress.fromJson(json['netAddress'] as Map<String, dynamic>),
      resolvedAddresses: List<String>.from(json['resolvedAddresses'] as List<dynamic>),
      connected: json['connected'] as bool,
      dialTime: Duration(microseconds: (json['dialTime'] as int) ~/ 1000), // Go Duration is in nanoseconds
      handshake: json['handshake'] as bool,
      handshakeTime: Duration(microseconds: (json['handshakeTime'] as int) ~/ 1000), // Go Duration is in nanoseconds
      scanned: json['scanned'] as bool,
      scanTime: Duration(microseconds: (json['scanTime'] as int) ~/ 1000), // Go Duration is in nanoseconds
      settings: json['settings'] != null ? RHP4Settings.fromJson(json['settings'] as Map<String, dynamic>) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors'] as List<dynamic>) : [],
      warnings: json['warnings'] != null ? List<String>.from(json['warnings'] as List<dynamic>) : [],
    );
  }
}

class TroubleshootResponse {
  final String publicKey;
  final String version;
  final List<RHP4Result> rhp4;

  TroubleshootResponse({
    required this.publicKey,
    required this.version,
    required this.rhp4,
  });

  factory TroubleshootResponse.fromJson(Map<String, dynamic> json) {
    return TroubleshootResponse(
      publicKey: json['publicKey'] as String,
      version: json['version'] as String,
      rhp4: (json['rhp4'] as List<dynamic>)
          .map((item) => RHP4Result.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Api {
  final String baseUrl;

  Api(this.baseUrl);

  Future<ExplorerHost> host({String? publicKey, String? netAddress}) async {
    final List<String> publicKeys = [if (publicKey != null) publicKey];
    final List<String> netAddresses = [if (netAddress != null) netAddress];

    if (publicKeys.isEmpty && netAddresses.isEmpty) {
      throw ArgumentError('At least one of publicKey or netAddress must be provided.');
    }

    final response = await http.post(Uri.parse('$baseUrl/hosts'),
      headers: {
        'Content-Type': 'application/json',
      },
    body: jsonEncode(_SearchHostsRequest(publicKeys: publicKeys, netAddresses: netAddresses)));
    if (response.statusCode != 200) {
      final String searchTerm = publicKey ?? netAddress!; // one of these must be defined
      throw Exception('Failed to load host $searchTerm: ${response.body}');
    }

    final List<dynamic> responseBody = jsonDecode(response.body);
    if (responseBody.isEmpty) {
      throw Exception('Host not found for public key: $publicKey');
    }

    return ExplorerHost.fromJson(responseBody[0] as Map<String, dynamic>);
  }

  Future<TroubleshootResponse> troubleshoot({
    required String publicKey,
    required List<V2NetAddress> rhp4NetAddresses,
  }) async {
    if (publicKey.isEmpty) {
      throw ArgumentError('publicKey must not be empty.');
    } else if (publicKey.length != 72) {
      throw ArgumentError('publicKey must be 72 characters long.');
    } else if (rhp4NetAddresses.isEmpty) {
      throw ArgumentError('rhp4NetAddresses must not be empty.');
    } else if (rhp4NetAddresses.any((addr) => addr.protocol.isEmpty || addr.address.isEmpty)) {
      throw ArgumentError('Each V2NetAddress must have a non-empty protocol and address.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/troubleshoot'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(_TroubleshootRequest(
        publicKey: publicKey,
        rhp4NetAddresses: rhp4NetAddresses,
      )),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to troubleshoot host with public key: ${response.body}');
    }
    return TroubleshootResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}