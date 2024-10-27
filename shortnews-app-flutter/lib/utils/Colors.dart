import 'package:flutter/material.dart';
import '../utils/Constants.dart';

const colorPrimary = Color(0xFF262B40);

const scaffoldColorDark = Color(0xFF090909);
const scaffoldSecondaryDark = Color(0xFF1E1E1E);
const appButtonColorDark = Color(0xFF282828);

Color getNewsStatusBgColor(String? status) {
  if (status == NewsStatusPublished) {
    return Colors.green;
  } else if (status == NewsStatusUnpublished) {
    return Colors.red;
  } else {
    return Colors.grey;
  }
}
