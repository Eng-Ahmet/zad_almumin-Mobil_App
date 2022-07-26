import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zad_almumin/constents/colors.dart';
import 'package:zad_almumin/constents/sizes.dart';
import 'package:zad_almumin/moduls/enums.dart';
import 'package:zad_almumin/services/theme_service.dart';
import '../../components/my_switch.dart';
import '../../constents/constents.dart';
import '../../constents/icons.dart';
import '../../constents/texts.dart';
import '../quran/components/menu_options_item.dart';
import 'classes/alarm_prop.dart';

class AlarmListTile extends GetView<ThemeCtr> {
  AlarmListTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.alarmProp,
    required this.onChanged,
    this.canChange = true,
  });

  String imagePath;
  String title;
  String subtitle;
  bool value;
  AlarmProp alarmProp;
  Function(bool) onChanged;
  bool canChange = true;
  GetStorage getStorage = GetStorage();

  @override
  Widget build(BuildContext context) {
    context.theme;

    List<MenuOptionsItem> menuItemList = [
      MenuOptionsItem(
        title: 'عالي  20 قأكثر يوميا',
        icon: Container(),
        onTap: () => alarmProp.zikrRepeat =ZikrRepeat.high,
        isSelected:alarmProp.zikrRepeat ==ZikrRepeat.high,
      ),
      MenuOptionsItem(
        title: 'متوسط  11-19  يوميا',
        icon: Container(),
        onTap: () => alarmProp.zikrRepeat =ZikrRepeat.normal,
        isSelected:alarmProp.zikrRepeat ==ZikrRepeat.normal,
      ),
      MenuOptionsItem(
        title: 'منخفض  5-10  يوميا',
        icon: Container(),
        onTap: () => alarmProp.zikrRepeat =ZikrRepeat.low,
        isSelected:alarmProp.zikrRepeat ==ZikrRepeat.low,
      ),
      MenuOptionsItem(
        title: 'نادر  1-5  يوميا',
        icon: Container(),
        onTap: () => alarmProp.zikrRepeat =ZikrRepeat.rare,
        isSelected:alarmProp.zikrRepeat ==ZikrRepeat.rare,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MySiezes.betweanAzkarBlock),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(child: Image.asset(imagePath, width: 50)),
          const SizedBox(width: 15),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTexts.settingsTitle(title: title),
                MyTexts.settingsContent(title: subtitle),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                alarmProp.notificationType == NotificationType.azkar ||
                        alarmProp.notificationType == NotificationType.hadith
                    ? PopupMenuButton<MenuOptionsItem>(
                        color: MyColors.background(),
                        icon: MyIcons.moreVert(),
                        onSelected: (value) {},
                        itemBuilder: (context) {
                          return [
                            ...menuItemList.map((e) => PopupMenuItem(
                                  value: e,
                                  textStyle: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 10),
                                  child: InkWell(
                                    onTap: () {
                                      for (var element in menuItemList) element.isSelected = false;
                                      e.isSelected = true;
                                      Get.back();
                                      e.onTap();
                                    },
                                    child: Container(
                                      color: e.isSelected ? MyColors.primary() : MyColors.background(),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          MyIcons.leftArrow(color: e.isSelected ? MyColors.background() : null),
                                          SizedBox(width: Get.width * .04),
                                          MyTexts.settingsTitle(
                                            title: e.title,
                                            size: 16,
                                            color: e.isSelected ? MyColors.background() : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ];
                        },
                      )
                    : IconButton(
                        onPressed: canChange
                            ? () async {
                                TimeOfDay? newTime = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      TimeOfDay(hour: alarmProp.time.value.hour, minute: alarmProp.time.value.minute),
                                  builder: (BuildContext context, Widget? child) => child!,
                                );
                                if (newTime == null) return;
                                alarmProp.time.value = Time(newTime.hour, newTime.minute);
                                getStorage.write(alarmProp.storageKey, jsonEncode(alarmProp.toJson()));
                                onChanged(true);
                              }
                            : () {
                                Get.dialog(
                                  AlertDialog(
                                    title: MyTexts.settingsTitle(title: 'غير مسموح'),
                                    content:
                                        MyTexts.settingsContent(title: 'لا يمكنك تغيير الاشعارات الخاصة بهذه الصلاة'),
                                    actions: [
                                      TextButton(
                                        child: MyTexts.settingsContent(title: 'حسنا'),
                                        onPressed: () {
                                          Get.back();
                                        },
                                      ),
                                    ],
                                  ),
                                  transitionDuration: Duration(milliseconds: 300),
                                  transitionCurve: Curves.easeInCirc,
                                );
                              },
                        icon: MyIcons.alarm,
                      ),
                alarmProp.notificationType == NotificationType.azkar ||
                        alarmProp.notificationType == NotificationType.hadith
                    ? Container()
                    : MyTexts.settingsContent(
                        title:
                            '${Constants.formatInt2.format(alarmProp.time.value.hour)}:${Constants.formatInt2.format(alarmProp.time.value.minute)}'),
              ],
            ),
          ),
          Expanded(child: MySwitch(value: value, onChanged: onChanged)),
        ],
      ),
    );
  }
}
