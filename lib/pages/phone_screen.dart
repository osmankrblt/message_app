import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:message_app/widgets/custom_button.dart';
import '../constants/utils.dart';
import '../helper/auth_provider.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:libphonenumber/libphonenumber.dart';

class PhoneScreen extends StatefulWidget {
  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  PhoneNumber _phoneNumber = PhoneNumber(
      isoCode: WidgetsBinding.instance.window.locale.countryCode.toString());
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final _isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: myConstants.themeColor,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 5.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 250,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            "assets/image2.png",
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        getPhoneInput(),
                        const SizedBox(
                          height: 27.0,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: myConstants.customButtonHeight,
                          child: CustomButton(
                            text: "Login",
                            onPressed: () async {
                              if (await checkInternetStatus()) {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  verifyNumber(
                                    _phoneNumber,
                                  );
                                }
                              } else {
                                showToast("No internet for verify number");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget getPhoneInput() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          border: Border(),
          borderRadius: BorderRadius.circular(
            20,
          ),
        ),
        child: InternationalPhoneNumberInput(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              showToast("Phone number length  musn't be empty");
              return "";
            } else if (value.length < 10) {
              showToast("Phone number  length must be at least 10 characters ");
              return "";
            }
            return null;
          },
          onInputChanged: (PhoneNumber number) {},
          onSaved: (PhoneNumber number) {
            _phoneNumber = number;
          },
          selectorConfig: SelectorConfig(
            showFlags: true,
            leadingPadding: 25,
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          ),
          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.disabled,
          selectorTextStyle: TextStyle(
            color: Colors.black,
          ),
          initialValue: _phoneNumber,
          maxLength: 14,
          scrollPadding: EdgeInsets.all(
            15,
          ),
          formatInput: true,
          keyboardType: TextInputType.phone,
          cursorColor: myConstants.themeColor,
          inputDecoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            hintText: "Phone number",
          ),
        ),
      ),
    );
  }

  Future<void> verifyNumber(PhoneNumber phoneNumber) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    try {
      bool? isValid = await PhoneNumberUtil.isValidPhoneNumber(
          phoneNumber: phoneNumber.phoneNumber!, isoCode: phoneNumber.isoCode!);
      if (isValid!) {
        ap.phoneVerify(context, phoneNumber.phoneNumber!);
      } else {
        showToast("Phone number is not valid");
      }
    } catch (e) {
      showToast(
        "Phone verify",
      );
    }
  }
}
