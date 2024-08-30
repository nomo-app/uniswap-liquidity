// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liquidity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$liquidityNotifierHash() => r'97056585ae41ef8495888e4f4db450928639cfbb';

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

abstract class _$LiquidityNotifier
    extends BuildlessAutoDisposeAsyncNotifier<String> {
  late final Liquidity liquidity;

  FutureOr<String> build(
    Liquidity liquidity,
  );
}

/// See also [LiquidityNotifier].
@ProviderFor(LiquidityNotifier)
const liquidityNotifierProvider = LiquidityNotifierFamily();

/// See also [LiquidityNotifier].
class LiquidityNotifierFamily extends Family<AsyncValue<String>> {
  /// See also [LiquidityNotifier].
  const LiquidityNotifierFamily();

  /// See also [LiquidityNotifier].
  LiquidityNotifierProvider call(
    Liquidity liquidity,
  ) {
    return LiquidityNotifierProvider(
      liquidity,
    );
  }

  @override
  LiquidityNotifierProvider getProviderOverride(
    covariant LiquidityNotifierProvider provider,
  ) {
    return call(
      provider.liquidity,
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
  String? get name => r'liquidityNotifierProvider';
}

/// See also [LiquidityNotifier].
class LiquidityNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<LiquidityNotifier, String> {
  /// See also [LiquidityNotifier].
  LiquidityNotifierProvider(
    Liquidity liquidity,
  ) : this._internal(
          () => LiquidityNotifier()..liquidity = liquidity,
          from: liquidityNotifierProvider,
          name: r'liquidityNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$liquidityNotifierHash,
          dependencies: LiquidityNotifierFamily._dependencies,
          allTransitiveDependencies:
              LiquidityNotifierFamily._allTransitiveDependencies,
          liquidity: liquidity,
        );

  LiquidityNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.liquidity,
  }) : super.internal();

  final Liquidity liquidity;

  @override
  FutureOr<String> runNotifierBuild(
    covariant LiquidityNotifier notifier,
  ) {
    return notifier.build(
      liquidity,
    );
  }

  @override
  Override overrideWith(LiquidityNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: LiquidityNotifierProvider._internal(
        () => create()..liquidity = liquidity,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        liquidity: liquidity,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<LiquidityNotifier, String>
      createElement() {
    return _LiquidityNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LiquidityNotifierProvider && other.liquidity == liquidity;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, liquidity.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LiquidityNotifierRef on AutoDisposeAsyncNotifierProviderRef<String> {
  /// The parameter `liquidity` of this provider.
  Liquidity get liquidity;
}

class _LiquidityNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LiquidityNotifier, String>
    with LiquidityNotifierRef {
  _LiquidityNotifierProviderElement(super.provider);

  @override
  Liquidity get liquidity => (origin as LiquidityNotifierProvider).liquidity;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
