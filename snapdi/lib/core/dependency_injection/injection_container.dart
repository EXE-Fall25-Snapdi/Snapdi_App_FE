import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_info.dart';
import '../constants/app_constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features
  await _initAuth();
  await _initPhotographer();
  await _initBooking();
  await _initProfile();
  
  // Core
  await _initCore();
  
  // External
  await _initExternal();
}

// Auth Feature
Future<void> _initAuth() async {
  // TODO: Register auth-specific dependencies
  // Example:
  // sl.registerFactory(() => LoginUseCase(sl()));
  // sl.registerFactory(() => RegisterUseCase(sl()));
  // sl.registerFactory(() => AuthBloc(loginUseCase: sl(), registerUseCase: sl()));
  // sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
  //   remoteDataSource: sl(),
  //   localDataSource: sl(),
  //   networkInfo: sl(),
  // ));
  // sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: sl()));
  // sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sharedPreferences: sl()));
}

// Photographer Feature
Future<void> _initPhotographer() async {
  // TODO: Register photographer-specific dependencies
}

// Booking Feature
Future<void> _initBooking() async {
  // TODO: Register booking-specific dependencies
}

// Profile Feature
Future<void> _initProfile() async {
  // TODO: Register profile-specific dependencies
}

// Core
Future<void> _initCore() async {
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
}

// External
Future<void> _initExternal() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  sl.registerLazySingleton(() => Connectivity());
  
  sl.registerLazySingleton(() {
    final dio = Dio();
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = Duration(milliseconds: AppConstants.connectionTimeout);
    dio.options.receiveTimeout = Duration(milliseconds: AppConstants.receiveTimeout);
    
    // Add interceptors
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
    
    // Add auth interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to headers
        final prefs = sl<SharedPreferences>();
        final token = prefs.getString(AppConstants.authTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token refresh on 401
        if (error.response?.statusCode == 401) {
          // TODO: Implement token refresh logic
        }
        handler.next(error);
      },
    ));
    
    return dio;
  });
}