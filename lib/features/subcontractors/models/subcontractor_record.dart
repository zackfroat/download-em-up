import 'package:flutter/material.dart';

/// Rating tier derived from Subcontractor Performance Score (SPI)
enum SubcontractorRating {
  gradeA, // SPI 85 - 100: Excellent (Preferred partner)
  gradeB, // SPI 70 - 84: Satisfactory (Active monitoring)
  gradeC, // SPI 50 - 69: At Risk (Action Plan required)
  gradeRed, // Critical Delay / Non-compliance: Highlighted in RED (Intervention)
}

extension SubcontractorRatingDetails on SubcontractorRating {
  String get displayName {
    switch (this) {
      case SubcontractorRating.gradeA:
        return 'Grade A (Excellent)';
      case SubcontractorRating.gradeB:
        return 'Grade B (Satisfactory)';
      case SubcontractorRating.gradeC:
        return 'Grade C (At Risk)';
      case SubcontractorRating.gradeRed:
        return 'RED ALERT (Critical Intervention)';
    }
  }

  Color get color {
    switch (this) {
      case SubcontractorRating.gradeA:
        return const Color(0xFF10B981);
      case SubcontractorRating.gradeB:
        return const Color(0xFF0284C7);
      case SubcontractorRating.gradeC:
        return const Color(0xFFF59E0B);
      case SubcontractorRating.gradeRed:
        return const Color(0xFFDC2626);
    }
  }
}

/// Status of the 3 timeline memo intervals before completion
enum TimelineMemoStatus {
  normal, // Ahead or on track
  memo1Sent, // 1st Memo: 4 Months Before Completion
  memo2Sent, // 2nd Memo: 2 Months Before Completion (Submits delay reasons & EOT)
  memo3Critical, // 3rd Memo: 1 Month Before Completion -> RED Highlight
  contractorIntervened, // Main Contractor Intervenes -> Extra costs recorded & recovered
}

/// Represents a registered subcontractor with contractual, timeline, and safety tracking
class SubcontractorRecord {
  final String id;
  final String companyName;
  final String tradeCategory; // Piling, Structural Steel, Formwork, Earthworks, MEP
  final String contractNumber;
  final DateTime contractStartDate;
  final DateTime targetCompletionDate;
  final int requiredManpower;
  final int actualManpower;
  final int requiredMachinery;
  final int actualMachinery;
  
  // 3-Track Compliance Flags
  final TimelineMemoStatus timelineStatus;
  final bool hasSafetyViolation;
  final int safetyRedCardCount;
  final bool isManpowerMachineryCompliant;
  final int nonComplianceMemoCount;

  // Final consolidated score (SPI: 0 - 100)
  final double performanceScore;
  final SubcontractorRating rating;
  final String? interventionNotes;

  const SubcontractorRecord({
    required this.id,
    required this.companyName,
    required this.tradeCategory,
    required this.contractNumber,
    required this.contractStartDate,
    required this.targetCompletionDate,
    required this.requiredManpower,
    required this.actualManpower,
    required this.requiredMachinery,
    required this.actualMachinery,
    required this.timelineStatus,
    this.hasSafetyViolation = false,
    this.safetyRedCardCount = 0,
    this.isManpowerMachineryCompliant = true,
    this.nonComplianceMemoCount = 0,
    required this.performanceScore,
    required this.rating,
    this.interventionNotes,
  });

  bool get isHighlightedInRed =>
      timelineStatus == TimelineMemoStatus.memo3Critical ||
      timelineStatus == TimelineMemoStatus.contractorIntervened ||
      rating == SubcontractorRating.gradeRed;

