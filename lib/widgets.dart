import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'data.dart';
import 'theme.dart';

/// Navy header with "<" back arrow + centered title.
PreferredSizeWidget navyAppBar(
  BuildContext context,
  String title, {
  String fallback = '/home',
  VoidCallback? onTitleLongPress,
}) {
  return AppBar(
    backgroundColor: C.navy,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.chevron_left, size: 28),
      onPressed: () => context.canPop() ? context.pop() : context.go(fallback),
    ),
    title: GestureDetector(
      onLongPress: onTitleLongPress,
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    ),
  );
}

/// The trophy logo. Placeholder icon for now.
/// TIP: export your logo from Figma as PNG, put it in assets/, then swap
/// the Icon below with Image.asset('assets/logo.png', height: size).
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 80});
  final double size;

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.emoji_events, size: size, color: C.orange);
}

class Shield extends StatelessWidget {
  const Shield(this.color, {super.key, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.shield, size: size, color: color);
}

IconData sportIcon(String sport) {
  switch (sport) {
    case 'Volleyball':
      return Icons.sports_volleyball;
    case 'Football':
      return Icons.sports_soccer;
    default:
      return Icons.sports_basketball;
  }
}

Color sportColor(String sport) {
  switch (sport) {
    case 'Volleyball':
      return const Color(0xFF9AA5B8);
    case 'Football':
      return C.navy;
    default:
      return C.orange;
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: C.orange,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          child: Text(label),
        ),
      );
}

class SocialButton extends StatelessWidget {
  const SocialButton(this.label, this.icon, {super.key, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18, color: C.navy),
          label: Text(label,
              style: const TextStyle(
                  color: C.navy, fontSize: 13, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: C.navy),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
}

/// Text field with icon. password:true adds the show/hide eye.
class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.hint,
    required this.icon,
    this.password = false,
    this.light = false,
    this.keyboardType,
  });
  final String hint;
  final IconData icon;
  final bool password;
  final bool light; // light = soft border (login), else navy border (register)
  final TextInputType? keyboardType;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final side = widget.light ? C.border : C.navy;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c),
        );
    return TextField(
      obscureText: widget.password && _hidden,
      keyboardType: widget.keyboardType,
      style: const TextStyle(color: C.navy, fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: C.grey, fontSize: 14),
        prefixIcon: Icon(widget.icon, color: C.grey, size: 20),
        suffixIcon: widget.password
            ? IconButton(
                icon: Icon(
                    _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: C.navy),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: border(side),
        focusedBorder: border(C.orange),
      ),
    );
  }
}

/// Orange pill tabs (Overall / Men's / Women's, Today / Tomorrow, etc.)
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.navy),
      ),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selected ? C.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: i == selected ? Colors.white : C.navy,
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

/// White rounded card used everywhere.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor = C.navy,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.only(bottom: 12),
  });
  final Widget child;
  final VoidCallback? onTap;
  final Color borderColor;
  final EdgeInsets padding, margin;

  @override
  Widget build(BuildContext context) => Padding(
        padding: margin,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: child,
            ),
          ),
        ),
      );
}

/// A game card for the Schedule screen.
class GameCard extends StatelessWidget {
  const GameCard(this.g, {super.key});
  final Game g;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(sportIcon(g.sport), size: 14, color: sportColor(g.sport)),
          const SizedBox(width: 6),
          Text(g.sport,
              style: const TextStyle(
                  color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(g.time,
              style: const TextStyle(
                  color: C.orange, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Shield(teamByName(g.home).color),
          const Text('VS', style: TextStyle(color: C.grey, fontSize: 10)),
          Shield(teamByName(g.away).color),
        ]),
        const SizedBox(height: 8),
        Text('${g.home} vs ${g.away}',
            style: const TextStyle(
                color: C.navy, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(g.venue, style: const TextStyle(color: C.grey, fontSize: 10)),
      ]),
    );
  }
}
