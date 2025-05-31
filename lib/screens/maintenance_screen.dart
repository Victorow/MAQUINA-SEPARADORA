// lib/screens/maintenance_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../widgets/app_drawer.dart';
import '../widgets/info_card.dart'; // Re-using the InfoCard from dashboard

// Data Model for Maintenance Task
class MaintenanceTask {
  final String id;
  final String component;
  final String type; // e.g., Corretiva, Preventiva, Calibração
  final DateTime scheduledDate;
  final String status; // e.g., Pendente, Em Progresso, Concluída
  final String technician;

  MaintenanceTask({
    required this.id,
    required this.component,
    required this.type,
    required this.scheduledDate,
    required this.status,
    required this.technician,
  });
}

class MaintenanceScreen extends StatefulWidget {
  static const routeName = '/maintenance';
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  int _pendingTasks = 5;
  int _inProgressTasks = 2;
  int _completedTasksThisMonth = 12;

  final List<MaintenanceTask> _allTasks = [
    MaintenanceTask(id: 'M042', component: 'Sensor SNS003', type: 'Corretiva', scheduledDate: DateTime(2025, 4, 11), status: 'Em Progresso', technician: 'Carlos Silva'),
    MaintenanceTask(id: 'M041', component: 'Atuador ATU007', type: 'Preventiva', scheduledDate: DateTime(2025, 4, 11), status: 'Pendente', technician: 'Ana Martins'),
    MaintenanceTask(id: 'M040', component: 'Sensor SNS005', type: 'Preventiva', scheduledDate: DateTime(2025, 4, 11), status: 'Em Progresso', technician: 'Pedro Alves'),
    MaintenanceTask(id: 'M039', component: 'Atuador ATU002', type: 'Calibração', scheduledDate: DateTime(2025, 4, 12), status: 'Pendente', technician: 'Carlos Silva'),
    MaintenanceTask(id: 'M038', component: 'Sensor SNS009', type: 'Preventiva', scheduledDate: DateTime(2025, 4, 10), status: 'Concluída', technician: 'Ana Martins'),
    MaintenanceTask(id: 'M037', component: 'Atuador ATU010', type: 'Corretiva', scheduledDate: DateTime(2025, 4, 9), status: 'Concluída', technician: 'João Costa'),
    MaintenanceTask(id: 'M036', component: 'Esteira Principal', type: 'Preventiva', scheduledDate: DateTime(2025, 4, 14), status: 'Pendente', technician: 'Ana Martins'),
    MaintenanceTask(id: 'M035', component: 'CLP Unit', type: 'Diagnóstico', scheduledDate: DateTime(2025, 4, 8), status: 'Concluída', technician: 'Carlos Silva'),
  ];

  List<MaintenanceTask> _filteredTasks = [];

  // Filter values
  String? _selectedStatus;
  String? _selectedType;
  String? _selectedComponent;

