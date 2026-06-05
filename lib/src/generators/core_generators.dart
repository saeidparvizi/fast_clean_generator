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
import '../exceptions/failure.dart'; import '../exceptions/server_exception.dart';

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

class ApiProvider {
  final GetConnect _connect;

  ApiProvider() : _connect = GetConnect() {
    _connect.httpClient.baseUrl = 'https://api.example.com';
    _connect.httpClient.timeout = const Duration(seconds: 30);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) =>
      _connect.get(path, query: data, headers: headers);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) =>
      _connect.post(path, data, headers: headers);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) =>
      _connect.put(path, data, headers: headers);

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) =>
      _connect.delete(path, query: data, headers: headers);
}
''';
  }

  static String generateApiHelper() {
    return '''
import 'package:get/get.dart';
import '../exceptions/server_exception.dart';

class ApiHelper {
  Future<T> handleRequest<T>({
    required Future<Response> Function() request,
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

  static String generateDioProvider() {
    return '''
import 'package:dio/dio.dart';

class ApiProvider {
  final Dio dio;

  ApiProvider()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.example.com',
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) =>
      dio.get(path, queryParameters: data, options: Options(headers: headers));

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) =>
      dio.post(path, data: data, options: Options(headers: headers));

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) =>
      dio.put(path, data: data, options: Options(headers: headers));

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) =>
      dio.delete(path, queryParameters: data, options: Options(headers: headers));
}
''';
  }

  static String generateDioHelper() {
    return '''
import 'package:dio/dio.dart';
import '../exceptions/server_exception.dart';

class ApiHelper {
  Future<T> handleRequest<T>({
    required Future<Response> Function() request,
    required T Function(dynamic) onSuccess,
    required String debugLabel,
  }) async {
    try {
      final response = await request();
      return onSuccess(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network Error');
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
  final Widget? leading;
  final bool centerTitle;

  const AppAppbar({
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
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

  static String get initialRoute {
    return AppRoutes.unknown;
  }

  static List<GetPage> get pages => [
  ];
}
''';
  }

  static String generateMainDart() {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/translations/app_translations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Clean Arch',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
''';
  }

  static String generateAppTranslations() {
    return '''
import 'package:get/get.dart';
import 'en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
      };
}
''';
  }

  static String generateEnUs() {
    return '''
const Map<String, String> enUs = {
  'app_title': 'Flutter Clean Arch',
  'success': 'Success',
  'error': 'Error',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'submit': 'Submit',
};
''';
  }

  static String generateAppColors() {
    return '''
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF6200EE);
  static const primaryVariant = Color(0xFF3700B3);
  static const secondary = Color(0xFF03DAC6);
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const error = Color(0xFFB00020);
  
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF757575);
}
''';
  }

  static String generateAppTheme() {
    return '''
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
  );
}
''';
  }
}
