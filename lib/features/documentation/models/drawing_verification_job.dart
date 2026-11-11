import 'package:flutter/material.dart';

/// Exact lifecycle states corresponding to the Stub Setting & Approved Drawing Flowchart
enum StubWorkflowStage {
  enterAccessCode, // Enter Drawing File Name and Provided Access Code in System
  drawingRetrieved, // Retrieve and View Approved Drawing -> Download for Offline Reference
  theodoliteEntry, // Identify Stub Setting Number -> Enter into Theodolite Machine
  superiorVerification, // Superior Verifies Stub Setting Number Against Approved Drawing
  correctionRequired, // [No] Decision: Correct the Setting Number in Theodolite
  proceedConcreting, // [Yes] Decision: Proceed with Stub Setting Concreting
  finalInspection, // Perform Final Inspection and Check Stub Setting
  uploadRecords, // Upload Stub Setting Verification Records to System
  submittedForApproval, // Submit for Final Verification and Approval
  completed, // Completed (Official Sign-off)
}

extension StubWorkflowStageDetails on StubWorkflowStage {
  String get displayName {
    switch (this) {
      case StubWorkflowStage.enterAccessCode:
        return 'Access Code Required';
      case StubWorkflowStage.drawingRetrieved:
        return 'Drawing Retrieved (AFC)';
      case StubWorkflowStage.theodoliteEntry:
        return 'Theodolite Setting Input';
      case StubWorkflowStage.superiorVerification:
        return 'Superior Verification Pending';
      case StubWorkflowStage.correctionRequired:
        return 'Correction Required (No)';
      case StubWorkflowStage.proceedConcreting:
        return 'Approved for Concreting';
      case StubWorkflowStage.finalInspection:
        return 'Post-Pour Inspection';
      case StubWorkflowStage.uploadRecords:
        return 'Records Upload Pending';
      case StubWorkflowStage.submittedForApproval:
        return 'Submitted for Approval';
      case StubWorkflowStage.completed:
        return 'Verified & Completed';
    }
  }

  Color get badgeColor {
    switch (this) {
      case StubWorkflowStage.enterAccessCode:
        return const Color(0xFF64748B); // Slate
      case StubWorkflowStage.drawingRetrieved:
        return const Color(0xFF0284C7); // Sky blue
      case StubWorkflowStage.theodoliteEntry:
        return const Color(0xFF6366F1); // Indigo
      case StubWorkflowStage.superiorVerification:
        return const Color(0xFFF59E0B); // Amber
      case StubWorkflowStage.correctionRequired:
        return const Color(0xFFEF4444); // Red
      case StubWorkflowStage.proceedConcreting:
        return const Color(0xFF0D9488); // Teal
      case StubWorkflowStage.finalInspection:
        return const Color(0xFF8B5CF6); // Purple
      case StubWorkflowStage.uploadRecords:
        return const Color(0xFFD97706); // Orange
      case StubWorkflowStage.submittedForApproval:
        return const Color(0xFF059669); // Emerald
      case StubWorkflowStage.completed:
        return const Color(0xFF10B981); // Green
    }
  }
}

/// Represents an Engineering Drawing & Stub Setting Verification record
class DrawingVerificationJob {
  final String id;
  final String drawingFileName;
  final String accessCode;
  final String drawingTitle;
  final String revisionNumber;
  final String projectSite;
  final String towerFoundationId;
  final String approvedStubSettingNumber;
  final String? theodoliteEnteredNumber;
  final bool isDownloadedOffline;
  final bool? isSettingVerifiedBySuperior;
  final String? superiorVerifierName;
  final String? correctionNotes;
  final String? concreteBatchId;
  final double? plumbnessToleranceMm;
  final String? verificationRecordFile;
  final StubWorkflowStage stage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const DrawingVerificationJob({
    required this.id,
    required this.drawingFileName,
    required this.accessCode,
    required this.drawingTitle,
    required this.revisionNumber,
    required this.projectSite,
    required this.towerFoundationId,
    required this.approvedStubSettingNumber,
    this.theodoliteEnteredNumber,
    this.isDownloadedOffline = false,
    this.isSettingVerifiedBySuperior,
    this.superiorVerifierName,
    this.correctionNotes,
    this.concreteBatchId,
    this.plumbnessToleranceMm,
    this.verificationRecordFile,
    required this.stage,
    required this.createdAt,
    this.completedAt,
  });

