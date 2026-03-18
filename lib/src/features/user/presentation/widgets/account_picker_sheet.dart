import 'package:flutter/material.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/foundation/config/global_context.dart';

Future<Account?> showAccountPickerSheet(
  BuildContext context, {
  required Account currentAccount,
  String? title,
}) {
  return showModalBottomSheet<Account>(
    context: context,
    showDragHandle: true,
    builder: (context) => AccountPickerSheet(
      currentAccount: currentAccount,
      title: title,
    ),
  );
}

class AccountPickerSheet extends StatefulWidget {
  const AccountPickerSheet({
    super.key,
    required this.currentAccount,
    this.title,
  });

  final Account currentAccount;
  final String? title;

  @override
  State<AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends State<AccountPickerSheet> {
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAccounts());
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await Account.accounts().then(
        (accounts) => accounts.where((account) => account.id != widget.currentAccount.id).toList(),
      );

      if (!mounted) return;
      setState(() => _accounts = accounts);
    } catch (e) {
      if (!mounted) return;
      setState(() => _accounts = []);
      debugPrint('Failed to load accounts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(widget.title ?? l10n.account(2), style: theme.textTheme.titleLarge),
          ),
          _accounts.isEmpty
              ? Center(child: Text(l10n.noAccountsAdded))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    return ListTile(
                      title: Text(account.username ?? '-', style: theme.textTheme.titleMedium),
                      subtitle: Text(account.instance),
                      onTap: () => Navigator.of(context).pop(account),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
