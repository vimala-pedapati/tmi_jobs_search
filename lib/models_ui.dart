import 'package:email_validator/email_validator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:formz/formz.dart';

enum UsernameValidationError { empty, invalid }

bool isValidEmail(String? value) {
  return EmailValidator.validate(value ?? '');
}

bool isValidIndianPhoneNumber(String? value) {
  RegExp indianPhoneNumberExp = RegExp(r"^[6-9]\d{9}$");
  return indianPhoneNumberExp.hasMatch(value ?? '');
}

bool hasValidFirstDigitForIndianPhoneNumber(String value) {
  return value.isNotEmpty && RegExp(r"^[6-9]$").hasMatch(value[0]);
}

class UsernameValue extends FormzInput<EmailMobile, UsernameValidationError> {
  const UsernameValue.pure() : super.pure(const EmailMobile(email: "", mobile: ""));
  UsernameValue.dirty([EmailMobile? emailMobile]) : super.dirty(emailMobile!);

  @override
  UsernameValidationError? validator(EmailMobile? value) {
    if (value!.email.isEmpty && value.mobile.isEmpty) {
      return UsernameValidationError.empty;
    } else {
      if(value.email.isNotEmpty){
        if (!isValidEmail(value.email)){
          return UsernameValidationError.invalid;
        }
        return null;
      }
      if(value.mobile.isNotEmpty){
        if (!isValidIndianPhoneNumber(value.mobile)){
          if (!hasValidFirstDigitForIndianPhoneNumber(value.mobile)) {
            return UsernameValidationError.invalid;
          }
          else {
            return UsernameValidationError.empty;
          }
        }
        return null;
      }
    }
    return null;
  }
}

enum OtpValidationError { empty, invalid }

class OtpValue extends FormzInput<String, OtpValidationError> {
  const OtpValue.pure() : super.pure('');
  const OtpValue.dirty([String value = '']) : super.dirty(value);

  @override
  OtpValidationError? validator(String? value) {
    if (value?.isEmpty == true) {
      return OtpValidationError.empty;
    } else {
      // RegExp otpExp = RegExp("^\\d{${dotenv.get('SIGNIN_OTP_LENGTH')}}\$");
      RegExp otpExp = RegExp("^\\d{${6}}\$");
      return !otpExp.hasMatch(value!) ? OtpValidationError.invalid : null;
    }
  }
}

class EmailMobile{
  final String mobile;
  final String email;

  const EmailMobile({required this.email, required this.mobile});
}