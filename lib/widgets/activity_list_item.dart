// lib/widgets/activity_list_item.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_data.dart';

class ActivityListItem extends StatelessWidget {
  final RecentActivity activity;

  const ActivityListItem({super.key, required this.activity});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'concluída':
        return Colors.green;
      case 'em progresso':
        return Colors.orange;
      case 'erro':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd/MM/yyyy HH:mm:ss').format(activity.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(activity.operation, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(activity.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                activity.status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getStatusColor(activity.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(activity.pieceType, style: const TextStyle(fontSize: 12)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(activity.destination, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}