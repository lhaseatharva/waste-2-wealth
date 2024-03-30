import 'package:flutter/material.dart';

class ManagePickupSchedule extends StatefulWidget {
  const ManagePickupSchedule({Key? key}) : super(key: key);

  @override
  _ManagePickupScheduleState createState() => _ManagePickupScheduleState();
}

class _ManagePickupScheduleState extends State<ManagePickupSchedule> {
  late Map<String, dynamic> schedule = {};

  @override
  void initState() {
    super.initState();
    fetchUserSchedule();
  }

  Future<void> fetchUserSchedule() async {
    // Dummy data for demonstration
    schedule = {
      'Monday': true,
      'Tuesday': false,
      'Wednesday': true,
      'Thursday': false,
      'Friday': true,
      'Saturday': false,
      'Sunday': true,
    };
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Pickup Schedule'),
        backgroundColor: Colors.lightGreen.shade200,
      ),
      body: schedule.isNotEmpty
          ? ListView.builder(
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final day = schedule.keys.elementAt(index);
                return ListTile(
                  title: Text(day),
                  subtitle: DropdownButtonFormField<String>(
                    value: schedule[day].toString(),
                    items: [
                      DropdownMenuItem(value: 'true', child: Text('True')),
                      DropdownMenuItem(value: 'false', child: Text('False')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        schedule[day] = value == 'true';
                      });
                    },
                  ),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveUserSchedule();
        },
        child: Icon(Icons.save),
      ),
    );
  }

  void saveUserSchedule() {
    // Implement your saving logic here
    // For dummy data, just print the schedule
    print(schedule);
  }
}

void main() {
  runApp(MaterialApp(
    home: ManagePickupSchedule(),
  ));
}
