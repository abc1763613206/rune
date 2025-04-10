import 'package:fluent_ui/fluent_ui.dart';

import '../../utils/router/navigation.dart';
import '../../widgets/ax_pressure.dart';
import '../../widgets/tile/tile.dart';
import '../../widgets/ax_reveal/ax_reveal.dart';

import 'utils/get_tile_colors.dart';

class LinkTile extends StatelessWidget {
  final String title;
  final String? path;
  final IconData icon;
  final void Function()? onPressed;

  const LinkTile({
    super.key,
    required this.title,
    this.path,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    final List<Color> colors = getTileColors(theme);

    return AxPressure(
      child: AxReveal0(
        child: Tile(
          onPressed: onPressed ??
              () {
                if (path != null) {
                  $push(path!);
                }
              },
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                color: colors[path.hashCode % colors.length],
                child: Center(
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: theme.typography.body?.apply(color: theme.activeColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
