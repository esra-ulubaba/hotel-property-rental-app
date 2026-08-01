import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final int maxLines;


  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
     this.isPassword= false,
     this.maxLines=1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  bool _obscure= true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     _obscure= widget.isPassword;

  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscure:false,
        maxLines: widget.maxLines,
        style: const TextStyle(fontSize: 18, color: Colors.white),
        validator: (text) =>
        text==null || text.isEmpty ? "Lütfen girin ${widget.label} " : null,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: Colors.white),
          labelText: widget.label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(icon: Icon(
            _obscure ? Icons.visibility_off: Icons.visibility,
            color: Colors.white70,
          ),
            onPressed: () {
                setState(() {
                  _obscure = !_obscure;
                });
            },
          )
              :null,
        ),
        
        
      ),
    );
  }
}
