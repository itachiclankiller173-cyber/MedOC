import 'package:flutter/material.dart';

import '../services/risk_assessment_service.dart';

class RiskCard extends StatelessWidget {
  final RiskAssessmentResult result;

  const RiskCard({super.key, required this.result});

  Color get riskColor {
    switch (result.overallRisk) {
      case "HIGH":
        return Colors.red;
      case "MEDIUM":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData get riskIcon {
    switch (result.overallRisk) {
      case "HIGH":
        return Icons.warning_rounded;
      case "MEDIUM":
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String get riskMessage {
    switch (result.overallRisk) {
      case "HIGH":
        return "Several readings need attention.";
      case "MEDIUM":
        return "Some readings should be monitored.";
      default:
        return "No major screening concerns detected.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: riskColor.withValues(alpha: 0.12),
                  child: Icon(riskIcon, color: riskColor, size: 32),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Risk Assessment",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        riskMessage,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // RISK LEVEL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(riskIcon, color: riskColor, size: 30),

                  const SizedBox(width: 12),

                  const Text(
                    "Overall Risk",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const Spacer(),

                  Text(
                    result.overallRisk,
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // SCORE
            Row(
              children: [
                const Text(
                  "Risk Score",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),

                const Spacer(),

                Text(
                  "${result.riskScore}",
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: (result.riskScore / 10).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              color: riskColor,
              backgroundColor: Colors.grey.shade200,
            ),

            // WARNINGS
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 25),

              const Text(
                "⚠ Warnings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...result.warnings.map(
                (warning) => _InfoRow(
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                  text: warning,
                ),
              ),
            ],

            // NORMAL CHECKS
            if (result.normalChecks.isNotEmpty) ...[
              const SizedBox(height: 20),

              const Text(
                "✓ Normal Checks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...result.normalChecks.map(
                (check) => _InfoRow(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  text: check,
                ),
              ),
            ],

            // RECOMMENDATIONS
            if (result.recommendations.isNotEmpty) ...[
              const SizedBox(height: 20),

              const Text(
                "💡 Recommendations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...result.recommendations.map(
                (recommendation) => _InfoRow(
                  icon: Icons.lightbulb_outline,
                  color: Colors.teal,
                  text: recommendation,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
