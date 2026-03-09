// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Configs et API
import 'core/api/api_client.dart';

// Feature ViewModels and Views
import 'features/navigation/navigation_view_model.dart';
import 'features/beer/beer_view_model.dart';
import 'features/home/home_view_model.dart';
import 'features/profile/profile_view_model.dart';
import 'features/navigation/main_navigation_view.dart';
import 'features/profile/subscription/subscription_view.dart';
import 'features/beer/wishlist/wishlist_view_model.dart';
import 'features/beer/collection/collection_view_model.dart';
import 'features/scan/scan_view.dart';
import 'features/home/add_beer/add_beer_view_model.dart';

// Auth
import 'features/auth/auth_view_model.dart';
import 'features/auth/landing_view.dart';
import 'features/auth/login_view.dart';
import 'features/auth/register_view.dart';
import 'features/auth/forgot_password_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final authVM = AuthViewModel(apiClient);
  await authVM.loadSession();

  // Check backend availability at startup
  await apiClient.healthCheck();

  runApp(
    MultiProvider(
      providers: [
        // Basic instances
        Provider.value(value: apiClient),
        ChangeNotifierProvider.value(value: authVM),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),

        // Catalog
        ChangeNotifierProvider(
          create: (context) => BeerViewModel(context.read<ApiClient>()),
        ),

        // Collection
        ChangeNotifierProxyProvider<AuthViewModel, CollectionViewModel?>(
          create: (_) => null,
          update: (context, authVM, previous) {
            if (authVM.userId == null) return null;

            if (previous != null && previous.userId == authVM.userId) {
              return previous;
            }

            return CollectionViewModel(
              context.read<ApiClient>(),
              authVM.userId!,
              authVM.collectionId ?? 0,
            );
          },
        ),

        // Wishlist
        ChangeNotifierProxyProvider<AuthViewModel, WishlistViewModel?>(
          create: (_) => null,
          update: (context, authVM, previous) {
            if (authVM.userId == null) return null;

            if (previous != null && previous.wishlistId == authVM.wishlistId) {
              return previous;
            }

            return WishlistViewModel(
              context.read<ApiClient>(),
              authVM.wishlistId ?? 0,
            );
          },
        ),

        // Profile
        ChangeNotifierProxyProvider<AuthViewModel, ProfileViewModel?>(
          create: (_) => null,
          update: (context, authVM, _) {
            if (authVM.userId == null) return null;
            return ProfileViewModel(
              context.read<ApiClient>(),
              userId: authVM.userId!,
              collectionId: authVM.collectionId ?? 0,
              wishlistId: authVM.wishlistId ?? 0,
            );
          },
        ),

        ChangeNotifierProxyProvider<AuthViewModel, AddBeerViewModel?>(
          create: (_) => null,
          update: (context, authVM, previous) {
            if (authVM.userId == null) return null;
            // Keep the same instance if the ID hasn't changed
            if (previous != null && previous.userId == authVM.userId) {
              return previous;
            }
            return AddBeerViewModel(userId: authVM.userId!);
          },
        ),
      ],
      child: const BeerNotebookApp(),
    ),
  );
}

class BeerNotebookApp extends StatelessWidget {
  const BeerNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beernotebook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',

        // Global AppBar styling
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,

          // Bottom border for the AppBar
          shape: Border(
            bottom: BorderSide(
              color: Color.fromRGBO(243, 242, 247, 1),
              width: 1,
            ),
          ),

          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontFamily: 'Quicksand',
          ),
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
        ),
        useMaterial3: true,
      ),

      // Landing page logic
      initialRoute: '/',

      routes: {
        // Auth routes
        '/': (context) => const LandingView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/forgot-password': (context) => const ForgotPasswordView(),

        // Authenticated main navigation
        '/main': (context) => const MainNavigationView(),
        '/subscription': (context) => const SubscriptionView(),

        '/scan': (context) => const ScanView(),
      },
    );
  }
}
