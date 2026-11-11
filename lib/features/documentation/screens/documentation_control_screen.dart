import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/controlled_drawing.dart';
import '../widgets/controlled_drawing_sheet.dart';
import '../widgets/doc_control_flowchart_modal.dart';

/// Main screen for Module 03: Centralized Documentation Control System
/// implementing the official Drawing Intake, Superseding, Offline Caching & AFC workflow.
class DocumentationControlScreen extends StatefulWidget {
  final String roleName;

  const DocumentationControlScreen({
    super.key,
    required this.roleName,
  });

  @override
  State<DocumentationControlScreen> createState() =>
      _DocumentationControlScreenState();
}

class _DocumentationControlScreenState
    extends State<DocumentationControlScreen> {
  late List<ControlledDrawing> _drawings;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: All, 1: Verifying/Resubmission, 2: Site Notified & Offline, 3: Active Construction

  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All Controlled Drawings',
    'Verifying & Resubmission',
    'Site Notified & Offline',
    'Active for Construction (AFC)',
  ];

  @override
  void initState() {
    super.initState();
    _drawings = List.from(ControlledDrawing.sampleDrawings);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ControlledDrawing> get _filteredDrawings {
    return _drawings.where((doc) {
      if (_selectedFilter == 1 &&
          doc.stage != DocControlStage.verifyingStatus &&
          doc.stage != DocControlStage.uploadedToDms &&
          doc.stage != DocControlStage.resubmissionRequired) {
        return false;
      }
      if (_selectedFilter == 2 &&
          doc.stage != DocControlStage.siteNotified &&
          doc.stage != DocControlStage.downloadedOffline &&
          doc.stage != DocControlStage.maintainedCurrent) {
        return false;
      }
      if (_selectedFilter == 3 &&
          doc.stage != DocControlStage.activeConstruction) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final numMatch = doc.drawingNumber.toLowerCase().contains(_searchQuery);
        final titleMatch = doc.title.toLowerCase().contains(_searchQuery);
        final discMatch = doc.discipline.toLowerCase().contains(_searchQuery);
        final siteMatch = doc.projectSite.toLowerCase().contains(_searchQuery);
        return numMatch || titleMatch || discMatch || siteMatch;
      }

      return true;
    }).toList();
  }

  void _openDrawingDetail(ControlledDrawing drawing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ControlledDrawingSheet(
        drawing: drawing,
        onUpdateDrawing: (updated) {
          setState(() {
            final idx = _drawings.indexWhere((d) => d.id == updated.id);
            if (idx != -1) {
              _drawings[idx] = updated;
            }
          });
        },
      ),
    );
  }

  void _openFlowchartDialog([DocControlStage? stage]) {
    showDialog(
      context: context,
      builder: (ctx) => DocControlFlowchartModal(activeStage: stage),
    );
  }

  void _promptUploadNewDrawing() {
    final numberController = TextEditingController(text: 'DWG-STR-COL-501');
    final titleController = TextEditingController(
      text: 'Main Tower Ground Column Stiffener & Anchor Schedule',
    );
    final disciplineController =
        TextEditingController(text: 'Structural Engineering');
    final siteController =
        TextEditingController(text: 'Main Podium Core Zone');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Intake Approved Drawing into DMS'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Drawing Number'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Drawing Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: disciplineController,
                decoration: const InputDecoration(labelText: 'Discipline'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: siteController,
                decoration: const InputDecoration(labelText: 'Project Site Location'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final newDoc = ControlledDrawing(
                id: 'DMS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                drawingNumber: numberController.text.trim(),
                title: titleController.text.trim(),
                discipline: disciplineController.text.trim(),
                currentRevision: 'Rev 01',
                approvalStatus: 'Pending Verification',
                projectSite: siteController.text.trim(),
                documentControllerName: 'Zainal Abidin (Lead Doc Controller)',
                fileName: '${numberController.text.trim()}-REV01.pdf',
                fileSize: '15.2 MB',
                stage: DocControlStage.adminReceived,
                receivedDate: DateTime.now(),
              );

              setState(() {
                _drawings.insert(0, newDoc);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Received ${newDoc.drawingNumber}. Enters workflow at Admin Intake.'),
                  backgroundColor: AppColors.darkText,
                ),
              );
            },
            child: const Text('Intake Drawing'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredDrawings;
    final verifyingCount = _drawings
        .where((d) =>
            d.stage == DocControlStage.verifyingStatus ||
            d.stage == DocControlStage.uploadedToDms ||
            d.stage == DocControlStage.resubmissionRequired)
        .length;
    final offlineReady =
        _drawings.where((d) => d.isAccessibleOffline).length;
    final afcActive = _drawings
        .where((d) => d.stage == DocControlStage.activeConstruction)
        .length;

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
                color: AppColors.indigoAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MOD-03',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.indigoAccent,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Document Control',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View Document Control Flowchart',
            icon: const Icon(Icons.account_tree_outlined,
                color: AppColors.darkText),
            onPressed: () => _openFlowchartDialog(),
          ),
          Builder(
            builder: (context) {
              final isMobile = MediaQuery.of(context).size.width < 500;
              if (isMobile) {
                return IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: AppColors.indigoAccent),
                  tooltip: 'Intake Drawing',
                  onPressed: _promptUploadNewDrawing,
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ElevatedButton.icon(
                  onPressed: _promptUploadNewDrawing,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Intake Drawing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigoAccent,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
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
                // 1. KPI Pipeline Banner
                _buildSummaryBanner(
                  total: _drawings.length,
                  verifyingCount: verifyingCount,
                  offlineReady: offlineReady,
                  afcActive: afcActive,
                ),

                const SizedBox(height: 24),

                // 2. Search & Filter Bar
                _buildSearchAndFilters(),

                const SizedBox(height: 16),

                // 3. Controlled Drawings List
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final drawing = filtered[index];
                      return _buildDrawingCard(drawing);
                    },
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(roleName: widget.roleName),
    );
  }

  Widget _buildSummaryBanner({
    required int total,
    required int verifyingCount,
    required int offlineReady,
    required int afcActive,
  }) {
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 560;

              final titleRow = Row(
                children: const [
                  Icon(
                    Icons.snippet_folder_rounded,
                    color: AppColors.indigoAccent,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Drawing Revision & Superseding Protocol',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              );

              final button = OutlinedButton.icon(
                onPressed: () => _openFlowchartDialog(),
                icon: const Icon(Icons.account_tree_rounded, size: 16),
                label: const Text('View Flowchart'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.indigoAccent,
                  side: const BorderSide(
                      color: AppColors.indigoAccent, width: 1.2),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 580;
              final childAspectRatio = isWide
                  ? 2.2
                  : constraints.maxWidth < 360
                      ? 1.55
                      : 1.75;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildMetricTile(
                    title: 'Drawings in DMS',
                    count: '$total',
                    color: const Color(0xFF6366F1),
                    icon: Icons.folder_shared_rounded,
                  ),
                  _buildMetricTile(
                    title: 'Verifying / Resub',
                    count: '$verifyingCount',
                    color: const Color(0xFFEF4444),
                    icon: Icons.published_with_changes_rounded,
                  ),
                  _buildMetricTile(
                    title: 'Site Offline Cache',
                    count: '$offlineReady',
                    color: const Color(0xFF8B5CF6),
                    icon: Icons.offline_pin_rounded,
                  ),
                  _buildMetricTile(
                    title: 'Active for Construction',
                    count: '$afcActive',
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

  Widget _buildMetricTile({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20), width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, color: color, size: 20),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText:
                  'Search drawing number, title, discipline, or project zone...',
              hintStyle:
                  const TextStyle(fontSize: 13.5, color: AppColors.textSubtle),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textMuted, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_filters.length, (index) {
              final isSelected = _selectedFilter == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilter = index);
                  },
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.darkText,
                  ),
                  selectedColor: AppColors.indigoAccent,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.indigoAccent
                        : AppColors.borderLight,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawingCard(ControlledDrawing drawing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDrawingDetail(drawing),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Drawing Number + Stage Badge
                // Mobile-responsive: Wrap prevents overflow on narrow screens
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded,
                            size: 18, color: AppColors.indigoAccent),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            drawing.drawingNumber,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Text(
                            drawing.currentRevision,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: drawing.stage.badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: drawing.stage.badgeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                drawing.stage.displayName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: drawing.stage.badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  drawing.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),

                // Discipline & Location
                Row(
                  children: [
                    Text(
                      drawing.discipline,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: AppColors.textSubtle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        drawing.projectSite,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Footer Row: Offline badge + Action button (Wrap prevents overflow)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          drawing.isAccessibleOffline
                              ? Icons.offline_pin_rounded
                              : Icons.cloud_outlined,
                          size: 15,
                          color: drawing.isAccessibleOffline
                              ? const Color(0xFF16A34A)
                              : AppColors.textSubtle,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          drawing.isAccessibleOffline
                              ? 'Offline at Site'
                              : 'Online (DMS)',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: drawing.isAccessibleOffline
                                ? const Color(0xFF16A34A)
                                : AppColors.textSubtle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Execute Step',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: drawing.stage.badgeColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: drawing.stage.badgeColor,
                        ),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        children: [
          Icon(Icons.folder_off_rounded,
              size: 48, color: AppColors.textSubtle),
          SizedBox(height: 12),
          Text(
            'No matching drawings found in system',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Adjust your search terms or filter to view drawings.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
