import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/database_helper.dart';

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({Key? key}) : super(key: key);

  @override
  _ManageScheduleScreenState createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    final schedules = await _dbHelper.database.then((db) => db.rawQuery('''
      SELECT id, date, time, is_booked 
      FROM schedules 
      WHERE doctor_id = 1
    '''));
    setState(() {
      _schedules = schedules;
    });
  }

  Future<void> _addSchedule() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final scheduleDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        await _dbHelper.database.then((db) => db.insert('schedules', {
              'doctor_id': 1, // Cambiar por el ID del médico desde la sesión
              'date': DateFormat('yyyy-MM-dd').format(scheduleDateTime),
              'time': DateFormat('HH:mm').format(scheduleDateTime),
              'is_booked': 0,
            }));
        _fetchSchedules();
      }
    }
  }

  Future<void> _deleteSchedule(int id) async {
    await _dbHelper.database.then((db) => db.delete('schedules', where: 'id = ?', whereArgs: [id]));
    _fetchSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Horarios'),
      ),
      body: ListView.builder(
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          final isBooked = schedule['is_booked'] == 1;

          return Card(
            color: isBooked ? Colors.red.shade100 : Colors.green.shade100,
            child: ListTile(
              title: Text(
                '${schedule['date']} - ${schedule['time']}',
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: isBooked
                  ? const Text('Reservado', style: TextStyle(color: Colors.red))
                  : const Text('Disponible', style: TextStyle(color: Colors.green)),
              trailing: isBooked
                  ? const Icon(Icons.notifications, color: Colors.red)
                  : IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSchedule(schedule['id']),
                    ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }
}
