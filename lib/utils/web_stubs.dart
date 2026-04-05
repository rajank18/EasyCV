// Stub for dart:html - used on non-web platforms
// This prevents compilation errors on Android/iOS

class Blob {
  Blob(List bytes, String type);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  AnchorElement({String? href});
  void setAttribute(String name, String value) {}
  void click() {}
}
