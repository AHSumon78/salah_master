import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// সাউন্ডের মডেল ক্লাস
class SoundItem {
  final String name;
  final String file;
  final bool isSystemSound;

  SoundItem({
    required this.name,
    required this.file,
    this.isSystemSound = false,
  });
}

class SoundManager {
  // মেথড চ্যানেল
  static const _ringtoneChannel = MethodChannel('com.butterflydevs.salahmaster/ringtone');
  static const _soundChannel = MethodChannel('com.butterflydevs.salahmaster/sound');

  // ১. অ্যাপের নিজস্ব সাউন্ডের তালিকা
  static final List<SoundItem> appSounds = [
    SoundItem(name: 'Alarm', file: 'alarm'),
    SoundItem(name: 'Azan1', file: 'azan1'),
    SoundItem(name: 'Azan2', file: 'azan2'),
    SoundItem(name: 'Fazar', file: 'fazar'),
  ];

  // ২. সিস্টেমের রিংটোন পিকার খোলার ফাংশন
  static Future<SoundItem?> pickSystemSound() async {
    try {
      final String? uriString =
          await _ringtoneChannel.invokeMethod('openSystemRingtonePicker');

      if (uriString != null && uriString.isNotEmpty) {
        return SoundItem(
          name: 'System Ringtone',
          file: uriString,
          isSystemSound: true,
        );
      }
    } on PlatformException catch (e) {
      print("Failed to pick ringtone: ${e.message}");
    }
    return null;
  }

  // ৩. সাউন্ড প্রিভিউ বা প্লে করার ফাংশন (Native Android এ পাঠাবে)
  static Future<void> playSound(SoundItem soundItem) async {
    try {
      await _soundChannel.invokeMethod('playSound', {
        'soundName': soundItem.file, // Native Android এ পাঠানো হচ্ছে
      });
    } catch (e) {
      print("সাউন্ড প্লে করতে সমস্যা হয়েছে: $e");
    }
  }

  // ৪. সাউন্ড বন্ধ করার ফাংশন
  static Future<void> stopSound() async {
    try {
      await _soundChannel.invokeMethod('stopSound');
    } catch (_) {}
  }

  static String getSoundName(String soundPath) {
    if (soundPath.isEmpty) return 'Default';
    // যদি পাথটিতে ?title= থাকে (যেমন: 1465?title=Dynamic Whether&canonical=1)
    if (soundPath.contains('?title=')) {
      try {
        final titlePart = soundPath.split('?title=')[1];
        final title = titlePart.split('&')[0];
        // URL এনকোড করা থাকলে ডিকোড করার জন্য Uri.decodeComponent ব্যবহার করা যেতে পারে
        return Uri.decodeComponent(title);
      } catch (e) {
        return 'Unknown';
      }
    }

    // সাধারণ ফাইলের পাথের জন্য
    final fileName = soundPath.split('/').last;
    final nameWithoutExtension = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    return nameWithoutExtension.replaceAll('_', ' ');
  }

  // ৫. নতুন বটমশিট মেথড যা SoundManager এ যুক্ত করা হলো
  static Future<String?> selectSound(BuildContext context) async {
    String? currentlyPlaying;

    final String? selectedSoundFile = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Sound',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      // সাউন্ড বন্ধ করার জন্য একটি সাধারণ স্টপ বাটন
                      TextButton.icon(
                        onPressed: () async {
                          await SoundManager.stopSound();
                          setState(() {
                            currentlyPlaying = null;
                          });
                        },
                        icon:
                            const Icon(Icons.stop, color: Colors.red, size: 20),
                        label: const Text(
                          'Stop',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        // ১. অ্যাপের নিজস্ব সাউন্ডগুলোর তালিকা
                        ...SoundManager.appSounds.map((soundItem) {
                          final isPlaying = currentlyPlaying == soundItem.file;

                          return ListTile(
                            leading: const Icon(Icons.music_note,
                                color: Colors.teal),
                            title: Text(soundItem.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.stop : Icons.play_arrow,
                                    color: isPlaying ? Colors.red : Colors.teal,
                                  ),
                                  tooltip: isPlaying ? 'Stop' : 'Preview',
                                  onPressed: () async {
                                    if (isPlaying) {
                                      await SoundManager.stopSound();
                                      setState(() {
                                        currentlyPlaying = null;
                                      });
                                    } else {
                                      await SoundManager.playSound(soundItem);
                                      setState(() {
                                        currentlyPlaying = soundItem.file;
                                      });
                                    }
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    SoundManager
                                        .stopSound(); // বের হওয়ার আগে সাউন্ড বন্ধ হবে
                                    Navigator.pop(context, soundItem.file);
                                  },
                                  child: const Text(
                                    'Select',
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              SoundManager.stopSound();
                              Navigator.pop(context, soundItem.file);
                            },
                          );
                        }),

                        const Divider(),

                        // ২. সিস্টেমের রিংটোন পিকার
                        ListTile(
                          leading: const Icon(Icons.audiotrack,
                              color: Colors.deepOrange),
                          title: const Text('System Ringtone'),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                            onPressed: () async {
                              final systemSound =
                                  await SoundManager.pickSystemSound();
                              if (systemSound != null) {
                                SoundManager.stopSound();
                                Navigator.pop(context, systemSound.file);
                              }
                            },
                          ),
                          onTap: () async {
                            final systemSound =
                                await SoundManager.pickSystemSound();
                            if (systemSound != null) {
                              SoundManager.stopSound();
                              Navigator.pop(context, systemSound.file);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    return selectedSoundFile;
  }

  static void dispose() {
    try {
      // মেথড চ্যানেল ব্যবহার করার কারণে অতিরিক্ত কোনো ডিসপোজ করার প্রয়োজন নেই,
      // তবে কোডের কম্পাইলেশন এরর এড়াতে এটি রাখা হয়েছে।
    } catch (_) {}
  }
}
