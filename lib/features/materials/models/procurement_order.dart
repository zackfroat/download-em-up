import 'package:flutter/material.dart';

/// Distinct lifecycle steps representing the user's exact flowchart
enum ProcurementWorkflowStage {
  poApproved, // PO Approved by Management -> Finance Proceeds with Payment
  supplierContacted, // Procurement Notified -> Obtains Proposed Delivery Date -> Discuss with Project Team
  siteReadinessCheck, // Is Site Ready for Delivery? (Decision)
  deliveryScheduled, // Confirm Delivery Date -> Calendar & Notifications (3-day & delivery day reminders)
  siteStockTake, // Supplier Delivers to Site -> Site Team Stock Take -> Compare Actual vs PO/DO
  shortageHandling, // Incomplete Quantity: Record Shortage, Notify Procurement/Supplier, Arrange Outstanding Delivery
  doVerification, // Quantity Complete -> Site PIC Confirms Receipt -> Verify Delivery Order (DO)
  completed, // Upload Proof of Delivery (POD) & DO into System -> Finished
}

extension ProcurementWorkflowStageDetails on ProcurementWorkflowStage {
  String get displayName {
    switch (this) {
      case ProcurementWorkflowStage.poApproved:
        return 'PO & Finance Approved';
      case ProcurementWorkflowStage.supplierContacted:
        return 'Supplier Proposed Date';
      case ProcurementWorkflowStage.siteReadinessCheck:
        return 'Site Readiness Review';
      case ProcurementWorkflowStage.deliveryScheduled:
        return 'Delivery Scheduled';
      case ProcurementWorkflowStage.siteStockTake:
        return 'Stock Take & Inspection';
      case ProcurementWorkflowStage.shortageHandling:
        return 'Shortage / Outstanding Delivery';
      case ProcurementWorkflowStage.doVerification:
        return 'DO & PIC Verification';
      case ProcurementWorkflowStage.completed:
        return 'POD Uploaded (Completed)';
    }
  }

  int get stepIndex {
    switch (this) {
      case ProcurementWorkflowStage.poApproved:
        return 1;
      case ProcurementWorkflowStage.supplierContacted:
        return 2;
      case ProcurementWorkflowStage.siteReadinessCheck:
        return 3;
      case ProcurementWorkflowStage.deliveryScheduled:
        return 4;
      case ProcurementWorkflowStage.siteStockTake:
        return 5;
      case ProcurementWorkflowStage.shortageHandling:
        return 5; // branch
      case ProcurementWorkflowStage.doVerification:
        return 6;
      case ProcurementWorkflowStage.completed:
        return 7;
    }
  }

  Color get badgeColor {
    switch (this) {
      case ProcurementWorkflowStage.poApproved:
        return const Color(0xFF6366F1); // Indigo
      case ProcurementWorkflowStage.supplierContacted:
        return const Color(0xFF0284C7); // Sky blue
      case ProcurementWorkflowStage.siteReadinessCheck:
        return const Color(0xFFF59E0B); // Amber
      case ProcurementWorkflowStage.deliveryScheduled:
        return const Color(0xFF0D9488); // Teal
      case ProcurementWorkflowStage.siteStockTake:
        return const Color(0xFF8B5CF6); // Purple
      case ProcurementWorkflowStage.shortageHandling:
        return const Color(0xFFEF4444); // Error Red
      case ProcurementWorkflowStage.doVerification:
        return const Color(0xFF059669); // Emerald
      case ProcurementWorkflowStage.completed:
        return const Color(0xFF10B981); // Green
    }
  }
}

/// Represents an item inside a Material Procurement Order
class ProcurementItem {
  final String itemName;
  final String specification;
  final int orderedQuantity;
  final int? actualQuantityReceived;
  final String unit;

  const ProcurementItem({
    required this.itemName,
    required this.specification,
    required this.orderedQuantity,
    this.actualQuantityReceived,
    required this.unit,
  });

  bool get isComplete =>
      actualQuantityReceived != null &&
      actualQuantityReceived! >= orderedQuantity;

  int get shortageQuantity {
    if (actualQuantityReceived == null) return 0;
    return (orderedQuantity - actualQuantityReceived!).clamp(0, orderedQuantity);
  }

  ProcurementItem copyWith({
    String? itemName,
    String? specification,
    int? orderedQuantity,
    int? actualQuantityReceived,
    String? unit,
  }) {
    return ProcurementItem(
      itemName: itemName ?? this.itemName,
      specification: specification ?? this.specification,
      orderedQuantity: orderedQuantity ?? this.orderedQuantity,
      actualQuantityReceived:
          actualQuantityReceived ?? this.actualQuantityReceived,
      unit: unit ?? this.unit,
    );
  }
}

