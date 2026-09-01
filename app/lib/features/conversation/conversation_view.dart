import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';

final ValueNotifier<String> conversationTitle =
    ValueNotifier<String>('Today Priorities');

final ValueNotifier<Uint8List?> _profilePhoto = ValueNotifier<Uint8List?>(null);

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => ConversationViewState();
}

class ConversationViewState extends State<ConversationView> {
 final Set<int> selected={};
 final List<ConversationMessage> _messages = [
   ConversationMessage('Hi, Savie! 👋\nHow can I help you today?', true, '09:41'),
   ConversationMessage('Help me summarize my main plan for today and top priorities.', false, '09:41'),
   ConversationMessage('Sure! Here is your summary and top priorities.', true, '09:42'),
 ];
 final TextEditingController _composerController = TextEditingController();
 final ImagePicker _picker = ImagePicker();
 final TextEditingController _searchController=TextEditingController();
 void _conversationMenu()=>showModalBottomSheet<void>(context:context,backgroundColor:shSurface,showDragHandle:true,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(22))),builder:(_)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[ActionTile(Icons.copy_outlined,'Copy',()=>Navigator.pop(context)),ActionTile(Icons.clear_all_rounded,'Clear',()=>Navigator.pop(context)),ActionTile(Icons.delete_outline,'Delete',()=>Navigator.pop(context)),ActionTile(Icons.share_outlined,'Share',()=>Navigator.pop(context)),const SizedBox(height:8)])));
 void _copyText(String text){ if(text.trim().isEmpty)return; Clipboard.setData(ClipboardData(text:text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Copied'),behavior:SnackBarBehavior.floating)); }
 void _messageActions(int index,{required bool assistant}){final actions=assistant?const ['Copy','Regenerate','Delete']:const ['Copy','Edit','Delete'];showModalBottomSheet<void>(context:context,backgroundColor:shSurface,showDragHandle:true,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(22))),builder:(_)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[for(final a in actions)ActionTile(a=='Copy'?Icons.copy_outlined:a=='Edit'?Icons.edit_outlined:a=='Regenerate'?Icons.refresh_rounded:Icons.delete_outline,a,()=>Navigator.pop(context)),const SizedBox(height:8)])));}
 void _enterSelection(int index)=>setState(()=>selected.add(index));
 void _toggleSelection(int index)=>setState((){if(selected.contains(index)){selected.remove(index);}else{selected.add(index);}});
 void _deleteSelected(){setState((){final ids=selected.toList()..sort((a,b)=>b.compareTo(a));for(final i in ids){if(i<_messages.length)_messages.removeAt(i);}selected.clear();});}
 void _runMessageAction(BuildContext context,int index,String action){
   Navigator.pop(context);
   if(index>=_messages.length)return;
   final m=_messages[index];
   if(action=='Copy'){_copyText(m.text);}
   else if(action=='Delete'){setState(()=>_messages.removeAt(index));}
   else if(action=='Regenerate'){setState(()=>m.text='Regenerated response — ready to continue.');}
   else if(action=='Edit'){final ctl=TextEditingController(text:m.text);showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:shSurface,showDragHandle:true,builder:(sheet)=>Padding(padding:EdgeInsets.fromLTRB(18,8,18,MediaQuery.of(sheet).viewInsets.bottom+18),child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Edit message',style:TextStyle(fontSize:16,fontWeight:FontWeight.w700)),const SizedBox(height:12),TextField(controller:ctl,maxLines:5),const SizedBox(height:14),Row(children:[Expanded(child:OutlinedButton(onPressed:()=>Navigator.pop(sheet),child:const Text('Cancel'))),const SizedBox(width:10),Expanded(child:FilledButton(onPressed:(){if(ctl.text.trim().isNotEmpty)setState(()=>m.text=ctl.text.trim());Navigator.pop(sheet);},child:const Text('Save')))])])));}
 }
 @override Widget build(BuildContext context){final selecting=selected.isNotEmpty;return Column(children:[
 if(selecting)Container(height:56,padding:const EdgeInsets.symmetric(horizontal:8),decoration:const BoxDecoration(color:shSurface),child:Row(children:[IconButton(onPressed:()=>setState(()=>selected.clear()),icon:const Icon(Icons.close)),Text(selected.length.toString(),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w700)),const Spacer(),IconButton(onPressed:_deleteSelected,icon:const Icon(Icons.delete_outline))]))
 else ValueListenableBuilder<String>(valueListenable:conversationTitle,builder:(context,title,_)=>ShTopBar(title:title,actions:[IconButton(onPressed:()=>showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:shSurface,showDragHandle:true,builder:(_)=>Padding(padding:const EdgeInsets.fromLTRB(18,8,18,18),child:TextField(controller:_searchController,autofocus:true,decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search conversation')))),icon:const Icon(Icons.search,size:19)),IconButton(onPressed:_conversationMenu,icon:const Icon(Icons.more_vert,size:21)),IconButton(onPressed:(){final controller=TextEditingController(text:title);showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:shSurface,showDragHandle:true,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(22))),builder:(sheet)=>Padding(padding:EdgeInsets.fromLTRB(18,8,18,MediaQuery.of(sheet).viewInsets.bottom+18),child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Rename conversation',style:TextStyle(fontSize:16,fontWeight:FontWeight.w700)),const SizedBox(height:12),TextField(controller:controller,autofocus:true),const SizedBox(height:14),Row(children:[Expanded(child:OutlinedButton(onPressed:()=>Navigator.pop(sheet),child:const Text('Cancel'))),const SizedBox(width:10),Expanded(child:FilledButton(onPressed:(){final name=controller.text.trim();if(name.isNotEmpty)conversationTitle.value=name;Navigator.pop(sheet);},child:const Text('Save')))])])));},icon:const Icon(Icons.edit_square,size:19))]))),
 const Padding(padding:EdgeInsets.symmetric(horizontal:12),child:CompanionCard()),
 Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(12,12,12,10),children:[const DateLabel('Today'),SelectableMessage(index:0,assistant:true,selected:selected.contains(0),onLongPress:()=>_enterSelection(0),onTap:()=>selecting?_toggleSelection(0):_messageActions(0,assistant:true),child:Message(text:'Hi, Savie! 👋\\nHow can I help you today?',time:'09:41',assistant:true)),SelectableMessage(index:1,assistant:false,selected:selected.contains(1),onLongPress:()=>_enterSelection(1),onTap:()=>selecting?_toggleSelection(1):_messageActions(1,assistant:false),child:Message(text:'Help me summarize my main plan for today and top priorities.',time:'09:41',assistant:false)),SelectableMessage(index:2,assistant:true,selected:selected.contains(2),onLongPress:()=>_enterSelection(2),onTap:()=>selecting?_toggleSelection(2):_messageActions(2,assistant:true),child:Message(text:'Sure! Here is your summary and top priorities.',time:'09:42',assistant:true)),SummaryCard()])),
 if(!selecting) Composer(controller:_composerController,onSend:_send,onAttach:_showAttachments),]);}
}
class SelectableMessage extends StatelessWidget { const SelectableMessage({required this.index,required this.assistant,required this.selected,required this.onLongPress,required this.onTap,required this.child}); final int index; final bool assistant,selected; final VoidCallback onLongPress,onTap; final Widget child; @override Widget build(BuildContext context)=>GestureDetector(onLongPress:onLongPress,onTap:onTap,child:AnimatedContainer(duration:const Duration(milliseconds:160),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),color:selected?shPurple.withOpacity(.12):Colors.transparent),child:Stack(children:[child,if(selected)const Positioned(right:4,top:4,child:Icon(Icons.check_circle,size:17))]))); }
class ConversationMessage {
 ConversationMessage(this.text,this.assistant,this.time,{this.image});
 String text; final bool assistant; final String time; final Uint8List? image;
}
class ActionTile extends StatelessWidget { const ActionTile(this.icon,this.label,this.onTap); final IconData icon; final String label; final VoidCallback onTap; @override Widget build(BuildContext context)=>ListTile(leading:Icon(icon,size:20),title:Text(label,style:const TextStyle(fontSize:11)),onTap:onTap); }
class CompanionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: shBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [shPurple, shElectric]),
            ),
            child: const Icon(Icons.psychology_outlined, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SH Prime', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Row(children: [Icon(Icons.circle, size: 6, color: Colors.green), SizedBox(width: 4), Text('Online', style: TextStyle(fontSize: 9, color: shMuted))]),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: shMuted),
        ],
      ),
    );
  }
}

