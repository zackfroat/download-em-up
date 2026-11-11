import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/controlled_drawing.dart';

/// Interactive modal sheet to view and execute the full Document Control lifecycle
class ControlledDrawingSheet extends StatefulWidget {
  final ControlledDrawing drawing;
  final Function(ControlledDrawing updated) onUpdateDrawing;

  const ControlledDrawingSheet({
    super.key,
    required this.drawing,
    required this.onUpdateDrawing,
  });

  @override
  State<ControlledDrawingSheet> createState() => _ControlledDrawingSheetState();
}

class _ControlledDrawingSheetState extends State<ControlledDrawingSheet> {
  late ControlledDrawing _drawing;

  @override
  void initState() {
    super.initState();
    _drawing = widget.drawing;
  }

  void _advance(ControlledDrawing updated) {
    setState(() {
      _drawing = updated;
    });
    widget.onUpdateDrawing(updated);
  }

  @override
  Widget build(BuildContext context) {
    final drawing = _drawing;

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
                    color: drawing.stage.badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: drawing.stage.badgeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    drawing.stage.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: drawing.stage.badgeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drawing.drawingNumber,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        '${drawing.currentRevision} • ${drawing.discipline}',
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
                  // 1. Flowchart Action Box
                  _buildFlowchartActionEngine(drawing),

                  const SizedBox(height: 24),

                  // 2. Drawing Metadata Card
                  _buildMetadataCard(drawing),

                  const SizedBox(height: 24),

                  // 3. Offline Accessibility & Site Status
                  _buildOfflineAndSiteStatusCard(drawing),

                  const SizedBox(height: 24),

                  // 4. Superseded Revision Archive
                  _buildRevisionHistoryCard(drawing),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowchartActionEngine(ControlledDrawing drawing) {
    switch (drawing.stage) {
      case DocControlStage.adminReceived:
        return _buildActionBox(
          icon: Icons.mark_email_read_rounded,
          color: const Color(0xFF64748B),
          title: 'Document Controller Received Approved Drawing',
          description:
              'Official transmittal received from consultant. Proceed to file and upload into Centralized Document Management System.',
          buttonLabel: 'File and Upload into DMS',
          onAction: () {
            _advance(
              drawing.copyWith(stage: DocControlStage.uploadedToDms),
            );
            _showFeedback('Filed and uploaded into Centralized DMS.');
          },
        );

      case DocControlStage.uploadedToDms:
        return _buildActionBox(
          icon: Icons.cloud_upload_rounded,
          color: const Color(0xFF0284C7),
          title: 'Uploaded into Document Management System',
          description:
              'Drawing is archived into system repository. Next: Verify drawing number, revision status, and engineering approval stamp.',
          buttonLabel: 'Verify Drawing Number, Revision & Approval',
          onAction: () {
            _advance(
              drawing.copyWith(stage: DocControlStage.verifyingStatus),
            );
            _showFeedback('Initiating drawing verification...');
          },
        );

      case DocControlStage.verifyingStatus:
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
                  SizedBox(width: 8),
                  Text(
                    'Flowchart Decision: Is Drawing Resubmission Required?',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Cross-checking ${drawing.drawingNumber} (${drawing.currentRevision}):\n'
                '• If approved without comments: Maintain current drawing and notify site team.\n'
                '• If amendments or comments are required: Supersede previous drawing and require resubmission.',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF78350F),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // NO: Maintain in system
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _advance(
                          drawing.copyWith(
                            isResubmissionRequired: false,
                            stage: DocControlStage.maintainedCurrent,
                          ),
                        );
                        _showFeedback(
                            'Verified (NO)! Maintaining current approved drawing in system.');
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 18),
                      label: const Text('NO - Maintain Approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // YES: Resubmission required
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _promptSupersedeDialog(drawing),
                      icon: const Icon(Icons.published_with_changes_rounded,
                          size: 18),
                      label: const Text('YES - Resubmission'),
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

      case DocControlStage.resubmissionRequired:
        return _buildActionBox(
          icon: Icons.warning_rounded,
          color: const Color(0xFFEF4444),
          title: 'Drawing Resubmission Required',
          description:
              'Previous drawing has been marked superseded and removed from active site use. Upload the latest updated and approved revision.',
          buttonLabel: 'Upload Latest Updated & Approved Revision',
          onAction: () => _promptUploadNewRevision(drawing),
        );

      case DocControlStage.maintainedCurrent:
        return _buildActionBox(
          icon: Icons.campaign_rounded,
          color: const Color(0xFF0D9488),
          title: 'Drawing Verified: Notify Site Construction Team',
          description:
              'Current approved revision confirmed in system. Send formal notification to field engineers and supervisors.',
          buttonLabel: 'Notify Site Team of Approved Drawing Availability',
          onAction: () {
            _advance(
              drawing.copyWith(
                isSiteTeamNotified: true,
                stage: DocControlStage.siteNotified,
              ),
            );
            _showFeedback('Site team notified via push alert and email!');
          },
        );

      case DocControlStage.siteNotified:
        return _buildActionBox(
          icon: Icons.download_rounded,
          color: const Color(0xFFF59E0B),
          title: 'Site Team Downloads Latest Approved Drawing',
          description:
              'Site team has received notification. Download drawing into field tablet and ensure it is accessible offline at site.',
          buttonLabel: 'Download & Ensure Offline Accessibility at Site',
          onAction: () {
            _advance(
              drawing.copyWith(
                isAccessibleOffline: true,
                stage: DocControlStage.downloadedOffline,
              ),
            );
            _showFeedback(
                'Drawing cached locally! Offline accessibility confirmed at site.');
          },
        );

      case DocControlStage.downloadedOffline:
        return _buildActionBox(
          icon: Icons.construction_rounded,
          color: const Color(0xFF8B5CF6),
          title: 'Offline Cache Verified: Authorize for Active Construction',
          description:
              'Drawing is verified offline. Site team can now formally build per this latest Approved for Construction (AFC) revision.',
          buttonLabel: 'Site Team Uses Latest Approved Drawing for Construction',
          onAction: () {
            _advance(
              drawing.copyWith(stage: DocControlStage.activeConstruction),
            );
            _showFeedback(
                'Workflow FINISHED: Drawing active for site construction!');
          },
        );

      case DocControlStage.activeConstruction:
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_rounded,
                  color: Color(0xFF10B981), size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE FOR SITE CONSTRUCTION (AFC)',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF065F46),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Site team is actively executing construction strictly according to this approved revision. Full protocol completed.',
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

  Widget _buildMetadataCard(ControlledDrawing drawing) {
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
          Text(
            drawing.title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Drawing Number', drawing.drawingNumber),
          _buildInfoRow('Discipline Category', drawing.discipline),
          _buildInfoRow('Current Revision', drawing.currentRevision),
          _buildInfoRow('Approval Status', drawing.approvalStatus),
          _buildInfoRow('Project Location', drawing.projectSite),
          _buildInfoRow('Document Controller', drawing.documentControllerName),
          _buildInfoRow('File Name & Size',
              '${drawing.fileName} (${drawing.fileSize})'),
        ],
      ),
    );
  }

  Widget _buildOfflineAndSiteStatusCard(ControlledDrawing drawing) {
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
            'Site Distribution & Offline Access Guard',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusCheckItem(
            'Site Team Notification Dispatched',
            drawing.isSiteTeamNotified,
            'Automated push notification sent to all site tablets',
          ),
          const SizedBox(height: 8),
          _buildStatusCheckItem(
            'Accessible Offline at Site',
            drawing.isAccessibleOffline,
            'Local vector cache verified for zero-reception areas',
          ),
          const SizedBox(height: 8),
          _buildStatusCheckItem(
            'Active for Construction (AFC)',
            drawing.stage == DocControlStage.activeConstruction,
            'Site team actively building per latest approved drawing',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCheckItem(String title, bool isDone, String subtitle) {
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

  Widget _buildRevisionHistoryCard(ControlledDrawing drawing) {
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              const Text(
                'Superseded Revision Archive',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                '${drawing.revisionHistory.length} Previous Revisions',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (drawing.revisionHistory.isEmpty)
            const Text(
              'No previous revisions. This is the original base issue.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSubtle,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: drawing.revisionHistory.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 14, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final rev = drawing.revisionHistory[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        rev.revision,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rev.notes,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            'Superseded on ${rev.uploadedAt}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _promptSupersedeDialog(ControlledDrawing drawing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Drawing Resubmission Required'),
        content: const Text(
          'Mark previous drawing as superseded and remove from active site use to prevent errors on-site?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _advance(
                drawing.copyWith(
                  isResubmissionRequired: true,
                  isPreviousRemovedFromActive: true,
                  stage: DocControlStage.resubmissionRequired,
                ),
              );
              _showFeedback('Previous drawing removed from active use.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Remove Previous & Require Resubmission'),
          ),
        ],
      ),
    );
  }

  void _promptUploadNewRevision(ControlledDrawing drawing) {
    final revController = TextEditingController(text: 'Rev 05');
    final notesController = TextEditingController(
      text: 'Re-issued with consultant structural engineer stamp.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Latest Approved Drawing Revision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify updated revision number and transmittal notes:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: revController,
              decoration: const InputDecoration(labelText: 'New Revision Number'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Revision Notes'),
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
              final newArchive = [
                DrawingRevisionEntry(
                  revision: drawing.currentRevision,
                  uploadedAt: 'Today',
                  notes: 'Superseded by ${revController.text.trim()}',
                ),
                ...drawing.revisionHistory,
              ];

              _advance(
                drawing.copyWith(
                  currentRevision: revController.text.trim(),
                  approvalStatus: 'Approved for Construction (AFC)',
                  isResubmissionRequired: false,
                  revisionHistory: newArchive,
                  stage: DocControlStage.maintainedCurrent,
                ),
              );
              _showFeedback(
                  'Latest revision ${revController.text.trim()} uploaded and verified!');
            },
            child: const Text('Verify & Upload Revision'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
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
}

