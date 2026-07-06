import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/screens/commons/app_card.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';

// দোয়ার মডেল ক্লাস
class DuaItem {
  final String title;
  final String englishTitle; // 👈 নতুন
  final String arabic;
  final String pronunciation;
  final String englishPronunciation; // 👈 নতুন
  final String meaning;
  final String englishMeaning; // 👈 নতুন
  final String reference;
  final String englishReference; // 👈 নতুন

  const DuaItem({
    required this.title,
    required this.englishTitle,
    required this.arabic,
    required this.pronunciation,
    required this.englishPronunciation,
    required this.meaning,
    required this.englishMeaning,
    required this.reference,
    required this.englishReference,
  });
}

class DuaManager {
  // 📂 ১. ক্যাটাগরি এবং তার অধীনে থাকা প্রয়োজনীয় দোয়াগুলোর ডাটাবেজ/লিস্ট
  static const Map<String, List<DuaItem>> _duaCategories = {
    "necessary_dua": [
      DuaItem(
        title: "ঘুম থেকে ওঠার দোয়া",
        englishTitle: "Dua after waking up",
        arabic:
            "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
        pronunciation:
            "আলহামদু লিল্লাহিল্লাযী আহ ইয়ানা বা'দা মা আমাতানা ওয়া ইলাইহিন নুশূর।",
        englishPronunciation:
            "Alhamdu lillahil-lazhi ah-yana ba'da ma amatana wa ilaihin-nushur.",
        meaning:
            "সব প্রশংসা আল্লাহর জন্য, যিনি আমাদের মৃত্যুর (ঘুমের) পর জীবিত করলেন এবং তাঁর দিকেই আমাদের পুনরুত্থান।",
        englishMeaning:
            "All praise is due to Allah who gave us life after he caused us to die and unto Him is the resurrection.",
        reference: "সহীহ বুখারী: ৬৩২৪, সহীহ মুসলিম: ২৭১১",
        englishReference: "Sahih Bukhari: 6324, Sahih Muslim: 2711",
      ),
      DuaItem(
        title: "ঘুমানোর আগের দোয়া",
        englishTitle: "Dua before sleeping",
        arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
        pronunciation: "বিসমিকা আল্লাহুম্মা আমূতু ওয়া আহয়া।",
        englishPronunciation: "Bismika Allahumma amutu wa ahya.",
        meaning:
            "হে আল্লাহ! আপনারই নামে আমি মৃত্যুবরণ করছি (ঘুমাচ্ছি) এবং জীবিত (জাগ্রত) হবো।",
        englishMeaning: "In Your name, O Allah, I die and I live.",
        reference: "সহীহ বুখারী: ৬৩২৪, সহীহ মুসলিম: ২৭১১",
        englishReference: "Sahih Bukhari: 6324, Sahih Muslim: 2711",
      ),
      DuaItem(
        title: "ঘর থেকে বের হওয়ার দোয়া",
        englishTitle: "Dua when leaving the house",
        arabic:
            "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
        pronunciation:
            "বিসমিল্লাহি তাওয়াক্কালতু 'আলাল্লাহি লা হাওলা ওয়া লা কুওয়াতা ইল্লা বিল্লাহ।",
        englishPronunciation:
            "Bismillahi tawakkaltu 'alallahi la hawla wa la quwwata illa billah.",
        meaning:
            "আল্লাহর নামে বের হচ্ছি, আল্লাহর ওপর ভরসা করলাম। আল্লাহর সাহায্য ছাড়া গুনাহ থেকে বাঁচার এবং নেক কাজ করার কোনো শক্তি নেই।",
        englishMeaning:
            "In the name of Allah, I place my trust in Allah. There is no might nor power except with Allah.",
        reference: "সুনানে আবু দাউদ: ৫০৯৫, সুনানে তিরমিজী: ৩৪২৬ (সহীহ)",
        englishReference:
            "Sunan Abi Dawud: 5095, Sunan At-Tirmidhi: 3426 (Sahih)",
      ),
      DuaItem(
        title: "ঘরে প্রবেশ করার দোয়া",
        englishTitle: "Dua when entering the house",
        arabic:
            "بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا",
        pronunciation:
            "বিসমিল্লাহি ওয়ালাজনা, ওয়া বিসমিল্লাহি খারাজনা, ওয়া 'আলাল্লাহি রাব্বিনা তাওয়াক্কালনা।",
        englishPronunciation:
            "Bismillahi walajna, wa bismillahi kharajna, wa 'alaallahi rabbina tawakkalna.",
        meaning:
            "আমরা আল্লাহর নামে প্রবেশ করলাম, আল্লাহর নামেই বের হলাম এবং আমাদের রব আল্লাহর ওপরই ভরসা করলাম।",
        englishMeaning:
            "In the name of Allah we enter, in the name of Allah we leave, and upon our Lord we place our trust.",
        reference: "সুনানে আবু দাউদ: ৫০৯৬ (হাসান)",
        englishReference: "Sunan Abi Dawud: 5096 (Hasan)",
      ),
      DuaItem(
        title: "মসজিদে প্রবেশের দোয়া",
        englishTitle: "Dua when entering the mosque",
        arabic: "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
        pronunciation: "আল্লাহুম্মাফ তাহলী আবওয়াবা রাহমাতিক।",
        englishPronunciation: "Allahummaf-tah li abwaba rahmatik.",
        meaning: "হে আল্লাহ! আমার জন্য আপনার রহমতের দরজাগুলো খুলে দিন।",
        englishMeaning: "O Allah, open for me the gates of Your mercy.",
        reference: "সহীহ মুসলিম: ৭১৩, সুনানে আবু দাউদ: ৪৬৫",
        englishReference: "Sahih Muslim: 713, Sunan Abi Dawud: 465",
      ),
      DuaItem(
        title: "মসজিদ থেকে বের হওয়ার দোয়া",
        englishTitle: "Dua when leaving the mosque",
        arabic: "اللَّهُمَّ إِنِّই أَسْأَلُكَ مِنْ فَضْلِكَ",
        pronunciation: "আল্লাহুম্মা ইন্নী আসআলুকা মিন ফাদলিক।",
        englishPronunciation: "Allahumma inni as'aluka min fadlik.",
        meaning:
            "হে আল্লাহ! আমি আপনার কাছে আপনার অনুগ্রহ বা বরকত প্রার্থনা করছি।",
        englishMeaning: "O Allah, I ask You from Your favor.",
        reference: "সহীহ মুসলিম: ৭১৩, সুনানে আবু দাউদ: ৪৬৫",
        englishReference: "Sahih Muslim: 713, Sunan Abi Dawud: 465",
      ),
      DuaItem(
        title: "খাবার খাওয়ার শুরুর দোয়া",
        englishTitle: "Dua before eating meal",
        arabic: "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
        pronunciation: "বিসমিল্লাহির রাহমানির রাহীম।",
        englishPronunciation: "Bismillahir-Rahmanir-Rahim.",
        meaning: "পরম করুণাময় অসীম দয়ালু আল্লাহর নামে (শুরু করছি)।",
        englishMeaning:
            "In the name of Allah, the Most Gracious, the Most Merciful.",
        reference: "সহীহ বুখারী: ৫৩৭৬, সুনানে আবু দাউদ: ৩৭৬৭",
        englishReference: "Sahih Bukhari: 5376, Sunan Abi Dawud: 3767",
      ),
      DuaItem(
        title: "খাবার শুরুতে বিসমিল্লাহ বলতে ভুলে গেলে",
        englishTitle: "If you forgot to say Bismillah before eating",
        arabic: "بِسْمِ اللَّهِ فِي أَوَّلِهِ وَآخِرِهِ",
        pronunciation: "বিসমিল্লাহি ফী আউওয়ালিহী ওয়া আখিরিহী।",
        englishPronunciation: "Bismillahi fi awwalihi wa akhirihi.",
        meaning: "এর শুরু এবং শেষেও আল্লাহর নাম নিচ্ছি।",
        englishMeaning: "In the name of Allah in its beginning and its end.",
        reference: "সুনানে আবু দাউদ: ৩৭৬৭, সুনানে তিরমিজী: ১৮৫৮ (সহীহ)",
        englishReference:
            "Sunan Abi Dawud: 3767, Sunan At-Tirmidhi: 1858 (Sahih)",
      ),
      DuaItem(
        title: "খাবার খাওয়ার শেষের দোয়া",
        englishTitle: "Dua after finishing meal",
        arabic:
            "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ",
        pronunciation:
            "আলহামদু লিল্লাহিল্লাযী আত'আমানা ওয়া সাকানা ওয়া জা'আলানা মুসলিমীন।",
        englishPronunciation:
            "Alhamdu lillahil-lazhi at'amana wa saqana wa ja'alana muslimin.",
        meaning:
            "সব প্রশংসা আল্লাহর জন্য, যিনি আমাদের আহার করালেন, পান করালেন এবং মুসলিম বানালেন।",
        englishMeaning:
            "All praise is due to Allah who has fed us, given us drink, and made us Muslims.",
        reference: "সুনানে আবু দাউদ: ৩৮৫০, সুনানে তিরমিজী: ৩৪৫৭ (হাসান)",
        englishReference:
            "Sunan Abi Dawud: 3850, Sunan At-Tirmidhi: 3457 (Hasan)",
      ),
      DuaItem(
        title: "টয়লেটে প্রবেশ করার দোয়া",
        englishTitle: "Dua before entering the restroom",
        arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ",
        pronunciation:
            "আল্লাহুম্মা ইন্নী আ'ঊযু বিকা মিনাল খুবুছি ওয়াল খাবাইছ।",
        englishPronunciation:
            "Allahumma inni a'udhu bika minal-khubuthi wal-khaba'ith.",
        meaning:
            "হে আল্লাহ! আমি আপনার কাছে অপবিত্র নর ও নারী শয়তানের অনিষ্ট থেকে আশ্রয় চাচ্ছি।",
        englishMeaning:
            "O Allah, I seek refuge in You from the male and female evil spirits.",
        reference: "সহীহ বুখারী: ১৪২, সহীহ মুসলিম: ৩৭৫",
        englishReference: "Sahih Bukhari: 142, Sahih Muslim: 375",
      ),
      DuaItem(
        title: "টয়লেট থেকে বের হওয়ার দোয়া",
        englishTitle: "Dua after leaving the restroom",
        arabic: "غُفْرَانَكَ",
        pronunciation: "গুফরানাকা।",
        englishPronunciation: "Ghufranaka.",
        meaning: "হে আল্লাহ! আমি আপনার কাছে ক্ষমা প্রার্থনা করছি।",
        englishMeaning: "I ask You for Your forgiveness, O Allah.",
        reference: "সুনানে আবু দাউদ: ৩০, সুনানে তিরমিজী: ৭ (সহীহ)",
        englishReference: "Sunan Abi Dawud: 30, Sunan At-Tirmidhi: 7 (Sahih)",
      ),
      DuaItem(
        title: "আয়না দেখার দোয়া",
        englishTitle: "Dua when looking into a mirror",
        arabic: "اللَّهُمَّ أَنْتَ حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي",
        pronunciation: "আল্লাহুম্মা আন্তা হাসসান্তা খালকী ফাহাসসিন খুলুকী।",
        englishPronunciation:
            "Allahumma anta hassanta khalqi fahassin khuluqi.",
        meaning:
            "হে আল্লাহ! আপনি আমার চেহারা ও গঠন সুন্দর করেছেন, আমার চরিত্রও সুন্দর করে দিন।",
        englishMeaning:
            "O Allah, You have made my physical creation beautiful, so make my character beautiful too.",
        reference: "মুসনাদে আহমাদ: ২৪৩৯২, সহীহ ইবনে হিব্বান: ৯৫৯ (সহীহ)",
        englishReference: "Musnad Ahmad: 24392, Sahih Ibn Hibban: 959 (Sahih)",
      ),
      DuaItem(
        title: "যানবাহনে চড়ার দোয়া",
        englishTitle: "Dua for riding a vehicle",
        arabic:
            "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ * وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ",
        pronunciation:
            "সুবহানাল্লাযী সাখখারা লানা হাযা ওয়া মা কুন্না লাহূ মুকরিনীনা, ওয়া ইন্না ইলা রাব্বিনা লামুনকালিবূন।",
        englishPronunciation:
            "Subhanal-lazhi sakh-khara lana haza wa ma kunna lahu muqrinina, wa inna ila rabbina lamunqalibun.",
        meaning:
            "পবিত্র সেই সত্তা, যিনি এগুলোকে আমাদের অনুগত করে দিয়েছেন, অথচ আমরা একে বশ করতে পারতাম না। আর আমরা অবশ্যই আমাদের রবের দিকে ফিরে যাব।",
        englishMeaning:
            "Glory is to Him Who has subjected this to us, whereas we were not able to do it ourselves. And surely, to our Lord we are returning.",
        reference: "সূরা আয-যুখরুফ: ১৩-১৪, সহীহ মুসলিম: ১৩৪২",
        englishReference: "Surah Az-Zukhruf: 13-14, Sahih Muslim: 1342",
      ),
      DuaItem(
        title: "জ্ঞানের বৃদ্ধির দোয়া (পড়াশোনার শুরুতে)",
        englishTitle: "Dua for increasing knowledge",
        arabic: "رَّبِّ زِدْنِي عِلْمًا",
        pronunciation: "রাব্বি যিদনী 'ইলমা।",
        englishPronunciation: "Rabbi zidni 'ilma.",
        meaning: "হে আমার প্রতিপালক! আমার জ্ঞান বৃদ্ধি করে দিন।",
        englishMeaning: "O my Lord, increase me in knowledge.",
        reference: "সূরা তাহা: ১১৪",
        englishReference: "Surah Ta-Ha: 114",
      ),
      DuaItem(
        title: "কোনো বিপদে পড়লে পড়ার দোয়া",
        englishTitle: "Dua when afflicted by a calamity",
        arabic:
            "إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي وَأَخْلِفْ لِي خَيْرًا مِنْهَا",
        pronunciation:
            "ইন্না লিল্লাহি ওয়া ইন্না ইলাইহি রাজিউন। আল্লাহুম্মা' জুরনী ফী মুসীবাতী ওয়া আখলিফ লী খাইরাম মিনহা।",
        englishPronunciation:
            "Inna lillahi wa inna ilaihi raji'un. Allahumma'-jurni fi musibati wa akhlif li khayram-minha.",
        meaning:
            "আমরা তো আল্লাহরই এবং আমরা তাঁরই দিকে প্রত্যাবর্তনকারী। হে আল্লাহ! আমার এই বিপদে আমাকে সওয়াব দিন এবং এর চেয়ে উত্তম প্রতিদান দান করুন।",
        englishMeaning:
            "We belong to Allah and to Him we shall return. O Allah, reward me for my affliction and replace it with something better.",
        reference: "সহীহ মুসলিম: ৯১৮",
        englishReference: "Sahih Muslim: 918",
      ),
    ],
    "prayer_dua": [
      DuaItem(
        title: "ছানা (নামাজ শুরুর দোয়া)",
        englishTitle: "Sana (Dua at the start of prayer)",
        arabic:
            "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ",
        pronunciation:
            "সুবহানাকা আল্লাহুম্মা ওয়া বিহামদিকা ওয়া তাবারাকাসমুকা ওয়া তা'আলা জাদ্দুকা ওয়া লা ইলাহা গাইরুকা।",
        englishPronunciation:
            "Subhanaka Allahumma wa bihamdika wa tabarakasmuka wa ta'ala jadduka wa la ilaha ghairuk.",
        meaning:
            "হে আল্লাহ! আমি আপনার পবিত্রতা ঘোষণা করছি এবং আপনার প্রশংসা করছি। আপনার নাম বরকতময়, আপনার মহত্ত্ব সর্বোচ্চ এবং আপনি ছাড়া কোনো উপাস্য নেই।",
        englishMeaning:
            "Glory be to You, O Allah, and all praise. Blessed is Your name and exalted is Your majesty. There is no deity worthy of worship besides You.",
        reference: "সুনানে আবু দাউদ: ৭৭৫, সুনানে তিরমিজী: ২৪২ (সহীহ)",
        englishReference:
            "Sunan Abi Dawud: 775, Sunan At-Tirmidhi: 242 (Sahih)",
      ),
      DuaItem(
        title: "রুকুর তাসবীহ",
        englishTitle: "Tasbih of Ruku",
        arabic: "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
        pronunciation: "সুবহানা রব্বিয়াল আযীম।",
        englishPronunciation: "Subhana Rabbiyal-Azim.",
        meaning: "আমার মহান প্রতিপালকের পবিত্রতা ঘোষণা করছি।",
        englishMeaning: "Glory is to my Lord, the Magnificent.",
        reference: "সহীহ মুসলিম: ৭৭২, সুনানে আবু দাউদ: ৮৭১",
        englishReference: "Sahih Muslim: 772, Sunan Abi Dawud: 871",
      ),
      DuaItem(
        title: "রুকু থেকে ওঠার দোয়া",
        englishTitle: "Dua when rising from Ruku",
        arabic: "سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ",
        pronunciation: "সামি'আল্লাহু লিমান হামিদাহ।",
        englishPronunciation: "Sami'allahu liman hamidah.",
        meaning:
            "যে আল্লাহর প্রশংসা করে, আল্লাহ তার প্রশংসা শোনেন (কবুল করেন)।",
        englishMeaning: "Allah listens to him who praises Him.",
        reference: "সহীহ বুখারী: ৭৮৯, সহীহ মুসলিম: ৩৯২",
        englishReference: "Sahih Bukhari: 789, Sahih Muslim: 392",
      ),
      DuaItem(
        title: "রুকু থেকে সোজা হয়ে দাঁড়িয়ে পড়ার দোয়া",
        englishTitle: "Dua after standing straight from Ruku",
        arabic:
            "رَبَّنَا وَلَكَ الْحَمْدُ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ",
        pronunciation:
            "রাব্বানা ওয়া লাকাল হামদ, হামদান কাছীরান তায়্যিবান মুবারাকান ফীহ।",
        englishPronunciation:
            "Rabbana wa lakal-hamd, hamdan kathiran tayyiban mubarakan fih.",
        meaning:
            "হে আমাদের প্রতিপালক! আপনার জন্যই সমস্ত প্রশংসা; এমন প্রশংসা যা অগণিত, পবিত্র এবং বরকতময়।",
        englishMeaning:
            "Our Lord, all praise is Yours, praise that is abundant, beautiful, and blessed.",
        reference: "সহীহ বুখারী: ७৯৯",
        englishReference: "Sahih Bukhari: 799",
      ),
      DuaItem(
        title: "সেজদার তাসবীহ",
        englishTitle: "Tasbih of Sujud",
        arabic: "سُبْحَانَ رَبِّيَ الْأَعْلَى",
        pronunciation: "সুবহানা রব্বিয়াল আ'লা।",
        englishPronunciation: "Subhana Rabbiyal-A'la.",
        meaning: "আমার সর্বোচ্চ প্রতিপালকের পবিত্রতা ঘোষণা করছি।",
        englishMeaning: "Glory is to my Lord, the Most High.",
        reference: "সহীহ মুসলিম: ৭৭২, সুনানে আবু দাউদ: ৮৭১",
        englishReference: "Sahih Muslim: 772, Sunan Abi Dawud: 871",
      ),
      DuaItem(
        title: "দুই সেজদার মধ্যবর্তী বৈঠকের দোয়া",
        englishTitle: "Dua between the two prostrations",
        arabic:
            "اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي",
        pronunciation:
            "আল্লাহুম্মাগ ফিরলী ওয়ারহামনী ওয়াহদিনী ওয়া 'আফিনী ওয়ারযুকনী।",
        englishPronunciation:
            "Allahummagh-fir li warhamni wahdini wa 'afini warzuqni.",
        meaning:
            "হে আল্লাহ! আপনি আমাকে ক্ষমা করুন, আমার প্রতি দয়া করুন, আমাকে হেদায়েত দিন, আমাকে নিরাপত্তা দিন এবং আমাকে জীবিকা দান করুন।",
        englishMeaning:
            "O Allah, forgive me, have mercy on me, guide me, grant me security, and provide for me.",
        reference: "সুনানে আবু দাউদ: ৮৫০, সুনানে তিরমিজী: ২৮৪ (সহীহ)",
        englishReference:
            "Sunan Abi Dawud: 850, Sunan At-Tirmidhi: 284 (Sahih)",
      ),
      DuaItem(
        title: "তাশাহহুদ (আত্তাহিইয়াতু)",
        englishTitle: "Tashahhud (Attahiyyaat)",
        arabic:
            "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
        pronunciation:
            "আত্তাহিইয়াতু লিল্লাহি ওয়াস সালাওয়াতু ওয়াত তায়্যিবাতু, আসসালামু 'আলাইকা আইয়ুহান নাবিয়্যু ওয়া রাহমাতুল্লাহি ওয়া বারাকাতুহু, আসসালামু 'আলাইনা ওয়া 'আলা 'ইবাদিল্লাহিস সালিহীন, ash-হাদু আল লা ইলাহা ইল্লাল্লাহু ওয়া আশহাদু আন্না মুহাম্মাদান 'আবদুহু ওয়া রাসুলুহু।",
        englishPronunciation:
            "At-tahiyyatu lillahi was-salawatu wat-tayyibat, as-salamu 'alaika ayyuhan-nabiyyu wa rahmatullahi wa barakatuh, as-salamu 'alaina wa 'ala 'ibadillahis-salihin, ashhadu alla ilaha illallahu wa ashhadu anna Muhammadan 'abduhu wa rasuluh.",
        meaning:
            "যাবতীয় মৌখিক, শারীরিক ও আর্থিক ইবাদত আল্লাহর জন্য। হে নবী! আপনার ওপর শান্তি, আল্লাহর রহমত ও বরকত বর্ষিত হোক। আমাদের ওপর এবং আল্লাহর নেক বান্দাদের ওপর শান্তি বর্ষিত হোক। আমি সাক্ষ্য দিচ্ছি যে আল্লাহ ছাড়া কোনো উপাস্য নেই এবং আরও সাক্ষ্য দিচ্ছি যে মুহাম্মদ আল্লাহর বান্দা ও রাসুল।",
        englishMeaning:
            "All compliments, prayers, and pure words are due to Allah. Peace be upon you, O Prophet, and the mercy of Allah and His blessings. Peace be upon us and upon the righteous slaves of Allah. I bear witness that there is no deity worthy of worship except Allah, and I bear witness that Muhammad is His slave and Messenger.",
        reference: "সহীহ বুখারী: ৮৩১, সহীহ মুসলিম: ৪০২",
        englishReference: "Sahih Bukhari: 831, Sahih Muslim: 402",
      ),
      DuaItem(
        title: "দুরুদ শরীফ (দুরুদে ইব্রাহীম)",
        englishTitle: "Durood-e-Ibrahim",
        arabic:
            "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
        pronunciation:
            "আল্লাহুম্মা সাল্লি 'আলা মুহাম্মাদিন ওয়া 'আলা আলি মুহাম্মাদ, কামা সাল্লাইতা 'আলা ইব্রাহীমা ওয়া 'আলা আলি ইব্রাহীম, ইন্নাকা হামীদুম মাজীদ। আল্লাহুম্মা বারিক 'আলা মুহাম্মাদিন ওয়া 'আলা আলি মুহাম্মাদ, কামা বারাকতা 'আলা ইব্রাহীমা ওয়া 'আলা আলি ইব্রাহীম, ইন্নাকা হামীদুম মাজীদ।",
        englishPronunciation:
            "Allahumma salli 'ala Muhammadin wa 'ala ali Muhammad, kama sallaita 'ala Ibrahima wa 'ala ali Ibrahima innaka Hamidum Majid. Allahumma barik 'ala Muhammadin wa 'ala ali Muhammad, kama barakta 'ala Ibrahima wa 'ala ali Ibrahima innaka Hamidum Majid.",
        meaning:
            "হে আল্লাহ! আপনি মুহাম্মদ ও তাঁর বংশধরদের ওপর রহমত বর্ষণ করুন, যেমন রহমত বর্ষণ করেছেন ইব্রাহীম ও তাঁর বংশধরদের ওপর। নিশ্চয়ই আপনি প্রশংসিত ও সম্মানিত। হে আল্লাহ! আপনি মুহাম্মদ ও তাঁর বংশধরদের ওপর বরকত নাজিল করুন, যেমন বরকত নাজিল করেছেন ইব্রাহীম ও তাঁর বংশধরদের ওপর। নিশ্চয়ই আপনি প্রশংসিত ও সম্মানিত।",
        englishMeaning:
            "O Allah, send prayers upon Muhammad and upon the family of Muhammad, as You sent prayers upon Ibrahim and upon the family of Ibrahim; You are indeed Praiseworthy, Most Glorious. O Allah, bless Muhammad and the family of Muhammad, as You blessed Ibrahim and the family of Ibrahim; You are indeed Praiseworthy, Most Glorious.",
        reference: "সহীহ বুখারী: ৩৩৭০, সহীহ মুসলিম: ৪০৫",
        englishReference: "Sahih Bukhari: 3370, Sahih Muslim: 405",
      ),
      DuaItem(
        title: "দোয়ায়ে মাসূরা",
        englishTitle: "Dua-e-Masura",
        arabic:
            "اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ وَارْحَمْنِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ",
        pronunciation:
            "আল্লাহুম্মা ইন্নী যালামতু নাফসী ঝুলমান কাছীরান ওয়া লা ইয়াগফিরুয যুনূবা ইল্লা আন্তা, ফাগফির লী মাগফিরাতাম মিন 'ইনদিকা ওয়ারহামনী, ইন্নাকা আন্তাল গাফুরুর রাহীম।",
        englishPronunciation:
            "Allahumma inni zalamtu nafsi zulman kathiran wa la yaghfirudh-dhunuba illa anta, faghfir li maghfiratan min 'indika warhamni, innaka antal-Ghafurur-Rahim.",
        meaning:
            "হে আল্লাহ! আমি নিজের ওপর অনেক জুলুম (গুনাহ) করেছি। আর আপনি ছাড়া গুনাহ ক্ষমা করার কেউ নেই। অতএব, আপনার পক্ষ থেকে আমাকে সম্পূর্ণ ক্ষমা করে দিন এবং আমার প্রতি দয়া করুন। নিশ্চয়ই আপনি পরম ক্ষমাশীল ও دয়ালু।",
        englishMeaning:
            "O Allah, I have greatly wronged myself and no one forgives sins except You. So, grant me forgiveness from You and have mercy on me. Indeed, You are the Forgiving, the Merciful.",
        reference: "সহীহ বুখারী: ৮৩৪, সহীহ মুসলিম: ২৭০৫",
        englishReference: "Sahih Bukhari: 834, Sahih Muslim: 2705",
      ),
      DuaItem(
        title: "বিতর নামাজের দোয়ায়ে কুনুত",
        englishTitle: "Dua-e-Qunut (Witr Prayer)",
        arabic:
            "اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ، وَبَارِكْ لِي فِيمَا أَعْطَيْتَ، وَقِنِي شَرَّ مَا قَضَيْتَ، فَإِنَّكَ تَقْضِي وَلَا يُقْضَى عَلَيْكَ، وَإِنَّهُ لَا يَذِلُّ مَنْ وَالَيْتَ، تَبَارَكْتَ رَبَّنَا وَتَعَالَيْتَ",
        pronunciation:
            "আল্লাহুম্মাহদিনী ফীমান হাদাইত, ওয়া 'আফিনী ফীমান 'আফাইভ, ওয়া তাওয়াল্লানী ফীমান তাওয়াল্লাইত, ওয়া বারিক লী ফীমা আ'তাইত, ওয়া কিনী শাররা মা কাদাইত, ফান্নাকা তাকদ্বী ওয়া লা ইয়ুকদ্বা 'আলাইক, ওয়া ইন্নাহু লা ইয়াযিল্লু মাও ওয়ালাইত, তাবারাকতা রাব্বানা ওয়া তা'আলাইত।",
        englishPronunciation:
            "Allahummah-dini fiman hadait, wa 'afini fiman 'afait, wa tawallani fiman tawallait, wa barik li fima a'tait, wa qini sharra ma qadait, fa-innaka taqdi wa la yuqda 'alaik, wa innahu la yazillu maw-walait, tabarakta Rabbana wa ta'alait.",
        meaning:
            "হে আল্লাহ! আপনি যাদের হেদায়েত দিয়েছেন আমাকে তাদের অন্তর্ভুক্ত করুন, যাদেরকে নিরাপত্তা দিয়েছেন আমাকে তাদের অন্তর্ভুক্ত করুন, যাদের অভিভাবকত্ব গ্রহণ করেছেন আমাকে তাদের অন্তর্ভুক্ত করুন, আপনি যা দান করেছেন তাতে বরকত দিন এবং আপনার ফয়সালাকৃত অনিষ্ট থেকে আমাকে রক্ষা করুন। কেননা আপনিই চূড়ান্ত ফয়সালা দেন, আপনার ওপর কেউ ফয়সালা দিতে পারে না। আপনি যার সাথে বন্ধুত্ব রাখেন সে কখনো অপমানিত হয় না। হে আমাদের প্রতিপালক! আপনি বরকতময় ও সর্বোচ্চ মহান।",
        englishMeaning:
            "O Allah, guide me among those whom You have guided, grant me safety among those whom You have granted safety, take me to Your care among those whom You have taken to Your care, bless me in what You have given, and protect me from the evil of what You have decreed. For surely You decree and none can decree over You. Certainly, he whom You befriend is not humiliated. Blessed are You, our Lord, and Exalted.",
        reference: "সুনানে আবু দাউদ: ১৪২৫, সুনানে তিরমিজী: ৪৬৪ (সহীহ)",
        englishReference:
            "Sunan Abi Dawud: 1425, Sunan At-Tirmidhi: 464 (Sahih)",
      ),
    ],
    "after_prayer_dua": [
      DuaItem(
        title: "ইস্তিগফার (সালাম ফেরানোর পর প্রথম আমল)",
        englishTitle: "Istighfar (First act after Taslim)",
        arabic:
            "أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ",
        pronunciation: "আস্তাগফিরুল্লাহ, আস্তাগফিরুল্লাহ, আস্তাগফিরুল্লাহ।",
        englishPronunciation: "Astagfirullah, Astagfirullah, Astagfirullah.",
        meaning:
            "আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি, আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি, আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি।",
        englishMeaning:
            "I seek the forgiveness of Allah, I seek the forgiveness of Allah, I seek the forgiveness of Allah.",
        reference: "সহীহ মুসলিম: ৫৯১, সুনানে আবু দাউদ: ১৫১৩",
        englishReference: "Sahih Muslim: 591, Sunan Abi Dawud: 1513",
      ),
      DuaItem(
        title: "সালামের পর শান্তির দোয়া",
        englishTitle: "Dua for peace after Taslim",
        arabic:
            "اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ",
        pronunciation:
            "আল্লাহুম্মা আন্তাস সালামু ওয়া মিনকাস সালাম, তাবারাকতা ইয়া যাল জালালি ওয়াল ইকরামি।",
        englishPronunciation:
            "Allahumma Antas-Salamu wa minkas-salamu, tabarakta ya Dhal-Jalali wal-Ikram.",
        meaning:
            "হে আল্লাহ! আপনিই শান্তি এবং আপনার পক্ষ থেকেই শান্তি অবতীর্ণ হয়। হে মহিমাময় ও মহানuভব! আপনি বরকতময়।",
        englishMeaning:
            "O Allah, You are Peace and from You comes peace. Blessed are You, O Owner of majesty and honor.",
        reference: "সহীহ মুসলিম: ৫৯১, সুনানে তিরমিজী: ৩০০",
        englishReference: "Sahih Muslim: 591, Sunan At-Tirmidhi: 300",
      ),
      DuaItem(
        title: "আল্লাহর একত্ববাদ ও কৃতজ্ঞতার দোয়া",
        englishTitle: "Dua for Allah's Oneness and gratitude",
        arabic:
            "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدּُ",
        pronunciation:
            "লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু, লাহুল মুলকু ওয়া লাহুল হামদু ওয়া হুওয়া 'আলা কুল্লি শাইয়িন ক্বাদীর। আল্লাহুম্মা লা মানি'আ লিমা আ'тайতা, ওয়া লা মু'তিয়া লিমা মানা'তা, ওয়া লা ইয়ানফাউ যাল জাদ্দি মিনকাল জাদ্দু।",
        englishPronunciation:
            "La ilaha illallahu wahdahu la sharika lahu, lahul-mulku wa lahul-hamdu wa Huwa 'ala kulli shay'in Qadir. Allahumma la mani'a lima a'tayta, wa la mu'tiya lima mana'ta, wa la yanfa'u dhal-jaddi minkal-jaddu.",
        meaning:
            "একমাত্র আল্লাহ ছাড়া কোনো সত্য উপাস্য নেই, তাঁর কোনো শরিক নেই। রাজত্ব একমাত্র তাঁরই এবং সমস্ত প্রশংসাও তাঁরই। তিনি সব কিছুর ওপর ক্ষমতাবান। হে আল্লাহ! আপনি যা দান করতে চান তা বাধা দেওয়ার কেউ নেই, আর আপনি যা আটকে দেন তা দান করার কেউ নেই। আর কোনো ধনবানের ধন-সম্পদ আপনার আজাবের বিপরীতে কোনো উপকারে আসবে না।",
        englishMeaning:
            "There is no deity worthy of worship except Allah alone, without partner. To Him belongs sovereignty and to Him belongs praise, and He is Able to do all things. O Allah, none can prevent what You admit, and none can admit what You prevent, and the wealth of a wealthy person cannot avail him against You.",
        reference: "সহীহ বুখারী: ৮৪৪, সহীহ মুসলিম: ৫৯৩",
        englishReference: "Sahih Bukhari: 844, Sahih Muslim: 593",
      ),
      DuaItem(
        title: "নিয়মিত ইবাদত ও শুকরিয়া আদায়ের তৌফিক চাওয়ার দোয়া",
        englishTitle: "Dua for strength to worship and show gratitude",
        arabic:
            "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
        pronunciation:
            "আল্লাহুম্মা আ'ইন্নী 'আলা যিকরিকা ওয়া শুকরিকা ওয়া হুসনি 'ইবাদাতিকা।",
        englishPronunciation:
            "Allahumma a'inni 'ala dhikrika wa shukrika wa husni 'ibadatik.",
        meaning:
            "হে আল্লাহ! আপনার জিকির করতে, আপনার শুকরিয়া আদায় করতে এবং উত্তমরূপে আপনার ইবাদত করতে আমাকে সাহায্য করুন।",
        englishMeaning:
            "O Allah, help me to remember You, to give thanks to You, and to worship You in the best manner.",
        reference: "সুনানে আবু দাউদ: ১৫২২, সুনানে নাসায়ী: ১৩০৩ (সহীহ)",
        englishReference:
            "Sunan Abi Dawud: 1522, Sunan An-Nasa'i: 1303 (Sahih)",
      ),
      DuaItem(
        title: "আয়াতুল কুরসী (ফরজ নামাজ শেষে জান্নাতের চাবিকাঠি)",
        englishTitle: "Ayat al-Kursi (Key to Paradise after obligatory prayer)",
        arabic:
            "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيּُ الْقَيּُومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْដِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ",
        pronunciation:
            "আল্লাহু লা ইলাহা ইল্লা হুওয়াল হাইয়ুল কাইয়ুম। লা তা'খুযুহু সিনাতুও ওয়া লা নাওম। লাহু মা ফিস সামাওয়াতি ওয়া মা ফিল আরয। মান যাল্লাযী ইয়াশফাউ 'ইনদাহu ইল্লা বিইযনিহ। ইয়া'লামু মা বাইনা আইদীহিম ওয়া মা খালফাহুম, ওয়া লা ইয়ুহীতূনা বিশাইয়িম মিন 'ইলমিহী ইল্লা বিমা শা-আ। ওয়াসি'আ কুরসিইয়uহুস সামাওয়াতি ওয়াল আরযা, ওয়া লা ইয়াউদুহু হিফযুহুমা, ওয়া হুওয়াল 'আলিইয়ুল 'আযীম।",
        englishPronunciation:
            "Allahu la ilaha illa Huwal-Hayyul-Qayyum. La ta'khudhuhu sinatuw-wa la nawm. Lahu ma fis-samawati wa ma fil-ard. Man dhal-ladhi yashfa'u 'indahu illa bi-idhnih. Ya'lamu ma bayna aydihim wa ma khalfahum, wa la yuhituna bi-shay'im-min 'ilmihi illa bima sha'. Wasi'a kursiyyuhus-samawati wal-ard, wa la ya'uduhu hifzuhuma, wa Huwal-'Aliyyul-'Azim.",
        meaning:
            "আল্লাহ ছাড়া কোনো সত্য উপাস্য নেই, তিনি চিরঞ্জীব, সব কিছুর ধারক। তাঁকে তন্দ্রা ও নিদ্রা স্পর্শ করে না। আসমান ও জমিনে যা কিছু আছে সব তাঁরই। কে সে, যে তাঁর অনুমতি ছাড়া তাঁর কাছে সুপারিশ করবে? তাদের সামনে ও পেছনে যা কিছু আছে সবই তিনি জানেন। তাঁর জ্ঞান থেকে তারা কোনো কিছুই পরিবেষ্টিত করতে পারে না, তবে তিনি যতটুকু চান সেটুকু ছাড়া। তাঁর কুরসী আসমান ও জমিন পরিব্যাপ্ত করে আছে এবং এ দুটোর রক্ষণাবেক্ষণ তাঁকে ক্লান্ত করে না। আর তিনি সুউচ্চ, মহান।",
        englishMeaning:
            "Allah! There is no deity worthy of worship except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.",
        reference: "সুনানে কুবরা নাসায়ী: ৯৯২৮, تাবারানী: ৭৫৩২ (সহীহ)",
        englishReference:
            "Sunan al-Kubra an-Nasa'i: 9928, Al-Tabarani: 7532 (Sahih)",
      ),
      DuaItem(
        title: "ফজরের পর জীবিকা ও কবুলযোগ্য আমলের দোয়া",
        englishTitle: "Dua for sustenance and accepted deeds (After Fajr)",
        arabic:
            "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا",
        pronunciation:
            "আল্লাহুম্মা ইন্নী আসআলuকা 'ইলমান নাফিয়া, ওয়া রিযকান তায়্যিবা, ওয়া 'আমালান মুতাকাব্বিলা।",
        englishPronunciation:
            "Allahumma inni as'aluka 'ilman nafi'an, wa rizqan tayyiban, wa 'amalan mutaqabbalan.",
        meaning:
            "হে আল্লাহ! আমি আপনার কাছে উপকারী জ্ঞান, পবিত্র জীবিকা এবং কবুলযোগ্য আমল প্রার্থনা করছি।",
        englishMeaning:
            "O Allah, I ask You for beneficial knowledge, pure sustenance, and acceptable deeds.",
        reference: "সুনানে ইবনে মাজাহ: ৯২৫, মুসনাদে আহমাদ: ২৬৬০৫ (সহীহ)",
        englishReference: "Sunan Ibn Majah: 925, Musnad Ahmad: 26605 (Sahih)",
      ),
      DuaItem(
        title: "জাহান্নাম থেকে মুক্তির দোয়া (ফজর ও মাগরিবের পর)",
        englishTitle: "Dua for protection from Hellfire (After Fajr & Maghrib)",
        arabic: "اللَّهُمَّ أَجِرْنِي مِنَ النَّارِ",
        pronunciation: "আল্লাহুম্মা আজিরনী মিনান নার।",
        englishPronunciation: "Allahumma ajirni minan-nar.",
        meaning: "হে আল্লাহ! আমাকে জাহান্নামের আগুন থেকে রক্ষা করুন।",
        englishMeaning: "O Allah, protect me from the Hellfire.",
        reference: "সুনানে আবু দাউদ: ৫০৭৯, মুসনাদে আহমাদ: ১৮০৫৪ (হাসান)",
        englishReference: "Sunan Abi Dawud: 5079, Musnad Ahmad: 18054 (Hasan)",
      ),
      DuaItem(
        title: "কাপুরুষতা, কৃপণতা ও কবরের আজাব থেকে আশ্রয়",
        englishTitle:
            "Refuge from cowardice, miserliness and punishment of grave",
        arabic:
            "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْجُبْنِ، وَأَعُوذُ بِكَ أَنْ أُرَدَّ إِلَى أَرْذَلِ الْعُمُرِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الدُّنْيَا، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ",
        pronunciation:
            "আল্লাহুম্মা ইন্নী আ'ঊযু বিকা মিনাল জুবনি, ওয়া আ'ঊযু বিকা আন উরাদ্দা ইলা আরযালিল 'উমুরি, ওয়া আ'ঊযু বিকা মিন ফিতনাতিদ দুনিয়া, ওয়া আ'ঊযু বিকা মিন 'আযাবিল ক্বাবরি।",
        englishPronunciation:
            "Allahumma inni a'udhu bika minal-jubni, wa a'udhu bika an uradda ila ardhalil-'umuri, wa a'udhu bika min fitnatid-dunya, wa a'udhu bika min 'adhabil-qabr.",
        meaning:
            "হে আল্লাহ! আমি আপনার কাছে ভীরুতা বা কাপুরুষতা থেকে আশ্রয় চাই, চরম বার্ধক্যে উপনীত হওয়া থেকে আশ্রয় চাই, দুনিয়ার ফিতনা (দাজ্জাল) থেকে আশ্রয় চাই এবং কবরের আজাব থেকে আশ্রয় চাই।",
        englishMeaning:
            "O Allah, I seek refuge in You from cowardice, and I seek refuge in You from being brought back to a bad stage of old age, and I seek refuge in You from the afflictions of the world, and I seek refuge in You from the punishment of the grave.",
        reference: "সহীহ বুখারী: ২৮২২, সুনানে তিরমিজী: ৩৫৬৭",
        englishReference: "Sahih Bukhari: 2822, Sunan At-Tirmidhi: 3567",
      ),
      DuaItem(
        title: "তাসবীহে ফাতেমী (ফরজ নামাজ শেষে জিকির)",
        englishTitle: "Tasbih of Fatimah (Dhikr after obligatory prayer)",
        arabic:
            "سُبْحَانَ اللَّهِ (×٣٣) \nالْحَمْدُ لِلَّهِ (×٣٣) \nاللَّهُ أَكْبَرُ (×٣٣ / ×٣٤)",
        pronunciation:
            "১. সুবহানাল্লাহ (৩৩ বার)\n২. আলহামদুলিল্লাহ (৩৩ বার)\n৩. আল্লাহু আকবার (৩৪ বার অথবা ৩৩ বার পড়ে নিচের ১০০ তম পূর্ণকারী দোয়াটি পড়বেন)।",
        englishPronunciation:
            "1. Subhanallah (33 times)\n2. Alhamdulillah (33 times)\n3. Allahu Akbar (34 times, or 33 times combined with the 100th completion dua below).",
        meaning:
            "১. আল্লাহ পরম পবিত্র।\n২. সমস্ত প্রশংসা আল্লাহর জন্য।\n৩. আল্লাহ সবচেয়ে মহান।",
        englishMeaning:
            "1. Glory be to Allah.\n2. All praise is due to Allah.\n3. Allah is the Most Great.",
        reference: "সহীহ বুখারী: ৮৪৩, সহীহ মুসলিম: ৫৯৬, ৫৯৭",
        englishReference: "Sahih Bukhari: 843, Sahih Muslim: 596, 597",
      ),
      DuaItem(
        title: "১০০ তম পূর্ণকারী দোয়া (গুনাহ মাফের সুসংবাদ)",
        englishTitle: "100th Completion Dua (Good tidings of forgiveness)",
        arabic:
            "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
        pronunciation:
            "লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু, লাহুল মুলকু ওয়া লাহুল হামদু ওয়া হুওয়া 'আলা কুল্লি শাইয়িন ক্বাদীর।",
        englishPronunciation:
            "La ilaha illallahu wahdahu la sharika lahu, lahul-mulku wa lahul-hamdu wa Huwa 'ala kulli shay'in Qadir.",
        meaning:
            "একমাত্র আল্লাহ ছাড়া কোনো সত্য উপাস্য নেই, তাঁর কোনো শরিক নেই। রাজত্ব একমাত্র তাঁরই এবং সমস্ত প্রশংসাও তাঁরই। তিনি সব কিছুর ওপর ক্ষমতাবান। (নোট: ৩৩ বার করে সুবহানাল্লাহ, আলহামদুলিল্লাহ ও আল্লাহু আকবার বলার পর এই দোয়াটি দিয়ে ১০০ পূরণ করলে সমুদ্রের ফেনা পরিমাণ গুনাহ থাকলেও আল্লাহ ক্ষমা করে দেন)।",
        englishMeaning:
            "There is no deity worthy of worship except Allah alone, without partner. To Him belongs sovereignty and to Him belongs praise, and He is Able to do all things. (Note: Completing the 100 counts with this after reciting Tasbih 33 times wipes away sins even if they are as abundant as the foam of the sea).",
        reference: "সহীহ মুসলিম: ৫৯৭",
        englishReference: "Sahih Muslim: 597",
      ),
    ],
    "special_prayer_dua": [
      DuaItem(
        title: "দোয়ায় কুনূত (বিতর নামাজ - হানাফী মাজহাব অনুযায়ী প্রচলিত)",
        englishTitle: "Dua-e-Qunut (Witr Prayer - According to Hanafi Madhhab)",
        arabic:
            "اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنُؤْمِنُ بِكَ وَنَتَوَكَّلُ عَلَيْكَ وَنُثْنِي عَلَيْكَ الْخَيْرَ وَنَشْكُرُكَ وَلَا نَكْفُرُكَ وَنَخْلَعُ وَنَتْرُكُ مَنْ يَفْجُرُكَ، اللَّهُمَّ إِيَّاكَ نَعْبُدُ وَلَكَ نُصَلِّي وَنَسْجُدُ وَإِلَيْكَ نَسْعَى وَنَحْفِدُ وَنَرْجُو رَحْمَتَكَ وَنَخْشَى عَذَابَكَ إِنَّ عَذَابَكَ بِالْكُفَّارِ مُلْحِقٌ",
        pronunciation:
            "আল্লাহুম্মা ইন্না নাস্তাইনুকা ওয়া নাস্তাগফিরুকা ওয়া নু'মিনু বিকা ওয়া নাতাওয়াক্কালু 'আলাইকা ওয়া নুছনী 'আলাইকাল খাইরা ওয়া নাশকুরুকা ওয়ালা নাকফুরুকা ওয়া নাখলা'উ ওয়া নাতরুকু মাই ইয়াফজুরুক। আল্লাহুম্মা ইয়্যাকা না'বুদু ওয়ালাকা নুসল্লী ওয়া নাসজুদu ওয়া ইলাইকা নাস'আ ওয়া নাহফিদu ওয়া নারজু রাহমাতাকা ওয়া নাখশা 'আযাবাকা ইন্না 'আযাবাকা বিল কুফফারি মুলহিক্ব।",
        englishPronunciation:
            "Allahumma inna nasta'inuka wa nastaghfiruka wa nu'minu bika wa natawakkalu 'alaika wa nuthni 'alaikal-khayra wa nashkuruka wa la nakfuruka wa nakhla'u wa natruku may yafjuruk. Allahumma iyyaka na'budu wa laka nusalli wa nasjudu wa ilaika nas'a wa nahfidu wa narju rahmataka wa nakhsha 'adhabaka inna 'adhabaka bil-kuffari mulhiq.",
        meaning:
            "হে আল্লাহ! আমরা আপনারই সাহায্য চাচ্ছি, আপনারই কাছে ক্ষমা প্রার্থনা করছি, আপনার ওপর ঈমান আনছি এবং আপনার ওপর ভরসা করছি। আপনার উত্তম প্রশংসা করছি, আপনার শুকরিয়া আদায় করছি, আপনার কুফরি (অকৃতজ্ঞতা) করছি না। যারা আপনার আদেশ অমান্য করে, তাদের আমরা পরিত্যাগ করছি ও তাদের সাথে সম্পর্ক ছিন্ন করছি। হে আল্লাহ! আমরা আপনারই ইবাদত করি, আপনার জন্যই নামাজ পড়ি ও সেজদা করি। আপনার দিকেই আমরা ধাবিত হই এবং আপনার সেবায় নিয়োজিত থাকি। আমরা আপনার রহমতের আশা করি ও আপনার আজাবকে ভয় পাই। নিশ্চয়ই আপনার আজাব কাফেরদের গ্রাস করবে।",
        englishMeaning:
            "O Allah, we seek Your help and Your forgiveness, we believe in You and place our trust in You. We praise You in the best manner, we thank You and we are not ungrateful to You. We cast off and leave one who disobeys You. O Allah, You alone we worship, and to You we pray and prostrate. To You we rush and we strive to serve. We hope for Your mercy and we fear Your punishment. Indeed, Your punishment will surely overtake the disbelievers.",
        reference:
            "মুসান্নাফ ইবনে আবী শায়বা: ৬৯৬৫, কিতাবুল আছার (ইমাম মুহাম্মদ): ১/১৬৩",
        englishReference:
            "Musannaf Ibn Abi Shaybah: 6965, Kitab al-Athar (Imam Muhammad): 1/163",
      ),
      DuaItem(
        title: "ইস্তিখারা নামাজের দোয়া (সঠিক সিদ্ধান্ত নেওয়ার নামাজ)",
        englishTitle: "Dua for Istikhara (Prayer for seeking guidance)",
        arabic:
            "اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ وَتَعْلَمُ وَلَا أَعْلَمُ وَأَنْتَ عَلَّامُ الْغُيُوبِ، اللَّهُمَّ إِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ خَيْرٌ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي فَاقْدُرْهُ لِي وَيَسِّরْهُ لِي ثُمَّ بَارِكْ لِي فِيهِ، وَإِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ شَرٌّ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي فَاصْرِفْهُ وعَنِّي وَاصْرِفْنِي عَنْهُ وَاقْدُرْ لِي الْخَيْرَ حَيْثُ كَانَ ثُمَّ أَرْضِنِي بِهِ",
        pronunciation:
            "আল্লাহুম্মা ইন্নী আস্তাখীরuকা বিইলমিকা ওয়া আস্তাক্বদিরুকা বিক্বুদরাতিকা ওয়া আসআলuকা মিন ফাদলিকাল 'আযীম, ফাইন্নাকা তাক্বদিরু ওয়ালা আক্বদিরu ওয়া তা'লামু ওয়ালা আ'লামu ওয়া আন্তা 'আল্লামুল গুয়ূব। আল্লাহুম্মা ইন কুন্তা তা'লামু আন্না হাযাল আমরা খাইরুল লী ফী দীনী ওয়া মা'আশী ওয়া 'আক্বিবাতি আমরী ফাক্বদুরহু লী ওয়া ইয়াসসিরহু লী ছুম্মা বারিক লী ফীহ। ওয়া ইন কুন্তা তা'লামu আন্না হাযাল আমরা শাররুল লী ফী দীনী ওয়া মা'আশী ওয়া 'আক্বিবাতি আমরী ফাসরিফহু 'আন্নী ওয়াসরিফনী 'আনহু ওয়াক্বদুর লিয়াল খাইরা হাইছু কানা ছুম্মা আরদ্বিনী বিহ।",
        englishPronunciation:
            "Allahumma inni astakhiruka bi'ilmika wa astaqdiruka biqudratika wa as'aluka min fadlikal-'azim, fa-innaka taqdiru wa la aqdiru wa ta'lamu wa la a'lamu wa anta 'Allamul-ghuyub. Allahumma in kunta ta'lamu anna hadhal-amra khayrun li fi dini wa ma'ashi wa 'aqibati amri faqdurhu li wa yassirhu li thumma barik li fih. Wa in kunta ta'lamu anna hadhal-amra sharrun li fi dini wa ma'ashi wa 'aqibati amri fasrifhu 'anni wasrifni 'anhu waqdur liyal-khayra haythu kana thumma ardini bih.",
        meaning:
            "হে আল্লাহ! আমি আপনার জ্ঞানের উসিলায় আপনার কাছে কল্যাণ প্রার্থনা করছি এবং আপনার কুদরতের উসিলায় শক্তি প্রার্থনা করছি। আমি আপনার মহান অনুগ্রহ যাঞ্চা করছি। কেননা আপনিই ক্ষমতাবান, আমি অক্ষম। আপনিই সর্বজ্ঞ, আমি অজ্ঞ এবং আপনিই অদৃশ্য বিষয়ের পরিজ্ঞাতা। হে আল্লাহ! এই কাজটি যদি আমার দ্বীন, জীবন ও পরিণামের দিক দিয়ে কল্যাণকর মনে করেন, তবে তা আমার জন্য নির্ধারিত ও সহজ করে দিন এবং তাতে বরকত দিন। আর এই কাজটি যদি আমার দ্বীন, জীবন ও পরিণামের দিক দিয়ে ক্ষতিকর মনে করেন, তবে তা আমার থেকে এবং আমাকে তা থেকে দূরে সরিয়ে রাখুন। আর আমার জন্য যেখানেই কল্যাণ থাক তা নির্ধারিত করুন এবং তাতেই আমার মনকে সন্তুষ্ট করে দিন।",
        englishMeaning:
            "O Allah, I seek Your guidance through Your knowledge, and I seek power through Your might, and I ask You of Your great bounty. For You are capable and I am not, You know and I do not, and You are the Knower of the unseen. O Allah, if You know that this matter is good for me in my religion, my livelihood, and the end of my affairs, then decree it for me, make it easy for me, and bless me in it. And if You know that this matter is harmful to me in my religion, my livelihood, and the end of my affairs, then turn it away from me and turn me away from it, and decree for me what is good wherever it may be, and make me satisfied with it.",
        reference: "সহীহ বুখারী: ১১৬২, সুনানে তিরমিজী: ৪৮০",
        englishReference: "Sahih Bukhari: 1162, Sunan At-Tirmidhi: 480",
      ),
      DuaItem(
        title: "জানাজা নামাজের দোয়া (প্রাপ্তবয়স্কদের জন্য)",
        englishTitle: "Dua for Janazah Prayer (For adults)",
        arabic:
            "اللَّهُمَّ اغْفِرْ لِحَيِّنَا وَمَيِّتِنَا وَشَاهِدِنَا وَغَائِبِنَا وَصَغِيرِنَا وَكَبِيرِنَا وَذَكَرِنَا وَأُنْثَانَا، اللَّهُمَّ مَنْ أَحْيَيْتَهُ مِنَّا فَأَحْيِهِ عَلَى الْإِسْلَامِ وَمَنْ تَوَفَّيْتَهُ مِنَّا فَتَوَفَّهُ عَلَى الْإِيمَانِ",
        pronunciation:
            "আল্লাহুম্মাগ ফির লিহায়্যিনা ওয়া মাইয়্যিতিনা ওয়া শাহিদিনা ওয়া গাইবিনা ওয়া সাগীরিনা ওয়া কাবীরিনা ওয়া যাকারিনা ওয়া উনছানা। আল্লাহুম্মা মান আহইয়াইতাহু মিন্না ফাহয়িহী 'আলাল ইসলাম, ওয়া মান তাওয়াফ্ফাইতাহু মিন্না ফাতাওয়াফ্ফাহু 'আলাল ঈমান।",
        englishPronunciation:
            "Allahummagh-fir lihayyina wa mayyitina wa shahidina wa gha'ibina wa saghirina wa kabirina wa dhakarina wa unthana. Allahumma man ahyaytahu minna fa-ahyihi 'alal-Islam, wa man tawaffaytahu minna fatawaffahu 'alal-Iman.",
        meaning:
            "হে আল্লাহ! আমাদের জীবিত ও মৃত, উপস্থিত ও অনুপস্থিত, ছোট ও বড় এবং আমাদের নারী ও পুরুষ সবাইকে ক্ষমা করে দিন। হে আল্লাহ! আমাদের মধ্যে আপনি যাকে জীবিত রাখবেন তাকে ইসলামের ওপর জীবিত রাখুন এবং যাকে মৃত্যু দেবেন তাকে ঈমানের সাথে মৃত্যু দান করুন।",
        englishMeaning:
            "O Allah, forgive our living and our dead, those who are present and those who are absent, our young and our old, our males and our females. O Allah, whomever You keep alive among us, keep him alive upon Islam, and whomever You cause to die among us, cause him to die upon faith.",
        reference: "সুনানে তিরমিজী: ১০২৪, সুনানে আবু দাউদ: ৩২০১ (সহীহ)",
        englishReference:
            "Sunan At-Tirmidhi: 1024, Sunan Abi Dawud: 3201 (Sahih)",
      ),
      DuaItem(
        title: "সেজদায়ে তেলাওয়াতের দোয়া (কোরআন পড়ার সময় সেজদা আসলে)",
        englishTitle: "Dua for Sujud al-Tilawah (Prostration of recitation)",
        arabic:
            "سَجَدَ وَجْهِيَ لِلَّذِي خَلَقَهُ وَشَقَّ سَمْعَهُ وَبَصَرَهُ بِحَوْلِهِ وَقُوَّتِهِ، فَتَبَارَكَ اللَّهُ أَحْسَنُ الْخَالِقِينَ",
        pronunciation:
            "সাজাদা ওয়াজহিয়া লিল্লাযী খালাক্বাহu ওয়া শাক্ব-ক্বা সাম'আহু ওয়া বাসারাহু বিহাউলিহী ওয়া ক্বুওয়াতিহী, ফাতাবারাকাল্লাহু আহসানul খালিক্বীন।",
        englishPronunciation:
            "Sajada wajhiya lilladhi khalaqahu wa shaqqa sam'ahu wa basarahu bi-hawlihi wa quwwatih, fatabarakallahu ahsanul-khaliqin.",
        meaning:
            "আমার মুখমণ্ডল সেজদায় অবনত হলো সেই সত্তার চরণে, যিনি একে সৃষ্টি করেছেন এবং তাঁর নিজস্ব শক্তি ও সামর্থ্যে এর কান ও চোখ সচল করেছেন। অতএব সর্বোত্তম স্রষ্টা আল্লাহ অত্যন্ত বরকতময়।",
        englishMeaning:
            "My face has prostrated to the One Who created it and split open its hearing and sight by His might and power. So blessed is Allah, the Best of creators.",
        reference: "সুনানে তিরমিজী: ৫৮০, সুনানে নাসায়ী: ১১২৯ (সহীহ)",
        englishReference:
            "Sunan At-Tirmidhi: 580, Sunan An-Nasa'i: 1129 (Sahih)",
      ),
      DuaItem(
        title: "সালাতুল হাজত-এর দোয়া (প্রয়োজন ও বিপদ মুক্তির নামাজ)",
        englishTitle: "Dua for Salat al-Hajat (Prayer for need)",
        arabic:
            "لَا إِلَهَ إِلَّا اللَّهُ الْحَلِيمُ الْكَرِيمُ، سُبْحَانَ اللَّهِ رَبِّ الْعَرْشِ الْعَظِيمِ، الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ، أَسْأَلُكَ مُوجِبَاتِ رَحْمَتِكَ، وَعَزَائِمَ مَغْفِرَتِكَ، وَالْغَنِيمَةَ مِنْ كُلِّ بِرِّ، وَالسَّلَامَةَ مِنْ كُلِّ إِثْمٍ، لَا تَدَعْ لِي ذَنْبًا إِلَّا غَفَرْتَهُ، وَلَا هَمًّا إِلَّا فَرَّجْتَهُ، وَلَا حَاجَةً هِيَ لَكَ رِضًا إِلَّا قَضَيْتَهَا يَا أَرْحَمَ الرَّاحِمِينَ",
        pronunciation:
            "লা ইলাহা ইল্লাল্লাহুল হালীমুল কারীম। সুবহানাল্লাহি রাব্বিল 'আরশিল 'আযীম। আলহামদু লিল্লাহি রাব্বিল 'আলামীন। আসআলুকা মূজিবাতি রাহমাতিক, ওয়া 'আযাইমা মাগফিরাতিক, ওয়াল গানীমাতা মিন কুল্লি বিররিন, ওয়াস সালা-মাতান মিন কুল্লি ইছমিন। লা তাদা' লী যাম্বান ইল্লা গাফারতাহু, ওয়া লা হাম্মান ইল্লা ফাররাজতাহু, ওয়া লা হাজাতান হিয়া লাকা রিদ্বান ইল্লা কাদ্বাইতাহা ইয়া আরহামার রাহিমীন।",
        englishPronunciation:
            "La ilaha illallahul-Halimul-Karim. Subhanallahi Rabbil-'Arshil-'Azim. Alhamdulillahi Rabbil-'alamin. As'aluka mujibati rahmatik, wa 'aza'ima maghfiratik, wal-ghanimata min kulli birrin, was-salamata min kulli ithm. La tada' li dhanban illa ghafartah, wa la hamman illa farrajtah, wa la hajatan hiya laka ridan illa qadaytaha ya Arhamar-Rahimin.",
        meaning:
            "ধৈর্যশীল ও দয়াময় আল্লাহ ছাড়া কোনো সত্য উপাস্য নেই। মহান আরশের প্রতিপালক আল্লাহ অত্যন্ত পবিত্র। সব প্রশংসা বিশ্বজগতের প্রতিপালক আল্লাহর। হে আল্লাহ! আমি আপনার কাছে আপনার রহমত পাওয়ার উপযুক্ত আমল, আপনার ক্ষমার সুনিশ্চিত সিদ্ধান্ত, প্রত্যেক নেক কাজের অংশ এবং সব গুনাহ থেকে নিরাপত্তা প্রার্থনা করছি। আমার এমন কোনো গুনাহ বাকি রাখবেন না যা আপনি ক্ষমা করেননি, এমন কোনো দুশ্চিন্তা রাখবেন না যা আপনি দূর করেননি এবং আপনার সন্তোষজনক এমন কোনো প্রয়োজন রাখবেন না যা আপনি পূরণ করেননি, হে সর্বশ্রেষ্ঠ দয়ালু!",
        englishMeaning:
            "There is no deity worthy of worship except Allah, the Forbearing, the Generous. Glory be to Allah, the Lord of the Magnificent Throne. All praise is due to Allah, the Lord of the worlds. I ask You for the means of Your mercy, the certainty of Your forgiveness, a share of every good deed, and safety from every sin. Leave no sin of mine unforgiven, no distress unrelieved, and no need that is pleasing to You unfulfilled, O Most Merciful of those who show mercy!",
        reference:
            "সুনানে তিরমিজী: ৪৭৯, সুনানে ইবনে মাজাহ: ১৩৮৪ (যয়িফ সূত্রে বর্ণিত হলেও আমলযোগ্য)",
        englishReference:
            "Sunan At-Tirmidhi: 479, Sunan Ibn Majah: 1384 (Weak chain but acceptable for virtuous deeds)",
      ),
      DuaItem(
        title: "সালাতুত তাওবাহ-এর দোয়া (গুনাহ মাফের নামাজ)",
        englishTitle: "Dua for Salat al-Tawbah (Prayer of repentance)",
        arabic:
            "اللَّهُمَّ إِنِّي أَسْتَغْفِرُكَ لِذَنْبِي كُلِّهِ، دِقِّهِ وَجِلِّهِ، وَأَوَّلِهِ وَآخِرِهِ، وَعَلَانِيَتِهِ وَسِرِّهِ",
        pronunciation:
            "আল্লাহুম্মা ইন্নী আস্তাগফিরuকা লিযাম্বী কুল্লিহী, দিক্কিহী ওয়া জিল্লিহী, ওয়া আউওয়ালিহী ওয়া আখিরিহী, ওয়া 'আলানিয়াতিহী ওয়া সিররিহী।",
        englishPronunciation:
            "Allahumma inni astaghfiruka lidhanbi kullihi, diqqihi wa jillihi, wa awwalihi wa akhirihi, wa 'alaniyatihi wa sirrihi.",
        meaning:
            "হে আল্লাহ! আমি আমার সমস্ত গুনাহের জন্য আপনার কাছে ক্ষমা চাচ্ছি—ছোট গুনাহ, বড় গুনাহ, আগের গুনাহ, পরের গুনাহ, প্রকাশ্য গুনাহ এবং গোপন গুনাহ।",
        englishMeaning:
            "O Allah, I seek Your forgiveness for all my sins—the small and the great, the first and the last, the open and the secret.",
        reference:
            "সহীহ মুসলিম: ৪৮৩ (নোট: ২ রাকাত তওবার নামাজ শেষে এই ইস্তিগফারটি পড়া অত্যন্ত ফজিলতপূর্ণ)",
        englishReference:
            "Sahih Muslim: 483 (Note: Reciting this istighfar after 2 rak'ahs of Tawbah prayer is highly virtuous)",
      ),
      DuaItem(
        title: "জানাজা নামাজের দোয়া (অপ্রাপ্তবয়স্ক বা শিশু ছেলেদের জন্য)",
        englishTitle: "Dua for Janazah Prayer (For minor boys)",
        arabic:
            "اللَّهُمَّ اجْعَلْهُ لَنَا فَرَطًا، وَاجْعَلْهُ لَنَا أَجْرًا وَذُخْرًا، وَاجْعَلْهُ لَنَا شَافِعًا وَمُشَفَّعًا",
        pronunciation:
            "আল্লাহুম্মাজ 'আলহু লানা ফারাত্বান, ওয়াজ 'আলহু লানা আজরান ওয়া যুখরান, ওয়াজ 'আলহু লানা শাফি'আন ওয়া মুশাফফা'আন।",
        englishPronunciation:
            "Allahummaj-'alhu lana faratan, waj-'alhu lana ajran wa dhukhran, waj-'alhu lana shafi'an wa mushaffa'a.",
        meaning:
            "হে আল্লাহ! এই শিশুকে আমাদের জন্য অগ্রগামী পুরস্কারস্বরূপ করুন, তাকে আমাদের জন্য প্রতিদান ও সম্পদ বানান এবং তাকে আমাদের জন্য সুপারিশকারী করুন যার সুপারিশ কবুল করা হয়।",
        englishMeaning:
            "O Allah, make him a forerunner for us, and make him a reward and a treasure for us, and make him an intercessor for us whose intercession is accepted.",
        reference:
            "সহীহ বুখারী: কিতাবুল জানায়িজ, অধ্যায় ৬৫ (হাসান মোয়াল্লাক হাদিস)",
        englishReference:
            "Sahih Bukhari: Kitab al-Jana'iz, Chapter 65 (Hasan Mu'allaq)",
      ),
      DuaItem(
        title: "জানাজা নামাজের দোয়া (অপ্রাপ্তবয়স্ক বা শিশু মেয়েদের জন্য)",
        englishTitle: "Dua for Janazah Prayer (For minor girls)",
        arabic:
            "اللَّهُمَّ اجْعَلْهَا لَنَا فَرَطًا، وَاجْعَلْهَا لَنَا أَجْرًا وَذُخْرًا، وَاجْعَلْهَا لَنَا شَافِعَةً وَمُشَفَّعَةً",
        pronunciation:
            "আল্লাহুম্মাজ 'আলহা লানা ফারাত্বান, ওয়াজ 'আলহা লানা আজরান ওয়া যুখরান, ওয়াজ 'আলহা লানা শাফি'আতান ওয়া মুশাফফা'আতান।",
        englishPronunciation:
            "Allahummaj-'alha lana faratan, waj-'alha lana ajran wa dhukhran, waj-'alha lana shafi'atan wa mushaffa'ah.",
        meaning:
            "হে আল্লাহ! এই শিশুকন্যাকে আমাদের জন্য অগ্রগামী পুরস্কারস্বরূপ করুন, তাকে আমাদের জন্য প্রতিদান ও সম্পদ বানান এবং তাকে আমাদের জন্য সুপারিশকারী করুন যার সুপারিশ কবুল করা হয়।",
        englishMeaning:
            "O Allah, make her a forerunner for us, and make her a reward and a treasure for us, and make her an intercessor for us whose intercession is accepted.",
        reference: "সহীহ বুখারী: কিতাবুল জানায়িজ, অধ্যায় ৬৫",
        englishReference: "Sahih Bukhari: Kitab al-Jana'iz, Chapter 65",
      ),
    ],
  };

