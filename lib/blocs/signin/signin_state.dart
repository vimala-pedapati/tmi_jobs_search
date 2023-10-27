part of 'signin_bloc.dart';

class SignInState extends Equatable {
  const SignInState({
    this.status = FormzSubmissionStatus.initial,
    this.username = const UsernameValue.pure(),
    this.otp = const OtpValue.pure(),
    this.notifyUser = false,
    this.otpExpiryTime = 0,
    this.disableOtpTimer = 0,
    this.authFlowResponse = const AuthFlowResponse.authNotInitiated(),
  });

  final FormzSubmissionStatus status;
  final UsernameValue? username;
  final OtpValue otp;
  final bool notifyUser;
  final AuthFlowResponse authFlowResponse;
  final int otpExpiryTime;
  final int disableOtpTimer;

  SignInState copyWith({
    FormzSubmissionStatus? status,
    UsernameValue? username,
    OtpValue? otp,
    bool? notifyUser,
    int? otpExpiryTime,
    int? disableOtpTimer,
    AuthFlowResponse? authFlowResponse,
  }) {
    return SignInState(
      status: status ?? this.status,
      username: username ?? this.username,
      otp: otp ?? this.otp,
      notifyUser: notifyUser ?? false, // this needs to be reset everytime state changes
      otpExpiryTime: otpExpiryTime ?? this.otpExpiryTime,
      disableOtpTimer: disableOtpTimer ?? this.disableOtpTimer,
      authFlowResponse: authFlowResponse ?? this.authFlowResponse,
    );
  }

  @override
  List<Object> get props => [status, username!, otp, notifyUser, authFlowResponse, otpExpiryTime,disableOtpTimer];
}
