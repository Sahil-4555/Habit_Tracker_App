import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/welcome_screen.dart';
import 'package:habit_tracker/services/auth_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth_prov = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Habit Tracker App'),
        actions: [
          IconButton(
            onPressed: () async {
              auth_prov.userSignOut().then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomeScreen(),),
                    ),
                  );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple,
              backgroundImage: NetworkImage(auth_prov.userModel.profilePic),
              radius: 50,
            ),
            const SizedBox(height: 20),
            Text(auth_prov.userModel.name),
            Text(auth_prov.userModel.phoneNumber),
            Text(auth_prov.userModel.email),
            Text(auth_prov.userModel.bio),
          ],
        ),
      ),
    );
  }
}
