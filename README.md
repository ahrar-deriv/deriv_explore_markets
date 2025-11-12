# Deriv Explore Markets

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.9.0-blue)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/flutter-%3E%3D3.35.0-blue)](https://flutter.dev/)

A professional Flutter package for displaying real-time market data from the Deriv API. Features a comprehensive market display widget with built-in category tabs, customizable theming, and automatic subscription management.

## ✨ Features

- 📊 **Real-time market data** via WebSocket connection to Deriv API
- 🎯 **Built-in categorized tabs** for Forex, Stock indices, Crypto, and Commodities
- 🔍 **Two widget options**:
  - `SmartMarketDisplay` - Full market view with tabs
  - `MarketGlanceWidget` - Compact view with chips (max 5 items)
- 🎨 **Fully customizable theme system** with Material Design 3 support
- 🔄 **Automatic subscription management** - no manual WebSocket handling needed
- 🎭 **Framework-agnostic** - works with any Flutter app (not FlutterFlow specific)
- ⚡ **Production-ready** with comprehensive error handling and reconnection logic
- 📱 **Cross-platform** - iOS, Android, Web supported
- 🧩 **Reusable components** - Extract and customize individual widgets

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  deriv_explore_markets: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Initialize the Package

Initialize once in your app's `main()` function:

```dart
import 'package:deriv_explore_markets/deriv_explore_markets.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the package with your configuration
  await DerivExploreMarkets.initialize(
    DerivExploreMarketsConfig(
      webSocketUrl: 'wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID',
      autoConnect: true, // Connects immediately
    ),
  );
  
  runApp(MyApp());
}
```

### 2. Use the Widget

After initialization, use `SmartMarketDisplay` anywhere in your app:

```dart
class MyMarketPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Markets')),
      body: SmartMarketDisplay(),
    );
  }
}
```

That's it! The widget uses the shared WebSocket connection automatically.

## ⚙️ Configuration

### Getting Your API Credentials

This package requires a Deriv API app_id. To get your credentials:

1. Visit https://api.deriv.com/
2. Register or log in to your account
3. Create a new app and get your `app_id`
4. Use your app_id in the WebSocket URL:
   ```
   wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID
   ```

**Security Note**: For production apps, store your app_id securely (environment variables, secure storage, etc.). Never commit credentials to source control.

## 📖 Usage Examples

### Initialize with Custom Theme

Set a default theme for all widgets during initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final customTheme = MarketDisplayTheme(
    primaryColor: Colors.purple,
    primaryBackground: Colors.grey[50]!,
    secondaryBackground: Colors.white,
    primaryText: Colors.black87,
    secondaryText: Colors.grey[600]!,
    alternate: Colors.grey[300]!,
    positiveColor: Colors.green[700]!,
    negativeColor: Colors.red[700]!,
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
  );
  
  await DerivExploreMarkets.initialize(
    DerivExploreMarketsConfig(
      webSocketUrl: 'wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID',
      defaultTheme: customTheme,
    ),
  );
  
  runApp(MyApp());
}

