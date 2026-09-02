class ResponseUploadModel {
  String? filename;
  String? mimetype;
  int? filesize;
  String? url;

  ResponseUploadModel({
    this.filename,
    this.mimetype,
    this.filesize,
    this.url,
  });

  factory ResponseUploadModel.fromJson(Map<String, dynamic> json) {
    return ResponseUploadModel(
      filename: json['filename'],
      mimetype: json['mimetype'],
      filesize: json['filesize'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'mimetype': mimetype,
      'filesize': filesize,
      'url': url,
    };
  }
}
