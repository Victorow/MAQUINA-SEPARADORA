// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import './dashboard_screen.dart'; // <-- ADD THIS IMPORT

class AboutScreen extends StatelessWidget {
  static const routeName = '/about';
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estação Separadora de Peças - Sobre'),
        backgroundColor: Colors.blue[800],
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                 Navigator.pop(context);
              } else {
                // If it's the first screen, navigate to dashboard
                Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
              }
            },
            child: const Text('Voltar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Placeholder for SENAI Logo - you'd use Image.asset or Image.network
                  Container(
                    width: 200,
                    height: 80,
                    color: Colors.red, // Placeholder color
                    alignment: Alignment.center,
                    child: const Text(
                      'SENAI',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Projeto Integrador - Estação Separadora de Peças',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Desenvolvedores:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Victor Augusto Ferreira dos Santos'),
                  const Text('Lucas Boroto'),
                  const Text('Allan Gabriel'),
                  const Text('Ana Julia Oliveira'),
                  const SizedBox(height: 16),
                  const Text(
                    'Informações do Projeto:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Turma: 3 ADS'),
                  const Text('Escola: Faculdade SENAI Taubaté Félix Guisard'),
                  const Text('Período de Desenvolvimento: 26 de fevereiro até 11 de abril de 2025'),
                  const SizedBox(height: 30),
                  const Text(
                    '© 2025 - Todos os direitos reservados',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}