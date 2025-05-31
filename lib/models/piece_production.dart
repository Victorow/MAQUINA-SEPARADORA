// lib/models/piece_production.dart
import 'package:equatable/equatable.dart';

class PieceProduction extends Equatable {
  final int id;
  final DateTime dateTime;
  final int corId;
  final int materialId;
  final int tamanhoId;
  final String? cor; // Optional, if joined
  final String? material; // Optional, if joined
  final String? tamanho; // Optional, if joined

  const PieceProduction({
    required this.id,
    required this.dateTime,
    required this.corId,
    required this.materialId,
    required this.tamanhoId,
    this.cor,
    this.material,
    this.tamanho,
  });

  @override
  List<Object?> get props => [id, dateTime, corId, materialId, tamanhoId, cor, material, tamanho];
}