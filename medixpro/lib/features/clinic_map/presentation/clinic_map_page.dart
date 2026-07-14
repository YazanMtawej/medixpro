import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/presentation/cubit/auth_cubit.dart';
import '../data/clinic_location_datasource.dart';

/// Shows the clinic location on an OpenStreetMap map.
///
/// * Patient (role != doctor): read-only — displays the doctor's clinic pin
///   and offers a "Get directions" button that opens the native maps app.
/// * Doctor: editable — taps the map to drop/move the pin, edits the clinic
///   name and address (auto-suggested from the picked point), and saves it to
///   the profile.
class ClinicMapPage extends StatefulWidget {
  final ClinicLocationDataSource dataSource;

  /// Pre-known coordinates (e.g. the doctor's already-saved location).
  final LatLng? initialLocation;

  /// When true the user can tap the map to set the location and save it.
  final bool editable;

  /// A ready-to-show clinic location. When provided (e.g. the accepting
  /// doctor's clinic on a patient's accepted request) the page displays it
  /// directly instead of fetching from the backend.
  final ClinicLocation? location;

  const ClinicMapPage({
    super.key,
    required this.dataSource,
    this.initialLocation,
    this.editable = false,
    this.location,
  });

  @override
  State<ClinicMapPage> createState() => _ClinicMapPageState();
}

class _ClinicMapPageState extends State<ClinicMapPage> {
  // Default centre (Syria — Damascus) used only until a real location is known.
  static const _fallbackCenter = LatLng(33.5138, 36.2765);

  final MapController _mapController = MapController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  LatLng? _selected;
  String _clinicName = "";
  String _address = "";
  bool _loading = true;
  bool _saving = false;
  bool _geocoding = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // A location was handed in directly — no need to hit the network.
    if (widget.location != null) {
      final loc = widget.location!;
      setState(() {
        _selected = LatLng(loc.latitude, loc.longitude);
        _clinicName = loc.clinicName;
        _address = loc.address;
        _loading = false;
      });
      return;
    }

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
          _nameCtrl.text = loc.clinicName;
          _addressCtrl.text = loc.address;
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

  /// Doctor picked a new point → remember it and try to auto-fill the address.
  void _onMapTap(LatLng point) {
    setState(() => _selected = point);
    _autofillAddress(point);
  }

  Future<void> _autofillAddress(LatLng point) async {
    setState(() => _geocoding = true);
    final address =
        await widget.dataSource.reverseGeocode(point.latitude, point.longitude);
    if (!mounted) return;
    setState(() {
      _geocoding = false;
      // Overwrite only when we actually resolved something — never wipe a
      // manually typed address on a failed lookup.
      if (address != null) _addressCtrl.text = address;
    });
  }

  Future<void> _save() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      await widget.dataSource.saveClinicLocation(
        _selected!.latitude,
        _selected!.longitude,
        clinicName: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );
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

  /// Patient: open the picked point in the device's maps app for turn-by-turn
  /// directions. Falls back to a Google Maps web URL when no maps app handles
  /// the `geo:` scheme.
  Future<void> _openDirections() async {
    if (_selected == null) return;
    final lat = _selected!.latitude;
    final lng = _selected!.longitude;
    final geoUri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
    final webUri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).couldNotOpenMaps)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canGetDirections = !widget.editable && _selected != null;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.editable ? l10n.setClinicLocation : l10n.clinicLocation),
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
                    onTap: widget.editable ? (_, point) => _onMapTap(point) : null,
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

                // Doctor: editable clinic name + address panel.
                if (widget.editable && _selected != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _EditPanel(
                      nameCtrl: _nameCtrl,
                      addressCtrl: _addressCtrl,
                      geocoding: _geocoding,
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
          : (canGetDirections
              ? FloatingActionButton.extended(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions),
                  label: Text(l10n.getDirections),
                )
              : null),
    );
  }
}

/// Doctor-only bottom panel to edit the clinic name and address.
class _EditPanel extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final bool geocoding;

  const _EditPanel({
    required this.nameCtrl,
    required this.addressCtrl,
    required this.geocoding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.clinicName,
                prefixIcon: const Icon(Icons.local_hospital_outlined, size: 20),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressCtrl,
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                labelText: l10n.address,
                prefixIcon: const Icon(Icons.place_outlined, size: 20),
                suffixIcon: geocoding
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
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
