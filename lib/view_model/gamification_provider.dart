import 'package:ascend/core/services/app_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gamification_provider.g.dart';

@riverpod
class GamificationNotifier extends _$GamificationNotifier {
  @override
  bool build() {
    return AppPreferences.getPreferenceBool(
          AppPreferences.keyGamificationEnabled,
        ) ??
        true; // Enabled by default
  }

  Future<void> toggle() async {
    state = !state;
    await AppPreferences.setPreferenceBool(
      AppPreferences.keyGamificationEnabled,
      state,
    );
  }
}
