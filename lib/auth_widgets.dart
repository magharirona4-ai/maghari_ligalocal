import 'package:flutter/material.dart';
import 'theme.dart';

/// Same look as AppField, but you can read what the user typed.
class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.password = false,
    this.light = false,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool password;
  final bool light;
  final TextInputType? keyboardType;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final side = widget.light ? C.border : C.navy;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c),
        );
    return TextField(
      controller: widget.controller,
      obscureText: widget.password && _hidden,
      keyboardType: widget.keyboardType,
      autocorrect: false,
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
