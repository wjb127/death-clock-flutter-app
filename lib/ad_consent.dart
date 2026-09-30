import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<bool> prepareAds() async {
  final updated = Completer<void>();
  ConsentInformation.instance.requestConsentInfoUpdate(
    ConsentRequestParameters(),
    () => updated.complete(),
    (_) => updated.complete(),
  );
  await updated.future;
  await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
  if (!await ConsentInformation.instance.canRequestAds()) return false;
  await MobileAds.instance.initialize();
  return true;
}
