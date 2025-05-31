// lib/screens/monitoring_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/info_card.dart'; // Re-using the InfoCard

// Data Model for Sensor Information
class SensorInfo {
  final String code;
  final String name;
  final String type;
  final String status; // Ativo, Anomalia, Manutenção
  final double anomalyRate; // as percentage, e.g., 0.03 for 0.03%

  SensorInfo({
    required this.code,
    required this.name,
    required this.type,
    required this.status,
    required this.anomalyRate,
  });
}

class MonitoringScreen extends StatefulWidget {
  static const routeName = '/monitoring';
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for summary
  int _totalSensors = 15;
  int _activeSensors = 13;
  int _anomalyAlerts = 3;

  // Mock data for sensor list
  final List<SensorInfo> _allSensors = [
    SensorInfo(code: 'SNS001', name: 'Sensor Cor RGB', type: 'Cor', status: 'Ativo', anomalyRate: 0.03),
    SensorInfo(code: 'SNS002', name: 'Sensor Indutivo', type: 'Metal', status: 'Ativo', anomalyRate: 0.00),
    SensorInfo(code: 'SNS003', name: 'Sensor Fluxo', type: 'Fluxo', status: 'Anomalia', anomalyRate: 5.27),
    SensorInfo(code: 'SNS004', name: 'Sensor Capacitivo', type: 'Plástico', status: 'Ativo', anomalyRate: 0.12),
    SensorInfo(code: 'SNS005', name: 'Sensor Ótico Presença', type: 'Presença', status: 'Manutenção', anomalyRate: 0.00), // Anomaly rate 0 for maintenance
    SensorInfo(code: 'SNS006', name: 'Sensor Força', type: 'Força', status: 'Ativo', anomalyRate: 0.08),
    SensorInfo(code: 'SNS007', name: 'Sensor Temperatura', type: 'Temperatura', status: 'Ativo', anomalyRate: 0.01),
    SensorInfo(code: 'SNS008', name: 'Sensor Umidade', type: 'Umidade', status: 'Ativo', anomalyRate: 0.05),
    SensorInfo(code: 'SNS009', name: 'Sensor Nível', type: 'Nível', status: 'Anomalia', anomalyRate: 2.15),
    SensorInfo(code: 'SNS010', name: 'Sensor Vibração', type: 'Vibração', status: 'Manutenção', anomalyRate: 0.00),
  ];

  List<SensorInfo> _filteredSensors = [];

  // Filter values
  String? _selectedStatusFilter;
  String? _selectedTypeFilter;
  String? _selectedSortFilter;

  final List<String> _statusFilterOptions = ['Todos', 'Ativo', 'Anomalia', 'Manutenção'];
  late List<String> _typeFilterOptions; // Will be populated from data
  final List<String> _sortFilterOptions = ['Padrão', 'Taxa Anomalia (Alta)', 'Taxa Anomalia (Baixa)', 'Nome (A-Z)'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _typeFilterOptions = ['Todos', ..._allSensors.map((s) => s.type).toSet()];
    _selectedStatusFilter = _statusFilterOptions.first;
    _selectedTypeFilter = _typeFilterOptions.first;
    _selectedSortFilter = _sortFilterOptions.first;
    _applyFiltersAndSort();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFiltersAndSort() {
    setState(() {
      _filteredSensors = _allSensors.where((sensor) {
        final statusMatch = _selectedStatusFilter == 'Todos' || sensor.status == _selectedStatusFilter;
        final typeMatch = _selectedTypeFilter == 'Todos' || sensor.type == _selectedTypeFilter;
        return statusMatch && typeMatch;
      }).toList();

      // Sorting
      if (_selectedSortFilter == 'Taxa Anomalia (Alta)') {
        _filteredSensors.sort((a, b) => b.anomalyRate.compareTo(a.anomalyRate));
      } else if (_selectedSortFilter == 'Taxa Anomalia (Baixa)') {
        _filteredSensors.sort((a, b) => a.anomalyRate.compareTo(b.anomalyRate));
      } else if (_selectedSortFilter == 'Nome (A-Z)') {
        _filteredSensors.sort((a, b) => a.name.compareTo(b.name));
      }
      // 'Padrão' does no additional sorting beyond initial filtering
    });
  }

   void _refreshData() {
    // In a real app, this would re-fetch data
    setState(() {
      // Update summary counts based on current _allSensors (or re-fetched data)
      _totalSensors = _allSensors.length;
      _activeSensors = _allSensors.where((s) => s.status == 'Ativo').length;
      _anomalyAlerts = _allSensors.where((s) => s.status == 'Anomalia').length;
      _applyFiltersAndSort(); // Re-apply filters to the potentially updated list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados de monitoramento atualizados!'), duration: Duration(seconds: 1)),
      );
    });
  }


