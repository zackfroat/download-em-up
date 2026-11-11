import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/procurement_order.dart';

/// Modal dialog illustrating the full Material Tracking & Procurement flowchart
/// exactly as diagrammed in the official process flowchart.
class WorkflowDiagramDialog extends StatelessWidget {
  final ProcurementWorkflowStage? activeStage;

  const WorkflowDiagramDialog({
    super.key,
    this.activeStage,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 20,
        vertical: isMobile ? 12 : 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 820),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_tree_rounded,
                      color: AppColors.emeraldAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Procurement & Material Tracking Workflow',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Official Standard Operating Flowchart (PO Approval to POD Verification)',
                          style: TextStyle(
                            fontSize: 12,
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

            // Scrollable Flowchart canvas
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildStartPill('START'),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'PO Approved by Management',
                          subtitle: 'Management signs off on requested purchase order',
                          isActive: activeStage == ProcurementWorkflowStage.poApproved,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Finance Proceeds with Payment',
                          subtitle: 'Advance or milestone disbursement executed',
                          isActive: activeStage == ProcurementWorkflowStage.poApproved,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Procurement Notified to Contact Supplier',
                          subtitle: 'Purchasing team transmits purchase order to vendor',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.supplierContacted,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Procurement Obtains Proposed Delivery Date from Supplier',
                          subtitle: 'Estimated dispatch timestamp provided by supplier',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.supplierContacted,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Discuss Delivery Date with Project Team',
                          subtitle: 'Coordination between site supervisor and engineers',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.siteReadinessCheck,
                        ),
                        _buildArrowDown(),

                        // Decision 1: Is Site Ready for Delivery?
                        _buildDecisionCard(
                          question: 'Is Site Ready for Delivery?',
                          yesLabel: 'Confirm Delivery Date',
                          noLabel: 'Reschedule Delivery with Supplier',
                          isYesActive: activeStage ==
                                  ProcurementWorkflowStage.deliveryScheduled ||
                              activeStage ==
                                  ProcurementWorkflowStage.siteStockTake ||
                              activeStage ==
                                  ProcurementWorkflowStage.doVerification ||
                              activeStage == ProcurementWorkflowStage.completed,
                          isNoActive: activeStage ==
                              ProcurementWorkflowStage.siteReadinessCheck,
                        ),

                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Record Delivery Date and Details in Shared Calendar',
                          subtitle: 'Shared site operations calendar integration',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.deliveryScheduled,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Calendar Sends Email Notification to Project Team',
                          subtitle: 'Automated email dispatch to relevant engineers',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.deliveryScheduled,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: '3 Days Before Delivery: Automatic Reminder Email',
                          subtitle: 'Early alert reminder sent to site engineers',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.deliveryScheduled,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Email Includes Date, Time and Material Details',
                          subtitle: 'Specifications, delivery bay, and crane slot allocation',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.deliveryScheduled,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Delivery Day: Calendar Notifies Site PIC',
                          subtitle: 'Site Person-In-Charge alerted for delivery intake',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.siteStockTake,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Supplier Delivers Materials to Site',
                          subtitle: 'Physical arrival at site staging and uncoupling zone',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.siteStockTake,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Site Team Conducts Stock Take',
                          subtitle: 'Visual tally and physical tally of delivered lots',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.siteStockTake,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Check Actual Quantity Against PO and Delivery Order',
                          subtitle: 'Discrepancy inspection vs manifests',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.siteStockTake,
                        ),
                        _buildArrowDown(),

                        // Decision 2: Is Material Quantity Complete?
                        _buildDecisionCard(
                          question: 'Is Material Quantity Complete?',
                          yesLabel: 'Site PIC Confirms Material Receipt',
                          noLabel: 'Record Shortage & Arrange Outstanding Delivery',
                          isYesActive: activeStage ==
                                  ProcurementWorkflowStage.doVerification ||
                              activeStage == ProcurementWorkflowStage.completed,
                          isNoActive: activeStage ==
                              ProcurementWorkflowStage.shortageHandling,
                        ),

                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Receive and Verify Delivery Order (DO)',
                          subtitle: 'Match physical delivery order stamp & vendor signature',
                          isActive: activeStage ==
                              ProcurementWorkflowStage.doVerification,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Upload Proof of Delivery and DO into System',
                          subtitle: 'Digital archival, photo evidence, and closed status',
                          isActive:
                              activeStage == ProcurementWorkflowStage.completed,
                        ),
                        _buildArrowDown(),
                        _buildStartPill('FINISH', isEnd: true),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartPill(String label, {bool isEnd = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
      decoration: BoxDecoration(
        color: isEnd ? const Color(0xFF10B981) : const Color(0xFF0F766E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildArrowDown() {
    return Column(
      children: [
        Container(
          width: 2,
          height: 16,
          color: AppColors.borderLight,
        ),
        const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSubtle),
      ],
    );
  }

  Widget _buildProcessBox({
    required String title,
    required String subtitle,
    bool isActive = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.teal.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.teal : AppColors.borderLight,
          width: isActive ? 2.0 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? AppColors.teal : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionCard({
    required String question,
    required String yesLabel,
    required String noLabel,
    required bool isYesActive,
    required bool isNoActive,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.help_outline_rounded,
                  color: Color(0xFFD97706), size: 18),
              const SizedBox(width: 6),
              Text(
                question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;

              final yesWidget = Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isYesActive ? const Color(0xFFDCFCE7) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isYesActive ? const Color(0xFF16A34A) : AppColors.borderLight,
                    width: isYesActive ? 1.8 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '✓ YES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      yesLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              );

              final noWidget = Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isNoActive ? const Color(0xFFFEE2E2) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isNoActive ? const Color(0xFFDC2626) : AppColors.borderLight,
                    width: isNoActive ? 1.8 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '✕ NO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    yesWidget,
                    const SizedBox(height: 8),
                    noWidget,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: yesWidget),
                  const SizedBox(width: 10),
                  Expanded(child: noWidget),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