class DateLabel extends StatelessWidget {
  const DateLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(text, style: const TextStyle(fontSize: 9, color: shMuted)),
        ),
      );
}

class Message extends StatelessWidget {
  const Message({
    required this.text,
    required this.time,
    required this.assistant,
    this.image,
  });

  final String text;
  final String time;
  final bool assistant;
  final Uint8List? image;

  void _showActions(BuildContext context) {
    final actions = assistant
        ? const ['Copy', 'Delete', 'Regenerate']
        : const ['Copy', 'Delete', 'Edit'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in actions)
              ListTile(
                leading: Icon(
                  action == 'Delete'
                      ? Icons.delete_outline
                      : action == 'Edit'
                          ? Icons.edit_outlined
                          : action == 'Regenerate'
                              ? Icons.refresh_rounded
                              : Icons.copy_outlined,
                  color: action == 'Delete' ? Colors.redAccent : Colors.white70,
                ),
                title: Text(action),
                onTap: onTap,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showActions(context),
      child: Align(
        alignment: assistant ? Alignment.centerLeft : Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (assistant)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChatAvatar(assistant: true),
              ),
            Container(
          constraints: const BoxConstraints(maxWidth: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: assistant
                ? null
                : const LinearGradient(colors: [shPurple, shElectric]),
            color: assistant ? shSurface2 : null,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(assistant ? 5 : 18),
              bottomRight: Radius.circular(assistant ? 18 : 5),
            ),
            border: assistant ? Border.all(color: shBorder) : null,
          ),
          child: Column(
            crossAxisAlignment:
                assistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    image!,
                    width: 245,
                    height: 175,
                    fit: BoxFit.cover,
                  ),
                ),
              if (image != null && text.isNotEmpty) const SizedBox(height: 7),
              if (text.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 11, height: 1.4),
                  ),
                ),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 8, color: shMuted)),
            ],
          ),
        ),
            if (!assistant)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ChatAvatar(assistant: false),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({required this.assistant});
  final bool assistant;

  @override
  Widget build(BuildContext context) {
    if (assistant) {
      return Container(
        width: 22,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [shPurple, shElectric]),
        ),
        child: ClipOval(child: Image.asset('assets/brand/unity.png', fit: BoxFit.contain)),
      );
    }
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: _profilePhoto,
      builder: (context, photo, _) => CircleAvatar(
        radius: 11,
        backgroundColor: shSurface2,
        backgroundImage: photo != null ? MemoryImage(photo) : null,
        child: photo == null ? const Icon(Icons.person_outline, size: 13, color: shMuted) : null,
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: shBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today Summary', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('• Meeting with team SH – 10:00 AM\n• Review document R6 – 1:00 PM\n• Implement feature A – 3:00 PM', style: TextStyle(fontSize: 10, color: shMuted, height: 1.55)),
          SizedBox(height: 9),
          Text('Top Priorities', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          SizedBox(height: 5),
          Text('1. Complete feature A\n2. Integrate calendar\n3. Write documentation', style: TextStyle(fontSize: 10, color: shMuted, height: 1.55)),
        ],
      ),
    );
  }
}

