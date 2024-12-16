import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PhonepePayment extends StatefulWidget {
  const PhonepePayment({super.key});

  @override
  State<PhonepePayment> createState() => _PhonepePaymentState();
}

class _PhonepePaymentState extends State<PhonepePayment> {
  String environment = "SANDBOX";
  String appId = "";
  String merchantId = "PGTESTPAYUAT86"; //;
  bool enableLogging = true;
  String checkSum = "";
  String saltKey = "96434309-7796-489d-8924-ab56988a6076";
  String saltIndex = "1";
  String callBackUrl = "";

  String apiEndPoint = "/pg/v1/pay";

  String body = "";

  Object? result;

  @override
  void initState() {
    // TODO: implement initState

    phonepeInit();
    body = getCheckSum().toString();
    super.initState();
  }

  void phonepeInit() async {
    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((value) {
      setState(() {});
    }).catchError((error) {
      handleError(error);
    });
  }

  handleError(error) {
    setState(() {
      result = {'error': error};
    });
  }

  void startTransaction() {
    PhonePePaymentSdk.startTransaction(body, callBackUrl, checkSum, "")
        .then((response) => {
              setState(() {
                if (response != null) {
                  String status = response['status'].toString();
                  String error = response['error'].toString();
                  if (status == 'SUCCESS') {
                    result = "Flow Completed - Status: Success!";
                  } else {
                    result =
                        "Flow Completed - Status: $status and Error: $error";
                  }
                } else {
                  result = "Flow Incomplete";
                }
              })
            })
        .catchError((error) {
      // handleError(error)
      return <dynamic>{};
    });
  }

  getCheckSum() {
    final body = {
      "merchantId": merchantId,
      "merchantTransactionId": "MT7850590068188104",
      "merchantUserId": "MUID123",
      "amount": 10000 * 100,
      "callbackUrl": "https://webhook.site/callback-url",
      "mobileNumber": "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };

    var base64body = base64.encode(utf8.encode(json.encode(body)));

    checkSum =
        '${sha256.convert(utf8.encode(base64body + apiEndPoint + saltKey)).toString()}###$saltIndex';

    return base64body;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: () {
                  startTransaction();
                }, child: Text('Start Transaction')),
              ),
            ),
            Text('Result /n $result')
          ],
        ),
      ),
    );
  }
}
