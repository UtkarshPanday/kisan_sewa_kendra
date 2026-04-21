import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kisan_sewa_kendra/generated/assets.dart';

import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
import '../controller/constants.dart';
import '../controller/pref.dart';
import '../controller/routers.dart';
import '../model/product_model.dart';
import '../shopify/shopify.dart';
import '../view/cart_view.dart';
import '../view/home_view.dart';
import '../view/product_view.dart';
import 'cart_icon.dart';
import 'network_image.dart';
import 'widget_button.dart';
import 'search_delegate.dart';

class KskAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String? title, share, subTitle;
  final Widget? filter;

  const KskAppbar({
    super.key,
    this.title,
    this.share,
    this.subTitle,
    this.filter,
  });

  @override
  State<KskAppbar> createState() => _KskAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(125);
}

class _KskAppbarState extends State<KskAppbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: false,
        toolbarHeight: 75,
        leadingWidth: 60,
        titleSpacing: 0,
        leading: Builder(
          builder: (context) => IconButton(
            padding: const EdgeInsets.only(left: 12),
            constraints: const BoxConstraints(),
            icon:
                Icon(Icons.menu_rounded, color: Constants.baseColor, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          "assets/logo-removebg-preview.png",
          height: 60,
          fit: BoxFit.contain,
        ),
        actions: [
          if (Constants.languageList.isNotEmpty && widget.title == null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PopupMenuButton<String>(
                icon: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Constants.baseColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Constants.baseColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language_rounded,
                          size: 16, color: Constants.baseColor),
                      const SizedBox(width: 4),
                      Text(
                        Constants.lang.toUpperCase(),
                        style: TextStyle(
                            color: Constants.baseColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                onSelected: (String code) async {
                  Constants.languageController.setLocale(code);
                  Constants.lang = code;
                },
                itemBuilder: (context) => Constants.languageList.map((lang) {
                  return PopupMenuItem<String>(
                    value: lang.iso,
                    child: Text(lang.name),
                  );
                }).toList(),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: KskCartIcon(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: WidgetButton(
              onTap: () => showSearch(
                  context: context, delegate: CustomSearchDelegate()),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: Colors.grey[500], size: 20),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.searchProducts,
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
