import 'package:flutter/material.dart';
import '../models/collection_item.dart';

/// Neo-Brutalist Icon Button with hard drop shadow & tactile press physics
class NeoIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final double borderWidth;
  final double shadowOffset;
  final double borderRadius;
  final String? tooltip;

  const NeoIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.size = 46,
    this.iconSize = 22,
    this.borderWidth = 2.5,
    this.shadowOffset = 3.0,
    this.borderRadius = 12,
    this.tooltip,
  });

  @override
  State<NeoIconButton> createState() => _NeoIconButtonState();
}

class _NeoIconButtonState extends State<NeoIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double offset = _isPressed ? widget.shadowOffset : 0.0;

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size + widget.shadowOffset,
        height: widget.size + widget.shadowOffset,
        child: Stack(
          children: [
            // Hard offset black shadow
            Positioned(
              left: widget.shadowOffset,
              top: widget.shadowOffset,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
              ),
            ),
            // Foreground tactile button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeInOut,
              left: offset,
              top: offset,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: Colors.black,
                    width: widget.borderWidth,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: widget.iconColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

/// Neo-Brutalist Folder Card with top tab protrusion, high-contrast borders,
/// and offset drop shadow
class NeoFolderCard extends StatefulWidget {
  final CollectionFolder folder;
  final VoidCallback onTap;

  const NeoFolderCard({
    super.key,
    required this.folder,
    required this.onTap,
  });

  @override
  State<NeoFolderCard> createState() => _NeoFolderCardState();
}

class _NeoFolderCardState extends State<NeoFolderCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double tabHeight = 14.0;
    const double shadowOffset = 3.5;
    final double currentOffset = _isPressed ? 2.5 : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            final cardHeight = constraints.maxHeight;
            final tabWidth = (cardWidth * 0.52).clamp(65.0, 95.0);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Hard Shadow Composite Layer (Tab shadow + Card body shadow)
                Positioned(
                  left: shadowOffset,
                  top: shadowOffset,
                  width: cardWidth,
                  height: cardHeight,
                  child: Stack(
                    children: [
                      // Tab Shadow
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: tabWidth,
                          height: tabHeight + 10,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      // Main Body Shadow
                      Positioned(
                        top: tabHeight,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Foreground Interactive Layer (Moves on press)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 70),
                  curve: Curves.easeOutQuad,
                  left: currentOffset,
                  top: currentOffset,
                  width: cardWidth,
                  height: cardHeight,
                  child: Stack(
                    children: [
                      // Protruding Top Folder Tab
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: tabWidth,
                          height: tabHeight + 8,
                          decoration: BoxDecoration(
                            color: widget.folder.tabColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),

                      // Main Card Body (overlaps bottom of tab to form solid seamless folder)
                      Positioned(
                        top: tabHeight,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: 2.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Row: Icon Badge + Stats / Badge
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon Badge
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: widget.folder.iconBadgeColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        widget.folder.icon,
                                        color: Colors.black,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Stats Column (link count, folder count, NEW badge)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${widget.folder.linkCount} ${widget.folder.linkCount == 1 ? "link" : "links"}',
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF4B5563),
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            if (widget.folder.isNew) ...[
                                              const SizedBox(width: 5),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 1.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF3366),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'NEW',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (widget.folder.folderCount != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '${widget.folder.folderCount} folders',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF6B7280),
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Bottom Title
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  widget.folder.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    letterSpacing: -0.3,
                                    height: 1.18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Neo-Brutalist Input Bar for entering or pasting link
class NeoLinkInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onPaste;
  final VoidCallback onAdd;

  const NeoLinkInputBar({
    super.key,
    required this.controller,
    required this.onPaste,
    required this.onAdd,
  });

  @override
  State<NeoLinkInputBar> createState() => _NeoLinkInputBarState();
}

class _NeoLinkInputBarState extends State<NeoLinkInputBar> {
  bool _isAddPressed = false;

  @override
  Widget build(BuildContext context) {
    const double shadowOffset = 3.0;

    return Row(
      children: [
        // Text Input Field Container
        Expanded(
          child: SizedBox(
            height: 52 + shadowOffset,
            child: Stack(
              children: [
                // Hard Shadow
                Positioned(
                  left: shadowOffset,
                  top: shadowOffset,
                  right: 0,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Foreground Input
                Positioned(
                  left: 0,
                  top: 0,
                  right: shadowOffset,
                  height: 52,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2.5),
                    ),
                    child: Row(
                      children: [
                        // "#" symbol
                        const Text(
                          '#',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Input Field
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Paste link to save',
                              hintStyle: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        // Clipboard / Paste icon button
                        GestureDetector(
                          onTap: widget.onPaste,
                          child: const Tooltip(
                            message: 'Paste from clipboard',
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.content_paste_rounded,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Yellow "+" Button
        GestureDetector(
          onTapDown: (_) => setState(() => _isAddPressed = true),
          onTapUp: (_) => setState(() => _isAddPressed = false),
          onTapCancel: () => setState(() => _isAddPressed = false),
          onTap: widget.onAdd,
          child: SizedBox(
            width: 52 + shadowOffset,
            height: 52 + shadowOffset,
            child: Stack(
              children: [
                // Hard Shadow
                Positioned(
                  left: shadowOffset,
                  top: shadowOffset,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Foreground Button
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 60),
                  curve: Curves.easeInOut,
                  left: _isAddPressed ? shadowOffset : 0.0,
                  top: _isAddPressed ? shadowOffset : 0.0,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD43F), // Vibrant energetic yellow
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2.5),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