  final List<String> _statusOptions = ['Todos', 'Pendente', 'Em Progresso', 'Concluída'];
  final List<String> _typeOptions = ['Todos', 'Corretiva', 'Preventiva', 'Calibração', 'Diagnóstico'];
  late List<String> _componentOptions;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _componentOptions = ['Todos', ..._allTasks.map((task) => task.component).toSet()];
    _applyFilters(); // Initialize with all tasks
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        final statusMatch = _selectedStatus == null || _selectedStatus == 'Todos' || task.status == _selectedStatus;
        final typeMatch = _selectedType == null || _selectedType == 'Todos' || task.type == _selectedType;
        final componentMatch = _selectedComponent == null || _selectedComponent == 'Todos' || task.component == _selectedComponent;
        return statusMatch && typeMatch && componentMatch;
      }).toList();
    });
  }

  void _refreshData() {
    // In a real app, this would re-fetch data from a service
    setState(() {
      // For now, just re-apply filters to simulate a refresh
      _applyFilters();
      _pendingTasks = _allTasks.where((t) => t.status == 'Pendente').length;
      _inProgressTasks = _allTasks.where((t) => t.status == 'Em Progresso').length;
      // This is a simplified calculation for completed this month
      _completedTasksThisMonth = _allTasks.where((t) => t.status == 'Concluída' && t.scheduledDate.month == DateTime.now().month && t.scheduledDate.year == DateTime.now().year).length;


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados de manutenção atualizados!'), duration: Duration(seconds: 1)),
      );
    });
  }

  Widget _buildFilterDropdown(
      {required String label,
      required String? currentValue,
      required List<String> items,
      required ValueChanged<String?> onChanged}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          value: currentValue ?? items.first,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendente':
        return Colors.orangeAccent;
      case 'Em Progresso':
        return Colors.blueAccent;
      case 'Concluída':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estação - Manutenção'),
        // backgroundColor is inherited from ThemeData
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
            Tab(text: 'Manutenções'),
            Tab(text: 'Agendar'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Manutenções Tab
          _buildMaintenanceListTab(theme),
          // Agendar Tab (Placeholder)
          const Center(child: Text('Funcionalidade de Agendamento em Desenvolvimento')),
          // Histórico Tab (Placeholder)
          const Center(child: Text('Funcionalidade de Histórico em Desenvolvimento')),
        ],
      ),
    );
  }

  Widget _buildMaintenanceListTab(ThemeData theme) {
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
                    title: 'Manutenções Pendentes',
                    value: _pendingTasks.toString(),
                    valueColor: _pendingTasks > 0 ? Colors.orange[700] : Colors.green[700],
                    icon: Icons.pending_actions_outlined,
                    iconColor: Colors.orangeAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InfoCard(
                    title: 'Em Progresso',
                    value: _inProgressTasks.toString(),
                    valueColor: _inProgressTasks > 0 ? Colors.blue[700] : Colors.grey[700],
                    icon: Icons.construction_outlined,
                    iconColor: Colors.blueAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InfoCard(
                    title: 'Concluídas (Mês)',
                    value: _completedTasksThisMonth.toString(),
                    valueColor: Colors.green[700],
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green),
              ),
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
                          label: 'Status',
                          currentValue: _selectedStatus,
                          items: _statusOptions,
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }),
                      _buildFilterDropdown(
                          label: 'Tipo',
                          currentValue: _selectedType,
                          items: _typeOptions,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          }),
                      _buildFilterDropdown(
                          label: 'Componente',
                          currentValue: _selectedComponent,
                          items: _componentOptions,
                          onChanged: (value) {
                            setState(() {
                              _selectedComponent = value;
                            });
                          }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filtrar'),
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40), // Make button wider
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Maintenance List Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Componente', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Agendamento', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Técnico', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Center(child: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
          const Divider(),
          // Maintenance List
          _filteredTasks.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Nenhuma manutenção encontrada com os filtros aplicados.')))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text(task.id, style: const TextStyle(fontSize: 12))),
                          Expanded(flex: 3, child: Text(task.component, style: const TextStyle(fontSize: 12))),
                          Expanded(flex: 2, child: Text(task.type, style: const TextStyle(fontSize: 12))),
                          Expanded(flex: 2, child: Text(DateFormat('dd/MM/yyyy').format(task.scheduledDate), style: const TextStyle(fontSize: 12))),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getStatusColor(task.status).withAlpha(50),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.status,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _getStatusColor(task.status), fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ),
                          Expanded(flex: 2, child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(task.technician, style: const TextStyle(fontSize: 12)),
                          )),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.info_outline, size: 18),
                                tooltip: 'Detalhes da Manutenção ${task.id}',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Detalhes para ${task.id} ainda não implementados.')),
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
              IconButton(icon: const Icon(Icons.first_page), onPressed: () {}),
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
              const Text('Página 1 de X'), // X would be calculated
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
              IconButton(icon: const Icon(Icons.last_page), onPressed: () {}),
            ],
          )
        ],
      ),
    );
  }
}