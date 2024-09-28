import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../providers/volume.dart';

class VolumeButton extends StatefulWidget {
  const VolumeButton({super.key});

  @override
  VolumeButtonState createState() => VolumeButtonState();
}

class VolumeButtonState extends State<VolumeButton> {
  final FlyoutController _flyoutController = FlyoutController();

  void onScroll(
      VolumeProvider volumeProvider, PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      final currentVolume = volumeProvider.volume;
      final delta = pointerSignal.scrollDelta.dy * -0.0005;
      final newVolume = (currentVolume + delta).clamp(0.0, 1.0);
      volumeProvider.updateVolume(newVolume);
    }
  }

  @override
  Widget build(BuildContext context) {
    final volumeProvider = Provider.of<VolumeProvider>(context);

    return Listener(
      onPointerSignal: (pointerSignal) {
        onScroll(volumeProvider, pointerSignal);
      },
      child: FlyoutTarget(
        controller: _flyoutController,
        child: IconButton(
          icon: Icon(
            volumeProvider.volume > 0.3
                ? Symbols.volume_up
                : volumeProvider.volume > 0
                    ? Symbols.volume_down
                    : Symbols.volume_mute,
          ),
          onPressed: () {
            _flyoutController.showFlyout(
              barrierColor: Colors.transparent,
              builder: (context) {
                return FlyoutContent(
                  child: VolumeController(
                    onScroll: onScroll,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _flyoutController.dispose();
  }
}

class VolumeController extends StatelessWidget {
  final void Function(
      VolumeProvider volumeProvider, PointerSignalEvent pointerSignal) onScroll;

  const VolumeController({
    super.key,
    required this.onScroll,
  });

  @override
  Widget build(BuildContext context) {
    final volumeProvider = Provider.of<VolumeProvider>(context);

    return Listener(
      onPointerSignal: (pointerSignal) {
        onScroll(volumeProvider, pointerSignal);
      },
      child: SizedBox(
        height: 150,
        width: 40,
        child: Slider(
          vertical: true,
          value: volumeProvider.volume * 100,
          onChanged: (value) {
            volumeProvider.updateVolume(value / 100);
          },
          label: '${(volumeProvider.volume * 100).toInt()}%',
        ),
      ),
    );
  }
}