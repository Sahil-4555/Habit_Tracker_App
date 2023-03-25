import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:habit_tracker/components/month_summary.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:habit_tracker/screens/show_user_data.dart';
import 'package:habit_tracker/screens/welcome_screen.dart';
import 'package:habit_tracker/services/auth_provider.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../components/my_alert_box.dart';
import '../components/next_screen.dart';
import 'habit_tile.dart';
import '../components/my_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

  @override
  void initState() {
    // if there is no current habit list, then it is the 1st time ever opening the app
    // then current default data
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    }
    // there is already exists data, this is not the first time
    else {
      db.loadData();
    }

    // update the database
    db.updateDatabase();
    super.initState();
  }

  // checkbox was tapped
  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todayHabitList[index][1] = value;
    });
    // update the database
    db.updateDatabase();
  }

  //create a new habit
  final _newHabitNameController = TextEditingController();
  void createNewHabit() {
    //show alert dialog for user to enter new habit details
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          hintText: 'Enter Habit Name..',
          controller: _newHabitNameController,
          onSave: saveNewHabit,
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  // Save New Habit
  void saveNewHabit() {
    //add new habit to todays habit list
    setState(() {
      db.todayHabitList.add([_newHabitNameController.text, false]);
    });

    // Clear text-field
    _newHabitNameController.clear();
    // pop dialog box
    Navigator.of(context).pop();

    // update the database
    db.updateDatabase();
  }

  // Cancel New Habit
  void cancelDialogBox() {
    // Clear textfield
    _newHabitNameController.clear();
    // pop dialog box
    Navigator.of(context).pop();
  }

  // Open Habit Setting to Edit
  void openHabitSettings(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          hintText: db.todayHabitList[index][0],
          onSave: () => saveExistingHabit(index),
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  // save existing habit with a new name
  void saveExistingHabit(int index) {
    setState(() {
      db.todayHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    Navigator.pop(context);
    // update the database
    db.updateDatabase();
  }

  // delete habit
  void deleteHabit(int index) {
    setState(() {
      db.todayHabitList.removeAt(index);
    });
    // update the database
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.grey[300],
        floatingActionButton: MyFloatingActionButton(
          onPressed: createNewHabit,
        ),
        // appBar: AppBar(
        //   backgroundColor: Colors.purple,
        //   title: const Text('Habit Tracker App'),
        //   actions: [
        //     IconButton(
        //       onPressed: () async {
        //         auth_prov.userSignOut().then(
        //               (value) => Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                   builder: (context) => const WelcomeScreen(),
        //                 ),
        //               ),
        //             );
        //       },
        //       icon: const Icon(Icons.exit_to_app),
        //     ),
        //   ],
        // ),
        //   body: Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         CircleAvatar(
        //           backgroundColor: Colors.purple,
        //           backgroundImage: NetworkImage(auth_prov.userModel.profilePic),
        //           radius: 50,
        //         ),
        //         const SizedBox(height: 20),
        //         Text(auth_prov.userModel.name),
        //         Text(auth_prov.userModel.phoneNumber),
        //         Text(auth_prov.userModel.email),
        //         Text(auth_prov.userModel.bio),
        //       ],
        //     ),
        //   ),
        // );
        // }
        body: ListView(
          children: [
            // Monthly Summary Heat Map
            MonthlySummary(
                datasets: db.heatMapDataSet,
                startDate: _myBox.get("START_DATE")),
            // List of Habits
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: db.todayHabitList.length,
              itemBuilder: (context, index) {
                return HabitTile(
                  habitName: db.todayHabitList[index][0],
                  habitCompleted: db.todayHabitList[index][1],
                  onChanged: (value) => checkBoxTapped(value, index),
                  settingsTapped: (context) => openHabitSettings(index),
                  deleteTapped: (context) => deleteHabit(index),
                );
              },
            ),
          ],
        ),
      bottomNavigationBar: Container(
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: GNav(
            backgroundColor: Colors.green,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.greenAccent,
            gap: 8,
            selectedIndex: 0,
            padding: const EdgeInsets.all(5),
            tabs: [
              GButton(
                icon: Icons.home,
                text: "home",
                onPressed: () {
                  nextScreen(context, const HomeScreen());
                },
              ),
              GButton(
                icon: Icons.person,
                text: "favorite",
                onPressed: () {
                  nextScreen(context, const UserDetails());
                },
              ),
              const GButton(
                icon: Icons.settings,
                text: "settings",
              ),
              const GButton(
                icon: Icons.search,
                text: "search",
              ),
            ],
          ),
        ),
      ),
    );

  }
}
