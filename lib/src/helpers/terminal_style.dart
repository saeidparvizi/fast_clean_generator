class TerminalStyle {
  TerminalStyle._();

  static const String reset = '\x1B[0m';
  static const String boldColor = '\x1B[1m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String cyan = '\x1B[36m';

  static String success(String msg) => '$green$msg$reset';
  static String error(String msg) => '$red$msg$reset';
  static String info(String msg) => '$cyan$msg$reset';
  static String warning(String msg) => '$yellow$msg$reset';
  static String bold(String msg) => '$boldColor$msg$reset';
}
