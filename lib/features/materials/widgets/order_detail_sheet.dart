import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/procurement_order.dart';

/// Interactive modal sheet letting the user inspect and advance an order
/// along the exact steps of the procurement flowchart.
class OrderDetailSheet extends StatefulWidget {
  final ProcurementOrder order;
  final Function(ProcurementOrder updated) onUpdateOrder;

  const OrderDetailSheet({
    super.key,
    required this.order,
    required this.onUpdateOrder,
  });

  @override
  State<OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends State<OrderDetailSheet> {
  late ProcurementOrder _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  void _advanceToNextStage(ProcurementOrder updated) {
    setState(() {
      _currentOrder = updated;
    });
    widget.onUpdateOrder(updated);
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: order.stage.badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: order.stage.badgeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    order.stage.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: order.stage.badgeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.poNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        order.supplierName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Next Recommended Flow Action Box
                  _buildWorkflowActionCard(order),

                  const SizedBox(height: 24),

                  // Order Summary Information
                  _buildSummaryInfo(order),

                  const SizedBox(height: 24),

                  // Material Items Manifest
                  _buildItemsManifest(order),

                  const SizedBox(height: 24),

                  // Calendar & Automated Reminders Status
                  _buildCalendarNotificationStatus(order),

                  const SizedBox(height: 24),

                  // Verification & DO Status
                  _buildDeliveryOrderVerificationStatus(order),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action Engine based on the exact Flowchart Logic
  // ---------------------------------------------------------------------------
  Widget _buildWorkflowActionCard(ProcurementOrder order) {
    switch (order.stage) {
      case ProcurementWorkflowStage.poApproved:
        return _buildActionContainer(
          icon: Icons.payments_rounded,
          color: const Color(0xFF6366F1),
          title: 'Finance Proceeding with Payment',
          description:
              'PO has been approved by management. Notify procurement to contact supplier and request proposed delivery date.',
          buttonLabel: 'Supplier Contacted & Obtain Proposed Date',
          onAction: () {
            final now = DateTime.now();
            _advanceToNextStage(
              order.copyWith(
                stage: ProcurementWorkflowStage.supplierContacted,
                proposedDeliveryDate: now.add(const Duration(days: 3)),
              ),
            );
          },
        );

      case ProcurementWorkflowStage.supplierContacted:
        return _buildActionContainer(
          icon: Icons.phone_in_talk_rounded,
          color: const Color(0xFF0284C7),
          title: 'Supplier Proposed Delivery Date Received',
          description:
              'Proposed Date: ${order.proposedDeliveryDate != null ? _formatDate(order.proposedDeliveryDate!) : "Pending"}.\nDiscuss proposed date with Site Project Team.',
          buttonLabel: 'Initiate Site Readiness Review',
          onAction: () {
            _advanceToNextStage(
              order.copyWith(
                stage: ProcurementWorkflowStage.siteReadinessCheck,
              ),
            );
          },
        );

      case ProcurementWorkflowStage.siteReadinessCheck:
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.help_outline_rounded,
                      color: Color(0xFFD97706), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Flowchart Decision: Is Site Ready for Delivery?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Verify site staging area, access clearances, crane availability, and weather conditions with project team.',
                style: TextStyle(fontSize: 13, color: Color(0xFF78350F)),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 460;

                  final yesButton = ElevatedButton.icon(
                    onPressed: () {
                      final confirmedDate = order.proposedDeliveryDate ??
                          DateTime.now().add(const Duration(days: 3));
                      _advanceToNextStage(
                        order.copyWith(
                          isSiteReady: true,
                          confirmedDeliveryDate: confirmedDate,
                          isCalendarNotified: true,
                          isThreeDayReminderSent: true,
                          stage: ProcurementWorkflowStage.deliveryScheduled,
                        ),
                      );
                      _showFeedback(
                          'Site Ready! Delivery confirmed & calendar notified.');
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 18),
                    label: const Text('YES - Confirm Date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );

                  final noButton = OutlinedButton.icon(
                    onPressed: () => _promptRescheduleDialog(order),
                    icon: const Icon(Icons.update_rounded, size: 18),
                    label: const Text('NO - Reschedule'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        SizedBox(width: double.infinity, child: yesButton),
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: noButton),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: yesButton),
                      const SizedBox(width: 10),
                      Expanded(child: noButton),
                    ],
                  );
                },
              ),
            ],
          ),
        );

      case ProcurementWorkflowStage.deliveryScheduled:
        return _buildActionContainer(
          icon: Icons.local_shipping_rounded,
          color: const Color(0xFF0D9488),
          title: 'Delivery Scheduled & Reminders Active',
          description:
              'Delivery scheduled for ${_formatDate(order.confirmedDeliveryDate ?? DateTime.now())}.\nCalendar notifications sent to project team and site PIC.',
          buttonLabel: 'Simulate Supplier Arrival & Conduct Stock Take',
          onAction: () {
            _advanceToNextStage(
              order.copyWith(
                isDeliveryDayNotified: true,
                stage: ProcurementWorkflowStage.siteStockTake,
              ),
            );
          },
        );

      case ProcurementWorkflowStage.siteStockTake:
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDD6FE), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_rounded,
                      color: Color(0xFF7C3AED), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Site Stock Take & Inspection',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B21B6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Site team conducts physical count and verifies actual count against PO & Delivery Order (DO).',
                style: TextStyle(fontSize: 13, color: Color(0xFF4C1D95)),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 460;

                  final completeButton = ElevatedButton.icon(
                    onPressed: () {
                      final updatedItems = order.items
                          .map((i) => i.copyWith(
                              actualQuantityReceived: i.orderedQuantity))
                          .toList();
                      _advanceToNextStage(
                        order.copyWith(
                          items: updatedItems,
                          deliveryOrderNumber:
                              order.deliveryOrderNumber ?? 'DO-VERIFIED-01',
                          stage: ProcurementWorkflowStage.doVerification,
                        ),
                      );
                      _showFeedback(
                          'Stock Take Complete! Site PIC confirms receipt.');
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Quantity 100% Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );

                  final shortageButton = OutlinedButton.icon(
                    onPressed: () => _promptShortageDialog(order),
                    icon: const Icon(Icons.warning_amber_rounded, size: 18),
                    label: const Text('Record Shortage (No)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        SizedBox(width: double.infinity, child: completeButton),
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: shortageButton),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: completeButton),
                      const SizedBox(width: 10),
                      Expanded(child: shortageButton),
                    ],
                  );
                },
              ),
            ],
          ),
        );

      case ProcurementWorkflowStage.shortageHandling:
        return _buildActionContainer(
          icon: Icons.report_problem_rounded,
          color: const Color(0xFFEF4444),
          title: 'Shortage Recorded - Supplier Notified',
          description:
              'Remarks: ${order.shortageRemarks ?? "Shortage logged"}.\nArranging outstanding material delivery batch with vendor.',
          buttonLabel: 'Receive Outstanding Material & Re-verify',
          onAction: () {
            // Fulfill the remaining quantities
            final updatedItems = order.items
                .map((i) =>
                    i.copyWith(actualQuantityReceived: i.orderedQuantity))
                .toList();
            _advanceToNextStage(
              order.copyWith(
                items: updatedItems,
                stage: ProcurementWorkflowStage.doVerification,
                deliveryOrderNumber:
                    order.deliveryOrderNumber ?? 'DO-RESOLVED-88',
              ),
            );
            _showFeedback('Outstanding delivery received and verified!');
          },
        );

      case ProcurementWorkflowStage.doVerification:
        return _buildActionContainer(
          icon: Icons.verified_user_rounded,
          color: const Color(0xFF059669),
          title: 'Site PIC Confirms Material Receipt',
          description:
              'Actual quantities verified against PO. Now receive, inspect, and stamp physical Delivery Order (DO).',
          buttonLabel: 'Upload Proof of Delivery (POD) & DO',
          onAction: () => _promptUploadPodDialog(order),
        );

      case ProcurementWorkflowStage.completed:
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workflow Finished: Material Received & DO Uploaded',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'All steps in the procurement monitoring workflow have been completed and verified.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF047857)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildActionContainer({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Summary & Item Manifest Views
  // ---------------------------------------------------------------------------
  Widget _buildSummaryInfo(ProcurementOrder order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Specifications & Destination',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow('Project Site Location', order.projectSite),
          _buildInfoRow('Vendor / Supplier', order.supplierName),
          _buildInfoRow('Supplier Contact', order.supplierContact),
          _buildInfoRow(
              'Site PIC Engineer', order.sitePicName ?? 'Kamal Ariffin'),
          _buildInfoRow('Date PO Issued', _formatDate(order.createdDate)),
          if (order.confirmedDeliveryDate != null)
            _buildInfoRow('Confirmed Delivery Date',
                _formatDate(order.confirmedDeliveryDate!)),
          if (order.rescheduleReason != null)
            _buildInfoRow(
                'Reschedule History', order.rescheduleReason!, isWarning: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isWarning ? AppColors.errorRed : AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsManifest(ProcurementOrder order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              const Text(
                'Materials Bill of Quantities',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                '${order.items.length} Line Items',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 16, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.specification,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.orderedQuantity} ${item.unit}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      if (item.actualQuantityReceived != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.isComplete
                              ? 'Received: ${item.actualQuantityReceived} ${item.unit}'
                              : 'Shortage: ${item.shortageQuantity} ${item.unit}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: item.isComplete
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarNotificationStatus(ProcurementOrder order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Automated Calendar & Notification Pipeline',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildNotificationCheckItem(
            'Recorded in Shared Calendar',
            order.isCalendarNotified,
            'Synchronized across site team calendar',
          ),
          const SizedBox(height: 8),
          _buildNotificationCheckItem(
            '3 Days Before Delivery: Automatic Reminder Email',
            order.isThreeDayReminderSent,
            'Email includes date, time, and material details',
          ),
          const SizedBox(height: 8),
          _buildNotificationCheckItem(
            'Delivery Day: Calendar Notifies Site PIC',
            order.isDeliveryDayNotified,
            'Direct SMS & push notification to on-site receiver',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCheckItem(
      String title, bool isDone, String subtitle) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: isDone ? AppColors.teal : AppColors.textSubtle,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDone ? AppColors.darkText : AppColors.textMuted,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryOrderVerificationStatus(ProcurementOrder order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Order (DO) & Proof of Delivery (POD)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Delivery Order Number',
            order.deliveryOrderNumber ?? 'Pending Physical Arrival',
          ),
          _buildInfoRow(
            'Proof of Delivery (POD)',
            order.proofOfDeliveryUrl != null
                ? 'Uploaded: ${order.proofOfDeliveryUrl}'
                : 'Pending Signed DO Upload',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog Helpers
  // ---------------------------------------------------------------------------
  void _promptRescheduleDialog(ProcurementOrder order) {
    final reasonController = TextEditingController(
      text: 'Site staging area blocked by tower crane mast installation.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reschedule Delivery with Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify reason site is not ready for delivery:',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _advanceToNextStage(
                order.copyWith(
                  isSiteReady: false,
                  rescheduleReason: reasonController.text.trim(),
                  proposedDeliveryDate:
                      DateTime.now().add(const Duration(days: 5)),
                  stage: ProcurementWorkflowStage.supplierContacted,
                ),
              );
              _showFeedback('Delivery rescheduled with supplier.');
            },
            child: const Text('Confirm Reschedule'),
          ),
        ],
      ),
    );
  }

  void _promptShortageDialog(ProcurementOrder order) {
    final remarksController = TextEditingController(
      text: 'Damaged batch / short 25 units. Arranging outstanding lot.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Shortage & Notify Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actual quantity does not match PO and DO. Record shortage details:',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe missing lot or items...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Mark partial receipt on items
              final updatedItems = order.items.map((i) {
                final received = (i.orderedQuantity * 0.75).round();
                return i.copyWith(actualQuantityReceived: received);
              }).toList();

              _advanceToNextStage(
                order.copyWith(
                  items: updatedItems,
                  shortageRemarks: remarksController.text.trim(),
                  stage: ProcurementWorkflowStage.shortageHandling,
                ),
              );
              _showFeedback('Shortage logged; Supplier notified.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Log Shortage'),
          ),
        ],
      ),
    );
  }

  void _promptUploadPodDialog(ProcurementOrder order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Proof of Delivery & DO'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Physical DO and site photo verification complete.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Row(
                children: [
                  Icon(Icons.attachment_rounded, color: AppColors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DO-Signed-Verified.pdf (2.4 MB)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _advanceToNextStage(
                order.copyWith(
                  proofOfDeliveryUrl: 'pod_archive_${order.id.toLowerCase()}.pdf',
                  stage: ProcurementWorkflowStage.completed,
                ),
              );
              _showFeedback('Workflow Finished! Order marked completed.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Complete & Upload POD'),
          ),
        ],
      ),
    );
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkText,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

