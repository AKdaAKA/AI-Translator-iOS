# AI Translator (iOS)

A simple, minimalist iOS translation application built using UIKit and Swift that translates text into Spanish using the Gemini API.

## How to Setup

1. Open `AI translator.xcodeproj` in Xcode.
2. Create a `Keys.plist` file inside the project directory (it is ignored by Git to protect secrets).
3. Add your Gemini API key inside `Keys.plist`:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>GEMINI_API_KEY</key>
       <string>YOUR_GEMINI_API_KEY</string>
   </dict>
   </plist>
   ```
4. Build and run the app!
