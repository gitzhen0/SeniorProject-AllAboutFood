import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iconly/iconly.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/services/auth_service.dart';
import 'package:interactive_voice_for_cooking_recipes/view/flows/flow_wrapper.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/create_account_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(String u, String p) onLogin;
  final Function() onGoogleLogin;
  final Function(TextEditingController u, TextEditingController p, TextEditingController c, String name) onAccountCreation;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onAccountCreation,
    required this.onGoogleLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isHidden = true;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            //1. add go back function to top app bar
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          AppText.login,
          style: TextStyle(
            color: Color.fromARGB(255, 10, 37, 51),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: const [
                  Text(
                    AppText.emailAddress,
                    style: TextStyle(color: Color.fromARGB(255, 10, 37, 51), fontSize: 16),
                  ),
                  Spacer(),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: username,
                // decoration: const InputDecoration(labelText: AppText.username),
                decoration: const InputDecoration(
                  hintText: AppText.emailAddressHint,
                  prefixIcon: Icon(
                    IconlyLight.message,
                    color: Color.fromARGB(255, 10, 37, 51),
                    size: 25,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Text(AppText.password, style: TextStyle(color: Color.fromARGB(255, 10, 37, 51), fontSize: 16)),
                  Spacer(),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: password,
                obscureText: _isHidden,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    IconlyLight.lock,
                    color: Color.fromARGB(255, 10, 37, 51),
                    size: 25,
                  ),

                  suffixIcon: IconButton(
                    onPressed: _togglePasswordView,
                    icon: Icon(_isHidden ? Icons.visibility : Icons.visibility_off, color: const Color.fromARGB(255, 151, 162, 176)),
                  ),
                  // labelText: AppText.password,
                  hintText: AppText.password,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    widget.onLogin(username.text, password.text);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      color: const Color.fromARGB(255, 4, 38, 40),
                    ),
                    height: 55,
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Spacer(),
                        Row(
                          children: const [
                            Spacer(),
                            Text(
                              AppText.login,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            Spacer()
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      FlowWrapper.push(
                          context,
                          CreateAccountScreen(
                            onAccountCreation: widget.onAccountCreation,
                          ));
                    },
                    child: const Text(AppText.createAccount),
                  ),
                  const SizedBox(width: 10),
                  const Text('|'),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      TextEditingController emailReset = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(AppText.forgotPassword),
                            content: TextField(
                              controller: emailReset,
                              decoration: const InputDecoration(labelText: AppText.email),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (emailReset.text.isValidEmail()) {
                                    GetIt.I<AuthService>().sendPasswordResetEmail(email: emailReset.text);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppText.anEmailHasBeenSent}${emailReset.text}. ${AppText.checkSpam}')));
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppText.invalidEmail)));
                                  }
                                },
                                child: const Text(AppText.sendPasswordEmail),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(AppText.cancel),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(AppText.forgotPassword),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),

              /// commented out until we can get google logins working in production

              // if (false)
              //   Row(
              //     children: const [
              //       Spacer(),
              //       Text(
              //         AppText.continueText2,
              //         style: TextStyle(
              //           fontSize: 17,
              //           color: Color.fromARGB(255, 151, 162, 176),
              //         ),
              //       ),
              //       Spacer(),
              //     ],
              //   ),
              // const SizedBox(
              //   height: 15,
              // ),
              // if (false)
              //   InkWell(
              //     onTap: () async {
              //       widget.onGoogleLogin();
              //     },
              //     child: Container(
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(17),
              //           color: const Color.fromARGB(255, 240, 97, 85)),
              //       height: 55,
              //       width: double.infinity,
              //       child: Column(
              //         children: [
              //           const Spacer(),
              //           Row(
              //             children: [
              //               const Spacer(),
              //               Image.asset(
              //                 'assets/icons/GoogleLogo.png',
              //                 scale: 3,
              //               ),
              //               const SizedBox(
              //                 width: 5,
              //               ),
              //               const Text(
              //                 AppText.loginWithGoogle,
              //                 style:
              //                     TextStyle(color: Colors.white, fontSize: 18),
              //               ),
              //               const Spacer()
              //             ],
              //           ),
              //           const Spacer(),
              //         ],
              //       ),
              //     ),
              //   ),
              const SizedBox(
                height: 30,
              ),

              /// Will Save Facebook Login for future release, the way to do it is not great
              // InkWell(
              //   onTap: () {
              //     //add facebook login function here
              //   },
              //   child: Container(
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(17),
              //       color: const Color.fromARGB(255, 30, 118, 214),
              //     ),
              //     height: 55,
              //     width: double.infinity,
              //     child: Column(
              //       children: [
              //         const Spacer(),
              //         Row(
              //           children: [
              //             const Spacer(),
              //             Image.asset(
              //               'assets/icons/FaceBookLogo.png',
              //               scale: 3,
              //             ),
              //             const SizedBox(
              //               width: 5,
              //             ),
              //             const Text(
              //               AppText.loginWithFacebook,
              //               style: TextStyle(color: Colors.white, fontSize: 18),
              //             ),
              //             const Spacer()
              //           ],
              //         ),
              //         const Spacer(),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}
