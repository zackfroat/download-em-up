import 'package:flutter/material.dart';

/// Modal dialog visually rendering the official MOD-01 Safety Training & Compliance Flowchart
class SafetyFlowchartModal extends StatelessWidget {
  const SafetyFlowchartModal({super.key});

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
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 860),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark blueprint slate
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
                      color: const Color(0xFF0284C7).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MOD-01 Safety Training & Compliance SOP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Standard Operational Workflow Diagram',
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

            // Flowchart Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildPillNode('START', const Color(0xFF10B981)),
                    _buildConnector(),
                    _buildStepNode(
                      'Safety Team Conducts Site Safety Induction',
                      'Briefing, videos, PPE check & site requirements',
                      Icons.play_lesson_rounded,
                      const Color(0xFF0284C7),
                    ),
                    _buildConnector(),
                    _buildStepNode(
                      'Upload Induction Records into System',
                      'Worker registered & safety passport issued',
                      Icons.cloud_upload_rounded,
                      const Color(0xFF0284C7),
                    ),
                    _buildConnector(),
                    _buildStepNode(
                      'Schedule Monthly Safety Training in Project Calendar',
                      'Automated system notifications sent to project team & subcontractors',
                      Icons.calendar_month_rounded,
                      const Color(0xFF6366F1),
                    ),
                    _buildConnector(),
                    _buildStepNode(
                      'Conduct Monthly Safety Training & Awareness',
                      'Record attendance sheets & upload signed training documents',
                      Icons.co_present_rounded,
                      const Color(0xFF0D9488),
                    ),
                    _buildConnector(),
                    _buildStepNode(
                      'Subcontractor Manpower Performs Site Activities',
                      'Continuous site inspection & safety surveillance',
                      Icons.engineering_rounded,
                      const Color(0xFF059669),
                    ),
                    _buildConnector(),

                    // Decision: Safety Violation Identified?
                    _buildDecisionNode(
                      'Safety Violation Identified?',
                      'Gate 1: On-site hazard surveillance',
                    ),
                    _buildConnector(),

                    // Branching representation
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 500;
                        if (isNarrow) {
                          return Column(
                            children: [
                              _buildBranchCard(
                                label: 'YES: VIOLATION DETECTED',
                                color: const Color(0xFFEF4444),
                                icon: Icons.report_problem_rounded,
                                steps: [
                                  'Issue NCR to Subcontractor',
                                  'Record NCR & Violation in System',
                                  'Subcontractor Implements Corrective Action',
                                  'Verify Corrective Action (Verified?)',
                                  'Repeated 3 Times? -> ISSUE RED CARD & REMOVE WORKER',
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildBranchCard(
                                label: 'NO: SAFE OPERATION',
                                color: const Color(0xFF10B981),
                                icon: Icons.verified_user_rounded,
                                steps: [
                                  'Continue Site Safety Monitoring',
                                  'Maintain Safe Man-Hours Record',
                                  'Review Training Records & Inspection Forms',
                                ],
                              ),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildBranchCard(
                                label: 'YES: VIOLATION DETECTED',
                                color: const Color(0xFFEF4444),
                                icon: Icons.report_problem_rounded,
                                steps: [
                                  'Issue NCR to Subcontractor',
                                  'Record NCR in System',
                                  'Subcontractor Implements Action',
                                  'Verify Corrective Action',
                                  'Repeated 3x -> RED CARD & REMOVAL',
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildBranchCard(
                                label: 'NO: SAFE OPERATION',
                                color: const Color(0xFF10B981),
                                icon: Icons.verified_user_rounded,
                                steps: [
                                  'Continue Safety Monitoring',
                                  'Log Clean Inspection Form',
                                  'Maintain Zero-Harm Record',
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    _buildConnector(),
                    _buildStepNode(
                      'Monthly Safety Document & Inspection Audit',
                      'Review compliance, verify corrective actions & update Subcontractor SPI Score',
                      Icons.fact_check_rounded,
                      const Color(0xFF0284C7),
                    ),
                    _buildConnector(),
                    _buildPillNode('FINISH (AUDITED & COMPLIANT)', const Color(0xFF10B981)),
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
      constraints: const BoxConstraints(maxWidth: 580),
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

  Widget _buildDecisionNode(String title, String subtitle) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF292524),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD97706), width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFBBF24),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFD6D3D1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard({
    required String label,
    required Color color,
    required IconData icon,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                  label,
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
          const SizedBox(height: 8),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color)),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFCBD5E1),
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
