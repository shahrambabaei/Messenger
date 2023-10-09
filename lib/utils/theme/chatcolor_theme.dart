import 'package:flutter/material.dart';

class ChatColorPalette {
  static const black = Color(0xff11131E);
  static const black1 = Color(0xff181A27);
  static const black2 = Color(0xff282B40);
  static const black3 = Color(0xff0A0C17);

  static const blue = Color(0xff282B40);
  static const blue1 = Color(0xff222733);
  static const blue2 = Color(0xff0C2960);
  static const blue3 = Color(0xff326BD4);

  static const white = Color(0xffFFFFFF);
  static const white1 = Color(0xffE3E3E9);
  static const white2 = Color(0xff474A5E); // Color(0xff868AA4);
  static const white3 = Color(0xff474A5E);

  static const grey = Color(0xffF2F6F8);
  static const greyDrawer = Color(0xffeaeaea);
  static const grey1 = Color(0xffF9F9FE);
  static const grey2 = Color(0xffe5e5e5);
  static const gray3 = Colors.grey;

  static const yellow = Color(0xffFF9D00);
  static const yellow1 = Color(0xffFFD500);
  static const green = Color(0xff57E888);
  static const green1 = Color(0xff31FFC0);
  static const red = Color(0xffF84125);
  static const darkBlue = Color(0xff39478b);
}

extension ChatExtensionColorPalette on BuildContext {
  Color chatColorPick({required  Color light,required Color dark}) {
    return (Theme.of(this).brightness == Brightness.light) ? light : dark;
  }
}
