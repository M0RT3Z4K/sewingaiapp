// lib/features/subscription/presentation/pages/payment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewingaiapp/core/utils/constants.dart' as constants;
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zarinpal/zarinpal.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> planData;

  const PaymentPage({super.key, required this.planData});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final duration = widget.planData['duration'];
    final price = widget.planData['price'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'پرداخت',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xff3EB9B4)))
            : Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اطلاعات خرید
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Color(0xffF5F5F5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'جزئیات خرید',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildInfoRow('محصول:', 'اشتراک پرو $duration ماهه'),
                          SizedBox(height: 12.h),
                          _buildInfoRow('ویژگی‌ها:', 'ارسال ۲۰ عکس در روز'),
                          SizedBox(height: 12.h),
                          Divider(),
                          SizedBox(height: 12.h),
                          _buildInfoRow(
                            'مبلغ قابل پرداخت:',
                            '${_formatPrice(price)} تومان',
                            isPrice: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // توضیحات
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Color(0xffE3F2FD),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xff1976D2),
                            size: 24.r,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'پس از پرداخت موفق، اشتراک شما فوراً فعال خواهد شد.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Color(0xff1976D2),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Spacer(),

                    // دکمه پرداخت
                    Padding(
                      padding: EdgeInsets.only(bottom: 30.w),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  _processPayment(widget.planData);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff3EB9B4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'ادامه خرید',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Color(0xff757575)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrice ? 18.sp : 14.sp,
            fontWeight: isPrice ? FontWeight.w700 : FontWeight.w500,
            color: isPrice ? Color(0xff3EB9B4) : Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> _processPayment(Map plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      PaymentRequest _paymentRequest = PaymentRequest()
        ..setIsSandBox(false)
        ..setMerchantID(constants.ZarinpalMerchantID)
        ..setCallbackURL("https://sewingaiapp.ir");

      String? paymentUrl;
      final user = await getIt<GetCurrentUser>().call();

      _paymentRequest.setAmount(plan['price'] * 10);
      _paymentRequest.setDescription("خرید اشتراک مربی هوشمند خیاطی");

      ZarinPal().startPayment(_paymentRequest, (
        status,
        paymentGatewayUri,
        data,
      ) async {
        if (status == 100) {
          await getIt<SupabaseClient>()
              .from("users")
              .update({
                "payment_authority": _paymentRequest.authority,
                "payment_amount": _paymentRequest.amount,
                "payment_status": "NOK",
              })
              .eq("token", user.token);
          paymentUrl = paymentGatewayUri;
        }
      });

      await Future.delayed(Duration(seconds: 2));

      if (paymentUrl != null) {
        // باز کردن لینک پرداخت
        await launchUrl(Uri.parse(paymentUrl!));

        // بستن صفحه پرداخت و برگشت به چت
        // deep link بعداً کاربر رو به پروفایل هدایت می‌کنه
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Directionality(
                textDirection: TextDirection.rtl,
                child: Text('خطا در ایجاد درخواست پرداخت'),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text('خطا در برقراری ارتباط با درگاه پرداخت'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
