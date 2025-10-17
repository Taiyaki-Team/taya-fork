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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: onSearches
            ? (isSearching
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.grey,
                    child: const Text(
                      "Searching...",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ))
                : const SizedBox.shrink())
            : const SizedBox.shrink(),
      );
    });
  }
}