// All widgets will use customTheme by default
SmartMarketDisplay()
```

### Override Theme Per Widget

You can still override the theme for individual widgets:

```dart
SmartMarketDisplay(
  theme: differentTheme, // Overrides default theme
)
```

### Event Handling

Handle symbol taps to navigate or show details:

```dart
SmartMarketDisplay(
  onSymbolTap: (symbol, tickData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymbolDetailPage(
          symbol: symbol,
          currentPrice: tickData?.quote,
        ),
      ),
    );
  },
)
```

### Initial Category

Start with a specific market category:

```dart
SmartMarketDisplay(
  initialCategory: 2, // 0=Forex, 1=Indices, 2=Crypto, 3=Commodities
)
```

### Custom Loading/Error States

Provide custom builders for loading and error states:

```dart
SmartMarketDisplay(
  loadingBuilder: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Connecting to markets...'),
      ],
    ),
  ),
  errorBuilder: (context, error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red),
        SizedBox(height: 16),
        Text('Error: $error'),
        ElevatedButton(
          onPressed: () {
            // Retry logic
          },
          child: Text('Retry'),
        ),
      ],
    ),
  ),
)
```

### Hide Category Tabs

Display markets without the category tabs:

```dart
SmartMarketDisplay(
  showCategoryTabs: false,
)
```

### Compact Glance Widget

Use `MarketGlanceWidget` for a compact view perfect for home pages:

```dart
MarketGlanceWidget(
  maxItems: 5,      // Show max 5 items
  height: 400,      // Optional, defaults to 400
  initialCategory: 0,  // Start with Forex
  onSymbolTap: (symbol, tickData) {
    // Handle tap
  },
  onSeeAllTap: () {
    // Navigate to full SmartMarketDisplay
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullMarketPage()),
    );
  },
)
```

**Perfect for:**
- Home page dashboard widgets
- Quick market overview
- Space-constrained layouts
- Preview before full view

### Manual WebSocket Control

Control the WebSocket connection manually:

```dart
// Disconnect when not needed
await DerivExploreMarkets.disconnect();

// Reconnect when needed
await DerivExploreMarkets.reconnect();

// Check connection status
final service = DerivExploreMarkets.websocketService;
print('Connected: ${service.isConnected}');
```

## 🎨 Theme Customization

The package provides three ways to customize appearance:

### 1. Set Default Theme at Initialization

Configure a default theme that all widgets will use:

```dart
await DerivExploreMarkets.initialize(
  DerivExploreMarketsConfig(
    webSocketUrl: wsUrl,
    defaultTheme: myCustomTheme,
  ),
);
```

### 2. Use Material 3 Themes

The default theme automatically adapts to your app's Material theme:

```dart
// Uses Material theme colors
SmartMarketDisplay()

// Or explicitly set light/dark
SmartMarketDisplay(
  theme: DefaultMarketDisplayTheme.light(context),
)
```

### 3. Per-Widget Custom Theme

Override the default theme for specific widgets:

```dart
final customTheme = MarketDisplayTheme(
  primaryColor: Color(0xFF6750A4),
  primaryBackground: Color(0xFFFFFBFE),
  secondaryBackground: Color(0xFFF3EDF7),
  primaryText: Color(0xFF1C1B1F),
  secondaryText: Color(0xFF49454F),
  alternate: Color(0xFFE6E1E5),
  positiveColor: Color(0xFF10B981),
  negativeColor: Color(0xFFEF4444),
  bodyLarge: TextStyle(fontSize: 16),
  bodyMedium: TextStyle(fontSize: 14),
  bodySmall: TextStyle(fontSize: 12),
);
```

## 🛠️ API Reference

### DerivExploreMarkets

Main initialization class. Call `initialize()` once in main().

```dart
await DerivExploreMarkets.initialize(config);
```

#### Methods

- `initialize(config)` - Initialize the package
- `reconnect()` - Manually reconnect WebSocket
- `disconnect()` - Disconnect WebSocket
- `dispose()` - Dispose all resources
- `websocketService` - Access the shared WebSocket service
- `config` - Access current configuration
- `isInitialized` - Check if initialized

### DerivExploreMarketsConfig

Configuration class for package initialization.

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `webSocketUrl` | `String` | Yes | - | Complete WebSocket URL with app_id |
| `defaultTheme` | `MarketDisplayTheme?` | No | null | Default theme for all widgets |
| `autoConnect` | `bool` | No | true | Auto-connect on initialization |
| `maxReconnectAttempts` | `int` | No | 5 | Max reconnection attempts |
| `reconnectDelay` | `Duration` | No | 3s | Delay between reconnects |

### SmartMarketDisplay

Full market display widget with tabs for all symbols.

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Optional width constraint |
| `height` | `double?` | No | Optional height constraint |
| `theme` | `MarketDisplayTheme?` | No | Override default theme |
| `onSymbolTap` | `Function(String, TickData?)?` | No | Callback when symbol is tapped |
| `loadingBuilder` | `Widget Function(BuildContext)?` | No | Custom loading indicator |
| `errorBuilder` | `Widget Function(BuildContext, String)?` | No | Custom error display |
| `initialCategory` | `int` | No | Initial tab (0-3, default: 0) |
| `showCategoryTabs` | `bool` | No | Show/hide category tabs (default: true) |

### MarketGlanceWidget

Compact market display widget with category chips (max 5 items).

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Optional width constraint |
| `height` | `double?` | No | Height constraint (default: 400) |
| `theme` | `MarketDisplayTheme?` | No | Override default theme |
| `maxItems` | `int` | No | Max items to show (default: 5) |
| `initialCategory` | `int` | No | Initial category (0-3, default: 0) |
| `onSymbolTap` | `Function(String, TickData?)?` | No | Callback when symbol is tapped |
| `onSeeAllTap` | `VoidCallback?` | No | Callback for "See All" button |
| `showSeeAllButton` | `bool` | No | Show/hide "See All" button (default: true) |

### MarketItemTile

Reusable tile widget for displaying individual market symbols.

Can be used independently to build custom market displays.

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `symbol` | `String` | Yes | Symbol code |
| `tickData` | `TickData?` | No | Current tick data (null if loading) |
| `activeSymbol` | `ActiveSymbol?` | No | Symbol metadata |
| `previousPrice` | `double?` | No | For percentage calculation |
| `theme` | `MarketDisplayTheme` | Yes | Theme for styling |
| `onTap` | `VoidCallback?` | No | Tap callback |

### WebSocketService

Low-level service for direct WebSocket management (advanced usage).

```dart
final service = WebSocketService();

