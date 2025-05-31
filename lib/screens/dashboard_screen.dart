// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/app_drawer.dart';
import '../widgets/info_card.dart';
import '../widgets/activity_list_item.dart';
import '../services/db_service.dart';
import '../models/dashboard_data.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DbService _dbService = DbService();
  Future<DashboardData>? _dashboardDataFuture;

  final Map<String, Color> _destinationColors = {
    "metal": Colors.blueGrey.shade700,
    "plastico": Colors.orange.shade700,
    "esteira metal": Colors.lightBlue.shade700,
    "esteira plástico": Colors.deepOrange.shade700,
    "esteira geral": Colors.green.shade700,
    "desconhecido": Colors.purple.shade300,
    "unknown": Colors.grey.shade600,
  };

  Color _getDestinationColor(String destination) {
    return _destinationColors[destination.toLowerCase()] ??
        _destinationColors[destination] ??
        _destinationColors["unknown"]!;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (mounted) {
      setState(() {
        _dashboardDataFuture = _dbService.getDashboardData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Estação Separadora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Funcionalidade de filtros ainda não implementada.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar Dados',
            onPressed: _loadData,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<DashboardData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorView(snapshot.error, theme);
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              _dataIsEmpty(snapshot.data!)) {
            return _buildNoDataView(theme,
                dataIsTrulyEmpty: _dataIsEmpty(snapshot.data));
          }

          final data = snapshot.data!;
          double maxProdCountForBarChart = 10.0;
          if (data.productionByHour.isNotEmpty) {
            maxProdCountForBarChart = (data.productionByHour
                        .map((e) => e.count)
                        .fold(
                            0.0,
                            (prev, curr) => prev > curr.toDouble()
                                ? prev
                                : curr.toDouble()) *
                    1.2) +
                5;
            if (maxProdCountForBarChart <= 10) {
              maxProdCountForBarChart = 10;
            } else if (maxProdCountForBarChart < 2 &&
                data.productionByHour.isNotEmpty) {
              maxProdCountForBarChart = 2;
            }
          }
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCardsRow(data, theme, context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, 'Produção por Hora (Hoje)'),
                  _buildProductionByHourChart(
                      data.productionByHour,
                      maxProdCountForBarChart,
                      theme,
                      data.totalPiecesToday,
                      screenWidth),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, 'Produção por Destino (Hoje)'),
                  _buildProductionByDestinationChart(
                      data.productionByDestination,
                      theme,
                      data.totalPiecesToday),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, 'Últimas Atividades'),
                  _buildRecentActivitiesListView(data.recentActivities, theme),
                  const SizedBox(height: 24),
                  Center(
                    child: IconButton(
                      icon:
                          Icon(Icons.refresh, color: theme.colorScheme.primary),
                      iconSize: 30,
                      tooltip: 'Recarregar Dados',
                      onPressed: _loadData,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _dataIsEmpty(DashboardData? data) {
    if (data == null) return true;
    return data.totalPiecesToday == 0 &&
        data.productionByHour.isEmpty &&
        data.productionByDestination.isEmpty &&
        data.recentActivities.isEmpty;
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildErrorView(Object? error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: theme.colorScheme.error.withAlpha(180), size: 60),
            const SizedBox(height: 20),
            Text('Ops! Erro ao carregar os dados.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              'Detalhe: $error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Tentar Novamente"),
              onPressed: _loadData,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataView(ThemeData theme, {bool dataIsTrulyEmpty = true}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                dataIsTrulyEmpty
                    ? Icons.inbox_outlined
                    : Icons.hourglass_empty_outlined,
                size: 60,
                color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
                dataIsTrulyEmpty
                    ? 'Nenhum dado de produção registrado hoje.'
                    : 'Aguardando dados para esta visualização...',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: Colors.grey.shade700)),
            if (dataIsTrulyEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                    'Verifique se o Node-RED está enviando dados para o Supabase.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget _buildInfoCardsRow(
      DashboardData data, ThemeData theme, BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isWide = constraints.maxWidth > 700;
      final cards = [
        InfoCard(
            title: 'Total de Peças Hoje',
            value: data.totalPiecesToday.toString(),
            icon: Icons.precision_manufacturing_outlined,
            iconColor: theme.colorScheme.primary),
        InfoCard(
            title: 'Taxa de Sucesso',
            value: '${data.successRate.toStringAsFixed(1)}%',
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.green.shade700,
            valueColor: Colors.green.shade700),
        InfoCard(
            title: 'Alertas Ativos',
            value: data.activeAlerts.toString(),
            icon: Icons.notification_important_rounded,
            iconColor: Colors.orange.shade700,
            valueColor: Colors.orange.shade700),
      ];
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cards
              .map((card) => Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: card,
                  )))
              .toList(),
        );
      } else {
        return Column(
          children: cards
              .map((card) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: card,
                  ))
              .toList(),
        );
      }
    });
  }

  Widget _buildProductionByHourChart(List<ProductionByHour> prodData,
      double maxY, ThemeData theme, int totalToday, double screenWidth) {
    if (prodData.isEmpty) {
      return _buildEmptyChartPlaceholder(
          theme, "Sem dados de produção por hora para hoje.", totalToday > 0);
    }
    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) =>
                  Colors.blueGrey.shade800.withAlpha(240),
              tooltipRoundedRadius: 8,
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String hourLabel =
                    '${group.x.toInt().toString().padLeft(2, '0')}:00 - ${(group.x.toInt() + 1).toString().padLeft(2, '0')}:00';
                return BarTooltipItem(
                  '$hourLabel\n',
                  TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                            color: Colors.black.withAlpha(128), blurRadius: 2)
                      ]),
                  children: <TextSpan>[
                    TextSpan(
                      text: rod.toY.round().toString(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: ' peças',
                      style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final hour = value.toInt();
                  if (prodData.any((p) => p.hour == hour) &&
                      (hour % 2 == 0 ||
                          prodData.length <= 6 ||
                          hour == prodData.first.hour ||
                          hour == prodData.last.hour)) {
                    return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8.0,
                        child: Text('${hour.toString().padLeft(2, '0')}h',
                            style: theme.textTheme.bodySmall));
                  }
                  return Container();
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: (maxY / 4).ceilToDouble() > 1
                    ? (maxY / 4).ceilToDouble()
                    : 2,
                getTitlesWidget: (value, meta) {
                  if (value == 0 && maxY <= 10 && maxY > 0) return Container();
                  if (value == meta.max && maxY > 0) return Container();
                  return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(value.toInt().toString(),
                          style: theme.textTheme.bodySmall));
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval:
                (maxY / 4).ceilToDouble() > 1 ? (maxY / 4).ceilToDouble() : 2,
            getDrawingHorizontalLine: (value) => FlLine(
                color: theme.dividerColor.withAlpha(80), strokeWidth: 0.8),
          ),
          barGroups: prodData.map((item) {
            double calculatedBarWidth =
                (screenWidth * 0.9 / (prodData.length * 2.0));
            if (calculatedBarWidth < 10) calculatedBarWidth = 10;
            if (calculatedBarWidth > 28) calculatedBarWidth = 28;
            return BarChartGroupData(
              x: item.hour,
              barRods: [
                BarChartRodData(
                  toY: item.count.toDouble(),
                  color: theme.colorScheme.primary.withAlpha(220),
                  width: calculatedBarWidth,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(5)),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductionByDestinationChart(
      List<ProductionByDestination> destData, ThemeData theme, int totalToday) {
    if (destData.isEmpty) {
      return _buildEmptyChartPlaceholder(theme,
          "Sem dados de produção por destino para hoje.", totalToday > 0);
    }
    double totalCountForPercentage =
        destData.fold(0.0, (sum, item) => sum + item.count);
    if (totalCountForPercentage == 0) totalCountForPercentage = 1;

    return Container(
      height: 230,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2.5,
                centerSpaceRadius: 35,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
                sections: List.generate(destData.length, (i) {
                  final item = destData[i];
                  final percentage =
                      (item.count / totalCountForPercentage * 100);
                  return PieChartSectionData(
                    color: _getDestinationColor(item.destination),
                    value: item.count.toDouble(),
                    title: percentage > 8
                        ? '${percentage.toStringAsFixed(0)}%'
                        : '',
                    radius: 70,
                    titleStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                              color: Colors.black87,
                              blurRadius: 3,
                              offset: Offset(0, 1))
                        ]),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ListView.builder(
                itemCount: destData.length,
                itemBuilder: (context, index) {
                  final item = destData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                                color: _getDestinationColor(item.destination),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(2.5))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                          item.destination,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        )),
                        Text(
                          '(${item.count})',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withAlpha(200)),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesListView(
      List<RecentActivity> activities, ThemeData theme) {
    if (activities.isEmpty) {
      return _buildEmptyChartPlaceholder(
          theme, "Nenhuma atividade recente para exibir.", false);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            return ActivityListItem(activity: activities[index]);
          },
          separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.4,
              indent: 0,
              endIndent: 0,
              color: theme.dividerColor.withAlpha(80)),
        ),
      ],
    );
  }

  Widget _buildEmptyChartPlaceholder(
      ThemeData theme, String message, bool isAguardando) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              isAguardando
                  ? Icons.hourglass_empty_rounded
                  : Icons.info_outline_rounded,
              size: 40,
              color: Colors.grey.shade500),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