/// A comprehensive material procurement tracking order reflecting the exact flowchart
class ProcurementOrder {
  final String id;
  final String poNumber;
  final String supplierName;
  final String supplierContact;
  final String projectSite;
  final List<ProcurementItem> items;
  final ProcurementWorkflowStage stage;
  final DateTime createdDate;
  final DateTime? proposedDeliveryDate;
  final DateTime? confirmedDeliveryDate;
  final bool? isSiteReady;
  final String? rescheduleReason;
  final String? sitePicName;
  final bool isCalendarNotified;
  final bool isThreeDayReminderSent;
  final bool isDeliveryDayNotified;
  final String? deliveryOrderNumber;
  final String? proofOfDeliveryUrl;
  final String? shortageRemarks;

  const ProcurementOrder({
    required this.id,
    required this.poNumber,
    required this.supplierName,
    required this.supplierContact,
    required this.projectSite,
    required this.items,
    required this.stage,
    required this.createdDate,
    this.proposedDeliveryDate,
    this.confirmedDeliveryDate,
    this.isSiteReady,
    this.rescheduleReason,
    this.sitePicName,
    this.isCalendarNotified = false,
    this.isThreeDayReminderSent = false,
    this.isDeliveryDayNotified = false,
    this.deliveryOrderNumber,
    this.proofOfDeliveryUrl,
    this.shortageRemarks,
  });

