import 'package:flutter/material.dart';

/// Representation of a single saved bookmark/link
class SavedLink {
  final String id;
  final String title;
  final String url;
  final String savedDate;
  final String? note;

  const SavedLink({
    required this.id,
    required this.title,
    required this.url,
    required this.savedDate,
    this.note,
  });
}

/// Representation of a collection folder matching the Neo-Brutalist UI
class CollectionFolder {
  final String id;
  final String title;
  final int linkCount;
  final int? folderCount;
  final Color tabColor;
  final Color iconBadgeColor;
  final IconData icon;
  final bool isNew;
  final List<SavedLink> links;

  const CollectionFolder({
    required this.id,
    required this.title,
    required this.linkCount,
    this.folderCount,
    required this.tabColor,
    required this.iconBadgeColor,
    required this.icon,
    this.isNew = false,
    this.links = const [],
  });

  CollectionFolder copyWith({
    String? id,
    String? title,
    int? linkCount,
    int? folderCount,
    Color? tabColor,
    Color? iconBadgeColor,
    IconData? icon,
    bool? isNew,
    List<SavedLink>? links,
  }) {
    return CollectionFolder(
      id: id ?? this.id,
      title: title ?? this.title,
      linkCount: linkCount ?? this.linkCount,
      folderCount: folderCount ?? this.folderCount,
      tabColor: tabColor ?? this.tabColor,
      iconBadgeColor: iconBadgeColor ?? this.iconBadgeColor,
      icon: icon ?? this.icon,
      isNew: isNew ?? this.isNew,
      links: links ?? this.links,
    );
  }

  /// Initial sample collections reflecting the screenshot precisely
  static List<CollectionFolder> get sampleCollections => const [
        CollectionFolder(
          id: 'unsorted',
          title: 'Unsorted',
          linkCount: 1,
          tabColor: Color(0xFF6B7280), // Slate grey
          iconBadgeColor: Color(0xFFE5E7EB), // Soft grey badge
          icon: Icons.folder_outlined,
          links: [
            SavedLink(
              id: 'u1',
              title: 'Quick notes & draft article',
              url: 'https://notion.so/my-draft',
              savedDate: 'Oct 18, 2026',
            ),
          ],
        ),
        CollectionFolder(
          id: 'must_watch',
          title: 'Must watch',
          linkCount: 57,
          tabColor: Color(0xFF22C55E), // Vibrant green
          iconBadgeColor: Color(0xFF22C55E),
          icon: Icons.bolt_rounded,
          links: [
            SavedLink(
              id: 'mw1',
              title: 'Flutter Neo-Brutalism Masterclass',
              url: 'https://youtube.com/watch?v=demo1',
              savedDate: 'Oct 15, 2026',
            ),
            SavedLink(
              id: 'mw2',
              title: 'UI Design breakdown 2026',
              url: 'https://youtube.com/watch?v=demo2',
              savedDate: 'Oct 16, 2026',
            ),
          ],
        ),
        CollectionFolder(
          id: 'learning_research',
          title: 'Learning & Research',
          linkCount: 24,
          folderCount: 2,
          tabColor: Color(0xFFFDE047), // Soft yellow
          iconBadgeColor: Color(0xFFFDE047),
          icon: Icons.menu_book_rounded,
          links: [
            SavedLink(
              id: 'lr1',
              title: 'Modern Architecture Patterns',
              url: 'https://martinfowler.com/articles',
              savedDate: 'Oct 10, 2026',
            ),
            SavedLink(
              id: 'lr2',
              title: 'Flutter Widget Internals Deep-Dive',
              url: 'https://docs.flutter.dev/internals',
              savedDate: 'Oct 12, 2026',
            ),
          ],
        ),
        CollectionFolder(
          id: 'coffee_chill',
          title: 'Coffee & Chill Spots',
          linkCount: 7,
          tabColor: Color(0xFF84CC16), // Chartreuse / lime green
          iconBadgeColor: Color(0xFF84CC16),
          icon: Icons.local_cafe_rounded,
          links: [
            SavedLink(
              id: 'c1',
              title: 'Artisan Espresso Bar - Downtown',
              url: 'https://maps.google.com/?q=artisan-cafe',
              savedDate: 'Oct 5, 2026',
            ),
            SavedLink(
              id: 'c2',
              title: 'Hidden Rooftop Coffee Garden',
              url: 'https://maps.google.com/?q=rooftop-coffee',
              savedDate: 'Oct 14, 2026',
            ),
          ],
        ),
        CollectionFolder(
          id: 'travel_plan',
          title: 'Travel plan',
          linkCount: 13,
          tabColor: Color(0xFFFB7185), // Coral pink
          iconBadgeColor: Color(0xFFFB7185),
          icon: Icons.flight_rounded,
          links: [
            SavedLink(
              id: 't1',
              title: 'Kyoto Autumn foliage itinerary',
              url: 'https://japan-guide.com/kyoto',
              savedDate: 'Sep 29, 2026',
            ),
            SavedLink(
              id: 't2',
              title: 'Swiss Alps Hiking Guide 2026',
              url: 'https://alps-trail.com',
              savedDate: 'Oct 2, 2026',
            ),
          ],
        ),
        CollectionFolder(
          id: 'weekend_recipes',
          title: 'Weekend Recipes',
          linkCount: 7,
          tabColor: Color(0xFF818CF8), // Purple / violet
          iconBadgeColor: Color(0xFF818CF8),
          icon: Icons.favorite_rounded,
          isNew: true,
          links: [
            SavedLink(
              id: 'r1',
              title: 'Authentic Sourdough Neapolitan Pizza',
              url: 'https://cooking.nytimes.com/pizza',
              savedDate: 'Oct 17, 2026',
            ),
            SavedLink(
              id: 'r2',
              title: 'Creamy Matcha Basque Cheesecake',
              url: 'https://justonecookbook.com/matcha-cake',
              savedDate: 'Oct 18, 2026',
            ),
          ],
        ),
      ];
}
