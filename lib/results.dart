import 'package:decimal/decimal.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'siascan.dart';

const int _sectorSize = 4194304; // 4 MiB

class _ResultsViewState extends State<ResultsView> {
  late final Future<TroubleshootResponse> _checkFuture;

  Future<TroubleshootResponse> _performCheck(
    String network,
    String publicKey,
  ) async {
    final api = getApi(network);
    final host = await api.host(publicKey: publicKey);
    return api.troubleshoot(
      publicKey: host.publicKey,
      rhp4NetAddresses: host.v2NetAddresses,
    );
  }

  @override
  void initState() {
    super.initState();
    _checkFuture = _performCheck(widget.network, widget.publicKey);
  }

  _ResultsViewState() : super();

  Widget _buildWarningList(Set<String> warnings) {
    if (warnings.isEmpty) {
      return const Text('No warnings found'); // should never happen
    }

    return Card(
      elevation: 3.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.warning, color: Colors.amber),
            title: Text('Warnings (${warnings.length})'),
            subtitle: Text('May indicate a potential issue with the host.'),
          ),
          Divider(indent: 0, endIndent: 0),
          Padding(
            padding: EdgeInsetsGeometry.all(20.0),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: warnings.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: 20, child: Divider(indent: 0, endIndent: 0)),
              itemBuilder: (context, index) {
                return SelectableText(warnings.elementAt(index));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorList(BuildContext context, Set<String> errors) {
    if (errors.isEmpty) {
      return const Text('No errors found'); // should never happen
    }

    return Card(
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text('Errors (${errors.length})'),
            subtitle: Text(
              'These issues prevent the host from functioning correctly.',
            ),
          ),
          Divider(indent: 0, endIndent: 0),
          Padding(
            padding: EdgeInsetsGeometry.all(20.0),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: errors.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: 20, child: Divider(indent: 0, endIndent: 0)),
              itemBuilder: (context, index) {
                return SelectableText(errors.elementAt(index));
              },
            ),
          ),
        ],
      ),
    );
  }

  String _protoTitle(String proto) {
    switch (proto.toLowerCase()) {
      case "siamux":
        return "SiaMux";
      case "quic":
        return "QUIC";
      default:
        return proto.toUpperCase();
    }
  }

  List<Widget> _buildTestList(BuildContext context, List<RHP4Result> results) {
    return results
        .map(
          (rhp4) => Card.filled(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(
                    rhp4.connected ? Icons.check_circle : Icons.error,
                    color: rhp4.connected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    _protoTitle(rhp4.netAddress.protocol),
                    maxLines: 1,
                  ),
                  subtitle: SelectableText(rhp4.netAddress.address),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildSettingsInfo(RHP4Settings settings) {
    final children = <Widget>[
      SettingsItem(
        icon: Icon(Icons.storage),
        title: 'Storage Price',
        subtitle: '${formatSiacoin(settings.prices.storagePrice * Decimal.fromInt(4320) * Decimal.fromBigInt(BigInt.from(1e12)))} per TB per month',
        tooltip: 'The cost to store one terabyte of data for one month.',
      ),
      SettingsItem(
        icon: Icon(Icons.lock),
        title: 'Collateral',
        subtitle: '${formatSiacoin(settings.prices.collateral * Decimal.fromInt(4320) * Decimal.fromBigInt(BigInt.from(1e12)))} per TB per month',
        tooltip: 'The amount of Siacoin the host will risk to store one terabyte of data for one month.',
      ),
      SettingsItem(
        icon: Icon(Icons.download),
        title: 'Ingress Price',
        subtitle: '${formatSiacoin(settings.prices.ingressPrice * Decimal.fromBigInt(BigInt.from(1e12)))} per TB',
        tooltip: 'The cost to upload one terabyte of data to the host.',
      ),
      SettingsItem(
        icon: Icon(Icons.upload),
        title: 'Egress Price',
        subtitle: '${formatSiacoin(settings.prices.egressPrice * Decimal.fromBigInt(BigInt.from(1e12)))} per TB',
        tooltip: 'The cost to download one terabyte of data from the host.',
      ),
      SettingsItem(
        icon: Icon(Icons.trending_up),
        title: 'Max Collateral',
        subtitle: formatSiacoin(settings.maxCollateral),
        tooltip: "The maximum amount of collateral the host is willing to lock into a single contract.",
      ),
      SettingsItem(
        icon: Icon(Icons.timer),
        title: 'Max Contract Duration',
        subtitle: '${formatBlockTime(settings.maxContractDuration)} (${formatNumeric(settings.maxContractDuration)} blocks)',
        tooltip: 'The maximum duration of a contract with the host.',
      ),
    ];
    return Card.filled(
      elevation: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 600) {
            return Column(children: children);
          }

          return Column(
            children: children.slices(2).map((chunk) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: chunk.map((tile) => Expanded(child: tile)).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildStorageInfo(RHP4Settings settings) {
    final storageUsedBytes =
        (settings.totalStorage - settings.remainingStorage) * _sectorSize;
    final totalStorageBytes = settings.totalStorage * _sectorSize;
    final storageUsedPercentage = storageUsedBytes / totalStorageBytes;

    return Card.filled(
      elevation: 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 4.0,
        children: [
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('Storage Usage'),
            trailing: Text(
              '${formatFileSize(storageUsedBytes)} / ${formatFileSize(totalStorageBytes)}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: LinearProgressIndicator(
              minHeight: 8.0,
              value: storageUsedPercentage,
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfo(String publicKey, String version, RHP4Result rhp4) {
    return Card.filled(
      elevation: 1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.key),
            title: Text('Public Key'),
            subtitle: SelectableText(publicKey),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: SelectableText(version),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalError(BuildContext context, String title, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.0),
          child: Card.filled(
            child: ListTile(
              leading: Icon(
                Icons.error,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(title),
              subtitle: SelectableText(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    return FutureBuilder<TroubleshootResponse>(
      future: _checkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildCriticalError(
            context,
            "Failed to test host",
            snapshot.error.toString(),
          );
        } else if (!snapshot.hasData) {
          return _buildCriticalError(
            context,
            "Unknown error",
            "Something unexpected happened... Please reload...",
          );
        }

        final result = snapshot.data!;
        final errorsList = result.rhp4.expand((rhp4) => rhp4.errors).toSet();
        final warningsList = result.rhp4
            .expand((rhp4) => rhp4.warnings)
            .toSet();

        final List<Widget> display = [];
        if (errorsList.isNotEmpty) {
          display.add(_buildErrorList(context, errorsList));
        }
        if (warningsList.isNotEmpty) {
          display.add(_buildWarningList(warningsList));
        }
        display.addAll(_buildTestList(context, result.rhp4));

        final rhp4 = result.rhp4.firstWhereOrNull((rhp4) => rhp4.connected);
        if (rhp4 == null) {
          display.add(
            Card.filled(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                child: Text(
                  'All tests failed. Please check your network connection or the host status.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          );
        } else {
          display.add(
            _buildGeneralInfo(result.publicKey, result.version, rhp4),
          );
          if (rhp4.settings != null) {
            display.add(_buildStorageInfo(rhp4.settings!));
            display.add(_buildSettingsInfo(rhp4.settings!));
          }
        }

        if (display.isEmpty) {
          return _buildCriticalError(
            context,
            "Failed to test host",
            "Something unexpected happened... Please reload...",
          );
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: display,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results')),
      body: _buildResults(context),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final Icon icon;
  final String title;
  final String subtitle;
  final String? tooltip;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (tooltip == null || tooltip!.isEmpty) {
      return ListTile(
        leading: icon,
        title: Text(title),
        subtitle: SelectableText(subtitle),
      );
    }
    return Tooltip(
      constraints: const BoxConstraints(maxWidth: 300.0),
      message: tooltip,
      child: ListTile(
        leading: icon,
        title: Text(title),
        subtitle: SelectableText(subtitle),
      ),
    );
  }
}

class ResultsView extends StatefulWidget {
  final String network;
  final String publicKey;

  const ResultsView(this.network, this.publicKey, {super.key});

  @override
  State<ResultsView> createState() => _ResultsViewState();
}
