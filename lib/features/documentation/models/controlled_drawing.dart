import 'package:flutter/material.dart';

/// Exact lifecycle stages from the Document Control Flowchart
enum DocControlStage {
  adminReceived, // Admin / Document Controller Receives Approved Drawing
  uploadedToDms, // File and Upload Approved Drawing into DMS
  verifyingStatus, // Verify Drawing Number, Revision and Approval Status
  resubmissionRequired, // Decision Yes: Remove Previous Drawing -> Upload Latest -> Verify Latest
  maintainedCurrent, // Decision No: Maintain Current Approved Drawing in System
  siteNotified, // Notify Site Team of Approved Drawing Availability
  downloadedOffline, // Site Team Downloads & Ensures Accessible Offline at Site
  activeConstruction, // Site Team Uses Latest Approved Drawing for Construction (FINISH)
}

extension DocControlStageDetails on DocControlStage {
  String get displayName {
    switch (this) {
      case DocControlStage.adminReceived:
        return 'Received by Doc Controller';
      case DocControlStage.uploadedToDms:
        return 'Uploaded into DMS';
      case DocControlStage.verifyingStatus:
        return 'Verifying Number & Rev';
      case DocControlStage.resubmissionRequired:
        return 'Resubmission / Superseding';
      case DocControlStage.maintainedCurrent:
        return 'Maintained in System';
      case DocControlStage.siteNotified:
        return 'Site Team Notified';
      case DocControlStage.downloadedOffline:
        return 'Cached Offline at Site';
      case DocControlStage.activeConstruction:
        return 'Active for Construction (AFC)';
    }
  }

  Color get badgeColor {
    switch (this) {
      case DocControlStage.adminReceived:
        return const Color(0xFF64748B); // Slate
      case DocControlStage.uploadedToDms:
        return const Color(0xFF0284C7); // Sky Blue
      case DocControlStage.verifyingStatus:
        return const Color(0xFF6366F1); // Indigo
      case DocControlStage.resubmissionRequired:
        return const Color(0xFFEF4444); // Red
      case DocControlStage.maintainedCurrent:
        return const Color(0xFF0D9488); // Teal
      case DocControlStage.siteNotified:
        return const Color(0xFFF59E0B); // Amber
      case DocControlStage.downloadedOffline:
        return const Color(0xFF8B5CF6); // Purple
      case DocControlStage.activeConstruction:
        return const Color(0xFF10B981); // Emerald Green
    }
  }
}

/// Historical superseded revision entry
class DrawingRevisionEntry {
  final String revision;
  final String uploadedAt;
  final String notes;
  final bool isArchived;

  const DrawingRevisionEntry({
    required this.revision,
    required this.uploadedAt,
    required this.notes,
    this.isArchived = true,
  });
}

/// Representation of an official construction drawing managed in the Centralized DMS
class ControlledDrawing {
  final String id;
  final String drawingNumber;
  final String title;
  final String discipline; // Structural, Architectural, Civil, MEP
  final String currentRevision;
  final String approvalStatus; // e.g. "Approved for Construction (AFC)"
  final String projectSite;
  final String documentControllerName;
  final bool isResubmissionRequired;
  final bool isPreviousRemovedFromActive;
  final bool isSiteTeamNotified;
  final bool isAccessibleOffline;
  final String fileName;
  final String fileSize;
  final DocControlStage stage;
  final DateTime receivedDate;
  final List<DrawingRevisionEntry> revisionHistory;

  const ControlledDrawing({
    required this.id,
    required this.drawingNumber,
    required this.title,
    required this.discipline,
    required this.currentRevision,
    required this.approvalStatus,
    required this.projectSite,
    required this.documentControllerName,
    this.isResubmissionRequired = false,
    this.isPreviousRemovedFromActive = false,
    this.isSiteTeamNotified = false,
    this.isAccessibleOffline = false,
    required this.fileName,
    required this.fileSize,
    required this.stage,
    required this.receivedDate,
    this.revisionHistory = const [],
  });

  ControlledDrawing copyWith({
    String? id,
    String? drawingNumber,
    String? title,
    String? discipline,
    String? currentRevision,
    String? approvalStatus,
    String? projectSite,
    String? documentControllerName,
    bool? isResubmissionRequired,
    bool? isPreviousRemovedFromActive,
    bool? isSiteTeamNotified,
    bool? isAccessibleOffline,
    String? fileName,
    String? fileSize,
    DocControlStage? stage,
    DateTime? receivedDate,
    List<DrawingRevisionEntry>? revisionHistory,
  }) {
    return ControlledDrawing(
      id: id ?? this.id,
      drawingNumber: drawingNumber ?? this.drawingNumber,
      title: title ?? this.title,
      discipline: discipline ?? this.discipline,
      currentRevision: currentRevision ?? this.currentRevision,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      projectSite: projectSite ?? this.projectSite,
      documentControllerName:
          documentControllerName ?? this.documentControllerName,
      isResubmissionRequired:
          isResubmissionRequired ?? this.isResubmissionRequired,
      isPreviousRemovedFromActive:
          isPreviousRemovedFromActive ?? this.isPreviousRemovedFromActive,
      isSiteTeamNotified: isSiteTeamNotified ?? this.isSiteTeamNotified,
      isAccessibleOffline: isAccessibleOffline ?? this.isAccessibleOffline,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      stage: stage ?? this.stage,
      receivedDate: receivedDate ?? this.receivedDate,
      revisionHistory: revisionHistory ?? this.revisionHistory,
    );
  }

