import 'dart:developer' as developer;
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_data.dart';
import '../models/report_models.dart';

void _log(String message) {
  developer.log('[DbService-MySQL] $message', name: 'DB');
}

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  MySqlConnection? _conn;

  static const String _host = '10.108.34.73';
  static const int _port = 3306;
  static const String _user = 'root';
  static const String _password = 'root';
  static const String _db = 'db_prod';

  Future<MySqlConnection> get _connection async {
    if (_conn == null) {
      _log('Tentando conectar em $_host:$_port como $_user no banco $_db...');
      try {
        _conn = await MySqlConnection.connect(ConnectionSettings(
          host: _host,
          port: _port,
          user: _user,
          password: _password,
          db: _db,
          timeout: const Duration(seconds: 15),
        ));
        _log('Conexão bem-sucedida!');
      } catch (e, s) {
        _log('Falha na conexão - $e\nStackTrace: $s');
        rethrow;
      }
    }
    return _conn!;
  }

  Future<void> close() async {
    if (_conn != null) {
      try {
        await _conn!.close();
        _log('Conexão fechada.');
      } catch (e) {
        _log('Erro ao fechar conexão: $e');
      } finally {
        _conn = null;
      }
    }
  }

  // --- Dashboard ---

  Future<int> _fetchTotalPiecesToday(MySqlConnection conn) async {
    _log('Buscando total de peças hoje...');
    try {
      var results = await conn.query('SELECT COUNT(*) as count FROM tb_prod WHERE DATE(data_hora) = CURDATE()');
      if (results.isNotEmpty) {
        final count = results.first['count'];
        return (count is int) ? count : (int.tryParse(count.toString()) ?? 0);
      }
      return 0;
    } catch (e, s) {
      _log('Erro _fetchTotalPiecesToday: $e\nStackTrace: $s');
      return 0;
    }
  }

  Future<List<ProductionByHour>> _fetchProductionByHourToday(MySqlConnection conn) async {
    _log('Buscando produção por hora hoje...');
    try {
      var results = await conn.query(
        'SELECT HOUR(data_hora) as hour, COUNT(*) as count FROM tb_prod WHERE DATE(data_hora) = CURDATE() GROUP BY HOUR(data_hora) ORDER BY HOUR(data_hora) ASC LIMIT 24'
      );
      return results.map((row) {
        return ProductionByHour(
          hour: row['hour'] as int? ?? 0,
          count: row['count'] as int? ?? 0,
        );
      }).toList();
    } catch (e, s) {
      _log('Erro _fetchProductionByHourToday: $e\nStackTrace: $s');
      return [];
    }
  }

  Future<List<ProductionByDestination>> _fetchProductionByDestinationToday(MySqlConnection conn) async {
    _log('Buscando produção por material hoje...');
    try {
      var results = await conn.query('''
        SELECT m.material as destination, COUNT(*) as count
        FROM tb_prod p
        JOIN tb_material m ON p.id_material = m.id_material
        WHERE DATE(p.data_hora) = CURDATE()
        GROUP BY m.material
      ''');
      return results.map((row) {
        return ProductionByDestination(
          destination: row['destination'] as String,
          count: row['count'] as int,
        );
      }).toList();
    } catch (e, s) {
      _log('Erro _fetchProductionByDestinationToday: $e\nStackTrace: $s');
      return [];
    }
  }

  Future<List<RecentActivity>> _fetchRecentActivities(MySqlConnection conn) async {
    _log('Buscando atividades recentes...');
    try {
      var results = await conn.query('''
        SELECT 
          p.data_hora,
          'inserção' AS operation,         -- ajuste conforme sua lógica
          '' AS status,                    -- ajuste se existir o campo status
          p.tipo_peca,
          m.material AS destination
        FROM tb_prod p
        JOIN tb_material m ON p.id_material = m.id_material
        ORDER BY p.data_hora DESC
        LIMIT 10
      ''');

      return results.map((row) {
        return RecentActivity(
          timestamp: (row['data_hora'] as DateTime).toLocal(),
          operation: row['operation'] as String? ?? '',
          status: row['status'] as String? ?? '',
          pieceType: row['tipo_peca'] as String? ?? '',
          destination: row['destination'] as String? ?? '',
        );
      }).toList();
    } catch (e, s) {
      _log('Erro _fetchRecentActivities: $e\nStackTrace: $s');
      return [];
    }
  }

  Future<double> _fetchSuccessRateToday(MySqlConnection conn) async {
    _log('Buscando taxa de sucesso hoje...');
    // Exemplo: se não tiver coluna de status, retorna 100%
    return 100.0;
  }

  Future<int> _fetchActiveAlertsCount(MySqlConnection conn) async {
    _log('Buscando contagem de alertas ativos...');
    // Exemplo: sem alertas
    return 0;
  }

  Future<DashboardData> getDashboardData() async {
    _log('getDashboardData (MySQL): Iniciando busca de dados para HOJE...');
    try {
      final conn = await _connection;
      final results = await Future.wait([
        _fetchTotalPiecesToday(conn),
        _fetchProductionByHourToday(conn),
        _fetchProductionByDestinationToday(conn),
        _fetchRecentActivities(conn),
        _fetchSuccessRateToday(conn),
        _fetchActiveAlertsCount(conn),
      ]);

      int totalToday = results[0] as int;
      List<ProductionByHour> productionByHour = results[1] as List<ProductionByHour>;
      List<ProductionByDestination> productionByDestination = results[2] as List<ProductionByDestination>;
      List<RecentActivity> recentActivities = results[3] as List<RecentActivity>;
      double successRate = results[4] as double;
      int activeAlerts = results[5] as int;

      return DashboardData(
        totalPiecesToday: totalToday,
        successRate: successRate,
        activeAlerts: activeAlerts,
        productionByHour: productionByHour,
        productionByDestination: productionByDestination,
        recentActivities: recentActivities,
      );
    } catch (e, s) {
      _log("Erro geral em getDashboardData (MySQL): $e\nStackTrace: $s");
      return const DashboardData(
        totalPiecesToday: 0,
        successRate: 0.0,
        activeAlerts: 0,
        productionByHour: [],
        productionByDestination: [],
        recentActivities: [],
      );
    }
  }

  // --- Relatórios ---

  Future<ReportSummaryData> fetchReportSummary(DateTime startDate, DateTime endDate) async {
    _log('Buscando resumo do relatório...');
    final conn = await _connection;
    try {
      final formattedStart = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEnd = DateFormat('yyyy-MM-dd').format(endDate);

      var totalResults = await conn.query(
        'SELECT COUNT(*) as total FROM tb_prod WHERE DATE(data_hora) BETWEEN ? AND ?',
        [formattedStart, formattedEnd]
      );
      int totalProcessed = totalResults.first['total'] as int;

      // Se não houver campo status, retorna 100%
      double successRate = 100.0;

      return ReportSummaryData(
        totalProcessed: totalProcessed,
        successRate: successRate,
      );
    } catch (e, s) {
      _log('Erro fetchReportSummary: $e\n$s');
      rethrow;
    }
  }

  Future<List<DailyMaterialProduction>> fetchDailyMaterialProduction(DateTime startDate, DateTime endDate) async {
    _log('Buscando produção diária por material...');
    final conn = await _connection;
    try {
      final formattedStart = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEnd = DateFormat('yyyy-MM-dd').format(endDate);

      var results = await conn.query('''
        SELECT 
          DATE(p.data_hora) as date,
          m.material,
          COUNT(*) as count
        FROM tb_prod p
        JOIN tb_material m ON p.id_material = m.id_material
        WHERE DATE(p.data_hora) BETWEEN ? AND ?
        GROUP BY DATE(p.data_hora), m.material
        ORDER BY DATE(p.data_hora) ASC
      ''', [formattedStart, formattedEnd]);

      return results.map((row) {
        return DailyMaterialProduction(
          date: (row['date'] as DateTime).toLocal(),
          material: row['material'] as String,
          count: row['count'] as int,
        );
      }).toList();
    } catch (e, s) {
      _log('Erro fetchDailyMaterialProduction: $e\n$s');
      rethrow;
    }
  }

  Future<List<PieceTypeSummaryItem>> fetchPieceTypeSummary(DateTime startDate, DateTime endDate) async {
    _log('Buscando resumo por tipo de peça...');
    final conn = await _connection;
    try {
      final formattedStart = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEnd = DateFormat('yyyy-MM-dd').format(endDate);

      var results = await conn.query('''
        SELECT 
          p.tipo_peca as pieceType,
          m.material,
          c.cor as color,
          COUNT(*) as quantity
        FROM tb_prod p
        JOIN tb_material m ON p.id_material = m.id_material
        JOIN tb_cor c ON p.id_cor = c.id_cor
        WHERE DATE(p.data_hora) BETWEEN ? AND ?
        GROUP BY p.tipo_peca, m.material, c.cor
        ORDER BY quantity DESC
      ''', [formattedStart, formattedEnd]);

      int total = results.fold(0, (sum, row) => sum + (row['quantity'] as int));

      return results.map((row) {
        final quantity = row['quantity'] as int;
        return PieceTypeSummaryItem(
          pieceType: row['pieceType'] as String? ?? '',
          material: row['material'] as String? ?? '',
          color: row['color'] as String? ?? '',
          quantity: quantity,
          percentageOfTotal: total > 0 ? (quantity / total * 100) : 0.0,
        );
      }).toList();
    } catch (e, s) {
      _log('Erro fetchPieceTypeSummary: $e\n$s');
      rethrow;
    }
  }
}
