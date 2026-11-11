import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/safety_flowchart_model.dart';
import '../widgets/safety_flowchart_modal.dart';
import '../widgets/safety_incident_detail_sheet.dart';

/// Full screen interface for MOD-01: Safety Training & Compliance Inspection
/// faithfully implementing the official Site Safety Induction, NCR, and Red Card Flowchart.
class SafetyTrainingScreen extends StatefulWidget {
  final String roleName;

  const SafetyTrainingScreen({
    super.key,
    required this.roleName,
  });

  @override
  State<SafetyTrainingScreen> createState() => _SafetyTrainingScreenState();
}

class _SafetyTrainingScreenState extends State<SafetyTrainingScreen> {
  late List<SafetyIncidentRecord> _records;
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All, 1: Monitoring, 2: Active NCRs, 3: Red Cards, 4: Audited

  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All Safety Records',
    'Site Monitoring',
    'Active NCR Issued',
    'Red Card Exclusions',
    'Audited & Compliant',
  ];

  @override
  void initState() {
    super.initState();
    _records = List.from(SafetyIncidentRecord.sampleRecords);
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

  List<SafetyIncidentRecord> get _filteredRecords {
    return _records.where((r) {
      if (_searchQuery.isNotEmpty) {
        final matchesQuery = r.id.toLowerCase().contains(_searchQuery) ||
            r.subcontractorName.toLowerCase().contains(_searchQuery) ||
            r.workerName.toLowerCase().contains(_searchQuery) ||
            r.activityDescription.toLowerCase().contains(_searchQuery);
        if (!matchesQuery) return false;
      }

      switch (_selectedFilterIndex) {
        case 1:
          return r.stage == SafetyFlowStage.monitoringActivities;
        case 2:
          return r.stage == SafetyFlowStage.ncrIssued ||
              r.stage == SafetyFlowStage.correctiveActionImplemented ||
              r.stage == SafetyFlowStage.escalatedNcr;
        case 3:
          return r.stage == SafetyFlowStage.redCardIssued;
        case 4:
          return r.stage == SafetyFlowStage.compliantAndAudited;
        default:
          return true;
      }
    }).toList();
  }

  void _openFlowchart() {
    showDialog(
      context: context,
      builder: (ctx) => const SafetyFlowchartModal(),
    );
  }

  void _openDetailSheet(SafetyIncidentRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafetyIncidentDetailSheet(
        record: record,
        onUpdateRecord: (updated) {
          setState(() {
            final idx = _records.indexWhere((r) => r.id == updated.id);
            if (idx != -1) _records[idx] = updated;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords;

    final monitoringCount = _records
        .where((r) => r.stage == SafetyFlowStage.monitoringActivities)
        .length;
    final ncrCount = _records
        .where((r) =>
            r.stage == SafetyFlowStage.ncrIssued ||
            r.stage == SafetyFlowStage.correctiveActionImplemented)
        .length;
    final redCardCount =
        _records.where((r) => r.stage == SafetyFlowStage.redCardIssued).length;
    final compliantCount = _records
        .where((r) => r.stage == SafetyFlowStage.compliantAndAudited)
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
                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MOD-01',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Safety Training & Compliance',
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
            tooltip: 'View Safety SOP Flowchart',
            icon: const Icon(Icons.account_tree_outlined, color: AppColors.darkText),
            onPressed: _openFlowchart,
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
                // Top Flowchart Banner
                _buildHeroBanner(),

                const SizedBox(height: 16),

                // Metrics Row
                _buildMetricsGrid(
                  monitoring: monitoringCount,
                  ncrs: ncrCount,
                  redCards: redCardCount,
                  compliant: compliantCount,
                ),

                const SizedBox(height: 20),

                // Search & Filter Row
                _buildSearchAndFilters(),

                const SizedBox(height: 16),

                // Incident/Record List
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
                      final item = filtered[index];
                      return _buildIncidentCard(item);
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

  Widget _buildHeroBanner() {
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

          final titleCol = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Safety Induction, NCR & Red Card Protocol',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Mandatory safety workflow: induction passports, monthly campaigns, on-site hazard surveillance, corrective actions, and 3-strike red card site exclusions.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            ],
          );

          final button = OutlinedButton.icon(
            onPressed: _openFlowchart,
            icon: const Icon(Icons.account_tree_rounded, size: 16),
            label: const Text('View Flowchart'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0284C7),
              side: const BorderSide(color: Color(0xFF0284C7)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleCol,
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: button),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: titleCol),
              const SizedBox(width: 14),
              button,
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricsGrid({
    required int monitoring,
    required int ncrs,
    required int redCards,
    required int compliant,
  }) {
    return LayoutBuilder(
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
              title: 'Active Surveillance',
              count: '$monitoring',
              color: const Color(0xFF0284C7),
              icon: Icons.shield_outlined,
            ),
            _buildMetricTile(
              title: 'NCRs Issued',
              count: '$ncrs',
              color: const Color(0xFFD97706),
              icon: Icons.report_problem_rounded,
            ),
            _buildMetricTile(
              title: 'Red Card Exclusions',
              count: '$redCards',
              color: const Color(0xFFDC2626),
              icon: Icons.dangerous_rounded,
            ),
            _buildMetricTile(
              title: 'Audited & Passed',
              count: '$compliant',
              color: const Color(0xFF10B981),
              icon: Icons.verified_rounded,
            ),
          ],
        );
      },
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
        border: Border.all(color: color.withValues(alpha: 0.20)),
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
        // Search Box
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by reference ID, subcontractor, worker, or activity...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle),
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
        const SizedBox(height: 12),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_filters.length, (index) {
              final isSelected = _selectedFilterIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilterIndex = index);
                  },
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.darkText,
                  ),
                  selectedColor: const Color(0xFF0284C7),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF0284C7) : AppColors.borderLight,
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

  Widget _buildIncidentCard(SafetyIncidentRecord record) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: record.stage == SafetyFlowStage.redCardIssued
              ? const Color(0xFFFCA5A5)
              : AppColors.borderLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetailSheet(record),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Wrap for mobile responsiveness)
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
                          record.id,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (record.violationCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: record.violationCount >= 3
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: record.violationCount >= 3
                                    ? const Color(0xFFFCA5A5)
                                    : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Text(
                              'Strike ${record.violationCount}/3',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: record.violationCount >= 3
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: record.stage.badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          record.stage.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: record.stage.badgeColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Activity Description
                Text(
                  record.activityDescription,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 6),

                // Subcontractor & Personnel details
                Text(
                  '${record.subcontractorName} • ${record.workerName} (${record.workerId})',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),

                // Footer (Wrap for mobile)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      record.projectSite,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSubtle,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Execute Step',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: record.stage.badgeColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: record.stage.badgeColor,
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
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        children: [
          Icon(Icons.health_and_safety_rounded, size: 44, color: AppColors.textSubtle),
          SizedBox(height: 10),
          Text(
            'No matching safety records found',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try adjusting your search criteria or category filter.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

