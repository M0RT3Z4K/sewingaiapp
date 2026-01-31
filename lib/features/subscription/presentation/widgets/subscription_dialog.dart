// lib/features/subscription/presentation/widgets/subscription_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionDialog extends StatefulWidget {
  const SubscriptionDialog({super.key});

  @override
  State<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {
  int _selectedPlan = 1; // پیش‌فرض پلن 6 ماهه (index 1)

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // عنوان
              Text(
                'برای ارسال بیشتر از ۳ عکس روزانه، باید اشتراک پرو را خریداری نمایید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),

              // پلن 3 ماهه
              _buildPlanCard(
                index: 0,
                duration: '۳',
                price: '۱۳۰,۰۰۰',
                description: 'ارسال عکس به تعداد نامحدود',
              ),
              SizedBox(height: 12.h),

              // پلن 6 ماهه (پیشنهادی)
              _buildPlanCard(
                index: 1,
                duration: '۶',
                price: '۲۲۰,۰۰۰',
                description: 'ارسال عکس به تعداد نامحدود',
                isRecommended: true,
              ),
              SizedBox(height: 12.h),

              // پلن 12 ماهه
              _buildPlanCard(
                index: 2,
                duration: '۱۲',
                price: '۴۲۰,۰۰۰',
                description: 'ارسال عکس به تعداد نامحدود',
              ),
              SizedBox(height: 20.h),

              // دکمه‌ها
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'بستن',
                        style: TextStyle(
                          color: Color(0xff757575),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // بستن دیالوگ و رفتن به صفحه پرداخت
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          '/payment',
                          arguments: {
                            'planIndex': _selectedPlan,
                            'duration': _selectedPlan == 0
                                ? 3
                                : _selectedPlan == 1
                                ? 6
                                : 12,
                            'price': _selectedPlan == 0
                                ? 130000
                                : _selectedPlan == 1
                                ? 220000
                                : 420000,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff3EB9B4),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'خرید',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String duration,
    required String price,
    required String description,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedPlan == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff3EB9B4).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xff3EB9B4) : Color(0xffE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // نمبر پلن
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xff3EB9B4) : Color(0xffF5F5F5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  duration,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // جزئیات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'اشتراک پرو $duration ماهه',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isRecommended) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xff22A45D),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'پیشنهادی',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12.sp, color: Color(0xff757575)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$price تومان',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff3EB9B4),
                    ),
                  ),
                ],
              ),
            ),

            // Radio button
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xff3EB9B4) : Color(0xffBDBDBD),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff3EB9B4),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
