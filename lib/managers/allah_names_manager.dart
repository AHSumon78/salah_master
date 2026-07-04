import 'dart:math';
import 'package:alarm/screens/commons/app_card.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';

class AllahNameItem {
  final String arabic;
  final String english;
  final String bangla;
  final String meaning; // এটি বাংলা অর্থ হিসেবে থাকবে
  final String englishMeaning; // 👈 নতুন যুক্ত করা হলো ইংরেজি অর্থের জন্য

  const AllahNameItem({
    required this.arabic,
    required this.english,
    required this.bangla,
    required this.meaning,
    required this.englishMeaning, // 👈
  });
}

class AllahNamesManager {
  // 🔥 গ্লোবাল নোটিফায়ার (হোম স্ক্রিন রিবিল্ড ছাড়া ডেটা চেঞ্জ করার জন্য)
  static final ValueNotifier<AllahNameItem> currentNameNotifier =
      ValueNotifier<AllahNameItem>(const AllahNameItem(
          arabic: "الله",
          english: "Allah",
          bangla: "আল্লাহ",
          meaning: "একমাত্র উপাস্য",
          englishMeaning: "The Only Deity"));

  // আল্লাহ তায়ালার নামের আংশিক তালিকা (কোড ছোট রাখার জন্য প্রধান কয়েকটি দেওয়া হলো, আপনি এখানে ৯৯টি নামই যোগ করতে পারবেন)
  static const List<AllahNameItem> _namesList = [
    AllahNameItem(
        arabic: "الرَّحْمَٰنُ",
        english: "Ar-Rahman",
        bangla: "আর-রহমান",
        meaning: "পরম দয়ালু / অত্যন্ত করুণাময়",
        englishMeaning: "The Most Gracious / The All-Beneficent"),
    AllahNameItem(
        arabic: "ٱلرَّحِيمُ",
        english: "Ar-Rahim",
        bangla: "আর-রহিম",
        meaning: "অত্যন্ত দয়ালু / ক্ষমাশীল",
        englishMeaning: "The Most Merciful / The Ever-Merciful"),
    AllahNameItem(
        arabic: "ٱلْمَلِكُ",
        english: "Al-Malik",
        bangla: "আল-মালিক",
        meaning: "রাজাধিরাজ / সর্বভৌম অধিপতি",
        englishMeaning: "The King / The Sovereign Lord"),
    AllahNameItem(
        arabic: "ٱلْقُدُّوسُ",
        english: "Al-Quddus",
        bangla: "আল-কুদ্দুস",
        meaning: "পরম পবিত্র",
        englishMeaning: "The Holy / The All-Pure"),
    AllahNameItem(
        arabic: "السَّلَامُ",
        english: "As-Salam",
        bangla: "আস-সালাম",
        meaning: "শান্তির উৎস / নিরাপত্তাদাতা",
        englishMeaning: "The Source of Peace / The Giver of Peace"),
    AllahNameItem(
        arabic: "ٱلْمُؤْمِنُ",
        english: "Al-Mu'min",
        bangla: "আল-মুমিন",
        meaning: "নিরাপত্তাদাতা / বিশ্বাস স্থাপনকারী",
        englishMeaning: "The Inspirer of Faith / The Giver of Security"),
    AllahNameItem(
        arabic: "ٱلْمُهَيْمِنُ",
        english: "Al-Muhaymin",
        bangla: "আল-মুহাইমিন",
        meaning: "রক্ষাকর্তা / তত্ত্বাবধায়ক",
        englishMeaning: "The Guardian / The Preserver"),
    AllahNameItem(
        arabic: "ٱلْعَزِيزُ",
        english: "Al-Aziz",
        bangla: "আল-আজিজ",
        meaning: "মহাপরাক্রমশালী / অপরাজেয়",
        englishMeaning: "The Almighty / The All-Mighty"),
    AllahNameItem(
        arabic: "الجَبَّارُ",
        english: "Al-Jabbar",
        bangla: "আল-জাব্বার",
        meaning: "প্রবল / অপরাজেয়",
        englishMeaning: "The Compeller / The Restorer"),
    AllahNameItem(
        arabic: "المُتَكَبِّرُ",
        english: "Al-Mutakabbir",
        bangla: "আল-মুতাকাব্বির",
        meaning: "সর্বোচ্চ মহিমান্বিত",
        englishMeaning: "The Supreme / The Majestic"),
    AllahNameItem(
        arabic: "ٱلْخَالِقُ",
        english: "Al-Khaliq",
        bangla: "আল-খালিক",
        meaning: "সৃষ্টিকর্তা",
        englishMeaning: "The Creator / The Planner"),
    AllahNameItem(
        arabic: "ٱلْبَارِئُ",
        english: "Al-Bari'",
        bangla: "আল-বারি",
        meaning: "উদ্ভাবক / সৃজনকারী",
        englishMeaning: "The Originator / The Maker"),
    AllahNameItem(
        arabic: "ٱلْمُصَوِّرُ",
        english: "Al-Musawwir",
        bangla: "আল-মুসাওয়ির",
        meaning: "রূপদাতা / আকৃতি দানকারী",
        englishMeaning: "The Fashioner / The Shaper"),
    AllahNameItem(
        arabic: "ٱلْغَفَّارُ",
        english: "Al-Ghaffar",
        bangla: "আল-গাফফার",
        meaning: "পরম ক্ষমাশীল",
        englishMeaning: "The All-Forgiving / The Forgiver"),
    AllahNameItem(
        arabic: "ٱلْقَهَّارُ",
        english: "Al-Qahhar",
        bangla: "আল-কাহহার",
        meaning: "পরাক্রমশালী / দমনকারী",
        englishMeaning: "The Subduer / The Ever-Dominant"),
    AllahNameItem(
        arabic: "ٱلْوَهَّابُ",
        english: "Al-Wahhab",
        bangla: "আল-ওয়াহহাব",
        meaning: "দাতা / অনুগ্রহকারী",
        englishMeaning: "The Giver of All / The Supreme Bestower"),
    AllahNameItem(
        arabic: "ٱلرَّزَّاقُ",
        english: "Ar-Razzaq",
        bangla: "আর-রাজ্জাক",
        meaning: "রিজিকদাতা",
        englishMeaning: "The Provider / The Sustainer"),
    AllahNameItem(
        arabic: "ٱلْفَتَّاحُ",
        english: "Al-Fattah",
        bangla: "আল-ফাত্তাহ",
        meaning: "বিজয়দাতা / উন্মোচনকারী",
        englishMeaning: "The Opener / The Judge"),
    AllahNameItem(
        arabic: "ٱلْعَلِيمُ",
        english: "Al-Alim",
        bangla: "আল-আলিম",
        meaning: "সর্বজ্ঞ",
        englishMeaning: "The All-Knowing / The Omniscient"),
    AllahNameItem(
        arabic: "ٱلْقَابِضُ",
        english: "Al-Qabid",
        bangla: "আল-কাবিদ",
        meaning: "সংকোচনকারী",
        englishMeaning: "The Restrainer / The Constrictor"),
    AllahNameItem(
        arabic: "ٱلْبَاسِطُ",
        english: "Al-Basit",
        bangla: "আল-বাসিত",
        meaning: "প্রসারণকারী",
        englishMeaning: "The Expander / The Munificent"),
    AllahNameItem(
        arabic: "ٱلْخَافِضُ",
        english: "Al-Khafid",
        bangla: "আল-খাফিদ",
        meaning: "নতকারী",
        englishMeaning: "The Abaser / The Humbler"),
    AllahNameItem(
        arabic: "ٱلرَّافِعُ",
        english: "Ar-Rafi",
        bangla: "আর-রাফি",
        meaning: "উন্নতকারী",
        englishMeaning: "The Exalter / The Elevator"),
    AllahNameItem(
        arabic: "ٱلْمُعِزُّ",
        english: "Al-Mu'izz",
        bangla: "আল-মুইজ",
        meaning: "সম্মানদাতা",
        englishMeaning: "The Giver of Honor / The Bestower of Glory"),
    AllahNameItem(
        arabic: "ٱلْمُذِلُّ",
        english: "Al-Mudhill",
        bangla: "আল-মুজিল",
        meaning: "অপমানকারী",
        englishMeaning: "The Giver of Dishonor / The Humiliator"),
    AllahNameItem(
        arabic: "ٱالسَّمِيعُ",
        english: "As-Sami",
        bangla: "আস-সামি",
        meaning: "সর্বশ্রোতা",
        englishMeaning: "The All-Hearing / The Ever-Listening"),
    AllahNameItem(
        arabic: "ٱل|ْبَصِيرُ",
        english: "Al-Basir",
        bangla: "আল-বাসির",
        meaning: "সর্বদ্রষ্টা",
        englishMeaning: "The All-Seeing / The All-Perceiving"),
    AllahNameItem(
        arabic: "ٱلْحَكَمُ",
        english: "Al-Hakam",
        bangla: "আল-হাকাম",
        meaning: "বিচারক",
        englishMeaning: "The Judge / The Arbitrator"),
    AllahNameItem(
        arabic: "ٱلْعَدْلُ",
        english: "Al-Adl",
        bangla: "আল-আদল",
        meaning: "ন্যায়পরায়ণ",
        englishMeaning: "The Utterly Just / The Equitable"),
    AllahNameItem(
        arabic: "ٱللَّطِيفُ",
        english: "Al-Latif",
        bangla: "আল-লাতিফ",
        meaning: "সূক্ষ্মদর্শী / কোমল",
        englishMeaning: "The Subtle One / The Most Gentle"),
    AllahNameItem(
        arabic: "ٱلْخَبِيرُ",
        english: "Al-Khabir",
        bangla: "আল-খবির",
        meaning: "সর্বজ্ঞাত",
        englishMeaning: "The All-Aware / The Well-Acquainted"),
    AllahNameItem(
        arabic: "ٱلْحَلِيمُ",
        english: "Al-Halim",
        bangla: "আল-হালিম",
        meaning: "সহনশীল / ধৈর্যশীল",
        englishMeaning: "The Forbearing / The Most Clement"),
    AllahNameItem(
        arabic: "ٱلْعَظِيمُ",
        english: "Al-Azim",
        bangla: "আল-আজিম",
        meaning: "মহান / অত্যুচ্চ",
        englishMeaning: "The Magnificent / The Infinite"),
    AllahNameItem(
        arabic: "ٱلْغَفُورُ",
        english: "Al-Ghafur",
        bangla: "আল-গাফুর",
        meaning: "পরম ক্ষমাশীল",
        englishMeaning: "The All-Forgiving / The Great Forgiver"),
    AllahNameItem(
        arabic: "ٱلشَّكُورُ",
        english: "Ash-Shakur",
        bangla: "আশ-শাকুর",
        meaning: "পুরস্কারদাতা / কৃতজ্ঞতা গ্রহণকারী",
        englishMeaning: "The Grateful / The Appreciative"),
    AllahNameItem(
        arabic: "ٱلْعَلِيُّ",
        english: "Al-Ali",
        bangla: "আল-আলি",
        meaning: "সর্বোচ্চ",
        englishMeaning: "The Most High / The Sublime"),
    AllahNameItem(
        arabic: "ٱلْكَبِيرُ",
        english: "Al-Kabir",
        bangla: "আল-কাবির",
        meaning: "মহান",
        englishMeaning: "The Most Great / The Grand"),
    AllahNameItem(
        arabic: "ٱلْحَفِيظُ",
        english: "Al-Hafiz",
        bangla: "আল-হাফিজ",
        meaning: "রক্ষক",
        englishMeaning: "The Preserver / The All-Protecting"),
    AllahNameItem(
        arabic: "ٱلْمُقِيتُ",
        english: "Al-Muqit",
        bangla: "আল-মুকিত",
        meaning: "পুষ্টিকারী / ক্ষমতাবান",
        englishMeaning: "The Sustainer / The Nourisher"),
    AllahNameItem(
        arabic: "ٱلْحَسِيبُ",
        english: "Al-Hasib",
        bangla: "আল-হাসিব",
        meaning: "হিসাব গ্রহণকারী",
        englishMeaning:
            "The Reckoner / The Sufficient Bringer of Accountability"),
    AllahNameItem(
        arabic: "ٱلْجَلِيلُ",
        english: "Al-Jalil",
        bangla: "আল-জলিল",
        meaning: "মহিমান্বিত",
        englishMeaning: "The Majestic / The Exalted"),
    AllahNameItem(
        arabic: "ٱلْكَرِيمُ",
        english: "Al-Karim",
        bangla: "আল-কারিম",
        meaning: "মহানুভব / দয়ালু",
        englishMeaning: "The Most Generous / The Bountiful"),
    AllahNameItem(
        arabic: "ٱلرَّقِيبُ",
        english: "Ar-Raqib",
        bangla: "আর-রাকিব",
        meaning: "পর্যবেক্ষক",
        englishMeaning: "The Watchful / The All-Observant"),
    AllahNameItem(
        arabic: "ٱلْمُجِيبُ",
        english: "Al-Mujib",
        bangla: "আল-মুজিব",
        meaning: "দোয়া কবুলকারী",
        englishMeaning: "The Responsive / The Answerer"),
    AllahNameItem(
        arabic: "ٱلْوَاسِعُ",
        english: "Al-Wasi",
        bangla: "আল-ওয়াসি",
        meaning: "সর্বব্যাপী",
        englishMeaning: "The All-Encompassing / The Boundless"),
    AllahNameItem(
        arabic: "ٱلْحَكِيمُ",
        english: "Al-Hakim",
        bangla: "আল-হাকিম",
        meaning: "পরম প্রজ্ঞাময়",
        englishMeaning: "The All-Wise / The Judicious"),
    AllahNameItem(
        arabic: "ٱلْوَدُودُ",
        english: "Al-Wadud",
        bangla: "আল-ওয়াদুদ",
        meaning: "প্রেমময়",
        englishMeaning: "The Loving One / The Most Affectionate"),
    AllahNameItem(
        arabic: "ٱلْمَجِيدُ",
        english: "Al-Majid",
        bangla: "আল-মাজিদ",
        meaning: "মহিমান্বিত / গৌরবময়",
        englishMeaning: "The All-Glorious / The Majestic"),
    AllahNameItem(
        arabic: "ٱلْبَاعِثُ",
        english: "Al-Ba'ith",
        bangla: "আল-বাইস",
        meaning: "পুনরুত্থানকারী",
        englishMeaning: "The Resurrector / The Awakener"),
    AllahNameItem(
        arabic: "ٱلشَّهِيدُ",
        english: "Ash-Shahid",
        bangla: "আশ-শাহিদ",
        meaning: "সাক্ষী",
        englishMeaning: "The Witness / The All-Testifying"),
    AllahNameItem(
        arabic: "ٱلْحَقُّ",
        english: "Al-Haqq",
        bangla: "আল-হক",
        meaning: "সত্য",
        englishMeaning: "The Absolute Truth / The Reality"),
    AllahNameItem(
        arabic: "ٱلْوَكِيلُ",
        english: "Al-Wakil",
        bangla: "আল-ওয়াকিল",
        meaning: "উকিল / কর্মভার অর্পণযোগ্য",
        englishMeaning: "The Trustee / The Dependable Advocate"),
    AllahNameItem(
        arabic: "ٱلْقَوِيُّ",
        english: "Al-Qawi",
        bangla: "আল-কাওয়ি",
        meaning: "মহাশক্তিশালী",
        englishMeaning: "The All-Strong / The Most Strong"),
    AllahNameItem(
        arabic: "ٱلْمَتِينُ",
        english: "Al-Matin",
        bangla: "আল-মাতিন",
        meaning: "দৃঢ় / অটল",
        englishMeaning: "The Firm / The Steadfast"),
    AllahNameItem(
        arabic: "ٱلْوَلِيُّ",
        english: "Al-Wali",
        bangla: "আল-ওয়ালি",
        meaning: "অভিভাবক / বন্ধু",
        englishMeaning: "The Protecting Associate / The Friendly Patron"),
    AllahNameItem(
        arabic: "ٱلْحَمِيدُ",
        english: "Al-Hamid",
        bangla: "আল-হামিদ",
        meaning: "প্রশংসিত",
        englishMeaning: "The All-Praiseworthy"),
    AllahNameItem(
        arabic: "ٱلْمُحْصِي",
        english: "Al-Muhsi",
        bangla: "আল-মুহসি",
        meaning: "গণনাকারী",
        englishMeaning: "The Appraiser / The Counter of All Items"),
    AllahNameItem(
        arabic: "ٱلْمُبْدِئُ",
        english: "Al-Mubdi",
        bangla: "আল-মুবদি",
        meaning: "সৃষ্টির সূচনাকারী",
        englishMeaning: "The Originator / The Initiator of All Creation"),
    AllahNameItem(
        arabic: "ٱلْمُعِيدُ",
        english: "Al-Mu'id",
        bangla: "আল-মুইদ",
        meaning: "পুনঃসৃষ্টিকারী",
        englishMeaning: "The Restorer / The Reinstator Who Brings Back All"),
    AllahNameItem(
        arabic: "ٱلْمُحْيِي",
        english: "Al-Muhyi",
        bangla: "আল-মুহয়ি",
        meaning: "জীবনদাতা",
        englishMeaning: "The Giver of Life"),
    AllahNameItem(
        arabic: "ٱلْمُمِيتُ",
        english: "Al-Mumit",
        bangla: "আল-মুমিত",
        meaning: "মৃত্যুদাতা",
        englishMeaning: "The Bringer of Death / The Destroyer"),
    AllahNameItem(
        arabic: "ٱلْحَيُّ",
        english: "Al-Hayy",
        bangla: "আল-হাইয়্যু",
        meaning: "চিরঞ্জীব",
        englishMeaning: "The Ever-Living"),
    AllahNameItem(
        arabic: "ٱلْقَيُّومُ",
        english: "Al-Qayyum",
        bangla: "আল-কাইয়্যুম",
        meaning: "স্বয়ংস্থিত / সবকিছুর ধারক",
        englishMeaning: "The Sustainer of All / The Self-Subsisting"),
    AllahNameItem(
        arabic: "ٱلْوَاجِدُ",
        english: "Al-Wajid",
        bangla: "আল-ওয়াজিদ",
        meaning: "অনুসন্ধানকারী / প্রাপ্ত",
        englishMeaning: "The Perceiver / The Finder"),
    AllahNameItem(
        arabic: "ٱلْمَاجِدُ",
        english: "Al-Majid",
        bangla: "আল-মাজিদ",
        meaning: "গৌরবময়",
        englishMeaning: "The Illustrious / The Magnificent"),
    AllahNameItem(
        arabic: "ٱلْوَاحِدُ",
        english: "Al-Wahid",
        bangla: "আল-ওয়াহিদ",
        meaning: "একক / অদ্বিতীয়",
        englishMeaning: "The One / The All-Inclusive One"),
    AllahNameItem(
        arabic: "ٱلْأَحَدُ",
        english: "Al-Ahad",
        bangla: "আল-আহাদ",
        meaning: "এক / অদ্বিতীয়",
        englishMeaning: "The Unique / The Only One"),
    AllahNameItem(
        arabic: "ٱلصَّمَدُ",
        english: "As-Samad",
        bangla: "আস-সামাদ",
        meaning: "অনন্য আশ্রয়স্থল",
        englishMeaning: "The Eternal / The Absolute / The Self-Sufficient"),
    AllahNameItem(
        arabic: "ٱلْقَادِرُ",
        english: "Al-Qadir",
        bangla: "আল-কাদির",
        meaning: "সর্বশক্তিমান",
        englishMeaning: "The Capable / The Powerful"),
    AllahNameItem(
        arabic: "ٱلْمُقْتَدِرُ",
        english: "Al-Muqtadir",
        bangla: "আল-مুক্তাদির",
        meaning: "সর্বক্ষমতাবান",
        englishMeaning: "The Omnipotent / The Determiner"),
    AllahNameItem(
        arabic: "ٱلْمُقَدِّمُ",
        english: "Al-Muqaddim",
        bangla: "আল-মুকাদ্দিম",
        meaning: "অগ্রবর্তীকারী",
        englishMeaning: "The Expediter / He Who Brings Forward"),
    AllahNameItem(
        arabic: "ٱلْمُؤَخِّرُ",
        english: "Al-Mu'akhkhir",
        bangla: "আল-মুয়াখখির",
        meaning: "পশ্চাদবর্তীকারী",
        englishMeaning: "The Delayer / He Who Puts Back"),
    AllahNameItem(
        arabic: "الأَوَّلُ",
        english: "Al-Awwal",
        bangla: "আল-আউয়াল",
        meaning: "প্রথম",
        englishMeaning: "The First"),
    AllahNameItem(
        arabic: "ٱلْآخِرُ",
        english: "Al-Akhir",
        bangla: "আল-আখির",
        meaning: "শেষ",
        englishMeaning: "The Last"),
    AllahNameItem(
        arabic: "ٱلظَّاهِرُ",
        english: "Az-Zahir",
        bangla: "আজ-জাহির",
        meaning: "প্রকাশ্য",
        englishMeaning: "The Manifest / The Evident"),
    AllahNameItem(
        arabic: "ٱلْبَاطِنُ",
        english: "Al-Batin",
        bangla: "আল-বাতিন",
        meaning: "গোপন / অদৃশ্য",
        englishMeaning: "The Hidden / The Unmanifest"),
    AllahNameItem(
        arabic: "ٱلْوَالِي",
        english: "Al-Wali",
        bangla: "আল-ওয়ালি",
        meaning: "শাসক / অভিভাবক",
        englishMeaning: "The Governor / The Ruling Patron"),
    AllahNameItem(
        arabic: "المُتَعَالِي",
        english: "Al-Muta'ali",
        bangla: "আল-মুতাআলি",
        meaning: "সর্বোচ্চ",
        englishMeaning: "The Supreme Exalted / The Most High"),
    AllahNameItem(
        arabic: "ٱلْبَرُّ",
        english: "Al-Barr",
        bangla: "আল-বার্র",
        meaning: "কল্যাণময়",
        englishMeaning: "The Source of All Goodness / The Beneficent"),
    AllahNameItem(
        arabic: "ٱلتَّوَّابُ",
        english: "At-Tawwab",
        bangla: "আত-তাওয়াব",
        meaning: "তওবা কবুলকারী",
        englishMeaning: "The Ever-Returning / The Acceptor of Repentance"),
    AllahNameItem(
        arabic: "ٱلْمُنْتَقِمُ",
        english: "Al-Muntaqim",
        bangla: "আল-মুনতাকিম",
        meaning: "প্রতিशोध গ্রহণকারী",
        englishMeaning: "The Avenger"),
    AllahNameItem(
        arabic: "ٱلْعَفُوُّ",
        english: "Al-Afuw",
        bangla: "আল-আফু",
        meaning: "ক্ষমাকারী",
        englishMeaning: "The Pardoner / The Effacer of Sins"),
    AllahNameItem(
        arabic: "ٱلرَّءُوفُ",
        english: "Ar-Ra'uf",
        bangla: "আর-রাউফ",
        meaning: "দয়ালু / স্নেহশীল",
        englishMeaning: "The Most Kind / The Ever-Compassionate"),
    AllahNameItem(
        arabic: "مَالِكُ ٱلْمُلْكِ",
        english: "Malik al-Mulk",
        bangla: "মালিকুল মুলক",
        meaning: "সাম্রাজ্যের অধিপতি",
        englishMeaning:
            "The Owner of All Sovereignty / The King of Absolute Sovereignty"),
    AllahNameItem(
        arabic: "ذُو ٱلْجَلَالِ وَٱلْإِكْرَامِ",
        english: "Dhul-Jalali wal-Ikram",
        bangla: "জুল জালালি ওয়াল ইকরাম",
        meaning: "মহিমা ও সম্মানের অধিকারী",
        englishMeaning: "The Lord of Majesty and Generosity"),
    AllahNameItem(
        arabic: "ٱلْمُقْسِطُ",
        english: "Al-Muqsit",
        bangla: "আল-মুকসিত",
        meaning: "ন্যায়বিচারক",
        englishMeaning: "The Equitable / The Requiter of Justice"),
    AllahNameItem(
        arabic: "ٱلْجَامِعُ",
        english: "Al-Jami",
        bangla: "আল-জামি",
        meaning: "সমবেতকারী",
        englishMeaning: "The Gatherer / The Unifier"),
    AllahNameItem(
        arabic: "ٱلْغَنِيُّ",
        english: "Al-Ghani",
        bangla: "আল-গানি",
        meaning: "অভাবমুক্ত",
        englishMeaning: "The All-Rich / The Self-Sufficient"),
    AllahNameItem(
        arabic: "ٱلْمُغْنِي",
        english: "Al-Mughni",
        bangla: "আল-মুগনি",
        meaning: "সমৃদ্ধকারী",
        englishMeaning: "The Enricher / The Emancipator"),
    AllahNameItem(
        arabic: "ٱلْمَانِعُ",
        english: "Al-Mani",
        bangla: "আল-মানি",
        meaning: "বাধাদানকারী",
        englishMeaning: "The Withholder / The Defender"),
    AllahNameItem(
        arabic: "ٱلضَّارُّ",
        english: "Ad-Darr",
        bangla: "আদ-দার্র",
        meaning: "ক্ষতিকারক",
        englishMeaning: "The Distressor / The Correcting Creator"),
    AllahNameItem(
        arabic: "ٱلنَّافِعُ",
        english: "An-Nafi",
        bangla: "আন-নাফি",
        meaning: "উপকারক",
        englishMeaning: "The Propitious / The Benefactor"),
    AllahNameItem(
        arabic: "ٱلنُّورُ",
        english: "An-Nur",
        bangla: "আন-নুর",
        meaning: "আলো",
        englishMeaning: "The Light / The Illuminator"),
    AllahNameItem(
        arabic: "ٱلْهَادِي",
        english: "Al-Hadi",
        bangla: "আল-হাদি",
        meaning: "পথপ্রদর্শক",
        englishMeaning: "The Guide / The Giver of Guidance"),
    AllahNameItem(
        arabic: "ٱلْبَدِيعُ",
        english: "Al-Badi",
        bangla: "আল-বাদি",
        meaning: "অনন্য সৃষ্টিকর্তা",
        englishMeaning:
            "The Incomparable Originator / The Unprecedented Creator"),
    AllahNameItem(
        arabic: "ٱلْبَاقِي",
        english: "Al-Baqi",
        bangla: "আল-বাকি",
        meaning: "চিরস্থায়ী",
        englishMeaning: "The Everlasting / The Immutable"),
    AllahNameItem(
        arabic: "ٱلْوَارِثُ",
        english: "Al-Warith",
        bangla: "আল-ওয়ারিস",
        meaning: "উত্তরাধিকারী",
        englishMeaning: "The Ultimate Inheritor / The Heir of All"),
    AllahNameItem(
        arabic: "ٱلرَّشِيدُ",
        english: "Ar-Rashid",
        bangla: "আর-রাশিদ",
        meaning: "সঠিক পথপ্রদর্শক",
        englishMeaning: "The Righteous Guide / The Infallible Teacher"),
    AllahNameItem(
        arabic: "ٱلصَّبُورُ",
        english: "As-Sabur",
        bangla: "আস-সাবুর",
        meaning: "অত্যধিক ধৈর্যশীল",
        englishMeaning: "The Patient / The Forbearing"),
  ];

