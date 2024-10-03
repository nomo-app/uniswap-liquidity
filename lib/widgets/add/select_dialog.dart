import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/dialog/nomo_dialog.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:uniswap_liquidity/provider/token_provider.dart';
import 'package:uniswap_liquidity/widgets/add/pair_item.dart';

class SelectDialog extends ConsumerWidget {
  const SelectDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenNotifierProvider);

    return NomoDialog(
      maxWidth: 600,
      title: "Select a token",
      titleStyle: context.typography.b2,
      content: tokens.when(
        data: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              NomoText(
                "Token balance",
                style: context.typography.b1,
              ),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final token = data[index];
                    return Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.pop(context, token),
                        child: TokenItem(token: token),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => NomoText(error.toString()),
        loading: () => CircularProgressIndicator(
          color: context.theme.colors.primary,
        ),
      ),
    );
  }
}
