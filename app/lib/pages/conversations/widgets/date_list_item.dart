import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:omi/providers/conversation_provider.dart';
import 'package:omi/utils/other/temp.dart';
import 'package:omi/utils/ui_guidelines.dart';
import 'package:provider/provider.dart';

class DateListItem extends StatelessWidget {
  final bool isFirst;
  final DateTime date;

  const DateListItem({super.key, required this.date, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var yesterday = now.subtract(const Duration(days: 1));
    var isToday = date.month == now.month && date.day == now.day && date.year == now.year;
    var isYesterday = date.month == yesterday.month && date.day == yesterday.day && date.year == yesterday.year;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 0 : 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isToday
                ? 'Your moments'
                : isYesterday
                    ? 'Yesterday'
                    : dateTimeFormat('MMM dd', date),
            style: AppStyles.sectionHeader,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
            ),
          ),
          // Only show calendar and expand icons for the first date (Your moments)
          if (isFirst) ...[
            Consumer<ConversationProvider>(
                builder: (BuildContext context, ConversationProvider convoProvider, Widget? child) {
              return InkWell(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  if (convoProvider.selectedDate != null) {
                    // Clear date filter
                    await convoProvider.clearDateFilter();
                  } else {
                    // Open date picker
                    await _selectDate(context);
                  }
                },
              child: Padding(
                padding: const EdgeInsets.all(12),
                  child: FaIcon(
                    convoProvider.selectedDate != null ? FontAwesomeIcons.calendarDay : FontAwesomeIcons.calendarDays,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            }),
            InkWell(
              onTap: () {
                print("the expand icon is clicked ");
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FaIcon(
                  FontAwesomeIcons.expand,
                  color: Colors.grey.shade400,
                ),
              ),
            )
          ]
        ],
      ),
    );
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
