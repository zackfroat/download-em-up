import 'package:flutter/material.dart';

/// The exact lifecycle stages matching the user's Equipment Maintenance Schedule flowchart.
enum EquipmentMaintenanceStage {
  registration, // 1-3: Register equipment, specs, expiry, wear & tear, warranty
  scheduleRecorded, // 4-5: Store Team enters estimated schedule -> Recorded in Calendar
  reminderActive, // 6-9: Automated reminders (1 Month, 1 Week, 3 Days) -> PIC notified
  requestSubmitted, // 10: Equipment PIC submits Maintenance Application / Request
  maintenanceInProgress, // 11: Maintenance Team carries out equipment maintenance
  formUploaded, // 12-13: Maintenance Team uploads completed form -> PIC notified for verification
  issuesReported, // 14 [No]: PIC reports outstanding issues back to Maintenance Team
  picVerified, // 14 [Yes]: Equipment PIC verifies and confirms maintenance completion
  cycleUpdated, // 15-16: System updates maintenance records, next date & calendar cycle -> FINISH
}

extension EquipmentMaintenanceStageDetails on EquipmentMaintenanceStage {
  String get displayName {
    switch (this) {
      case EquipmentMaintenanceStage.registration:
        return 'Registration & Specs';
      case EquipmentMaintenanceStage.scheduleRecorded:
        return 'Calendar Scheduled';
      case EquipmentMaintenanceStage.reminderActive:
        return 'Reminders Active';
      case EquipmentMaintenanceStage.requestSubmitted:
        return 'PIC Request Submitted';
      case EquipmentMaintenanceStage.maintenanceInProgress:
        return 'Maintenance in Progress';
      case EquipmentMaintenanceStage.formUploaded:
        return 'Form Uploaded (Awaiting PIC)';
      case EquipmentMaintenanceStage.issuesReported:
        return 'Issues Reported (Rework Required)';
      case EquipmentMaintenanceStage.picVerified:
        return 'PIC Verified & Confirmed';
      case EquipmentMaintenanceStage.cycleUpdated:
        return 'Next Cycle Synced (Completed)';
    }
  }

  int get stepNumber {
    switch (this) {
      case EquipmentMaintenanceStage.registration:
        return 1;
      case EquipmentMaintenanceStage.scheduleRecorded:
        return 2;
      case EquipmentMaintenanceStage.reminderActive:
        return 3;
      case EquipmentMaintenanceStage.requestSubmitted:
        return 4;
      case EquipmentMaintenanceStage.maintenanceInProgress:
        return 5;
      case EquipmentMaintenanceStage.formUploaded:
        return 6;
      case EquipmentMaintenanceStage.issuesReported:
        return 6; // branch No
      case EquipmentMaintenanceStage.picVerified:
        return 7;
      case EquipmentMaintenanceStage.cycleUpdated:
        return 8;
    }
  }

  Color get badgeColor {
    switch (this) {
      case EquipmentMaintenanceStage.registration:
        return const Color(0xFF64748B); // Slate
      case EquipmentMaintenanceStage.scheduleRecorded:
        return const Color(0xFF0284C7); // Sky
      case EquipmentMaintenanceStage.reminderActive:
        return const Color(0xFFF59E0B); // Amber
      case EquipmentMaintenanceStage.requestSubmitted:
        return const Color(0xFF6366F1); // Indigo
      case EquipmentMaintenanceStage.maintenanceInProgress:
        return const Color(0xFFF97316); // Orange
      case EquipmentMaintenanceStage.formUploaded:
        return const Color(0xFF8B5CF6); // Purple
      case EquipmentMaintenanceStage.issuesReported:
        return const Color(0xFFEF4444); // Red
      case EquipmentMaintenanceStage.picVerified:
      case EquipmentMaintenanceStage.cycleUpdated:
        return const Color(0xFF10B981); // Emerald
    }
  }
}