  Widget _buildFilterDropdown({
    required String? currentValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hintText, // Optional hint text for the dropdown
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            // labelText: hintText, // Using hintText for placeholder if value is null
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          hint: hintText != null ? Text(hintText, style: const TextStyle(fontSize: 14)) : null,
          value: currentValue,
          isExpanded: true,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Color _getStatusChipColor(String status) {
    switch (status) {
      case 'Ativo':
        return Colors.green;
      case 'Anomalia':
        return Colors.red;
      case 'Manutenção':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estação - Monitoramento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Dados',
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sensores'),
            Tab(text: 'Atuadores'),
            Tab(text: 'Esteiras'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSensorsTab(theme),
          const Center(child: Text('Monitoramento de Atuadores em Desenvolvimento')),
          const Center(child: Text('Monitoramento de Esteiras em Desenvolvimento')),
        ],
      ),
    );
  }

  Widget _buildSensorsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                  child: InfoCard(
                      title: 'Total de Sensores',
                      value: _totalSensors.toString(),
                      icon: Icons.sensors,
                      iconColor: theme.colorScheme.primary)),
              const SizedBox(width: 16),
              Expanded(
                  child: InfoCard(
                      title: 'Sensores Ativos',
                      value: _activeSensors.toString(),
                      valueColor: Colors.green[700],
                      icon: Icons.sensors,
                      iconColor: Colors.green)),
              const SizedBox(width: 16),
              Expanded(
                  child: InfoCard(
                      title: 'Alerta Anomalias',
                      value: _anomalyAlerts.toString(),
                      valueColor: _anomalyAlerts > 0 ? Colors.red[700] : Colors.grey[700],
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.red)),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildFilterDropdown(
                          hintText: 'Status: Todos',
                          currentValue: _selectedStatusFilter,
                          items: _statusFilterOptions,
                          onChanged: (value) {
                            setState(() { _selectedStatusFilter = value; });
                          }),
                      _buildFilterDropdown(
                          hintText: 'Tipo: Todos',
                          currentValue: _selectedTypeFilter,
                          items: _typeFilterOptions,
                          onChanged: (value) {
                            setState(() { _selectedTypeFilter = value; });
                          }),
                      _buildFilterDropdown(
                          hintText: 'Ordenar por',
                          currentValue: _selectedSortFilter,
                          items: _sortFilterOptions,
                          onChanged: (value) {
                            setState(() { _selectedSortFilter = value; });
                          }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.tune),
                    label: const Text('Aplicar Filtros'),
                    onPressed: _applyFiltersAndSort,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sensor List Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Código', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 4, child: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Taxa Anomalia', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Center(child: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
          const Divider(),

          // Sensor List
          _filteredSensors.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Nenhum sensor encontrado.')))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredSensors.length,
                  itemBuilder: (context, index) {
                    final sensor = _filteredSensors[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(sensor.code, style: const TextStyle(fontSize: 12))),
                          Expanded(flex: 4, child: Text(sensor.name, style: const TextStyle(fontSize: 12))),
                          Expanded(flex: 3, child: Text(sensor.type, style: const TextStyle(fontSize: 12))),
                          Expanded(
                            flex: 2,
                            child: Chip(
                              label: Text(sensor.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                              backgroundColor: _getStatusChipColor(sensor.status),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust padding inside chip
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              sensor.status == 'Manutenção' ? '-' : '${sensor.anomalyRate.toStringAsFixed(2)}%',
                              style: TextStyle(fontSize: 12, color: sensor.anomalyRate > 1 ? Colors.redAccent : Colors.black87),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.info_outline, size: 18),
                                tooltip: 'Detalhes do Sensor ${sensor.code}',
                                onPressed: () {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Detalhes para ${sensor.code} não implementados.')),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                ),
            const SizedBox(height: 20),
            // Pagination (Placeholder)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.first_page), onPressed: () {}, tooltip: "Primeira Página"),
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}, tooltip: "Página Anterior"),
                const Text('Página 1 de X'),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}, tooltip: "Próxima Página"),
                IconButton(icon: const Icon(Icons.last_page), onPressed: () {}, tooltip: "Última Página"),
              ],
            )
        ],
      ),
    );
  }
}