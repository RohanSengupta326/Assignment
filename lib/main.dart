/* 
I am writing to provide an update on the task I was assigned during the final round of the 
interview process at Realtime Innovations for the Flutter developer position.

When I received the task, I realized that it required working with two new technologies, Bloc
 and Sqflite. Understanding the importance of these tools in Flutter development, I decided to
  invest time in learning and familiarizing myself with them before proceeding with the task.

Over the course of the next five days, I dedicated myself to studying Bloc and Sqflite, 
thoroughly exploring their functionalities and best practices. While I had to cover a lot of 
ground within a short span of time, I believe I have successfully grasped the fundamental 
concepts and acquired a working knowledge of both technologies.

Despite the time constraints, I strived to complete the task to the best of my abilities.
 I focused on implementing the basic necessities outlined in the requirements, aiming to
  demonstrate my understanding of Flutter development principles and showcase my 
  problem-solving skills. However, due to the limited timeframe and the learning curve
   associated with Bloc and Sqflite, I acknowledge that there may be areas in the app 
   that could be further improved.

I genuinely appreciate the opportunity you have given me to showcase my skills and learn new
 technologies in the process. Working on this task has been a valuable experience that has
 strengthened my Flutter development skills, and I am grateful for the chance to grow as a 
 developer.

 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee_bloc.dart';
import '/database_helper.dart';
import './models/employee.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    BlocProvider<EmployeeBloc>(
      create: (context) => EmployeeBloc(DatabaseHelper.instance),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DatabaseHelper databaseHelper;
  late EmployeeBloc employeeBloc;

  @override
  void initState() {
    super.initState();

    employeeBloc = BlocProvider.of<EmployeeBloc>(context);
    employeeBloc.add(FetchEmployeesEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final employeeBloc = BlocProvider.of<EmployeeBloc>(context);
    log('EmployeeBloc instance: $employeeBloc');
    employeeBloc.add(FetchEmployeesEvent());
  }

  @override
  void dispose() {
    employeeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmployeeBloc>(
      create: (context) => employeeBloc..add(FetchEmployeesEvent()),
      child: MaterialApp(
        title: 'Employee App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log('HomePage build method called');
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
      ),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state.employees.isEmpty) {
            return Center(child: Text('Nothing to show.'));
          }
          return ListView.builder(
            itemCount: state.employees.length,
            itemBuilder: (context, index) {
              final employee = state.employees[index];
              return Dismissible(
                key: Key(employee.startDate.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  // Delete the employee from the database and update the state
                  final deletedEmployee = state.employees[index];
                  BlocProvider.of<EmployeeBloc>(context)
                      .add(DeleteEmployeeEvent(deletedEmployee));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Employee deleted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        employee.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Text(employee.jobRole),
                      trailing: Text(DateFormat('dd, MMM, yyyy')
                          .format(employee.startDate)),
                    ),
                    Divider(),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEmployeePage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddEmployeePage extends StatefulWidget {
  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobRoleController = TextEditingController();
  DateTime? selectedStartDate;
  DateTime? selectedExitDate;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectExitDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedExitDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Employee'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Employee Name'),
            ),
            TextField(
              controller: jobRoleController,
              decoration: InputDecoration(labelText: 'Job Role'),
            ),
            InkWell(
              onTap: () => _selectStartDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Starting Date',
                ),
                child: Text(
                  selectedStartDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedStartDate!)
                      : 'Select starting date',
                ),
              ),
            ),
            InkWell(
              onTap: () => _selectExitDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Exit Date',
                ),
                child: Text(
                  selectedExitDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedExitDate!)
                      : 'Select exit date',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final employee = Employee(
                  name: nameController.text,
                  jobRole: jobRoleController.text,
                  startDate: selectedStartDate ?? DateTime.now(),
                  exitDate: selectedExitDate ?? DateTime.now(),
                );
                BlocProvider.of<EmployeeBloc>(context)
                    .add(AddEmployeeEvent(employee));
                Navigator.pop(context);
              },
              child: Text('Add Employee'),
            ),
          ],
        ),
      ),
    );
  }
}