/// Wear & Tear condition levels
enum WearAndTearStatus {
  good,
  minorWear,
  moderateWear,
  criticalWear;

  String get label {
    switch (this) {
      case WearAndTearStatus.good:
        return 'Good / Operational';
      case WearAndTearStatus.minorWear:
        return 'Minor Wear';
      case WearAndTearStatus.moderateWear:
        return 'Moderate Wear (Watchlist)';
      case WearAndTearStatus.criticalWear:
        return 'Critical (Maintenance Urgent)';
    }
  }

  Color get color {
    switch (this) {
      case WearAndTearStatus.good:
        return const Color(0xFF10B981);
      case WearAndTearStatus.minorWear:
        return const Color(0xFF0284C7);
      case WearAndTearStatus.moderateWear:
        return const Color(0xFFF59E0B);
      case WearAndTearStatus.criticalWear:
        return const Color(0xFFEF4444);
    }
  }
}

/// Representation of an Equipment / Machinery entry with full flowchart lifecycle tracking
class EquipmentMaintenanceItem {
  final String id;
  final String equipmentCode; // e.g. EQ-CAT-320D
  final String equipmentName; // e.g. Hydraulic Excavator CAT 320D
  final String category; // e.g. Earthmoving, Lifting, Power
  final String brandAndModel; // e.g. Caterpillar 320D3
  final String serialNumber; // e.g. CAT0320DPN8912
  final String specifications; // e.g. 151HP Diesel, 21-ton payload, 1.2m3 bucket
  final String locationSite; // e.g. Site Sector B - Foundation Zone
  final int operatingHours; // e.g. 1,420 hrs

  final DateTime registrationDate;
  final DateTime warrantyExpiry;
  final DateTime roadTaxOrInspectionExpiry;
  final WearAndTearStatus wearAndTear;

  final DateTime scheduledMaintenanceDate;
  final String estimatedScheduleNotes;
  final bool isCalendarSynced;

  // Automated reminders per flowchart
  final bool reminder1MonthSent;
  final bool reminder1WeekSent;
  final bool reminder3DaysSent;

  final String equipmentPic; // Equipment Person-in-Charge
  final String picContact;
  final bool picRequestSubmitted;
  final DateTime? requestSubmittedDate;
  final String? requestWorkScope;

  final String assignedMaintenanceTeam; // e.g. Apex Heavy Tech Maintenance Crew
  final bool maintenanceTeamStarted;
  final DateTime? maintenanceStartedDate;

  final bool maintenanceFormUploaded;
  final String? maintenanceFormName;
  final String? maintenanceFormNotes;
  final DateTime? formUploadedDate;

  // Decision: Has Maintenance Been Completed Satisfactorily?
  final bool? isSatisfactory;
  final String? outstandingIssuesReport;
  final DateTime? picVerificationDate;

  final DateTime? nextMaintenanceCycleDate;
  final EquipmentMaintenanceStage stage;

  const EquipmentMaintenanceItem({
    required this.id,
    required this.equipmentCode,
    required this.equipmentName,
    required this.category,
    required this.brandAndModel,
    required this.serialNumber,
    required this.specifications,
    required this.locationSite,
    required this.operatingHours,
    required this.registrationDate,
    required this.warrantyExpiry,
    required this.roadTaxOrInspectionExpiry,
    required this.wearAndTear,
    required this.scheduledMaintenanceDate,
    required this.estimatedScheduleNotes,
    this.isCalendarSynced = true,
    this.reminder1MonthSent = true,
    this.reminder1WeekSent = false,
    this.reminder3DaysSent = false,
    required this.equipmentPic,
    required this.picContact,
    this.picRequestSubmitted = false,
    this.requestSubmittedDate,
    this.requestWorkScope,
    required this.assignedMaintenanceTeam,
    this.maintenanceTeamStarted = false,
    this.maintenanceStartedDate,
    this.maintenanceFormUploaded = false,
    this.maintenanceFormName,
    this.maintenanceFormNotes,
    this.formUploadedDate,
    this.isSatisfactory,
    this.outstandingIssuesReport,
    this.picVerificationDate,
    this.nextMaintenanceCycleDate,
    required this.stage,
  });

