import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:message_app/widgets/custom_button.dart';
import '../constants/utils.dart';
import '../helper/firebase_provider.dart';
import 'package:message_app/constants/my_constants.dart';

class PhoneScreen extends StatefulWidget {
  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  PhoneNumber _phoneNumber = PhoneNumber(
      isoCode: WidgetsBinding.instance.window.locale.countryCode.toString());

  @override
  Widget build(BuildContext context) {
    final _isLoading =
        Provider.of<FirebaseProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
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
                            onPressed: () => verifyNumber(
                              _phoneNumber.phoneNumber,
                            ),
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
    return Container(
      decoration: BoxDecoration(
        border: Border(),
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
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
        keyboardType: TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        cursorColor: myConstants.themeColor,
        inputDecoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          hintText: "Phone number",
        ),
      ),
    );
  }

  Future<void> verifyNumber(phoneNumber) async {
    phoneNumber = phoneNumber;
    final ap = Provider.of<FirebaseProvider>(context, listen: false);

    try {
      ap.phoneVerify(context, phoneNumber);
    } catch (e) {
      showSnackBar(context, "Phone verify", e.toString(), ContentType.failure);
    }
  }
}
