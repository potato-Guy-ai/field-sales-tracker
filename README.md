# Field Sales Tracker

Offline-first door-to-door sales tracking app for field operations.

## 🎯 Core Philosophy

> "Follow my own path, sell my own stock, track my own money — all offline."

This is not a general-purpose CRM. It's a personal field-operations system built for one door-to-door seller who knows their territory.

## ✨ Features

### 🗺️ Auto Route Tracking
- GPS tracking starts automatically when app opens
- Old routes are automatically reused when you're in a known area
- No route selection UI needed — app assumes "this area is already known"
- Shows your historical path with current position
- Warns if you deviate from known routes

### 🏠 Door Number + Customer Mapping
- Mandatory door numbers for every customer
- Exact location (adjustable pin)
- Searchable by name, phone, or door number
- Solves the "can't find the house" problem

### 📦 Stock & Inventory
- Fully dynamic (add/delete anytime)
- Quantity in pieces or weight (kg/litre)
- Two prices per item:
  - **Cost price** (what you paid)
  - **Selling price** (what customer pays)
- Low-stock alerts
- Clean profit & loss calculation

### 💰 Sales & Balance Tracking
- Credit-based system (common for door-to-door)
- Partial payments allowed
- Formula: `Previous Balance + New Sale - Payment = New Balance`
- Manual balance editing (real-world flexibility)
- Payment methods: Cash, UPI, or mixed

### 📊 Profit & Loss Reports
- Per day analysis
- Per customer analysis
- Mixed analysis (customer × date range)
- Charts for visual clarity
- Exportable as PDF

### 📤 Export & Backup
- PDF reports with date ranges
- Local backup & restore
- Share backups via any app

## 🏗️ Architecture

```
lib/
├── core/
│   └── database/
│       └── database_helper.dart      # SQLite setup
├── models/
│   ├── customer.dart
│   ├── stock.dart
│   ├── sale.dart
│   └── route.dart
├── repositories/
│   ├── customer_repository.dart
│   ├── stock_repository.dart
│   ├── sales_repository.dart
│   ├── route_repository.dart
│   └── reports_repository.dart
├── services/
│   ├── location_service.dart         # GPS tracking
│   ├── route_tracker.dart            # Auto route reuse logic
│   ├── pdf_export_service.dart       # PDF generation
│   └── backup_service.dart           # Backup/restore
└── screens/
    └── home_screen.dart              # Main navigation
```

## 🚀 Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / Xcode
- Google Maps API key (for map features)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/potato-Guy-ai/field-sales-tracker.git
cd field-sales-tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Add Google Maps API key:
- Open `android/app/src/main/AndroidManifest.xml`
- Replace `YOUR_API_KEY_HERE` with your actual API key

4. Run the app:
```bash
flutter run
```

## 📱 Database Schema

### Tables
- **routes** - GPS route tracking
- **route_points** - Individual GPS coordinates
- **customers** - Customer details with door numbers
- **stock** - Inventory with dual pricing
- **sales** - Sale transactions
- **sale_items** - Items in each sale
- **payments** - Payment records

### Key Relationships
- Sales → Customers (many-to-one)
- Sale Items → Sales (many-to-one)
- Sale Items → Stock (many-to-one)
- Route Points → Routes (many-to-one)

## 🎨 Design Decisions

### Why Offline-First?
Door-to-door sellers often work in areas with poor connectivity. Everything works without internet.

### Why Auto Route Reuse?
Sellers visit the same areas repeatedly. The app remembers your paths and reuses them automatically.

### Why Door Numbers?
Addresses can be vague in many areas. Door numbers become your mental map replacement.

### Why Two Prices?
To calculate real profit, you need both what you paid (cost) and what customers pay (selling price).

### Why Credit-Based?
Most door-to-door sales involve credit. Balance tracking is core, not optional.

## 🔒 Privacy & Security

- All data stored locally
- No cloud sync (optional in future)
- No app lock (user choice)
- Backups can be shared manually

## 📈 Roadmap

### MVP (Current)
- ✅ Database schema
- ✅ Core models
- ✅ Stock management
- ✅ Sales & balance logic
- ✅ Route tracking engine
- ✅ Reports & export
- ✅ Backup/restore

### Phase 2 (Future)
- [ ] Google Maps UI integration
- [ ] Customer management screens
- [ ] Sales creation UI
- [ ] Visual reports with charts
- [ ] Route visualization on map

### Phase 3 (Future)
- [ ] Cloud backup (optional)
- [ ] Multi-language support
- [ ] Voice notes for customers
- [ ] Photo attachments

## 🤝 Contributing

This is a personal project, but suggestions are welcome! Open an issue to discuss changes.

## 📄 License

MIT License - feel free to use and modify for your own needs.

## 🙏 Acknowledgments

Built for real door-to-door sellers who need a simple, reliable tool that works offline.

---

**Note:** Remember to add your Google Maps API key in `AndroidManifest.xml` before running the app.
