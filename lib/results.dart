import 'package:decimal/decimal.dart';
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
    final api = Api('https://api.siascan.com');
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

  Widget _buildSettingsInfo(TroubleshootResponse result) {
    final rhp4 = result.rhp4.firstWhere((rhp4) => rhp4.connected);

    return Card.filled(
      elevation: 1.0,
      child: GridView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 5,
        ),
        children: [
          Tooltip(
            message:
                'Storage is the cost of storing one terabyte of data for one month on the host.',
            child: ListTile(
              leading: Icon(Icons.storage),
              title: Text('Storage'),
              subtitle: SelectableText(
                '${formatSiacoin(rhp4.settings.prices.storagePrice * Decimal.fromInt(4320) * Decimal.fromBigInt(BigInt.from(1e12)))} per TB per month',
              ),
            ),
          ),
          Tooltip(
            message:
                'Collateral is the amount of Siacoin the host will risk to store one terabyte of data for one month.',
            child: ListTile(
              leading: Icon(Icons.lock),
              title: Text('Collateral'),
              subtitle: SelectableText(
                '${formatSiacoin(rhp4.settings.prices.collateral * Decimal.fromInt(4320) * Decimal.fromBigInt(BigInt.from(1e12)))} per TB per month',
              ),
            ),
          ),
          Tooltip(
            message: 'Ingress is the data sent from the renter to the host.',
            child: ListTile(
              leading: Icon(Icons.download),
              title: Text('Ingress'),
              subtitle: SelectableText(
                '${formatSiacoin(rhp4.settings.prices.ingressPrice * Decimal.fromBigInt(BigInt.from(1e12)))} per TB',
              ),
            ),
          ),
          Tooltip(
            message: 'Egress is the data sent from the host to the renter.',
            child: ListTile(
              leading: Icon(Icons.upload),
              title: Text('Egress'),
              subtitle: SelectableText(
                '${formatSiacoin(rhp4.settings.prices.egressPrice * Decimal.fromBigInt(BigInt.from(1e12)))} per TB',
              ),
            ),
          ),
          Tooltip(
            message:
                "Max Collateral is the maximum amount of collateral the host is willing to lock into a contract.",
            child: ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Max Collateral'),
              subtitle: SelectableText(
                formatSiacoin(rhp4.settings.maxCollateral),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.timer),
            title: Text('Max Contract Duration'),
            subtitle: SelectableText(
              '${rhp4.settings.maxContractDuration} blocks',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfo(TroubleshootResponse result) {
    final rhp4 = result.rhp4.firstWhere((rhp4) => rhp4.connected);
    final storageUsedBytes =
        (rhp4.settings.totalStorage - rhp4.settings.remainingStorage) *
        _sectorSize;
    final totalStorageBytes = rhp4.settings.totalStorage * _sectorSize;
    final storageUsedPercentage = storageUsedBytes / totalStorageBytes;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card.filled(
          elevation: 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.key),
                title: Text('Public Key'),
                subtitle: SelectableText(result.publicKey),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Version'),
                subtitle: SelectableText(result.version),
              ),
            ],
          ),
        ),
        Card.filled(
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: LinearProgressIndicator(
                  minHeight: 8.0,
                  value: storageUsedPercentage,
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TroubleshootResponse>(
      future: _checkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data found'));
        }

        final result = snapshot.data!;
        final errorsList = result.rhp4.expand((rhp4) => rhp4.errors).toSet();
        final warningsList = result.rhp4
            .expand((rhp4) => rhp4.warnings)
            .toSet();

        return Scaffold(
          appBar: AppBar(title: Text('Results')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800.0),
                child: Column(
                  children: [
                    if (errorsList.isNotEmpty)
                      _buildErrorList(context, errorsList),
                    if (warningsList.isNotEmpty)
                      _buildWarningList(warningsList),
                    _buildGeneralInfo(result),
                    _buildSettingsInfo(result),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
