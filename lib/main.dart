import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const backendUrl = "http://localhost:9090/todos";

class Todo {
  String id;
  String name;
  bool completed;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.name,
    required this.completed,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      name: json['name'] as String,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void snackerBarShow(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<List<dynamic>> _fetchTodos() async {
    var result = await http.get(
      Uri.parse(backendUrl),
    );
    var decoded = await jsonDecode(result.body);
    List<dynamic> decodedList = decoded['data'];
    List<Todo>? newTodo = decodedList.map((i) => Todo.fromJson(i)).toList();
    return newTodo;
  }

  Future<void> _addTodo(String name) async {
    var result = await http.post(
      Uri.parse(backendUrl),
      body: jsonEncode({"name": name}),
    );
    if (result.statusCode == 200) {
      snackerBarShow("Added");
      return Future(() => setState(() {}));
    } else {
      snackerBarShow("Error");
    }
  }

  Future<void> _updateTodo(String id, bool completed) async {
    var req = {"completed": !completed};
    var result = await http.patch(
      Uri.parse('$backendUrl/$id'),
      body: jsonEncode(req),
    );
    if (result.statusCode == 200) {
      snackerBarShow("Updated");
      return Future(() => setState(() {}));
    } else {
      snackerBarShow("Error");
    }
  }

  Future<void> _updateName(String id, String name) async {
    var req = {"name": name};
    var result = await http.patch(
      Uri.parse('$backendUrl/$id'),
      body: jsonEncode(req),
    );
    if (result.statusCode == 200) {
      snackerBarShow("Updated");
      return Future(() => setState(() {}));
    } else {
      snackerBarShow("Error");
    }
  }

  Future<void> _deleteTodo(String id) async {
    var result = await http.delete(
      Uri.parse('$backendUrl/$id'),
    );
    if (result.statusCode == 200) {
      snackerBarShow("Deleted");
      return Future(() => setState(() {}));
    } else {
      snackerBarShow("Error");
    }
  }

  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Todo List"),
      ),
      body: FutureBuilder(
        future: _fetchTodos(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Todo> data = snapshot.data as List<Todo>;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: IconButton(
                    icon: Icon(
                      data[index].completed
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    onPressed: () {
                      _updateTodo(data[index].id, data[index].completed);
                    },
                  ),
                  title: GestureDetector(
                    onTap: () {
                      nameController.text = data[index].name;
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            constraints: const BoxConstraints(
                              maxWidth: 400,
                              maxHeight: 250,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(
                                      'Update Title',
                                      style: TextStyle(fontSize: 24),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    width: 200,
                                    child: TextField(
                                      controller: nameController,
                                      autofocus: true,
                                      maxLines: 3,
                                      maxLength: 200,
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                        Colors.purple.shade100,
                                      ),
                                    ),
                                    onPressed: () {
                                      _updateName(
                                        data[index].id,
                                        nameController.text,
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const SizedBox(
                                      width: 200,
                                      child: Text(
                                        "Submit",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      data[index].name,
                      style: data[index].completed
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                            )
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteTodo(data[index].id);
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                constraints:
                    const BoxConstraints(maxWidth: 400, maxHeight: 250),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Title',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        width: 200,
                        child: TextField(
                          controller: nameController,
                          autofocus: true,
                          maxLines: 3,
                          maxLength: 200,
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                            Colors.purple.shade100,
                          ),
                        ),
                        onPressed: () {
                          _addTodo(nameController.text);
                          Navigator.pop(context);
                        },
                        child: const SizedBox(
                          width: 200,
                          child: Text(
                            "Submit",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
