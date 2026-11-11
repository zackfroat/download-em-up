import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/safety_flowchart_model.dart';

/// Interactive modal sheet to review, issue NCR, track corrective actions, or issue RED CARD
class SafetyIncidentDetailSheet extends StatefulWidget {
  final SafetyIncidentRecord record;
  final Function(SafetyIncidentRecord updated) onUpdateRecord;

  const SafetyIncidentDetailSheet({
    super.key,
    required this.record,
    required this.onUpdateRecord,
  });

  @override
  State<SafetyIncidentDetailSheet> createState() => _SafetyIncidentDetailSheetState();
}

class _SafetyIncidentDetailSheetState extends State<SafetyIncidentDetailSheet> {
  late SafetyIncidentRecord _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  void _advanceToNcr() {
    setState(() {
      _record = _record.copyWith(
        stage: SafetyFlowStage.ncrIssued,
        ncrNumber: 'NCR-SAF-2026-${_record.id.split('-').last}',
        violationCount: _record.violationCount + 1,
        violationDetails: 'Safety violation formally registered by safety officer during surveillance.',
      );
    });
    widget.onUpdateRecord(_record);
  }

  void _verifyCorrectiveAction() {
    setState(() {
      _record = _record.copyWith(
        stage: SafetyFlowStage.correctiveActionVerified,
        correctiveAction: 'Rectification inspected on site. Safety barrier reinstated & PPE re-issued.',
      );
    });
    widget.onUpdateRecord(_record);
  }

  void _issueRedCard() {
    setState(() {
      _record = _record.copyWith(
        stage: SafetyFlowStage.redCardIssued,
        violationCount: 3,
        correctiveAction: 'Worker reached 3 violations. RED CARD issued. Permanent site exclusion.',
      );
    });
    widget.onUpdateRecord(_record);
  }

  void _markAuditedAndCompliant() {
    setState(() {
      _record = _record.copyWith(
        stage: SafetyFlowStage.compliantAndAudited,
      );
    });
    widget.onUpdateRecord(_record);
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;

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
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: record.stage.badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: record.stage.badgeColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      record.stage.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: record.stage.badgeColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.id,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        record.subcontractorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Decision Flow Action Box
                  _buildDecisionGatewayBox(record),

                  const SizedBox(height: 20),

                  // Record Details Card
                  _buildDetailsCard(record),

                  const SizedBox(height: 20),

                  // Subcontractor & Worker Info
                  _buildWorkerInfoCard(record),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionGatewayBox(SafetyIncidentRecord record) {
    if (record.stage == SafetyFlowStage.redCardIssued) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dangerous_rounded, color: Color(0xFFDC2626), size: 24),
                SizedBox(width: 8),
                Text(
                  'RED CARD ISSUED — WORKER EXCLUDED',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              'Worker has committed 3 safety infractions. Under site SOP, badge is revoked and worker is permanently removed. Subcontractor SPI score penalized.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF7F1D1D), height: 1.3),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: record.stage.badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: record.stage.badgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alt_route_rounded, color: record.stage.badgeColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Flowchart Step: ${record.stage.displayName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: record.stage.badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Adaptive Action Buttons based on Stage
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;

              if (record.stage == SafetyFlowStage.monitoringActivities) {
                return isNarrow
                    ? Column(
                        children: [
                          _buildActionButton(
                            label: 'Issue Non-Conformance Report (NCR)',
                            icon: Icons.assignment_late_rounded,
                            color: const Color(0xFFD97706),
                            onTap: _advanceToNcr,
                          ),
                          const SizedBox(height: 8),
                          _buildActionButton(
                            label: 'Mark Safe & Compliance Audited',
                            icon: Icons.verified_rounded,
                            color: const Color(0xFF10B981),
                            onTap: _markAuditedAndCompliant,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              label: 'Issue NCR',
                              icon: Icons.assignment_late_rounded,
                              color: const Color(0xFFD97706),
                              onTap: _advanceToNcr,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildActionButton(
                              label: 'Audit & Pass',
                              icon: Icons.verified_rounded,
                              color: const Color(0xFF10B981),
                              onTap: _markAuditedAndCompliant,
                            ),
                          ),
                        ],
                      );
              }

              if (record.stage == SafetyFlowStage.ncrIssued) {
                return isNarrow
                    ? Column(
                        children: [
                          _buildActionButton(
                            label: 'Verify Corrective Action Implemented',
                            icon: Icons.check_circle_outline_rounded,
                            color: const Color(0xFF2563EB),
                            onTap: _verifyCorrectiveAction,
                          ),
                          const SizedBox(height: 8),
                          _buildActionButton(
                            label: 'Issue RED CARD (3rd Violation)',
                            icon: Icons.warning_rounded,
                            color: const Color(0xFFDC2626),
                            onTap: _issueRedCard,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              label: 'Verify Action',
                              icon: Icons.check_circle_outline_rounded,
                              color: const Color(0xFF2563EB),
                              onTap: _verifyCorrectiveAction,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildActionButton(
                              label: 'Issue Red Card',
                              icon: Icons.warning_rounded,
                              color: const Color(0xFFDC2626),
                              onTap: _issueRedCard,
                            ),
                          ),
                        ],
                      );
              }

              return SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  label: 'Complete Safety Audit Record',
                  icon: Icons.task_alt_rounded,
                  color: const Color(0xFF10B981),
                  onTap: _markAuditedAndCompliant,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(SafetyIncidentRecord record) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity & Incident Specification',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Activity', record.activityDescription),
          _buildInfoRow('Project Site', record.projectSite),
          if (record.ncrNumber != null) _buildInfoRow('NCR Reference', record.ncrNumber!),
          if (record.violationDetails != null)
            _buildInfoRow('Violation Details', record.violationDetails!),
          if (record.correctiveAction != null)
            _buildInfoRow('Corrective Action', record.correctiveAction!),
        ],
      ),
    );
  }

  Widget _buildWorkerInfoCard(SafetyIncidentRecord record) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subcontractor & Personnel Record',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Subcontractor', record.subcontractorName),
          _buildInfoRow('Involved Worker', '${record.workerName} (${record.workerId})'),
          _buildInfoRow(
            'Violation Strike',
            '${record.violationCount} of 3 (Strike 3 = Immediate Red Card Exclusion)',
          ),
          _buildInfoRow(
            'Site Induction',
            record.isInductionDone ? 'Verified & Uploaded' : 'Pending Induction',
          ),
          _buildInfoRow(
            'Monthly Training',
            record.isMonthlyTrainingLogged ? 'Attended & Signed' : 'Pending Session',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelWidth = constraints.maxWidth < 400 ? 115.0 : 145.0;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

