import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/subcontractor_record.dart';
import '../widgets/subcontractor_detail_sheet.dart';
import '../widgets/subcontractor_flowchart_modal.dart';

/// Full screen interface for MOD-05: Subcontractor Summary & Performance Monitoring
/// implementing the 3-Track Compliance & Performance Rating Flowchart.
class SubcontractorSummaryScreen extends StatefulWidget {
  final String roleName;

  const SubcontractorSummaryScreen({
    super.key,
    required this.roleName,
  });

  @override
  State<SubcontractorSummaryScreen> createState() => _SubcontractorSummaryScreenState();
}

class _SubcontractorSummaryScreenState extends State<SubcontractorSummaryScreen> {
  late List<SubcontractorRecord> _subcontractors;
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All, 1: Grade A, 2: Grade B, 3: RED Alerts

  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All Subcontractors',
    'Grade A (Preferred)',
    'Grade B (Active)',
    'RED ALERTS (Intervention)',
  ];

  @override
  void initState() {
    super.initState();
    _subcontractors = List.from(SubcontractorRecord.sampleSubcontractors);
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

  List<SubcontractorRecord> get _filteredSubcontractors {
    return _subcontractors.where((s) {
      if (_searchQuery.isNotEmpty) {
        final matchesQuery = s.id.toLowerCase().contains(_searchQuery) ||
            s.companyName.toLowerCase().contains(_searchQuery) ||
            s.tradeCategory.toLowerCase().contains(_searchQuery) ||
            s.contractNumber.toLowerCase().contains(_searchQuery);
        if (!matchesQuery) return false;
      }

      switch (_selectedFilterIndex) {
        case 1:
          return s.rating == SubcontractorRating.gradeA;
        case 2:
          return s.rating == SubcontractorRating.gradeB;
        case 3:
          return s.isHighlightedInRed;
        default:
          return true;
      }
    }).toList();
  }

  void _openFlowchart() {
    showDialog(
      context: context,
      builder: (ctx) => const SubcontractorFlowchartModal(),
    );
  }

  void _openDetailSheet(SubcontractorRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SubcontractorDetailSheet(
        record: record,
        onUpdateRecord: (updated) {
          setState(() {
            final idx = _subcontractors.indexWhere((s) => s.id == updated.id);
            if (idx != -1) _subcontractors[idx] = updated;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSubcontractors;

    final gradeACount = _subcontractors
        .where((s) => s.rating == SubcontractorRating.gradeA)
        .length;
    final redAlertCount =
        _subcontractors.where((s) => s.isHighlightedInRed).length;
    final totalManpower = _subcontractors.fold<int>(
        0, (sum, s) => sum + s.actualManpower);
    final totalMachinery = _subcontractors.fold<int>(
        0, (sum, s) => sum + s.actualMachinery);

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
                color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MOD-05',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF43F5E),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Subcontractor Monitoring',
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
            tooltip: 'View 3-Track Monitoring Flowchart',
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
                  gradeA: gradeACount,
                  redAlerts: redAlertCount,
                  manpower: totalManpower,
                  machinery: totalMachinery,
                ),

                const SizedBox(height: 20),

                // Search & Filter
                _buildSearchAndFilters(),

                const SizedBox(height: 16),

                // Subcontractor List
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
                      return _buildSubcontractorCard(item);
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
                '3-Track Subcontractor Compliance Protocol',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Integrated tracking across Timeline (4M/2M/1M Red Memos), Safety (Red Card exclusions), and Manpower/Machinery quotas to compute Subcontractor Performance Index (SPI).',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            ],
          );

          final button = OutlinedButton.icon(
            onPressed: _openFlowchart,
            icon: const Icon(Icons.account_tree_rounded, size: 16),
            label: const Text('View Flowchart'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF43F5E),
              side: const BorderSide(color: Color(0xFFF43F5E)),
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
    required int gradeA,
    required int redAlerts,
    required int manpower,
    required int machinery,
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
              title: 'Grade A Partners',
              count: '$gradeA',
              color: const Color(0xFF10B981),
              icon: Icons.verified_user_rounded,
            ),
            _buildMetricTile(
              title: 'RED Interventions',
              count: '$redAlerts',
              color: const Color(0xFFDC2626),
              icon: Icons.warning_rounded,
            ),
            _buildMetricTile(
              title: 'Site Manpower',
              count: '$manpower',
              color: const Color(0xFF0284C7),
              icon: Icons.badge_rounded,
            ),
            _buildMetricTile(
              title: 'Machinery Active',
              count: '$machinery',
              color: const Color(0xFFF59E0B),
              icon: Icons.precision_manufacturing_rounded,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search subcontractor by name, trade, or contract number...',
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
                  selectedColor: const Color(0xFFF43F5E),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFF43F5E) : AppColors.borderLight,
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

  Widget _buildSubcontractorCard(SubcontractorRecord s) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: s.isHighlightedInRed ? const Color(0xFFFCA5A5) : AppColors.borderLight,
          width: s.isHighlightedInRed ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetailSheet(s),
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
                          s.id,
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
                            s.contractNumber,
                            style: const TextStyle(
                              fontSize: 10.5,
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
                          color: s.rating.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.rating.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: s.rating.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Company Name (Highlighted in RED if flagged)
                Text(
                  s.companyName,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: s.isHighlightedInRed
                        ? const Color(0xFFDC2626)
                        : AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),

                // Trade Category
                Text(
                  s.tradeCategory,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),

                // 3 Tracks status strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _buildChipMetric('Timeline', s.timelineStatus.name.toUpperCase()),
                      _buildChipMetric('Workers', '${s.actualManpower}/${s.requiredManpower}'),
                      _buildChipMetric('Machines', '${s.actualMachinery}/${s.requiredMachinery}'),
                      _buildChipMetric(
                        'SPI',
                        '${s.performanceScore.toStringAsFixed(0)} pts',
                        color: s.rating.color,
                      ),
                    ],
                  ),
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
                      'Target: ${s.targetCompletionDate.day}/${s.targetCompletionDate.month}/${s.targetCompletionDate.year}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSubtle),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Inspect Tracks',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: s.rating.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: s.rating.color),
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

  Widget _buildChipMetric(String label, String value, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.darkText,
          ),
        ),
      ],
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
          Icon(Icons.groups_2_rounded, size: 44, color: AppColors.textSubtle),
          SizedBox(height: 10),
          Text(
            'No matching subcontractors found',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try adjusting your search criteria or rating filter.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

