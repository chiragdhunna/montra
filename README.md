# 📊 Montra

## 🚀 Overview

The **Financial Manager App** is a **Flutter** application that helps users track their **expenses, income, transactions, budgets, and financial goals**. It provides an intuitive and modern UI for managing personal finances effectively.

## Key Features

### Core Functionality

- 💰 **Transaction Management**

  - Income & expense tracking
  - Receipt attachments
  - Transaction categories
  - Recurring transactions

- 🏦 **Account Management**

  - Multiple account types
  - Inter-account transfers
  - Balance tracking
  - Bank integration

- 📊 **Analytics & Reports**
  - Visual spending analysis
  - Custom date range reports
  - Category-wise breakdown
  - Export functionality

### Technical Features

- 🔐 Secure local storage with SQLite
- 🌐 REST API integration
- 🎨 Responsive UI with ScreenUtil
- 🔄 State management with BLoC pattern
- ⚡ Code generation with Freezed

## Technical Architecture

### State Management

```dart
// Example BLoC Pattern Implementation
@freezed
class IncomeState with _$IncomeState {
  const factory IncomeState.initial() = _Initial;
  const factory IncomeState.loading() = _Loading;
  const factory IncomeState.success(List<Transaction> transactions) = _Success;
  const factory IncomeState.error(String message) = _Error;
}
```

### Model Layer (Freezed)

```dart
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required double amount,
    required TransactionType type,
    required DateTime createdAt,
    String? description,
    String? attachment,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
```

### Local Database (SQLite)

```dart
// Database Schema
final String createTransactionTable = '''
  CREATE TABLE transactions (
    id TEXT PRIMARY KEY,
    amount REAL NOT NULL,
    type TEXT NOT NULL,
    created_at TEXT NOT NULL,
    description TEXT,
    attachment_path TEXT
  )
''';
```

## Project Setup

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- VS Code or Android Studio
- Git

### Installation Steps

1. **Clone & Setup**

```bash
# Clone repository
git clone https://github.com/yourusername/montra.git

# Navigate to project
cd montra

# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs
```

2. **Configure Environment**

```dart
// filepath: lib/config/env.dart
const API_BASE_URL = 'YOUR_API_URL';
const DB_NAME = 'montra.db';
```

3. **Run Application**

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Development Guide

### Adding New Features

1. **Create Model**

```dart
// filepath: lib/models/feature_model.dart
@freezed
class FeatureModel with _$FeatureModel {
  const factory FeatureModel({
    required String id,
    required String name,
  }) = _FeatureModel;
}
```

2. **Implement BLoC**

```dart
// filepath: lib/blocs/feature_bloc.dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc() : super(const FeatureState.initial()) {
    on<FeatureRequested>(_onFeatureRequested);
  }
}
```

## 📸 Screenshots

| Home Screen                             | Expense Tracking                               | Financial Report                                | Budgeting                               |
| --------------------------------------- | ---------------------------------------------- | ----------------------------------------------- | --------------------------------------- |
| ![Home Screen](./readme_data/image.png) | ![Expense Tracking](./readme_data/image-3.png) | ![Financial Report ](./readme_data/image-1.png) | ![Budgeting](./readme_data/image-2.png) |

## 🛠 Tech Stack

- **Flutter** (Dart)
- **State Management**: Bloc
- **Local Database**: SQLite
- **Networking**: HTTP, REST APIs
- **Charts & Graphs**: fl_chart
- **UI Components**: Flutter ScreenUtil, Google Fonts

## API Integration

### REST API Endpoints

- `POST /api/v1/transactions` - Create transaction
- `GET /api/v1/transactions` - Fetch transactions
- `PUT /api/v1/transactions/:id` - Update transaction
- `DELETE /api/v1/transactions/:id` - Delete transaction

### Example API Call

```dart
// filepath: lib/services/api_service.dart
class ApiService {
  Future<List<Transaction>> getTransactions() async {
    final response = await dio.get('/api/v1/transactions');
    return (response.data as List)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }
}
```

## Database Schema

### Tables

- transactions
- accounts
- categories
- budget_plans
- attachments

## 🔧 Installation

```sh
# Clone the repository
git clone https://github.com/chiragdhunna/montra

# Navigate to the project directory
cd montra

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Fastlane Integration

Fastlane is integrated into the project to streamline app distribution and automate deployment tasks. It supports the following:

- 📦 **App Distribution**: Automate builds and distribute the app to testers or app stores.
- 🔑 **Code Signing**: Manage certificates and provisioning profiles.
- 📋 **Changelog Management**: Automatically generate changelogs for releases.
- 🚀 **CI/CD Integration**: Seamlessly integrate with CI/CD pipelines.

#### Fastlane Commands

1. **Setup Fastlane**:

   ```bash
   cd android
   fastlane init
   ```

2. **Build and Distribute**:

   ```bash
   # Build APK
   fastlane build

   # Distribute to Testers
   fastlane distribute
   ```

3. **Release to Play Store**:
   ```bash
   fastlane release
   ```

## 📂 Project Structure

```
📦 montra
├── 📂 lib
│   ├── 📂 constants                    # Constants and global variables
│   ├── 📂 screens
│   │   ├── 📂 notification             # Notification settings screen
│   │   ├── 📂 on_boarding              # Onboarding flow
│   │   ├── 📂 splash                   # Splash screen
│   │   ├── 📂 user_screens
│   │   │   ├── 📂 budget_screens       # Budget-related screens
│   │   │   ├── 📂 financial_reports    # Expense & income reports
│   │   │   ├── 📂 income_or_expense    # Income & expense tracking
│   │   │   ├── 📂 profile_section
│   │   │   │   ├── 📂 account_screens  # Account management
│   │   │   │   ├── 📂 export_screens   # Export data & backup
│   │   │   │   ├── 📂 settings_screens # App settings (theme, currency, security)
│   ├── 📂 widgets                      # Reusable UI components
│   │   ├── transaction_card.dart        # Transaction list card
│   │   ├── budget_card.dart             # Budget list card
│   ├── 📂 models                       # Data models
│   ├── 📂 services                     # API and database services
│   ├── 📂 utils                        # Helper utilities
│   ├── main.dart                       # Entry point of the application
└── pubspec.yaml                        # Flutter dependencies & configurations

```

## 🚀 How to Use

1. **Add Transactions**: Log your daily expenses and income.
2. **Analyze Reports**: Use charts and graphs to monitor spending trends.
3. **Set Budgets**: Control your finances by setting up budgets.
4. **Customize Settings**: Change currency, theme, and security preferences.

## 🙌 Contribution

Feel free to contribute by **creating pull requests** or **reporting issues**.

---

Made with ❤️ by [Chirag Dhunna](https://github.com/chiragdhunna) 🚀
