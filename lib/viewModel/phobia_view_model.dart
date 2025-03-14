import 'package:flutter/material.dart';
import '../utils/components/phobia_list.dart';

class PhobiaViewModel extends ChangeNotifier {
  final List<Phobia> _phobias = [
    Phobia(
      name: "Heights",
      scientificName: "Acrophobia",
      iconPath: "assets/icons/height.webp",
      routeName: "height",
    ),
    Phobia(
      name: "Flying",
      scientificName: "Aerophobia",
      iconPath: "assets/icons/flying.webp",
      routeName: "flying",
    ),
    Phobia(
      name: "Spiders",
      scientificName: "Arachnophobia",
      iconPath: "assets/icons/spider.webp",
      routeName: "spider",
    ),
  ];

  List<Phobia> get phobias => _phobias;
}
