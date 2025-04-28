import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Colors/App_Colors.dart';
import '../Controller/Auth_Controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _SignUpState();
}

class _SignUpState extends State<AuthScreen> {
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body:Container(
        width: double.infinity,
        height: double.infinity,
        decoration:  BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [Color(0xFF2196F3), Color(0xFF90CAF9)],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16,right: 22,top: 80),
          child: SingleChildScrollView(
            child: Column(
                      children: [
                        SizedBox(height: height * 0.2),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                              border: Border.all(width: 1,color: Colors.grey),
                              color: ColorConst.white.withAlpha((0.95 * 255).toInt()),
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
                                        "For your security, please enter security code.",
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
                                  keyboardType: TextInputType.text,
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
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF2196F3), Color(0xFF90CAF9)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(10))
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

    );
  }
}
