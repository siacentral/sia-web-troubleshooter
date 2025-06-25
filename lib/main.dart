import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:troubleshooter/utils.dart';
import 'results.dart';

void main() {
  runApp(TroubleshootApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => TroubleshootView()),
    GoRoute(
      path: '/:network/:publicKey',
      builder: (context, state) {
        final network = state.pathParameters['network']!;
        final publicKey = state.pathParameters['publicKey']!;
        return ResultsView(network, publicKey);
      },
    ),
  ],
);

class TroubleshootApp extends StatelessWidget {
  const TroubleshootApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sia Host Troubleshooter',
      restorationScopeId: 'troubleshoot',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 29, 38, 9),
        ),
      ),
      routerConfig: _router,
    );
  }
}

class TroubleshootView extends StatefulWidget {
  const TroubleshootView({super.key});

  @override
  State<TroubleshootView> createState() => _TroubleshootViewState();
}

class _TroubleshootViewState extends State<TroubleshootView> {
  final _formKey = GlobalKey<FormState>();

  String hostSearchTerm = '';
  String selectedNetwork = 'mainnet';
  bool isLoading = false;

  Future<void> _searchHostPublicKey(String netaddress) async {
    try {
      final api = getApi(selectedNetwork);
      final result = await api.host(netAddress: netaddress);

      if (!mounted) return;
      context.go('/$selectedNetwork/${result.publicKey}');
    } catch (e) {
      if (!mounted) return;
      // Handle any errors that might occur during the API call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching host public key: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 24.0,
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Public Key or Net Address is required';
                      } else if (value.startsWith('ed25519:') &&
                          value.length != 72) {
                        return 'Public key must be 72 characters long and start with "ed25519:"';
                      }
                      return null;
                    },
                    onSaved: (newValue) => hostSearchTerm = newValue ?? '',
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      contentPadding: const EdgeInsets.all(16.0),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,  // removes the outline stroke in filled mode
                      ),
                      labelText: 'Enter Public Key or Net Address',
                    ),
                  ),
                  DropdownButtonFormField(
                    onSaved: (newValue) =>
                        selectedNetwork = newValue ?? 'mainnet',
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      contentPadding: const EdgeInsets.all(16.0),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,  // removes the outline stroke in filled mode
                      ),
                      labelText: 'Select Network',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a network';
                      }
                      return null;
                    },
                    value: selectedNetwork,
                    items: const [
                      DropdownMenuItem(
                        value: 'mainnet',
                        child: Text('Mainnet'),
                      ),
                      DropdownMenuItem(value: 'zen', child: Text('Zen')),
                    ],
                    onChanged: (value) {},
                  ),
                  FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (isLoading) return;

                            if (!_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Public Key or Net Address is required',
                                  ),
                                ),
                              );
                              return;
                            }
                            _formKey.currentState?.save();
                            if (!hostSearchTerm.startsWith('ed25519:')) {
                              _searchHostPublicKey(hostSearchTerm);
                              return;
                            }
                            context.go('/$selectedNetwork/$hostSearchTerm');
                          },
                    child: const Text('Check Host Status'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
