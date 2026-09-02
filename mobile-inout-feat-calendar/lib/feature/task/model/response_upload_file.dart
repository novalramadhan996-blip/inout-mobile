class ResponseUploadFile {
  String? fileName;
  String? mimeType;
  int? fileSize;
  String? url;

  ResponseUploadFile({
    this.fileName,
    this.mimeType,
    this.fileSize,
    this.url,
  });

  factory ResponseUploadFile.fromJson(Map<String, dynamic> json) { 
    return ResponseUploadFile(
        fileName: json['filename'],
        mimeType: json['mimetype'],
        fileSize: json['filesize'],
        url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': fileName,
      'mimetype': mimeType,
      'filesize': fileSize,
      'url': url,
    };
  }
}