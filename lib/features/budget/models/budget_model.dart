import 'package:flutter/material.dart';

enum BudgetStatus {
  onTrack,
  caution,
  exceeded,
}

extension BudgetStatusDetails on BudgetStatus {
  String get displayName {
    switch (this) {
      case BudgetStatus.onTrack:
        return 'On Track';
      case BudgetStatus.caution:
        return 'Attention (Near Limit)';
      case BudgetStatus.exceeded:
        return 'Budget Exceeded';
    }
  }

  Color get color {
    switch (this) {
      case BudgetStatus.onTrack:
        return const Color(0xFF10B981); // Emerald
      case BudgetStatus.caution:
        return const Color(0xFFF59E0B); // Amber
      case BudgetStatus.exceeded:
        return const Color(0xFFDC2626); // Red
    }
  }
}

/// Represents a package/trade budget allocation
class BudgetPackage {
  final String code; // e.g., PKG-01
  final String name; // e.g., Foundation & Piling Works
  final String contractor; // e.g., Mega Piling Engineering
  final double allocatedBudget;
  final double committedCost;
  final double actualSpent;
  final BudgetStatus status;
  final String milestoneProgress;

  const BudgetPackage({
    required this.code,
    required this.name,
    required this.contractor,
    required this.allocatedBudget,
    required this.committedCost,
    required this.actualSpent,
    required this.status,
    required this.milestoneProgress,
  });

  double get variance => allocatedBudget - actualSpent;
  double get utilizationPercentage => (actualSpent / allocatedBudget) * 100;
}

/// Represents monthly cost review entry
class MonthlyCostReviewItem {
  final String month; // e.g., October 2026
  final double projectedDisbursement;
  final double actualDisbursement;
  final String remarks;
  final bool isApprovedByDirector;

  const MonthlyCostReviewItem({
    required this.month,
    required this.projectedDisbursement,
    required this.actualDisbursement,
    required this.remarks,
    this.isApprovedByDirector = false,
  });

  MonthlyCostReviewItem copyWith({
    String? month,
    double? projectedDisbursement,
    double? actualDisbursement,
    String? remarks,
    bool? isApprovedByDirector,
  }) {
    return MonthlyCostReviewItem(
      month: month ?? this.month,
      projectedDisbursement: projectedDisbursement ?? this.projectedDisbursement,
      actualDisbursement: actualDisbursement ?? this.actualDisbursement,
      remarks: remarks ?? this.remarks,
      isApprovedByDirector: isApprovedByDirector ?? this.isApprovedByDirector,
    );
  }
}

/// Sample data aggregating costs from procurement, subcontractors, and equipment
class BudgetRepository {
  static double get totalProjectBudget => 24500000.00; // RM 24.5M
  static double get totalCommittedCost => 18450000.00; // RM 18.45M
  static double get totalActualDisbursed => 12850000.00; // RM 12.85M

  static List<BudgetPackage> get samplePackages => [
        const BudgetPackage(
          code: 'PKG-CIVIL-01',
          name: 'Foundation Piling & Substructure Concreting',
          contractor: 'Mega Piling Engineering Sdn Bhd',
          allocatedBudget: 6200000.00,
          committedCost: 5900000.00,
          actualSpent: 4850000.00,
          status: BudgetStatus.onTrack,
          milestoneProgress: '78% Complete',
        ),
        const BudgetPackage(
          code: 'PKG-STEEL-02',
          name: 'Structural Steel Supply & Erection',
          contractor: 'Apex Structural Steel Sdn Bhd',
          allocatedBudget: 5800000.00,
          committedCost: 5400000.00,
          actualSpent: 3950000.00,
          status: BudgetStatus.caution,
          milestoneProgress: '65% Complete (EOT Pending)',
        ),
        const BudgetPackage(
          code: 'PKG-CONC-03',
          name: 'Superstructure Formwork & Concrete Works',
          contractor: 'Citra Bina Concrete Works',
          allocatedBudget: 4500000.00,
          committedCost: 4650000.00,
          actualSpent: 2850000.00,
          status: BudgetStatus.exceeded,
          milestoneProgress: '42% Complete (Intervention Team Deployed)',
        ),
        const BudgetPackage(
          code: 'PKG-MAT-04',
          name: 'Bulk Cement & Ready-Mix Supply (MOD-06)',
          contractor: 'Lafarge Holcim Direct Delivery',
          allocatedBudget: 3200000.00,
          committedCost: 2950000.00,
          actualSpent: 2150000.00,
          status: BudgetStatus.onTrack,
          milestoneProgress: '100% On-Demand Cycle',
        ),
        const BudgetPackage(
          code: 'PKG-EQ-05',
          name: 'Heavy Machinery Lease & Preventive Maintenance (MOD-07)',
          contractor: 'Tadano & Caterpillar Heavy Equipment',
          allocatedBudget: 2800000.00,
          committedCost: 2600000.00,
          actualSpent: 1650000.00,
          status: BudgetStatus.onTrack,
          milestoneProgress: '4 Machinery Units Sched',
        ),
      ];

  static List<MonthlyCostReviewItem> get sampleReviews => [
        const MonthlyCostReviewItem(
          month: 'November 2026 (Current)',
          projectedDisbursement: 1450000.00,
          actualDisbursement: 1120000.00,
          remarks: 'Intervention costs re-allocated to contractor back-charge. Cash flow healthy.',
          isApprovedByDirector: false,
        ),
        const MonthlyCostReviewItem(
          month: 'October 2026',
          projectedDisbursement: 1650000.00,
          actualDisbursement: 1580000.00,
          remarks: 'Pier foundation concrete milestone fully disbursed upon RE sign-off.',
          isApprovedByDirector: true,
        ),
        const MonthlyCostReviewItem(
          month: 'September 2026',
          projectedDisbursement: 1350000.00,
          actualDisbursement: 1410000.00,
          remarks: 'Steel rebar market price index adjustment (+4.4%). Covered by contingency.',
          isApprovedByDirector: true,
        ),
      ];
}

