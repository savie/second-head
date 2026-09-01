import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/navigation/sh_navigation_shell.dart';

class JourneyView extends StatefulWidget { const JourneyView({super.key}); @override State<JourneyView> createState()=>JourneyViewState(); }
class JourneyViewState extends State<JourneyView> {
 String filter='All'; String query=''; int? selected;
 final List<JourneyItem> items=[JourneyItem('Project SH Roadmap','Documented roadmap and key milestones','2 days ago','Knowledge','The documented roadmap and key milestones for Second Head.',true),JourneyItem('Client Meeting Notes','Important notes from the meeting about feature priorities.','Yesterday','Experience','Important notes captured from the client meeting and its feature priorities.',false),JourneyItem('Ideas – AI Personalization','Ideas about personalization based on user behavior.','May 29','Memory','Ideas and retained context about personalization based on user behavior.',true),JourneyItem('Reference – Runtime Contract','Notes about runtime contract and future calling.','May 25','Knowledge','Reference material describing the runtime contract and future calling.',false)];
 @override Widget build(BuildContext context){if(selected!=null)return JourneyDetail(item:items[selected!],onBack:()=>setState(()=>selected=null),onChanged:()=>setState((){}),onDelete:(){setState((){items.removeAt(selected!);selected=null;});});final q=query.trim().toLowerCase(); final visible=[for(var i=0;i<items.length;i++)if((filter=='All'||items[i].type==filter)&&(q.isEmpty||('${items[i].title} ${items[i].subtitle} ${items[i].content} ${items[i].type}').toLowerCase().contains(q)))i];return Stack(children:[Column(children:[ShTopBar(title:'Journey',actions:[IconButton(onPressed:()=>_search(context),icon:const Icon(Icons.search,size:19))]),JourneyFilters(value:filter,onChanged:(v)=>setState(()=>filter=v)),Expanded(child:ListView.builder(padding:const EdgeInsets.fromLTRB(12,8,12,88),itemCount:visible.length,itemBuilder:(_,i)=>JourneyCard(item:items[visible[i]],onTap:()=>setState(()=>selected=visible[i]))))]),Positioned(right:18,bottom:18,child:FloatingActionButton(heroTag:'journey-add',onPressed:()=>_create(context),child:const Icon(Icons.add)))]);}
 Future<void> _search(BuildContext context) async {final ctl=TextEditingController(text:query);final result=await showModalBottomSheet<String>(context:context,isScrollControlled:true,backgroundColor:shSurface,showDragHandle:true,builder:(sc)=>Padding(padding:EdgeInsets.fromLTRB(18,8,18,MediaQuery.of(sc).viewInsets.bottom+18),child:TextField(controller:ctl,autofocus:true,textInputAction:TextInputAction.search,onSubmitted:(_)=>Navigator.pop(sc,ctl.text),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search journey'))));ctl.dispose();if(mounted&&result!=null)setState(()=>query=result.trim());}
 Future<void> _create(BuildContext context) async {
  final type=await showModalBottomSheet<String>(
    context:context,backgroundColor:shSurface,showDragHandle:true,
    builder:(_)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
      const Padding(padding:EdgeInsets.all(16),child:Align(alignment:Alignment.centerLeft,child:Text('Create new',style:TextStyle(fontSize:16,fontWeight:FontWeight.w700)))),
      for(final t in const ['Memory','Knowledge','Experience'])
        ListTile(leading:const Icon(Icons.add_circle_outline),title:Text(t),onTap:()=>Navigator.pop(context,t)),
      const SizedBox(height:8),
    ])),
  );
  if(!mounted||type==null)return;
  final title=TextEditingController(),content=TextEditingController();
  var privatePolicy=true;
  final draft=await showModalBottomSheet<bool>(
    context:context,isScrollControlled:true,backgroundColor:shSurface,showDragHandle:true,
    builder:(sheet)=>StatefulBuilder(builder:(_,setLocal)=>Padding(
      padding:EdgeInsets.fromLTRB(18,8,18,MediaQuery.of(sheet).viewInsets.bottom+18),
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text('Create $type',style:const TextStyle(fontSize:16,fontWeight:FontWeight.w700)),
        const SizedBox(height:12),
        TextField(controller:title,autofocus:true,decoration:const InputDecoration(hintText:'Title')),
        const SizedBox(height:10),TextField(controller:content,maxLines:7,decoration:const InputDecoration(hintText:'Write content...')),
        const SizedBox(height:12),Row(children:[
          Expanded(child:PolicyOption(label:'Private',icon:Icons.lock_outline,selected:privatePolicy,onTap:()=>setLocal(()=>privatePolicy=true))),
          const SizedBox(width:10),
          Expanded(child:PolicyOption(label:'Public',icon:Icons.public,selected:!privatePolicy,onTap:()=>setLocal(()=>privatePolicy=false))),
        ]),
        const SizedBox(height:14),Row(children:[
          Expanded(child:OutlinedButton(onPressed:()=>Navigator.pop(sheet),child:const Text('Cancel'))),
          const SizedBox(width:10),
          Expanded(child:FilledButton(onPressed:(){if(title.text.trim().isEmpty||content.text.trim().isEmpty)return;Navigator.pop(sheet,true);},child:const Text('Save'))),
        ]),
      ]),
    )),
  );
  final t=title.text.trim(), body=content.text.trim(); title.dispose(); content.dispose();
  if(!mounted||draft!=true)return;
  setState(()=>items.insert(0,JourneyItem(t,body,'Just now',type,body,privatePolicy)));
}

}
class JourneyFilters extends StatelessWidget { JourneyFilters({required this.value,required this.onChanged}); final String value; final ValueChanged<String> onChanged; @override Widget build(BuildContext context)=>SingleChildScrollView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),child:Row(children:[for(final l in const ['All','Memory','Knowledge','Experience'])Padding(padding:const EdgeInsets.only(right:7),child:InkWell(borderRadius:BorderRadius.circular(20),onTap:()=>onChanged(l),child:Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:7),decoration:BoxDecoration(color:value==l?shPurple.withValues(alpha: .16):shSurface,borderRadius:BorderRadius.circular(20),border:Border.all(color:value==l?shPurple:shBorder)),child:Text(l,style:TextStyle(fontSize:9,color:value==l?Colors.white:shMuted)))))])); }
class JourneyItem { JourneyItem(this.title,this.subtitle,this.date,this.type,this.content,this.isPrivate); String title,subtitle,date,type,content; bool isPrivate; }
class JourneyCard extends StatelessWidget { const JourneyCard({required this.item,required this.onTap}); final JourneyItem item; final VoidCallback onTap; @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(16),child:Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:shSurface,borderRadius:BorderRadius.circular(16),border:Border.all(color:shBorder)),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:4),decoration:BoxDecoration(color:shPurple.withValues(alpha: .12),borderRadius:BorderRadius.circular(8)),child:Text(item.type,style:const TextStyle(fontSize:8,color:shMuted))),const SizedBox(width:7),Expanded(child:Text(item.title,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w600)))]),const SizedBox(height:5),Text(item.subtitle,style:const TextStyle(fontSize:9,color:shMuted,height:1.35)),const SizedBox(height:6),Text(item.date,style:const TextStyle(fontSize:8,color:shMuted))])),const Icon(Icons.chevron_right_rounded,color:shMuted)]))); }
class JourneyDetail extends StatefulWidget {
 const JourneyDetail({required this.item,required this.onBack,required this.onChanged,required this.onDelete});
 final JourneyItem item; final VoidCallback onBack,onChanged,onDelete;
 @override State<JourneyDetail> createState()=>JourneyDetailState();
}
class JourneyDetailState extends State<JourneyDetail>{
 late bool privatePolicy;
 @override void initState(){super.initState();privatePolicy=widget.item.isPrivate;}
 @override Widget build(BuildContext context)=>Column(children:[
  ShTopBar(title:widget.item.type,leading:IconButton(onPressed:widget.onBack,icon:const Icon(Icons.arrow_back)),actions:[
   IconButton(onPressed:_edit,icon:const Icon(Icons.edit_outlined,size:19)),
   IconButton(onPressed:_delete,icon:const Icon(Icons.delete_outline,size:19)),
  ]),
  Expanded(child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(16,8,16,20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(widget.item.title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w700)),const SizedBox(height:14),
   Container(width:double.infinity,padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:shSurface,borderRadius:BorderRadius.circular(16),border:Border.all(color:shBorder)),child:Text(widget.item.content,style:const TextStyle(fontSize:12,height:1.5))),
   const SizedBox(height:20),const Text('Policy',style:TextStyle(fontSize:12,fontWeight:FontWeight.w700)),const SizedBox(height:8),
   Row(children:[
    Expanded(child:PolicyOption(label:'Private',icon:Icons.lock_outline,selected:privatePolicy,onTap:()=>_setPolicy(true))),
    const SizedBox(width:10),
    Expanded(child:PolicyOption(label:'Public',icon:Icons.public,selected:!privatePolicy,onTap:()=>_setPolicy(false))),
   ]),
  ])),
 ]);
 void _setPolicy(bool value){setState(()=>privatePolicy=value);widget.item.isPrivate=value;widget.onChanged();}
 Future<void> _edit() async {
  final title=TextEditingController(text:widget.item.title),body=TextEditingController(text:widget.item.content);var priv=widget.item.isPrivate;
  final draft=await showModalBottomSheet<List<dynamic>>(context:context,isScrollControlled:true,backgroundColor:shSurface,showDragHandle:true,builder:(sheet)=>StatefulBuilder(builder:(_,setLocal)=>Padding(
   padding:EdgeInsets.fromLTRB(18,8,18,MediaQuery.of(sheet).viewInsets.bottom+18),
   child:Column(mainAxisSize:MainAxisSize.min,children:[
    Text('Edit ${widget.item.type}',style:const TextStyle(fontSize:16,fontWeight:FontWeight.w700)),const SizedBox(height:12),
    TextField(controller:title,decoration:const InputDecoration(hintText:'Title')),const SizedBox(height:10),TextField(controller:body,maxLines:7),
    const SizedBox(height:12),Row(children:[
     Expanded(child:PolicyOption(label:'Private',icon:Icons.lock_outline,selected:priv,onTap:()=>setLocal(()=>priv=true))),
     const SizedBox(width:10),Expanded(child:PolicyOption(label:'Public',icon:Icons.public,selected:!priv,onTap:()=>setLocal(()=>priv=false))),
    ]),
    const SizedBox(height:14),Row(children:[
     Expanded(child:OutlinedButton(onPressed:()=>Navigator.pop(sheet),child:const Text('Cancel'))),const SizedBox(width:10),
     Expanded(child:FilledButton(onPressed:(){if(title.text.trim().isEmpty||body.text.trim().isEmpty)return;Navigator.pop(sheet,[title.text.trim(),body.text.trim(),priv]);},child:const Text('Save'))),
    ]),
   ]))),
  );
  final t=title.text.trim(),b=body.text.trim();title.dispose();body.dispose();
  if(!mounted||draft==null)return;
  setState((){widget.item.title=t;widget.item.content=b;widget.item.subtitle=b;widget.item.isPrivate=draft[2] as bool;privatePolicy=widget.item.isPrivate;});
  widget.onChanged();
 }
 Future<void> _delete() async {final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(title:const Text('Delete journey'),content:const Text('Delete this journey entry?'),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Delete'))]));if(ok==true&&mounted)widget.onDelete();}
}

class PolicyOption extends StatelessWidget { const PolicyOption({required this.label,required this.icon,required this.selected,required this.onTap}); final String label; final IconData icon; final bool selected; final VoidCallback onTap; @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(14),child:Container(padding:const EdgeInsets.symmetric(vertical:13,horizontal:12),decoration:BoxDecoration(color:selected?shPurple.withValues(alpha: .13):shSurface,borderRadius:BorderRadius.circular(14),border:Border.all(color:selected?shPurple:shBorder)),child:Row(children:[Icon(icon,size:18),const SizedBox(width:8),Text(label,style:const TextStyle(fontSize:10))]))); }
