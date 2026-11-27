import 'package:pokemon/extensions/string_capitalized.dart';

class AbilityInfo {
  AbilityInfo({required this.isHidden, required this.name});

  final bool isHidden;
  final String name;

  String get displayAbility =>
      name.split('-').map((part) => part.capitalized).join(' ');

  factory AbilityInfo.fromJson(Map<String, dynamic> json) {
    final ability = json['ability'] as Map<String, dynamic>;
    return AbilityInfo(
      isHidden: json['is_hidden'] as bool,
      name: ability['name'] as String,
    );
  }
}
