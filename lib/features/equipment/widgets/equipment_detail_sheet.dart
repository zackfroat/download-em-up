import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/equipment_maintenance_item.dart';
import 'equipment_flowchart_modal.dart';

/// Interactive modal sheet to view and advance equipment through the maintenance SOP flowchart
class EquipmentDetailSheet extends StatefulWidget {
  final EquipmentMaintenanceItem item;
  final ValueChanged<EquipmentMaintenanceItem> onUpdate;

  const EquipmentDetailSheet({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<EquipmentDetailSheet> createState() => _EquipmentDetailSheetState();
}

class _EquipmentDetailSheetState extends State<EquipmentDetailSheet> {
  late EquipmentMaintenanceItem _item;
  final _issueController = TextEditingController();
  final _workScopeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _issueController.text = _item.outstandingIssuesReport ?? '';
    _workScopeController.text = _item.requestWorkScope ?? '';
  }

  @override
  void dispose() {
    _issueController.disposeValidate();
    _workScopeController.dispose();
    super.dispose();
  }

  void _updateItem(EquipmentMaintenanceItem updated) {
    setState(() => _item = updated);
    widget.onUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle & top bar
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: Color(0xFFF97316),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _item.equipmentName,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${_item.equipmentCode} • ${_item.brandAndModel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => EquipmentFlowchartModal(
                        activeStage: _item.stage,
                      ),
                    );
                  },
                  icon: const Icon(Icons.account_tree_rounded, size: 16),
                  label: const Text('Flowchart'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF97316),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lifecycle Stage Banner
                  _buildStageBanner(),

                  const SizedBox(height: 18),

                  // Machine Specifications & Baseline (Steps 1-3)
                  _buildSpecificationsCard(),

                  const SizedBox(height: 18),

                  // Store Team Schedule & Calendar Synchronization (Steps 4-5)
                  _buildCalendarScheduleCard(),

                  const SizedBox(height: 18),

                  // Automated Reminders Status (Steps 6-9)
                  _buildRemindersTimelineCard(),

                  const SizedBox(height: 18),

                  // PIC Maintenance Application (Step 10)
                  _buildPicApplicationCard(),

                  const SizedBox(height: 18),

                  // Maintenance Execution & Form Upload (Steps 11-13)
                  _buildMaintenanceExecutionCard(),

                  const SizedBox(height: 18),

                  // Decision Gateway: Has Maintenance Been Completed Satisfactorily? (Step 14)
                  _buildDecisionGatewayCard(),

                  const SizedBox(height: 18),

                  // Final System Records & Next Cycle (Steps 15-16)
                  if (_item.stage == EquipmentMaintenanceStage.cycleUpdated ||
                      _item.stage == EquipmentMaintenanceStage.picVerified)
                    _buildCompletedNextCycleCard(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageBanner() {
    final stage = _item.stage;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: stage.badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stage.badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: stage.badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'STEP ${stage.stepNumber}/8',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.displayName,
                  style: TextStyle(
                    color: stage.badgeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  _getStageDescription(stage),
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStageDescription(EquipmentMaintenanceStage stage) {
    switch (stage) {
      case EquipmentMaintenanceStage.registration:
        return 'Machinery registered with technical specs, warranty & wear assessment.';
      case EquipmentMaintenanceStage.scheduleRecorded:
        return 'Estimated schedule entered by Store Team and recorded into Calendar.';
      case EquipmentMaintenanceStage.reminderActive:
        return 'Automated reminders queued: 1 Month, 1 Week, and 3 Days prior to maintenance.';
      case EquipmentMaintenanceStage.requestSubmitted:
        return 'Equipment PIC submitted official maintenance application / request.';
      case EquipmentMaintenanceStage.maintenanceInProgress:
        return 'Maintenance Team is currently executing on-site overhaul & inspection.';
      case EquipmentMaintenanceStage.formUploaded:
        return 'Maintenance form uploaded. Pending Equipment PIC satisfactory verification.';
      case EquipmentMaintenanceStage.issuesReported:
        return 'PIC flagged outstanding defects. Sent back to Maintenance Team for rectification.';
      case EquipmentMaintenanceStage.picVerified:
        return 'Equipment PIC verified and confirmed satisfactory completion.';
      case EquipmentMaintenanceStage.cycleUpdated:
        return 'System updated maintenance logs and synchronized next calendar maintenance cycle.';
    }
  }

  Widget _buildSpecificationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.darkText),
              const SizedBox(width: 8),
              const Text(
                'Machinery Specifications & Status (Steps 1-3)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.darkText),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _item.wearAndTear.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _item.wearAndTear.color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _item.wearAndTear.label,
                  style: TextStyle(
                    color: _item.wearAndTear.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _item.specifications,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 480;
              if (isMobile) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildSpecItem('Operating Hours', '${_item.operatingHours} hrs', Icons.timer_outlined),
                        _buildSpecItem('Serial No.', _item.serialNumber, Icons.qr_code_2_rounded),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildSpecItem('Location Site', _item.locationSite, Icons.place_outlined),
                        _buildSpecItem('Category', _item.category, Icons.category_outlined),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildSpecItem('Warranty Expiry', _formatDate(_item.warrantyExpiry), Icons.verified_user_outlined),
                        _buildSpecItem('PMA / Statutory', _formatDate(_item.roadTaxOrInspectionExpiry), Icons.assignment_outlined),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      _buildSpecItem('Operating Hours', '${_item.operatingHours} hrs', Icons.timer_outlined),
                      _buildSpecItem('Serial No.', _item.serialNumber, Icons.qr_code_2_rounded),
                      _buildSpecItem('Location Site', _item.locationSite, Icons.place_outlined),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSpecItem('Warranty Expiry', _formatDate(_item.warrantyExpiry), Icons.verified_user_outlined),
                      _buildSpecItem('PMA / Statutory Expiry', _formatDate(_item.roadTaxOrInspectionExpiry), Icons.assignment_outlined),
                      _buildSpecItem('Category', _item.category, Icons.category_outlined),
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

  Widget _buildSpecItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.darkText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_rounded, size: 18, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              const Text(
                'Store Team Schedule & Calendar Sync (Steps 4-5)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF14532D)),
              ),
              const Spacer(),
              if (_item.isCalendarSynced)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16A34A)),
                      SizedBox(width: 4),
                      Text(
                        'CALENDAR SYNCED',
                        style: TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Target Maintenance Date: ${_formatDate(_item.scheduledMaintenanceDate)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF14532D),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _item.estimatedScheduleNotes,
            style: const TextStyle(fontSize: 12, color: Color(0xFF166534)),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active_rounded, size: 18, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'Automated Reminders & PIC Notification (Steps 6-9)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF78350F)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildReminderBadge('1st Reminder', '1 Month Before', _item.reminder1MonthSent),
              const SizedBox(width: 8),
              _buildReminderBadge('2nd Reminder', '1 Week Before', _item.reminder1WeekSent),
              const SizedBox(width: 8),
              _buildReminderBadge('3rd Reminder', '3 Days Before', _item.reminder3DaysSent),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFFEF3C7),
                  child: Icon(Icons.person_rounded, size: 16, color: Color(0xFFB45309)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Equipment PIC: ${_item.equipmentPic}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                      ),
                      Text(
                        'Contact: ${_item.picContact} • Notified via automated mobile & email push',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderBadge(String label, String timing, bool sent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: sent ? const Color(0xFFFEF3C7) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: sent ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Icon(
              sent ? Icons.check_circle_rounded : Icons.schedule_rounded,
              size: 16,
              color: sent ? const Color(0xFFD97706) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: sent ? const Color(0xFF78350F) : Colors.grey.shade600,
              ),
            ),
            Text(
              timing,
              style: TextStyle(
                fontSize: 9.5,
                color: sent ? const Color(0xFF92400E) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicApplicationCard() {
    final submitted = _item.picRequestSubmitted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              const Text(
                'Equipment PIC Maintenance Request (Step 10)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF312E81)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: submitted
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  submitted ? 'APPLICATION LOGGED' : 'ACTION REQUIRED',
                  style: TextStyle(
                    color: submitted ? const Color(0xFF059669) : const Color(0xFFD97706),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (submitted) ...[
            Text(
              'Work Scope: ${_item.requestWorkScope ?? "Standard preventative maintenance & inspection"}',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF312E81)),
            ),
            if (_item.requestSubmittedDate != null)
              Text(
                'Submitted on: ${_formatDate(_item.requestSubmittedDate!)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF4338CA)),
              ),
          ] else ...[
            const Text(
              'The Equipment PIC must formally submit the maintenance request to dispatch the maintenance team.',
              style: TextStyle(fontSize: 12, color: Color(0xFF4338CA)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _workScopeController,
              decoration: const InputDecoration(
                hintText: 'Enter specific maintenance work scope or symptoms...',
                isDense: true,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                final scope = _workScopeController.text.trim().isEmpty
                    ? 'General preventative servicing & mechanical inspection'
                    : _workScopeController.text.trim();
                _updateItem(
                  _item.copyWith(
                    picRequestSubmitted: true,
                    requestSubmittedDate: DateTime.now(),
                    requestWorkScope: scope,
                    stage: EquipmentMaintenanceStage.maintenanceInProgress,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maintenance request submitted! Maintenance Team dispatched.'),
                    backgroundColor: Color(0xFF4F46E5),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Submit Maintenance Request as PIC'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaintenanceExecutionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.engineering_rounded, size: 18, color: Color(0xFFEA580C)),
              const SizedBox(width: 8),
              const Text(
                'Maintenance Team Execution & Form (Steps 11-13)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF7C2D12)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _item.maintenanceFormUploaded
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFEA580C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _item.maintenanceFormUploaded ? 'FORM UPLOADED' : 'IN PROGRESS',
                  style: TextStyle(
                    color: _item.maintenanceFormUploaded ? const Color(0xFF059669) : const Color(0xFFC2410C),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Assigned Team: ${_item.assignedMaintenanceTeam}',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF7C2D12)),
          ),
          const SizedBox(height: 6),
          if (_item.maintenanceFormUploaded) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFD8A8)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _item.maintenanceFormName ?? 'Maintenance_Service_Report.pdf',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          _item.maintenanceFormNotes ?? 'Servicing notes logged by technical crew',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'Maintenance Team carries out servicing. Once completed, upload the signed maintenance form.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9A3412)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                _updateItem(
                  _item.copyWith(
                    maintenanceFormUploaded: true,
                    maintenanceFormName: '${_item.equipmentCode}_Service_Report.pdf',
                    maintenanceFormNotes: 'All lubricants and filter replacements verified. Ready for PIC inspection.',
                    formUploadedDate: DateTime.now(),
                    stage: EquipmentMaintenanceStage.formUploaded,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maintenance form uploaded! System notified Equipment PIC for verification.'),
                    backgroundColor: Color(0xFFEA580C),
                  ),
                );
              },
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: const Text('Upload Completed Maintenance Form into System'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEA580C),
                side: const BorderSide(color: Color(0xFFEA580C)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDecisionGatewayCard() {
    final isAwaitingDecision = _item.stage == EquipmentMaintenanceStage.formUploaded ||
        _item.stage == EquipmentMaintenanceStage.issuesReported;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAwaitingDecision ? const Color(0xFFFBBF24) : const Color(0xFF334155),
          width: isAwaitingDecision ? 2 : 1,
        ),
        boxShadow: isAwaitingDecision
            ? [
                BoxShadow(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                  blurRadius: 12,
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.gavel_rounded, color: Color(0xFFFBBF24), size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FLOWCHART DECISION (Step 14)',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Has Maintenance Been Completed Satisfactorily?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'The Equipment PIC conducts a physical run test & checks the uploaded service report against manufacturer specifications.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 16),

          // If issues reported already:
          if (_item.stage == EquipmentMaintenanceStage.issuesReported) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF451A1A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'DECISION: NO (Defects / Issues Reported)',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PIC Report: ${_item.outstandingIssuesReport ?? "Defects logged"}',
                    style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '↺ Status: Looped back to Step 11. Maintenance Team notified to carry out rectification.',
                    style: TextStyle(color: Color(0xFFF87171), fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Decision Action Buttons (Adaptive for Mobile)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;

              final yesButton = ElevatedButton.icon(
                onPressed: _confirmSatisfactoryCompletion,
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text('YES - Satisfactory'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              );

              final noButton = OutlinedButton.icon(
                onPressed: _showReportIssuesDialog,
                icon: const Icon(Icons.report_problem_rounded, size: 18),
                label: const Text('NO - Report Issues'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  const SizedBox(width: 12),
                  Expanded(child: noButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmSatisfactoryCompletion() {
    final nextDate = DateTime.now().add(const Duration(days: 180)); // Next 6 months
    _updateItem(
      _item.copyWith(
        isSatisfactory: true,
        picVerificationDate: DateTime.now(),
        nextMaintenanceCycleDate: nextDate,
        wearAndTear: WearAndTearStatus.good,
        stage: EquipmentMaintenanceStage.cycleUpdated,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verified by PIC! Maintenance records and Next Calendar Cycle (${_formatDate(nextDate)}) updated.',
        ),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showReportIssuesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.report_problem_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Report Outstanding Issues'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe the defects observed during the run test. Per flowchart, this loops back to the Maintenance Team (Step 11).',
              style: TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _issueController,
              decoration: const InputDecoration(
                hintText: 'e.g. Oil leakage at main cylinder, unusual engine knocking...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              final issues = _issueController.text.trim().isEmpty
                  ? 'Defects flagged during PIC run test. Re-servicing required.'
                  : _issueController.text.trim();
              Navigator.pop(ctx);
              _updateItem(
                _item.copyWith(
                  isSatisfactory: false,
                  outstandingIssuesReport: issues,
                  stage: EquipmentMaintenanceStage.issuesReported,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issues reported to Maintenance Team! Re-servicing required.'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Back to Maintenance Team'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedNextCycleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.task_alt_rounded, size: 20, color: Color(0xFF059669)),
              SizedBox(width: 8),
              Text(
                'Maintenance Records & Calendar Updated (Steps 15-16)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF065F46)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '✓ Verified and signed off by PIC on ${_formatDate(_item.picVerificationDate ?? DateTime.now())}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF047857)),
          ),
          if (_item.nextMaintenanceCycleDate != null) ...[
            const SizedBox(height: 4),
            Text(
              '✓ Next Scheduled Maintenance Cycle: ${_formatDate(_item.nextMaintenanceCycleDate!)} (Calendar Synced)',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

extension on TextEditingController {
  void disposeValidate() {
    dispose();
  }
}
