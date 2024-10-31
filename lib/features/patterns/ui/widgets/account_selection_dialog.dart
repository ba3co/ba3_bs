import 'package:flutter/material.dart';

class AccountSelectionDialog extends StatelessWidget {
  final List<String> accountNames;

  const AccountSelectionDialog({super.key, required this.accountNames});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 500,
      child: ListView.builder(
        itemCount: accountNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Center(
                child: Text(
              accountNames[index],
              style: const TextStyle(fontSize: 14),
            )),
            onTap: () => Navigator.of(context).pop(accountNames[index]),
          );
        },
      ),
    );
  }
}
