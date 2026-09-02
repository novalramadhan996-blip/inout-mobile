class RequestComment {
  String? module;
  String? moduleId;
  String? content;
  String? contentType;
  String? parentCommentId;

  RequestComment({
    this.module,
    this.moduleId,
    this.content,
    this.contentType,
    this.parentCommentId,
  });

  factory RequestComment.fromJson(Map<String, dynamic> json) {
    return RequestComment(
      module: json['module'],
      moduleId: json['module_id'],
      content: json['content'],
      contentType: json['content_type'],
      parentCommentId: json['parent_comment_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'module_id': moduleId,
      'content': content,
      'content_type': contentType,
      'parent_comment_id': parentCommentId,
    };
  }
}