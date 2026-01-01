import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Text(
            '♔',
            style: TextStyle(
              fontSize: 80.sp,
              color: Theme.of(context).colorScheme.primary,
              height: 1,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'GRANDMASTER CHESS',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
