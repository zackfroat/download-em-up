import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/procurement_order.dart';

/// Top visual pipeline & metrics widget for Material Tracking & Procurement
class WorkflowPipelineWidget extends StatelessWidget {
  final List<ProcurementOrder> orders;
  final VoidCallback onViewDiagram;

  const WorkflowPipelineWidget({
    super.key,
    required this.orders,
    required this.onViewDiagram,
  });

  @override
  Widget build(BuildContext context) {
    final pendingReadiness = orders
        .where((o) => o.stage == ProcurementWorkflowStage.siteReadinessCheck)
        .length;
    final scheduled = orders
        .where((o) => o.stage == ProcurementWorkflowStage.deliveryScheduled)
        .length;
    final shortage = orders
        .where((o) => o.stage == ProcurementWorkflowStage.shortageHandling)
        .length;
    final completed =
        orders.where((o) => o.stage == ProcurementWorkflowStage.completed).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner with flowchart button (Mobile Adaptive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 540;

              final titleRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.schema_rounded,
                    color: AppColors.teal,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Procurement Lifecycle Pipeline',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              );

              final button = OutlinedButton.icon(
                onPressed: onViewDiagram,
                icon: const Icon(Icons.account_tree_rounded, size: 16),
                label: const Text('View Flowchart'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(color: AppColors.teal, width: 1.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: button),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleRow,
                  button,
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Metric Badges Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 580;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isWide ? 2.2 : 2.0,
                children: [
                  _buildMetricCard(
                    title: 'Readiness Check',
                    count: '$pendingReadiness',
                    color: const Color(0xFFF59E0B),
                    icon: Icons.checklist_rounded,
                  ),
                  _buildMetricCard(
                    title: 'Scheduled',
                    count: '$scheduled',
                    color: const Color(0xFF0D9488),
                    icon: Icons.calendar_month_rounded,
                  ),
                  _buildMetricCard(
                    title: 'Shortage Alerts',
                    count: '$shortage',
                    color: const Color(0xFFEF4444),
                    icon: Icons.warning_amber_rounded,
                  ),
                  _buildMetricCard(
                    title: 'Completed (POD)',
                    count: '$completed',
                    color: const Color(0xFF10B981),
                    icon: Icons.verified_rounded,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          Icon(icon, color: color, size: 22),
        ],
      ),
    );
  }
}

