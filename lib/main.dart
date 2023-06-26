import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mapping_project/home.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController mailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.15,),
              Container(
                  margin: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  child: const Text("WELCOME",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)
                    ,)
              ),
              Container(
                margin: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.grey, //New
                        blurRadius: 25.0,
                        offset: Offset(10, -10)
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40,),
                    MailField(controller: mailController),
                    PassField(controller: passController,),
                    const SizedBox(height: 100,),
                    InkWell(
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width*0.3,
                        height: MediaQuery.of(context).size.height*0.05,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: const Text("Login",style: TextStyle(color: Colors.white,fontSize: 20),),
                      ),
                      onTap: () async{

                        var mail = mailController.text.toString();
                        var pass = passController.text.toString();

                        try {
                          final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: mail,
                            password: pass,
                          );

                          Navigator.of(context).push(MaterialPageRoute(builder: (builder) => Home(mail: mail,)));

                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'email-already-in-use') {
                            final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: mail,
                              password: pass,
                            );

                            Navigator.of(context).push(MaterialPageRoute(builder: (builder) => Home(mail: mail,)));
                          } else {
                            AwesomeDialog(
                                context: context,
                                dialogType: DialogType.info,
                                animType: AnimType.rightSlide,
                                title: e.code,
                            ).show();
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MailField extends StatelessWidget {

  TextEditingController controller;

  MailField({
    super.key,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade300
      ),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.orange,
        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.person,color: Colors.orange),
        ),
      ),
    );
  }
}

class PassField extends StatefulWidget {
  TextEditingController controller;
  PassField({Key? key,required this.controller}) : super(key: key);

  @override
  State<PassField> createState() => _PassFieldState();
}

class _PassFieldState extends State<PassField> {
  bool pass = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade300
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: pass,
        cursorColor: Colors.orange,
        decoration: InputDecoration(
            border: InputBorder.none,
            icon: const Icon(Icons.key,color: Colors.orange),
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    pass = !pass;
                  });
                },
                icon: pass? const Icon(Icons.visibility_off,color: Colors.orange,) : const Icon(Icons.visibility,color: Colors.orange,)
            )
        ),
      ),
    );
  }
}