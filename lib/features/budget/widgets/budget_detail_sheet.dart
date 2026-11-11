import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/budget_model.dart';

/// Interactive modal sheet to review a budget package breakdown or edit package budget allocations (Admin only)
class BudgetDetailSheet extends StatefulWidget {
  final BudgetPackage package;
  final bool isAdmin;
  final Function(BudgetPackage updated)? onUpdatePackage;

  const BudgetDetailSheet({
    super.key,
    required this.package,
    required this.isAdmin,
    this.onUpdatePackage,
  });

  @override
  State<BudgetDetailSheet> createState() => _BudgetDetailSheetState();
}

class _BudgetDetailSheetState extends State<BudgetDetailSheet> {
  late BudgetPackage _package;

  @override
  void initState() {
    super.initState();
    _package = widget.package;
  }

  void _showAdjustBudgetDialog() {
    final controller = TextEditingController(
      text: (_package.allocatedBudget / 1000000).toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.edit_note_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Adjust Contract Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Package: ${_package.name} (${_package.code})',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'New Allocated Budget (Million RM)',
                prefixText: 'RM ',
                suffixText: 'M',
                border: OutlineInputBorder(),
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
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                final newBudget = val * 1000000.0;
                BudgetStatus newStatus = BudgetStatus.onTrack;
                if (_package.actualSpent > newBudget) {
                  newStatus = BudgetStatus.exceeded;
                } else if (_package.actualSpent > newBudget * 0.85) {
                  newStatus = BudgetStatus.caution;
                }

                setState(() {
                  _package = BudgetPackage(
                    code: _package.code,
                    name: _package.name,
                    contractor: _package.contractor,
                    allocatedBudget: newBudget,
                    committedCost: _package.committedCost,
                    actualSpent: _package.actualSpent,
                    status: newStatus,
                    milestoneProgress: _package.milestoneProgress,
                  );
                });
                widget.onUpdatePackage?.call(_package);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget allocation adjusted successfully.'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Allocation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final package = _package;
    final isAdmin = widget.isAdmin;

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
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: package.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: package.status.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    package.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: package.status.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.code,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        package.name,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Permission Indicator Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isAdmin ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAdmin ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAdmin ? Icons.admin_panel_settings_rounded : Icons.visibility_rounded,
                          color: isAdmin ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isAdmin
                                ? 'Admin Mode: Full read, allocation adjustment, and cost review approval permissions.'
                                : 'Staff View: Operational monitoring & cost verification (Read-Only Ledger).',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isAdmin ? const Color(0xFF92400E) : const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Utilization Overview Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Budget Utilization',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              '${package.utilizationPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: package.status.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (package.utilizationPercentage / 100).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(package.status.color),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Financial Breakdown Card
                  Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Financial Cost Ledger',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                            if (isAdmin)
                              TextButton.icon(
                                onPressed: _showAdjustBudgetDialog,
                                icon: const Icon(Icons.tune_rounded, size: 14),
                                label: const Text('Adjust Allocation'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFF59E0B),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Allocated Contract Value',
                            'RM ${(package.allocatedBudget / 1000000).toStringAsFixed(2)}M'),
                        _buildInfoRow('Committed Liabilities',
                            'RM ${(package.committedCost / 1000000).toStringAsFixed(2)}M'),
                        _buildInfoRow('Actual Spent (Disbursed)',
                            'RM ${(package.actualSpent / 1000000).toStringAsFixed(2)}M'),
                        _buildInfoRow(
                          'Remaining Balance',
                          'RM ${(package.variance / 1000000).toStringAsFixed(2)}M',
                          isPositive: package.variance >= 0,
                        ),
                        _buildInfoRow('Appointed Contractor', package.contractor),
                        _buildInfoRow('Physical Milestone', package.milestoneProgress),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Audit & Compliance Guarantee
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user_rounded,
                            color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cross-referenced with MOD-05 Subcontractor Claims & MOD-06 Material Invoices. All disbursements require Resident Engineer digital sign-off.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF065F46),
                              height: 1.35,
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

  Widget _buildInfoRow(String label, String value, {bool? isPositive}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelWidth = constraints.maxWidth < 400 ? 130.0 : 170.0;
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
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isPositive == null
                        ? AppColors.darkText
                        : (isPositive ? const Color(0xFF10B981) : const Color(0xFFDC2626)),
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
