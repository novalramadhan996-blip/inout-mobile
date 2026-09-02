class ResponseBoard {
  String? projectBoardId;
  String? projectBoardTitle;

  ResponseBoard({
    this.projectBoardId,
    this.projectBoardTitle,
  });

  factory ResponseBoard.fromJson(Map<String, dynamic> json) { 
    return ResponseBoard(
        projectBoardId: json['project_board_id'],
        projectBoardTitle: json['title'],
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_board_id': projectBoardId,
      'title': projectBoardTitle,
    };
  }
}