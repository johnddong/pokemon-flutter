import 'package:flutter/material.dart';
import 'package:pokemon/models/pokemon_list_item.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.catalog, required this.onSearch});

  final List<PokemonListItem> catalog;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<PokemonListItem>(
      displayStringForOption: (option) => option.displayName,
      optionsMaxHeight: 400,
      optionsBuilder: (value) {
        final q = value.text.trim().toLowerCase();
        if (q.isEmpty) return const Iterable.empty();
        return catalog.where((option) => option.name.contains(q)).take(20);
      },
      onSelected: (option) => onSearch(option.name),
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    leading: Image.network(
                      option.spriteUrl,
                      width: 40,
                      height: 40,
                    ),
                    title: Text(option.displayName),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return TextField(
              autocorrect: false,
              contextMenuBuilder: (context, editableTextState) {
                return const SizedBox.shrink();
              },
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by name or dex number',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: controller.clear,
                      ),
              ),
              onSubmitted: (value) {
                final q = value.trim().toLowerCase();
                final hasOptions =
                    q.isNotEmpty &&
                    catalog
                        .where((option) => option.name.contains(q))
                        .take(20)
                        .isNotEmpty;
                if (hasOptions) {
                  onFieldSubmitted(); // highlighted / first match
                } else {
                  onSearch(value); // typed text, even if not in the dropdown
                }
              },
            );
          },
        );
      },
    );
  }
}
