import 'package:flutter/material.dart';

/// Modal dialog rendering the 3-track Subcontractor Performance Monitoring Flowchart
class SubcontractorFlowchartModal extends StatelessWidget {
  const SubcontractorFlowchartModal({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 880),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.groups_2_rounded,
                      color: Color(0xFFFB7185),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MOD-05 Subcontractor Performance Monitoring SOP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '3-Track Compliance & Performance Scoring Architecture',
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildPillNode('START', const Color(0xFF10B981)),
                    _buildConnector(),
                    _buildStepNode(
                      'Register Subcontractor & Contract Requirements',
                      'Scope of work, completion date, required manpower & machinery specs',
                      Icons.how_to_reg_rounded,
                      const Color(0xFF0284C7),
                    ),
                    _buildConnector(),
                    _buildStepNode(
                      'Synchronize Project Timeline with Calendar',
                      'Milestones, intermediate deadlines, and automated alert triggers synced',
                      Icons.calendar_month_rounded,
                      const Color(0xFF6366F1),
                    ),
                    _buildConnector(),
                    _buildStepNode(
                      'Monitor Subcontractor Performance Across 3 Simultaneous Tracks',
                      'Continuous tracking of Timeline, Safety, and Manpower/Machinery',
                      Icons.speed_rounded,
                      const Color(0xFFF43F5E),
                    ),
                    _buildConnector(),

                    // 3 Tracks Layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 720;
                        if (isNarrow) {
                          return Column(
                            children: [
                              _buildTrackCard(
                                title: '1. TIMELINE COMPLIANCE',
                                color: const Color(0xFFF59E0B),
                                icon: Icons.schedule_rounded,
                                items: [
                                  '1st Memo: 4 Months Before Completion',
                                  '2nd Memo: 2 Months Before (Submit Delay Reasons & EOT)',
                                  '3rd Memo: 1 Month Before Completion',
                                  'CRITICAL: Highlight Subcontractor in RED',
                                  'Main Contractor Intervenes to Complete Works',
                                  'Recover Additional Costs According to Contract',
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTrackCard(
                                title: '2. SAFETY COMPLIANCE',
                                color: const Color(0xFFEF4444),
                                icon: Icons.health_and_safety_rounded,
                                items: [
                                  'Site Team Monitors Manpower Safety',
                                  'Safety Requirement Violated? (Yes/No)',
                                  'If Yes: Issue Safety Memo & RED CARD',
                                  'Record Violation in System',
                                  'Manpower Permanently Removed from Site',
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTrackCard(
                                title: '3. MANPOWER & MACHINERY',
                                color: const Color(0xFF0D9488),
                                icon: Icons.precision_manufacturing_rounded,
                                items: [
                                  'Verify Actual vs Contractual Quotas',
                                  'Contractual Requirements Fulfilled? (Yes/No)',
                                  'If No: Issue Non-Compliance Memo',
                                  'Record & Count Non-Compliance in System',
                                  'Monitor Corrective Action Plan',
                                ],
                              ),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTrackCard(
                                title: '1. TIMELINE TRACK',
                                color: const Color(0xFFF59E0B),
                                icon: Icons.schedule_rounded,
                                items: [
                                  '1st Memo: 4M Prior',
                                  '2nd Memo: 2M Prior (EOT)',
                                  '3rd Memo: 1M Prior',
                                  'RED Highlight Alert',
                                  'Contractor Intervention',
                                  'Cost Recovery Clause',
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTrackCard(
                                title: '2. SAFETY TRACK',
                                color: const Color(0xFFEF4444),
                                icon: Icons.health_and_safety_rounded,
                                items: [
                                  'Monitor Manpower',
                                  'Violation Check',
                                  'Issue Safety Memo',
                                  'Issue RED CARD',
                                  'Worker Site Removal',
                                  'SPI Score Deduction',
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTrackCard(
                                title: '3. RESOURCES TRACK',
                                color: const Color(0xFF0D9488),
                                icon: Icons.precision_manufacturing_rounded,
                                items: [
                                  'Verify Headcount',
                                  'Verify Equipment',
                                  'Non-Compliance Check',
                                  'Issue Deficiency Memo',
                                  'Track Rectification',
                                  'Audit Compliance',
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    _buildConnector(),
                    _buildStepNode(
                      'System Consolidates All Performance Records',
                      'Automated aggregation of timeline delays, safety infractions, and resource quotas',
                      Icons.integration_instructions_rounded,
                      const Color(0xFF6366F1),
                    ),
                    _buildConnector(),
                    _buildStepNode(
                      'Calculate Subcontractor Performance Score (SPI) & Grade Rating',
                      'Grade A (85-100), Grade B (70-84), Grade C (50-69), or RED ALERT (<50)',
                      Icons.assessment_rounded,
                      const Color(0xFF10B981),
                    ),
                    _buildConnector(),
                    _buildStepNode(
                      'Management Reviews Performance and Takes Contractual Action',
                      'Vendor performance review, contract award eligibility, or intervention recovery',
                      Icons.gavel_rounded,
                      const Color(0xFF0284C7),
                    ),
                    _buildConnector(),
                    _buildPillNode('FINISH (RATING FINALIZED)', const Color(0xFF10B981)),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 2,
      height: 20,
      color: const Color(0xFF475569),
    );
  }

  Widget _buildStepNode(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 620),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard({
    required String title,
    required Color color,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontSize: 13)),
                  Expanded(
                    child: Text(
                      i,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFCBD5E1),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

