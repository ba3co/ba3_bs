import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_spacer.dart';

class ChequesDetailsCalculations extends StatelessWidget {
  const ChequesDetailsCalculations({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const VerticalSpace(),
        SizedBox(
          width: 350,
          child: Row(
            children: [
              const SizedBox(
                  width: 100,
                  child: Text(
                    "المجموع",
                  )),
              // Container(width: 120, color: chequesDetailsPlutoController.checkIfBalancedCheques() ? Colors.green : Colors.red, padding: const EdgeInsets.all(5), child: Text(chequesDetailsPlutoController.calcDebitTotal().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
              const SizedBox(width: 10),
              // Container(width: 120, color: chequesDetailsPlutoController.checkIfBalancedCheques() ? Colors.green : Colors.red, padding: const EdgeInsets.all(5), child: Text(chequesDetailsPlutoController.calcCreditTotal().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 18))),
            ],
          ),
        ),
        const VerticalSpace(
          5,
        ),
        SizedBox(
          width: 350,
          child: Row(
            children: [
              const SizedBox(width: 100, child: Text("الفرق")),
              Container(
                width: 250,
                // color: chequesDetailsPlutoController.checkIfBalancedCheques() ? Colors.green : Colors.red,
                padding: const EdgeInsets.all(5),
                // child: Text(
                //   chequesDetailsPlutoController.getDefBetweenCreditAndDebt().toStringAsFixed(2),
                //   style: const TextStyle(color: Colors.white, fontSize: 18),
                // ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
