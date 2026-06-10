import 'package:flutter/material.dart';
import 'package:kover/widgets/settings/option_container.dart';

class ChoiceOption<T> extends StatelessWidget {
  final String title;
  final String? description;
  final T value;
  final List<ChoiceOptionEntry<T>> options; // Custom model for labels/icons
  final IconData? icon;
  final void Function(T)? onChanged;

  const ChoiceOption({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    this.description,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OptionContainer(
      title: title,
      description: description,
      icon: icon,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 420) {
            return DropdownButtonFormField<T>(
              initialValue: value,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: options
                  .map(
                    (option) => DropdownMenuItem<T>(
                      value: option.value,
                      child: Row(
                        mainAxisSize: .min,
                        spacing: 8.0,
                        children: [
                          if (option.icon != null) Icon(option.icon, size: 18),
                          Flexible(child: Text(option.label)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null && newValue != value) {
                  onChanged?.call(newValue);
                }
              },
            );
          }

          return SingleChildScrollView(
            scrollDirection: .horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: SegmentedButton(
                segments: options
                    .map(
                      (option) => ButtonSegment<T>(
                        value: option.value,
                        label: Text(
                          option.label,
                        ),
                        icon: option.icon != null ? Icon(option.icon) : null,
                      ),
                    )
                    .toList(),
                selected: {value},
                onSelectionChanged: (Set<T> newSelection) {
                  if (newSelection.first != value) {
                    onChanged?.call(newSelection.first);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChoiceOptionEntry<T> {
  final T value;
  final String label;
  final IconData? icon;

  const ChoiceOptionEntry({
    required this.value,
    required this.label,
    this.icon,
  });
}
