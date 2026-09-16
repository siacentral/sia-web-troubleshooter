import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'siascan.dart';

const _moduleUrl = 'wasm/troubleshooter_wasm.js';
const _timeout = Duration(seconds: 10);

extension type _WasmModule(JSObject _) implements JSObject {
  @JS('default')
  external JSPromise<JSAny?> init();

  external JSPromise<JSString> scanHost(
    String address,
    String hostKey,
    int timeoutMs,
  );
}

Future<_WasmModule>? _module;

Future<_WasmModule> _importModule() async {
  final url = Uri.parse(web.document.baseURI).resolve(_moduleUrl).toString();
  final module = _WasmModule(await importModule(url.toJS).toDart);
  await module.init().toDart;
  return module;
}

Future<_WasmModule> _loadModule() async {
  try {
    return await (_module ??= _importModule());
  } catch (_) {
    _module = null;
    rethrow;
  }
}

/// Opens a WebTransport session to the host's QUIC address from the browser,
/// scans its settings and closes the session. Never throws; failures are
/// reported in the result's errors.
Future<RHP4Result> scanWebTransport(
  V2NetAddress netAddress,
  String publicKey,
) async {
  try {
    final module = await _loadModule();
    final json = await module
        .scanHost(netAddress.address, publicKey, _timeout.inMilliseconds)
        .toDart;
    return RHP4Result.fromJson(jsonDecode(json.toDart) as Map<String, dynamic>);
  } catch (e) {
    return RHP4Result(
      netAddress: V2NetAddress(
        protocol: 'webtransport',
        address: netAddress.address,
      ),
      resolvedAddresses: const [],
      connected: false,
      dialTime: Duration.zero,
      handshake: false,
      handshakeTime: Duration.zero,
      scanned: false,
      scanTime: Duration.zero,
      settings: null,
      errors: ['WebTransport test could not run: $e'],
      warnings: const [],
    );
  }
}