  static List<ControlledDrawing> get sampleDrawings => [
        ControlledDrawing(
          id: 'DMS-2026-001',
          drawingNumber: 'DWG-STR-T2-401',
          title: 'Tower T2 Foundation Pile Cap & Substructure Reinforcement',
          discipline: 'Structural Engineering',
          currentRevision: 'Rev 04',
          approvalStatus: 'Approved for Construction (AFC)',
          projectSite: 'Tower Base T2 • North Sector',
          documentControllerName: 'Zainal Abidin (Lead Doc Controller)',
          isResubmissionRequired: false,
          isPreviousRemovedFromActive: true,
          isSiteTeamNotified: true,
          isAccessibleOffline: true,
          fileName: 'DWG-STR-T2-401-REV04-AFC.pdf',
          fileSize: '18.4 MB',
          stage: DocControlStage.activeConstruction,
          receivedDate: DateTime.now().subtract(const Duration(days: 4)),
          revisionHistory: const [
            DrawingRevisionEntry(
              revision: 'Rev 03',
              uploadedAt: '12 Oct 2026',
              notes: 'Superseded: Rebar spacing revised per RFI-STR-089.',
            ),
            DrawingRevisionEntry(
              revision: 'Rev 02',
              uploadedAt: '28 Sep 2026',
              notes: 'Superseded: Pile cap dimensions enlarged.',
            ),
          ],
        ),
        ControlledDrawing(
          id: 'DMS-2026-002',
          drawingNumber: 'DWG-ARC-POD-205',
          title: 'Podium Commercial Level 2 Partition & Glazing Layout',
          discipline: 'Architectural',
          currentRevision: 'Rev 03',
          approvalStatus: 'Resubmission Required (RFI Pending)',
          projectSite: 'Podium Block Zone B',
          documentControllerName: 'Nurul Huda (Doc Controller)',
          isResubmissionRequired: true,
          isPreviousRemovedFromActive: true,
          isSiteTeamNotified: false,
          isAccessibleOffline: false,
          fileName: 'DWG-ARC-POD-205-REV03-REJECTED.pdf',
          fileSize: '12.1 MB',
          stage: DocControlStage.resubmissionRequired,
          receivedDate: DateTime.now().subtract(const Duration(days: 1)),
          revisionHistory: const [
            DrawingRevisionEntry(
              revision: 'Rev 02',
              uploadedAt: '15 Oct 2026',
              notes: 'Removed from active use: Fire wall rating amendment.',
            ),
          ],
        ),
        ControlledDrawing(
          id: 'DMS-2026-003',
          drawingNumber: 'DWG-MEP-HVAC-112',
          title: 'Basement 1 Chilled Water Piping & Duct Routing Matrix',
          discipline: 'Mechanical & Plumbing',
          currentRevision: 'Rev 02',
          approvalStatus: 'Approved by Lead Consultant',
          projectSite: 'Basement 1 Plant Room',
          documentControllerName: 'Zainal Abidin (Lead Doc Controller)',
          isResubmissionRequired: false,
          isPreviousRemovedFromActive: false,
          isSiteTeamNotified: true,
          isAccessibleOffline: true,
          fileName: 'DWG-MEP-HVAC-112-REV02-AFC.pdf',
          fileSize: '24.6 MB',
          stage: DocControlStage.downloadedOffline,
          receivedDate: DateTime.now().subtract(const Duration(hours: 18)),
        ),
        ControlledDrawing(
          id: 'DMS-2026-004',
          drawingNumber: 'DWG-CIV-DRAIN-088',
          title: 'Perimeter Surface Stormwater Drainage & Sump Detention',
          discipline: 'Civil & Infrastructure',
          currentRevision: 'Rev 01',
          approvalStatus: 'Pending Verification',
          projectSite: 'Main Access Road & Perimeter Boundary',
          documentControllerName: 'Nurul Huda (Doc Controller)',
          isResubmissionRequired: false,
          isPreviousRemovedFromActive: false,
          isSiteTeamNotified: false,
          isAccessibleOffline: false,
          fileName: 'DWG-CIV-DRAIN-088-REV01.pdf',
          fileSize: '9.8 MB',
          stage: DocControlStage.verifyingStatus,
          receivedDate: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ];
}

