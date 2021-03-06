import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasks_go_brr/resources/colors.dart';
import 'package:tasks_go_brr/resources/dimens.dart';
import 'package:tasks_go_brr/ui/base/base_state.dart';
import 'package:tasks_go_brr/ui/custom/button_icon_rounded.dart';

class InputFieldRounded extends StatefulWidget {
  final TextEditingController textController;
  final TextInputType keyboardType;
  final Key? formKey;
  final FormFieldValidator<String>? validator;

  String? labelText;
  final int? minLines;
  final int? maxLines;
  final IconData? buttonIcon;
  final VoidCallback? onTap;
  final Icon? prefixIcon;
  Color? borderColor;
  Color? textColor;
  Color? labelUnselectedColor;
  bool? shouldUnfocus;

  InputFieldRounded({
    Key? key,
    this.labelText,
    this.minLines,
    this.maxLines,
    required this.textController,
    this.keyboardType = TextInputType.text,
    this.formKey,
    this.validator,
    this.prefixIcon,
    this.buttonIcon,
    this.borderColor,
    this.textColor,
    this.labelUnselectedColor,
    this.onTap,
    this.shouldUnfocus,
  }) {
    shouldUnfocus = shouldUnfocus ?? true;
  }

  @override
  State<StatefulWidget> createState() => _InputFieldRoundedState();
}

class _InputFieldRoundedState extends BaseState<InputFieldRounded> {
  final FocusNode focusNode = FocusNode();

  void changeLabel(String label) {
    widget.labelText = label;
    setState(() {});
  }

  @override
  void initState() {
    _setListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.borderColor = widget.borderColor ?? context.primary;
    widget.textColor = widget.textColor ?? context.onSurface;
    widget.labelUnselectedColor =
        widget.labelUnselectedColor ?? context.onSurfaceAccent;

    if (widget.buttonIcon != null) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: (widget.maxLines ?? 1) > 1
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: _inputField()),
            SizedBox(
              width: Margin.small_half.w,
            ),
            Container(
              height: 42.h,
              width: 42.h,
              margin: EdgeInsets.symmetric(
                  horizontal: Margin.small, vertical: Margin.small_very),
              child: ButtonIconRounded(
                  icon: widget.buttonIcon!,
                  backgroundColor: context.surfaceAccent,
                  iconColor: context.onSurface,
                  onTap: () {
                    if (widget.shouldUnfocus! &&
                        widget.textController.text.isNotEmpty)
                      unfocus();
                    if (widget.onTap != null) widget.onTap!();
                  }),
            ),
          ],
        ),
      );
    } else {
      return _inputField();
    }
  }

  Widget _inputField() {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        key: widget.key,
        validator: widget.validator,
        focusNode: focusNode,
        controller: widget.textController,
        textAlign: TextAlign.start,
        textInputAction: TextInputAction.next,
        keyboardType: widget.keyboardType,
        cursorColor: widget.borderColor!,
        style:
            TextStyle(fontSize: Dimens.text_normal, color: widget.textColor!),
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
              vertical: Paddings.middle, horizontal: Paddings.middle),
          labelText: widget.labelText,
          labelStyle: TextStyle(
              fontSize: Dimens.text_normal,
              color: focusNode.hasFocus
                  ? widget.borderColor!
                  : widget.labelUnselectedColor!),
          alignLabelWithHint: true,
          prefixIcon: widget.prefixIcon,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radiuss.small_smaller),
            borderSide: BorderSide(
              color: widget.borderColor!,
              width: Borders.small,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radiuss.small_smaller),
            borderSide: BorderSide(
              color: widget.borderColor!,
              width: Borders.small,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radiuss.small_smaller),
            borderSide: BorderSide(
              color: context.error,
              width: Borders.small,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radiuss.small_smaller),
            borderSide: BorderSide(
              color: context.error,
              width: Borders.small,
            ),
          ),
        ),
      ),
    );
  }

  void _setListeners() {
    focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }
}