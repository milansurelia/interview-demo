# tectonas_ems

A Flutter application for employee management.

## Features

- Employee Module
  - Listing Submodule with search and filter
  - Detail Submodule
- Offline employee cache with network fallback

## Getting started

### Prerequisites

- Install the Flutter SDK and complete the setup for your target platform.
- Use an emulator/simulator or connect a device to run the app.

### Run locally

From the project directory, fetch dependencies and launch the app:

```sh
flutter pub get
flutter run
```

## How the app is structured

### Startup and dependencies

`lib/main.dart` initializes Flutter, awaits `setupDependencies()`, and then
starts `MyApp`. `lib/core/di/initial_dependencies.dart` registers a shared
`Dio` client and opens the Hive CE employee box. The `HiveOfflineService` and
the open box are registered in GetIt so screens and Blocs share one cache.

### Employee data

`lib/employee/model/employee_model.dart` is the canonical employee model.
`EmployeeModel.fromMap` turns API JSON into typed employee, address, and company
objects; `toMap` and `toJson` serialize those objects for display and caching.

The app reads JSONPlaceholder's `/users` endpoint for the listing and
`/users/{id}` for an individual employee. Listing and detail Blocs own those
requests and expose loading, loaded, and error states to their screens.

### Listing screen

`lib/employee/listing-submodule/screen/employee_listing_screen.dart` creates
the listing Bloc and listens to its state. Search filters the current employee
list in real time by name or email. The company dropdown adds a second,
composable filter. Selecting a card opens that employee's detail screen.

`lib/employee/listing-submodule/screen/widgets/employee_listing_card.dart`
contains the reusable employee card and its navigation behavior.

### Detail screen

`lib/employee/detail-submodule/screen/employee_detail_screen.dart` requests
the selected employee ID, then renders their contact details, address,
coordinates, and company information. Both employee screens support pull to
refresh and show a retry action when detail loading fails.

### Offline behavior

Successful listing and detail responses are persisted in the Hive box by
`lib/core/cache/employee_cache.dart`. If a request fails, the Blocs try to
display saved employee data and mark it as coming from cache, without assuming
the device is offline. Cached data is available only after it has been fetched
successfully at least once. This is local read-through caching, not background
synchronization or offline editing.

### Shared layout

`lib/core/widgets/spacing.dart` defines `VSpace` and `HSpace` widgets for
consistent vertical and horizontal gaps.

## Tests

`test/employee_model_test.dart` checks employee JSON serialization and saving
and loading an employee through the Hive cache. Run it with:

```sh
flutter test test/employee_model_test.dart
```
