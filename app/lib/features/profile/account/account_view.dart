import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/state/sh_profile_state.dart';
import '../../../core/theme/sh_theme.dart';
import '../profile_widgets.dart';

part 'account_widgets.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 900,
    );
    if (file == null) return;
    profilePhoto.value = await file.readAsBytes();
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ProfilePhotoAction(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ProfilePhotoAction(
                icon: Icons.photo_library_outlined,
                label: 'Photos',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              ProfilePhotoAction(
                icon: Icons.delete_outline,
                label: 'Remove',
                onTap: profilePhoto.value == null
                    ? null
                    : () {
                        Navigator.pop(context);
                        profilePhoto.value = null;
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editValue({
    required String title,
    required String initial,
    required ValueChanged<String> onSave,
  }) async {
    _editController.value = TextEditingValue(
      text: initial,
      selection: TextSelection.collapsed(offset: initial.length),
    );
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: shSurface,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          8,
          18,
          MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(
              controller: _editController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => Navigator.pop(sheetContext, _editController.text.trim()),
              decoration: InputDecoration(
                filled: true,
                fillColor: shBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: shBorder),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(sheetContext, _editController.text.trim()),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted || value == null || value.isEmpty) return;
    onSave(value);
  }

  Future<void> _editEmail() => _editValue(
        title: 'Email',
        initial: profileEmail.value,
        onSave: (value) => profileEmail.value = value,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      body: Column(
        children: [
          ShTopBar(
            title: 'Account',
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _showPhotoOptions,
                    child: const ShProfileMark(size: 112),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Tap photo to change',
                    style: TextStyle(fontSize: 11, color: shMuted),
                  ),
                ),
                const SizedBox(height: 22),
                ValueListenableBuilder<String>(
                  valueListenable: profileName,
                  builder: (context, name, _) => ValueListenableBuilder<String>(
                    valueListenable: profileEmail,
                    builder: (context, email, _) => _AccountSection(
                      title: 'Personal',
                      rows: [
                        _AccountRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Name',
                          value: name,
                          editable: true,
                          onTap: () => _editValue(
                            title: 'Name',
                            initial: name,
                            onSave: (value) => profileName.value = value,
                          ),
                        ),
                        _AccountRow(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email',
                          value: email,
                          editable: true,
                          onTap: () => _editEmail(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _AccountSection(
                  title: 'Identifiers',
                  rows: const [
                    _AccountRow(
                      icon: Icons.badge_outlined,
                      label: 'Account ID',
                      value: 'xxxxx',
                    ),
                    _AccountRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'SH ID',
                      value: 'xxxxx',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AccountSection(
                  title: 'Account',
                  rows: const [
                    _AccountRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Account created',
                      value: 'mm-dd-yyyy',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
