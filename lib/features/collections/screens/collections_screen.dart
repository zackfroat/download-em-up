import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/collection_item.dart';
import '../widgets/neo_widgets.dart';

/// Pixel-perfect Neo-Brutalist Bookmark & Collections Screen
class CollectionsScreen extends StatefulWidget {
  final bool showDeviceFrame;
  final VoidCallback? onBack;

  const CollectionsScreen({
    super.key,
    this.showDeviceFrame = false,
    this.onBack,
  });

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late List<CollectionFolder> _collections;
  bool _isSearchActive = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _collections = List.from(CollectionFolder.sampleCollections);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _linkController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CollectionFolder> get _filteredCollections {
    if (_searchQuery.isEmpty) return _collections;
    return _collections.where((folder) {
      final matchesTitle = folder.title.toLowerCase().contains(_searchQuery);
      final matchesLinks = folder.links.any((l) =>
          l.title.toLowerCase().contains(_searchQuery) ||
          l.url.toLowerCase().contains(_searchQuery));
      return matchesTitle || matchesLinks;
    }).toList();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _linkController.text = data.text!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildNeoSnackBar('Link pasted from clipboard!'),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildNeoSnackBar('Clipboard is empty or contains no link.'),
        );
      }
    }
  }

  void _onAddLink() {
    final text = _linkController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildNeoSnackBar('Please paste or type a URL first!'),
      );
      return;
    }

    _showSaveToCollectionModal(text);
  }

  void _showSaveToCollectionModal(String linkUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String? selectedFolderId = _collections.first.id;
        final titleController = TextEditingController(
          text: linkUrl.startsWith('http')
              ? Uri.tryParse(linkUrl)?.host ?? 'Saved Link'
              : 'Saved Link',
        );

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 12,
                right: 12,
                top: 20,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Save to Collection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.black),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Link Title',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Destination',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _collections.map((col) {
                      final isSelected = col.id == selectedFolderId;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedFolderId = col.id;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? col.tabColor : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(col.icon, size: 16, color: Colors.black),
                              const SizedBox(width: 6),
                              Text(
                                col.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        if (selectedFolderId != null) {
                          _saveLinkToFolder(
                            selectedFolderId!,
                            titleController.text.trim().isEmpty
                                ? 'Saved Link'
                                : titleController.text.trim(),
                            linkUrl,
                          );
                          Navigator.pop(ctx);
                          _linkController.clear();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD43F), // Energetic yellow
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Save Link',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveLinkToFolder(String folderId, String title, String url) {
    setState(() {
      final index = _collections.indexWhere((c) => c.id == folderId);
      if (index != -1) {
        final folder = _collections[index];
        final newLink = SavedLink(
          id: 'link_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          url: url,
          savedDate: 'Just now',
        );
        final updatedLinks = [newLink, ...folder.links];
        _collections[index] = folder.copyWith(
          linkCount: folder.linkCount + 1,
          links: updatedLinks,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      _buildNeoSnackBar('Saved successfully! 🎉'),
    );
  }

  void _showCollectionDetails(CollectionFolder folder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, -4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: folder.iconBadgeColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Center(
                          child: Icon(folder.icon, color: Colors.black, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folder.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${folder.linkCount} links saved',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 24),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: Colors.black, thickness: 2, height: 28),

              // Links List
              Expanded(
                child: folder.links.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.link_off_rounded,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text(
                              'No links in this collection yet',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: folder.links.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final link = folder.links[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 1.8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.link_rounded,
                                    color: Colors.black, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        link.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        link.url,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF2563EB),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Saved ${link.savedDate}',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 18),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: link.url));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      _buildNeoSnackBar('Link copied! 📋'),
                                    );
                                  },
                                ),
                              ],
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

  void _showCreateCollectionModal() {
    final titleController = TextEditingController();
    Color selectedColor = const Color(0xFF22C55E);
    IconData selectedIcon = Icons.folder_rounded;

    final List<Color> colors = [
      const Color(0xFF6B7280), // Slate grey
      const Color(0xFF22C55E), // Vivid green
      const Color(0xFFFDE047), // Soft yellow
      const Color(0xFF84CC16), // Lime
      const Color(0xFFFB7185), // Coral pink
      const Color(0xFF818CF8), // Violet
      const Color(0xFF38BDF8), // Sky blue
      const Color(0xFFFB923C), // Orange
    ];

    final List<IconData> icons = [
      Icons.folder_rounded,
      Icons.bolt_rounded,
      Icons.menu_book_rounded,
      Icons.local_cafe_rounded,
      Icons.flight_rounded,
      Icons.favorite_rounded,
      Icons.star_rounded,
      Icons.music_note_rounded,
      Icons.code_rounded,
      Icons.movie_rounded,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 12,
                right: 12,
                top: 20,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Collection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.black),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Collection Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Design Inspiration',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Color',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: colors.map((c) {
                      final isSelected = c == selectedColor;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = c),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: isSelected ? 3 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  size: 18, color: Colors.black)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Icon',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: icons.map((ic) {
                      final isSelected = ic == selectedIcon;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = ic),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFD43F)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                          ),
                          child: Icon(ic, color: Colors.black, size: 20),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        final title = titleController.text.trim();
                        if (title.isNotEmpty) {
                          setState(() {
                            _collections.add(
                              CollectionFolder(
                                id: 'col_${DateTime.now().millisecondsSinceEpoch}',
                                title: title,
                                linkCount: 0,
                                tabColor: selectedColor,
                                iconBadgeColor: selectedColor,
                                icon: selectedIcon,
                                isNew: true,
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            _buildNeoSnackBar('Created "$title" folder! 📁'),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD43F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Create Folder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  SnackBar _buildNeoSnackBar(String text) {
    return SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD43F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Top-level scaffold with the light neo-brutalist canvas
    final content = Scaffold(
      backgroundColor: const Color(0xFFFBFBF9), // Exact off-white creamy canvas
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Status Bar Mock (09:27, cellular, wifi, battery 87%)
              _buildTopStatusBar(),

              const SizedBox(height: 16),

              // 2. Action Icons Row (Settings on left; Folder & Search on right)
              _buildTopActionRow(),

              const SizedBox(height: 24),

              // 3. Hero Headlines: "Save now.\nFind anytime."
              const Text(
                'Save now.\nFind anytime.',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.08,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 20),

              // 4. Link Input Bar (# Paste link to save + Yellow Plus Button)
              NeoLinkInputBar(
                controller: _linkController,
                onPaste: _pasteFromClipboard,
                onAdd: _onAddLink,
              ),

              // Search Bar (if search is active)
              if (_isSearchActive) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Search collections or links...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _isSearchActive = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // 5. Section Heading: "My Collections"
              const Text(
                'My Collections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 16),

              // 6. Two-Column Neo-Brutalist Folder Tab Cards Grid
              _buildCollectionsGrid(),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );

    // If device frame preview is desired
    if (widget.showDeviceFrame) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFD43F), // Playful yellow backdrop
        body: Center(
          child: Container(
            width: 390,
            height: 820,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(42),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(12, 12),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: content,
            ),
          ),
        ),
      );
    }

    return content;
  }

  Widget _buildTopStatusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '09:27',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.signal_cellular_alt_rounded,
                size: 17, color: Colors.black),
            const SizedBox(width: 4),
            const Icon(Icons.wifi_rounded, size: 17, color: Colors.black),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '87',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Settings (or Back if navigated from inside another screen)
        if (widget.onBack != null)
          NeoIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Go back',
            onTap: widget.onBack!,
          )
        else
          NeoIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildNeoSnackBar('Neo-Brutalist Settings opened! ⚙️'),
              );
            },
          ),

        // Right: Folder (+) and Search
        Row(
          children: [
            NeoIconButton(
              icon: Icons.create_new_folder_outlined,
              tooltip: 'New Collection',
              onTap: _showCreateCollectionModal,
            ),
            const SizedBox(width: 12),
            NeoIconButton(
              icon: Icons.search_rounded,
              tooltip: 'Search collections',
              onTap: () {
                setState(() {
                  _isSearchActive = !_isSearchActive;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionsGrid() {
    final list = _filteredCollections;

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 48, color: Colors.black45),
              const SizedBox(height: 12),
              Text(
                'No collections found matching "$_searchQuery"',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Strictly 2 columns on mobile just like the screenshot!
        final int crossAxisCount = constraints.maxWidth > 650 ? 3 : 2;
        // Aspect ratio tuned so folder tabs and info fit comfortably
        final double childAspectRatio = constraints.maxWidth < 360 ? 0.95 : 1.08;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final folder = list[index];
            return NeoFolderCard(
              folder: folder,
              onTap: () => _showCollectionDetails(folder),
            );
          },
        );
      },
    );
  }
}
