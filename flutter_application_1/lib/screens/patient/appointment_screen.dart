import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/database_helper.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _availableSchedules = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAvailableSchedules();
  }

  Future<void> _fetchAvailableSchedules() async {
    final schedules = await _dbHelper.database.then((db) => db.rawQuery('''
      SELECT schedules.id, schedules.date, schedules.time, users.name AS doctor_name 
      FROM schedules 
      JOIN users ON schedules.doctor_id = users.id 
      WHERE schedules.is_booked = 0
    '''));
    setState(() {
      _availableSchedules = schedules;
    });
  }

  Future<void> _bookAppointment(int scheduleId, String doctorName, String date, String time) async {
    await _dbHelper.database.then((db) {
      db.update(
        'schedules',
        {'is_booked': 1},
        where: 'id = ?',
        whereArgs: [scheduleId],
      );
      db.insert('appointments', {
        'patient_id': 1, // Reemplaza con el ID del paciente de la sesión
        'doctor_id': scheduleId,
        'schedule_id': scheduleId,
        'reason': 'Consulta general',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cita reservada con $doctorName el $date a las $time')),
    );
    _fetchAvailableSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = _availableSchedules.where((schedule) {
      final doctorName = schedule['doctor_name']?.toLowerCase() ?? '';
      return doctorName.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Cita'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar médico',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSchedules.length,
              itemBuilder: (context, index) {
                final schedule = filteredSchedules[index];
                return Card(
                  child: ListTile(
                    title: Text(schedule['doctor_name']),
                    subtitle: Text(
                      '${schedule['date']} - ${schedule['time']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _bookAppointment(
                          schedule['id'],
                          schedule['doctor_name'],
                          schedule['date'],
                          schedule['time'],
                        );
                      },
                      child: const Text('Reservar'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
