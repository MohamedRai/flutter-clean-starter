import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{package}}/core/widgets/async_builder.dart';
import 'package:{{package}}/core/widgets/empty_state.dart';
import 'package:{{package}}/features/{{feature}}/domain/entities/{{entity}}.dart';
import 'package:{{package}}/features/{{feature}}/presentation/cubit/{{entity}}_list_cubit.dart';
import 'package:{{package}}/features/{{feature}}/presentation/widgets/{{entity}}_tile.dart';

/// Lists [{{entity.pascalCase()}}]s.
///
/// Expects a [{{entity.pascalCase()}}ListCubit] above it, provided by the route.
class {{feature.pascalCase()}}Page extends StatelessWidget {
  /// Creates the page. Pass a localized [title] from the route.
  const {{feature.pascalCase()}}Page({required this.title, super.key});

  /// App-bar title.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AsyncBuilder<{{entity.pascalCase()}}ListCubit, List<{{entity.pascalCase()}}>>(
        onRetry: () => context.read<{{entity.pascalCase()}}ListCubit>().retry(),
        successBuilder: (context, items) => items.isEmpty
            ? const EmptyState()
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    {{entity.pascalCase()}}Tile({{entity.camelCase()}}: items[index]),
              ),
      ),
    );
  }
}
