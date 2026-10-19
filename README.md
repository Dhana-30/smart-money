# 📱 SmartMoney Flutter App

A complete, production-ready cross-platform Mobile Application built with **Flutter (Material 3)** for personal money management, zero-paste payment SMS auto-detection, income & locked savings partitioning, daily streak gamification, alarms, editable transactions, end-of-day summaries, and month-end CSV dispatch.

---

## 🌟 Key Features

### 1. 💬 Automatic Zero-Paste Payment SMS Tracker
- **No manual copying or pasting required** in real-world mobile usage!
- Uses Android's `Telephony` broadcast receiver to listen for real-time bank SMS messages (e.g. **ICICI, SBI, HDFC, Axis, GPay, PhonePe, Paytm**).
- Handles complex UPI messages containing both words *debited* and *credited* (e.g., `ICICI Bank Acct XX938 debited for Rs 70.00 on 19-Oct-26; MOHD JAVED credited...`).
- Immediately presents a confirmation popup asking:
  - **Debited (Expense)** or **Credited (Income)**
  - Pre-fills detected amount (e.g. ₹70.00), payee/merchant name, and suggested category.

### 2. 💼 Month Starting Income & Locked Savings Pool
- At the start of the month, input your **Starting Income** and choose your **Target Locked Savings** (e.g. ₹50,000 income - ₹15,000 savings).
- The remaining amount becomes your **Spendable Expense Pool** (₹35,000).
- As you record expenses or income, the app continuously updates your:
  - **Remaining Spendable Balance**
  - **Safe Daily Spend** limit based on exact days remaining in the month.

### 3. 📊 Daily End-of-Day Summary
- At your user-specified evening time (e.g. 9:30 PM), the app displays an **End-of-Day Summary Popup**:
  - Total expenses incurred today.
  - Itemized breakdown of all transactions logged during the day.
  - Remaining spendable pool balance.
  - Safe daily budget recommendation for tomorrow.

### 4. ✏️ 100% Editable Transactions
- Every transaction displayed across the **Dashboard**, **Daily Tab**, and **Recent Lists** includes an **Edit Button (✏️)**.
- Tap the edit icon to modify amount, category, date, payment method, or notes with immediate persistence.

### 5. 📲 Month-End CSV Export to Specified Phone Number
- Configure your designated phone number (e.g. `+91 9876543210`).
- Export an itemized CSV spreadsheet of all monthly transactions directly to that phone number via WhatsApp or SMS intent.

### 6. 🔥 Habit Consistency & Alarms
- Daily streak counter with flame animation.
- Milestone badges: *First Step*, *3-Day Fire*, *7-Day Habit*, *Pro Tracker*, *Budget Master*.
- Scheduled daily reminder alarms with audio chime to prevent missing expense entries.

---

## 🏗️ Architecture & Project Structure

```text
u:\smart_money_flutter\
├── .github/workflows/
│   └── build_apk.yml                  # Cloud CI/CD to build APK on GitHub without local Flutter
├── android/
│   └── app/src/main/AndroidManifest.xml # Configured RECEIVE_SMS, READ_SMS, POST_NOTIFICATIONS
├── pubspec.yaml                       # Dependencies: telephony, share_plus, path_provider, etc.
└── lib\
    ├── main.dart                      # App entry point & Material 3 themes
    ├── models\
    │   ├── transaction_model.dart     # Transaction & Category models + JSON serialization
    │   └── habit_badge.dart           # Gamification badges
    ├── services\
    │   ├── storage_service.dart       # SharedPreferences persistence (Income, Savings, EOD, Phone)
    │   ├── alarm_service.dart         # Local notifications & audio chime
    │   ├── sms_parser_service.dart    # Robust regex parser for Indian bank & UPI SMS
    │   └── sms_listener_service.dart  # Telephony background incoming SMS listener
    ├── providers\
    │   └── finance_provider.dart      # Central state manager (Spendable pool, safe daily spend, CRUD)
    ├── widgets\
    │   ├── custom_charts.dart         # Donut & Bar charts
    │   ├── add_transaction_modal.dart # Add & Edit transaction bottom sheet
    │   ├── payment_detection_dialog.dart # SMS confirmation dialog (Debited vs Credited)
    │   └── end_of_day_summary_dialog.dart # Daily evening summary popup
    └── screens\
        ├── home_screen.dart           # Bottom navigation & SMS listener initialization
        ├── dashboard_tab.dart         # Income/savings card, quick actions, presets, recent items
        ├── daily_tab.dart             # Day navigator with editable transaction ledger
        ├── monthly_tab.dart           # Calendar heatmap with red/green day indicators
        ├── analytics_tab.dart         # Spending breakdown & category charts
        └── settings_tab.dart          # Income allocation, EOD time picker, phone number, alarms
```

---

## 📦 How to Build the APK (Without Installing Flutter Locally)

Since your local system does not have Flutter installed, an automated **GitHub Actions CI/CD pipeline** is included in `.github/workflows/build_apk.yml`:

1. Push this folder to a GitHub repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit for SmartMoney app"
   git remote add origin https://github.com/<your-username>/smart_money_flutter.git
   git push -u origin main
   ```
2. Open your GitHub repository in your browser and click the **Actions** tab.
3. The **"Build Android APK"** workflow will automatically run and build `app-release.apk` on GitHub's cloud servers (takes ~3 minutes).
4. Download the compiled `SmartMoney-Release-APK` artifact and install it directly on your Android phone!

---

## 💻 Zero-Setup Local Version (`MoneyManagerApp`)

For immediate use on your computer without building an APK:
- Double click: `u:\MoneyManagerApp\Open_SmartMoney_App.bat`
- It opens the identical Money Management system instantly in your browser with offline PWA support, SMS simulator, and full data persistence.
