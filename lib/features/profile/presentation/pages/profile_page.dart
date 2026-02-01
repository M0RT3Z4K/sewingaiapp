import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/injection_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getIt<GetCurrentUser>().call(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50.h),
              Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 150.r,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                snapshot.data!.phoneNumber,
                style: TextStyle(fontSize: 18.sp),
              ),
            ],
          );
        },
      ),
    );
  }
}
