// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenBalanceNotifierHash() =>
    r'3d0dae51a23992bf5a4700eda970a18af90b9916';

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

abstract class _$TokenBalanceNotifier
    extends BuildlessAutoDisposeAsyncNotifier<Amount> {
  late final ERC20Entity token;

  FutureOr<Amount> build(
    ERC20Entity token,
  );
}

/// See also [TokenBalanceNotifier].
@ProviderFor(TokenBalanceNotifier)
const tokenBalanceNotifierProvider = TokenBalanceNotifierFamily();

/// See also [TokenBalanceNotifier].
class TokenBalanceNotifierFamily extends Family<AsyncValue<Amount>> {
  /// See also [TokenBalanceNotifier].
  const TokenBalanceNotifierFamily();

  /// See also [TokenBalanceNotifier].
  TokenBalanceNotifierProvider call(
    ERC20Entity token,
  ) {
    return TokenBalanceNotifierProvider(
      token,
    );
  }

  @override
  TokenBalanceNotifierProvider getProviderOverride(
    covariant TokenBalanceNotifierProvider provider,
  ) {
    return call(
      provider.token,
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
  String? get name => r'tokenBalanceNotifierProvider';
}

/// See also [TokenBalanceNotifier].
class TokenBalanceNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<TokenBalanceNotifier, Amount> {
  /// See also [TokenBalanceNotifier].
  TokenBalanceNotifierProvider(
    ERC20Entity token,
  ) : this._internal(
          () => TokenBalanceNotifier()..token = token,
          from: tokenBalanceNotifierProvider,
          name: r'tokenBalanceNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tokenBalanceNotifierHash,
          dependencies: TokenBalanceNotifierFamily._dependencies,
          allTransitiveDependencies:
              TokenBalanceNotifierFamily._allTransitiveDependencies,
          token: token,
        );

  TokenBalanceNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.token,
  }) : super.internal();

  final ERC20Entity token;

  @override
  FutureOr<Amount> runNotifierBuild(
    covariant TokenBalanceNotifier notifier,
  ) {
    return notifier.build(
      token,
    );
  }

  @override
  Override overrideWith(TokenBalanceNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TokenBalanceNotifierProvider._internal(
        () => create()..token = token,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        token: token,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TokenBalanceNotifier, Amount>
      createElement() {
    return _TokenBalanceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TokenBalanceNotifierProvider && other.token == token;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, token.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TokenBalanceNotifierRef on AutoDisposeAsyncNotifierProviderRef<Amount> {
  /// The parameter `token` of this provider.
  ERC20Entity get token;
}

class _TokenBalanceNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TokenBalanceNotifier,
        Amount> with TokenBalanceNotifierRef {
  _TokenBalanceNotifierProviderElement(super.provider);

  @override
  ERC20Entity get token => (origin as TokenBalanceNotifierProvider).token;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