  // 🔄 প্রতিবার অ্যাপ ওপেন হলে বা বাটনে চাপ দিলে নাম পরিবর্তন করার মেথড
  static void generateRandomName() {
    final random = Random();
    int randomIndex = random.nextInt(_namesList.length);
    currentNameNotifier.value = _namesList[randomIndex];
  }

  // 🕋 ৩. চারকোনা বক্স উইজেট (UI) যা সরাসরি হোম স্ক্রিনের গ্রিডে বসবে
  static Widget buildAllahNamesGridTile(BuildContext context) {
    return ValueListenableBuilder<AllahNameItem>(
      valueListenable: currentNameNotifier,
      builder: (context, nameItem, child) {
        // 🌐 বর্তমান অ্যাপের ভাষা বাংলা কিনা চেক করা হচ্ছে
        final bool isBangla =
            Localizations.localeOf(context).languageCode == 'bn';

        // ভাষা অনুযায়ী উচ্চারণ এবং অর্থ ফিল্টার
        String pronunciationDisplay =
            isBangla ? nameItem.bangla : nameItem.english;
        String meaningDisplay =
            isBangla ? nameItem.meaning : nameItem.englishMeaning;

        return Material(
          color: Theme.of(context).cardBackground,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showAllNamesBottomSheet(
                context), // 🔥 ট্যাপ করলে ফুল লিস্ট ওপেন হবে
            splashColor: Colors.amber.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ১ম লাইন: টাইটেল আইকন ও ছোট নাম
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.auto_awesome_outlined,
                          color: Theme.of(context).iconColor),
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.topRight,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isBangla
                                ? "আল্লাহর নাম"
                                : "Name of Allah", // ডাইনামিক হেডার ট্যাগ
                            style: Theme.of(context).caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ২য় লাইন: বড় করে আরবি হরফে পবিত্র নাম
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        nameItem.arabic,
                        style: Theme.of(context).time.copyWith(
                              fontSize: 30,
                            ),
                      ),
                    ),
                  ),

