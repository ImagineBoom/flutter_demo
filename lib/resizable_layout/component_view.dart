import 'package:flutter/material.dart';


class Sliders extends StatefulWidget {
  const Sliders({super.key});

  @override
  State<Sliders> createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  double sliderValue1 = 100.0;

  @override
  Widget build(BuildContext context) {
    return Slider(
      max: 200,
      divisions: 10,
      value: sliderValue1,
      label: sliderValue1.round().toString(),
      onChanged: (value) {
        setState(() {
          sliderValue1 = value;
        });
      },
    );
  }
}