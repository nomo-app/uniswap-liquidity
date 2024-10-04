// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenNotifierHash() => r'7922139b6a1d0d01c6ec72f59b9416aad4c6ed7b';

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

abstract class _$TokenNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<ERC20Entity>> {
  late final List<Pair> pairs;

  FutureOr<List<ERC20Entity>> build(
    List<Pair> pairs,
  );
}

/// See also [TokenNotifier].
@ProviderFor(TokenNotifier)
const tokenNotifierProvider = TokenNotifierFamily();

/// See also [TokenNotifier].
class TokenNotifierFamily extends Family<AsyncValue<List<ERC20Entity>>> {
  /// See also [TokenNotifier].
  const TokenNotifierFamily();

  /// See also [TokenNotifier].
  TokenNotifierProvider call(
    List<Pair> pairs,
  ) {
    return TokenNotifierProvider(
      pairs,
    );
  }

  @override
  TokenNotifierProvider getProviderOverride(
    covariant TokenNotifierProvider provider,
  ) {
    return call(
      provider.pairs,
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
  String? get name => r'tokenNotifierProvider';
}

/// See also [TokenNotifier].
class TokenNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TokenNotifier, List<ERC20Entity>> {
  /// See also [TokenNotifier].
  TokenNotifierProvider(
    List<Pair> pairs,
  ) : this._internal(
          () => TokenNotifier()..pairs = pairs,
          from: tokenNotifierProvider,
          name: r'tokenNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tokenNotifierHash,
          dependencies: TokenNotifierFamily._dependencies,
          allTransitiveDependencies:
              TokenNotifierFamily._allTransitiveDependencies,
          pairs: pairs,
        );

  TokenNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pairs,
  }) : super.internal();

  final List<Pair> pairs;

  @override
  FutureOr<List<ERC20Entity>> runNotifierBuild(
    covariant TokenNotifier notifier,
  ) {
    return notifier.build(
      pairs,
    );
  }

  @override
  Override overrideWith(TokenNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TokenNotifierProvider._internal(
        () => create()..pairs = pairs,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pairs: pairs,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TokenNotifier, List<ERC20Entity>>
      createElement() {
    return _TokenNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TokenNotifierProvider && other.pairs == pairs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pairs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TokenNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<ERC20Entity>> {
  /// The parameter `pairs` of this provider.
  List<Pair> get pairs;
}

class _TokenNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TokenNotifier,
        List<ERC20Entity>> with TokenNotifierRef {
  _TokenNotifierProviderElement(super.provider);

  @override
  List<Pair> get pairs => (origin as TokenNotifierProvider).pairs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
