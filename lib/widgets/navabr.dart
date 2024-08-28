

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:work_zone/pages/signin.dart';
import 'package:work_zone/widgets/colors.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: null,
            accountEmail: null,
            currentAccountPicture: SvgPicture.asset('lib/assets/img/logo/logo-light.svg'),
            decoration: BoxDecoration(
              color: white,
            ),
          ),
          ListTile(
            leading: Icon(MdiIcons.storeEdit),
            title: Text(
              'Login',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => SignInScreen());
            },
          ),

        ],
      ),
    );
  }
}
