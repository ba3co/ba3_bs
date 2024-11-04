import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/sellers/data/models/seller_model.dart';
import 'package:flutter/material.dart';

class SellerSelectionDialog extends StatelessWidget {
  final List<SellerModel> sellers;

  const SellerSelectionDialog({super.key, required this.sellers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 500,
      child: ListView.builder(
        itemCount: sellers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Center(
                child: Text(
              sellers[index].costName!,
              style: const TextStyle(fontSize: 14),
            )),
            onTap: () => Navigator.of(context).pop(sellers[index]),
          );
        },
      ),
    );
  }
}

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
