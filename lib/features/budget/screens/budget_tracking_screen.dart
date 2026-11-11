import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/budget_model.dart';
import '../widgets/budget_detail_sheet.dart';

/// Full screen interface for MOD-04: Budget Tracking Dashboard & Monthly Cost Review
/// aggregating project-wide expenditures across Materials (MOD-06), Subcontractors (MOD-05), and Equipment (MOD-07).
class BudgetTrackingScreen extends StatefulWidget {
  final String roleName;

  const BudgetTrackingScreen({
    super.key,
    required this.roleName,
  });

  @override
  State<BudgetTrackingScreen> createState() => _BudgetTrackingScreenState();
}

class _BudgetTrackingScreenState extends State<BudgetTrackingScreen> {
  late List<BudgetPackage> _packages;
  late List<MonthlyCostReviewItem> _monthlyReviews;
  int _selectedTab = 0; // 0: Work Packages, 1: Monthly Cost Reviews
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _packages = List.from(BudgetRepository.samplePackages);
    _monthlyReviews = List.from(BudgetRepository.sampleReviews);
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

  List<BudgetPackage> get _filteredPackages {
    if (_searchQuery.isEmpty) return _packages;
    return _packages.where((p) {
      return p.code.toLowerCase().contains(_searchQuery) ||
          p.name.toLowerCase().contains(_searchQuery) ||
          p.contractor.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _openDetailSheet(BudgetPackage package) {
    final isAdmin = widget.roleName.toLowerCase().contains('admin');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BudgetDetailSheet(
        package: package,
        isAdmin: isAdmin,
        onUpdatePackage: (updated) {
          setState(() {
            final idx = _packages.indexWhere((p) => p.code == updated.code);
            if (idx != -1) _packages[idx] = updated;
          });
        },
      ),
    );
  }

  void _toggleApproval(int index) {
    final isAdmin = widget.roleName.toLowerCase().contains('admin');
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Director authorization required: Only Admin accounts can sign off on monthly budget reviews.',
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      final current = _monthlyReviews[index];
      _monthlyReviews[index] = current.copyWith(
        isApprovedByDirector: !current.isApprovedByDirector,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _monthlyReviews[index].isApprovedByDirector
              ? 'Monthly disbursement signed off by Project Director.'
              : 'Disbursement approval revoked.',
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPackages;

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
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MOD-04',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Budget Tracking & Cost Review',
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
                // Top Executive Budget Card
                _buildExecutiveBanner(),

                const SizedBox(height: 16),

                // Metrics Grid
                _buildMetricsGrid(),

                const SizedBox(height: 20),

                // Tab Selector
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
                          title: 'Work Package Breakdown',
                          icon: Icons.pie_chart_outline_rounded,
                          isSelected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          title: 'Monthly Cost Reviews',
                          icon: Icons.calendar_view_month_rounded,
                          isSelected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                if (_selectedTab == 0) ...[
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
                        hintText: 'Search packages by code, trade, or contractor...',
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
                  const SizedBox(height: 14),

                  // Packages List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildPackageCard(item);
                    },
                  ),
                ] else ...[
                  // Monthly Reviews List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _monthlyReviews.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rev = _monthlyReviews[index];
                      return _buildMonthlyReviewCard(rev, index);
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
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16, color: isSelected ? Colors.white : AppColors.darkText),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
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

  Widget _buildExecutiveBanner() {
    final isAdmin = widget.roleName.toLowerCase().contains('admin');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                'Executive Project Financial Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isAdmin ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAdmin ? Icons.admin_panel_settings_rounded : Icons.lock_outline_rounded,
                        size: 13,
                        color: isAdmin ? const Color(0xFFB45309) : const Color(0xFF15803D),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isAdmin ? 'Admin Approval Mode' : 'Staff Read-Only',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isAdmin ? const Color(0xFFB45309) : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isAdmin
                ? 'Admin Clearance: Authorized to approve monthly disbursements, adjust contract allocations, and override budget alerts.'
                : 'Staff View: Operational visibility into package disbursements and variance. Cost reviews require Director sign-off.',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
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
              title: 'Total Project Budget',
              count: 'RM 24.5M',
              color: const Color(0xFF0284C7),
              icon: Icons.account_balance_rounded,
            ),
            _buildMetricTile(
              title: 'Committed Cost',
              count: 'RM 18.5M',
              color: const Color(0xFFF59E0B),
              icon: Icons.pending_actions_rounded,
            ),
            _buildMetricTile(
              title: 'Actual Spent',
              count: 'RM 12.9M',
              color: const Color(0xFF10B981),
              icon: Icons.payments_rounded,
            ),
            _buildMetricTile(
              title: 'Remaining Contingency',
              count: 'RM 6.0M',
              color: const Color(0xFF6366F1),
              icon: Icons.savings_rounded,
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
                    fontSize: 17,
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
                    fontSize: 10.5,
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

  Widget _buildPackageCard(BudgetPackage p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: p.status == BudgetStatus.exceeded
              ? const Color(0xFFFCA5A5)
              : AppColors.borderLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetailSheet(p),
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
                    Text(
                      p.code,
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
                          color: p.status.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.status.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: p.status.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Package Name
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.contractor,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),

                // Financial summary strip
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
                      _buildChipMetric('Budget', 'RM ${(p.allocatedBudget / 1000000).toStringAsFixed(1)}M'),
                      _buildChipMetric('Spent', 'RM ${(p.actualSpent / 1000000).toStringAsFixed(1)}M'),
                      _buildChipMetric('Usage', '${p.utilizationPercentage.toStringAsFixed(0)}%', color: p.status.color),
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
                      p.milestoneProgress,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSubtle),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Ledger',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: p.status.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: p.status.color),
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

  Widget _buildMonthlyReviewCard(MonthlyCostReviewItem rev, int index) {
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
            runSpacing: 6,
            children: [
              Text(
                rev.month,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rev.isApprovedByDirector
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rev.isApprovedByDirector ? 'Director Approved' : 'Pending Sign-off',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: rev.isApprovedByDirector
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Projected', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text(
                      'RM ${(rev.projectedDisbursement / 1000000).toStringAsFixed(2)}M',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Actual Disbursed', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text(
                      'RM ${(rev.actualDisbursement / 1000000).toStringAsFixed(2)}M',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rev.remarks,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3),
          ),
          const SizedBox(height: 12),
          if (widget.roleName.toLowerCase().contains('admin'))
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _toggleApproval(index),
                icon: Icon(
                  rev.isApprovedByDirector
                      ? Icons.remove_circle_outline_rounded
                      : Icons.draw_rounded,
                  size: 16,
                ),
                label: Text(
                  rev.isApprovedByDirector
                      ? 'Revoke Director Approval'
                      : 'Director Sign-off & Authorize Disbursement',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: rev.isApprovedByDirector
                      ? const Color(0xFFDC2626)
                      : const Color(0xFFF59E0B),
                  side: BorderSide(
                    color: rev.isApprovedByDirector
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFF59E0B),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_clock_rounded, size: 14, color: AppColors.textSubtle),
                  SizedBox(width: 6),
                  Text(
                    'Director Sign-off Required (Admin Only)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
        ],
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
}

