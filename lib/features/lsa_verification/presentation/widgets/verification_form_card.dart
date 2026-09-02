import 'package:habot_lsa_verification/export.dart';

class VerificationFormCard extends StatefulWidget {
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

  @override
  State<VerificationFormCard> createState() => _VerificationFormCardState();
}

class _VerificationFormCardState extends State<VerificationFormCard> {
  late final TextEditingController _lsaIdController;
  late final TextEditingController _consentCodeController;
  late final TextEditingController _predecessorIdController;

  final FocusNode _primaryFocusNode = FocusNode();
  Timer? _frictionTimer;

  @override
  void initState() {
    super.initState();
    _lsaIdController = widget.lsaIdController ?? TextEditingController();
    _consentCodeController =
        widget.consentCodeController ?? TextEditingController();
    _predecessorIdController =
        widget.predecessorIdController ?? TextEditingController();

    _primaryFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _frictionTimer?.cancel();
    _primaryFocusNode.removeListener(_onFocusChange);
    _primaryFocusNode.dispose();

    if (widget.lsaIdController == null) {
      _lsaIdController.dispose();
    }
    if (widget.consentCodeController == null) {
      _consentCodeController.dispose();
    }
    if (widget.predecessorIdController == null) {
      _predecessorIdController.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_primaryFocusNode.hasFocus) {
      _startFrictionTimer();
    } else {
      _frictionTimer?.cancel();
    }
  }

  void _onUserInteraction() {
    _startFrictionTimer();
  }

  void _startFrictionTimer() {
    _frictionTimer?.cancel();
    _frictionTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _primaryFocusNode.hasFocus) {
        context.read<LsaVerificationBloc>().add(
              FrictionEventDetected(
                fieldName: 'lsa_id',
                stallDurationSeconds: 5,
              ),
            );
      }
    });
  }

  void _handleSubmit() {
    _frictionTimer?.cancel();

    if (widget.onSubmit != null) {
      widget.onSubmit!();
      return;
    }

    context.read<LsaVerificationBloc>().add(
          VerifyAndSubmitPressed(
            lsaId: _lsaIdController.text,
            parentConsentCode: _consentCodeController.text,
            predecessorId: _predecessorIdController.text,
          ),
        );
  }

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

    return BlocBuilder<LsaVerificationBloc, LsaVerificationState>(
      builder: (context, state) {
        final bool isLoading = state is LsaVerificationInProgress;

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
              const FieldLabel(label: 'LSA ID', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lsaIdController,
                focusNode: _primaryFocusNode,
                onChanged: (_) => _onUserInteraction(),
                enabled: !isLoading,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration(
                  context,
                  hintText: 'Enter LSA ID',
                  prefixIcon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(height: 20),
              const FieldLabel(
                label: 'Parent Consent Code',
                isRequired: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _consentCodeController,
                enabled: !isLoading,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration(
                  context,
                  hintText: 'Enter consent code',
                  prefixIcon: Icons.key_outlined,
                ),
              ),
              const SizedBox(height: 20),
              const FieldLabel(
                label: 'Predecessor ID',
                isRequired: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _predecessorIdController,
                enabled: !isLoading,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration(
                  context,
                  hintText: 'Enter predecessor ID',
                  prefixIcon: Icons.account_tree_outlined,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _handleSubmit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.verified_outlined, size: 20),
                  label: Text(
                    isLoading ? 'Verifying Lineage...' : 'Verify & Submit',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF3157D5),
                    disabledBackgroundColor:
                        const Color(0xFF3157D5).withValues(alpha: 0.6),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
