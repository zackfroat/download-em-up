# InsideTeam

> **Build Safer. Work Smarter. Together.**  
> Enterprise-grade Construction Management & Telecommunication Infrastructure Operations Platform.

---

## 📥 Download Release

Get the latest Android release build directly from GitHub:

[![Download APK](https://img.shields.io/badge/Download-InsideTeam%20v0.0.1%20APK-0D9488?style=for-the-badge&logo=android&logoColor=white)](https://github.com/zackfroat/download-em-up/releases/tag/v0.0.1)

👉 **[Download InsideTeam v0.0.1 (APK)](https://github.com/zackfroat/download-em-up/releases/tag/v0.0.1)**

---

## 📌 Project Overview

**InsideTeam** is a cross-platform (Mobile, Web, Desktop) application built with Flutter & Dart designed for construction project directors, site managers, safety officers, and field staff. It streamlines and unifies project workflows across telecommunication, safety, procurement, sub-contracting, and financial tracking.

---

## 🚀 Key Modules & Capabilities

InsideTeam features 8 core operational modules with role-based permissions (Staff vs Admin):

| Module Code | Module Name | Description & Key Functions |
| :--- | :--- | :--- |
| **MOD-01** | **Safety & Training** | Site safety induction, monthly safety campaigns, incident logging, NCR tracking, and interactive safety workflow audit flowcharts. |
| **MOD-02** | **Document Control** | Controlled engineering drawings, verification approval stages, version revisions, and document distribution registers. |
| **MOD-03** | **SOP & Compliance** | Quality assurance checklists, step-by-step Standard Operating Procedures, verification sign-offs, and site audits. |
| **MOD-04** | **Budget Tracking & Cost Review** | Work package budget breakdown, financial variance analytics, monthly disbursement reviews with Director sign-off gating. |
| **MOD-05** | **Subcontractor Management** | Subcontractor performance scoring (SPI), contract timeline milestones, machinery/manpower compliance memos, and SLA tracking. |
| **MOD-06** | **Material Procurement** | Procurement order tracking, automated step-by-step workflow pipeline, supplier verification, and delivery receiving. |
| **MOD-07** | **Equipment & Maintenance** | Machinery & tools registry, preventative maintenance schedules, operational status, and certification renewal alerts. |
| **MOD-08** | **Site Progress & Scheduling** | Milestone tracking, baseline progress comparisons, project calendar synchronization, and delay mitigations. |

---

## 🔐 Role-Based Access Control (RBAC)

The platform enforces strict role-based gating across all screens:
- **Staff View**: Read-only operational visibility into records, checklists, work packages, and ledger items without destructive capabilities.
- **Admin View**: Elevated permissions allowing director-level sign-offs, monthly disbursement authorizations, budget allocation edits, and safety audit status overrides.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Channel stable, Dart 3.x)
- **State Management**: Reactive state handling with `StatefulWidget` and `ChangeNotifier` services
- **Backend / Auth**: [Supabase](https://supabase.com/) integration for authentication and remote storage
- **UI & Design**: Custom Material 3 theme with cohesive slate/teal/amber color palette, custom responsive layouts, and interactive SVG/CustomPainter flowchart modals
- **Platforms Supported**: Android (APK), Web (HTML5/CanvasKit), Windows, macOS, Linux

---

## 🏃 Getting Started & Development

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.2` or later)
- Android SDK / Android Studio (for Android builds)
- Git

### 1. Clone the repository
```bash
git clone https://github.com/zackfroat/download-em-up.git
cd download-em-up
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the development server
```bash
# Run on Web Server
flutter run -d web-server --web-port=3000

# Or run on connected Android Device / Emulator
flutter run
```

### 4. Build Release APK
```bash
flutter build apk --release
```
The compiled APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Testing

Run all unit and widget tests:
```bash
flutter test
```

---

## 📄 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.
