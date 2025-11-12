# Setting Up the Example App

This guide helps you set up and run the example application securely.

## Quick Start

1. **Navigate to example directory:**
   ```bash
   cd example
   ```

2. **Create your environment file:**
   ```bash
   cp .env.example .env
   ```

3. **Edit the .env file and add your Deriv API app_id:**
   ```bash
   # Open with your preferred editor
   nano .env
   # or
   code .env
   ```

   Replace `YOUR_APP_ID` with your actual app_id:
   ```
   DERIV_WEBSOCKET_URL=wss://ws.derivws.com/websockets/v3?app_id=YOUR_ACTUAL_APP_ID
   ```

4. **Get dependencies:**
   ```bash
   flutter pub get
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

## Getting Your Deriv API Credentials

1. Visit [https://api.deriv.com/](https://api.deriv.com/)
2. Register or log in to your account
3. Create a new app
4. Copy your `app_id`
5. Paste it in your `.env` file

## Security Notes

- ✅ The `.env` file is automatically ignored by Git (see `.gitignore`)
- ✅ Never commit your actual credentials to version control
- ✅ Only `.env.example` (with placeholder values) is tracked by Git
- ✅ Always use environment variables for sensitive data

## Troubleshooting

### Error: "DERIV_WEBSOCKET_URL not found"
- Make sure you created the `.env` file from `.env.example`
- Check that the file is in the `example/` directory
- Verify the variable name is exactly `DERIV_WEBSOCKET_URL`

### Error: Connection failed
- Verify your `app_id` is correct
- Check your internet connection
- Ensure the Deriv API is accessible in your region

## What's Next?

After running the example, explore:
- [Package Documentation](README.md)
- [Quick Start Guide](QUICK_START.md)
- [API Documentation](https://api.deriv.com/)
