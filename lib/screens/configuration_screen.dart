// lib/screens/configuration_screen.dart
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';

class ConfigurationScreen extends StatefulWidget {
  static const routeName = '/configuration';
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _savedBaseUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedBaseUrl = prefs.getString('baseUrl') ?? 'http://localhost:3000';
      _controller.text = _savedBaseUrl!;
      _loading = false;
    });
  }

  Future<void> _saveBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', _controller.text.trim());
    setState(() {
      _savedBaseUrl = _controller.text.trim();
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Endereço da API salvo com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração da Conexão'),
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  Text(
                    'Conexão com o Backend (API REST)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Este aplicativo está configurado para se comunicar com um backend REST (Node.js + MySQL).',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: 'Endereço da API (baseUrl)',
                              prefixIcon: Icon(Icons.link),
                              border: OutlineInputBorder(),
                              hintText: 'Ex: http://192.168.0.100:3000',
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            onPressed: _saveBaseUrl,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Endereço atual salvo: ${_savedBaseUrl ?? "-"}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Icon(
                      Icons.cloud_done_outlined,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
