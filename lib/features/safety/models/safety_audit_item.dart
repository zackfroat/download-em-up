import 'package:flutter/material.dart';

enum HazardSeverity { low, medium, high, critical }

extension HazardSeverityDetails on HazardSeverity {
  String get displayName {
    switch (this) {
      case HazardSeverity.low:
        return 'Low (Advisory)';
      case HazardSeverity.medium:
        return 'Medium Risk';
      case HazardSeverity.high:
        return 'High Risk';
      case HazardSeverity.critical:
        return 'CRITICAL (Stop-Work)';
    }
  }

  Color get color {
    switch (this) {
      case HazardSeverity.low:
        return const Color(0xFF10B981); // Emerald
      case HazardSeverity.medium:
        return const Color(0xFFF59E0B); // Amber
      case HazardSeverity.high:
        return const Color(0xFFF97316); // Orange
      case HazardSeverity.critical:
        return const Color(0xFFEF4444); // Red
    }
  }
}

enum RectificationStatus {
  open,
  inRectification,
  resolvedAndClosed,
}

extension RectificationStatusDetails on RectificationStatus {
  String get displayName {
    switch (this) {
      case RectificationStatus.open:
        return 'Open Hazard';
      case RectificationStatus.inRectification:
        return 'In Rectification';
      case RectificationStatus.resolvedAndClosed:
        return 'Resolved & Closed';
    }
  }

  Color get color {
    switch (this) {
      case RectificationStatus.open:
        return const Color(0xFFEF4444);
      case RectificationStatus.inRectification:
        return const Color(0xFFF59E0B);
      case RectificationStatus.resolvedAndClosed:
        return const Color(0xFF10B981);
    }
  }
}

/// Represents an identified site hazard or near-miss
class HazardReport {
  final String id;
  final String title;
  final String category; // Fall from Height, Electrical, PPE Violation, Struck-By
  final String location;
  final HazardSeverity severity;
  final RectificationStatus status;
  final String reportedBy;
  final String? assignedSupervisor;
  final String correctiveAction;
  final DateTime reportedDate;
  final DateTime? resolvedDate;

  const HazardReport({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.severity,
    required this.status,
    required this.reportedBy,
    this.assignedSupervisor,
    required this.correctiveAction,
    required this.reportedDate,
    this.resolvedDate,
  });

  HazardReport copyWith({
    String? id,
    String? title,
    String? category,
    String? location,
    HazardSeverity? severity,
    RectificationStatus? status,
    String? reportedBy,
    String? assignedSupervisor,
    String? correctiveAction,
    DateTime? reportedDate,
    DateTime? resolvedDate,
  }) {
    return HazardReport(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      reportedBy: reportedBy ?? this.reportedBy,
      assignedSupervisor: assignedSupervisor ?? this.assignedSupervisor,
      correctiveAction: correctiveAction ?? this.correctiveAction,
      reportedDate: reportedDate ?? this.reportedDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
    );
  }

