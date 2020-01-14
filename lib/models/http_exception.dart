class HttpException implements Exception{
  String error;
  HttpException(this.error);
  
  @override
  String toString() {
    return error;
  }
}