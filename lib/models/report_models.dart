class ReportSummaryData {
  final int totalProcessed;
  final double successRate;

  const ReportSummaryData({
    required this.totalProcessed,
    required this.successRate,
  });
}

class DailyMaterialProduction {
  final DateTime date;
  final String material;
  final int count;

  DailyMaterialProduction({
    required this.date,
    required this.material,
    required this.count,
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
