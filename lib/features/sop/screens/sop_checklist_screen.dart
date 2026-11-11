import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_footer.dart';
import '../../documentation/models/drawing_verification_job.dart';
import '../../documentation/widgets/drawing_viewer_sheet.dart';
import '../../documentation/widgets/stub_flowchart_modal.dart';
import '../models/sop_checklist.dart';
import '../widgets/sop_detail_sheet.dart';

/// Screen for Module 02: SOP Verification Checklist
/// Features general quality checklists AND the specialized Stub Setting & Theodolite Concreting SOP Protocol.
class SopChecklistScreen extends StatefulWidget {
  final String roleName;

  const SopChecklistScreen({
    super.key,
    required this.roleName,
  });

  @override
  State<SopChecklistScreen> createState() => _SopChecklistScreenState();
}

class _SopChecklistScreenState extends State<SopChecklistScreen> {
  late List<SopChecklist> _checklists;
  late List<DrawingVerificationJob> _stubJobs;
  int _selectedTab = 0; // 0: Stub Setting SOP Protocol, 1: General Daily SOPs

  @override
  void initState() {
    super.initState();
    _checklists = List.from(SopChecklist.sampleChecklists);
    _stubJobs = List.from(DrawingVerificationJob.sampleJobs);
  }

  void _openStubJob(DrawingVerificationJob job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DrawingViewerSheet(
        job: job,
        onUpdateJob: (updated) {
          setState(() {
            final idx = _stubJobs.indexWhere((j) => j.id == updated.id);
            if (idx != -1) {
              _stubJobs[idx] = updated;
            }
          });
        },
      ),
    );
  }

  void _openGeneralChecklist(SopChecklist checklist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SopDetailSheet(
        checklist: checklist,
        onUpdateChecklist: (updated) {
          setState(() {
            final idx = _checklists.indexWhere((c) => c.id == updated.id);
            if (idx != -1) {
              _checklists[idx] = updated;
            }
          });
        },
      ),
    );
  }

  void _openStubFlowchart() {
    showDialog(
      context: context,
      builder: (ctx) => const StubFlowchartModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MOD-02',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'SOP Verification Checklist',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View Stub Setting Flowchart',
            icon: const Icon(Icons.account_tree_outlined,
                color: AppColors.darkText),
            onPressed: _openStubFlowchart,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Protocol Selector Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          title: 'Stub Setting & Concreting SOP Protocol',
                          icon: Icons.precision_manufacturing_rounded,
                          isSelected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          title: 'Daily Site Quality Checklists',
                          icon: Icons.checklist_rtl_rounded,
                          isSelected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (_selectedTab == 0) ...[
                  // Stub Setting & Theodolite Protocol
                  _buildStubSettingBanner(),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _stubJobs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = _stubJobs[index];
                      return _buildStubJobCard(job);
                    },
                  ),
                ] else ...[
                  // General Daily SOP Checklists
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _checklists.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final chk = _checklists[index];
                      return _buildGeneralChecklistCard(chk);
                    },
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(roleName: widget.roleName),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18, color: isSelected ? Colors.white : AppColors.darkText),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner with LayoutBuilder for mobile responsiveness — stacks vertically on < 540px
  Widget _buildStubSettingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 540;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stub Setting Verification & Theodolite Protocol',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mandatory SOP: Access Code intake, Theodolite machine calibration, superior sign-off & post-concreting tolerance inspection.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openStubFlowchart,
                    icon: const Icon(Icons.account_tree_rounded, size: 16),
                    label: const Text('View Flowchart'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.teal,
                      side: const BorderSide(color: AppColors.teal),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stub Setting Verification & Theodolite Protocol',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mandatory SOP: Access Code intake, Theodolite machine calibration, superior sign-off & post-concreting tolerance inspection.',
                      style:
                          TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              OutlinedButton.icon(
                onPressed: _openStubFlowchart,
                icon: const Icon(Icons.account_tree_rounded, size: 16),
                label: const Text('View Flowchart'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(color: AppColors.teal),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Stub Job Card — uses Wrap for header to prevent stage badge overflow on mobile
  Widget _buildStubJobCard(DrawingVerificationJob job) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openStubJob(job),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Job ID + Access Code + Stage Badge (Wrap for mobile)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          job.id,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.offWhite,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            job.accessCode,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: job.stage.badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          job.stage.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: job.stage.badgeColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.drawingTitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 10),
                // Footer: Stub number + project site (Wrap for mobile)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Target Stub No: ',
                            style: TextStyle(
                                fontSize: 12.5, color: AppColors.textMuted)),
                        Text(
                          job.approvedStubSettingNumber,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      job.projectSite,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// General Checklist Card — uses Wrap for header & footer to prevent overflow on mobile
  Widget _buildGeneralChecklistCard(SopChecklist checklist) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openGeneralChecklist(checklist),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Checklist number + status badge (Wrap for mobile)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      checklist.checklistNumber,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: checklist.status.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          checklist.status.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: checklist.status.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  checklist.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${checklist.projectSite} • ${checklist.zoneOrPier}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                // Footer: item count + action link (Wrap for mobile)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      '${checklist.passCount} of ${checklist.items.length} items verified',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open Checklist',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 15, color: AppColors.teal),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
