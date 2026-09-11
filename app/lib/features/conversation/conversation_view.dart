import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/state/sh_profile_state.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/sh_theme.dart';
import '../../core/result.dart';
import '../../runtime/ai_runtime/ai_runtime_client.dart';
import '../../runtime/runtime_contract.dart';
import '../journey/semantic_hook.dart';
import 'conversation_runtime_bridge.dart';

final ValueNotifier<String> conversationTitle = ValueNotifier<String>('Today Priorities');
final ValueNotifier<int> conversationRevision = ValueNotifier<int>(0);

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => ConversationViewState();
}

class ConversationViewState extends State<ConversationView> {
  final Connectivity _connectivity = Connectivity();
  final ConversationRuntimeBridge _runtime = const ConversationRuntimeBridge();
  final AIRuntimeClient _aiRuntime = const AIRuntimeClient();
  final TextEditingController _composerController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final Set<int> selected = {};
  final List<ConversationMessage> _messages = [];

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _internetCheckTimer;
