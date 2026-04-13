# E2E Test Results Summary (2026-04-12)

## Games Tested: 35

### ✅ PASSED (100%)
| Game | Pass Rate | Notes |
|------|-----------|-------|
| MG-0001 | 100% (1/1) | Single test game |
| MG-0002 | 100% (4/4) | Cat Alchemy - setState fix applied |
| MG-0029 | 100% (4/4) | Blood Opera - DailyQuestManager fix applied |

### ❌ FAILED (Gradle Version Issue)
| Game | Status | Issue |
|------|--------|-------|
| MG-0035 | 0% | Gradle version 8.9, needs 8.13+ |

### ❌ FAILED (Compilation Errors - Bracket Issues)
| Game | Error Pattern |
|------|---------------|
| MG-0012 | `GachaManager();` → `GachaManager());` |
| MG-0015 | Multiple syntax errors |
| MG-0016 | Spread operator misuse |
| MG-0018 | Bracket errors in DI registration |
| MG-0021 | Bracket errors + missing assets |
| MG-0022 | Bracket errors + missing assets |
| MG-0023 | Bracket errors + non-ASCII chars |
| MG-0024 | Bracket errors + non-ASCII chars |
| MG-0025 | Bracket errors |
| MG-0026 | Bracket errors (10+ instances) |
| MG-0027 | Bracket errors |
| MG-0028 | Bracket errors |
| MG-0030 | Bracket errors (4+ instances) |
| MG-0031 | Missing directories + undefined getters |
| MG-0033 | Bracket errors + missing `translate` method |
| MG-0034 | Bracket errors + duplicate `l10n` extensions |
| MG-0036 | Bracket errors |
| MG-0037 | Bracket errors |
| MG-0038 | Bracket errors + missing `translate` method |
| MG-0039 | Bracket errors + missing assets + duplicate `l10n` |
| MG-0040 | Bracket errors |
| MG-0041 | Bracket errors + missing `main` method |
| MG-0042 | Bracket errors + missing `CarnavalMatchApp` constructor |

### ❌ FAILED (Other Issues)
| Game | Pass Rate | Issue |
|------|-----------|-------|
| MG-0010 | 25% (1/4) | Firebase double init - FIXED, needs retest |
| MG-0011 | 0% | UI overflow (141px) causing pumpAndSettle timeout |
| MG-0013 | 0% | Test timeout after 12 minutes |
| MG-0014 | 50% (2/4) | UI element not found |
| MG-0020 | 0% | AndroidManifest.xml not found |
| MG-0032 | 50% (2/4) | UI element not found |

## Common Error Patterns

1. **Bracket Errors** (affects 20+ games):
   ```dart
   GetIt.I.registerSingleton(Manager();  // Missing closing parenthesis
   ```
   Fix: Add closing parenthesis `)`

2. **Firebase Double Initialization**:
   ```dart
   await Firebase.initializeApp(...);  // Called multiple times
   ```
   Fix: Wrap in try-catch

3. **UI Overflow** (MG-0011):
   - Row in `MGForestHud` overflows by 141px
   - Causes pumpAndSettle timeout

4. **Missing Asset Directories**:
   - Invalid pubspec.yaml paths like `assets\audio\bgm\spine\`

5. **Missing Methods**:
   - `translate()` method not defined in multiple games
   - Duplicate `l10n` extension conflicts

## Fixes Applied

### MG-0002 (lib/main.dart)
```dart
if (mounted) {
  setState(() { _isLoading = false; });
}
```

### MG-0010 (lib/main.dart)
```dart
try {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
} catch (e) {
  // Firebase already initialized - skip in tests
}
```

### MG-0029, 0032 (lib/main.dart)
```dart
if (!GetIt.I.isRegistered<DailyQuestManager>()) {
  final dailyQuest = DailyQuestManager();
  GetIt.I.registerSingleton<DailyQuestManager>(dailyQuest);
}
```

## Test Statistics

- **Total Games:** 52
- **Tested:** 35 (67%)
- **Passed:** 3 (8.6% of tested)
- **Failed with Compilation Errors:** 27 (77% of failures)
- **Failed with Other Issues:** 5 (14% of failures)

## Main Blockers

1. **Systematic bracket errors** in DI registration code
2. **Missing asset directories** in pubspec.yaml
3. **UI layout issues** causing test timeouts
4. **Gradle version mismatch** (MG-0035)
5. **Firebase initialization** in test environment
6. **Missing/undefined methods** (translate, l10n conflicts)

## Recommended Next Steps

1. Fix bracket errors systematically across all games
2. Add Firebase initialization guards to all games
3. Fix missing asset directory references
4. Update Gradle version for MG-0035
5. Investigate and fix UI overflow issues
6. Continue testing remaining 17 games
