import 'package:flutter/material.dart';

/// Flowchart stages matching the official MOD-01 flowchart
enum SafetyFlowStage {
  siteInduction, // Step 1: Safety Induction (Briefing, Videos, Upload)
  trainingScheduled, // Step 2: Monthly Training Scheduled in Calendar & Notified
  trainingConducted, // Step 3: Training Conducted & Attendance Recorded
  monitoringActivities, // Step 4: Subcontractor Manpower Performing Site Activities
  ncrIssued, // Decision Yes: Safety Violation Identified -> Issue NCR to Subcontractor
  correctiveActionImplemented, // Subcontractor Implements Corrective Action
  correctiveActionVerified, // Verify Corrective Action -> Verified?
  escalatedNcr, // If Verification No -> Issue NCR to Project Team & Subcontractor
  redCardIssued, // Worker repeated violation 3 times -> Issue Red Card & Remove from site
  compliantAndAudited, // Documents & safety compliant -> Safety records maintained
}

extension SafetyFlowStageDetails on SafetyFlowStage {
  String get displayName {
    switch (this) {
      case SafetyFlowStage.siteInduction:
        return 'Site Induction Completed';
      case SafetyFlowStage.trainingScheduled:
        return 'Campaign Sched in Calendar';
      case SafetyFlowStage.trainingConducted:
        return 'Training Attendance Logged';
      case SafetyFlowStage.monitoringActivities:
        return 'Site Safety Monitoring';
      case SafetyFlowStage.ncrIssued:
        return 'NCR Issued to Subcontractor';
      case SafetyFlowStage.correctiveActionImplemented:
        return 'Corrective Action Implemented';
      case SafetyFlowStage.correctiveActionVerified:
        return 'Action Verified (Pending Signoff)';
      case SafetyFlowStage.escalatedNcr:
        return 'Escalated NCR (Team Review)';
      case SafetyFlowStage.redCardIssued:
        return 'Red Card (Worker Removed)';
      case SafetyFlowStage.compliantAndAudited:
        return 'Compliant & Audit Passed';
    }
  }

  Color get badgeColor {
    switch (this) {
      case SafetyFlowStage.siteInduction:
        return const Color(0xFF0284C7); // Sky Blue
      case SafetyFlowStage.trainingScheduled:
        return const Color(0xFF6366F1); // Indigo
      case SafetyFlowStage.trainingConducted:
        return const Color(0xFF0D9488); // Teal
      case SafetyFlowStage.monitoringActivities:
        return const Color(0xFF059669); // Emerald
      case SafetyFlowStage.ncrIssued:
        return const Color(0xFFD97706); // Amber
      case SafetyFlowStage.correctiveActionImplemented:
        return const Color(0xFF2563EB); // Blue
      case SafetyFlowStage.correctiveActionVerified:
        return const Color(0xFF10B981); // Emerald
      case SafetyFlowStage.escalatedNcr:
        return const Color(0xFFDC2626); // Strong Red
      case SafetyFlowStage.redCardIssued:
        return const Color(0xFFB91C1C); // Dark Red
      case SafetyFlowStage.compliantAndAudited:
        return const Color(0xFF16A34A); // Green
    }
  }
}

/// Represents an active safety record/incident according to the flowchart
class SafetyIncidentRecord {
  final String id; // e.g. SAF-2026-001
  final String subcontractorName;
  final String projectSite;
  final String activityDescription;
  final SafetyFlowStage stage;
  final String workerName;
  final String workerId;
  final int violationCount; // Tracks 1, 2, or 3 times (3 = Red Card trigger)
  final String? ncrNumber;
  final String? violationDetails;
  final String? correctiveAction;
  final bool isInductionDone;
  final bool isMonthlyTrainingLogged;
  final DateTime recordDate;

  const SafetyIncidentRecord({
    required this.id,
    required this.subcontractorName,
    required this.projectSite,
    required this.activityDescription,
    required this.stage,
    required this.workerName,
    required this.workerId,
    this.violationCount = 0,
    this.ncrNumber,
    this.violationDetails,
    this.correctiveAction,
    this.isInductionDone = true,
    this.isMonthlyTrainingLogged = true,
    required this.recordDate,
  });

