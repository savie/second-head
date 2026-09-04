import 'package:flutter/material.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';
import 'export_data_view.dart';
import 'delete_data_view.dart';
import 'data_files_view.dart';
import 'data_privacy_widgets.dart';

class DataPrivacyView extends StatelessWidget {
  const DataPrivacyView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(
      children: [
        ShTopBar(
          title: 'Data & Privacy',
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
            children: [
              const DPSectionLabel('YOUR DATA'),
              const SizedBox(height: 8),
              DPCard(
                icon: Icons.folder_copy_outlined,
                title: 'Data & Files',
                subtitle: 'Manage local images, files, audio and video',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const DataFilesView()),
                ),
              ),
              const SizedBox(height: 10),
              DPCard(
                icon: Icons.file_download_outlined,
                title: 'Export Data',
                subtitle: 'Get a copy of your SH data',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ExportDataView()),
                ),
              ),
              const SizedBox(height: 10),
              DPCard(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Data',
                subtitle: 'Remove selected SH data',
                destructive: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const DeleteDataView()),
                ),
              ),
              const SizedBox(height: 22),
              const DPSectionLabel('PRIVACY'),
              const SizedBox(height: 8),
              DPCard(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Information',
                subtitle: 'How your data is handled',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PrivacyInformationView()),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class PrivacyInformationView extends StatelessWidget {
  const PrivacyInformationView();

  @override
  Widget build(BuildContext context) => DPSubPage(
    title: 'Privacy Information',
    children: [
      const DPSectionLabel('PRIVACY'),
      const SizedBox(height: 8),
      const DPInfoCard(
        icon: Icons.privacy_tip_outlined,
        title: 'How your data is handled',
        description: 'This page provides a clear overview of how SH data is handled. Detailed policy controls belong to the relevant SH workflows rather than being duplicated here.',
      ),
      const SizedBox(height: 14),
      const DPSectionLabel('DATA TYPES'),
      const SizedBox(height: 8),
      const DPOptionCard(
        icon: Icons.storage_outlined,
        title: 'Stored SH data',
        subtitle: 'Data that belongs to your SH account and stored workflows',
      ),
      const SizedBox(height: 10),
      const DPOptionCard(
        icon: Icons.phone_android_outlined,
        title: 'Local files',
        subtitle: 'Images, files, audio and video kept on this device',
      ),
      const SizedBox(height: 10),
      const DPOptionCard(
        icon: Icons.tune_rounded,
        title: 'Privacy controls',
        subtitle: 'Policy and permission controls remain in their relevant SH workflows',
      ),
    ],
  );
}
