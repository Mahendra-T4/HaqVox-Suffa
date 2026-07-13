import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haqvox/app/core/models/verification_params.dart';
import 'package:haqvox/app/core/widgets/app_shell.dart';
import 'package:haqvox/app/src/auth/view/forgot_password.dart';
import 'package:haqvox/app/src/auth/view/login.dart';
import 'package:haqvox/app/src/auth/view/otp/register_otp.dart';
import 'package:haqvox/app/src/auth/view/register.dart';
import 'package:haqvox/app/src/auth/view/setpassword.dart';
import 'package:haqvox/app/src/auth/view/verification.dart';
import 'package:haqvox/app/src/bottom_bar.dart';
import 'package:haqvox/app/src/eBook/models/ebook_details_params.dart';
import 'package:haqvox/app/src/eBook/view/book_detail.dart';
import 'package:haqvox/app/src/eBook/view/ebook_chapter_audio_view_new.dart';
import 'package:haqvox/app/src/editProfile/pages/edit_profile.dart';
import 'package:haqvox/app/src/home/models/ebook_params.dart';
import 'package:haqvox/app/src/home/view/eBook%20List/ebook_listview.dart';
import 'package:haqvox/app/src/home/view/home.dart';
import 'package:haqvox/app/src/info/view/faq_view.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/notifications/view/notifications.dart';
import 'package:haqvox/app/src/splash.dart';
import 'package:haqvox/app/src/subscription/view/subscription_plan_view.dart';
import 'package:haqvox/app/src/support/view/suffa_support.dart';
import 'package:haqvox/app/src/support/view/support_type_list.dart';
import 'package:haqvox/app/src/support/view/ticket_history_view.dart';

class Config {
  static final GoRouter router = GoRouter(
    initialLocation: Splash.routeName,
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AppShell(currentRoute: state.uri.path, child: child);
        },
        routes: [
          // Main app routes that should show mini player
          GoRoute(
            path: Home.routeName,
            name: Home.routeName,
            builder: (context, state) => const Home(),
          ),
          GoRoute(
            path: BottomBar.routeName,
            name: BottomBar.routeName,
            builder: (context, state) => const BottomBar(),
          ),
          GoRoute(
            path: MySpace.routeName,
            name: MySpace.routeName,
            builder: (context, state) => const MySpace(),
          ),
          GoRoute(
            path: FAQView.routeName,
            name: FAQView.routeName,
            builder: (context, state) => const FAQView(),
          ),
          GoRoute(
            path: SuffaSupport.routeName,
            name: SuffaSupport.routeName,
            builder: (context, state) => const SuffaSupport(),
          ),

          GoRoute(
            path: AllSupportList.routeName,
            name: AllSupportList.routeName,
            builder: (context, state) => const AllSupportList(),
          ),
          GoRoute(
            path: SubscriptionPlanView.routeName,
            name: SubscriptionPlanView.routeName,
            builder: (context, state) => const SubscriptionPlanView(),
          ),
          GoRoute(
            path: TicketHistoryView.routeName,
            name: TicketHistoryView.routeName,
            builder: (context, state) => const TicketHistoryView(),
          ),
          GoRoute(
            path: BookDetail.routeName,
            name: BookDetail.routeName,
            builder: (context, state) {
              final params = state.extra as EBooksDetailsParams;
              return BookDetail(params: params);
            },
          ),
          GoRoute(
            path: EBookChapterAudio.routeName,
            name: EBookChapterAudio.routeName,
            builder: (context, state) {
              final params = state.extra as AudioParams;
              return EBookChapterAudio(audioParams: params);
            },
          ),
          GoRoute(
            path: EBookListView.routeName,
            name: EBookListView.routeName,
            builder: (context, state) {
              final params = state.extra as EBookListParams;
              return EBookListView(eBookListParams: params);
            },
          ),
          GoRoute(
            path: Notifications.routeName,
            name: Notifications.routeName,
            builder: (context, state) => Notifications(),
          ),

          GoRoute(
            path: EditProfile.routeName,
            name: EditProfile.routeName,
            builder: (context, state) => EditProfile(),
          ),
          GoRoute(
            path: OfflineDownloads.routeName,
            name: OfflineDownloads.routeName,
            builder: (context, state) => const OfflineDownloads(),
          ),
        ],
      ),

      // Auth routes outside ShellRoute (no mini player)
      GoRoute(
        path: Splash.routeName,
        name: Splash.routeName,
        builder: (context, state) => const Splash(),
      ),
      GoRoute(
        path: Login.routeName,
        name: Login.routeName,
        builder: (context, state) => const Login(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RegisterVerification.routeName,
        name: RegisterVerification.routeName,
        builder: (context, state) {
          final params = state.extra as VerificationParams;
          return RegisterVerification(verificationParams: params);
        },
      ),
      GoRoute(
        path: Verification.routeName,
        name: Verification.routeName,
        builder: (context, state) {
          final params = state.extra as VerificationParams;
          return Verification(verificationParams: params);
        },
      ),
      GoRoute(
        path: ForgotPassword.routeName,
        name: ForgotPassword.routeName,
        builder: (context, state) => const ForgotPassword(),
      ),
      GoRoute(
        path: SetPassword.routeName,
        name: SetPassword.routeName,
        builder: (context, state) {
          final rKey = state.extra as String;
          return SetPassword(rKey: rKey);
        },
      ),
    ],
  );
}
