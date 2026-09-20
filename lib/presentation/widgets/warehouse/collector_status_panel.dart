import 'package:flutter/material.dart';

class CollectorStatusPanel extends StatelessWidget {
  final Map<String, dynamic> collector;
  final Map<String, dynamic>? activeTrip;
  final List<Map<String, dynamic>> tasks;

  const CollectorStatusPanel({
    super.key,
    required this.collector,
    this.activeTrip,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collector['name'] ?? 'Unknown Collector',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'ID: ${collector['collectorId'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (activeTrip?['status'] == 'IN_TRANSIT' ? Colors.green : Colors.blue).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  activeTrip?['status'] ?? 'ON ASSIGNMENT',
                  style: TextStyle(
                    color: activeTrip?['status'] == 'IN_TRANSIT' ? Colors.green[800] : Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          const Text(
            'Assigned Tasks Sequence:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'No active tasks found in this trip.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {
                      final t = tasks[i];
                      final status = t['status'] ?? 'ASSIGNED';
                      final isCompleted = status == 'COMPLETED';
                      final isPickedUp = status == 'PICKED_UP' || status == 'IN_TRANSIT';

                      Color statusColor = Colors.orange;
                      if (isCompleted) {
                        statusColor = Colors.green;
                      } else if (isPickedUp) {
                        statusColor = Colors.blue;
                      }

                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Stop #${i + 1}: Order #${t['orderId']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${t['materialCategory']} (${t['estimatedWeight']} kg)',
                              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status.toString().replaceAll('_', ' '),
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: statusColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