  EquipmentMaintenanceItem copyWith({
    String? equipmentCode,
    String? equipmentName,
    String? category,
    String? brandAndModel,
    String? serialNumber,
    String? specifications,
    String? locationSite,
    int? operatingHours,
    DateTime? registrationDate,
    DateTime? warrantyExpiry,
    DateTime? roadTaxOrInspectionExpiry,
    WearAndTearStatus? wearAndTear,
    DateTime? scheduledMaintenanceDate,
    String? estimatedScheduleNotes,
    bool? isCalendarSynced,
    bool? reminder1MonthSent,
    bool? reminder1WeekSent,
    bool? reminder3DaysSent,
    String? equipmentPic,
    String? picContact,
    bool? picRequestSubmitted,
    DateTime? requestSubmittedDate,
    String? requestWorkScope,
    String? assignedMaintenanceTeam,
    bool? maintenanceTeamStarted,
    DateTime? maintenanceStartedDate,
    bool? maintenanceFormUploaded,
    String? maintenanceFormName,
    String? maintenanceFormNotes,
    DateTime? formUploadedDate,
    bool? isSatisfactory,
    String? outstandingIssuesReport,
    DateTime? picVerificationDate,
    DateTime? nextMaintenanceCycleDate,
    EquipmentMaintenanceStage? stage,
  }) {
    return EquipmentMaintenanceItem(
      id: id,
      equipmentCode: equipmentCode ?? this.equipmentCode,
      equipmentName: equipmentName ?? this.equipmentName,
      category: category ?? this.category,
      brandAndModel: brandAndModel ?? this.brandAndModel,
      serialNumber: serialNumber ?? this.serialNumber,
      specifications: specifications ?? this.specifications,
      locationSite: locationSite ?? this.locationSite,
      operatingHours: operatingHours ?? this.operatingHours,
      registrationDate: registrationDate ?? this.registrationDate,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      roadTaxOrInspectionExpiry:
          roadTaxOrInspectionExpiry ?? this.roadTaxOrInspectionExpiry,
      wearAndTear: wearAndTear ?? this.wearAndTear,
      scheduledMaintenanceDate:
          scheduledMaintenanceDate ?? this.scheduledMaintenanceDate,
      estimatedScheduleNotes:
          estimatedScheduleNotes ?? this.estimatedScheduleNotes,
      isCalendarSynced: isCalendarSynced ?? this.isCalendarSynced,
      reminder1MonthSent: reminder1MonthSent ?? this.reminder1MonthSent,
      reminder1WeekSent: reminder1WeekSent ?? this.reminder1WeekSent,
      reminder3DaysSent: reminder3DaysSent ?? this.reminder3DaysSent,
      equipmentPic: equipmentPic ?? this.equipmentPic,
      picContact: picContact ?? this.picContact,
      picRequestSubmitted: picRequestSubmitted ?? this.picRequestSubmitted,
      requestSubmittedDate: requestSubmittedDate ?? this.requestSubmittedDate,
      requestWorkScope: requestWorkScope ?? this.requestWorkScope,
      assignedMaintenanceTeam:
          assignedMaintenanceTeam ?? this.assignedMaintenanceTeam,
      maintenanceTeamStarted:
          maintenanceTeamStarted ?? this.maintenanceTeamStarted,
      maintenanceStartedDate:
          maintenanceStartedDate ?? this.maintenanceStartedDate,
      maintenanceFormUploaded:
          maintenanceFormUploaded ?? this.maintenanceFormUploaded,
      maintenanceFormName: maintenanceFormName ?? this.maintenanceFormName,
      maintenanceFormNotes: maintenanceFormNotes ?? this.maintenanceFormNotes,
      formUploadedDate: formUploadedDate ?? this.formUploadedDate,
      isSatisfactory: isSatisfactory ?? this.isSatisfactory,
      outstandingIssuesReport:
          outstandingIssuesReport ?? this.outstandingIssuesReport,
      picVerificationDate: picVerificationDate ?? this.picVerificationDate,
      nextMaintenanceCycleDate:
          nextMaintenanceCycleDate ?? this.nextMaintenanceCycleDate,
      stage: stage ?? this.stage,
    );
  }

