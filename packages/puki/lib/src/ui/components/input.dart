part of 'component.dart';

class _InputWidget {
  TextField textField({FocusNode? focusNode, TextEditingController? controller, String? hintText, Function(String)? onChanged}) {
    return TextField(
      focusNode: focusNode,
      keyboardType: TextInputType.multiline,
      maxLines: 8,
      minLines: 1,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        isDense: true,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Future showInputTypeMenus({required BuildContext context, required List<PmInputType?> types, required Function(PmInputType type) onSelect}) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(10),
          child: Material(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(types.length, (i) {
                final type = types[i];
                return Visibility(
                  visible: type!.showInMenu,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: i == 0
                          ? BorderRadius.vertical(top: Radius.circular(20))
                          : i == (types.length - 1)
                              ? BorderRadius.vertical(bottom: Radius.circular(20))
                              : BorderRadius.zero,
                    ),
                    leading: Icon(type.icon),
                    title: Text(type.name),
                    onTap: () {
                      onSelect(type);
                    },
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
