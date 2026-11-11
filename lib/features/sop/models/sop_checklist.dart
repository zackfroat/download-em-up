import 'package:flutter/material.dart';

enum SopStatus {
  inProgress,
  pendingVerification,
  verifiedAndPassed,
  remedialActionRequired,
}

extension SopStatusDetails on SopStatus {
  String get displayName {
    switch (this) {
      case SopStatus.inProgress:
        return 'In Progress (Draft)';
      case SopStatus.pendingVerification:
        return 'Pending Verification';
      case SopStatus.verifiedAndPassed:
        return 'Verified & Passed';
      case SopStatus.remedialActionRequired:
        return 'Action Required';
    }
  }

  Color get color {
    switch (this) {
      case SopStatus.inProgress:
        return const Color(0xFF64748B); // Slate
      case SopStatus.pendingVerification:
        return const Color(0xFFF59E0B); // Amber
      case SopStatus.verifiedAndPassed:
        return const Color(0xFF10B981); // Emerald
      case SopStatus.remedialActionRequired:
        return const Color(0xFFEF4444); // Red
    }
  }
}

enum CheckItemStatus {
  pass,
  fail,
  pending,
  notApplicable,
}

class SopCheckItem {
  final String id;
  final String description;
  final String standardCriteria;
  final CheckItemStatus status;
  final String? inspectorRemarks;

  const SopCheckItem({
    required this.id,
    required this.description,
    required this.standardCriteria,
    this.status = CheckItemStatus.pending,
    this.inspectorRemarks,
  });

  SopCheckItem copyWith({
    String? id,
    String? description,
    String? standardCriteria,
    CheckItemStatus? status,
    String? inspectorRemarks,
  }) {
    return SopCheckItem(
      id: id ?? this.id,
      description: description ?? this.description,
      standardCriteria: standardCriteria ?? this.standardCriteria,
      status: status ?? this.status,
      inspectorRemarks: inspectorRemarks ?? this.inspectorRemarks,
    );
  }
}

class SopChecklist {
  final String id;
  final String checklistNumber;
  final String title;
  final String category;
  final String projectSite;
  final String zoneOrPier;
  final String inspectorName;
  final String? verifyingEngineerName;
  final List<SopCheckItem> items;
  final SopStatus status;
  final DateTime dateCreated;
  final DateTime? dateVerified;
  final String? remedialNotes;

  const SopChecklist({
    required this.id,
    required this.checklistNumber,
    required this.title,
    required this.category,
    required this.projectSite,
    required this.zoneOrPier,
    required this.inspectorName,
    this.verifyingEngineerName,
    required this.items,
    required this.status,
    required this.dateCreated,
    this.dateVerified,
    this.remedialNotes,
  });

  int get passCount =>
      items.where((i) => i.status == CheckItemStatus.pass).length;
  int get failCount =>
      items.where((i) => i.status == CheckItemStatus.fail).length;
  int get pendingCount =>
      items.where((i) => i.status == CheckItemStatus.pending).length;
  double get completionProgress =>
      items.isEmpty ? 0 : (items.length - pendingCount) / items.length;

  SopChecklist copyWith({
    String? id,
    String? checklistNumber,
    String? title,
    String? category,
    String? projectSite,
    String? zoneOrPier,
    String? inspectorName,
    String? verifyingEngineerName,
    List<SopCheckItem>? items,
    SopStatus? status,
    DateTime? dateCreated,
    DateTime? dateVerified,
    String? remedialNotes,
  }) {
    return SopChecklist(
      id: id ?? this.id,
      checklistNumber: checklistNumber ?? this.checklistNumber,
      title: title ?? this.title,
      category: category ?? this.category,
      projectSite: projectSite ?? this.projectSite,
      zoneOrPier: zoneOrPier ?? this.zoneOrPier,
      inspectorName: inspectorName ?? this.inspectorName,
      verifyingEngineerName:
          verifyingEngineerName ?? this.verifyingEngineerName,
      items: items ?? this.items,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      dateVerified: dateVerified ?? this.dateVerified,
      remedialNotes: remedialNotes ?? this.remedialNotes,
    );
  }

