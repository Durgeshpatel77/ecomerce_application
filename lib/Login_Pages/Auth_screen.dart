import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../All_custom_widgets/BackGround_Custom.dart';
import '../Colors/App_Colors.dart';
import '../Controller/Auth_Controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthController authController = Get.put(AuthController());
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          CustomScaffoldForLogin(width: double.infinity, height: double.infinity),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.10),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.2),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: ColorConst.white.withOpacity(0.95),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Color(0xffe1e7ff),
                              radius: 25,
                              child: Icon(Icons.lock, color: Colors.blue),
                            ),
                            title: Text(
                              "Security Verification",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                            subtitle: Text(
                              "Complete verification to continue",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(7),
                                    bottomLeft: Radius.circular(7),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color(0xffeef2fe),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(7),
                                      bottomRight: Radius.circular(7),
                                    ),
                                  ),
                                  child: Text(
                                    "For your security, please enter 6-digit security code.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text("6-Digit Security Code"),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 45,
                            child: TextField(
                              controller: authController.codeController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                hintText: '. . . . . .',
                                hintStyle: TextStyle(fontSize: 26),
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                counterText: '',
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          Obx(() => authController.isLoading.value
                              ? Center(child: CircularProgressIndicator())
                              : InkWell(
                            onTap: () {
                              authController.loginApi();
                            },
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xff5843e6),
                                    Color(0xff8a36ea),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.verified_outlined,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " Verify & Continue",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
