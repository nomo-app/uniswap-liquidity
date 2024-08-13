import 'package:walletkit_dart/walletkit_dart.dart';

final rpc = EvmRpcInterface(
  type: ZeniqSmartNetwork,
  clients: [
    EvmRpcClient(zeniqSmartRPCEndpoint),
  ],
);
final factory = UniswapV2Factory(
  rpc: rpc,
  contractAddress: "0x7D0cbcE25EaaB8D5434a53fB3B42077034a9bB99",
);
