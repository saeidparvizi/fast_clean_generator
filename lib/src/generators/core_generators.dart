// lib/src/generators/core_generators.dart

class CoreGenerator {
  CoreGenerator._();

  static String generateFailure() {
    return '''
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
''';
  }

  static String generateServerException() {
    return '''
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
''';
  }

  static String generateUseCase() {
    return '''
import 'package:dartz/dartz.dart';
import '../exceptions/failure.dart';

abstract class BaseUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
''';
  }

  static String generateRepositoryExecutor() {
    return '''
import 'package:dartz/dartz.dart';
import '../exceptions/failure.dart';
import '../exceptions/server_exception.dart';

class RepositoryExecutor {
  Future<Either<Failure, T>> execute<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
''';
  }

  static String generateUtils() {
    return '''
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Utils {
  static void showMessage({required String message, bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
    );
  }
}
''';
  }

  static String generateApiProvider() {
    return '''
import 'package:get/get.dart';

// You can replace this with a real Dio implementation
class ApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://api.example.com';
    super.onInit();
  }
}
''';
  }

  static String generateApiHelper() {
    return '''
import '../exceptions/server_exception.dart';

class ApiHelper {
  Future<T> handleRequest<T>({
    required Future<dynamic> Function() request,
    required T Function(dynamic) onSuccess,
    required String debugLabel,
  }) async {
    try {
      final response = await request();
      if (response.status.hasError) {
        throw ServerException(response.statusText ?? 'Unknown Error');
      }
      return onSuccess(response.body);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
''';
  }

  static String generateAppInput() {
    return '''
import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;

  const AppInput({
    required this.controller,
    required this.labelText,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
    );
  }
}
''';
  }

  static String generateAppAppbar() {
    return '''
import 'package:flutter/material.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppAppbar({
    required this.title,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
''';
  }

  static String generateInitialAppRoutes() {
    return '''
part of 'app_pages.dart';

abstract class AppRoutes {
  static const unknown = '/unknown';
}
''';
  }

  static String generateInitialAppPages() {
    return '''
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static String get initialRoutes {
    return AppRoutes.unknown;
  }

  static List<GetPage> get pages => [
  ];
}
''';
  }
}
