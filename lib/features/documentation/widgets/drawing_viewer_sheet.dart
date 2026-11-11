import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/drawing_verification_job.dart';

/// Modal sheet to inspect, access, verify, and advance a stub setting job through
/// the exact flowchart stages.
class DrawingViewerSheet extends StatefulWidget {
  final DrawingVerificationJob job;
  final Function(DrawingVerificationJob updated) onUpdateJob;

  const DrawingViewerSheet({
    super.key,
    required this.job,
    required this.onUpdateJob,
  });

  @override
  State<DrawingViewerSheet> createState() => _DrawingViewerSheetState();
}

class _DrawingViewerSheetState extends State<DrawingViewerSheet> {
  late DrawingVerificationJob _job;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  void _advanceJob(DrawingVerificationJob updated) {
    setState(() {
      _job = updated;
    });
    widget.onUpdateJob(updated);
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
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
                    color: job.stage.badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: job.stage.badgeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    job.stage.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: job.stage.badgeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.drawingFileName,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        '${job.projectSite} • ${job.towerFoundationId}',
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Flowchart Action Card
                  _buildFlowchartActionEngine(job),

                  const SizedBox(height: 24),

                  // Approved Engineering Drawing Inspection Box
                  _buildDrawingInspectorCard(job),

                  const SizedBox(height: 24),

                  // Theodolite Alignment & Survey Specification Card
                  _buildTheodoliteSpecificationCard(job),

                  const SizedBox(height: 24),

                  // Concreting & Post-Pour Verification Status
                  _buildConcretingInspectionStatus(job),

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
  // Flowchart Execution Engine
  // ---------------------------------------------------------------------------
  Widget _buildFlowchartActionEngine(DrawingVerificationJob job) {
    switch (job.stage) {
      case StubWorkflowStage.enterAccessCode:
        return _buildAccessCodeUnlockCard(job);

      case StubWorkflowStage.drawingRetrieved:
        return _buildActionBox(
          icon: Icons.cloud_download_rounded,
          color: const Color(0xFF0284C7),
          title: 'Approved Drawing Retrieved in System',
          description:
              'Approved AFC drawing is active. Download drawing file for offline reference at site, then identify correct stub setting number.',
          buttonLabel: 'Download for Offline Reference & Identify Stub',
          onAction: () {
            _advanceJob(
              job.copyWith(
                isDownloadedOffline: true,
                stage: StubWorkflowStage.theodoliteEntry,
              ),
            );
            _showFeedback(
                'Drawing downloaded for offline site reference! Stub identified.');
          },
        );

      case StubWorkflowStage.theodoliteEntry:
        return _buildTheodoliteInputCard(job);

      case StubWorkflowStage.superiorVerification:
        return _buildSuperiorVerificationDecisionCard(job);

      case StubWorkflowStage.correctionRequired:
        return _buildCorrectionActionCard(job);

      case StubWorkflowStage.proceedConcreting:
        return _buildActionBox(
          icon: Icons.foundation_rounded,
          color: const Color(0xFF0D9488),
          title: 'Setting Verified: Proceed with Stub Setting Concreting',
          description:
              'Superior verification passed! Site crew is cleared to pour concrete around stub template.',
          buttonLabel: 'Log Concreting Pour & Conduct Final Inspection',
          onAction: () => _promptConcretingInspectionDialog(job),
        );

      case StubWorkflowStage.finalInspection:
        return _buildActionBox(
          icon: Icons.checklist_rtl_rounded,
          color: const Color(0xFF8B5CF6),
          title: 'Concreting Poured: Conduct Final Inspection',
          description:
              'Check plumbness, diagonal tolerances, and stub setting coordinates post-concreting.',
          buttonLabel: 'Complete Final Inspection & Upload Records',
          onAction: () {
            _advanceJob(
              job.copyWith(
                plumbnessToleranceMm: 1.1,
                stage: StubWorkflowStage.uploadRecords,
              ),
            );
            _showFeedback('Final inspection recorded within tolerance (1.1mm)!');
          },
        );

      case StubWorkflowStage.uploadRecords:
        return _buildActionBox(
          icon: Icons.upload_file_rounded,
          color: const Color(0xFFD97706),
          title: 'Upload Stub Setting Verification Records to System',
          description:
              'Attach survey data sheets, theodolite calibration log, and physical photos of embedded stub angles.',
          buttonLabel: 'Attach Verification Records & Submit',
          onAction: () {
            _advanceJob(
              job.copyWith(
                verificationRecordFile: 'stub_survey_signoff_verified.pdf',
                stage: StubWorkflowStage.submittedForApproval,
              ),
            );
            _showFeedback('Records uploaded & submitted for final approval!');
          },
        );

      case StubWorkflowStage.submittedForApproval:
        return _buildActionBox(
          icon: Icons.approval_rounded,
          color: const Color(0xFF059669),
          title: 'Submitted for Final Verification & Approval',
          description:
              'All field verification records, theodolite surveys, and concrete logs are awaiting senior consultant sign-off.',
          buttonLabel: 'Authorize Final Engineering Approval',
          onAction: () {
            _advanceJob(
              job.copyWith(
                stage: StubWorkflowStage.completed,
                completedAt: DateTime.now(),
              ),
            );
            _showFeedback('Workflow Completed! Stub setting officially signed off.');
          },
        );

      case StubWorkflowStage.completed:
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded,
                  color: Color(0xFF10B981), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COMPLETED: Stub Setting Verified & Approved',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Signed off by ${job.superiorVerifierName ?? "Resident Engineer"} on ${_formatDateTime(job.completedAt ?? DateTime.now())}.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Action Engine Components
  // ---------------------------------------------------------------------------
  Widget _buildAccessCodeUnlockCard(DrawingVerificationJob job) {
    final codeController = TextEditingController(text: job.accessCode);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.teal, size: 20),
              SizedBox(width: 8),
              Text(
                'Step 1: Enter Drawing File Name & Provided Access Code',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Drawings are security-gated to prevent unapproved or superseded revisions from being used on-site.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Access Code',
                    hintText: 'e.g. AFC-9921-T2',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (codeController.text.trim().isNotEmpty) {
                    _advanceJob(
                      job.copyWith(
                        accessCode: codeController.text.trim(),
                        stage: StubWorkflowStage.drawingRetrieved,
                      ),
                    );
                    _showFeedback(
                        'Access Code Accepted! Retrieved Approved Drawing.');
                  }
                },
                icon: const Icon(Icons.key_rounded, size: 18),
                label: const Text('Retrieve Drawing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTheodoliteInputCard(DrawingVerificationJob job) {
    final theodoliteController = TextEditingController(
      text: job.theodoliteEnteredNumber ?? job.approvedStubSettingNumber,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.precision_manufacturing_rounded,
                  color: Color(0xFF4F46E5), size: 20),
              SizedBox(width: 8),
              Text(
                'Step 2: Enter Stub Setting Number into Theodolite Machine',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3730A3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Target Setting Number from Approved Drawing: ${job.approvedStubSettingNumber}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: theodoliteController,
            decoration: const InputDecoration(
              labelText: 'Theodolite Machine Registered Number',
              hintText: 'e.g. STUB-T2-N449.201',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final entered = theodoliteController.text.trim();
                _advanceJob(
                  job.copyWith(
                    theodoliteEnteredNumber: entered,
                    stage: StubWorkflowStage.superiorVerification,
                  ),
                );
                _showFeedback(
                    'Entered into Theodolite. Submitted for Superior Verification!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Submit for Superior Verification in System',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperiorVerificationDecisionCard(DrawingVerificationJob job) {
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
              Icon(Icons.rate_review_rounded,
                  color: Color(0xFFD97706), size: 22),
              SizedBox(width: 8),
              Text(
                'Flowchart Decision: Setting Number Verified?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Superior / Resident Engineer cross-checks the Theodolite display against the Approved AFC Drawing.\n'
            '• Approved in Drawing: ${job.approvedStubSettingNumber}\n'
            '• Entered in Theodolite: ${job.theodoliteEnteredNumber ?? "None"}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF78350F),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // YES: Proceed with Stub Setting Concreting
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _advanceJob(
                      job.copyWith(
                        isSettingVerifiedBySuperior: true,
                        superiorVerifierName:
                            'Ir. Michael Chen (Resident Engineer)',
                        stage: StubWorkflowStage.proceedConcreting,
                      ),
                    );
                    _showFeedback(
                        'Verified (YES)! Cleared for Stub Setting Concreting.');
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('YES - Verified'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // NO: Correct Setting Number in Theodolite
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _advanceJob(
                      job.copyWith(
                        isSettingVerifiedBySuperior: false,
                        correctionNotes:
                            'Setting number does not match approved coordinate. Correction required.',
                        stage: StubWorkflowStage.correctionRequired,
                      ),
                    );
                    _showFeedback(
                        'Mismatch flagged (NO)! Correction required in Theodolite.');
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('NO - Mismatch'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionActionCard(DrawingVerificationJob job) {
    final correctionController = TextEditingController(
      text: job.approvedStubSettingNumber,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.build_circle_rounded,
                  color: Color(0xFFDC2626), size: 20),
              SizedBox(width: 8),
              Text(
                'Correct the Setting Number in Theodolite',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Discrepancy: ${job.correctionNotes ?? "Mismatch detected"}.\nRe-calibrate optical setting on machine to match approved number: ${job.approvedStubSettingNumber}',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF7F1D1D)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: correctionController,
            decoration: const InputDecoration(
              labelText: 'Corrected Number in Theodolite',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _advanceJob(
                  job.copyWith(
                    theodoliteEnteredNumber: correctionController.text.trim(),
                    stage: StubWorkflowStage.superiorVerification,
                  ),
                );
                _showFeedback(
                    'Setting corrected! Returned to Superior Verification.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Resubmit to Superior for Cross-Check'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBox({
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
  // Drawing & Inspection Details Cards
  // ---------------------------------------------------------------------------
  Widget _buildDrawingInspectorCard(DrawingVerificationJob job) {
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
          // Title + Offline badge (Wrap for mobile)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const Text(
                'Approved Construction Drawing Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: job.isDownloadedOffline
                      ? const Color(0xFFDCFCE7)
                      : AppColors.offWhite,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      job.isDownloadedOffline
                          ? Icons.offline_pin_rounded
                          : Icons.cloud_outlined,
                      size: 14,
                      color: job.isDownloadedOffline
                          ? const Color(0xFF16A34A)
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.isDownloadedOffline ? 'Offline Ready' : 'Online Only',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: job.isDownloadedOffline
                            ? const Color(0xFF16A34A)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Drawing File Name', job.drawingFileName),
          _buildInfoRow('Drawing Title', job.drawingTitle),
          _buildInfoRow('Revision Status', job.revisionNumber),
          _buildInfoRow('Security Access Code', job.accessCode),
          _buildInfoRow('Target Tower Base / Leg',
              '${job.projectSite} • ${job.towerFoundationId}'),
        ],
      ),
    );
  }

  Widget _buildTheodoliteSpecificationCard(DrawingVerificationJob job) {
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
            'Theodolite Coordinate & Alignment Setting',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Approved Stub Setting No.',
            job.approvedStubSettingNumber,
          ),
          _buildInfoRow(
            'Theodolite Entered No.',
            job.theodoliteEnteredNumber ?? 'Pending Machine Calibration',
          ),
          _buildInfoRow(
            'Superior Verification',
            job.isSettingVerifiedBySuperior == true
                ? 'VERIFIED by ${job.superiorVerifierName ?? "Superior"}'
                : (job.isSettingVerifiedBySuperior == false
                    ? 'REJECTED - Discrepancy Found'
                    : 'Awaiting Cross-Check'),
            isWarning: job.isSettingVerifiedBySuperior == false,
          ),
        ],
      ),
    );
  }

  Widget _buildConcretingInspectionStatus(DrawingVerificationJob job) {
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
            'Concreting, Plumbness & System Upload Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'ReadyMix Concrete Batch',
            job.concreteBatchId ?? 'Pending Concreting Clearance',
          ),
          _buildInfoRow(
            'Plumbness Tolerance Check',
            job.plumbnessToleranceMm != null
                ? '${job.plumbnessToleranceMm} mm (Tolerance <= 2.0 mm: PASS)'
                : 'Pending Post-Pour Inspection',
          ),
          _buildInfoRow(
            'System Verification Record',
            job.verificationRecordFile != null
                ? 'Uploaded: ${job.verificationRecordFile}'
                : 'Pending Upload to System',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs & Helpers
  // ---------------------------------------------------------------------------
  void _promptConcretingInspectionDialog(DrawingVerificationJob job) {
    final batchController =
        TextEditingController(text: 'G40-P6-BATCH-${DateTime.now().millisecond}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Concreting Pour'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter concrete delivery batch and pour ticket for this stub foundation:',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: batchController,
              decoration: const InputDecoration(
                labelText: 'Concrete Batch Number',
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
              _advanceJob(
                job.copyWith(
                  concreteBatchId: batchController.text.trim(),
                  stage: StubWorkflowStage.finalInspection,
                ),
              );
              _showFeedback('Concreting recorded! Proceed to Final Inspection.');
            },
            child: const Text('Proceed to Inspection'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelWidth = constraints.maxWidth < 400 ? 120.0 : 175.0;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
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
          );
        },
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

