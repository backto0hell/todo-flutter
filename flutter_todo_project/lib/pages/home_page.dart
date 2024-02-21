import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userEdit = '';
  String _userToDo = '';
  List saveText = [];
  List<String> todoList = [];
  bool showOnlyCompleted = false;
  Set<int> completedTasks = {};

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('EEE, HH:mm');
    return formatter.format(now);
  }

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  Future<void> _loadTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('todoList');
    if (savedList != null) {
      setState(() {
        todoList = savedList;
      });
    }
  }

  Future<void> _saveTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todoList', todoList);
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      final task = todoList[index];
      if (task.contains('(completed)')) {
        // Если задача была выполнена, убираем метку
        todoList[index] = task.replaceAll('(completed)', '').trim();
      } else {
        // Иначе добавляем метку выполненности
        todoList[index] = '$task (completed)';
      }
      _saveTodoList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 36, 104),
        title: const Text(
          'Список делишек',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(showOnlyCompleted
                ? Icons.check_box
                : Icons.check_box_outline_blank),
            onPressed: () {
              setState(() {
                showOnlyCompleted = !showOnlyCompleted;
              });
            },
          )
        ],
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/img/BG.gif"),
            fit: BoxFit.cover,
          ),
        ),
        child: todoList.isEmpty
            ? const Center(
                child: Text(
                  'Нет запланированных задач',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            : ListView.builder(
                itemCount: todoList.length,
                itemBuilder: (BuildContext context, int index) {
                  final task = todoList[index];
                  final isCompleted = task.contains('(completed)');
                  if (showOnlyCompleted && !task.contains('(completed)')) {
                    return Container(); // Не отображаем невыполненные задачи
                  }
                  return Dismissible(
                    key: Key(todoList[index]),
                    child: Card(
                      child: ListTile(
                        title: Text(todoList[index]),
                        subtitle: Text(getCurrentDateTime(),
                            style: const TextStyle(color: Colors.grey)),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            icon: Icon(
                              isCompleted
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              toggleTaskCompletion(index);
                            },
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                setState(() {
                                  todoList.removeAt(index);
                                  completedTasks.remove(index);
                                  _saveTodoList();
                                });
                              } else if (value == 'edit') {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Редактировать задачу'),
                                        content: TextField(
                                          controller: TextEditingController(
                                              text: todoList[index]),
                                          onChanged: (String value) {
                                            _userEdit = value;
                                          },
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                {
                                                  if (_userEdit ==
                                                      todoList[index]) {
                                                    setState(() {
                                                      //todoList[index] = _userEdit;
                                                      _saveTodoList();
                                                      _userEdit = '';
                                                    });
                                                  } else if (_userEdit
                                                      .isNotEmpty) {
                                                    setState(() {
                                                      todoList[index] =
                                                          _userEdit;
                                                      _saveTodoList();
                                                      _userEdit = '';
                                                    });
                                                  }
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: const Text('Сохранить'))
                                        ],
                                      );
                                    });
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Редактировать'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text(
                                    'Удалить',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ];
                            },
                          )
                        ]),
                      ),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        todoList.removeAt(index);
                        _saveTodoList();
                      });
                    },
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Создать новое дело'),
                    content: TextField(
                      onChanged: (String value) {
                        _userToDo = value;
                      },
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            if (_userToDo.isNotEmpty) {
                              setState(() {
                                todoList.add(_userToDo);
                                _saveTodoList();
                                _userToDo = '';
                              });
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Пожалуйста, введите текст')));
                            }
                          },
                          child: const Text('Добавить'))
                    ],
                  );
                });
          },
          child: const Icon(
            Icons.add_box,
            color: Colors.grey,
          )),
    );
  }
}
