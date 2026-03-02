// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserProgressViewModel)
final userProgressViewModelProvider = UserProgressViewModelProvider._();

final class UserProgressViewModelProvider
    extends $AsyncNotifierProvider<UserProgressViewModel, UserProgressModel?> {
  UserProgressViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProgressViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProgressViewModelHash();

  @$internal
  @override
  UserProgressViewModel create() => UserProgressViewModel();
}

String _$userProgressViewModelHash() =>
    r'3d8ffc740edee0930510cfc64b4fca8ece43b1e3';

abstract class _$UserProgressViewModel
    extends $AsyncNotifier<UserProgressModel?> {
  FutureOr<UserProgressModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<UserProgressModel?>, UserProgressModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProgressModel?>, UserProgressModel?>,
              AsyncValue<UserProgressModel?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
