# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-12

### Added
- Initial release of `deriv_explore_markets` package
- **Centralized initialization system** (`DerivExploreMarkets.initialize()`)
- **Shared WebSocket connection** (single connection for entire app)
- **Package-level configuration** (`DerivExploreMarketsConfig`)
- `SmartMarketDisplay` widget for comprehensive market view with tabs
- `MarketGlanceWidget` compact widget with category chips (max 5 items)
- `MarketItemTile` reusable component for custom market displays
- Built-in category tabs for Forex, Stock indices, Crypto, and Commodities
- Forex subcategory tabs (All, Major, Minor, Exotic)
- `WebSocketService` for managing Deriv API WebSocket connections
- `MarketDisplayTheme` for complete visual customization
- `DefaultMarketDisplayTheme` with Material Design 3 support
- Automatic WebSocket reconnection with configurable retry logic
- Real-time tick data models (`TickData`, `ActiveSymbol`)
- Comprehensive error handling and status streaming
- Symbol filtering by market, submarket, and type
- Event callbacks (`onSymbolTap`, `onSeeAllTap`, custom builders)
- Example app with 4 usage demonstrations
- Complete API documentation with dartdoc comments

### Features
- 📊 Real-time market data via WebSocket
- 🏗️ Centralized initialization (Firebase-style)
- 🔗 Shared WebSocket connection (single connection for entire app)
- 🎯 Two display widgets: Full view & Compact glance
- 🎨 Fully customizable theme system
- 🔄 Automatic subscription management
- 📱 Cross-platform support (iOS, Android, Web)
- ⚡ Production-ready error handling
- 🎭 Framework-agnostic design
- 🧩 Reusable components (MarketItemTile)

### Documentation
- Comprehensive README with usage examples
- Example app demonstrating all features
- API reference documentation


[0.1.0]: https://github.com/ahrar-deriv/deriv_explore_markets/releases/tag/v0.1.0

