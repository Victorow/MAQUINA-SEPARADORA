// lib/services/db_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart'; // Descomente se precisar de DateFormat em algum lugar aqui
import '../models/dashboard_data.dart';

void _log(String message) {
  // ignore: avoid_print
  print('[DbService] $message');
}

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  Future<int> _fetchTotalPiecesToday() async {
    _log('RPC: get_total_pieces_today');
    try {
      final dynamic result = await _client.rpc('get_total_pieces_today');
      _log('RPC Result (get_total_pieces_today): $result');
      return (result is int) ? result : (int.tryParse(result.toString()) ?? 0);
    } catch (e, s) {
      _log('Error RPC get_total_pieces_today: $e\nStackTrace: $s');
      return 0;
    }
  }

  Future<List<ProductionByHour>> _fetchProductionByHourToday() async {
    _log('RPC: get_production_by_hour_today');
    try {
      final List<dynamic> results =
          await _client.rpc('get_production_by_hour_today');
      _log(
          'RPC Result (get_production_by_hour_today): ${results.length} rows.');
      return results.map((row) {
        return ProductionByHour(
          hour: row['hour'] as int? ?? 0,
          count: row['count'] as int? ?? 0,
        );
      }).toList();
    } catch (e, s) {
      _log('Error RPC get_production_by_hour_today: $e\nStackTrace: $s');
      return [];
    }
  }

  Future<List<ProductionByDestination>>
      _fetchProductionByDestinationToday() async {
    _log('RPC: get_production_by_destination_today');
    try {
      final List<dynamic> results =
          await _client.rpc('get_production_by_destination_today');
      _log(
          'RPC Result (get_production_by_destination_today): ${results.length} rows.');
      return results.map((row) {
        return ProductionByDestination(
          destination: row['material_name'] as String? ?? 'Desconhecido',
          count: row['item_count'] as int? ?? 0,
        );
      }).toList();
    } catch (e, s) {
      _log('Error RPC get_production_by_destination_today: $e\nStackTrace: $s');
      return [];
    }
  }

  Future<List<RecentActivity>> _fetchRecentActivities() async {
    _log('RPC: get_recent_activities');
    try {
      final List<dynamic> results = await _client.rpc('get_recent_activities');
      _log('RPC Result (get_recent_activities): ${results.length} rows.');
      return results.map((row) {
        DateTime timestamp;
        var dataHoraValue = row['data_hora_val'];
        if (dataHoraValue is String) {
          timestamp = DateTime.tryParse(dataHoraValue) ?? DateTime.now();
        } else {
          timestamp = DateTime.now();
          _log(
              "Timestamp em formato inesperado para RecentActivity: $dataHoraValue, usando DateTime.now()");
        }

        String material = row['material_val'] as String? ?? 'N/A';
        String tamanho = row['tamanho_val'] as String? ?? 'N/A';
        String type = "$material $tamanho";

        String status = "Concluída";
        int hash = material.hashCode + tamanho.hashCode + timestamp.second;
        if (hash % 7 == 0) status = "Em Progresso";
        if (hash % 13 == 0) status = "Erro";

        return RecentActivity(
          timestamp: timestamp,
          operation: "Separação",
          status: status,
          pieceType: type,
          destination: "Esteira $material",
        );
      }).toList();
    } catch (e, s) {
      _log('Error RPC get_recent_activities: $e\nStackTrace: $s');
      return [];
    }
  }

  Future<double> _fetchSuccessRateToday() async {
    _log('RPC: get_success_rate_today');
    try {
      final dynamic result = await _client.rpc('get_success_rate_today');
      _log('RPC Result (get_success_rate_today): $result');
      if (result != null) {
        if (result is double) {
          return result;
        }
        if (result is int) {
          return result.toDouble();
        }
        return double.tryParse(result.toString()) ?? 0.0;
      }
      return 0.0;
    } catch (e, s) {
      _log('Error RPC get_success_rate_today: $e\nStackTrace: $s');
      return 0.0;
    }
  }

  // NOVO MÉTODO PARA BUSCAR A CONTAGEM DE ALERTAS ATIVOS
  Future<int> _fetchActiveAlertsCount() async {
    _log('RPC: get_active_alerts_count');
    try {
      final dynamic result = await _client.rpc('get_active_alerts_count');
      _log('RPC Result (get_active_alerts_count): $result');
      // A função get_active_alerts_count retorna INTEGER, então o cast para int deve ser seguro.
      return (result is int) ? result : (int.tryParse(result.toString()) ?? 0);
    } catch (e, s) {
      _log('Error RPC get_active_alerts_count: $e\nStackTrace: $s');
      return 0; // Retorna 0 em caso de erro
    }
  }

  Future<DashboardData> getDashboardData() async {
    _log(
        'getDashboardData: Iniciando busca de dados com Supabase (via RPC)...');

    // int activeAlerts = 3; // VALOR MOCKADO REMOVIDO

    try {
      final results = await Future.wait([
        _fetchTotalPiecesToday(),
        _fetchProductionByHourToday(),
        _fetchProductionByDestinationToday(),
        _fetchRecentActivities(),
        _fetchSuccessRateToday(),
        _fetchActiveAlertsCount(), // NOVA CHAMADA ADICIONADA
      ]);

      // Os resultados vêm na ordem das chamadas
      int totalToday = results[0] as int;
      List<ProductionByHour> productionByHour =
          results[1] as List<ProductionByHour>;
      List<ProductionByDestination> productionByDestination =
          results[2] as List<ProductionByDestination>;
      List<RecentActivity> recentActivities =
          results[3] as List<RecentActivity>;
      double successRate = results[4] as double;
      int activeAlerts = results[5]
          as int; // NOVO - Pega os alertas ativos do resultado do RPC

      if (productionByDestination.isEmpty && totalToday > 0) {
        _log(
            "getDashboardData: Sem dados de destino específicos para hoje, adicionando mock data...");
        productionByDestination.add(ProductionByDestination(
            destination: "Esteira Metal", count: (totalToday * 0.4).round()));
        productionByDestination.add(ProductionByDestination(
            destination: "Esteira Plástico",
            count: (totalToday * 0.3).round()));
        productionByDestination.add(ProductionByDestination(
            destination: "Esteira Geral", count: (totalToday * 0.3).round()));
      }

      _log(
          'getDashboardData: Finalizando (Supabase). totalToday=$totalToday, successRate=$successRate, activeAlerts=$activeAlerts, prodByHourCount=${productionByHour.length}, destCount=${productionByDestination.length}, activityCount=${recentActivities.length}');
      return DashboardData(
        totalPiecesToday: totalToday,
        successRate: successRate,
        activeAlerts: activeAlerts, // AGORA VEM DO BANCO
        productionByHour: productionByHour,
        productionByDestination: productionByDestination,
        recentActivities: recentActivities,
      );
    } catch (e, s) {
      _log(
          "Erro geral em getDashboardData ao buscar dados do Supabase: $e\nStackTrace: $s");
      return const DashboardData(
        totalPiecesToday: 0,
        successRate: 0.0,
        activeAlerts: 0, // Retorna 0 em caso de erro geral
        productionByHour: [],
        productionByDestination: [],
        recentActivities: [],
      );
    }
  }
}
