import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String profilePic;
  final String name;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditIcon;

  const ProfileAvatar({
    super.key,
    required this.profilePic,
    this.name = '',
    this.radius = 50,
    this.onTap,
    this.showEditIcon = false,
  });

  String get _initials {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      final firstInitial = parts[0].isNotEmpty ? parts[0][0] : '';
      final secondInitial = parts[1].isNotEmpty ? parts[1][0] : '';
      return (firstInitial + secondInitial).toUpperCase();
    }
    return name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '';
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarChild;

    if (profilePic.isEmpty) {
      avatarChild = _buildInitialsOrPlaceholder();
    } else if (profilePic.startsWith('http') || profilePic.startsWith('blob:') || kIsWeb) {
      avatarChild = Image.network(
        profilePic,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitialsOrPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: radius,
              height: radius,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orangeAccent,
              ),
            ),
          );
        },
      );
    } else {
      // Mobile / Desktop local file
      final file = io.File(profilePic);
      if (file.existsSync()) {
        avatarChild = Image.file(
          file,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsOrPlaceholder(),
        );
      } else {
        avatarChild = _buildInitialsOrPlaceholder();
      }
    }

    Widget avatarWidget = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(child: avatarChild),
    );

    if (onTap != null) {
      avatarWidget = GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              avatarWidget,
              if (showEditIcon)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return avatarWidget;
  }

  Widget _buildInitialsOrPlaceholder() {
    if (_initials.isNotEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            _initials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.7,
            ),
          ),
        ),
      );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      color: Colors.orangeAccent.withValues(alpha: 0.1),
      child: Icon(
        Icons.person,
        size: radius,
        color: Colors.orangeAccent,
      ),
    );
  }
}
