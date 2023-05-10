import 'package:flutter/material.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:iconly/iconly.dart';

class CreateAccountScreen extends StatefulWidget {
  final Function(TextEditingController u, TextEditingController p, TextEditingController c, String name) onAccountCreation;

  const CreateAccountScreen({super.key, required this.onAccountCreation});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _isHidden = true;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            //1. add go back function to top app bar
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          AppText.createAccount,
          style: TextStyle(color: Color.fromARGB(255, 10, 37, 51), fontWeight: FontWeight.bold),
        ),
      ),
      // appBar: AppBar(title: const Text(AppText.createAccount)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: const [
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      AppText.firstName,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    // Spacer()
                  ],
                ),
                const SizedBox(
                  height: 7,
                ),
                TextField(
                  controller: fname,
                  decoration: const InputDecoration(
                      // isDense: true,
                      // contentPadding: EdgeInsets.fromLTRB(15, 30, 15, 0),
                      prefixIcon: Icon(
                        IconlyLight.profile,
                        color: Color.fromARGB(255, 10, 37, 51),
                        size: 25,
                      ),
                      hintText: AppText.firstName),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  AppText.lastName,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 7,
                ),
                TextField(
                  controller: lname,
                  decoration: const InputDecoration(
                      // isDense: true,
                      // contentPadding: EdgeInsets.fromLTRB(15, 30, 15, 0),
                      prefixIcon: Icon(
                        IconlyLight.profile,
                        color: Color.fromARGB(255, 10, 37, 51),
                        size: 25,
                      ),
                      hintText: AppText.lastName),
                ),
              ]),
              const SizedBox(
                height: 20,
              ),
              //Email line-------------------------------------------------
              Row(
                children: const [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppText.emailAddress,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Spacer()
                ],
              ),
              const SizedBox(
                height: 7,
              ),

              TextField(
                controller: username,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    IconlyLight.message,
                    color: Color.fromARGB(255, 10, 37, 51),
                    size: 25,
                  ),
                  // labelText: AppText.username,
                  hintText: AppText.emailAddressHint,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //Password line-------------------------------------------------
              Row(
                children: const [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppText.password,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Spacer()
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              // const SizedBox(height: 20),
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

//-----------confirm password starts here-----------------------
              const SizedBox(
                height: 20,
              ),
              Row(
                children: const [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppText.confirmPassword,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Spacer()
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              // const SizedBox(height: 20),
              TextField(
                controller: confirmPassword,
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
                  hintText: AppText.confirmPassword,
                ),
              ),

              // const SizedBox(height: 20),
              // TextField(
              //   controller: confirmPassword,
              //   obscureText: true,
              //   enableSuggestions: false,
              //   autocorrect: false,
              //   decoration:
              //       const InputDecoration(labelText: AppText.confirmPassword),
              // ),
              const SizedBox(height: 40),

              InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    widget.onAccountCreation(username, password, confirmPassword, '$fname $lname');
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
                              AppText.createAccount,
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            Spacer()
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  )),

              // ElevatedButton(
              //   onPressed: () async {
              //     widget.onAccountCreation(username, password, confirmPassword);
              //   },
              //   child: const Text(AppText.createAccount),
              // ),

              const SizedBox(
                height: 20,
              ),
              const Text(
                AppText.continueText,
                style: TextStyle(
                  color: Color.fromARGB(255, 10, 37, 51),
                ),
              ),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, padding: const EdgeInsets.fromLTRB(0, 0, 0, 0)),
                    child: const Text(
                      AppText.termsOfService,
                      style: TextStyle(
                        color: Color.fromARGB(255, 10, 37, 51),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Text(
                    " & ",
                    style: TextStyle(
                      color: Color.fromARGB(255, 10, 37, 51),
                      // fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, padding: const EdgeInsets.fromLTRB(0, 0, 0, 0)),
                    child: const Text(
                      AppText.privacyPolicy,
                      style: TextStyle(
                        color: Color.fromARGB(255, 10, 37, 51),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer()
                ],
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
