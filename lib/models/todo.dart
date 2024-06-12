class Todo {
  // Construtor nomeado que inicializa os campos `title` e `dateTime`
  Todo({required this.title, required this.dateTime});

  // Construtor nomeado que cria um objeto `Todo` a partir de um JSON
  Todo.fromJson(Map<String, dynamic> json)
    : title = json['title'], // Extrai o valor do título do JSON
      dateTime = DateTime.parse(json['datetime']); // Converte a string datetime para um objeto DateTime

  // Campos da classe `Todo`
  String title; // Título da tarefa
  DateTime dateTime; // Data e hora da tarefa

  // Método que converte um objeto `Todo` em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title, // Adiciona o título ao JSON
      'datetime': dateTime.toIso8601String(), // Converte DateTime para string no formato ISO 8601
    };
  }
}
