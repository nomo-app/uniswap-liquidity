import 'package:walletkit_dart/walletkit_dart.dart';

final rpc = EvmRpcInterface(
  useQueuedManager: false,
  type: ZeniqSmartNetwork,
  clients: [
    EvmRpcClient(zeniqSmartRPCEndpoint),
  ],
);
final factory = UniswapV2Factory(
  rpc: rpc,
  contractAddress: "0x7D0cbcE25EaaB8D5434a53fB3B42077034a9bB99",
);
final zeniqSwapRouter = UniswapV2Router(
  rpc: rpc,
  contractAddress: "0x7963c1bd24E4511A0b14bf148F93e2556AFe3C27",
);
