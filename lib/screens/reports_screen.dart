// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:fl_chart/fl_chart.dart'; // For charts
import '../widgets/app_drawer.dart';
import '../widgets/info_card.dart'; // Re-using InfoCard

// Data Models
class ReportSummaryData {
  final int totalProcessed;
  final double successRate;

  ReportSummaryData({required this.totalProcessed, required this.successRate});
}

class DailyMaterialProduction {
  final DateTime date;
  final int metalCount;
  final int plasticCount;

  DailyMaterialProduction({
    required this.date,
    required this.metalCount,
    required this.plasticCount,
  });
}

class PieceTypeSummaryItem {
  final String pieceType;
  final String material;
  final String color;
  final int quantity;
  final double percentageOfTotal;

  PieceTypeSummaryItem({
    required this.pieceType,
    required this.material,
    required this.color,
    required this.quantity,
    required this.percentageOfTotal,
  });
}

class ReportsScreen extends StatefulWidget {
  static const routeName = '/reports';
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 10));
  DateTime _endDate = DateTime.now();

  ReportSummaryData _summaryData = ReportSummaryData(totalProcessed: 14582, successRate: 98.7);
  final List<DailyMaterialProduction> _dailyProduction = [];
  List<PieceTypeSummaryItem> _pieceTypeSummary = [];

  bool _isLoading = false;
  bool _reportGenerated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _generateMockReportData() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _summaryData = ReportSummaryData(
          totalProcessed: 13000 + (_endDate.difference(_startDate).inDays * 150),
          successRate: 97.5 + (_endDate.day % 10) * 0.1);

      _dailyProduction.clear();
      int days = _endDate.difference(_startDate).inDays;
      if (days < 0) days = 0;
      if (days > 30) days = 30;

      for (int i = 0; i <= days; i++) {
        final date = _startDate.add(Duration(days: i));
        _dailyProduction.add(DailyMaterialProduction(
          date: date,
          metalCount: 80 + (i * 5) + (date.day % 20),
          plasticCount: 60 + (i * 3) + (date.day % 15),
        ));
      }

      _pieceTypeSummary.clear();
      final totalForSummary = _summaryData.totalProcessed > 0 ? _summaryData.totalProcessed : 1;
      _pieceTypeSummary = [
        PieceTypeSummaryItem(pieceType: 'Cilindro P', material: 'Metal', color: 'Azul', quantity: (totalForSummary * 0.2).toInt(), percentageOfTotal: 20.0),
        PieceTypeSummaryItem(pieceType: 'Cubo M', material: 'Plástico', color: 'Vermelho', quantity: (totalForSummary * 0.15).toInt(), percentageOfTotal: 15.0),
        PieceTypeSummaryItem(pieceType: 'Paralel. G', material: 'Metal', color: 'Verde', quantity: (totalForSummary * 0.25).toInt(), percentageOfTotal: 25.0),
        PieceTypeSummaryItem(pieceType: 'Esfera P', material: 'Plástico', color: 'Amarelo', quantity: (totalForSummary * 0.1).toInt(), percentageOfTotal: 10.0),
        PieceTypeSummaryItem(pieceType: 'Outros', material: 'Variado', color: 'N/A', quantity: (totalForSummary * 0.3).toInt(), percentageOfTotal: 30.0),
      ];

      setState(() {
        _isLoading = false;
        _reportGenerated = true;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estação - Relatórios'),
        actions: [
          _buildExportButton('PDF', Icons.picture_as_pdf_outlined, () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportar PDF não implementado')));
          }),
          const SizedBox(width: 8),
          _buildExportButton('CSV', Icons.article_outlined, () { // Icon was already corrected
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportar CSV não implementado')));
          }),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Produção Diária'),
            Tab(text: 'Eficiência Operacional'),
            Tab(text: 'Saúde dos Sensores'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyProductionTab(theme),
          const Center(child: Text('Relatório de Eficiência Operacional em Desenvolvimento')),
          const Center(child: Text('Relatório de Saúde dos Sensores em Desenvolvimento')),
        ],
      ),
    );
  }

  Widget _buildDailyProductionTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date Filters
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Período:", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'De',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("até"),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Até',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: _isLoading ? const SizedBox(width:18, height:18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,)) : const Icon(Icons.assessment_outlined),
                    label: const Text('Gerar Relatório'),
                    onPressed: _isLoading ? null : _generateMockReportData,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_reportGenerated) ...[
            Row(
              children: [
                Expanded(
                    child: InfoCard(
                        title: 'Total Peças Processadas',
                        value: NumberFormat.decimalPattern('pt_BR').format(_summaryData.totalProcessed),
                        icon: Icons.precision_manufacturing_outlined)),
                const SizedBox(width: 16),
                Expanded(
                    child: InfoCard(
                        title: 'Taxa de Sucesso',
                        value: '${_summaryData.successRate.toStringAsFixed(1)}%',
                        valueColor: Colors.green[700],
                        icon: Icons.check_circle_outline)),
              ],
            ),
            const SizedBox(height: 24),

            Text('Produção Diária por Material', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Container(
              height: 250,
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: _dailyProduction.isEmpty
                  ? const Center(child: Text("Sem dados para o período selecionado."))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 0.5),
                          getDrawingVerticalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 0.5),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: _dailyProduction.length > 7 ? (_dailyProduction.length / 7).ceilToDouble() : 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < _dailyProduction.length) {
                                  return SideTitleWidget( // This widget cannot be const
                                    axisSide: meta.axisSide,
                                    space: 8.0,
                                    child: Text(DateFormat('dd/MM').format(_dailyProduction[index].date), style: const TextStyle(fontSize: 10)),
                                  );
                                }
                                return Container(); // Can be const Container() if needed
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: theme.dividerColor)),
                        minX: 0,
                        maxX: (_dailyProduction.length -1).toDouble(),
                        minY: 0,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _dailyProduction.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.metalCount.toDouble())).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                          LineChartBarData(
                            spots: _dailyProduction.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.plasticCount.toDouble())).toList(),
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final flSpot = barSpot;
                                String materialName = "";
                                if (barSpot.barIndex == 0) materialName = "Metal";
                                if (barSpot.barIndex == 1) materialName = "Plástico";
                                return LineTooltipItem(
                                  '$materialName: ${flSpot.y.toInt()} peças\n',
                                  TextStyle(color: barSpot.bar.color, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: DateFormat('dd/MM/yyyy').format(_dailyProduction[flSpot.x.toInt()].date),
                                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                                    ),
                                  ]
                                );
                              }).toList();
                            }
                          )
                        ),
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(y: 0, color: Colors.transparent)
                          ]
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.blue, "Metal"),
                  const SizedBox(width: 16),
                  _buildLegendItem(Colors.green, "Plástico"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Resumo por Tipo de Peça', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildPieceTypeSummaryTable(), // Definition below
          ] else if (!_isLoading) ... [
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text("Selecione um período e clique em 'Gerar Relatório' para ver os dados.", textAlign: TextAlign.center),
              ),
            )
          ],
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: CircularProgressIndicator(),
            )),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildPieceTypeSummaryTable() {
    return DataTable(
      columnSpacing: 16.0,
      headingRowHeight: 36,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 36,
      columns: const [ // DataColumn can be const
        DataColumn(label: Text('Tipo Peça', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        DataColumn(label: Text('Material', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        // FIX: Changed L.bold to FontWeight.bold and made TextStyle const
        DataColumn(label: Text('Cor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        DataColumn(label: Text('Qtd.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
        DataColumn(label: Text('% Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
      ],
      rows: _pieceTypeSummary.map((item) {
        return DataRow(cells: [ // DataRow cells cannot be const if content is dynamic
          DataCell(Text(item.pieceType, style: const TextStyle(fontSize: 11))),
          DataCell(Text(item.material, style: const TextStyle(fontSize: 11))),
          DataCell(Text(item.color, style: const TextStyle(fontSize: 11))),
          DataCell(Text(NumberFormat.decimalPattern('pt_BR').format(item.quantity), style: const TextStyle(fontSize: 11))),
          DataCell(Text('${item.percentageOfTotal.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11))),
        ]);
      }).toList(),
    );
  }
}