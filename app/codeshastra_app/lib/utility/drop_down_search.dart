// import 'package:ai_farmer_app/utility/custom_dialog.dart';
// import 'package:ai_farmer_app/utility/custom_textform_field.dart';
import 'package:codeshastra_app/utility/custom_dialog.dart';
import 'package:codeshastra_app/utility/custom_textform_field.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
// import 'package:rso_flutter/utils/theme/text_theme.dart';

class CustomSearchableDropdown<T> extends StatefulWidget {
  const CustomSearchableDropdown({
    super.key,
    this.value,
    this.hint,
    this.title,
    bool? disable,
    this.onChanged,
    required this.items,
  }) : disable = disable ?? false;

  final T? value;
  final String? hint;
  final String? title;
  final bool disable;
  final List<DropDownItem> items;
  final void Function(dynamic)? onChanged;

  @override
  State<CustomSearchableDropdown> createState() =>
      _CustomSearchableDropdownState();
}

class _CustomSearchableDropdownState extends State<CustomSearchableDropdown> {
  @override
  initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(CustomSearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showFilter() {
    showDialog(
      context: context,
      builder: (context) {
        var search = '';
        return CustomDialog(
          title: widget.title ?? '',
          content: StatefulBuilder(
            builder: (context, setState) {
              final list =
                  widget.items
                      .where(
                        (element) => element.name.toLowerCase().contains(
                          search.toLowerCase(),
                        ),
                      )
                      .toList();
              return SizedBox(
                height: MediaQuery.sizeOf(context).height * .6,
                child: Column(
                  children: [
                    CustomTextFormField(
                      value: search,
                      type: CustomTextFormFieldType.outlined,
                      hintText: 'Search',
                      onChanged: (p0) {
                        setState(() {
                          search = p0;
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        key: Key(widget.title ?? ''),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return InkWell(
                            onTap: () {
                              if (widget.onChanged != null)
                                widget.onChanged!.call(item.value);
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                item.name,
                                // style: BaseTextTheme.mediumFont
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultValue =
        widget.items
            .firstWhereOrNull((element) => element.value == widget.value)
            ?.name;
    return InkWell(
      onTap: widget.disable ? null : showFilter,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              defaultValue ?? widget.hint ?? '',
              style: TextStyle(color: Colors.black),
            ),
            Icon(
              Icons.keyboard_arrow_down_outlined,
              color: widget.disable ? Colors.grey : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class DropDownItem {
  final String name;
  final dynamic value;

  const DropDownItem({required this.name, required this.value});

  factory DropDownItem.fromJson(Map<String, dynamic> json) =>
      DropDownItem(name: json["name"], value: json["value"]);

  Map<String, dynamic> toJson() => {"name": name, "value": value};
}
