import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_data.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Future<DashboardData>? _dashboardDataFuture;
  DateTime _selectedDate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _loadData();
    });
  }

  void _loadData() {
    setState(() {
      _dashboardDataFuture = _apiService.fetchDashboardData();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'SELECIONE A DATA',
      cancelText: 'CANCELAR',
      confirmText: 'OK',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
      _startAutoRefresh();
    }
  }

  bool _dataIsEmpty(DashboardData data) {
    return data.totalPiecesToday == 0 &&
        data.productionByHour.isEmpty &&
        data.productionByDestination.isEmpty &&
        data.recentActivities.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard (${DateFormat('dd/MM/yyyy').format(_selectedDate)})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Selecionar Data',
            onPressed: () => _pickDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar Dados',
            onPressed: _loadData,
          ),
        ],
      ),
      drawer: const AppDrawer(), // <-- Isso exibe o Drawer e o ícone de menu
      body: FutureBuilder<DashboardData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Erro amigável com botão de tentar novamente
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 20),
                    Text(
                      'Não foi possível carregar os dados do dashboard.\nVerifique sua conexão ou tente novamente.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Tentar Novamente"),
                      onPressed: _loadData,
                    )
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || _dataIsEmpty(snapshot.data!)) {
            // Placeholder para nenhum dado
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 20),
                    Text(
                      'Nenhum dado de produção registrado para ${DateFormat('dd/MM/yyyy').format(_selectedDate)}.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Recarregar"),
                      onPressed: _loadData,
                    )
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.blue),
                  title: const Text('Total de peças hoje'),
                  trailing: Text('${data.totalPiecesToday}',
                      style: theme.textTheme.headlineSmall),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Taxa de sucesso'),
                  trailing: Text('${data.successRate.toStringAsFixed(1)}%',
                      style: theme.textTheme.headlineSmall),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.warning,
                      color: data.activeAlerts > 0
                          ? Colors.red
                          : Colors.grey),
                  title: const Text('Alertas ativos'),
                  trailing: Text('${data.activeAlerts}',
                      style: theme.textTheme.headlineSmall),
                ),
              ),
              const SizedBox(height: 24),
              Text('Produção por Hora', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildProductionByHour(data.productionByHour, theme),
              const SizedBox(height: 24),
              Text('Produção por Material', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildProductionByDestination(data.productionByDestination, theme),
              const SizedBox(height: 24),
              Text('Últimas Atividades', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildRecentActivities(data.recentActivities, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductionByHour(List<ProductionByHour> items, ThemeData theme) {
    if (items.isEmpty) {
      return const Text('Sem dados para hoje.');
    }
    return Column(
      children: items
          .map((e) => ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('${e.hour.toString().padLeft(2, '0')}:00'),
                trailing: Text('${e.count} peças'),
              ))
          .toList(),
    );
  }

  Widget _buildProductionByDestination(
      List<ProductionByDestination> items, ThemeData theme) {
    if (items.isEmpty) {
      return const Text('Sem dados para hoje.');
    }
    return Column(
      children: items
          .map((e) => ListTile(
                leading: const Icon(Icons.category),
                title: Text(e.destination),
                trailing: Text('${e.count} peças'),
              ))
          .toList(),
    );
  }

  Widget _buildRecentActivities(
      List<RecentActivity> activities, ThemeData theme) {
    if (activities.isEmpty) {
      return const Text('Sem atividades recentes.');
    }
    return Column(
      children: activities
          .map((a) => ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(
                    '${a.pieceType} - ${a.destination} (${a.operation})'),
                subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(a.timestamp)),
                trailing: Text(a.status),
              ))
          .toList(),
    );
  }
}
