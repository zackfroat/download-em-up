import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/equipment_maintenance_item.dart';
import '../widgets/equipment_detail_sheet.dart';
import '../widgets/equipment_flowchart_modal.dart';
import '../widgets/register_equipment_modal.dart';

/// Full screen interface for MOD-07: Equipment Maintenance Schedule
/// faithfully implementing the user's uploaded Equipment & Machinery Maintenance Flowchart.
class EquipmentMaintenanceScreen extends StatefulWidget {
  final String roleName;

  const EquipmentMaintenanceScreen({
    super.key,
    required this.roleName,
  });

  @override
  State<EquipmentMaintenanceScreen> createState() => _EquipmentMaintenanceScreenState();
}

class _EquipmentMaintenanceScreenState extends State<EquipmentMaintenanceScreen> {
  late List<EquipmentMaintenanceItem> _equipmentList;
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All, 1: Reminders & Sched, 2: In Maintenance, 3: PIC Decision Pending, 4: Issues/Rework, 5: Completed
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All Machinery',
    'Scheduled & Reminders',
    'Maintenance In Progress',
    'Awaiting PIC Decision',
    'Issues / Rework',
    'Next Cycle Synced',
  ];

  @override
  void initState() {
    super.initState();
    _equipmentList = List.from(EquipmentMaintenanceItem.sampleList);
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

  List<EquipmentMaintenanceItem> get _filteredList {
    return _equipmentList.where((item) {
      if (_selectedFilterIndex == 1 &&
          item.stage != EquipmentMaintenanceStage.scheduleRecorded &&
          item.stage != EquipmentMaintenanceStage.reminderActive &&
          item.stage != EquipmentMaintenanceStage.requestSubmitted) {
        return false;
      }
      if (_selectedFilterIndex == 2 &&
          item.stage != EquipmentMaintenanceStage.maintenanceInProgress) {
        return false;
      }
      if (_selectedFilterIndex == 3 &&
          item.stage != EquipmentMaintenanceStage.formUploaded) {
        return false;
      }
      if (_selectedFilterIndex == 4 &&
          item.stage != EquipmentMaintenanceStage.issuesReported) {
        return false;
      }
      if (_selectedFilterIndex == 5 &&
          item.stage != EquipmentMaintenanceStage.picVerified &&
          item.stage != EquipmentMaintenanceStage.cycleUpdated) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        final matchCode = item.equipmentCode.toLowerCase().contains(q);
        final matchName = item.equipmentName.toLowerCase().contains(q);
        final matchCategory = item.category.toLowerCase().contains(q);
        final matchSerial = item.serialNumber.toLowerCase().contains(q);
        final matchPic = item.equipmentPic.toLowerCase().contains(q);
        if (!matchCode && !matchName && !matchCategory && !matchSerial && !matchPic) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _openDetailSheet(EquipmentMaintenanceItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: EquipmentDetailSheet(
          item: item,
          onUpdate: (updated) {
            setState(() {
              final idx = _equipmentList.indexWhere((e) => e.id == updated.id);
              if (idx != -1) {
                _equipmentList[idx] = updated;
              }
            });
          },
        ),
      ),
    );
  }

  void _openRegisterModal() {
    showDialog(
      context: context,
      builder: (ctx) => RegisterEquipmentModal(
        onRegistered: (newItem) {
          setState(() {
            _equipmentList.insert(0, newItem);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registered ${newItem.equipmentCode} and synced to Master Calendar!'),
              backgroundColor: const Color(0xFFF97316),
            ),
          );
        },
      ),
    );
  }

  void _openFlowchartDialog([EquipmentMaintenanceStage? stage]) {
    showDialog(
      context: context,
      builder: (ctx) => EquipmentFlowchartModal(activeStage: stage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Equipment Maintenance',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'MOD-07',
                    style: TextStyle(
                      color: Color(0xFFEA580C),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Machinery Lifecycle SOP & Reminders',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree_rounded, color: Color(0xFFEA580C)),
            tooltip: 'View Equipment SOP Flowchart',
            onPressed: () => _openFlowchartDialog(),
          ),
          Builder(
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (screenWidth < 400) {
                return const SizedBox(width: 6);
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text(
                    widget.roleName,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: AppColors.staffBadgeBg,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Banner & Metrics
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  _buildFlowchartHeroBanner(),
                  const SizedBox(height: 16),
                  _buildMetricsRow(),
                  const SizedBox(height: 16),
                  _buildSearchAndFilters(),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Equipment List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: _filteredList.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.precision_manufacturing_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No equipment matching your criteria',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _filteredList[index];
                        return _buildEquipmentCard(item);
                      },
                      childCount: _filteredList.length,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRegisterModal,
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Register Equipment (Step 1)'),
      ),
      bottomNavigationBar: AppFooter(roleName: widget.roleName),
    );
  }

  Widget _buildFlowchartHeroBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;

        if (isMobile) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.4)),
                      ),
                      child: const Icon(
                        Icons.schema_rounded,
                        color: Color(0xFFF97316),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Equipment Maintenance SOP Flowchart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Follows full lifecycle: Store Schedule -> Automated Reminders (1 Mo/1 Wk/3 Days) -> PIC Application -> Form Upload -> Decision Gateway -> Next Cycle Sync',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openFlowchartDialog(),
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('View Flowchart Diagram'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
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
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.schema_rounded,
                  color: Color(0xFFF97316),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Equipment Maintenance Standard Operating Flowchart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Follows full lifecycle: Store Schedule -> Automated Reminders (1 Mo/1 Wk/3 Days) -> PIC Application -> Form Upload -> Decision Gateway -> Next Cycle Sync',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _openFlowchartDialog(),
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text('View Flowchart Diagram'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsRow() {
    final total = _equipmentList.length;
    final inProgress = _equipmentList.where((e) => e.stage == EquipmentMaintenanceStage.maintenanceInProgress).length;
    final awaitingDecision = _equipmentList.where((e) => e.stage == EquipmentMaintenanceStage.formUploaded).length;
    final issuesCount = _equipmentList.where((e) => e.stage == EquipmentMaintenanceStage.issuesReported).length;
    final completed = _equipmentList.where((e) => e.stage == EquipmentMaintenanceStage.cycleUpdated || e.stage == EquipmentMaintenanceStage.picVerified).length;

    final metrics = [
      {'label': 'Total Fleet', 'count': '$total', 'icon': Icons.precision_manufacturing_rounded, 'color': const Color(0xFF64748B)},
      {'label': 'In Maintenance', 'count': '$inProgress', 'icon': Icons.engineering_rounded, 'color': const Color(0xFFF97316)},
      {'label': 'Awaiting Decision', 'count': '$awaitingDecision', 'icon': Icons.gavel_rounded, 'color': const Color(0xFF8B5CF6)},
      {'label': 'Issues / Rework', 'count': '$issuesCount', 'icon': Icons.report_problem_rounded, 'color': const Color(0xFFEF4444)},
      {'label': 'Cycles Synced', 'count': '$completed', 'icon': Icons.task_alt_rounded, 'color': const Color(0xFF10B981)},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 860) {
          return Row(
            children: metrics
                .map(
                  (m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildMetricCard(
                        m['label'] as String,
                        m['count'] as String,
                        m['icon'] as IconData,
                        m['color'] as Color,
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        }

        final crossAxisCount = constraints.maxWidth > 540 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: constraints.maxWidth > 400 ? 2.4 : 2.0,
          ),
          itemBuilder: (context, i) {
            final m = metrics[i];
            return _buildMetricCard(
              m['label'] as String,
              m['count'] as String,
              m['icon'] as IconData,
              m['color'] as Color,
            );
          },
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
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

  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by equipment code, machinery name, model, serial no, or PIC...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (idx) {
              final isSelected = _selectedFilterIndex == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_filters[idx]),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilterIndex = idx);
                  },
                  selectedColor: const Color(0xFFF97316),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darkText,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFF97316) : AppColors.borderLight,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentCard(EquipmentMaintenanceItem item) {
    final stage = item.stage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: stage == EquipmentMaintenanceStage.issuesReported
              ? const Color(0xFFEF4444).withValues(alpha: 0.5)
              : (stage == EquipmentMaintenanceStage.formUploaded
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.5)
                  : AppColors.borderLight),
          width: (stage == EquipmentMaintenanceStage.issuesReported || stage == EquipmentMaintenanceStage.formUploaded)
              ? 1.5
              : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openDetailSheet(item),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row: Icon + Code + Category + Step Number
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: stage.badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.precision_manufacturing_rounded,
                      color: stage.badgeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          item.equipmentCode,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFEA580C),
                            letterSpacing: 0.4,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Step Badge in top-right
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Step ${stage.stepNumber}/8',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Equipment Name & Model
              Text(
                item.equipmentName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${item.brandAndModel} • S/N: ${item.serialNumber}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Dedicated Full-Width Lifecycle Stage Banner (Never overlaps!)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: stage.badgeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: stage.badgeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: stage.badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        stage.displayName,
                        style: TextStyle(
                          color: stage.badgeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 10),

              // Specs & Wear Status Strip (Mobile-Adaptive Wrap)
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${item.operatingHours} hrs',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.darkText),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.place_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          item.locationSite,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: item.wearAndTear.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.wearAndTear.label,
                      style: TextStyle(
                        color: item.wearAndTear.color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Scheduled Date & Reminders Strip (Compact & Overflow-Free)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 5),
                    Text(
                      'Sched: ${_formatDate(item.scheduledMaintenanceDate)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkText),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMiniReminderIndicator('1M', item.reminder1MonthSent),
                        const SizedBox(width: 4),
                        _buildMiniReminderIndicator('1W', item.reminder1WeekSent),
                        const SizedBox(width: 4),
                        _buildMiniReminderIndicator('3D', item.reminder3DaysSent),
                      ],
                    ),
                  ],
                ),
              ),

              // Special Alert for Issues Reported (Step 14 NO)
              if (stage == EquipmentMaintenanceStage.issuesReported) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Defect flagged: ${item.outstandingIssuesReport ?? "Defects found"} (Looped to Step 11)',
                          style: const TextStyle(color: Color(0xFF991B1B), fontSize: 10.5, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniReminderIndicator(String label, bool sent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: sent ? const Color(0xFFFEF3C7) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            sent ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 10,
            color: sent ? const Color(0xFFD97706) : Colors.grey,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: sent ? const Color(0xFF78350F) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

