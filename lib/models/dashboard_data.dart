import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final int totalPiecesToday;
  final double successRate;
  final int activeAlerts;
  final List<ProductionByHour> productionByHour;
  final List<ProductionByDestination> productionByDestination;
  final List<RecentActivity> recentActivities;

  const DashboardData({
    required this.totalPiecesToday,
    required this.successRate,
    required this.activeAlerts,
    required this.productionByHour,
    required this.productionByDestination,
    required this.recentActivities,
  });

  @override
  List<Object?> get props => [
        totalPiecesToday,
        successRate,
        activeAlerts,
        productionByHour,
        productionByDestination,
        recentActivities,
      ];
}

class ProductionByHour extends Equatable {
  final int hour;
  final int count;

  const ProductionByHour({required this.hour, required this.count});

  @override
  List<Object?> get props => [hour, count];
}

class ProductionByDestination extends Equatable {
  final String destination;
  final int count;

  const ProductionByDestination({required this.destination, required this.count});

  @override
  List<Object?> get props => [destination, count];
}

class RecentActivity extends Equatable {
  final DateTime timestamp;
  final String operation;
  final String status;
  final String pieceType;
  final String destination;

  const RecentActivity({
    required this.timestamp,
    required this.operation,
    required this.status,
    required this.pieceType,
    required this.destination,
  });

  @override
  List<Object?> get props => [timestamp, operation, status, pieceType, destination];
}