class Composer extends StatelessWidget {
  const Composer({required this.controller,required this.onSend,required this.onAttach});

  @override
  final TextEditingController controller; final VoidCallback onSend; final VoidCallback onAttach;
}
  void _showAttachments() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AttachAction(icon: Icons.camera_alt_outlined, label: 'Camera'),
              AttachAction(icon: Icons.photo_library_outlined, label: 'Photos'),
              AttachAction(icon: Icons.attach_file_rounded, label: 'File'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 9),
      child: Row(
        children: [
          IconButton(onPressed: onAttach, icon: const Icon(Icons.add_circle_outline, size: 22)),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Message SH...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 13),
                  suffixIcon: IconButton(onPressed: onSend, icon: const Icon(Icons.arrow_upward, size: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AttachAction extends StatelessWidget {
  const AttachAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [shPurple, shElectric]),
              ),
              child: Icon(icon),
            ),
            const SizedBox(height: 7),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}


class RecentConversationEntry {
  const RecentConversationEntry(this.title, this.preview);
  final String title;
  final String preview;
}

final ValueNotifier<List<RecentConversationEntry>> recentConversations =
    ValueNotifier<List<RecentConversationEntry>>([
  const RecentConversationEntry('Today Priorities', 'Summary and top priorities'),
  const RecentConversationEntry('SH Roadmap', 'Project planning and milestones'),
  const RecentConversationEntry('Ideas & Notes', 'Personalized ideas and notes'),
]);
