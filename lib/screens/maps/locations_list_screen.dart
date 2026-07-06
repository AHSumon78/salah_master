// lib/screens/locations_list_screen.dart
import 'package:alarm/l10n/generated/app_localizations.dart';
import 'package:alarm/models/Location.dart';

import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/screens/commons/app_card.dart';
import 'package:alarm/screens/maps/location_details_screen.dart';
import 'package:alarm/services/NativeDB.dart';
import 'package:alarm/services/app_theme_extension.dart';
import 'package:flutter/material.dart';


class LocationsListScreen extends StatefulWidget {
  const LocationsListScreen({super.key});

  @override
  State<LocationsListScreen> createState() => _LocationsListScreenState();
}

class _LocationsListScreenState extends State<LocationsListScreen> {
  List<Location> locations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allLocations = await NativeDB.getLocations();
    if (mounted) {
      setState(() {
        locations = allLocations;
        isLoading = false;
      });
    }
  }

  Future<void> _addNewLocation() async {
    // থিমের ডেটা এবং এক্সটেনশনগুলোকে ভ্যারিয়েবলে নিয়ে নেওয়া হলো সহজে ব্যবহারের জন্য
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if the location limit is reached
    if (locations.length >= 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can add a maximum of 10 locations.',
              style: TextStyle(
                  color: isDark
                      ? Colors.black87
                      : Colors.white), // স্নাকবার টেক্সট কন্ট্রোল
            ),
            backgroundColor: isDark
                ? Colors.redAccent.shade100
                : Colors.red.shade700, // ডাইনামিক রেড
          ),
        );
      }
      return;
    }

    String? newLocationName;

    final name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor, // 🌟 ডায়ালগ ব্যাকগ্রাউন্ড কন্ট্রোল
          title: Text(
            'Add New Location',
            style: theme.title, // 🌟 আপনার এক্সটেনশনের টাইটেল স্টাইল
          ),
          content: TextField(
            onChanged: (value) {
              newLocationName = value;
            },
            style: theme.subtitle
                .copyWith(color: theme.textColor), // লেখার সময় অক্ষরের কালার
            decoration: InputDecoration(
              hintText: "Enter location name",
              hintStyle: theme.caption, // হিন্ট টেক্সটের স্টাইল
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: theme.customDivider), // নরমাল বর্ডার
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: theme.iconColor,
                    width: 2), // 🌟 ক্লিকড অবস্থার বর্ডার
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: theme.subtitle.copyWith(
                  color: isDark
                      ? Colors.white60
                      : Colors.black54, // ক্যানসেল বাটন কিছুটা ম্লান
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Add',
                style: theme.subtitle.copyWith(
                  color: isDark
                      ? Colors.tealAccent
                      : Colors.teal, // 🌟 অ্যাড বাটন হাইলাইটেড
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (newLocationName != null &&
                    newLocationName!.trim().isNotEmpty) {
                  Navigator.of(context).pop(newLocationName!.trim());
                }
              },
            ),
          ],
        );
      },
    );

    if (name != null) {
      final newLocation = Location(
        name: name,
        preAlarmMinutes: 0,
        latitude: 24,
        longitude: 90,
        diameter: 500,
      );

      await NativeDB.insertLocation(
        name: newLocation.name,
        lat: newLocation.latitude,
        lon: newLocation.longitude,
        diameter: newLocation.diameter,
        preAlarm: newLocation.preAlarmMinutes,
      );

      await Future.delayed(const Duration(seconds: 1));
      await _loadLocations();
    }
  }

  Future<void> _deleteLocation(final location) async {
    // Only allow deletion of locations from the third one onwards (index 2)
    if (location.id < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The first two locations cannot be deleted.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this location? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await NativeDB.deleteLocation(location.id!); // ✅ correct
      await _loadLocations();
    }
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l = AppLocalizations.of(context)!;
        return Dialog(
          // AlertDialog এর বদলে Dialog ব্যবহার করা ভালো কাস্টম ডিজাইনের জন্য
          backgroundColor: Colors.transparent, // ভেতরের ডিফল্ট রঙ সরিয়ে দিচ্ছে
          insetPadding: const EdgeInsets.symmetric(
              horizontal: 20), // স্ক্রিনের সাইড থেকে গ্যাপ
          child: Container(
            // আপনার কাঙ্ক্ষিত গ্রাডিয়েন্ট এখন কাজ করবে
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // কন্টেন্ট অনুযায়ী সাইজ হবে
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title সেকশন
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).iconColor, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        l.locationsUses,
                        style: Theme.of(context).title,
                      ),
                    ],
                  ),
                  Divider(color: Theme.of(context).iconColor, height: 25),

                  // Content সেকশন
                  Text(
                    l.locationsUsesDescription,
                    style: Theme.of(context).subtitle,
                  ),

                  const SizedBox(height: 20),

                  // Actions (Understood Button)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l.understood,
                        style: TextStyle(
                            color: Theme.of(context).iconColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBarCommon(
        title: l.alarmsLocations,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline,
                color: Theme.of(context).iconColor, size: 30),
            onPressed: () => _showPopup(context),
            tooltip: 'Learn More',
          ),
        ],
      ),
      body: AppBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : Stack(
                children: [
                  // Large mosque icon in the background
                  Center(
                    child: Icon(
                      Icons.mosque,
                      color: Colors.grey.withValues(
                          alpha: 0.1), // Adjusted opacity for subtle effect
                      size: 200, // Large size for background
                    ),
                  ),
                  // The list of locations
                  ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return AppCard(
                        child: Material(
                          // 👈 Add this widget here
                          type: MaterialType.transparency,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            // Mosque icon at the start of each list tile
                            leading: Icon(Icons.location_on,
                                color: theme.iconColor, size: 30),
                            title: Text(
                              location.name,
                              style: Theme.of(context).title,
                            ),
                            subtitle: Text(
                              'Lat: ${location.latitude.toStringAsFixed(4)}, Lon: ${location.longitude.toStringAsFixed(4)}',
                              style: Theme.of(context).subtitle,
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LocationDetailsScreen(location: location),
                                ),
                              );
                              _loadLocations();
                            },
                            // Only show delete icon for locations from index 2 onwards
                            trailing: index >= 2
                                ? IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 24),
                                    onPressed: () => _deleteLocation(location),
                                  )
                                : const Icon(Icons.arrow_forward_ios,
                                    color: Colors.teal, size: 18),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // 👈 এখানে height control
        child: FloatingActionButton(
          onPressed: _addNewLocation,
          backgroundColor: Colors.teal.withValues(alpha: 0.6),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
