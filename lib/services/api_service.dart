import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_data.dart';

class ApiService {
  // Busca o baseUrl salvo pelo usuário ou retorna o padrão
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('baseUrl') ?? 'http://localhost:3000';
  }

  Future<DashboardData> fetchDashboardData() async {
    final baseUrl = await getBaseUrl();
    final response = await http.get(Uri.parse('$baseUrl/dashboard'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DashboardData(
        totalPiecesToday: data['totalPiecesToday'],
        successRate: (data['successRate'] as num).toDouble(),
        activeAlerts: data['activeAlerts'],
        productionByHour: (data['productionByHour'] as List)
            .map((e) => ProductionByHour(hour: e['hour'], count: e['count']))
            .toList(),
        productionByDestination: (data['productionByDestination'] as List)
            .map((e) => ProductionByDestination(destination: e['destination'], count: e['count']))
            .toList(),
        recentActivities: (data['recentActivities'] as List)
            .map((e) => RecentActivity(
                  timestamp: DateTime.parse(e['data_hora']),
                  operation: e['operation'],
                  status: e['status'],
                  pieceType: e['tipo_peca'],
                  destination: e['destination'],
                ))
            .toList(),
      );
    } else {
      throw Exception('Erro ao buscar dados do dashboard');
    }
  }
}
