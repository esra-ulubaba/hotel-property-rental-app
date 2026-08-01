import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';


class CalenderViewUi extends StatefulWidget {
  final int? monthIndex;
  final List<DateTime>? bookedDates;
  final Function? selectDate;
  final Function? getSelectedDates;

  const CalenderViewUi({
    super.key,
    this.getSelectedDates,
    this.selectDate,
    this.monthIndex,
    this.bookedDates,
  });

  @override
  State<CalenderViewUi> createState() => _CalenderViewUiState();
}


class _CalenderViewUiState extends State<CalenderViewUi> {
  List<DateTime> _selectedDates = [];
  List<MonthTileUi> _monthTiles = [];
  int? _currentMonthInt;
  int? _currentYearInt;


  _setUpMonthTiles() {
    setState(() {
      //Bu, temel olarak ayları belirtmek için kullanılacak. Örneğin mevcut ay, gelecek aylar
      _monthTiles = [];
      int daysInMonth = AppConstants.daysInMonthsMap![_currentMonthInt]!;
      DateTime firstDayOfMonth = DateTime(_currentYearInt!, _currentMonthInt!, 1);
      int firstWeekOfMonth = firstDayOfMonth.weekday;

      if (firstWeekOfMonth != 7) {
        for (int i = 0; i < firstWeekOfMonth; i++) {
          _monthTiles.add(MonthTileUi(dateTime: null));
        }
      }

      for (int i = 1; i <= daysInMonth; i++) {
        DateTime date = DateTime(_currentYearInt!, _currentMonthInt!, i);
        _monthTiles.add(MonthTileUi(dateTime: date));
      }
    });
  }

  _selectDate(DateTime date) {
    if (_selectedDates.contains(date)) {
      _selectedDates.remove(date);
    } else {
      _selectedDates.add(date);
    }
    widget.selectDate!(date);

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _currentMonthInt = (DateTime.now().month + widget.monthIndex!) % 12;
    if (_currentMonthInt == 0) {
      _currentMonthInt = 12;
    }

    _currentYearInt = DateTime.now().year;
    if (_currentMonthInt! < DateTime.now().month) {
      _currentYearInt = _currentYearInt! + 1;
    }

    _selectedDates.addAll(widget.getSelectedDates!());
    _selectedDates.sort();

    _setUpMonthTiles();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: AutoSizeText(
              " ${AppConstants.monthsDictionaryMap[_currentMonthInt]} - $_currentYearInt",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // white text
              ),
            ),
          ),
          GridView.builder(
            itemCount: _monthTiles.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1 / 1,
            ),
            itemBuilder: (context, index) {
              final monthTile = _monthTiles[index];
              if (monthTile.dateTime == null) {
                return const SizedBox();
              }

              DateTime today = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              );

              bool isSelected = _selectedDates.contains(monthTile.dateTime);
              bool isPast = monthTile.dateTime!.isBefore(today);
              bool isBooked = widget.bookedDates!.contains(monthTile.dateTime);

              // Past OR Booked → disabled grey
              if (isPast || isBooked) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[800], // dark grey background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "${monthTile.dateTime!.day}",
                      style: const TextStyle(
                        color: Colors.grey, // grey text
                      ),
                    ),
                  ),
                );
              }

              // Selected date → Airbnb pink
              if (isSelected) {
                return GestureDetector(
                  onTap: () {
                    _selectDate(monthTile.dateTime!);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5A5F), // Airbnb pink
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "${monthTile.dateTime!.day}",
                        style: const TextStyle(
                          color: Colors.white, // white text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Future Available → white bg with dark text
              return GestureDetector(
                onTap: () {
                  _selectDate(monthTile.dateTime!);
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white, // white background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "${monthTile.dateTime!.day}",
                      style: const TextStyle(
                        color: Colors.black, // dark text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}



class MonthTileUi extends StatelessWidget {
  final DateTime? dateTime;

  const MonthTileUi({super.key, this.dateTime,});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      dateTime == null ? "" : dateTime!.day.toString(),
    );
  }
}
