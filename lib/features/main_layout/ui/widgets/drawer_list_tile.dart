import 'package:flutter/material.dart';

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.index,
    required this.onTap,
  });

  final String title;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
              child: Row(
            children: [
              const SizedBox(
                width: 40,
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ))),
    );
  }
}
