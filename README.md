# TaskMaster Pro — Flutter To-Do List Application

**Mobile Application Development-II Lab Project**  
**Architecture:** Model-View-Controller (MVC) with Clean Architecture principles  
**State Management & Navigation:** GetX  
**Database Storage:** SQLite (Local) & Firebase Cloud Firestore (Cloud Sync)  
**Firebase Project:** `class-project-55319` (class project)  
**Security:** Salted SHA-256 Cryptographic Password Hashing  

---

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Evaluation Criteria Breakdown](#evaluation-criteria-breakdown)
3. [Architecture & Folder Structure](#architecture--folder-structure)
4. [Functional Modules](#functional-modules)
   - [Authentication & Security](#1-user-authentication--security)
   - [Home & Task Dashboard](#2-home-dashboard--statistics)
   - [Task Management (CRUD)](#3-task-operations-crud)
   - [Search, Filtering & Sorting](#4-search-filtering--sorting)
5. [GetX Implementation Details](#getx-implementation-details)
   - [State Management](#state-management)
   - [Dependency Injection](#dependency-injection)
   - [Navigation & Middleware](#named-routes--middleware)
6. [Data Storage & Database Schema](#data-storage--database-schema)
7. [Getting Started & Setup](#getting-started--setup)
8. [Running Tests](#running-tests)

---

## 🎯 Project Overview
**TaskMaster Pro** is a production-grade personal task management mobile application built using Flutter and the MVC pattern. It enables users to securely register, authenticate, and manage daily tasks with priority levels, due date tracking, overdue alerts, search, and dynamic filtering.

Each user's tasks are completely isolated via relational database keys (`user_id`), ensuring robust multi-user privacy on the device.

---

## 🏆 Evaluation Criteria Breakdown (Total: 20 Marks)

| Component | Marks | Implementation in TaskMaster Pro |
|---|:---:|---|
| **Login, Sign-Up, and Validation** | **3** | Full email regex, min-length password & name validation, confirm password match, toggle password visibility, persistent sessions. |
| **Task Management Functionality** | **5** | Add, Edit, Delete (with confirmation dialog), Toggle Completed/Pending status, Overdue detection, Due date selection. |
| **MVC Architecture & Code Organization** | **4** | Strict decoupling of Models, Views, Controllers, Services, Bindings, Routes, and Shared Widgets. Zero UI business logic. |
| **GetX State Management & Navigation** | **3** | Reactive `RxList`, `RxBool`, `RxString`, `Obx()`, `Get.toNamed()`, `GetPage` definitions, and `AuthMiddleware` route protection. |
| **Reusable Widgets & Separate Constants** | **2** | Modular `CustomButton`, `CustomTextField`, `TaskCard`, `LoadingWidget`, `ConfirmationDialog`, and centralized colors, icons, strings. |
| **UI Design, Testing & Demonstration** | **3** | Modern Material 3 UI design, progress bar, priority color coding, comprehensive unit and widget test suite passing with 0 errors. |

---

## 📁 Architecture & Folder Structure

The project strictly follows the requested project structure:

```
lib/
├── main.dart                          # Application entrypoint & initialization
├── app/
│   ├── bindings/
│   │   └── app_binding.dart           # Bindings for lazy dependency injection
│   ├── constants/
│   │   ├── app_colors.dart            # Centralized brand, priority, & semantic colors
│   │   ├── app_icons.dart             # Centralized iconography
│   │   ├── app_images.dart            # Asset references
│   │   └── app_strings.dart           # Localized strings, labels & validation messages
│   └── routes/
│       ├── app_routes.dart            # Named route string constants
│       └── app_pages.dart             # Route page definitions & AuthMiddleware
├── data/
│   ├── models/
│   │   ├── user_model.dart            # User data model (serialization & copyWith)
│   │   └── task_model.dart            # Task data model with TaskPriority enum
│   └── services/
│       ├── database_helper.dart       # SQLite database initialization & tables creation
│       ├── auth_service.dart          # Hashing, registration, login, session persistence
│       └── task_service.dart          # CRUD SQLite queries isolated by user_id
├── modules/
│   ├── auth/
│   │   ├── controllers/
│   │   │   └── auth_controller.dart   # Validation logic, login/signup handlers
│   │   └── views/
│   │       ├── login_view.dart        # Responsive login form
│   │       └── register_view.dart     # Responsive registration form
│   ├── home/
│   │   ├── controllers/
│   │   │   └── home_controller.dart   # Task filtering, sorting, search, stats
│   │   └── views/
│   │       └── home_view.dart         # Dashboard, stats cards, task list
│   └── tasks/
│       ├── controllers/
│       │   └── task_controller.dart   # Task create/update/status controller
│       └── views/
│           ├── add_edit_task_view.dart# Form to create or modify tasks
│           └── task_detail_view.dart  # Detailed task view with status actions
└── shared/
    └── widgets/
        ├── confirmation_dialog.dart   # Generic styled modal confirmation
        ├── custom_button.dart         # Reusable button with loading & outline styles
        ├── custom_text_field.dart     # Form text input with validation and styling
        ├── loading_widget.dart        # Centered loading spinner with optional text
        └── task_card.dart             # Interactive card with priority pill & quick toggle
```

---

## 🔐 Functional Modules

### 1. User Authentication & Security
- **Salted Password Hashing**: Passwords are never stored in plain text. `AuthService.hashPassword()` creates a SHA-256 hash combined with a cryptographic salt.
- **Session Persistence**: Upon successful authentication, the active `user_id` is recorded in `SharedPreferences`. Returning users remain signed in.
- **Route Guard / Middleware**: `AuthMiddleware` inspects `AuthService.isAuthenticated`. Any unauthenticated attempt to visit `/home`, `/add-task`, etc. is automatically routed to `/login`.

### 2. Home Dashboard & Statistics
- Real-time task statistics:
  - **Total Tasks**
  - **In Progress / Pending**
  - **Completed**
  - **Completion Rate ProgressBar** (e.g. `75% Tasks Completed`)
- Pull-to-refresh (`RefreshIndicator`) to sync tasks.

### 3. Task Operations (CRUD)
- **Create**: Specify title, optional description, due date (interactive `DatePicker`), and priority (`Low`, `Medium`, `High`).
- **Read**: Quick glance via `TaskCard` or full detail view via `TaskDetailView`.
- **Update**: Edit title, notes, priority, or due date.
- **Delete**: Supported via swipe/more menu with safety confirmation dialog (`ConfirmationDialog`).
- **Status Toggle**: 1-tap completion toggle from the home card or task detail view.

### 4. Search, Filtering & Sorting
- **Search**: Instant reactive filtering matching title and description.
- **Filters**: Segment tasks by `All`, `Pending`, or `Completed`.
- **Sorting**:
  - Sort by **Due Date** (earliest first)
  - Sort by **Priority** (High $\to$ Medium $\to$ Low)
  - Sort by **Newest** (creation timestamp)

---

## ⚡ GetX Implementation Details

### State Management
- **Reactive Variables**: Uses `.obs` observables (`RxList<TaskModel>`, `RxBool`, `RxString`, `Rx<TaskPriority>`).
- **Reactive UI**: Uses `Obx(() => ...)` ensuring surgical widget tree rebuilds only where data changes.

### Dependency Injection
- Pre-boot initializations in `main.dart` with `Get.putAsync<AuthService>()`.
- Per-route lazy injection configured inside `AppPages` via dedicated `Bindings`:
  - `AuthBinding`: injects `AuthController`
  - `HomeBinding`: injects `HomeController`
  - `TaskBinding`: injects `TaskController`

### Named Routes & Middleware
All route navigation uses clean named routing:
- `Get.toNamed(Routes.ADD_TASK)`
- `Get.offAllNamed(Routes.LOGIN)`
- `Get.back(result: true)`

---

## 🗄️ Data Storage & Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL
);
```

### Tasks Table
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  due_date TEXT NOT NULL,
  priority TEXT NOT NULL,
  is_completed INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
```

---

## 🚀 Getting Started & Setup

1. **Clone or open the repository**:
   ```bash
   cd "class project"
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify code quality**:
   ```bash
   flutter analyze
   ```

4. **Run the application**:
   - On Android emulator / physical device:
     ```bash
     flutter run
     ```
   - On Windows Desktop:
     ```bash
     flutter run -d windows
     ```
   - On Chrome / Web:
     ```bash
     flutter run -d chrome
     ```

---

## 🧪 Running Tests
Execute the automated test suite covering serialization, business rules, and UI widgets:
```bash
flutter test
```
All tests verify:
- ✅ `UserModel` serialization & copyWith
- ✅ `TaskModel` serialization & priority parsing
- ✅ Overdue task calculation logic
- ✅ `CustomButton` tap response & loading indicator
- ✅ `CustomTextField` rendering & text entry
- ✅ `TaskCard` rendering & completion toggling
