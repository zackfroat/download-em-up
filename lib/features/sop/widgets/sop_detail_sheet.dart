import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/sop_checklist.dart';

/// Interactive modal sheet to review, check off, and verify an SOP Checklist
class SopDetailSheet extends StatefulWidget {
  final SopChecklist checklist;
  final Function(SopChecklist updated) onUpdateChecklist;

  const SopDetailSheet({
    super.key,
    required this.checklist,
    required this.onUpdateChecklist,
  });

  @override
  State<SopDetailSheet> createState() => _SopDetailSheetState();
}

class _SopDetailSheetState extends State<SopDetailSheet> {
  late SopChecklist _checklist;

  @override
  void initState() {
    super.initState();
    _checklist = widget.checklist;
  }

  void _updateItemStatus(int index, CheckItemStatus newStatus) {
    setState(() {
      final updatedItems = List<SopCheckItem>.from(_checklist.items);
      updatedItems[index] = updatedItems[index].copyWith(status: newStatus);

      // Recalculate checklist status
      SopStatus status = _checklist.status;
      if (updatedItems.any((i) => i.status == CheckItemStatus.fail)) {
        status = SopStatus.remedialActionRequired;
      } else if (updatedItems.every((i) =>
          i.status == CheckItemStatus.pass ||
          i.status == CheckItemStatus.notApplicable)) {
        if (_checklist.verifyingEngineerName != null) {
          status = SopStatus.verifiedAndPassed;
        } else {
          status = SopStatus.pendingVerification;
        }
      } else {
        status = SopStatus.inProgress;
      }

      _checklist = _checklist.copyWith(
        items: updatedItems,
        status: status,
      );
    });
    widget.onUpdateChecklist(_checklist);
  }

  void _signOffEngineer() {
    setState(() {
      _checklist = _checklist.copyWith(
        verifyingEngineerName: 'Ir. Michael Chen (Resident Engineer)',
        status: SopStatus.verifiedAndPassed,
        dateVerified: DateTime.now(),
      );
    });
    widget.onUpdateChecklist(_checklist);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOP Checklist Verified and Digitally Signed Off!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checklist = _checklist;

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
                    color: checklist.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: checklist.status.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    checklist.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: checklist.status.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checklist.checklistNumber,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        '${checklist.projectSite} • ${checklist.zoneOrPier}',
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
                  // Title & Meta Info Card
                  _buildHeaderMetaCard(checklist),

                  const SizedBox(height: 20),

                  // Verification Action Box
                  _buildActionSignoffBox(checklist),

                  const SizedBox(height: 24),

                  // Section Title (Wrap for mobile)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      const Text(
                        'Quality & Safety Verification Items',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        '${checklist.passCount}/${checklist.items.length} Passed',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Check Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: checklist.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = checklist.items[index];
                      return _buildCheckItemCard(item, index);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Remedial Notes Card (if any)
                  if (checklist.remedialNotes != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Color(0xFFDC2626), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Remedial Notice & Action Required',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            checklist.remedialNotes!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF7F1D1D),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetaCard(SopChecklist checklist) {
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
            checklist.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Discipline Category', checklist.category),
          _buildInfoRow('Site Location', checklist.projectSite),
          _buildInfoRow('Zone / Grid / Pier', checklist.zoneOrPier),
          _buildInfoRow('Site Inspector', checklist.inspectorName),
          _buildInfoRow(
            'Verifying Engineer',
            checklist.verifyingEngineerName ?? 'Pending Final Sign-off',
          ),
        ],
      ),
    );
  }

  Widget _buildActionSignoffBox(SopChecklist checklist) {
    final allPassed = checklist.items.every((i) =>
        i.status == CheckItemStatus.pass ||
        i.status == CheckItemStatus.notApplicable);

    if (checklist.status == SopStatus.verifiedAndPassed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded,
                color: Color(0xFF10B981), size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formally Verified & Approved for Next Work Stage',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  Text(
                    'Signed by ${checklist.verifyingEngineerName ?? "Engineer"}',
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: allPassed
            ? AppColors.teal.withValues(alpha: 0.08)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: allPassed ? AppColors.teal : const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allPassed ? Icons.task_alt_rounded : Icons.info_outline_rounded,
                color: allPassed ? AppColors.teal : const Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  allPassed
                      ? 'All Items Passed: Ready for Engineer Verification'
                      : 'Checklist Verification in Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: allPassed ? AppColors.teal : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            allPassed
                ? 'Review inspection items below and apply resident engineer digital authorization stamp.'
                : 'Inspect all physical criteria on site and mark Pass, Fail, or N/A.',
            style: const TextStyle(fontSize: 12.5, color: AppColors.darkText),
          ),
          if (allPassed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _signOffEngineer,
                icon: const Icon(Icons.draw_rounded, size: 18),
                label: const Text('Sign Off & Authorize SOP Approval'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckItemCard(SopCheckItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.status == CheckItemStatus.fail
              ? const Color(0xFFFCA5A5)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
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
                      item.description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Criteria: ${item.standardCriteria}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (item.inspectorRemarks != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Remarks: ${item.inspectorRemarks}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 10),

          // Action Chips: Pass, Fail, N/A (Wrap for mobile)
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildChoiceButton(
                label: 'Pass',
                icon: Icons.check_circle_rounded,
                isSelected: item.status == CheckItemStatus.pass,
                activeColor: const Color(0xFF10B981),
                onTap: () => _updateItemStatus(index, CheckItemStatus.pass),
              ),
              _buildChoiceButton(
                label: 'Fail',
                icon: Icons.cancel_rounded,
                isSelected: item.status == CheckItemStatus.fail,
                activeColor: const Color(0xFFEF4444),
                onTap: () => _updateItemStatus(index, CheckItemStatus.fail),
              ),
              _buildChoiceButton(
                label: 'N/A',
                icon: Icons.remove_circle_outline_rounded,
                isSelected: item.status == CheckItemStatus.notApplicable,
                activeColor: const Color(0xFF64748B),
                onTap: () =>
                    _updateItemStatus(index, CheckItemStatus.notApplicable),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.offWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelWidth = constraints.maxWidth < 400 ? 110.0 : 140.0;
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

