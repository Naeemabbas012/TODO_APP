import 'package:flutter/material.dart';
import 'package:to_do_app/database/database.dart';
import 'package:to_do_app/screens/home_screen.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';

class AddNoteScreen extends StatefulWidget {
 final Note? note;
 final Function? updateNoteList;

 AddNoteScreen({this.note, this.updateNoteList});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority = 'Low';
  DateTime _date = DateTime.now();
  String btnText = "Add Note";
  String titleText = "Add Note";
  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState(){
    super.initState();

    if(widget.note != null){
     _title = widget.note!.title!;
     _date = widget.note!.date!;
     _priority = widget.note!.priority!;

     setState(() {
       btnText = "Update Note";
       titleText = "Update Note";
     });
    }
    else{
      setState(() {
        btnText = "Add Note";
        titleText = "Add Note";
      });
    }
    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose(){
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
    );
    if(date != null && date != _date){
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }
  _delete(){
  DatabaseHelper.instance.deleteNote(widget.note!.id!);
  Navigator.pushReplacement(
  context,
  MaterialPageRoute(
  builder: (_)=> HomeScreen(),
  ),
  );
  widget.updateNoteList!();
}

  _submit(){
   if(_formKey.currentState!.validate()){
     _formKey.currentState!.save();
     print('$_title, $_date, $_priority');

     Note note = Note(title: _title, date: _date, priority: _priority);

     if(widget.note == null){
       note.status = 0;
       DatabaseHelper.instance.insertNote(note);

       Navigator.pushReplacement(
           context,
           MaterialPageRoute(
               builder: (_) =>  HomeScreen(),
           ),
       );
     }
     else{
       note.id = widget.note!.id;
       note.status = widget.note!.status;
       DatabaseHelper.instance.updateNote(note);

       Navigator.pushReplacement(
           context,
           MaterialPageRoute(
             builder: (_)=>  HomeScreen(),
           ),
       );
     }

     widget.updateNoteList!();
   }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.blueAccent,
      body: GestureDetector(
        onTap: ()=> FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
               GestureDetector(
                 onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  HomeScreen(),)),
                 child:  Icon(
                   Icons.arrow_back,
                   size: 30.0,
                   color: Theme.of(context).primaryColor,
                 ),
               ),
                const SizedBox(height: 20.0,),
                 Text(
                  titleText,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0,),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget> [
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: const TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )
                          ),
                          validator: (input) =>
                          input!.trim().isEmpty ? 'please enter a note title' : null,
                          onSaved: (input) => _title = input!,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: const TextStyle(fontSize: 18.0),
                          onTap: _handleDatePicker,
                          decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: const TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                          ),
                        ),
                      ),
                      Padding(
                          padding:  const EdgeInsets.symmetric(vertical: 20.0),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          iconSize: 22.0,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          items: _priorities.map((String priority){
                              return DropdownMenuItem(
                                value: priority,
                                  child: Text(
                                    priority,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  );
                          }).toList(),
                          style: const TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: const TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )
                          ),
                          validator: (input) => _priority == null ? 'please select a priority level' : null,
                          onChanged: (value){
                            setState(() {
                              _priority = value.toString();
                            });
                          },
                          value: _priority,
                        ),
                          ),
                      Container(
                        margin:  const EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: ElevatedButton(
                          style: 
                           const ButtonStyle(
                              backgroundColor:WidgetStatePropertyAll(Colors.purpleAccent)),
                          onPressed: _submit,
                          child: Text(
                            btnText,
                            style:  const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,

                            ),
                          ),
                        ),
                      ),
                      widget.note != null ? Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: ElevatedButton(
                            child: Text(
                              'delete Note',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                          onPressed: _delete,
                        ),
                      ): SizedBox.shrink(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
