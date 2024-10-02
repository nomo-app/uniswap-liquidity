import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'show_all_pools_provider.g.dart';

@Riverpod(keepAlive: true)
class ShowAllPools extends _$ShowAllPools {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }
}
