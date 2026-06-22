import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:medixpro/l10n/app_localizations.dart';

import '../../auth/presentation/cubit/auth_cubit.dart';
import '../data/clinic_location_datasource.dart';

/// Shows the clinic location on an OpenStreetMap map.
///
/// * Patient (role != doctor): read-only — fetches and displays the doctor's
///   clinic pin.
/// * Doctor: editable — taps the map to drop/move the pin and saves it to the
///   profile.
class ClinicMapPage extends StatefulWidget {
  final ClinicLocationDataSource dataSource;

  /// Pre-known coordinates (e.g. the doctor's already-saved location).
  final LatLng? initialLocation;

  /// When true the user can tap the map to set the location and save it.
  final bool editable;

  const ClinicMapPage({
    super.key,
    required this.dataSource,
    this.initialLocation,
    this.editable = false,
  });

  @override
  State<ClinicMapPage> createState() => _ClinicMapPageState();
}

class _ClinicMapPageState extends State<ClinicMapPage> {
  // Default centre (Syria — Damascus) used only until a real location is known.
  static const _fallbackCenter = LatLng(33.5138, 36.2765);

  final MapController _mapController = MapController();

  LatLng? _selected;
  String _clinicName = "";
  String _address = "";
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
    _load();
  }

  Future<void> _load() async {
    try {
      final loc = widget.editable
          ? await widget.dataSource.fetchMyLocation()
          : await widget.dataSource.fetchClinicLocation();
      if (!mounted) return;
      setState(() {
        if (loc != null) {
          _selected = LatLng(loc.latitude, loc.longitude);
          _clinicName = loc.clinicName;
          _address = loc.address;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context).noClinicLocation;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      await widget.dataSource
          .saveClinicLocation(_selected!.latitude, _selected!.longitude);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationSaved)),
      );
      Navigator.of(context).pop(_selected);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationSaveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editable ? l10n.setClinicLocation : l10n.clinicLocation),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selected ?? _fallbackCenter,
                    initialZoom: _selected != null ? 15 : 7,
                    onTap: widget.editable
                        ? (_, point) => setState(() => _selected = point)
                        : null,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.medixpro.app",
                    ),
                    if (_selected != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selected!,
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.location_on,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Hint / info banner.
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: _InfoBanner(
                    text: widget.editable
                        ? l10n.tapToSetLocation
                        : (_error ??
                            (_selected == null
                                ? l10n.noClinicLocation
                                : (_clinicName.isNotEmpty
                                    ? _clinicName
                                    : l10n.clinicLocation))),
                    subtitle: !widget.editable && _address.isNotEmpty
                        ? _address
                        : null,
                  ),
                ),
              ],
            ),
      floatingActionButton: widget.editable
          ? FloatingActionButton.extended(
              onPressed: (_selected == null || _saving) ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(l10n.saveLocation),
            )
          : null,
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  final String? subtitle;
  const _InfoBanner({required this.text, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Text(subtitle!, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper that reads the current role from [AuthCubit].
bool currentUserIsDoctor(BuildContext context) {
  final state = context.read<AuthCubit>().state;
  return state is AuthAuthenticated && state.user.isDoctor;
}
