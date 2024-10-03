// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenNotifierHash() => r'09aa111673b633640466a85c2389fc7b4b5add16';

/// See also [TokenNotifier].
@ProviderFor(TokenNotifier)
final tokenNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TokenNotifier, List<ERC20Entity>>.internal(
  TokenNotifier.new,
  name: r'tokenNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokenNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TokenNotifier = AutoDisposeAsyncNotifier<List<ERC20Entity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
