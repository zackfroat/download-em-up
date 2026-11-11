import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/subcontractor_record.dart';

/// Modal detail sheet to review a subcontractor across the 3 tracks:
/// 1. Timeline Memos (4M, 2M, 1M, RED highlight, Intervention)
/// 2. Safety Compliance & Red Card tracking
/// 3. Manpower & Machinery contractual quota verification
class SubcontractorDetailSheet extends StatefulWidget {
  final SubcontractorRecord record;
  final Function(SubcontractorRecord updated) onUpdateRecord;

  const SubcontractorDetailSheet({
    super.key,
    required this.record,
    required this.onUpdateRecord,
  });

  @override
  State<SubcontractorDetailSheet> createState() => _SubcontractorDetailSheetState();
}

class _SubcontractorDetailSheetState extends State<SubcontractorDetailSheet> {
  late SubcontractorRecord _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  void _advanceTimelineMemo() {
    setState(() {
      TimelineMemoStatus nextStatus = _record.timelineStatus;
      SubcontractorRating rating = _record.rating;
      String? notes = _record.interventionNotes;

      if (_record.timelineStatus == TimelineMemoStatus.normal) {
        nextStatus = TimelineMemoStatus.memo1Sent;
      } else if (_record.timelineStatus == TimelineMemoStatus.memo1Sent) {
        nextStatus = TimelineMemoStatus.memo2Sent;
        notes = '2nd Memo issued (2 Months prior). Subcontractor submitting delay justifications.';
      } else if (_record.timelineStatus == TimelineMemoStatus.memo2Sent) {
        nextStatus = TimelineMemoStatus.memo3Critical;
        rating = SubcontractorRating.gradeRed;
        notes = '3rd Memo issued (1 Month prior). CRITICAL ALERT: Highlighted in RED. Main contractor intervention triggered.';
      } else if (_record.timelineStatus == TimelineMemoStatus.memo3Critical) {
        nextStatus = TimelineMemoStatus.contractorIntervened;
        notes = 'Intervention deployed. Additional manpower & equipment deployed; costs to be recovered per contract.';
      }

      _record = _record.copyWith(
        timelineStatus: nextStatus,
        rating: rating,
        interventionNotes: notes,
      );
    });
    widget.onUpdateRecord(_record);
  }

  void _issueSafetyRedCard() {
    setState(() {
      final newCount = _record.safetyRedCardCount + 1;
      _record = _record.copyWith(
        hasSafetyViolation: true,
        safetyRedCardCount: newCount,
        performanceScore: (_record.performanceScore - 8.0).clamp(0.0, 100.0),
        rating: newCount >= 2 ? SubcontractorRating.gradeRed : _record.rating,
        interventionNotes: 'Safety violation registered. Red Card issued to worker. SPI score penalized.',
      );
    });
    widget.onUpdateRecord(_record);
  }

  void _issueResourceDeficiencyMemo() {
    setState(() {
      final newCount = _record.nonComplianceMemoCount + 1;
      _record = _record.copyWith(
        isManpowerMachineryCompliant: false,
        nonComplianceMemoCount: newCount,
        performanceScore: (_record.performanceScore - 5.0).clamp(0.0, 100.0),
      );
    });
    widget.onUpdateRecord(_record);
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;

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
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: record.rating.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: record.rating.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    record.rating.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: record.rating.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: record.isHighlightedInRed
                              ? const Color(0xFFDC2626)
                              : AppColors.darkText,
                        ),
                      ),
                      Text(
                        '${record.tradeCategory} • ${record.contractNumber}',
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

          // Scrollable Tracks Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Red Alert Banner if highlighted
                  if (record.isHighlightedInRed) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Color(0xFFDC2626), size: 22),
                              SizedBox(width: 8),
                              Text(
                                'CRITICAL INTERVENTION: HIGHLIGHTED IN RED',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            record.interventionNotes ??
                                'Subcontractor milestone delayed past critical threshold. Main contractor stepping in to complete outstanding works.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF7F1D1D),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // SPI Score Header Tile
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subcontractor Performance Index (SPI)',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${record.performanceScore.toStringAsFixed(1)} / 100',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: record.rating.color,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: record.rating.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            record.rating.displayName.split(' ').first,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: record.rating.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Track 1: Timeline Compliance
                  _buildTrackSection(
                    title: 'Track 1: Project Timeline Compliance',
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFFF59E0B),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Contract Completion',
                          '${record.targetCompletionDate.day}/${record.targetCompletionDate.month}/${record.targetCompletionDate.year}',
                        ),
                        _buildInfoRow('Timeline Stage', record.timelineStatus.name.toUpperCase()),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _advanceTimelineMemo,
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('Escalate Milestone Memo (4M -> 2M -> 1M RED)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Track 2: Safety Compliance
                  _buildTrackSection(
                    title: 'Track 2: Safety Compliance & Red Cards',
                    icon: Icons.health_and_safety_rounded,
                    color: const Color(0xFFEF4444),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Safety Violation Status',
                          record.hasSafetyViolation ? 'Active Infraction' : 'Clean Safety Record',
                        ),
                        _buildInfoRow(
                          'Worker Red Cards Issued',
                          '${record.safetyRedCardCount} (Site removals logged)',
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _issueSafetyRedCard,
                            icon: const Icon(Icons.assignment_late_rounded, size: 16),
                            label: const Text('Issue Safety Memo & Red Card'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Track 3: Manpower & Machinery Quota
                  _buildTrackSection(
                    title: 'Track 3: Manpower & Machinery Compliance',
                    icon: Icons.precision_manufacturing_rounded,
                    color: const Color(0xFF0D9488),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'On-Site Manpower',
                          '${record.actualManpower} / ${record.requiredManpower} Required Workers',
                        ),
                        _buildInfoRow(
                          'Machinery Deployed',
                          '${record.actualMachinery} / ${record.requiredMachinery} Required Units',
                        ),
                        _buildInfoRow(
                          'Deficiency Memos',
                          '${record.nonComplianceMemoCount} Memos on file',
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _issueResourceDeficiencyMemo,
                            icon: const Icon(Icons.playlist_add_check_rounded, size: 16),
                            label: const Text('Log Non-Compliance Memo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelWidth = constraints.maxWidth < 400 ? 120.0 : 160.0;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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

