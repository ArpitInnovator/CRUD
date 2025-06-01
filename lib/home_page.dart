import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:CRUD/add_new_task.dart';
import 'package:CRUD/utils.dart';
import 'package:CRUD/widgets/task_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';



class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
         
       title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewTask(),
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.add,
            ),
          ),

           IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('tasks').where(
            'creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(!snapshot.hasData) {
              return const Text('No data here');
            }
          
            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: ValueKey(snapshot.data!.docs[index].id),
                    onDismissed: (direction) {
                      if(direction == DismissDirection.endToStart) {
                        FirebaseFirestore.instance
                        .collection('tasks')
                        .doc(snapshot.data!.docs[index].id).delete();
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: TaskCard(
                            color: hexToColor(snapshot.data!.docs[index].data()['color']),
                            headerText: snapshot.data!.docs[index].data()['title'],
                            descriptionText: snapshot.data!.docs[index].data()['description'],
                            scheduledDate: DateFormat('dd-MM-yyyy – hh:mm a').format(
                              (snapshot.data!.docs[index].data()['date'] as Timestamp).toDate(),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddNewTask(
                                    taskData: snapshot.data!.docs[index].data(),
                                    taskId: snapshot.data!.docs[index].id,
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
        ),
      ),
    );
  }
}