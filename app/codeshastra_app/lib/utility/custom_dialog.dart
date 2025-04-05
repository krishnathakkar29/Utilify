import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  const CustomDialog(
      {Key? key,
      this.title,
      required this.content,
      this.padding,
      this.titleColor,
      this.titleBackground,
      this.showCloseIcon = true})
      : super(key: key);
  final Widget content;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final Color? titleColor;
  final Color? titleBackground;
  final bool showCloseIcon;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (widget.title != null)
              Container(
                color: widget.titleBackground,
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                        child: Text(
                      widget.title ?? '',
                      textAlign: TextAlign.center,
                      // style: BaseTextTheme.boldFont
                      //     .copyWith(color: widget.titleColor),
                    )),
                    if (widget.showCloseIcon)
                      SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                          )),
                  ],
                ),
              ),
            if (widget.title != null)
              const Divider(thickness: 1, height: 1, endIndent: 10, indent: 10),
            Flexible(
                child: Container(
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    child: widget.content)),
          ])),
    );
  }
}
