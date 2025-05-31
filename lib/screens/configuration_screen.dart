// lib/screens/configuration_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
// Importe seu main.dart se quiser acessar supabaseUrl, ou coloque supabaseUrl em um arquivo de config separado.
// import '../main.dart'; // Exemplo se supabaseUrl estivesse acessível de main.dart

class ConfigurationScreen extends StatelessWidget {
  // Mudado para StatelessWidget
  static const routeName = '/configuration';
  const ConfigurationScreen({super.key});

  // Se você tornou supabaseUrl acessível (ex: importando de um arquivo de config ou main.dart)
  // final String currentSupabaseUrl = supabaseUrl; // Exemplo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração da Conexão'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // Usando ListView para manter a estrutura, caso queira adicionar mais itens depois
          children: <Widget>[
            Text(
              'Conexão com o Banco de Dados',
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
                    Text(
                      'Este aplicativo está configurado para usar o Supabase como provedor de banco de dados na nuvem.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    // Se você tornar supabaseUrl acessível, pode exibi-la:
                    // Row(
                    //   children: [
                    //     const Icon(Icons.link, color: Colors.grey),
                    //     const SizedBox(width: 8),
                    //     Expanded(
                    //       child: Text(
                    //         'URL do Projeto: $currentSupabaseUrl', // Necessário importar ou passar a URL
                    //         style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 10),
                    const Text(
                      'As credenciais de conexão (URL e Chave Anon) são definidas no código-fonte (main.dart) e não são configuráveis através desta interface para o Supabase.',
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            // Você pode adicionar outras configurações do aplicativo aqui no futuro,
            // que não sejam relacionadas à conexão direta do banco Supabase.
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
