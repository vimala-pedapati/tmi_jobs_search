import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:formz/formz.dart';
import 'package:tmi_jobs_search/models_ui.dart';


part 'signin_event.dart';
part 'signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc({
    required AuthenticationRepositary authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const SignInState()) {
    on<SignInUsernameChanged>(_onUsernameChanged);
    on<SignInOtpChanged>(_onOTPChanged);
    on<SignInUsernameSubmitted>(_onUsernameSubmitted);
    on<SignInStartOtpExpiryTimer>(_onSignInStartOtpExpiryTimer);
    on<SignInOtpExpiryTime>(_onSignInOtpExpiryTime);
    on<SignInCancelOtpExpiryTimer>(_onSignInCancelOtpExpiryTimer);
    on<SignInOtpSubmitted>(_onOtpSubmitted);
    on<SignInBackFromOtpPage>(_onSignInBackFromOtpPage);
    on<SignInStartDisableOtpExpiryTimer>(_onSignInStartDisableOtpExpiryTimer);
    on<SignInDisableOtpExpiryTime>(_onSignInDisableOtpExpiryTime);
  }

  final AuthenticationRepositary _authenticationRepository;

  void _onUsernameChanged(
    SignInUsernameChanged event,
    Emitter<SignInState> emit,
  ) {
    final username = UsernameValue.dirty(EmailMobile(email: event.email, mobile: event.mobile));
    emit(state.copyWith(
      username: username,
      authFlowResponse: const AuthFlowResponse.authNotInitiated(),
      status: Formz.validate([username]) ? FormzSubmissionStatus.success : FormzSubmissionStatus.failure,
    ));
  }

  void _onSignInBackFromOtpPage(
      SignInBackFromOtpPage event,
      Emitter<SignInState> emit,
      ) {
    emit(state.copyWith(
      authFlowResponse: const AuthFlowResponse.authNotInitiated()),
    );
  }

  void _onOTPChanged(
    SignInOtpChanged event,
    Emitter<SignInState> emit,
  ) {
    final otp = OtpValue.dirty(event.otp);
    emit(state.copyWith(
      otp: otp,
      status: Formz.validate([otp]) ? FormzSubmissionStatus.success : FormzSubmissionStatus.failure,
    ));
  }

  Timer? _otpTimer;
  int _duration = 0;
  int _disableDuration = 0;

  Future<void> _onSignInStartOtpExpiryTimer(
      SignInStartOtpExpiryTimer event,
      Emitter<SignInState> emit,
      ) async {
      cancelOtpTimer();
      _duration = int.parse(dotenv.get('SIGNIN_OTP_EXPIRY_TIME'));
      emit(state.copyWith(otpExpiryTime: _duration));
      _otpTimer =  Timer.periodic(
        const Duration(seconds: 1),
            (Timer timer) {
          if (_duration == 0) {
            cancelOtpTimer();
          } else {
            _duration--;
            add(SignInOtpExpiryTime(duration: _duration));
          }
        },
      );
  }

  Future<void> _onSignInStartDisableOtpExpiryTimer(
      SignInStartDisableOtpExpiryTimer event,
      Emitter<SignInState> emit,
      ) async {
    cancelOtpTimer();
    _disableDuration = (DateTime.fromMillisecondsSinceEpoch(event.duration * 1000).difference(DateTime.now())).inSeconds;
    emit(state.copyWith(disableOtpTimer: _disableDuration));
    _otpTimer =  Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        if (_disableDuration == 0) {
          cancelOtpTimer();
        } else {
          _disableDuration--;
          add(SignInDisableOtpExpiryTime(duration: _disableDuration));
        }
      },
    );
  }

  void _onSignInOtpExpiryTime(
      SignInOtpExpiryTime event,
      Emitter<SignInState> emit,
      ) {
    emit(state.copyWith(otpExpiryTime: event.duration));
    if(event.duration == 0) {
      emit(state.copyWith(notifyUser: true, authFlowResponse: const AuthFlowResponse.invalidSession()));
    }
  }

  void _onSignInDisableOtpExpiryTime(
      SignInDisableOtpExpiryTime event,
      Emitter<SignInState> emit,
      ) {
    emit(state.copyWith(disableOtpTimer: event.duration));
    if(event.duration == 0) {
      emit(state.copyWith(notifyUser: false, authFlowResponse: const AuthFlowResponse.authNotInitiated()));
    }
  }

  void _onSignInCancelOtpExpiryTimer(
      SignInCancelOtpExpiryTimer event,
      Emitter<SignInState> emit) {
    cancelOtpTimer();
  }

  void cancelOtpTimer(){
    if(_otpTimer !=null && _otpTimer!.isActive){
      _otpTimer!.cancel();
      _otpTimer = null;
    }
  }

  void _onUsernameSubmitted(
    SignInUsernameSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    if (state.username!.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        String username = "";
        if(state.username!.value.mobile.isNotEmpty) {
          username = '+91${state.username!.value.mobile}';
        }
        if(state.username!.value.email.isNotEmpty) {
          username = state.username!.value.email;
        }

        final response = await _authenticationRepository.getLoginOtp(
          username: username,
        );
        emit(state.copyWith(
            authFlowResponse: response,
            notifyUser: true,
            username: state.username,
            status: (response.runtimeType  == const AuthFlowResponse.otpRequestSucceeded().runtimeType)
                ? (Formz.validate([state.otp]) ? FormzSubmissionStatus.success : FormzSubmissionStatus.failure)
                : (Formz.validate([state.username!]) ? FormzSubmissionStatus.success : FormzSubmissionStatus.failure)));
      } catch (_) {
        emit(state.copyWith(
            authFlowResponse: const AuthFlowResponse.unknownError(), notifyUser: true));
      }
    }
  }

  void _onOtpSubmitted(
    SignInOtpSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    if (state.otp.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      cancelOtpTimer();
      try {
        final response = await _authenticationRepository.logInWithOTP(
          otp: state.otp.value,
        );
        emit(state.copyWith(
            authFlowResponse: response,
            notifyUser: response.isNotEqual(const AuthFlowResponse.signinSucceeded()),
            status:(response.runtimeType  == const AuthFlowResponse.signinSucceeded().runtimeType)
                ? FormzSubmissionStatus.success
                : FormzSubmissionStatus.failure));
      } catch (_) {
        emit(state.copyWith(
            authFlowResponse: const AuthFlowResponse.unknownError(), notifyUser: true));
      }
    }
  }
}
