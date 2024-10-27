import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'BaseLanguage.dart';
import 'LanguageAf.dart';
import 'LanguageAr.dart';
import 'LanguageEn.dart';
import 'LanguageFr.dart';
import 'LanguageHi.dart';
import 'LanguagePt.dart';
import 'LanguageTr.dart';

class AppLocalizations extends LocalizationsDelegate<BaseLanguage> {
  const AppLocalizations();

  @override
  Future<BaseLanguage> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'hi':
        return LanguageHi();
      case 'ar':
        return LanguageAr();
      case 'fr':
        return LanguageFr();
      case 'tr':
        return LanguageTr();
      case 'pt':
        return LanguagePt();
      case 'af':
        return LanguageAf();
      default:
        return LanguageEn();
    }
  }

  @override
  bool isSupported(Locale locale) => LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
}
