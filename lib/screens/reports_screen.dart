import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/app_drawer.dart';
import '../widgets/info_card.dart';
import '../services/db_service.dart';
import '../models/report_models.dart';

class ReportsScreen extends StatefulWidget {
  static const routeName = '/reports';
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  ReportSummaryData? _summaryData;
  List<DailyMaterialProduction> _dailyProduction = [];
  List<PieceTypeSummaryItem> _pieceTypeSummary = [];

  bool _isLoading = false;
  bool _reportGenerated = false;

  final DbService _dbService = DbService();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndGenerateReport() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _reportGenerated = false;
      _summaryData = null;
      _dailyProduction = [];
      _pieceTypeSummary = [];
    });

    try {
      final summary = await _dbService.fetchReportSummary(_startDate, _endDate);
      final dailyProd = await _dbService.fetchDailyMaterialProduction(_startDate, _endDate);
      final pieceSummary = await _dbService.fetchPieceTypeSummary(_startDate, _endDate);

      if (mounted) {
        setState(() {
          _summaryData = summary;
          _dailyProduction = dailyProd;
          _pieceTypeSummary = pieceSummary;
          _reportGenerated = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar relatório: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: isStartDate ? 'SELECIONE A DATA INICIAL' : 'SELECIONE A DATA FINAL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
        _reportGenerated = false;
      });
    }
  }

  Widget _buildExportButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estação - Relatórios'),
        actions: [
          _buildExportButton('PDF', Icons.picture_as_pdf_outlined, () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportar PDF não implementado.')));
          }),
          const SizedBox(width: 8),
          _buildExportButton('CSV', Icons.summarize_outlined, () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportar CSV não implementado.')));
          }),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(icon: Icon(Icons.calendar_view_day_outlined), text: 'Produção Diária'),
            Tab(icon: Icon(Icons.settings_accessibility_outlined), text: 'Eficiência'),
            Tab(icon: Icon(Icons.sensors_outlined), text: 'Sensores'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyProductionTab(theme),
          _buildPlaceholderTab("Relatório de Eficiência Operacional"),
          _buildPlaceholderTab("Relatório de Saúde dos Sensores"),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('$title em Desenvolvimento...', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
      ),
    );
  }

  Widget _buildDailyProductionTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selecione o Período:", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'De',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              suffixIcon: Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary),
                            ),
                            child: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text("até", style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Até',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              suffixIcon: Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary),
                            ),
                            child: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white,))
                        : const Icon(Icons.bar_chart_rounded, size: 20),
                    label: const Text('Gerar Relatório'),
                    onPressed: _isLoading ? null : _fetchAndGenerateReport,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
          else if (_reportGenerated) ...[
            if (_summaryData != null) ...[
              Text("Resumo do Período", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      title: 'Total Processadas',
                      value: NumberFormat.decimalPattern('pt_BR').format(_summaryData!.totalProcessed),
                      icon: Icons.precision_manufacturing_rounded,
                      iconColor: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoCard(
                      title: 'Taxa de Sucesso (%)',
                      value: _summaryData!.successRate.toStringAsFixed(1),
                      valueColor: _summaryData!.successRate > 90 ? Colors.green.shade700 : Colors.orange.shade700,
                      iconColor: _summaryData!.successRate > 90 ? Colors.green.shade600 : Colors.orange.shade600,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ] else ...[
              const Center(child: Text("Não foi possível carregar o resumo do período.", style: TextStyle(color: Colors.red))),
              const SizedBox(height: 24),
            ],

            Text('Produção Diária por Material', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            _buildDailyProductionLineChart(theme),
            const SizedBox(height: 24),

            Text('Resumo por Tipo de Peça', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            _buildPieceTypeSummaryTable(theme),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text("Selecione um período e clique em 'Gerar Relatório' para visualizar os dados.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildDailyProductionLineChart(ThemeData theme) {
    if (_dailyProduction.isEmpty && _reportGenerated && !_isLoading) {
      return const SizedBox(height: 250, child: Center(child: Text("Sem dados de produção diária para o período selecionado.")));
    }
    if (!_reportGenerated || _dailyProduction.isEmpty) return const SizedBox.shrink();

    // Obtenha todas as datas únicas ordenadas
    final dates = _dailyProduction.map((e) => e.date).toSet().toList()..sort();
    // Obtenha todos os materiais únicos
    final materials = _dailyProduction.map((e) => e.material).toSet().toList();

    // Crie um mapa para cada material com os counts por data
    Map<String, List<FlSpot>> materialSpots = {};
    double maxY = 0;
    for (var material in materials) {
      materialSpots[material] = [];
      for (int i = 0; i < dates.length; i++) {
        final date = dates[i];
        final prod = _dailyProduction.firstWhere(
          (p) => p.date == date && p.material == material,
          orElse: () => DailyMaterialProduction(date: date, material: material, count: 0),
        );
        materialSpots[material]!.add(FlSpot(i.toDouble(), prod.count.toDouble()));
        if (prod.count > maxY) maxY = prod.count.toDouble();
      }
    }
    maxY = (maxY * 1.15).ceilToDouble();
    if (maxY < 10) maxY = 10;

    final colorMap = {
      'metal': Colors.blueGrey,
      'plástico': Colors.orange,
      // adicione mais materiais se necessário
    };

    return Container(
      height: 320,
      padding: const EdgeInsets.only(top: 24, right: 20, bottom: 12, left: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withAlpha(100),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (maxY / 5).ceilToDouble() > 0 ? (maxY / 5).ceilToDouble() : 1,
            verticalInterval: dates.length > 10 ? (dates.length / 7).ceilToDouble() : 1,
            getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor.withAlpha(80), strokeWidth: 0.6),
            getDrawingVerticalLine: (value) => FlLine(color: theme.dividerColor.withAlpha(80), strokeWidth: 0.6),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: dates.length > 7 ? ((dates.length / 5).ceilToDouble()).clamp(1, 5).toDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dates.length) {
                    if (dates.length <= 7 || index % ((dates.length / 5).ceil()) == 0 || index == dates.length - 1) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8.0,
                        child: Text(DateFormat('dd/MM').format(dates[index]), style: theme.textTheme.bodySmall),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: (maxY / 5).ceilToDouble() > 0 ? (maxY / 5).ceilToDouble() : 1,
                getTitlesWidget: (v, meta) {
                  if (v == meta.max && maxY > 0) return const SizedBox.shrink();
                  return Text(v.toInt().toString(), style: theme.textTheme.bodySmall);
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: theme.dividerColor.withAlpha(150), width: 0.8)),
          minX: 0,
          maxX: (dates.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: materials.map((material) {
            return LineChartBarData(
              spots: materialSpots[material]!,
              isCurved: true,
              color: colorMap[material] ?? Colors.grey,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: (colorMap[material] ?? Colors.grey).withAlpha(30)),
            );
          }).toList(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.blueGrey.withAlpha(230),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  final material = materials[barSpot.barIndex];
                  final dateIndex = flSpot.x.toInt();
                  if (dateIndex < 0 || dateIndex >= dates.length) return null;
                  return LineTooltipItem(
                    '$material: ${flSpot.y.toInt()} peças\n',
                    TextStyle(color: colorMap[material] ?? Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                    children: [
                      TextSpan(
                        text: DateFormat('dd/MM/yyyy').format(dates[dateIndex]),
                        style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11),
                      ),
                    ],
                    textAlign: TextAlign.left,
                  );
                }).where((item) => item != null).toList().cast<LineTooltipItem>();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieceTypeSummaryTable(ThemeData theme) {
    if (_pieceTypeSummary.isEmpty && _reportGenerated && !_isLoading) {
      return const SizedBox(height: 150, child: Center(child: Text("Sem dados de resumo por tipo de peça para o período.")));
    }
    if (!_reportGenerated || _pieceTypeSummary.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 20.0,
              headingRowHeight: 40,
              dataRowMinHeight: 38,
              dataRowMaxHeight: 38,
              headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
              columns: const [
                DataColumn(label: Text('Tipo Peça')),
                DataColumn(label: Text('Material')),
                DataColumn(label: Text('Cor')),
                DataColumn(label: Text('Qtd.'), numeric: true),
                DataColumn(label: Text('% Total'), numeric: true),
              ],
              rows: _pieceTypeSummary.map((item) {
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                    if (_pieceTypeSummary.indexOf(item) % 2 != 0) {
                      return theme.colorScheme.surfaceContainerLowest.withAlpha(40);
                    }
                    return null;
                  }),
                  cells: [
                    DataCell(Text(item.pieceType, style: theme.textTheme.bodyMedium)),
                    DataCell(Text(item.material, style: theme.textTheme.bodyMedium)),
                    DataCell(Text(item.color, style: theme.textTheme.bodyMedium)),
                    DataCell(Text(NumberFormat.decimalPattern('pt_BR').format(item.quantity), style: theme.textTheme.bodyMedium)),
                    DataCell(Text('${item.percentageOfTotal.toStringAsFixed(1)}%', style: theme.textTheme.bodyMedium)),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
