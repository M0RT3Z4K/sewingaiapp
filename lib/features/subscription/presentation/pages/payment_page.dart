// lib/features/subscription/presentation/pages/payment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:sewingaiapp/core/utils/constants.dart' as constants;
import 'package:sewingaiapp/features/auth/domain/usecases/get_cached_token.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    setState(() {
      _isLoading = true;
    });

    // اینجا باید با API پرداخت ارتباط برقرار کنی و لینک پرداخت رو بگیری
    // مثلاً از زرین‌پال، پی‌پینگ یا هر درگاه دیگه

    // برای نمونه:
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // بعد از گرفتن لینک پرداخت، WebView رو نمایش میدی
  }

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
            icon: Icon(Icons.arrow_forward, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
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
                          _buildInfoRow(
                            'ویژگی‌ها:',
                            'ارسال عکس به تعداد نامحدود',
                          ),
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
                          onPressed: () {
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
    // فرمت کردن قیمت با کاما
    final priceInt = price;
    return priceInt.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> _processPayment(Map plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // اینجا باید با API پرداخت ارتباط برقرار کنی
      // مثلاً درخواست به زرین‌پال، پی‌پینگ یا ...

      // نمونه:
      // final response = await http.post(
      //   Uri.parse('YOUR_PAYMENT_API_URL'),
      //   body: {
      //     'amount': widget.planData['price'],
      //     'description': 'خرید اشتراک ${widget.planData['duration']} ماهه',
      //   },
      // );
      PaymentRequest _paymentRequest = PaymentRequest()
        ..setIsSandBox(
          true,
        ) // if your application is in developer mode, then set the sandBox as True otherwise set sandBox as false
        ..setMerchantID(constants.ZarinpalMerchantID)
        ..setCallbackURL(
          // "http://sewingapp.ai",
          "https://sewingaiapp.ir",
          // "https://sewingapp.liara.run/payment",
        ); //The callback can be an android scheme or a website URL, you and can pass any data with The callback for both scheme and  URL

      String? paymentUrl;
      final user = await getIt<GetCurrentUser>().call();

      _paymentRequest.setAmount(plan['price'] * 10);
      _paymentRequest.setDescription("خرید اشتراک مربی هوشمند خیاطی");
      // Call Start payment
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
          paymentUrl = paymentGatewayUri; // launch URL in browser
        }
      });

      await Future.delayed(Duration(seconds: 2));

      // فرض کنیم لینک پرداخت رو گرفتیم

      // نمایش WebView برای پرداخت
      launchUrl(Uri.parse(paymentUrl!));
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در برقراری ارتباط با درگاه پرداخت'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // void _showPaymentWebView(String url) {
  //   setState(() {
  //     _isLoading = false;
  //   });

  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => PaymentWebView(
  //         url: url,
  //         onPaymentSuccess: () {
  //           // بعد از پرداخت موفق
  //           Navigator.of(context).popUntil((route) => route.isFirst);
  //           _showSuccessDialog();
  //         },
  //         onPaymentFailed: () {
  //           // در صورت شکست پرداخت
  //           Navigator.of(context).pop();
  //           _showFailureDialog();
  //         },
  //       ),
  //     ),
  //   );
  // }

  // void _showSuccessDialog() async {
  //   GetIt getIt = GetIt.instance;
  //   await getIt<SupabaseClient>()
  //       .from('users')
  //       .update({
  //         'subscription': 'premium',
  //         'sub_days_remain': widget.planData['duration'] * 30,
  //         'image_inday': 0,
  //       })
  //       .eq('token', getIt<GetCachedToken>());
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => Directionality(
  //       textDirection: TextDirection.rtl,
  //       child: AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16.r),
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(Icons.check_circle, color: Color(0xff22A45D), size: 64.r),
  //             SizedBox(height: 16.h),
  //             Text(
  //               'پرداخت موفق',
  //               style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
  //             ),
  //             SizedBox(height: 8.h),
  //             Text(
  //               'اشتراک شما با موفقیت فعال شد.',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 14.sp, color: Color(0xff757575)),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Color(0xff3EB9B4),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8.r),
  //                 ),
  //               ),
  //               child: Text(
  //                 'متوجه شدم',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 16.sp,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showFailureDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Directionality(
  //       textDirection: TextDirection.rtl,
  //       child: AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16.r),
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(Icons.error_outline, color: Color(0xffEA3323), size: 64.r),
  //             SizedBox(height: 16.h),
  //             Text(
  //               'پرداخت ناموفق',
  //               style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
  //             ),
  //             SizedBox(height: 8.h),
  //             Text(
  //               'پرداخت شما با خطا مواجه شد. لطفاً دوباره تلاش کنید.',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 14.sp, color: Color(0xff757575)),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Color(0xff3EB9B4),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8.r),
  //                 ),
  //               ),
  //               child: Text(
  //                 'تلاش مجدد',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 16.sp,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

// WebView برای نمایش صفحه پرداخت
class PaymentWebView extends StatefulWidget {
  final String url;
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentFailed;

  const PaymentWebView({
    super.key,
    required this.url,
    required this.onPaymentSuccess,
    required this.onPaymentFailed,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onUrlChange: (change) {
            if (change.url!.contains('STATUS=OK')) {
              widget.onPaymentSuccess();
            } else if (change.url!.contains('STATUS=NOK')) {
              widget.onPaymentFailed();
            }
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });

            // چک کردن URL برای تشخیص موفقیت یا شکست پرداخت
            if (url.contains('STATUS=OK')) {
              widget.onPaymentSuccess();
            } else if (url.contains('STATUS=NOK')) {
              widget.onPaymentFailed();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('پرداخت'), backgroundColor: Color(0xff3EB9B4)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Color(0xff3EB9B4))),
        ],
      ),
    );
  }
}
