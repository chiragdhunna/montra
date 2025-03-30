String errorMessage(String error) {
  final errMessage = error.replaceFirst('Exception: ', '');
  return errMessage;
}
