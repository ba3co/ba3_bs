import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:flutter/material.dart';

class AccountSelectionDialog extends StatelessWidget {
  final List<AccountModel> accounts;

  const AccountSelectionDialog({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 500,
      child: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Center(
                child: Text(
              accounts[index].accName!,
              style: const TextStyle(fontSize: 14),
            )),
            onTap: () => Navigator.of(context).pop(accounts[index]),
          );
        },
      ),
    );
  }
}