  DrawingVerificationJob copyWith({
    String? id,
    String? drawingFileName,
    String? accessCode,
    String? drawingTitle,
    String? revisionNumber,
    String? projectSite,
    String? towerFoundationId,
    String? approvedStubSettingNumber,
    String? theodoliteEnteredNumber,
    bool? isDownloadedOffline,
    bool? isSettingVerifiedBySuperior,
    String? superiorVerifierName,
    String? correctionNotes,
    String? concreteBatchId,
    double? plumbnessToleranceMm,
    String? verificationRecordFile,
    StubWorkflowStage? stage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return DrawingVerificationJob(
      id: id ?? this.id,
      drawingFileName: drawingFileName ?? this.drawingFileName,
      accessCode: accessCode ?? this.accessCode,
      drawingTitle: drawingTitle ?? this.drawingTitle,
      revisionNumber: revisionNumber ?? this.revisionNumber,
      projectSite: projectSite ?? this.projectSite,
      towerFoundationId: towerFoundationId ?? this.towerFoundationId,
      approvedStubSettingNumber:
          approvedStubSettingNumber ?? this.approvedStubSettingNumber,
      theodoliteEnteredNumber:
          theodoliteEnteredNumber ?? this.theodoliteEnteredNumber,
      isDownloadedOffline: isDownloadedOffline ?? this.isDownloadedOffline,
      isSettingVerifiedBySuperior:
          isSettingVerifiedBySuperior ?? this.isSettingVerifiedBySuperior,
      superiorVerifierName:
          superiorVerifierName ?? this.superiorVerifierName,
      correctionNotes: correctionNotes ?? this.correctionNotes,
      concreteBatchId: concreteBatchId ?? this.concreteBatchId,
      plumbnessToleranceMm:
          plumbnessToleranceMm ?? this.plumbnessToleranceMm,
      verificationRecordFile:
          verificationRecordFile ?? this.verificationRecordFile,
      stage: stage ?? this.stage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Sample jobs representing various stages in the flowchart
  static List<DrawingVerificationJob> get sampleJobs => [
        DrawingVerificationJob(
          id: 'JOB-STUB-091',
          drawingFileName: 'DWG-T2-STUB-FOUND-REV4.dwg',
          accessCode: 'AFC-9921-T2',
          drawingTitle: 'Tower T2 Stub Angle & Anchor Bolt Setting Layout',
          revisionNumber: 'Rev 04 (AFC - Approved for Construction)',
          projectSite: 'Tower Base T2 • North Sector',
          towerFoundationId: 'LEG-A / PIER-01',
          approvedStubSettingNumber: 'STUB-T2-N449.201',
          theodoliteEnteredNumber: 'STUB-T2-N449.201',
          isDownloadedOffline: true,
          isSettingVerifiedBySuperior: true,
          superiorVerifierName: 'Ir. Michael Chen (Resident Engineer)',
          concreteBatchId: 'G40-P6-BATCH-0881',
          plumbnessToleranceMm: 1.2,
          verificationRecordFile: 'stub_t2_survey_tolerance_report.pdf',
          stage: StubWorkflowStage.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          completedAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        DrawingVerificationJob(
          id: 'JOB-STUB-092',
          drawingFileName: 'DWG-T3-FOUND-REBAR-REV3.dwg',
          accessCode: 'AFC-8834-T3',
          drawingTitle: 'Tower T3 Anchor Stub Setting & Embedment Detail',
          revisionNumber: 'Rev 03 (AFC)',
          projectSite: 'Tower Base T3 • Ridge Zone',
          towerFoundationId: 'LEG-C / PIER-03',
          approvedStubSettingNumber: 'STUB-T3-E210.840',
          theodoliteEnteredNumber: 'STUB-T3-E210.840',
          isDownloadedOffline: true,
          isSettingVerifiedBySuperior: true,
          superiorVerifierName: 'Ir. Michael Chen (Resident Engineer)',
          concreteBatchId: 'G40-P6-BATCH-0902',
          stage: StubWorkflowStage.finalInspection,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        DrawingVerificationJob(
          id: 'JOB-STUB-093',
          drawingFileName: 'DWG-T4-STUB-COORD-REV2.dwg',
          accessCode: 'AFC-7712-T4',
          drawingTitle: 'Tower T4 Substation Feeder Stub Elevation Setting',
          revisionNumber: 'Rev 02 (AFC)',
          projectSite: 'Tower Base T4 • Valley Crossing',
          towerFoundationId: 'LEG-B / PIER-02',
          approvedStubSettingNumber: 'STUB-T4-S115.650',
          theodoliteEnteredNumber: 'STUB-T4-S115.600', // Mismatch!
          isDownloadedOffline: true,
          isSettingVerifiedBySuperior: false,
          superiorVerifierName: 'Ir. Michael Chen (Resident Engineer)',
          correctionNotes:
              'Theodolite reading offset by 50mm (entered 115.600 instead of 115.650). Calibrate and re-verify.',
          stage: StubWorkflowStage.correctionRequired,
          createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        ),
        DrawingVerificationJob(
          id: 'JOB-STUB-094',
          drawingFileName: 'DWG-T5-ANCHOR-SETTING-REV1.dwg',
          accessCode: 'AFC-6623-T5',
          drawingTitle: 'Tower T5 Quad Leg Stub Setting & Centerline Matrix',
          revisionNumber: 'Rev 01 (AFC)',
          projectSite: 'Tower Base T5 • East Plateau',
          towerFoundationId: 'LEG-D / PIER-04',
          approvedStubSettingNumber: 'STUB-T5-W332.190',
          theodoliteEnteredNumber: 'STUB-T5-W332.190',
          isDownloadedOffline: true,
          stage: StubWorkflowStage.superiorVerification,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        DrawingVerificationJob(
          id: 'JOB-STUB-095',
          drawingFileName: 'DWG-T6-STUB-ANGLES-REV2.dwg',
          accessCode: 'AFC-5510-T6',
          drawingTitle: 'Tower T6 Heavy Angle Stub Setting & Template Anchor',
          revisionNumber: 'Rev 02 (AFC)',
          projectSite: 'Tower Base T6 • Sloped Foundation',
          towerFoundationId: 'LEG-A / PIER-01',
          approvedStubSettingNumber: 'STUB-T6-N802.450',
          isDownloadedOffline: false,
          stage: StubWorkflowStage.enterAccessCode,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];
}

