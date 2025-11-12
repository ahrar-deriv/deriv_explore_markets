/// A professional Flutter package for displaying real-time market data
/// from Deriv API.
///
/// Provides a comprehensive widget with built-in category tabs,
/// real-time tick updates via WebSocket, and fully customizable theming.
///
/// ## Features
///
/// - Real-time market data from Deriv WebSocket API
/// - Built-in categorized tabs (Forex, Stock indices, Crypto, Commodities)
/// - Customizable theme system (no framework dependencies)
/// - Automatic subscription management
/// - Production-ready with comprehensive error handling
///
/// ## Quick Start
///
/// ```dart
/// import 'package:deriv_explore_markets/deriv_explore_markets.dart';
///
/// SmartMarketDisplay(
///   webSocketUrl: 'wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID',
///   onSymbolTap: (symbol, tickData) {
///     print('Tapped: $symbol');
///   },
/// )
/// ```
///
/// ## Configuration
///
/// You must provide a complete WebSocket URL including your Deriv API app_id.
/// Get your app_id from https://api.deriv.com/
library;

export 'src/core/deriv_explore_markets.dart';
export 'src/core/deriv_explore_markets_config.dart';
export 'src/models/active_symbol.dart';
export 'src/models/tick_data.dart';
export 'src/models/websocket_response.dart';
export 'src/models/websocket_status.dart';
export 'src/services/websocket_service.dart';
export 'src/theme/default_theme.dart';
export 'src/theme/market_display_theme.dart';
export 'src/widgets/category_chip.dart';
export 'src/widgets/market_glance_widget.dart';
export 'src/widgets/market_item_tile.dart';
export 'src/widgets/smart_market_display.dart';
