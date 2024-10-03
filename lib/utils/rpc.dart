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

final factoryZeniqSwap = ZeniqswapV2Factory(
  rpc: rpc,
  contractAddress: "0x40a4E23Cc9E57161699Fd37c0A4d8bca383325f3",
);

final zeniqV2SwapRouter = ZeniqswapV2Router(
  rpc: rpc,
  contractAddress: "0xEBb0C81b3450520f54282A9ca9996A1960Be7c7A",
);