  /// Initial sample dataset showcasing each state of the flowchart
  static List<EquipmentMaintenanceItem> get sampleList => [
        // 1. Awaiting PIC Verification after maintenance form upload
        EquipmentMaintenanceItem(
          id: 'EQ-01',
          equipmentCode: 'EQ-CAT-320D',
          equipmentName: 'Hydraulic Excavator CAT 320D',
          category: 'Heavy Earthmoving',
          brandAndModel: 'Caterpillar 320D-3 (2023)',
          serialNumber: 'CAT0320DPN8912',
          specifications:
              '151 HP C4.4 ACERT Engine, 21.8 Ton operating weight, 1.2 m³ heavy-duty rock bucket, high-pressure auxiliary hydraulic lines.',
          locationSite: 'North Embankment Subgrade Cut - Zone 3',
          operatingHours: 2450,
          registrationDate: DateTime(2024, 1, 15),
          warrantyExpiry: DateTime(2027, 1, 15),
          roadTaxOrInspectionExpiry: DateTime(2025, 12, 31),
          wearAndTear: WearAndTearStatus.moderateWear,
          scheduledMaintenanceDate: DateTime.now().subtract(const Duration(days: 2)),
          estimatedScheduleNotes:
              '2,500-hr major preventative service: Hydraulic fluid change, swing motor filter replacement, track tensioning.',
          isCalendarSynced: true,
          reminder1MonthSent: true,
          reminder1WeekSent: true,
          reminder3DaysSent: true,
          equipmentPic: 'Ir. Ahmad Razali (Plant PIC)',
          picContact: '+60 12-882 1092',
          picRequestSubmitted: true,
          requestSubmittedDate: DateTime.now().subtract(const Duration(days: 4)),
          requestWorkScope:
              'Comprehensive hydraulic system overhaul, 500-hr oil filter change, and slew ring lubrication.',
          assignedMaintenanceTeam: 'Tractors Malaysia Field Service Crew',
          maintenanceTeamStarted: true,
          maintenanceStartedDate: DateTime.now().subtract(const Duration(days: 2)),
          maintenanceFormUploaded: true,
          maintenanceFormName: 'CAT320D_PM_Service_Form_REV2.pdf',
          maintenanceFormNotes:
              'Replaced primary & secondary fuel filters. Re-torqued final drive sprocket bolts to 650 Nm. Hydraulic pump pressure calibrated at 350 bar.',
          formUploadedDate: DateTime.now().subtract(const Duration(hours: 6)),
          isSatisfactory: null, // Pending PIC decision
          stage: EquipmentMaintenanceStage.formUploaded,
        ),

        // 2. Outstanding Issues Reported (Decision: NO -> Sent back to maintenance team)
        EquipmentMaintenanceItem(
          id: 'EQ-02',
          equipmentCode: 'EQ-TDN-50T',
          equipmentName: 'Mobile Rough Terrain Crane Tadano 50T',
          category: 'Lifting & Rigging',
          brandAndModel: 'Tadano GR-500EX',
          serialNumber: 'TDN-50T-7721-M',
          specifications:
              '50-ton lifting capacity, 33.4m 4-section boom, Mitsubishi 6M60-TLU3B Turbo Diesel, AML-C load moment limiter.',
          locationSite: 'Tower Crane Erection Base - Sector A',
          operatingHours: 3820,
          registrationDate: DateTime(2023, 6, 10),
          warrantyExpiry: DateTime(2026, 6, 10),
          roadTaxOrInspectionExpiry: DateTime(2025, 11, 20),
          wearAndTear: WearAndTearStatus.criticalWear,
          scheduledMaintenanceDate: DateTime.now().subtract(const Duration(days: 5)),
          estimatedScheduleNotes:
              'Quarterly statutory PMA lifting inspection and hydraulic outrigger cylinder overhaul.',
          isCalendarSynced: true,
          reminder1MonthSent: true,
          reminder1WeekSent: true,
          reminder3DaysSent: true,
          equipmentPic: 'Mohd Danial (Lifting Supervisor)',
          picContact: '+60 17-334 9180',
          picRequestSubmitted: true,
          requestSubmittedDate: DateTime.now().subtract(const Duration(days: 6)),
          requestWorkScope:
              'Outrigger seal replacement, main wire rope inspection, and load moment sensor calibration.',
          assignedMaintenanceTeam: 'RigTech Machinery Engineering Services',
          maintenanceTeamStarted: true,
          maintenanceStartedDate: DateTime.now().subtract(const Duration(days: 4)),
          maintenanceFormUploaded: true,
          maintenanceFormName: 'TADANO_50T_INSPECTION_RPT.pdf',
          maintenanceFormNotes:
              'Outrigger seals replaced. Load cells tested at 100% rated load.',
          formUploadedDate: DateTime.now().subtract(const Duration(days: 2)),
          isSatisfactory: false, // Flagged NO by PIC!
          outstandingIssuesReport:
              'Hydraulic oil weeping observed under rear-left outrigger jack cylinder during holding pressure test. Wire rope lubricant uneven.',
          picVerificationDate: DateTime.now().subtract(const Duration(days: 1)),
          stage: EquipmentMaintenanceStage.issuesReported,
        ),

        // 3. Automated Reminders Active (Upcoming in 3 days)
        EquipmentMaintenanceItem(
          id: 'EQ-03',
          equipmentCode: 'EQ-GEN-150KVA',
          equipmentName: 'Silent Diesel Generator 150 kVA',
          category: 'Power Generation',
          brandAndModel: 'Denyo DCA-150SPK',
          serialNumber: 'DNY-150-88301',
          specifications:
              '150 kVA prime continuous rating, Komatsu SAA6D102E-2 engine, acoustic sound-attenuated canopy 62 dBA at 7m.',
          locationSite: 'Site Main Batching Plant & Laboratory Compound',
          operatingHours: 4120,
          registrationDate: DateTime(2023, 11, 01),
          warrantyExpiry: DateTime(2026, 11, 01),
          roadTaxOrInspectionExpiry: DateTime(2026, 05, 15),
          wearAndTear: WearAndTearStatus.minorWear,
          scheduledMaintenanceDate: DateTime.now().add(const Duration(days: 3)),
          estimatedScheduleNotes:
              'Bi-monthly scheduled lube servicing: Oil change, coolant flush, battery electrolyte test.',
          isCalendarSynced: true,
          reminder1MonthSent: true,
          reminder1WeekSent: true,
          reminder3DaysSent: true,
          equipmentPic: 'Za Atizi Zainuddin (Electrical Site PIC)',
          picContact: '+60 19-440 1827',
          picRequestSubmitted: true,
          requestSubmittedDate: DateTime.now().subtract(const Duration(hours: 18)),
          requestWorkScope:
              'Scheduled 250-hr lube filter change, AVR excitation calibration, and emergency fuel cutoff check.',
          assignedMaintenanceTeam: 'PowerGen On-Site Electrical Crew',
          stage: EquipmentMaintenanceStage.requestSubmitted,
        ),

        // 4. Completed & Next Cycle Synced in Calendar
        EquipmentMaintenanceItem(
          id: 'EQ-04',
          equipmentCode: 'EQ-KOM-D65',
          equipmentName: 'Crawler Bulldozer Komatsu D65PX-18',
          category: 'Heavy Earthmoving',
          brandAndModel: 'Komatsu D65PX-18 (Tier 4 Final)',
          serialNumber: 'KM-D65-99214',
          specifications:
              '217 HP Komatsu SAA6D114E-6 engine, SIGMADOZER blade 5.61 m³, PLUS rotating bushing undercarriage.',
          locationSite: 'Bulk Earthwork Spoil Disposal Area 2',
          operatingHours: 1890,
          registrationDate: DateTime(2024, 3, 20),
          warrantyExpiry: DateTime(2027, 3, 20),
          roadTaxOrInspectionExpiry: DateTime(2026, 03, 19),
          wearAndTear: WearAndTearStatus.good,
          scheduledMaintenanceDate: DateTime.now().subtract(const Duration(days: 14)),
          estimatedScheduleNotes:
              'Routine track tension adjustment, blade pivot pin grease, and air pre-cleaner flush.',
          isCalendarSynced: true,
          reminder1MonthSent: true,
          reminder1WeekSent: true,
          reminder3DaysSent: true,
          equipmentPic: 'Ir. Ahmad Razali (Plant PIC)',
          picContact: '+60 12-882 1092',
          picRequestSubmitted: true,
          requestSubmittedDate: DateTime.now().subtract(const Duration(days: 16)),
          requestWorkScope: 'Preventative track inspection and turbocharger air duct inspection.',
          assignedMaintenanceTeam: 'UMW Komatsu Heavy Machinery Service',
          maintenanceTeamStarted: true,
          maintenanceStartedDate: DateTime.now().subtract(const Duration(days: 14)),
          maintenanceFormUploaded: true,
          maintenanceFormName: 'KOMATSU_D65PX_SIGN_OFF.pdf',
          maintenanceFormNotes:
              'Completed all lubrication schedules. Undercarriage wear measured at 12% (excellent). All torque parameters verified.',
          formUploadedDate: DateTime.now().subtract(const Duration(days: 13)),
          isSatisfactory: true,
          picVerificationDate: DateTime.now().subtract(const Duration(days: 12)),
          nextMaintenanceCycleDate: DateTime.now().add(const Duration(days: 168)), // 6 months
          stage: EquipmentMaintenanceStage.cycleUpdated,
        ),

        // 5. Store Team Estimated Schedule & Calendar Synced (Early reminder stage)
        EquipmentMaintenanceItem(
          id: 'EQ-05',
          equipmentCode: 'EQ-BOM-BW211',
          equipmentName: 'Single Drum Vibratory Roller Bomag BW211',
          category: 'Compaction Machinery',
          brandAndModel: 'Bomag BW211 D-5',
          serialNumber: 'BMG-211-55021',
          specifications:
              '128 HP Deutz Turbo Engine, 11-ton operating mass, dual amplitude exciter drum 2.13m width, Terrameter compaction measurement.',
          locationSite: 'Pavement Subbase Road Alignment - CH 12+400',
          operatingHours: 920,
          registrationDate: DateTime(2024, 7, 01),
          warrantyExpiry: DateTime(2027, 7, 01),
          roadTaxOrInspectionExpiry: DateTime(2026, 06, 30),
          wearAndTear: WearAndTearStatus.good,
          scheduledMaintenanceDate: DateTime.now().add(const Duration(days: 28)),
          estimatedScheduleNotes:
              '1,000-hr exciter drum eccentric shaft bearing oil change and vibration damper rubber mount inspection.',
          isCalendarSynced: true,
          reminder1MonthSent: true, // 1 month reminder sent
          reminder1WeekSent: false,
          reminder3DaysSent: false,
          equipmentPic: 'Za Atizi Zainuddin (Plant Operations PIC)',
          picContact: '+60 19-440 1827',
          picRequestSubmitted: false,
          assignedMaintenanceTeam: 'Multico Bomag Service Department',
          stage: EquipmentMaintenanceStage.reminderActive,
        ),
      ];
}