  // 🕋 ২. হোম স্ক্রিনের গ্রিডে বসানোর জন্য চারকোনা বক্স উইজেট (UI)
  static Widget buildDuaGridTile(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Material(
      color: Theme.of(context).cardBackground,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // 🔥 ট্যাপ করলে নিচ থেকে ক্যাটাগরি লিস্টের বটমশিট ওপেন হবে
        onTap: () => _showDuaCategoriesBottomSheet(context),
        splashColor: Colors.purple.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ১ম লাইন: আইকন ও ছোট সাবটাইটেল
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.front_hand_outlined,
                      color: Theme.of(context).iconColor),
                  Text(
                    lang.azkar,
                    style: Theme.of(context).subtitle,
                  ),
                ],
              ),

              // ২য় লাইন: মাঝখানে আকর্ষণীয় বড় বোল্ড টাইটেল
              Text(
                lang.dua,
                style: Theme.of(context).title.copyWith(
                    fontSize: 15, fontWeight: FontWeight.bold, height: 1.2),
              ),

              // ৩য় লাইন: নিচের ছোট গাইড টেক্সট
              Text(
                "Tap to read list",
                style: Theme.of(context).caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🕋 ৩. ক্যাটাগরিগুলোর মেইন লিস্ট সম্বলিত বটমশিট
  static void _showDuaCategoriesBottomSheet(BuildContext context) {
    // 🌐 কারেন্ট ল্যাঙ্গুয়েজ চেক
    final bool isBangla = Localizations.localeOf(context).languageCode == 'bn';

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).appBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, color: Theme.of(context).iconColor),
                  const SizedBox(width: 10),
                  Text(
                    isBangla
                        ? "দোয়ার ক্যাটাগরি সমূহ"
                        : "Dua Categories", // 👈 ডাইনামিক হেডার
                    style: Theme.of(context).title,
                  ),
                ],
              ),
              Divider(color: Theme.of(context).iconColor, height: 24),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _duaCategories.keys.map((categoryKey) {
                    // 👈 ক্যাটাগরি কি অনুযায়ী ডিসপ্লে নেম ঠিক করা
                    String displayCategoryName = "";
                    if (categoryKey == "necessary_dua") {
                      displayCategoryName =
                          isBangla ? "প্রয়োজনীয় দোয়া" : "Necessary Duas";
                    } else if (categoryKey == "prayer_dua") {
                      displayCategoryName =
                          isBangla ? "নামাজের মধ্যকার দোয়া" : "Duas in Prayer";
                    } else if (categoryKey == "after_prayer_dua") {
                      displayCategoryName =
                          isBangla ? "নামাজের পরের দোয়া" : "After Prayer Dua";
                    } else if (categoryKey == "special_prayer_dua") {
                      displayCategoryName = isBangla
                          ? "বিশেষ নামাজের দোয়া"
                          : "Special Prayer's Dua";
                    }

                    return ListTile(
                      leading: Icon(Icons.folder_open,
                          color: Theme.of(context).iconColor),
                      title: Text(displayCategoryName,
                          style: Theme.of(context).title),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 14, color: Theme.of(context).iconColor),
                      onTap: () {
                       // Navigator.pop(context);
                        _showDuaListScreen(context, displayCategoryName,
                            _duaCategories[categoryKey]!);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🕋 ৪. কোনো নির্দিষ্ট ক্যাটাগরিতে ক্লিক করলে তার ভেতরের দোয়াগুলো পড়ার জন্য ফুল স্ক্রিন পপ-আপ (বা এক্সপ্যান্ডেড উইন্ডো)
  // 🕋 ৪. কোনো নির্দিষ্ট ক্যাটাগরিতে ক্লিক করলে তার ভেতরের দোয়াগুলো পড়ার জন্য ফুল স্ক্রিন পপ-আপ
  static void _showDuaListScreen(
      BuildContext context, String categoryTitle, List<DuaItem> duaList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).appBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // সাব-হেডার পার্ট
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(categoryTitle, style: Theme.of(context).title),
                    IconButton(
                        icon: Icon(Icons.close,
                            color: Theme.of(context).iconColor),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Divider(color: Theme.of(context).iconColor, height: 20),

              // দোয়ার কার্ডগুলোর মেইন স্ক্রোলিং এরিয়া
              Expanded(
                child: ListView.builder(
                  cacheExtent: 1500, 
                  physics:const AlwaysScrollableScrollPhysics(),
                  itemCount: duaList.length,
                  itemBuilder: (context, index) {
                    final dua = duaList[index];
                    // 🌐 কারেন্ট ল্যাঙ্গুয়েজ চেক
                    final bool isBangla =
                        Localizations.localeOf(context).languageCode == 'bn';

                    // ভাষা অনুযায়ী ডেটা ফিল্টারিং
                    String titleDisplay =
                        isBangla ? dua.title : dua.englishTitle;
                    String pronunciationDisplay =
                        isBangla ? dua.pronunciation : dua.englishPronunciation;
                    String meaningDisplay =
                        isBangla ? dua.meaning : dua.englishMeaning;
                    String referenceDisplay =
                        isBangla ? dua.reference : dua.englishReference;

                    return AppCard(
                      key: ValueKey(dua.title),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // দোয়ার শিরোনাম
                            Text(titleDisplay,
                                style: Theme.of(context).title.copyWith(
                                    decoration: TextDecoration.underline)),
                            const SizedBox(height: 12),

                            // আরবী হরফ (যা সব ভাষার জন্যই ফিক্সড থাকবে)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                dua.arabic,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 30,
                                    height: 1.8,
                                    color: Theme.of(context).arabicColor),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // উচ্চারণ
                            Text(isBangla ? "উচ্চারণ:" : "Pronunciation:",
                                style: Theme.of(context).subtitle),
                            Text(pronunciationDisplay,
                                style: Theme.of(context).subtitle),
                            const SizedBox(height: 8),

                            // অর্থ
                            Text(isBangla ? "অর্থ:" : "Meaning:",
                                style: Theme.of(context).title),
                            Text(meaningDisplay,
                                style: Theme.of(context).title),
                            const SizedBox(height: 8),

                            // সূত্র
                            Text(isBangla ? "সূত্র:" : "Reference:",
                                style: Theme.of(context).subtitle),
                            Text(referenceDisplay,
                                style: Theme.of(context).subtitle),
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

class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({super.parent});

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // 💡 এখানে 'ScrollMetrics position' ব্যবহার করা হয়েছে যা একদম লেটেস্ট ফ্লাটারে সাপোর্টেড।
    // offset * 0.5 মানে স্ক্রোল স্পিড অর্ধেক হয়ে যাবে (ধীরগতির হবে)।
    // স্পিড বাড়াতে চাইলে ১.৫ বা ২.০ দিতে পারেন।
    return offset * 0.5;
  }
}
