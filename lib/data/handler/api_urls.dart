class ApiUrls {
  /// ***********************************************************************************
  /// *                                    APIS                                        *
  /// ***********************************************************************************
  static final String baseUrl = "https://6836a919664e72d28e418f57.mockapi.io/api/todo";
  static final String getTodoApi = "/todos";
  static final String postTodoApi = "/todos";
  static String deleteTodoApi({required String id}) => "/todos/$id";
  static String updateTodoApi({required String id}) => "/todos/$id";
}
