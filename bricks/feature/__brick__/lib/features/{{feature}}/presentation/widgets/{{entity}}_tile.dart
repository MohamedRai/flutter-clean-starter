import 'package:flutter/material.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';

/// One [{{entity.pascalCase()}}] in a list.
class {{entity.pascalCase()}}Tile extends StatelessWidget {
  /// Creates the tile.
  const {{entity.pascalCase()}}Tile({required this.{{entity.camelCase()}}, this.onTap, super.key});

  /// The item to show.
  final {{entity.pascalCase()}} {{entity.camelCase()}};

  /// Called when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      ListTile(title: Text({{entity.camelCase()}}.name), onTap: onTap);
}
