import 'package:mobile_app/features/authentication/data/models/log_in_model.dart';
import 'package:mobile_app/features/authentication/data/models/sign_up_model.dart';
import 'package:mobile_app/features/authentication/domain/entities/business_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/login_entity.dart';

extension LogInMapper on LoginEntity {
  LogInModel toProductModel() {
    return LogInModel(email: email, password: password);
  }
}

extension BusinessSignUpMapper on BusinessSignupEntity {
  BusinessSignUpModel toBusinessSignUpModel() {
    return BusinessSignUpModel(
      firstName: firstName,
      lastName: lastName,
      businessName: businessName,
      businessEmail: businessEmail,
      businessPhone: businessPhone,
      businessDescription: businessDescription,
      companyWebsite: companyWebsite,
      preferredLanguage: preferredLanguage,
      socialMediaLinks: socialMediaLinks,
      password: password,
      phoneNumber: phoneNumber,
      selectedRole: selectedRole,
      servicesRequired: servicesRequired,
    );
  }
}
