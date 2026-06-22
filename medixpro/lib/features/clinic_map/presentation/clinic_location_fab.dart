import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/core/network/api_client.dart';
import 'package:medixpro/l10n/app_localizations.dart';

import '../../auth/presentation/cubit/auth_cubit.dart';
import '../data/clinic_location_datasource.dart';
import 'clinic_map_page.dart';

/// Floating action button that opens the clinic map.
///
/// * Doctor → opens the editable map to set/move the clinic pin.
/// * Patient → opens the read-only map showing the doctor's clinic.
class ClinicLocationFab extends StatelessWidget {
  const ClinicLocationFab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;
    final isDoctor =
        authState is AuthAuthenticated && authState.user.isDoctor;

    return FloatingActionButton(
      heroTag: "clinic_location_fab",
      tooltip: isDoctor ? l10n.setClinicLocation : l10n.viewClinicLocation,
      onPressed: () {
        final dataSource = ClinicLocationDataSource(context.read<ApiClient>());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClinicMapPage(
              dataSource: dataSource,
              editable: isDoctor,
            ),
          ),
        );
      },
      child: const Icon(Icons.location_on),
    );
  }
}