  SafetyIncidentRecord copyWith({
    String? id,
    String? subcontractorName,
    String? projectSite,
    String? activityDescription,
    SafetyFlowStage? stage,
    String? workerName,
    String? workerId,
    int? violationCount,
    String? ncrNumber,
    String? violationDetails,
    String? correctiveAction,
    bool? isInductionDone,
    bool? isMonthlyTrainingLogged,
    DateTime? recordDate,
  }) {
    return SafetyIncidentRecord(
      id: id ?? this.id,
      subcontractorName: subcontractorName ?? this.subcontractorName,
      projectSite: projectSite ?? this.projectSite,
      activityDescription: activityDescription ?? this.activityDescription,
      stage: stage ?? this.stage,
      workerName: workerName ?? this.workerName,
      workerId: workerId ?? this.workerId,
      violationCount: violationCount ?? this.violationCount,
      ncrNumber: ncrNumber ?? this.ncrNumber,
      violationDetails: violationDetails ?? this.violationDetails,
      correctiveAction: correctiveAction ?? this.correctiveAction,
      isInductionDone: isInductionDone ?? this.isInductionDone,
      isMonthlyTrainingLogged: isMonthlyTrainingLogged ?? this.isMonthlyTrainingLogged,
      recordDate: recordDate ?? this.recordDate,
    );
  }

  static List<SafetyIncidentRecord> get sampleRecords => [
        SafetyIncidentRecord(
          id: 'SAF-2026-001',
          subcontractorName: 'Mega Piling Engineering Sdn Bhd',
          projectSite: 'Tower Base T2 • North Sector',
          activityDescription: 'Deep excavation foundation piling and steel cage lowering',
          stage: SafetyFlowStage.monitoringActivities,
          workerName: 'Ahmad Faizul',
          workerId: 'WRK-MP-042',
          violationCount: 0,
          isInductionDone: true,
          isMonthlyTrainingLogged: true,
          recordDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        SafetyIncidentRecord(
          id: 'SAF-2026-002',
          subcontractorName: 'Apex Structural Steel Sdn Bhd',
          projectSite: 'Pier Zone 4 • Substructure',
          activityDescription: 'Working at height without double-lanyard anchor clip',
          stage: SafetyFlowStage.ncrIssued,
          workerName: 'Nurul Hisham',
          workerId: 'WRK-APX-119',
          violationCount: 2,
          ncrNumber: 'NCR-SAF-2026-014',
          violationDetails: 'Safety belt unclipped while adjusting cross-brace bracket at 6.5m elevation.',
          correctiveAction: 'Subcontractor safety supervisor instructed to hold 30-min stand-down retraining.',
          isInductionDone: true,
          isMonthlyTrainingLogged: true,
          recordDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        SafetyIncidentRecord(
          id: 'SAF-2026-003',
          subcontractorName: 'Citra Bina Concrete Works',
          projectSite: 'Pier Cap C2 • Formwork Sector',
          activityDescription: 'Repeated PPE non-compliance: missing safety goggles during rebar grinding',
          stage: SafetyFlowStage.redCardIssued,
          workerName: 'Raju Selvam',
          workerId: 'WRK-CB-088',
          violationCount: 3,
          ncrNumber: 'NCR-SAF-2026-018',
          violationDetails: 'Third consecutive violation of PPE guidelines. Red Card issued on site.',
          correctiveAction: 'Worker permanently demobilized & removed from site. SPI score penalized by -5 pts.',
          isInductionDone: true,
          isMonthlyTrainingLogged: true,
          recordDate: DateTime.now().subtract(const Duration(days: 8)),
        ),
        SafetyIncidentRecord(
          id: 'SAF-2026-004',
          subcontractorName: 'Bina Jaya Heavy Civil',
          projectSite: 'Access Road Alignment Km 14+200',
          activityDescription: 'Earthmoving traffic safety and flagman marshalling',
          stage: SafetyFlowStage.compliantAndAudited,
          workerName: 'Farid Zakaria',
          workerId: 'WRK-BJ-023',
          violationCount: 0,
          isInductionDone: true,
          isMonthlyTrainingLogged: true,
          recordDate: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ];
}

