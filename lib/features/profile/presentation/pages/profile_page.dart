import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/features/subscription/presentation/widgets/subscription_dialog.dart';
import 'package:sewingaiapp/injection_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'پروفایل',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: getIt<GetCurrentUser>().call(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100.h),
                    child: CircularProgressIndicator(color: Color(0xff3EB9B4)),
                  ),
                );
              }

              final user = snapshot.data!;
              final isPremium = user.subscription == 'premium';
              final daysRemaining = user.subDaysRemain;

              return Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.h),

                      // آیکون پروفایل
                      Center(
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 120.r,
                          color: Color(0xff3EB9B4),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // شماره تلفن
                      Text(
                        user.phoneNumber,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // کارت اطلاعات اشتراک
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Color(0xffF5F5F5),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPremium
                                      ? Icons.workspace_premium
                                      : Icons.person_outline,
                                  color: isPremium
                                      ? Color(0xffFFD700)
                                      : Color(0xff757575),
                                  size: 28.r,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'نوع اشتراک',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              isPremium ? 'اشتراک پرو' : 'اشتراک رایگان',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: isPremium
                                    ? Color(0xff3EB9B4)
                                    : Color(0xff757575),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Divider(color: Colors.grey[300]),
                            SizedBox(height: 16.h),

                            // اطلاعات اشتراک
                            if (isPremium) ...[
                              _buildInfoRow(
                                icon: Icons.calendar_today,
                                label: 'مدت باقیمانده',
                                value: '$daysRemaining روز',
                              ),
                              SizedBox(height: 12.h),
                              _buildInfoRow(
                                icon: Icons.image,
                                label: 'ارسال عکس امروز',
                                value: '${user.imageInDay} / 20',
                              ),
                            ] else ...[
                              _buildInfoRow(
                                icon: Icons.image,
                                label: 'ارسال عکس روزانه',
                                value: '${user.imageInDay} / 3',
                              ),
                              SizedBox(height: 16.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showSubscriptionDialog();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff3EB9B4),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'ارتقا به پرو',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // کارت ویژگی‌های اشتراک پرو
                      if (!isPremium) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: Color(0xffE3F2FD),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xff1976D2),
                                    size: 24.r,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'ویژگی‌های اشتراک پرو',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff1976D2),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              _buildFeatureItem('ارسال ۲۰ عکس در روز'),
                              // _buildFeatureItem('پشتیبانی اختصاصی'),
                              // _buildFeatureItem('دسترسی به آموزش‌های ویژه'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SubscriptionDialog(),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: Color(0xff757575)),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Color(0xff757575)),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xff1976D2), size: 20.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, color: Color(0xff1976D2)),
            ),
          ),
        ],
      ),
    );
  }
}
