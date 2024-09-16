// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_pool_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedPoolHash() => r'e2693f5b0509dbb8f44367e514b405b1c6fe858c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SelectedPool extends BuildlessAutoDisposeAsyncNotifier<Pair> {
  late final Pair pair;

  FutureOr<Pair> build(
    Pair pair,
  );
}

/// See also [SelectedPool].
@ProviderFor(SelectedPool)
const selectedPoolProvider = SelectedPoolFamily();

/// See also [SelectedPool].
class SelectedPoolFamily extends Family<AsyncValue<Pair>> {
  /// See also [SelectedPool].
  const SelectedPoolFamily();

  /// See also [SelectedPool].
  SelectedPoolProvider call(
    Pair pair,
  ) {
    return SelectedPoolProvider(
      pair,
    );
  }

  @override
  SelectedPoolProvider getProviderOverride(
    covariant SelectedPoolProvider provider,
  ) {
    return call(
      provider.pair,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'selectedPoolProvider';
}

/// See also [SelectedPool].
class SelectedPoolProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SelectedPool, Pair> {
  /// See also [SelectedPool].
  SelectedPoolProvider(
    Pair pair,
  ) : this._internal(
          () => SelectedPool()..pair = pair,
          from: selectedPoolProvider,
          name: r'selectedPoolProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectedPoolHash,
          dependencies: SelectedPoolFamily._dependencies,
          allTransitiveDependencies:
              SelectedPoolFamily._allTransitiveDependencies,
          pair: pair,
        );

  SelectedPoolProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pair,
  }) : super.internal();

  final Pair pair;

  @override
  FutureOr<Pair> runNotifierBuild(
    covariant SelectedPool notifier,
  ) {
    return notifier.build(
      pair,
    );
  }

  @override
  Override overrideWith(SelectedPool Function() create) {
    return ProviderOverride(
      origin: this,
      override: SelectedPoolProvider._internal(
        () => create()..pair = pair,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pair: pair,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SelectedPool, Pair> createElement() {
    return _SelectedPoolProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedPoolProvider && other.pair == pair;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pair.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SelectedPoolRef on AutoDisposeAsyncNotifierProviderRef<Pair> {
  /// The parameter `pair` of this provider.
  Pair get pair;
}

class _SelectedPoolProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SelectedPool, Pair>
    with SelectedPoolRef {
  _SelectedPoolProviderElement(super.provider);

  @override
  Pair get pair => (origin as SelectedPoolProvider).pair;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