// Connect
await service.connect('wss://ws.derivws.com/websockets/v3?app_id=YOURAPPID');

// Subscribe to specific symbols
await service.subscribeToTicks(['frxEURUSD', 'BTCUSD']);

// Subscribe by market
await service.subscribeByMarket('forex');

// Listen to tick updates
service.tickStream.listen((tick) {
  print('${tick.symbol}: ${tick.quote}');
});

// Disconnect
await service.disconnect();
```

## 📱 Example App

A complete example app is included in the `example/` directory. To run it:

```bash
cd example
flutter pub get
flutter run
```

The example demonstrates:
- Basic usage with default theme
- Custom theme implementation
- Event handling with symbol taps
- Different market categories

## 🔧 Troubleshooting

### WebSocket Connection Fails

**Problem**: Cannot connect to WebSocket server

**Solutions**:
- Verify your `app_id` is correct
- Check internet connectivity
- Ensure the WebSocket URL format is correct
- Check if Deriv API is accessible in your region

### No Symbols Displayed

**Problem**: Widget shows "No symbols available"

**Solutions**:
- Wait a few seconds for active_symbols to load
- Check WebSocket connection status
- Verify the selected market has available symbols
- Check error stream for API errors

### Theme Not Applied

**Problem**: Custom theme colors not showing

**Solutions**:
- Ensure theme parameter is passed to SmartMarketDisplay
- Verify all required theme properties are defined
- Check if widget is rebuilt after theme changes

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Deriv API Documentation](https://api.deriv.com/)
- [Deriv API Explorer](https://api.deriv.com/api-explorer/)
- [WebSocket API Reference](https://api.deriv.com/api-explorer/#websocket)
- [Report Issues](https://github.com/ahrar-deriv/deriv_explore_markets/issues)

## 📊 Market Categories

The widget supports the following market categories:

- **Forex** (with subcategories: All, Major, Minor, Exotic)
- **Stock Indices** 
- **Cryptocurrencies**
- **Commodities**

Each category displays real-time tick data with:
- Symbol name and description
- Current quote price
- Percentage change (color-coded green/red)
- Symbol-specific icon

## ⚡ Performance

- Efficient WebSocket connection with automatic reconnection
- Optimized rendering with selective rebuilds
- Minimal memory footprint
- Automatic subscription cleanup on dispose

## 🔐 Security

- Never hardcode credentials in your app
- Use environment variables for sensitive data
- Consider implementing authentication for production
- Follow Deriv API security best practices

---

**Made with ❤️ for the Flutter community**