  ProcurementOrder copyWith({
    String? id,
    String? poNumber,
    String? supplierName,
    String? supplierContact,
    String? projectSite,
    List<ProcurementItem>? items,
    ProcurementWorkflowStage? stage,
    DateTime? createdDate,
    DateTime? proposedDeliveryDate,
    DateTime? confirmedDeliveryDate,
    bool? isSiteReady,
    String? rescheduleReason,
    String? sitePicName,
    bool? isCalendarNotified,
    bool? isThreeDayReminderSent,
    bool? isDeliveryDayNotified,
    String? deliveryOrderNumber,
    String? proofOfDeliveryUrl,
    String? shortageRemarks,
  }) {
    return ProcurementOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplierName: supplierName ?? this.supplierName,
      supplierContact: supplierContact ?? this.supplierContact,
      projectSite: projectSite ?? this.projectSite,
      items: items ?? this.items,
      stage: stage ?? this.stage,
      createdDate: createdDate ?? this.createdDate,
      proposedDeliveryDate: proposedDeliveryDate ?? this.proposedDeliveryDate,
      confirmedDeliveryDate:
          confirmedDeliveryDate ?? this.confirmedDeliveryDate,
      isSiteReady: isSiteReady ?? this.isSiteReady,
      rescheduleReason: rescheduleReason ?? this.rescheduleReason,
      sitePicName: sitePicName ?? this.sitePicName,
      isCalendarNotified: isCalendarNotified ?? this.isCalendarNotified,
      isThreeDayReminderSent:
          isThreeDayReminderSent ?? this.isThreeDayReminderSent,
      isDeliveryDayNotified:
          isDeliveryDayNotified ?? this.isDeliveryDayNotified,
      deliveryOrderNumber: deliveryOrderNumber ?? this.deliveryOrderNumber,
      proofOfDeliveryUrl: proofOfDeliveryUrl ?? this.proofOfDeliveryUrl,
      shortageRemarks: shortageRemarks ?? this.shortageRemarks,
    );
  }

  /// Initial sample procurement orders showcasing each phase of the flowchart
  static List<ProcurementOrder> get initialSampleOrders => [
        ProcurementOrder(
          id: 'PO-2026-081',
          poNumber: 'PO-MTR-8821',
          supplierName: 'Megasteel Building Solutions Ltd',
          supplierContact: '+60 12-384 9912 (Mr. Tan)',
          projectSite: 'Tower A - Main Substructure',
          items: const [
            ProcurementItem(
              itemName: 'High-Tensile Deformed Steel Bar (T25)',
              specification: 'BS 4449 Grade 500B / 12m length',
              orderedQuantity: 250,
              actualQuantityReceived: 250,
              unit: 'Tons',
            ),
            ProcurementItem(
              itemName: 'Mild Steel Round Bar (R10)',
              specification: 'BS 4449 Grade 250',
              orderedQuantity: 80,
              actualQuantityReceived: 80,
              unit: 'Tons',
            ),
          ],
          stage: ProcurementWorkflowStage.completed,
          createdDate: DateTime.now().subtract(const Duration(days: 12)),
          proposedDeliveryDate:
              DateTime.now().subtract(const Duration(days: 4)),
          confirmedDeliveryDate:
              DateTime.now().subtract(const Duration(days: 4)),
          isSiteReady: true,
          sitePicName: 'Engr. David Wong (Site PIC)',
          isCalendarNotified: true,
          isThreeDayReminderSent: true,
          isDeliveryDayNotified: true,
          deliveryOrderNumber: 'DO-MGS-99014',
          proofOfDeliveryUrl: 'pod_towerA_steel_signed.pdf',
        ),
        ProcurementOrder(
          id: 'PO-2026-082',
          poNumber: 'PO-MTR-8822',
          supplierName: 'Precast Concreteworks Industries',
          supplierContact: '+60 19-873 2210 (Ms. Sarah)',
          projectSite: 'Podium Carpark Zone B',
          items: const [
            ProcurementItem(
              itemName: 'Precast RC Hollow Core Slab (HCS 200)',
              specification: 'Span 6.5m, load rating 5kN/m2',
              orderedQuantity: 120,
              actualQuantityReceived: 95,
              unit: 'Pieces',
            ),
          ],
          stage: ProcurementWorkflowStage.shortageHandling,
          createdDate: DateTime.now().subtract(const Duration(days: 6)),
          proposedDeliveryDate:
              DateTime.now().subtract(const Duration(days: 1)),
          confirmedDeliveryDate:
              DateTime.now().subtract(const Duration(days: 1)),
          isSiteReady: true,
          sitePicName: 'Hafiz Rahim (Site Supervisor)',
          isCalendarNotified: true,
          isThreeDayReminderSent: true,
          isDeliveryDayNotified: true,
          deliveryOrderNumber: 'DO-PCI-4402',
          shortageRemarks:
              'Batch missing 25 panels due to supplier transport trailer breakdown. Supplier notified; replacement batch scheduled for tomorrow morning.',
        ),
        ProcurementOrder(
          id: 'PO-2026-083',
          poNumber: 'PO-MTR-8823',
          supplierName: 'Holcim ReadyMix Concrete',
          supplierContact: '+60 13-992 1100 (Dispatch Dept)',
          projectSite: 'Basement 2 Raft Slab Pour',
          items: const [
            ProcurementItem(
              itemName: 'Ready-Mix Grade 40 OPC Waterproof Concrete',
              specification: 'Slump 120mm +/- 25mm with integral waterproofing',
              orderedQuantity: 450,
              unit: 'm³',
            ),
          ],
          stage: ProcurementWorkflowStage.deliveryScheduled,
          createdDate: DateTime.now().subtract(const Duration(days: 4)),
          proposedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
          confirmedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
          isSiteReady: true,
          sitePicName: 'Engr. David Wong (Site PIC)',
          isCalendarNotified: true,
          isThreeDayReminderSent: true,
          isDeliveryDayNotified: false,
        ),
        ProcurementOrder(
          id: 'PO-2026-084',
          poNumber: 'PO-MTR-8824',
          supplierName: 'Saint-Gobain Gyproc Drywall System',
          supplierContact: '+60 17-550 4432 (Mr. Raymond)',
          projectSite: 'Block B Level 5-10 Partitions',
          items: const [
            ProcurementItem(
              itemName: 'Moisture Resistant Gypsum Board (12.5mm)',
              specification: '1200mm x 2400mm tapered edge',
              orderedQuantity: 800,
              unit: 'Sheets',
            ),
            ProcurementItem(
              itemName: 'Galvanized Steel Stud & Track (75mm)',
              specification: '0.55mm BMT zinc coated',
              orderedQuantity: 650,
              unit: 'Lengths',
            ),
          ],
          stage: ProcurementWorkflowStage.siteReadinessCheck,
          createdDate: DateTime.now().subtract(const Duration(days: 2)),
          proposedDeliveryDate: DateTime.now().add(const Duration(days: 4)),
          isSiteReady: null, // Pending site inspection
          sitePicName: 'Kamal Ariffin (Site Engineer)',
          isCalendarNotified: false,
        ),
        ProcurementOrder(
          id: 'PO-2026-085',
          poNumber: 'PO-MTR-8825',
          supplierName: 'Sika Construction Chemicals',
          supplierContact: '+60 12-441 9081 (Technical Sales)',
          projectSite: 'Rooftop Plant Room Waterproofing',
          items: const [
            ProcurementItem(
              itemName: 'Sikalastic-612 Polyurethane Waterproofing Membrane',
              specification: 'Single component liquid applied PU',
              orderedQuantity: 60,
              unit: 'Pails (20L)',
            ),
          ],
          stage: ProcurementWorkflowStage.poApproved,
          createdDate: DateTime.now().subtract(const Duration(hours: 18)),
          sitePicName: 'Kamal Ariffin (Site Engineer)',
        ),
      ];
}

