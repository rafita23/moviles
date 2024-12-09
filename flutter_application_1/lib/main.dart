import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/doctor/manage_schedule_screen.dart';
import 'screens/patient/appointment_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Citas Médicas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/patient_dashboard': (context) => const PatientDashboard(),
        '/doctor_dashboard': (context) => const DoctorDashboard(),
        '/manage_schedule': (context) => const ManageScheduleScreen(),
        '/appointment_screen': (context) => const AppointmentScreen(),
      },
    );
  }
}