  SubcontractorRecord copyWith({
    String? id,
    String? companyName,
    String? tradeCategory,
    String? contractNumber,
    DateTime? contractStartDate,
    DateTime? targetCompletionDate,
    int? requiredManpower,
    int? actualManpower,
    int? requiredMachinery,
    int? actualMachinery,
    TimelineMemoStatus? timelineStatus,
    bool? hasSafetyViolation,
    int? safetyRedCardCount,
    bool? isManpowerMachineryCompliant,
    int? nonComplianceMemoCount,
    double? performanceScore,
    SubcontractorRating? rating,
    String? interventionNotes,
  }) {
    return SubcontractorRecord(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      tradeCategory: tradeCategory ?? this.tradeCategory,
      contractNumber: contractNumber ?? this.contractNumber,
      contractStartDate: contractStartDate ?? this.contractStartDate,
      targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
      requiredManpower: requiredManpower ?? this.requiredManpower,
      actualManpower: actualManpower ?? this.actualManpower,
      requiredMachinery: requiredMachinery ?? this.requiredMachinery,
      actualMachinery: actualMachinery ?? this.actualMachinery,
      timelineStatus: timelineStatus ?? this.timelineStatus,
      hasSafetyViolation: hasSafetyViolation ?? this.hasSafetyViolation,
      safetyRedCardCount: safetyRedCardCount ?? this.safetyRedCardCount,
      isManpowerMachineryCompliant:
          isManpowerMachineryCompliant ?? this.isManpowerMachineryCompliant,
      nonComplianceMemoCount:
          nonComplianceMemoCount ?? this.nonComplianceMemoCount,
      performanceScore: performanceScore ?? this.performanceScore,
      rating: rating ?? this.rating,
      interventionNotes: interventionNotes ?? this.interventionNotes,
    );
  }

  static List<SubcontractorRecord> get sampleSubcontractors => [
        SubcontractorRecord(
          id: 'SUB-001',
          companyName: 'Mega Piling Engineering Sdn Bhd',
          tradeCategory: 'Foundation & Bored Piling',
          contractNumber: 'CNT-2025-MP01',
          contractStartDate: DateTime(2025, 4, 1),
          targetCompletionDate: DateTime(2026, 8, 30),
          requiredManpower: 24,
          actualManpower: 24,
          requiredMachinery: 5,
          actualMachinery: 5,
          timelineStatus: TimelineMemoStatus.normal,
          hasSafetyViolation: false,
          safetyRedCardCount: 0,
          isManpowerMachineryCompliant: true,
          nonComplianceMemoCount: 0,
          performanceScore: 94.0,
          rating: SubcontractorRating.gradeA,
        ),
        SubcontractorRecord(
          id: 'SUB-002',
          companyName: 'Apex Structural Steel Sdn Bhd',
          tradeCategory: 'Structural Steel Erection',
          contractNumber: 'CNT-2025-APX04',
          contractStartDate: DateTime(2025, 6, 15),
          targetCompletionDate: DateTime(2026, 11, 20),
          requiredManpower: 32,
          actualManpower: 28,
          requiredMachinery: 4,
          actualMachinery: 3,
          timelineStatus: TimelineMemoStatus.memo2Sent,
          hasSafetyViolation: true,
          safetyRedCardCount: 1,
          isManpowerMachineryCompliant: false,
          nonComplianceMemoCount: 2,
          performanceScore: 72.5,
          rating: SubcontractorRating.gradeB,
          interventionNotes: 'EOT submitted for 3 weeks; awaiting resident engineer review.',
        ),
        SubcontractorRecord(
          id: 'SUB-003',
          companyName: 'Citra Bina Concrete Works',
          tradeCategory: 'Substructure Concreting & Formwork',
          contractNumber: 'CNT-2025-CB09',
          contractStartDate: DateTime(2025, 3, 1),
          targetCompletionDate: DateTime(2026, 7, 15),
          requiredManpower: 45,
          actualManpower: 26,
          requiredMachinery: 6,
          actualMachinery: 3,
          timelineStatus: TimelineMemoStatus.memo3Critical,
          hasSafetyViolation: true,
          safetyRedCardCount: 2,
          isManpowerMachineryCompliant: false,
          nonComplianceMemoCount: 4,
          performanceScore: 46.0,
          rating: SubcontractorRating.gradeRed,
          interventionNotes: 'Critical delay (-42 days behind). Highlighted in RED. Main contractor intervention team deployed.',
        ),
        SubcontractorRecord(
          id: 'SUB-004',
          companyName: 'Bina Jaya Heavy Civil',
          tradeCategory: 'Drainage & Earthworks',
          contractNumber: 'CNT-2025-BJ12',
          contractStartDate: DateTime(2025, 8, 1),
          targetCompletionDate: DateTime(2027, 2, 28),
          requiredManpower: 18,
          actualManpower: 18,
          requiredMachinery: 8,
          actualMachinery: 8,
          timelineStatus: TimelineMemoStatus.memo1Sent,
          hasSafetyViolation: false,
          safetyRedCardCount: 0,
          isManpowerMachineryCompliant: true,
          nonComplianceMemoCount: 0,
          performanceScore: 88.0,
          rating: SubcontractorRating.gradeA,
        ),
      ];
}

