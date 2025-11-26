import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_checklist.dart';
import '../../../bond/controllers/bonds/bond_type_controller.dart';
import '../../../cheques/controllers/cheques/cheque_type_conntroller.dart';
import '../../../cheques/data/models/cheque_type.dart';
import '../../../patterns/controllers/pattern_controller.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../../bond/data/models/bond_type.dart';


class BillBondChequeTypesChecklist extends StatelessWidget {
  BillBondChequeTypesChecklist({
    super.key,
    required this.onBillTypeSelected,
    required this.onBillTypeDeselected,
    required this.onBondTypeSelected,
    required this.onBondTypeDeselected,
    required this.onChequeTypeSelected,
    required this.onChequeTypeDeselected,
    this.initiallySelectedBillTypes,
    this.initiallySelectedBondTypes,
    this.initiallySelectedChequeTypes,
  });

  final PatternController billController = Get.find<PatternController>();
  final BondTypeController bondController = Get.find<BondTypeController>();
  final ChequeTypeController chequeController = Get.find<ChequeTypeController>();

  final void Function(BillTypeModel item) onBillTypeSelected;
  final void Function(BillTypeModel item) onBillTypeDeselected;

  final void Function(BondTypeModel item) onBondTypeSelected;
  final void Function(BondTypeModel item) onBondTypeDeselected;

  final void Function(ChequeType item) onChequeTypeSelected;
  final void Function(ChequeType item) onChequeTypeDeselected;

  final List<BillTypeModel>? initiallySelectedBillTypes;
  final List<BondTypeModel>? initiallySelectedBondTypes;
  final List<ChequeType>? initiallySelectedChequeTypes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Bill Types Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Bill Types",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder<List<BillTypeModel>>(
            future: billController.getAllBillTypes(false),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final billTypes = snapshot.data!;
              return CustomChecklist<BillTypeModel>(
                items: billTypes.where((item) => item.fullName != null).toList(),
                initiallySelected: initiallySelectedBillTypes,
                displayText: (item) => item.fullName!,
                onItemSelected: onBillTypeSelected,
                onItemDeselected: onBillTypeDeselected,
              );
            },
          ),

          const SizedBox(height: 20),

          /// Bond Types Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Bond Types",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder<List<BondTypeModel>>(
            future: bondController.getAllBondTypes(true),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final bondTypes = snapshot.data!;
              return CustomChecklist<BondTypeModel>(
                items: bondTypes.where((item) => item.label != null).toList(),
                initiallySelected: initiallySelectedBondTypes,
                displayText: (item) => item.label ?? '',
                onItemSelected: onBondTypeSelected,
                onItemDeselected: onBondTypeDeselected,
              );
            },
          ),

          const SizedBox(height: 20),

          /// Cheque Types Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Cheque Types",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder<List<ChequeType>>(
            future: chequeController.getAllCheques(true),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final chequeTypes = snapshot.data!;
              return CustomChecklist<ChequeType>(
                items: chequeTypes.where((item) => item.label.isNotEmpty).toList(),
                initiallySelected: initiallySelectedChequeTypes,
                displayText: (item) => item.label,
                onItemSelected: onChequeTypeSelected,
                onItemDeselected: onChequeTypeDeselected,
              );
            },
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../../core/widgets/custom_checklist.dart';
// import '../../../bond/controllers/bonds/bond_type_controller.dart';
// import '../../../patterns/controllers/pattern_controller.dart';
// import '../../../patterns/data/models/bill_type_model.dart';
// import '../../../bond/data/models/bond_type.dart';
//
// class BillAndBondTypesChecklist extends StatelessWidget {
//   BillAndBondTypesChecklist({
//     super.key,
//     required this.onBillTypeSelected,
//     required this.onBillTypeDeselected,
//     required this.onBondTypeSelected,
//     required this.onBondTypeDeselected,
//   });
//
//   final PatternController billController = Get.find<PatternController>();
//   final BondTypeController bondController = Get.find<BondTypeController>();
//
//   final void Function(BillTypeModel item) onBillTypeSelected;
//   final void Function(BillTypeModel item) onBillTypeDeselected;
//
//   final void Function(BondTypeModel item) onBondTypeSelected;
//   final void Function(BondTypeModel item) onBondTypeDeselected;
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// Bill Types Section
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 8.0),
//             child: Text(
//               "Bill Types",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           FutureBuilder<List<BillTypeModel>>(
//             future: billController.getAllBillTypes(false),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (snapshot.hasError) {
//                 return Center(child: Text("Error: ${snapshot.error}"));
//               }
//
//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text("No bill types found"));
//               }
//
//               final billTypes = snapshot.data!;
//
//               return CustomChecklist<BillTypeModel>(
//                 items: billTypes.where((item) => item.fullName != null).toList(),
//                 displayText: (item) => item.fullName!,
//                 onItemSelected: onBillTypeSelected,
//                 onItemDeselected: onBillTypeDeselected,
//               );
//             },
//           ),
//
//           const SizedBox(height: 20),
//
//           /// Bond Types Section
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 8.0),
//             child: Text(
//               "Bond Types",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           FutureBuilder<List<BondTypeModel>>(
//             future: bondController.getAllBondTypes(true),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (snapshot.hasError) {
//                 return Center(child: Text("Error: ${snapshot.error}"));
//               }
//
//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text("No bond types found"));
//               }
//
//               final bondTypes = snapshot.data!;
//
//               return CustomChecklist<BondTypeModel>(
//                 items: bondTypes.where((item) => item.label != null).toList(),
//                 displayText: (item) => item.label ?? '',
//                 onItemSelected: onBondTypeSelected,
//                 onItemDeselected: onBondTypeDeselected,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
