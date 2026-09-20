import 'package:flutter/material.dart';
import '../../../core/services/collector_service.dart';
import '../../../core/theme/app_theme.dart';
import 'order_assignment_screen.dart';
import 'collector_tracking_screen.dart';
import 'assignment_history_screen.dart';
import '../../widgets/warehouse/add_collector_dialog.dart';
import '../../widgets/warehouse/dispatch_task_dialog.dart';

class CollectorManagementScreen extends StatefulWidget {
  const CollectorManagementScreen({super.key});

  @override
  State<CollectorManagementScreen> createState() => _CollectorManagementScreenState();
}

class _CollectorManagementScreenState extends State<CollectorManagementScreen> {
  final CollectorService _collectorService = CollectorService();
  late Future<List<dynamic>> _collectorsFuture;

  @override
  void initState() {
    super.initState();
    _loadCollectors();
  }

  void _loadCollectors() {
    setState(() {
      _collectorsFuture = _collectorService.getCollectors();
    });
  }

  void _showAddCollectorDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCollectorDialog(),
    ).then((added) {
      if (added == true) {
        _loadCollectors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Management'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCollectorDialog,
        label: const Text('Add Collector'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _collectorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final collectors = snapshot.data ?? [];

          if (collectors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No collectors found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add a collector to start managing pickups'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: collectors.length,
            itemBuilder: (context, index) {
              final collector = collectors[index];
              final profile = collector['collectorProfile'] ?? {};
              final availability = profile['availabilityStatus'] ?? 'OFFLINE';
              
              final isBusy = availability == 'BUSY';
              final isOffline = availability == 'OFFLINE';
              final isIdle = !isBusy && !isOffline;

              final completedTasks = profile['completedTasks'] ?? 0;
              final totalCollectedKg = (profile['totalCollectedKg'] ?? 0).toDouble();

              Color statusColor = Colors.grey;
              String statusText = 'Offline';
              if (isBusy) {
                statusColor = Colors.orange[800]!;
                statusText = 'On Assignment';
              } else if (isIdle) {
                statusColor = Colors.green[700]!;
                statusText = 'Idle';
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Avatar, Name, Status Badge
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: collector['profileImage'] != null
                                ? NetworkImage(collector['profileImage'])
                                : null,
                            child: collector['profileImage'] == null
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  collector['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ID: ${collector['collectorId']}',
                                  style: TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Contact & Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${collector['contactNo']}',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                  ),
                                ],
                              ),
                              if (collector['plainPassword'] != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.lock_open, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Pass: ${collector['plainPassword']}',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Completed: $completedTasks tasks',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Collected: ${totalCollectedKg.toStringAsFixed(1)} kg',
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      
                      // Actions row
                      Row(
                        children: [
                          // 1. Assign Orders
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isBusy
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderAssignmentScreen(collector: collector),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          _loadCollectors();
                                        }
                                      });
                                    },
                              icon: const Icon(Icons.assignment_add, size: 16),
                              label: const Text('Assign', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                foregroundColor: AppTheme.primaryGreen,
                                side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.5)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // 2. Track Live
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: !isBusy
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CollectorTrackingScreen(collector: collector),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.location_searching, size: 16),
                              label: const Text('Track Live', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                foregroundColor: Colors.blue[700],
                                side: BorderSide(color: Colors.blue.withOpacity(0.5)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // 3. View History
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AssignmentHistoryScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history, size: 16),
                              label: const Text('History', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                foregroundColor: Colors.grey[800],
                                side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

