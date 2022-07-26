import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zad_almumin/classes/zikr_data.dart';
import 'package:zad_almumin/moduls/enums.dart';

import '../pages/ayahsTest/classes/ayah_prop.dart';
import '../pages/ayahsTest/controller/ayahs_questions_ctr.dart';

class JsonService {
  static List allQuranData = [];
  static List allHadithData = [];
  static List allZikrDataList = [];
  static List allAllahNamesList = [];
  JsonService() {
    loadQuranData();
    loadHadithData();
    loadZikrData();
    loadAllahNamesData();
  }
  static loadQuranData() async {
    if (allQuranData.isNotEmpty) return;
    String jsonString = await rootBundle.loadString('assets/database/quran/allQuran.json');
    allQuranData = json.decode(jsonString);
  }

  static loadHadithData() async {
    if (allHadithData.isNotEmpty) return;
    String jsonString = await rootBundle.loadString('assets/database/hadith/allHadith.json');
    allHadithData = json.decode(jsonString);
  }

  static loadZikrData() async {
    if (allZikrDataList.isNotEmpty) return;
    String jsonString = await rootBundle.loadString('assets/database/azkar/allazkar.json');
    Map data = json.decode(jsonString);
    allZikrDataList = data['allAzkar'];
  }

  static loadAllahNamesData() async {
    if (allAllahNamesList.isNotEmpty) return;
    String jsonString = await rootBundle.loadString('assets/database/azkar/allahNames.json');
    dynamic data = jsonDecode(jsonString);
    allAllahNamesList = data['list'];
  }

  static Future<ZikrData> getRandomQuranAyah() async {
    if (allQuranData.isEmpty)
      await loadQuranData();
    else
      await Future.delayed(Duration(milliseconds: 300));

    int randomSure = Random().nextInt(114) + 1;

    Map<String, dynamic> surahData = allQuranData[randomSure - 1];

    List<dynamic> allSureAyahs = surahData['ayahs'];
    int randomAyah = Random().nextInt(allSureAyahs.length);
    ZikrData zikrData = ZikrData(
      zikrType: ZikrType.quran,
      title: 'اعوذ بالله من الشيطان الرجيم',
      content: allSureAyahs[randomAyah]['text'],
      ayahNumber: allSureAyahs[randomAyah]['numberInSurah'],
      surahNumber: randomSure,
    );
    return zikrData;
  }

  static Future<ZikrData> getSpesificQuranAyah({required int ayahNumber, required int surahNumber}) async {
    Map<String, dynamic> surahData = allQuranData[surahNumber - 1];

    List<dynamic> allSureAyahs = surahData['ayahs'];
    for (var i = 0; i < allSureAyahs.length; i++) {
      if (allSureAyahs[i]['numberInSurah'] == ayahNumber + 1) {
        return ZikrData(
          zikrType: ZikrType.quran,
          title: 'اعوذ بالله من الشيطان الرجيم',
          content: allSureAyahs[i]['text'],
          ayahNumber: allSureAyahs[i]['numberInSurah'],
          surahNumber: surahNumber,
          isRandomAyah: false,
        );
      }
    }
    return await getRandomQuranAyah();
  }

  static Future<AyahProp> getAyahForQuestion(BuildContext context) async {
    final AyahsQuestionsCtr ctr = Get.find<AyahsQuestionsCtr>();

    String jsonString =
        await DefaultAssetBundle.of(context).loadString('assets/database/quran/first_ayahs_from_each_page.json');

    List juzs = json.decode(jsonString);

    int randomJuz = ctr.juzFrom.value - 1;
    if (ctr.juzTo.value != ctr.juzFrom.value)
      randomJuz = Random().nextInt(ctr.juzTo.value - ctr.juzFrom.value) + ctr.juzFrom.value;

    int randomPage = ctr.pageFrom.value - 1;
    if (ctr.pageTo.value != ctr.pageFrom.value)
      randomPage = Random().nextInt(ctr.pageTo.value - ctr.pageFrom.value) + ctr.pageFrom.value;

    AyahProp selectedAyah = AyahProp.fromJson(juzs[randomJuz][randomPage]);
    return selectedAyah;
  }

  static Future<Map> getAllQuranData(int surahNUmber) async {
    if (allQuranData.isEmpty) await loadQuranData();
    return allQuranData[surahNUmber - 1];
  }

  static Future<Map> getAllHadithData(int bookNumber) async {
    if (allHadithData.isEmpty) await loadHadithData();
    return allHadithData[bookNumber - 1];
  }

  static Future<ZikrData> getHadithData() async {
    if (allHadithData.isEmpty)
      await loadHadithData();
    else
      await Future.delayed(Duration(milliseconds: 200));

    int randomBook = Random().nextInt(20) + 1;
    Map<String, dynamic> hadithBookData = allHadithData[randomBook - 1];
    List<dynamic> hadithChaptarsMap = hadithBookData['chaptars'];

    int randomChapter = Random().nextInt(hadithChaptarsMap.length);
    List hadithsMap = hadithChaptarsMap[randomChapter]['hadiths'];
    if (hadithsMap.isEmpty) return await getHadithData();

    int randomHadith = Random().nextInt(hadithsMap.length);
    return ZikrData(zikrType: ZikrType.hadith, title: 'حديث عن رسول الله ﷺ', content: hadithsMap[randomHadith]['text']);
  }

  static Future<List<ZikrData>> getAzkarData({required int zikrIndexInJson}) async {
    if (allZikrDataList.isEmpty) await loadZikrData();

    List<ZikrData> zikrDataList = [];

    List<dynamic> azkarList = allZikrDataList[zikrIndexInJson]['azkarList'];
    for (int i = 0; i < azkarList.length; i++) {
      zikrDataList.add(ZikrData(
        zikrType: ZikrType.azkar,
        title: azkarList[i]['title'] ?? "",
        content: azkarList[i]['zekr'] ?? "",
        count: (azkarList[i]['count'] == '' || azkarList[i]['count'] == null) ? 1 : int.parse(azkarList[i]['count']),
        description: azkarList[i]['description'] ?? "",
        haveList: azkarList[i]['haveList'] ?? false,
        list: azkarList[i]['list'] ?? [],
      ));
    }
    return zikrDataList;
  }

  static Future<String> getRandomZikr() async {
    if (allZikrDataList.isEmpty) await loadZikrData();

    int randomZikrIndex = Random().nextInt(allZikrDataList.length);

    List<dynamic> azkarList = allZikrDataList[randomZikrIndex]['azkarList'];
    int randomAzkarIndex = Random().nextInt(azkarList.length);
    String zikr = azkarList[randomAzkarIndex]['zekr'];

    return zikr;
  }

  static Future<List<ZikrData>> getAllahNames() async {
    if (allAllahNamesList.isEmpty) await loadAllahNamesData();

    List<ZikrData> allahNamesList = [];
    for (var i = 0; i < allAllahNamesList.length; i++) {
      allahNamesList.add(
        ZikrData(
          zikrType: ZikrType.allahNames,
          title: allAllahNamesList[i]['name'],
          content: allAllahNamesList[i]['content'],
        ),
      );
    }
    return allahNamesList;
  }
}
