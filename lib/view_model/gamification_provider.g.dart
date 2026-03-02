// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GamificationNotifier)
final gamificationProvider = GamificationNotifierProvider._();

final class GamificationNotifierProvider
    extends $NotifierProvider<GamificationNotifier, bool> {
  GamificationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gamificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gamificationNotifierHash();

  @$internal
  @override
  GamificationNotifier create() => GamificationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$gamificationNotifierHash() =>
    r'b400c106d391730f15379d654ea57a2c9fad88d0';

abstract class _$GamificationNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