  static List<HazardReport> get sampleHazards => [
        HazardReport(
          id: 'HAZ-2026-041',
          title: 'Unsecured perimeter toe-board on 5th floor slab edge',
          category: 'Fall from Height',
          location: 'Block A Level 5 • East Cantilever',
          severity: HazardSeverity.high,
          status: RectificationStatus.inRectification,
          reportedBy: 'Kamal Ariffin (Site Supervisor)',
          assignedSupervisor: 'Hafiz Rahim (Safety Officer)',
          correctiveAction:
              'Install standard 150mm toe-board and secondary debris catch netting before allowing floor formwork crew to proceed.',
          reportedDate: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        HazardReport(
          id: 'HAZ-2026-042',
          title: 'Exposed 3-phase temporary power distribution cable across roadway',
          category: 'Electrical Safety',
          location: 'Main Site Haul Road • Crossing 2',
          severity: HazardSeverity.critical,
          status: RectificationStatus.resolvedAndClosed,
          reportedBy: 'Hafiz Rahim (Safety Officer)',
          assignedSupervisor: 'David Wong (MEP Engineer)',
          correctiveAction:
              'Power isolated immediately. Cable rerouted through heavy-duty rubber trench ramp and overhead suspension cable bracket.',
          reportedDate: DateTime.now().subtract(const Duration(days: 1)),
          resolvedDate: DateTime.now().subtract(const Duration(hours: 18)),
        ),
        HazardReport(
          id: 'HAZ-2026-043',
          title: 'Subcontractor crew operating grinder without face shield & cut-resistant gloves',
          category: 'PPE Non-Compliance',
          location: 'Steel Rebar Fabrication Yard',
          severity: HazardSeverity.medium,
          status: RectificationStatus.open,
          reportedBy: 'Kamal Ariffin (Site Supervisor)',
          assignedSupervisor: 'Kamal Ariffin',
          correctiveAction:
              'Work stopped. PPE issued from store and toolbox re-briefing delivered to subcontractor foremen.',
          reportedDate: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
}

/// Daily Toolbox Talk log entry
class ToolboxBriefing {
  final String id;
  final String topic;
  final String targetTrade;
  final String siteZone;
  final int workerCount;
  final String conductorName;
  final DateTime dateConducted;

  const ToolboxBriefing({
    required this.id,
    required this.topic,
    required this.targetTrade,
    required this.siteZone,
    required this.workerCount,
    required this.conductorName,
    required this.dateConducted,
  });

  static List<ToolboxBriefing> get sampleBriefings => [
        ToolboxBriefing(
          id: 'TB-2026-110',
          topic: 'Safe Rigging, Crane Hand Signals & Exclusion Zones',
          targetTrade: 'Rigger & Tower Crane Crew',
          siteZone: 'Tower Crane TC-01 Base Staging Area',
          workerCount: 18,
          conductorName: 'Hafiz Rahim (Safety Officer)',
          dateConducted: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ToolboxBriefing(
          id: 'TB-2026-109',
          topic: 'Deep Excavation Shoring Precautions & Gas Monitoring',
          targetTrade: 'Earthworks & Foundation Crew',
          siteZone: 'Zone C Retaining Wall Excavation',
          workerCount: 24,
          conductorName: 'Kamal Ariffin (Site Supervisor)',
          dateConducted: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        ToolboxBriefing(
          id: 'TB-2026-108',
          topic: '100% Tie-Off Rule for Working at Height above 2.0m',
          targetTrade: 'Scaffolding & Steel Fixers',
          siteZone: 'Main Tower Podium Level 3',
          workerCount: 42,
          conductorName: 'Hafiz Rahim (Safety Officer)',
          dateConducted: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}

/// Regulatory Statutory Audit Record
class ComplianceAuditRecord {
  final String id;
  final String title;
  final String authority; // DOSH / CIDB / OSHA / Environmental Dept
  final double complianceScore;
  final String status;
  final String auditor;
  final DateTime auditDate;

  const ComplianceAuditRecord({
    required this.id,
    required this.title,
    required this.authority,
    required this.complianceScore,
    required this.status,
    required this.auditor,
    required this.auditDate,
  });

  static List<ComplianceAuditRecord> get sampleAudits => [
        ComplianceAuditRecord(
          id: 'AUD-2026-01',
          title: 'Quarterly Statutory Occupational Safety & Health Audit',
          authority: 'DOSH (Department of Occupational Safety & Health)',
          complianceScore: 96.4,
          status: 'Compliant (Grade A)',
          auditor: 'Ir. Zulkifli (Senior DOSH Inspector)',
          auditDate: DateTime.now().subtract(const Duration(days: 8)),
        ),
        ComplianceAuditRecord(
          id: 'AUD-2026-02',
          title: 'CIDB Green Card & Worker Competency Site Verification',
          authority: 'CIDB Malaysia',
          complianceScore: 98.2,
          status: '100% Verified Personnel',
          auditor: 'CIDB Enforcement Team',
          auditDate: DateTime.now().subtract(const Duration(days: 18)),
        ),
      ];
}

