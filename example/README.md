# Deriv Explore Markets Example

This example demonstrates how to use the `deriv_explore_markets` package in your Flutter application.

## Setup

### 1. Configure Environment Variables

The example app uses environment variables to keep API credentials secure.

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` and add your Deriv API credentials:**
   ```bash
   # Open .env in your editor
   nano .env
   # or
   code .env
   ```

3. **Replace `YOUR_APP_ID` with your actual app_id:**
   ```
   DERIV_WEBSOCKET_URL=wss://ws.derivws.com/websockets/v3?app_id=YOUR_ACTUAL_APP_ID
   ```

**Getting your API credentials:**
- Visit https://api.deriv.com/
- Register or log in to your account
- Create a new app and get your `app_id`

**⚠️ Security Note:** The `.env` file is in `.gitignore` and will not be committed to version control. Never share your API credentials publicly.

## Running the Example

1. Navigate to the example directory:
```bash
cd example
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Examples Included

### Initialization

The app initializes the package once in `main()` using credentials from `.env`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  final websocketUrl = dotenv.env['DERIV_WEBSOCKET_URL']!;
  
  await DerivExploreMarkets.initialize(
    DerivExploreMarketsConfig(
      webSocketUrl: websocketUrl,
      autoConnect: true,
    ),
  );
  
  runApp(MyApp());
}
```

### 1. Basic Usage
Demonstrates the simplest way to use `SmartMarketDisplay` with default settings and theme.

```dart
SmartMarketDisplay()
```

No WebSocket URL needed in the widget - it uses the initialized connection!

### 2. Custom Theme
Shows how to customize the appearance using a custom `MarketDisplayTheme`.

```dart
final customTheme = MarketDisplayTheme(
  primaryColor: Colors.purple,
  // ... other theme properties
);

SmartMarketDisplay(
  theme: customTheme,
  initialCategory: 2, // Start with Crypto
)
```

### 3. Event Handling
Demonstrates how to handle user interactions with symbol taps.

```dart
SmartMarketDisplay(
  onSymbolTap: (symbol, tickData) {
    print('User tapped: $symbol');
    // Navigate to detail page, show info, etc.
  },
)
```

## Features Demonstrated

- ✅ Real-time market data display
- ✅ Category tabs (Forex, Stock indices, Crypto, Commodities)
- ✅ Subcategory filtering (for Forex: All, Major, Minor, Exotic)
- ✅ Custom theming
- ✅ Event handling
- ✅ Material Design 3 integration
- ✅ Light/Dark mode support
- ✅ Secure credential management with .env

## Learn More

- [Package Documentation](../README.md)
- [Deriv API Documentation](https://api.deriv.com/)