                  // ৩য় লাইন: ডাইনামিক নাম এবং তার অর্থ
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pronunciationDisplay, // বাংলা অথবা ইংরেজি উচ্চারণ
                        style: Theme.of(context).title.copyWith(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        meaningDisplay, // বাংলা অথবা ইংরেজি অর্থ
                        style: Theme.of(context).caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🕋 🔥 নতুন যুক্ত করা হলো: চেপে ধরে রাখলে ৯৯টি নামের ২-কলামের প্রিমিয়াম গ্রিডভিউ বটমশিট
  static void _showAllNamesBottomSheet(BuildContext context) {
    // বটমশিট ওপেন হওয়ার সময়ও ল্যাঙ্গুয়েজ চেক করা হচ্ছে
    final bool isBangla = Localizations.localeOf(context).languageCode == 'bn';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).appBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75),
          padding: const EdgeInsets.all(
              12.0), // সামান্য প্যাডিং বাড়ানো হলো সুন্দর দেখানোর জন্য
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // হেডার সেকশন
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Theme.of(context).iconColor),
                      const SizedBox(width: 12),
                      Text(
                        isBangla
                            ? "আল্লাহর ৯৯টি পবিত্র নাম"
                            : "99 Names of Allah", // ডাইনামিক টাইটেল
                        style: Theme.of(context).title.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).iconColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: Theme.of(context).iconColor, height: 20),

              // 🗓️ ২-কলামের পিওর মিনিমাল স্কয়ার গ্রিড ভিউ
              Expanded(
                child: GridView.builder(
                  itemCount: _namesList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4,
                  ),
                  itemBuilder: (context, index) {
                    final item = _namesList[index];
                    final serialNum = index + 1;

                    // গ্রিড আইটেমের ভেতরের ডাইনামিক ল্যাঙ্গুয়েজ ফিল্টারিং
                    String itemPronunciation =
                        isBangla ? item.bangla : item.english;
                    String itemMeaning =
                        isBangla ? item.meaning : item.englishMeaning;

                    return AppCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // সিরিয়াল নাম্বার এবং ডান কোনায় মহিমান্বিত আরবী নাম
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .iconColor
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                      "#${serialNum.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                          color: Theme.of(context).iconColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  child: FittedBox(
                                    alignment: Alignment.centerRight,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      item.arabic,
                                      style: TextStyle(
                                        color: Theme.of(context).arabicColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            // নিচে ডাইনামিক উচ্চারণ এবং ছোট অক্ষরে তার অর্থ
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemPronunciation, // ল্যাঙ্গুয়েজ অনুযায়ী উচ্চারণ
                                  style: Theme.of(context).title.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  itemMeaning, // ল্যাঙ্গুয়েজ অনুযায়ী অর্থ
                                  style: Theme.of(context)
                                      .caption
                                      .copyWith(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
