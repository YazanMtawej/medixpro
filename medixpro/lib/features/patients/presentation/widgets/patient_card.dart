import 'package:flutter/material.dart';
import '../../domain/entities/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PatientCard(
    this.patient, {
    super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 400;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),

          child: Material(
            color: Colors.transparent,

            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,

              child: Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: cs.surface,
                  border: Border.all(color: cs.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),

                child: isSmall
                    ? _buildColumnLayout(context, cs)
                    : _buildRowLayout(context, cs),
              ),
            ),
          ),
        );
      },
    );
  }

  /// ================= ROW LAYOUT (tablet / desktop) =================
  Widget _buildRowLayout(BuildContext context, ColorScheme cs) {
    final theme = Theme.of(context);

    return Row(
      children: [

        /// Avatar
        _avatar(cs),

        const SizedBox(width: 12),

        /// Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Age: ${patient.age} • ${patient.phone}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 6),

              _genderBadge(cs),
            ],
          ),
        ),

        _menu(context),
      ],
    );
  }

  /// ================= COLUMN LAYOUT (mobile) =================
  Widget _buildColumnLayout(BuildContext context, ColorScheme cs) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            _avatar(cs),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                patient.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),

            _menu(context),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          "Age: ${patient.age} • ${patient.phone}",
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 8),

        _genderBadge(cs),
      ],
    );
  }

  /// ================= AVATAR =================
  Widget _avatar(ColorScheme cs) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            cs.primary,
            cs.primaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Text(
          patient.name.isNotEmpty ? patient.name[0] : "?",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// ================= GENDER BADGE =================
  Widget _genderBadge(ColorScheme cs) {
    final isMale = patient.gender == "Male";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMale
            ? cs.primary.withOpacity(0.12)
            : cs.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        patient.gender,
        style: TextStyle(
          fontSize: 12,
          color: isMale ? cs.primary : cs.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ================= MENU =================
  Widget _menu(BuildContext context) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (v) {
        if (v == "edit") onEdit?.call();
        if (v == "delete") onDelete?.call();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: "edit", child: Text("Edit")),
        PopupMenuItem(value: "delete", child: Text("Delete")),
      ],
    );
  }
}