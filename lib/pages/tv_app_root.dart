import 'package:crocott_dart/auth.dart';
import 'package:dart_common/dart_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/app_config.dart';
import 'package:turtleott/base/websocket/online_subscribers_bloc/online_subscribers_bloc.dart';
import 'package:turtleott/base/websocket/websocket_api_bloc/websocket_api_bloc.dart';
import 'package:turtleott/constants.dart';
import 'package:turtleott/fetcher.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/debug_page.dart';
import 'package:turtleott/pages/home/home_page.dart';
import 'package:turtleott/pages/login/app_root_bloc.dart';
import 'package:turtleott/pages/login/login_fields.dart';
import 'package:turtleott/pages/profile.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/extension.dart';
import 'package:turtleott/utils/terms_privacy.dart';

class TVAppRoot extends StatefulWidget {
  const TVAppRoot();

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<TVAppRoot> {
  late AppBloc _bloc;
  bool isLoginCode = false;
  final FocusNode _policyButton = FocusNode();
  final FocusNode _termsButton = FocusNode();
  final FocusNode _languageButton = FocusNode();

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    final stabledHost = settings.server() ?? SERVER_HOST;
        final crocott = CrocOTTImpl(
        host: stabledHost,
        onTokenChanged: (Tokens token) {
          _bloc.login(token);
        },
        onNeedHelp: () {
          _bloc.logout();
        });
    final fetcher = Fetcher(impl: crocott);
    _bloc = AppBloc(fetcher: fetcher);
    _bloc.hostController.text = stabledHost;
    if (canAutoConnect()) {
      _bloc.connect(isLoginCode: isLoginCode, context: context);
    }
  }

  bool canAutoConnect() {
    final settings = locator<LocalStorageService>();
    final accessToken = settings.accessToken();
    final refreshToken = settings.refreshToken();
    final device = settings.device();
    return accessToken != null && refreshToken != null && device != null;
  }

  @override
  void dispose() {
    _bloc.dispose();
    _termsButton.dispose();
    _policyButton.dispose();
    _languageButton.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppState>(
        stream: _bloc.stream,
        builder: (ctx, snapshot) {
          return _root(ctx, snapshot.data);
        });
  }

  Widget _root(BuildContext context, AppState? state) {
    bool onNextPressed(AuthMode authMode) {
      if (authMode == AuthMode.signUp) {
        return _bloc.registerUser();
      }
      _bloc.connect(isLoginCode: authMode == AuthMode.codeLogin, context: context);
      return false;
    }

    if (state is AuthenticatedAppState) {
      final settings = locator<LocalStorageService>();
      settings.setDevice(state.device);
      settings.setServer(state.server);

      final profile = Profile(_bloc.fetcher, state.info);
      final mode = state.info.brand.mode;

      final info = profile.fetcher.wsEndpoint();

      context.read<WebSocketApiBloc>().connect(info);

      return AppConfig(
          buildType: AppConfig.of(context).buildType, wsMode: mode, child: HomeTV(profile));
    }

    Widget content;
    if (state is LoadingAppState) {
      content =
          SizedBox(height: MediaQuery.of(context).size.height, child: LoginLoading(state.text));
    } else if (state is ErrorAppState) {
      String text;
      if (state.error is IError) {
        text = (state.error as IError).error();
        if (state.error is ErrorHttp) {
          final errh = state.error;
          text = errh.reason!;
          if (errh.isErrorJson()) {
            text = context.errorBackendTextWithoutToken(errh.errorJson().code);
          }
        }
      } else if (state.error is ErrorUI) {
        final errui = state.error;
        if (errui.code == ErrorUI.kErrInvalidInputHost) {
          text = translate(context, TR_INVALID_INPUT);
        } else if (errui.code == ErrorUI.kErrInvalidInputCode) {
          text = translate(context, TR_INVALID_INPUT);
        } else if (errui.code == ErrorUI.kErrInvalidInputLoginOrPassword) {
          text = translate(context, TR_INVALID_INPUT);
        }
        text = translate(context, TR_INVALID_INPUT);
      } else {
        text = context.errorBackendTextWithoutToken(state.error);
      }
      content = _body(text);
    } else if (state is LogOutState) {
      context.read<RealtimeMessageBloc>().add(const InitialEvent());
      content = _body(null);
    } else {
      content = _body(null);
    }

    final device = locator<RuntimeDevice>();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: FractionallySizedBox(widthFactor: device.hasTouch ? 1.0 : 0.4, child: content)));
  }

  Widget _body(String? error) {
    final settings = locator<LocalStorageService>();
    final server = settings.server();
    bool onNextPressed(AuthMode authMode) {
      if (authMode == AuthMode.signUp) {
        return _bloc.registerUser();
      }
      _bloc.connect(isLoginCode: authMode == AuthMode.codeLogin, context: context);
      return false;
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Spacer(),
          LoginFields.needFocus(
              _bloc.firstNameController,
              _bloc.lastNameController,
              _bloc.emailController,
              _bloc.passwordController,
              _bloc.codeController,
              _bloc.hostController,
              onNextPressed,
              AppConfig.of(context).isDev,
              server,
              error),
          const Spacer(),
          TermsAndConditions(bloc: _bloc)
        ]);
  }
}

class LoginLoading extends StatelessWidget {
  final String state;

  const LoginLoading(this.state);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(),
      const SizedBox(height: 16),
      Text(translate(context, state))
    ]));
  }
}

class LoginFooter extends StatelessWidget {
  const LoginFooter();

  @override
  Widget build(BuildContext context) {
    return TextButtonTheme(
        data: TextButtonThemeData(
            style: Theme.of(context)
                .textButtonTheme
                .style!
                .copyWith(minimumSize: WidgetStateProperty.all<Size>(const Size(48, 48)))),
        child: const VersionTile.login());
  }
}
