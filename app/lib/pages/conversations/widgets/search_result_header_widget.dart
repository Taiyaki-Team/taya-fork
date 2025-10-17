import 'package:flutter/material.dart';
import 'package:omi/providers/conversation_provider.dart';
import 'package:omi/utils/ui_guidelines.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchResultHeaderWidget extends StatefulWidget {
  const SearchResultHeaderWidget({super.key});

  @override
  State<SearchResultHeaderWidget> createState() => _SearchResultHeaderWidgetState();
}

class _SearchResultHeaderWidgetState extends State<SearchResultHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationProvider>(builder: (context, provider, child) {
      var onSearches = provider.previousQuery.isNotEmpty;
      var isSearching = provider.isFetchingConversations;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: onSearches
            ? (isSearching
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.grey,
                    child: const Text(
                      "Searching your conversations",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ))
                : provider.totalSearchPages > 0
                    ? const Text(
                        "Search results",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      )
                    : const SizedBox.shrink())
            : const SizedBox.shrink(),
      );
    });
  }
}
