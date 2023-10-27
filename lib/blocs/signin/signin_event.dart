part of 'signin_bloc.dart';

abstract class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class SignInUsernameChanged extends SignInEvent {
  const SignInUsernameChanged(this.email, this.mobile);
  final String email;
  final String mobile;

  @override
  List<Object> get props => [email, mobile];
}

class SignInOtpChanged extends SignInEvent {
  const SignInOtpChanged(this.otp);

  final String otp;

  @override
  List<Object> get props => [otp];
}

class SignInUsernameSubmitted extends SignInEvent {
  const SignInUsernameSubmitted();
}

class SignInOtpSubmitted extends SignInEvent {
  const SignInOtpSubmitted();
}

class SignInBackFromOtpPage extends SignInEvent {
  const SignInBackFromOtpPage();
}

class SignInStartOtpExpiryTimer extends SignInEvent {
  const SignInStartOtpExpiryTimer();
}

class SignInCancelOtpExpiryTimer extends SignInEvent {}

class SignInOtpExpiryTime extends SignInEvent {
  final int duration;
  const SignInOtpExpiryTime({required this.duration});

  @override
  List<Object> get props => [duration];
}

class SignInStartDisableOtpExpiryTimer extends SignInEvent {
  final int duration;
  const SignInStartDisableOtpExpiryTimer({required this.duration});
}

//class SignInCancelOtpExpiryTimer extends SignInEvent {}

class SignInDisableOtpExpiryTime extends SignInEvent {
  final int duration;
  const SignInDisableOtpExpiryTime({required this.duration});

  @override
  List<Object> get props => [duration];
}
