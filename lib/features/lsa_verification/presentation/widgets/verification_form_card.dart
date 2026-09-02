import 'package:flutter/material.dart';
import 'field_label.dart';

class VerificationFormCard extends StatelessWidget {
  final TextEditingController? lsaIdController;
  final TextEditingController? consentCodeController;
  final TextEditingController? predecessorIdController;
  final VoidCallback? onSubmit;

  const VerificationFormCard({
    super.key,
    this.lsaIdController,
    this.consentCodeController,
    this.predecessorIdController,
    this.onSubmit,
  });

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hintText,
    required IconData prefixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF98A2B3),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 20,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFD0D5DD),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFD0D5DD),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFF3157D5), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF172033);
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE4E7EC);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Review the information below before submitting.',
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // LSA ID
          const FieldLabel(label: 'LSA ID', isRequired: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: lsaIdController,
            style: TextStyle(color: textColor),
            decoration: _inputDecoration(
              context,
              hintText: 'Enter LSA ID',
              prefixIcon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: 20),

          // Parent Consent Code
          const FieldLabel(
            label: 'Parent Consent Code',
            isRequired: true,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: consentCodeController,
            style: TextStyle(color: textColor),
            decoration: _inputDecoration(
              context,
              hintText: 'Enter consent code',
              prefixIcon: Icons.key_outlined,
            ),
          ),
          const SizedBox(height: 20),

          // Predecessor ID
          const FieldLabel(
            label: 'Predecessor ID',
            isRequired: true,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: predecessorIdController,
            style: TextStyle(color: textColor),
            decoration: _inputDecoration(
              context,
              hintText: 'Enter predecessor ID',
              prefixIcon: Icons.account_tree_outlined,
            ),
          ),
          const SizedBox(height: 28),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onSubmit ?? () {},
              icon: const Icon(Icons.verified_outlined, size: 20),
              label: const Text(
                'Verify & Submit',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF3157D5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
