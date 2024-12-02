import 'package:ba3_bs/features/sellers/data/models/seller_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SellerSelectionDialog extends StatelessWidget {
  final List<SellerModel> sellers;
  final Function(SellerModel selectedSeller) onSellerTap;
  final VoidCallback onCloseTap; // The callback for closing the dialog

  const SellerSelectionDialog({
    super.key,
    required this.sellers,
    required this.onSellerTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (1.sh - 500) / 2,
      left: (1.sw - 500) / 2,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          width: 500,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button (top-right corner)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 24, color: Colors.black),
                    onPressed: onCloseTap, // Call the close callback when pressed
                  ),
                  Text(
                    'اختر البائع',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
              Expanded(
                child: Center(
                  child: ListView.builder(
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Center(
                          child: Text(
                            sellers[index].costName!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        onTap: () {
                          // Trigger the callback with the selected seller
                          onSellerTap(sellers[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
