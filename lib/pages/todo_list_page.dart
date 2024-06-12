
import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import 'package:todo_list/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {

  //Controlador para o campo de texto
  final TextEditingController todoController = TextEditingController();
  
  //Instancia do repositorio de tarefas
  final TodoRepository todoRepository = TodoRepository();

  //Lista de tarefas
  List<Todo> todos = [];

  //Variáveis para armazenar a tarefa deletada e sua posição
  Todo? deleteTodo;
  int? deletedTodoPos;

  // Texto de erro para o campo de texto
  String? errorText;

  @override
  void initState() {
    super.initState();


    // Carrega a lista de tarefas do repositório
    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Adicionar uma tarefa',
                          hintText: 'Ex. Estudar Flutter',
                          errorText: errorText,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(33, 101, 248, 1)
                            )
                          )
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Botão de adicionar tarefa
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;

                        //Verifica se o texto está vazio
                        if(text.isEmpty){
                          setState(() {
                           errorText = 'O titulo não pode ser vazio!';
                          });
                          return;
                        }

                        //Adiciona a nova tarefa à lista
                        setState(() {
                          Todo newTodo = Todo(
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          todos.add(newTodo);
                          errorText = null;
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos); //salva a lista no repositorio
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(33, 101, 248, 1),
                        padding: EdgeInsets.all(20),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Contagem de tarefas pendentes e botão para deletar todas
                Row(
                  children: [
                    Expanded(
                      child:
                          Text("Você possui ${todos.length} tarefas pendentes"),
                    ),
                    SizedBox(width: 8),
                    // botão de deletar tudo
                    ElevatedButton(
                      onPressed: showDeleteTodosConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 33, 101, 248),
                          padding: EdgeInsets.all(20)),
                      child: Text(
                        'Limpar tudo',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Função chamada ao deletar uma tarefa

  void onDelete(Todo todo) {
    deleteTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });

    todoRepository.saveTodoList(todos);

    // Mostra uma SnackBar para desfazer a exclusão
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Tarefa ${todo.title} foi removido com sucesso!',
          style: TextStyle(color: Colors.red)),
      backgroundColor: Colors.white,
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: const Color(0xff060708),
        onPressed: (() {
          setState(() {
            todos.insert(deletedTodoPos!, deleteTodo!);
          }); 
          todoRepository.saveTodoList(todos);
        }
        ),
      ),
      duration: const Duration(seconds: 5),
    ),
    );
  }

  // Mostra um diálogo de confirmação para deletar todas as tarefas
  void showDeleteTodosConfirmationDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Limpar Tudo?'),
              content:
                  Text('Você tem certeza que deseja apagar todas as tarefas?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(foregroundColor:Color.fromRGBO(33, 101, 248, 1)),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteAllToos();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text('Limpar tudo')
                ),
              ],
            )
          );
        }

     // Função para deletar todas as tarefas
    void deleteAllToos(){
      setState(() {
        todos.clear();
      });

      todoRepository.saveTodoList(todos);
    }

  } 
