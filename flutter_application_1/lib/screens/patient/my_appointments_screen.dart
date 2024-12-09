import 'package:flutter/material.dart';
import '../../utils/database_helper.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  _MyAppointmentsScreenState createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final appointments = await _dbHelper.database.then((db) => db.rawQuery('''
      SELECT appointments.id, appointments.reason, schedules.date, schedules.time, users.name AS doctor_name 
      FROM appointments 
      JOIN schedules ON appointments.schedule_id = schedules.id 
      JOIN users ON schedules.doctor_id = users.id 
      WHERE appointments.patient_id = 1
    '''));
    setState(() {
      _appointments = appointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
      ),
      body: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Card(
            child: ListTile(
              title: Text('Médico: ${appointment['doctor_name']}'),
              subtitle: Text(
                '${appointment['date']} - ${appointment['time']} \nMotivo: ${appointment['reason']}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}
