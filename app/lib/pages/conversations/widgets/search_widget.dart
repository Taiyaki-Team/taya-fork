import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:omi/providers/conversation_provider.dart';
import 'package:omi/providers/home_provider.dart';
import 'package:omi/utils/other/debouncer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  bool showClearButton = false;

  void setShowClearButton() {
    if (showClearButton != searchController.text.isNotEmpty) {
      setState(() {
        showClearButton = searchController.text.isNotEmpty;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header with Cancel and Done buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          Navigator.of(context).pop();
                          if (context.mounted) {
                            final provider = Provider.of<ConversationProvider>(context, listen: false);
                            await provider.filterConversationsByDate(selectedDate);
                          }
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Color(0xFF4FAFBE),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Date picker
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F5F5),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime.now(),
                      minimumDate: DateTime(2020),
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (DateTime newDate) {
                        selectedDate = newDate;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: TextFormField(
        controller: searchController,
        focusNode: context.read<HomeProvider>().convoSearchFieldFocusNode,
        onChanged: (value) {
          var provider = Provider.of<ConversationProvider>(context, listen: false);
          _debouncer.run(() async {
            await provider.searchConversations(value);
          });
          setShowClearButton();
        },
        decoration: InputDecoration(
          hintText: 'Search moments',
          hintStyle: TextStyle(
            color: Color(0xFF0D1F40).withOpacity(0.5),
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Color(0xFF4FAFBE),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: Color(0xFF4FAFBE),
            size: 16,
          ),
          suffixIcon: showClearButton
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Color(0xFF0D1F40),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minHeight: 36,
                    minWidth: 36,
                  ),
                  onPressed: () async {
                    var provider = Provider.of<ConversationProvider>(context, listen: false);
                    await provider.searchConversations(""); // clear
                    searchController.clear();
                    setShowClearButton();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(
          color: Color(0xFF0D1F40),
          fontSize: 14,
        ),
      ),
    );
  }
}
