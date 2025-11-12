import 'package:deriv_explore_markets/deriv_explore_markets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Get WebSocket URL from environment
  final websocketUrl = dotenv.env['DERIV_WEBSOCKET_URL'];

  if (websocketUrl == null || websocketUrl.isEmpty) {
    throw Exception(
      'DERIV_WEBSOCKET_URL not found in .env file.\n'
      'Please create a .env file from .env.example and add your Deriv API credentials.',
    );
  }

  // Initialize the package once at app startup
  await DerivExploreMarkets.initialize(
    DerivExploreMarketsConfig(
      webSocketUrl: websocketUrl,
      autoConnect: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deriv Explore Markets Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _examples = const [
    BasicExample(),
    CustomThemeExample(),
    EventHandlingExample(),
    MarketGlanceExample(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deriv Explore Markets Examples'),
        elevation: 2,
      ),
      body: _examples[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Basic'),
          NavigationDestination(
            icon: Icon(Icons.palette),
            label: 'Custom Theme',
          ),
          NavigationDestination(icon: Icon(Icons.touch_app), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.preview), label: 'Glance'),
        ],
      ),
    );
  }
}

class BasicExample extends StatelessWidget {
  const BasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Usage',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SmartMarketDisplay with default theme and settings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: SmartMarketDisplay()),
      ],
    );
  }
}

class CustomThemeExample extends StatelessWidget {
  const CustomThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    final customTheme = MarketDisplayTheme(
      primaryColor: Colors.purple,
      primaryBackground: Colors.grey[50]!,
      secondaryBackground: Colors.white,
      primaryText: Colors.black87,
      secondaryText: Colors.grey[600]!,
      alternate: Colors.grey[300]!,
      positiveColor: Colors.green[700]!,
      negativeColor: Colors.red[700]!,
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: const TextStyle(fontSize: 14),
      bodySmall: const TextStyle(fontSize: 12),
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Custom Theme',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.purple[900]),
              ),
              const SizedBox(height: 8),
              Text(
                'Custom purple theme with personalized colors and typography.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.purple[700]),
              ),
            ],
          ),
        ),
        Expanded(
          child: SmartMarketDisplay(theme: customTheme, initialCategory: 2),
        ),
      ],
    );
  }
}

class EventHandlingExample extends StatefulWidget {
  const EventHandlingExample({super.key});

  @override
  State<EventHandlingExample> createState() => _EventHandlingExampleState();
}

class _EventHandlingExampleState extends State<EventHandlingExample> {
  String? _lastTappedSymbol;
  double? _lastPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Handling',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap any symbol to see event handling in action.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
              if (_lastTappedSymbol != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Tapped:',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _lastTappedSymbol!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_lastPrice != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Price: ${_lastPrice!.toStringAsFixed(5)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: SmartMarketDisplay(
            onSymbolTap: (symbol, tickData) {
              setState(() {
                _lastTappedSymbol = symbol;
                _lastPrice = tickData?.quote;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped: $symbol'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MarketGlanceExample extends StatelessWidget {
  const MarketGlanceExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market Glance Widget',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Compact view with category chips. Perfect for home pages! Shows max 5 items.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MarketGlanceWidget(
              maxItems: 5,
              onSymbolTap: (symbol, tickData) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped: $symbol'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
