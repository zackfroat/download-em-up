import 'package:flutter/material.dart';
import '../models/equipment_maintenance_item.dart';

/// Interactive modal illustrating the complete Equipment Maintenance Schedule Flowchart
class EquipmentFlowchartModal extends StatelessWidget {
  final EquipmentMaintenanceStage? activeStage;

  const EquipmentFlowchartModal({
    super.key,
    this.activeStage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 640;

    return Dialog(
      backgroundColor: const Color(0xFF0F172A), // Dark slate matching the blueprint/flowchart design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF334155), width: 1.5),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 20,
        vertical: isMobile ? 12 : 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 860),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFF97316).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.build_circle_rounded,
                      color: Color(0xFFF97316),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Equipment & Machinery Maintenance SOP Flowchart',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Standard Operational Workflow: Registration -> Schedule Calendar -> Reminders -> PIC Sign-Off -> Next Cycle Sync',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF334155)),

            // Flowchart Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // START
                        _buildPillNode('START', const Color(0xFF22C55E)),
                        _buildConnectorArrow(),

                        // 1. Register All Equipment / Machinery in System
                        _buildFlowNode(
                          title: 'Register All Equipment / Machinery in System',
                          subtitle: 'Digital inventory onboarding: Assign Unique Equipment ID & Category',
                          isActive: activeStage == EquipmentMaintenanceStage.registration,
                          badgeNumber: '1',
                        ),
                        _buildConnectorArrow(),

                        // 2. Enter Equipment Specifications and Details
                        _buildFlowNode(
                          title: 'Enter Equipment Specifications and Details',
                          subtitle: 'Brand, model, serial no, engine capacity, load rating, and operational site',
                          isActive: activeStage == EquipmentMaintenanceStage.registration,
                          badgeNumber: '2',
                        ),
                        _buildConnectorArrow(),

                        // 3. Record Expiry Date, Maintenance Date, Wear & Tear Status and Warranty Period
                        _buildFlowNode(
                          title: 'Record Expiry Date, Maintenance Date, Wear & Tear Status and Warranty Period',
                          subtitle: 'PMA/PMT inspection permits, statutory warranty bounds, and baseline wear assessment',
                          isActive: activeStage == EquipmentMaintenanceStage.registration,
                          badgeNumber: '3',
                        ),
                        _buildConnectorArrow(),

                        // 4. Store Team Enters Estimated Maintenance Schedule
                        _buildFlowNode(
                          title: 'Store Team Enters Estimated Maintenance Schedule',
                          subtitle: 'Plant supervisor inputs operating hour thresholds & planned servicing dates',
                          isActive: activeStage == EquipmentMaintenanceStage.scheduleRecorded,
                          badgeNumber: '4',
                        ),
                        _buildConnectorArrow(),

                        // 5. System Automatically Records Maintenance Schedule in Calendar
                        _buildFlowNode(
                          title: 'System Automatically Records Maintenance Schedule in Calendar',
                          subtitle: 'Project master schedule & site equipment calendar synchronized automatically',
                          isActive: activeStage == EquipmentMaintenanceStage.scheduleRecorded,
                          badgeNumber: '5',
                        ),
                        _buildConnectorArrow(),

                        // 6. System Sends First Reminder: 1 Month Before Maintenance
                        _buildFlowNode(
                          title: 'System Sends First Reminder: 1 Month Before Maintenance',
                          subtitle: 'Automated 30-day early notification to Plant Manager & Procurement for spare parts',
                          isActive: activeStage == EquipmentMaintenanceStage.reminderActive,
                          accentColor: const Color(0xFF0284C7),
                          badgeNumber: '6',
                        ),
                        _buildConnectorArrow(),

                        // 7. System Sends Second Reminder: 1 Week Before Maintenance
                        _buildFlowNode(
                          title: 'System Sends Second Reminder: 1 Week Before Maintenance',
                          subtitle: '7-day alert: Mobilize technical service crew & verify workshop readiness',
                          isActive: activeStage == EquipmentMaintenanceStage.reminderActive,
                          accentColor: const Color(0xFFF59E0B),
                          badgeNumber: '7',
                        ),
                        _buildConnectorArrow(),

                        // 8. System Sends Third Reminder: 3 Days Before Maintenance
                        _buildFlowNode(
                          title: 'System Sends Third Reminder: 3 Days Before Maintenance',
                          subtitle: '72-hour final reminder: Site preparation & machine staging notification',
                          isActive: activeStage == EquipmentMaintenanceStage.reminderActive,
                          accentColor: const Color(0xFFF97316),
                          badgeNumber: '8',
                        ),
                        _buildConnectorArrow(),

                        // 9. Equipment PIC Receives Maintenance Notifications
                        _buildFlowNode(
                          title: 'Equipment PIC Receives Maintenance Notifications',
                          subtitle: 'Designated Site Person-In-Charge alerted on mobile dashboard & email',
                          isActive: activeStage == EquipmentMaintenanceStage.reminderActive,
                          badgeNumber: '9',
                        ),
                        _buildConnectorArrow(),

                        // 10. Equipment PIC Submits Maintenance Application / Request
                        _buildFlowNode(
                          title: 'Equipment PIC Submits Maintenance Application / Request',
                          subtitle: 'Formal work order request logged with operating hours and scope of service',
                          isActive: activeStage == EquipmentMaintenanceStage.requestSubmitted,
                          badgeNumber: '10',
                        ),
                        _buildConnectorArrow(),

                        // 11. Maintenance Team Carries Out Equipment Maintenance
                        _buildFlowNode(
                          title: 'Maintenance Team Carries Out Equipment Maintenance',
                          subtitle: 'Technicians execute mechanical overhaul, oil/filter replacement, electrical & safety checks',
                          isActive: activeStage == EquipmentMaintenanceStage.maintenanceInProgress,
                          accentColor: const Color(0xFFF97316),
                          badgeNumber: '11',
                          highlightLoopTarget: true,
                        ),
                        _buildConnectorArrow(),

                        // 12. Maintenance Team Uploads Completed Maintenance Form into System
                        _buildFlowNode(
                          title: 'Maintenance Team Uploads Completed Maintenance Form into System',
                          subtitle: 'Service reports, replaced parts list, torque calibration logs, and sign-offs uploaded',
                          isActive: activeStage == EquipmentMaintenanceStage.formUploaded,
                          badgeNumber: '12',
                        ),
                        _buildConnectorArrow(),

                        // 13. System Notifies Equipment PIC for Verification
                        _buildFlowNode(
                          title: 'System Notifies Equipment PIC for Verification',
                          subtitle: 'Push notification & alert dispatched to PIC to inspect completed machine',
                          isActive: activeStage == EquipmentMaintenanceStage.formUploaded,
                          badgeNumber: '13',
                        ),
                        _buildConnectorArrow(),

                        // 14. DECISION: Has Maintenance Been Completed Satisfactorily?
                        _buildDecisionNode(
                          question: 'Has Maintenance Been Completed Satisfactorily?',
                          isActive: activeStage == EquipmentMaintenanceStage.formUploaded ||
                              activeStage == EquipmentMaintenanceStage.issuesReported ||
                              activeStage == EquipmentMaintenanceStage.picVerified,
                        ),

                        const SizedBox(height: 16),

                        // Branching Layout: YES vs NO
                        _buildDecisionBranches(context),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillNode(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildConnectorArrow({String? label, Color? color}) {
    final arrowColor = color ?? const Color(0xFF64748B);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                label,
                style: TextStyle(
                  color: arrowColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Container(width: 2, height: 16, color: arrowColor),
          Icon(Icons.arrow_drop_down_rounded, color: arrowColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildFlowNode({
    required String title,
    required String subtitle,
    bool isActive = false,
    Color? accentColor,
    String? badgeNumber,
    bool highlightLoopTarget = false,
  }) {
    final effectiveColor = accentColor ?? (isActive ? const Color(0xFFF97316) : const Color(0xFF38BDF8));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF1E293B)
            : const Color(0xFF131D33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? effectiveColor
              : (highlightLoopTarget
                  ? const Color(0xFFF97316).withValues(alpha: 0.5)
                  : const Color(0xFF334155)),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (badgeNumber != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: effectiveColor.withValues(alpha: 0.6)),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeNumber,
                style: TextStyle(
                  color: effectiveColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (highlightLoopTarget)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '↺ Loop Re-entry',
                          style: TextStyle(
                            color: Color(0xFFF97316),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'CURRENT',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDecisionNode({
    required String question,
    bool isActive = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF231C12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFFFBBF24) : const Color(0xFF785412),
          width: isActive ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBBF24).withValues(alpha: isActive ? 0.25 : 0.08),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.help_outline_rounded, color: Color(0xFFFBBF24), size: 18),
              const SizedBox(width: 8),
              Text(
                'DECISION GATEWAY',
                style: TextStyle(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Physical post-servicing run test & PIC checklist sign-off',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionBranches(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    final noBranchWidget = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1417),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activeStage == EquipmentMaintenanceStage.issuesReported
              ? const Color(0xFFEF4444)
              : const Color(0xFF4C1D24),
          width: activeStage == EquipmentMaintenanceStage.issuesReported ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEF4444)),
            ),
            child: const Text(
              'NO',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildFlowNode(
            title: 'PIC Reports Outstanding Issues to Maintenance Team',
            subtitle: 'Defect notice logged: Oil leak, sensor fault, vibration, or calibration failure',
            isActive: activeStage == EquipmentMaintenanceStage.issuesReported,
            accentColor: const Color(0xFFEF4444),
          ),
          _buildConnectorArrow(
            label: 'Loop back to Step 11',
            color: const Color(0xFFEF4444),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A1519),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.replay_rounded, color: Color(0xFFEF4444), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maintenance Team re-executes servicing until defects resolved.',
                    style: TextStyle(
                      color: Color(0xFFFCA5A5),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final yesBranchWidget = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2218),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activeStage == EquipmentMaintenanceStage.picVerified ||
                  activeStage == EquipmentMaintenanceStage.cycleUpdated
              ? const Color(0xFF10B981)
              : const Color(0xFF14532D),
          width: activeStage == EquipmentMaintenanceStage.picVerified ||
                  activeStage == EquipmentMaintenanceStage.cycleUpdated
              ? 2
              : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: const Text(
              'YES',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildFlowNode(
            title: 'Equipment PIC Verifies and Confirms Maintenance Completion',
            subtitle: 'Site sign-off recorded with digital timestamp & PIC inspection ID',
            isActive: activeStage == EquipmentMaintenanceStage.picVerified,
            accentColor: const Color(0xFF10B981),
          ),
          _buildConnectorArrow(color: const Color(0xFF10B981)),
          _buildFlowNode(
            title: 'System Updates Maintenance Records and Next Maintenance Date',
            subtitle: 'New operating baseline logged (+250 / +500 hrs or statutory period)',
            isActive: activeStage == EquipmentMaintenanceStage.cycleUpdated,
            accentColor: const Color(0xFF10B981),
          ),
          _buildConnectorArrow(color: const Color(0xFF10B981)),
          _buildFlowNode(
            title: 'System Updates Calendar for Next Maintenance Cycle',
            subtitle: 'Master equipment calendar synchronized & automated reminder timers reset',
            isActive: activeStage == EquipmentMaintenanceStage.cycleUpdated,
            accentColor: const Color(0xFF10B981),
          ),
          _buildConnectorArrow(color: const Color(0xFF10B981)),
          _buildPillNode('FINISH', const Color(0xFF10B981)),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          noBranchWidget,
          const SizedBox(height: 16),
          yesBranchWidget,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: noBranchWidget),
        const SizedBox(width: 16),
        Expanded(flex: 6, child: yesBranchWidget),
      ],
    );
  }
}
