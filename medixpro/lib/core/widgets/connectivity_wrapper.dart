import 'package:flutter/material.dart';
import '../connectivity/connectivity_service.dart';
import '../theme/app_colors.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset>   _slide;
  bool _showBanner = false;
  bool _isOnline   = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    ConnectivityService.instance.onStatusChange.listen(_onStatusChange);
  }

  void _onStatusChange(bool online) {
    setState(() {
      _isOnline   = online;
      _showBanner = true;
    });
    _ctrl.forward();

    if (online) {
      // بعد 2 ثانية أخفِ بانر "Back Online"
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _ctrl.reverse().then((_) {
            if (mounted) setState(() => _showBanner = false);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            top:   0,
            left:  0,
            right: 0,
            child: SlideTransition(
              position: _slide,
              child: Material(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 16),
                  color: _isOnline
                      ? AppColors.success
                      : const Color(0xFF323232),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Icon(
                          _isOnline ? Icons.wifi : Icons.wifi_off,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isOnline
                              ? "Back online"
                              : "No internet connection",
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}