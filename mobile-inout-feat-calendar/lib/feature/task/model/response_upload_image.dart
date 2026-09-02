class ResponseUploadImage {
  String? fileName;
  String? mimeType;
  int? fileSize;
  String? imageUrl;

  ResponseUploadImage({
    this.fileName,
    this.mimeType,
    this.fileSize,
    this.imageUrl,
  });

  factory ResponseUploadImage.fromJson(Map<String, dynamic> json) { 
    return ResponseUploadImage(
        fileName: json['filename'],
        mimeType: json['mimetype'],
        fileSize: json['filesize'],
        imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': fileName,
      'mimetype': mimeType,
      'filesize': fileSize,
      'image_url': imageUrl,
    };
  }
}