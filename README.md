# WeatherApp

WeatherApp shows you real-time weather for your current location — temperature, conditions, and sunrise/sunset times — all tied to your personal account.

---

## Setup

Before running the app, add your OpenWeatherMap API key:

1. Open `WeatherApp/Config.swift`
2. Replace the placeholder with your key:
   ```swift
   static let openWeatherAPIKey = "your_api_key_here"
   ```
   Get a free key at [openweathermap.org/api](https://openweathermap.org/api)

---

## Getting Started

1. Open the app
2. Create an account with a username and password
3. Log in — the app will ask for your location the first time
4. Your current weather loads automatically

---

## What You'll See

### Dashboard
The main screen shows everything at a glance:
- **Location** — your city, country, and coordinates
- **Weather card** — current temperature, feels-like, and conditions. The background changes based on whether it's day, night, or raining
- **Sunrise & Sunset** — times for your location with a visual arc
- **Recent Views** — your 2 most recent weather checks

### Weather History
Tap **History** on the dashboard to see every weather check tied to your account, with the location, conditions, temperature, and sunrise/sunset times for each entry. History is private — each user only sees their own.

---

## Features

- Real-time weather for your current GPS location
- Background and icon that change for day, night, and rain
- Pull down on the dashboard to refresh
- Per-account history — each user sees only their own weather checks
- Secure login — your password is never stored in plain text
- Log out anytime from the top-right button

---

## Account & Password

When registering, your password must have:
- At least 8 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number
- At least 1 special character (e.g. `!`, `@`, `#`)

A live checklist shows you which requirements you've met as you type.

---

## Permissions

WeatherApp only asks for your location while the app is open. Location is used solely to fetch weather data and is never stored or shared.
