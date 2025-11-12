# Quick Start Guide

Get up and running with `deriv_explore_markets` in 3 simple steps.

## Step 1: Initialize (Once in main.dart)

```dart
import 'package:deriv_explore_markets/deriv_explore_markets.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the package
  await DerivExploreMarkets.initialize(
    DerivExploreMarketsConfig(
      webSocketUrl: 'wss://ws.derivws.com/websockets/v3?app_id=YOURAPPID',
      autoConnect: true,
    ),
  );
  
  runApp(MyApp());
}
```

## Step 2: Use the Widgets (Anywhere)

### Full Market View

```dart
class MarketPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Markets')),
      body: SmartMarketDisplay(),  // Full view with tabs
    );
  }
}
```

### Compact Glance (for Home Pages)

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MarketGlanceWidget(
        maxItems: 5,  // Shows top 5 items
      ),
    );
  }
}
```

## Step 3: Enjoy! 🎉

That's literally all you need! The widgets will:
- ✅ Use the shared WebSocket connection
- ✅ Display real-time market data
- ✅ Handle all subscriptions automatically
- ✅ Show category selection (tabs or chips)
- ✅ Update prices in real-time

## Advanced Usage

### Custom Theme

Set a default theme for all widgets:

```dart
await DerivExploreMarkets.initialize(
  DerivExploreMarketsConfig(
    webSocketUrl: wsUrl,
    defaultTheme: MarketDisplayTheme(
      primaryColor: Colors.purple,
      positiveColor: Colors.green,
      negativeColor: Colors.red,
      // ... other colors
    ),
  ),
);
```

### Event Handling

Handle symbol taps:

```dart
SmartMarketDisplay(
  onSymbolTap: (symbol, tickData) {
    print('Tapped: $symbol at ${tickData?.quote}');
  },
)
```

### Manual Connection Control

```dart
// Disconnect when app goes to background
await DerivExploreMarkets.disconnect();

// Reconnect when app comes back
await DerivExploreMarkets.reconnect();

// Check status
final service = DerivExploreMarkets.websocketService;
print('Connected: ${service.isConnected}');
```

## Widgets Available

- **SmartMarketDisplay** - Full market view with category chips and unlimited items
- **MarketGlanceWidget** - Compact view with chips showing max 5 items
- **MarketItemTile** - Reusable component for custom displays
- **CategoryChip** - Reusable Figma-designed chip component

## Run the Example

```bash
cd example
flutter run
```

The example app shows:
1. Basic usage with default theme
2. Custom purple theme
3. Event handling with symbol taps
4. Market glance widget (compact view)

## Need Help?

- 📖 Full documentation: [README.md](README.md)
- 🔧 API Reference: See README API section
- 🐛 Troubleshooting: See README troubleshooting section
- 💬 FlutterFlow integration: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)

---

**That's it! You're ready to display real-time markets! 📊**

