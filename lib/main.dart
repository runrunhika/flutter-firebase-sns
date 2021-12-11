import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_sns_app/view/start_up/login_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

// class LoginCheck extends StatefulWidget {
//   const LoginCheck({Key? key}) : super(key: key);

//   @override
//   _LoginCheckState createState() => _LoginCheckState();
// }

// class _LoginCheckState extends State<LoginCheck> {
//   void checkUser() async {
//     final currentUser = await FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => LoginPage()));
//     } else {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => Screen()));
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     checkUser();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(child: Text("Error")),
//     );
//   }
// }
