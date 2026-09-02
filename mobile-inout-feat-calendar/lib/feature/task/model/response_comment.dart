class ResponseComment {
  String? commentId;
  String? parentCommentId;
  String? module;
  String? moduleId;
  String? content;
  String? contentType;
  String? imageContent;
  String? status;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;

  ResponseComment({
    this.commentId,
    this.parentCommentId,
    this.module,
    this.moduleId,
    this.content,
    this.contentType,
    this.imageContent,
    this.status,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy
  });

  factory ResponseComment.fromJson(Map<String, dynamic> json) { 
    return ResponseComment(
        commentId: json['comment_id'],
        parentCommentId: json['parent_comment_id'],
        module: json['module'],
        moduleId: json['module_id'],
        content: json['content'],
        contentType: json['content_type'],
        status: json['status'],
        createdAt: json['created_at'],
        createdBy: json['created_by'],
        updatedAt: json['updated_at'],
        updatedBy: json['updated_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'parent_comment_id': parentCommentId,
      'module': module,
      'module_id': moduleId,
      'content': content,
      'content_type': contentType,
      'status': status,
      'created_at': createdAt,
      'created_by': createdBy,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
    };
  }
}