  static List<SopChecklist> get sampleChecklists => [
        SopChecklist(
          id: 'SOP-2026-001',
          checklistNumber: 'SOP-CHK-9102',
          title: 'Tower Foundation Pre-Pour Concreting Verification',
          category: 'Concreting & Foundations',
          projectSite: 'Tower Base T2 • North Sector',
          zoneOrPier: 'Pier 01 (Leg A & B)',
          inspectorName: 'Kamal Ariffin (Site Supervisor)',
          verifyingEngineerName: 'Ir. Michael Chen (Resident Engineer)',
          status: SopStatus.verifiedAndPassed,
          dateCreated: DateTime.now().subtract(const Duration(days: 2)),
          dateVerified: DateTime.now().subtract(const Duration(days: 1)),
          items: const [
            SopCheckItem(
              id: 'C1',
              description: 'Formwork stability, tightness, and release agent application',
              standardCriteria: 'Zero leakage gaps, plumb within +/- 3mm tolerance',
              status: CheckItemStatus.pass,
            ),
            SopCheckItem(
              id: 'C2',
              description: 'Rebar size, spacing, lap length, and cover block adequacy',
              standardCriteria: 'BS 8110 minimum cover 50mm for substructure',
              status: CheckItemStatus.pass,
            ),
            SopCheckItem(
              id: 'C3',
              description: 'Stub setting anchor bolts alignment against AFC Drawing',
              standardCriteria: 'Matched with Theodolite survey reading STUB-T2-N449.201',
              status: CheckItemStatus.pass,
            ),
            SopCheckItem(
              id: 'C4',
              description: 'Debris removal & water sump clearance before pour',
              standardCriteria: 'Bottom of pit free from loose clay, muck, or standing water',
              status: CheckItemStatus.pass,
            ),
          ],
        ),
        SopChecklist(
          id: 'SOP-2026-002',
          checklistNumber: 'SOP-CHK-9103',
          title: 'Deep Trench Excavation & Shoring Stability Inspection',
          category: 'Earthworks & Safety',
          projectSite: 'Main Substructure Zone C',
          zoneOrPier: 'Grid C4 - C9 Retaining Pit',
          inspectorName: 'Hafiz Rahim (Safety Supervisor)',
          verifyingEngineerName: 'Ir. Michael Chen (Resident Engineer)',
          status: SopStatus.remedialActionRequired,
          dateCreated: DateTime.now().subtract(const Duration(hours: 18)),
          remedialNotes:
              'Secondary soldier pile at Grid C6 showed minor surface seepage. Dewatering pump installed; trench barricades must be pushed back 1.5m.',
          items: const [
            SopCheckItem(
              id: 'E1',
              description: 'Shoring wall plumbness and sheet pile interlock integrity',
              standardCriteria: 'No visible bulging or excessive lateral deflection',
              status: CheckItemStatus.pass,
            ),
            SopCheckItem(
              id: 'E2',
              description: 'Perimeter safety barricade & warning signage placement',
              standardCriteria: 'Minimum 1.2m height barrier placed 1.0m from edge',
              status: CheckItemStatus.fail,
              inspectorRemarks: 'Barricade was set too close (0.4m) to lip edge.',
            ),
            SopCheckItem(
              id: 'E3',
              description: 'Safe trench access ladder installation (every 15m)',
              standardCriteria: 'Tied off ladder extending 1.0m above landing',
              status: CheckItemStatus.pass,
            ),
            SopCheckItem(
              id: 'E4',
              description: 'Gas testing / atmospheric monitoring for deep pit',
              standardCriteria: 'Oxygen > 19.5%, H2S < 10ppm',
              status: CheckItemStatus.pass,
            ),
          ],
        ),
        SopChecklist(
          id: 'SOP-2026-003',
          checklistNumber: 'SOP-CHK-9104',
          title: 'Modular Scaffolding & Working-at-Height Sign-off',
          category: 'Scaffolding & Access',
          projectSite: 'Podium Level 3 Facade',
          zoneOrPier: 'East Elevation Scaffolding',
          inspectorName: 'David Wong (Site Engineer)',
          status: SopStatus.pendingVerification,
          dateCreated: DateTime.now().subtract(const Duration(hours: 4)),
          items: const [
            SopCheckItem(
              id: 'S1',
              description: 'Sole plates and adjustable base jacks on firm level ground',
              standardCriteria: 'No hollow voids or uncompacted timber pads',
              status: CheckItemStatus.pass,
            ),
            SopCheckItem(
              id: 'S2',
              description: 'Standard ledger and transom locking pin verification',
              standardCriteria: 'Wedged securely with zero loose pins',
              status: CheckItemStatus.pass,
            ),
            SopCheckItem(
              id: 'S3',
              description: 'Full deck toe-boards, double guardrails, and debris netting',
              standardCriteria: 'Top rail 1050mm, mid rail 500mm, toe board 150mm',
              status: CheckItemStatus.pass,
            ),
            SopCheckItem(
              id: 'S4',
              description: 'Wall ties and facade anchor bolts installation',
              standardCriteria: 'Anchors every 4m vertically and 6m horizontally',
              status: CheckItemStatus.pending,
            ),
          ],
        ),
      ];
}

