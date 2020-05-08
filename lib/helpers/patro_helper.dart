import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../patro/patro.dart';
import 'dart:math' as math;

//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0


/// Class containing styling for `TableCalendar`'s content.
class CalendarStyle {
  /// Style of foreground Text for regular weekdays.
  final TextStyle dayStyle;

  /// Style of foreground Text for selected day.
  final TextStyle selectedStyle;

  /// Style of foreground Text for today.
  final TextStyle todayStyle;

  /// Style of foreground Text for days outside of `startDay` - `endDay` Date range.
  final TextStyle unavailableStyle;

  /// Background Color of selected day.
  final Color selectedColor;

  /// Background Color of today.
  final Color todayColor;

  /// Determines whether the row of days of the week should be rendered or not.
  final bool renderDaysOfWeek;

  /// Padding of `CleanNepaliCalendar`'s content.
  final EdgeInsets contentPadding;

  /// Specifies whether or not SelectedDay should be highlighted.
  final bool highlightSelected;

  /// Specifies whether or not Today should be highlighted.
  final bool highlightToday;

  const CalendarStyle({
    this.dayStyle = const TextStyle(),
    this.selectedStyle = const TextStyle(
        color: const Color(0xFFFAFAFA), fontSize: 16.0), // Material grey[50]
    this.todayStyle = const TextStyle(
        color: const Color(0xFFFAFAFA), fontSize: 16.0), // Material grey[50]
    this.unavailableStyle = const TextStyle(color: const Color(0xFFBFBFBF)),
    this.selectedColor = const Color(0xFF5C6BC0), // Material indigo[400]
    this.todayColor = const Color(0xFF9FA8DA), // Material indigo[200]
    this.renderDaysOfWeek = true,
    this.contentPadding =
        const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
    this.highlightSelected = true,
    this.highlightToday = true,
  });
}

//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0



/// Class containing styling and configuration of `CleanNepaliCalendar`'s header.
class HeaderStyle {
  /// Responsible for making title Text centered.
  final bool centerHeaderTitle;

  /// Use to customize header's title text (eg. with different `DateFormat`).
  /// You can use `String` transformations to further customize the text.
  /// Defaults to simple `'yMMMM'` format (eg. January 2019, February 2019, March 2019, etc.).
  ///
  /// Example usage:
  /// ```dart
  /// titleTextBuilder: (date, locale) => DateFormat.yM(locale).format(date),
  /// ```
  final TextBuilder titleTextBuilder;

  /// Style for title Text (month-year) displayed in header.
  final TextStyle titleTextStyle;

  /// Inside padding for left chevron.
  final EdgeInsets leftChevronPadding;

  /// Inside padding for right chevron.
  final EdgeInsets rightChevronPadding;

  /// Icon used for left chevron.
  /// Defaults to black `Icons.chevron_left`.
  final Icon leftChevronIcon;

  /// Icon used for right chevron.
  /// Defaults to black `Icons.chevron_right`.
  final Icon rightChevronIcon;

  /// Header decoration, used to draw border or shadow or change color of the header
  /// Defaults to empty BoxDecoration.
  final BoxDecoration decoration;

  const HeaderStyle({
    this.centerHeaderTitle = true,
    this.titleTextBuilder,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.leftChevronPadding = const EdgeInsets.all(8.0),
    this.rightChevronPadding = const EdgeInsets.all(8.0),
    this.leftChevronIcon = const Icon(Icons.chevron_left, color: Colors.black),
    this.rightChevronIcon =
        const Icon(Icons.chevron_right, color: Colors.black),
    this.decoration = const BoxDecoration(),
  });
}

typedef void _SelectedDayCallback(NepaliDateTime day, {bool runCallback});

class NepaliCalendarController {
  NepaliDateTime get selectedDay => _selectedDay;
  NepaliDateTime _selectedDay;
  _SelectedDayCallback _selectedDayCallback;

  void _init({
    @required _SelectedDayCallback selectedDayCallback,
    @required NepaliDateTime initialDay,
  }) {
    _selectedDayCallback = selectedDayCallback;
    _selectedDay = initialDay;
  }

  void setSelectedDay(
    NepaliDateTime value, {
    bool isProgrammatic = true,
    bool animate = true,
    bool runCallback = false,
  }) {
    _selectedDay = value;

    if (isProgrammatic && _selectedDayCallback != null) {
      _selectedDayCallback(value, runCallback: runCallback);
    }
  }
}

typedef String TextBuilder(NepaliDateTime date, Language language);
typedef void HeaderGestureCallback(NepaliDateTime focusedDay);

String formattedMonth(
  int month, [
  Language language,
]) =>
    NepaliDateFormat.MMMM(language).format(
      NepaliDateTime(0, month),
    );

const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight =
    _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);

class CleanNepaliCalendar extends StatefulWidget {
  const CleanNepaliCalendar({
    Key key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.language = Language.nepali,
    this.onDaySelected,
    this.headerStyle = const HeaderStyle(),
    this.calendarStyle = const CalendarStyle(),
    this.onHeaderTapped,
    this.onHeaderLongPressed,
    @required this.controller,
  }) : super(key: key);

  final NepaliDateTime initialDate;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final Function(NepaliDateTime) onDaySelected;
  final SelectableDayPredicate selectableDayPredicate;
  final Language language;
  final CalendarStyle calendarStyle;
  final HeaderStyle headerStyle;
  final HeaderGestureCallback onHeaderTapped;
  final HeaderGestureCallback onHeaderLongPressed;
  final NepaliCalendarController controller;

  @override
  _CleanNepaliCalendarState createState() => _CleanNepaliCalendarState();
}

class _CleanNepaliCalendarState extends State<CleanNepaliCalendar> {
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? NepaliDateTime.now();
    widget.controller._init(
      selectedDayCallback: _handleDayChanged,
      initialDay: widget.initialDate ?? NepaliDateTime.now(),
    );
  }

  bool _announcedInitialDate = false;

  MaterialLocalizations localizations;
  TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        NepaliDateFormat.yMMMMd().format(_selectedDate),
        textDirection,
      );
    }
  }

  @override
  void didUpdateWidget(CleanNepaliCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedDate = widget.initialDate ?? NepaliDateTime.now();
    widget.controller
        .setSelectedDay(widget.initialDate ?? NepaliDateTime.now());
  }

  NepaliDateTime _selectedDate;
  final GlobalKey _pickerKey = GlobalKey();

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.windows:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
        break;
      case TargetPlatform.linux:
        break;
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleDayChanged(NepaliDateTime value, {bool runCallback = true}) {
    _vibrate();
    setState(() {
      widget.controller.setSelectedDay(value, isProgrammatic: false);
      _selectedDate = value;
    });
    if (runCallback && widget.onDaySelected != null)
      widget.onDaySelected(value);
  }

  Widget _buildPicker() {
    return Padding(
      padding: widget.calendarStyle.contentPadding,
      child: _MonthView(
        key: _pickerKey,
        headerStyle: widget.headerStyle,
        calendarStyle: widget.calendarStyle,
        language: widget.language,
        selectedDate: _selectedDate,
        onChanged: _handleDayChanged,
        firstDate: widget.firstDate ?? NepaliDateTime(2000, 1),
        lastDate: widget.lastDate ?? NepaliDateTime(2095, 12),
        selectableDayPredicate: widget.selectableDayPredicate,
        onHeaderTapped: widget.onHeaderTapped,
        onHeaderLongPressed: widget.onHeaderLongPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPicker();
  }
}

typedef SelectableDayPredicate = bool Function(NepaliDateTime day);



class _DayWidget extends StatelessWidget {
  const _DayWidget({
    Key key,
    @required this.isSelected,
    @required this.isDisabled,
    @required this.isToday,
    @required this.label,
    @required this.text,
    @required this.onTap,
    @required this.calendarStyle,
  }) : super(key: key);

  final bool isSelected;
  final bool isDisabled;
  final bool isToday;
  final String label;
  final String text;
  final Function() onTap;
  final CalendarStyle calendarStyle;

  @override
  Widget build(BuildContext context) {
    Decoration _buildCellDecoration() {
      if (isSelected && calendarStyle.highlightSelected) {
        return BoxDecoration(
          color: calendarStyle.selectedColor,
          shape: BoxShape.circle,
        );
      } else if (isToday && calendarStyle.highlightToday) {
        return BoxDecoration(
          shape: BoxShape.circle,
          color: calendarStyle.todayColor,
        );
      } else {
        return BoxDecoration(
          shape: BoxShape.circle,
        );
      }
    }

    TextStyle _buildCellTextStyle() {
      if (isDisabled) {
        return calendarStyle.unavailableStyle;
      } else if (isSelected && calendarStyle.highlightSelected) {
        return calendarStyle.selectedStyle;
      } else if (isToday && calendarStyle.highlightToday) {
        return calendarStyle.todayStyle;
      } else {
        return calendarStyle.dayStyle;
      }
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 2000),
      decoration: _buildCellDecoration(),
      child: Center(
        child: Semantics(
          label: label,
          selected: isSelected,
          child: ExcludeSemantics(
            child: Text(text, style: _buildCellTextStyle()),
          ),
        ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    Key key,
    @required Language language,
    @required Animation<double> chevronOpacityAnimation,
    @required bool isDisplayingFirstMonth,
    @required NepaliDateTime previousMonthDate,
    @required NepaliDateTime date,
    @required bool isDisplayingLastMonth,
    @required NepaliDateTime nextMonthDate,
    @required HeaderStyle headerStyle,
    @required Function() handleNextMonth,
    @required Function() handlePreviousMonth,
    @required this.onHeaderTapped,
    @required this.onHeaderLongPressed,
  })  : _chevronOpacityAnimation = chevronOpacityAnimation,
        _isDisplayingFirstMonth = isDisplayingFirstMonth,
        _previousMonthDate = previousMonthDate,
        date = date,
        _isDisplayingLastMonth = isDisplayingLastMonth,
        _nextMonthDate = nextMonthDate,
        _headerStyle = headerStyle,
        _handleNextMonth = handleNextMonth,
        _handlePreviousMonth = handlePreviousMonth,
        _language = language,
        super(key: key);

  final Animation<double> _chevronOpacityAnimation;
  final bool _isDisplayingFirstMonth;
  final NepaliDateTime _previousMonthDate;
  final NepaliDateTime date;
  final bool _isDisplayingLastMonth;
  final NepaliDateTime _nextMonthDate;
  final HeaderStyle _headerStyle;
  final Function() _handleNextMonth;
  final Function() _handlePreviousMonth;
  final Language _language;
  final HeaderGestureCallback onHeaderTapped;
  final HeaderGestureCallback onHeaderLongPressed;

  _onHeaderTapped() {
    if (onHeaderTapped != null) {
      onHeaderTapped(date);
    }
  }

  _onHeaderLongPressed() {
    if (onHeaderLongPressed != null) {
      onHeaderLongPressed(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _headerStyle.decoration,
      height: _kDayPickerRowHeight,
      child: Row(
        children: <Widget>[
          Semantics(
            sortKey: _MonthPickerSortKey.previousMonth,
            child: FadeTransition(
              opacity: _chevronOpacityAnimation,
              child: IconButton(
                padding: _headerStyle.leftChevronPadding,
                icon: _headerStyle.leftChevronIcon,
                tooltip: _isDisplayingFirstMonth
                    ? null
                    : 'Previous month ${formattedMonth(_previousMonthDate.month, Language.english)} ${_previousMonthDate.year}',
                onPressed:
                    _isDisplayingFirstMonth ? null : _handlePreviousMonth,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _onHeaderTapped,
              onLongPress: _onHeaderLongPressed,
              child: _headerStyle.centerHeaderTitle
                  ? Center(
                      child: _buildTitle(),
                    )
                  : _buildTitle(),
            ),
          ),
          Semantics(
            sortKey: _MonthPickerSortKey.nextMonth,
            child: FadeTransition(
              opacity: _chevronOpacityAnimation,
              child: IconButton(
                padding: _headerStyle.rightChevronPadding,
                icon: _headerStyle.rightChevronIcon,
                tooltip: _isDisplayingLastMonth
                    ? null
                    : 'Next month ${formattedMonth(_nextMonthDate.month, Language.english)} ${_nextMonthDate.year}',
                onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  FadeTransition _buildTitle() {
    return FadeTransition(
      opacity: _chevronOpacityAnimation,
      child: ExcludeSemantics(
        child: Text(
          _headerStyle.titleTextBuilder != null
              ? _headerStyle.titleTextBuilder(
                  date,
                  _language,
                )
              : '${formattedMonth(date.month, _language)} ${_language == Language.english ? date.year : NepaliUnicode.convert('${date.year}')}',
          style: _headerStyle.titleTextStyle,
          textAlign: _headerStyle.centerHeaderTitle
              ? TextAlign.center
              : TextAlign.start,
        ),
      ),
    );
  }
}

const double _kDayPickerRowHeight = 42.0;

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const columnCount = 7;
    final tileWidth = constraints.crossAxisExtent / columnCount;
    final tileHeight = math.min(_kDayPickerRowHeight,
        constraints.viewportMainAxisExtent / (_kMaxDayPickerRowCount + 1));
    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _kDayPickerGridDelegate = _DayPickerGridDelegate();

class _DaysView extends StatelessWidget {
  _DaysView({
    Key key,
    @required this.selectedDate,
    @required this.currentDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    @required this.displayedMonth,
    @required this.language,
    @required this.calendarStyle,
    @required this.headerStyle,
    this.selectableDayPredicate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(selectedDate != null),
        assert(currentDate != null),
        assert(onChanged != null),
        assert(displayedMonth != null),
        assert(dragStartBehavior != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate)),
        super(key: key);

  final NepaliDateTime selectedDate;

  final NepaliDateTime currentDate;

  final ValueChanged<NepaliDateTime> onChanged;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final NepaliDateTime displayedMonth;

  final SelectableDayPredicate selectableDayPredicate;

  final DragStartBehavior dragStartBehavior;

  final Language language;
  final CalendarStyle calendarStyle;
  final HeaderStyle headerStyle;

  List<Widget> _getDayHeaders(Language language, TextStyle headerStyle) {
    return (language == Language.english
            ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            : ['आ', 'सो', 'मं', 'बु', 'वि', 'शु', 'श'])
        .map(
          (label) => ExcludeSemantics(
            child: Center(
              child: Text(label, style: headerStyle),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final year = displayedMonth.year;
    final month = displayedMonth.month;
    final daysInMonth = displayedMonth.totalDays;
    final firstDayOffset = displayedMonth.weekday - 1;
    final labels = <Widget>[];
    if (calendarStyle.renderDaysOfWeek)
      labels.addAll(
        _getDayHeaders(language, themeData.textTheme.caption),
      );
    for (var i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final day = i - firstDayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        labels.add(Container());
      } else {
        final dayToBuild = NepaliDateTime(year, month, day);
        final disabled = dayToBuild.isAfter(lastDate) ||
            dayToBuild.isBefore(firstDate) ||
            (selectableDayPredicate != null &&
                !selectableDayPredicate(dayToBuild));

        final isSelectedDay = selectedDate.year == year &&
            selectedDate.month == month &&
            selectedDate.day == day;
        final bool isCurrentDay = currentDate.year == year &&
            currentDate.month == month &&
            currentDate.day == day;
        final semanticLabel =
            '${formattedMonth(month, Language.english)} $day, $year';
        final text =
            '${language == Language.english ? day : NepaliUnicode.convert('$day')}';

        Widget dayWidget = _DayWidget(
          isDisabled: disabled,
          text: text,
          label: semanticLabel,
          isToday: isCurrentDay,
          isSelected: isSelectedDay,
          calendarStyle: calendarStyle,
          onTap: () {
            onChanged(dayToBuild);
          },
        );

        if (!disabled) {
          dayWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onChanged(dayToBuild);
            },
            child: dayWidget,
            dragStartBehavior: dragStartBehavior,
          );
        }
        labels.add(dayWidget);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: <Widget>[
          Flexible(
            child: GridView.custom(
              gridDelegate: _kDayPickerGridDelegate,
              childrenDelegate:
                  SliverChildListDelegate(labels, addRepaintBoundaries: false),
            ),
          ),
        ],
      ),
    );
  }
}

const Duration _kMonthScrollDuration = Duration(milliseconds: 200);

class _MonthView extends StatefulWidget {
  _MonthView({
    Key key,
    @required this.selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    @required this.language,
    @required this.calendarStyle,
    @required this.headerStyle,
    this.selectableDayPredicate,
    this.onHeaderLongPressed,
    this.onHeaderTapped,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(selectedDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate)),
        super(key: key);

  final NepaliDateTime selectedDate;

  final ValueChanged<NepaliDateTime> onChanged;

  final NepaliDateTime firstDate;

  final NepaliDateTime lastDate;

  final SelectableDayPredicate selectableDayPredicate;

  final DragStartBehavior dragStartBehavior;

  final Language language;

  final CalendarStyle calendarStyle;

  final HeaderStyle headerStyle;
  final HeaderGestureCallback onHeaderTapped;
  final HeaderGestureCallback onHeaderLongPressed;

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<_MonthView>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _chevronOpacityTween =
      Tween<double>(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    // Initially display the pre-selected date.
    final monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
    _dayPickerController = PageController(initialPage: monthPage);
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();

    // Setup the fade animation for chevrons
    _chevronOpacityController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _chevronOpacityAnimation =
        _chevronOpacityController.drive(_chevronOpacityTween);
  }

  @override
  void didUpdateWidget(_MonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      final monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
      _dayPickerController = PageController(initialPage: monthPage);
      _handleMonthPageChanged(monthPage);
    }
  }

  TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    textDirection = Directionality.of(context);
  }

  NepaliDateTime _todayDate;
  NepaliDateTime _currentDisplayedMonthDate;
  Timer _timer;
  PageController _dayPickerController;
  AnimationController _chevronOpacityController;
  Animation<double> _chevronOpacityAnimation;

  void _updateCurrentDate() {
    _todayDate = NepaliDateTime.now();
    final tomorrow = NepaliDateTime(
      _todayDate.year,
      _todayDate.month,
      _todayDate.day + 1,
    );
    var timeUntilTomorrow = tomorrow.difference(_todayDate);
    timeUntilTomorrow +=
        const Duration(seconds: 1); // so we don't miss it by rounding
    _timer?.cancel();
    _timer = Timer(timeUntilTomorrow, () {
      setState(_updateCurrentDate);
    });
  }

  static int _monthDelta(NepaliDateTime startDate, NepaliDateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  NepaliDateTime _addMonthsToMonthDate(
    NepaliDateTime monthDate,
    int monthsToAdd,
  ) {
    int year = monthsToAdd ~/ 12;
    int months = monthDate.month + monthsToAdd % 12;
    if (months > 12) {
      year += months ~/ 12;
      months = months % 12;
    }
    return NepaliDateTime(
      monthDate.year + year,
      months,
    );
  }

  Widget _buildItems(BuildContext context, int index) {
    final month = _addMonthsToMonthDate(widget.firstDate, index);
    return _DaysView(
      key: ValueKey<NepaliDateTime>(month),
      headerStyle: widget.headerStyle,
      calendarStyle: widget.calendarStyle,
      selectedDate: widget.selectedDate,
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      language: widget.language,
      selectableDayPredicate: widget.selectableDayPredicate,
      dragStartBehavior: widget.dragStartBehavior,
    );
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
          "${formattedMonth(_nextMonthDate.month, Language.english)} ${_nextMonthDate.year}",
          textDirection);
      _dayPickerController.nextPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
          "${formattedMonth(_previousMonthDate.month, Language.english)} ${_previousMonthDate.year}",
          textDirection);
      _dayPickerController.previousPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  bool get _isDisplayingFirstMonth {
    return !_currentDisplayedMonthDate
        .isAfter(NepaliDateTime(widget.firstDate.year, widget.firstDate.month));
  }

  bool get _isDisplayingLastMonth {
    return !_currentDisplayedMonthDate
        .isBefore(NepaliDateTime(widget.lastDate.year, widget.lastDate.month));
  }

  NepaliDateTime _previousMonthDate;
  NepaliDateTime _nextMonthDate;

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      _previousMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = _addMonthsToMonthDate(widget.firstDate, monthPage + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kMaxDayPickerHeight,
      child: Column(
        children: <Widget>[
          _CalendarHeader(
            onHeaderLongPressed: widget.onHeaderLongPressed,
            onHeaderTapped: widget.onHeaderTapped,
            language: widget.language,
            handleNextMonth: _handleNextMonth,
            handlePreviousMonth: _handlePreviousMonth,
            headerStyle: widget.headerStyle,
            chevronOpacityAnimation: _chevronOpacityAnimation,
            isDisplayingFirstMonth: _isDisplayingFirstMonth,
            previousMonthDate: _previousMonthDate,
            date: _currentDisplayedMonthDate,
            isDisplayingLastMonth: _isDisplayingLastMonth,
            nextMonthDate: _nextMonthDate,
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                Semantics(
                  sortKey: _MonthPickerSortKey.calendar,
                  child: NotificationListener<ScrollStartNotification>(
                    onNotification: (_) {
                      _chevronOpacityController.forward();
                      return false;
                    },
                    child: NotificationListener<ScrollEndNotification>(
                      onNotification: (_) {
                        _chevronOpacityController.reverse();
                        return false;
                      },
                      child: PageView.builder(
                        dragStartBehavior: widget.dragStartBehavior,
                        key: ValueKey<NepaliDateTime>(widget.selectedDate),
                        controller: _dayPickerController,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            _monthDelta(widget.firstDate, widget.lastDate) + 1,
                        itemBuilder: _buildItems,
                        onPageChanged: _handleMonthPageChanged,
                      ),
                    ),
                  ),
                ),
                /*  PositionedDirectional(
                  top: 0.0,
                  start: 8.0,
                ), */
                /* PositionedDirectional(
                  top: 0.0,
                  end: 8.0,
                  child: 
                ), */
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayPickerController?.dispose();
    super.dispose();
  }
}

// Defines semantic traversal order of the top-level widgets inside the month
// picker.
class _MonthPickerSortKey extends OrdinalSortKey {
  const _MonthPickerSortKey(double order) : super(order);

  static const _MonthPickerSortKey previousMonth = _MonthPickerSortKey(1.0);
  static const _MonthPickerSortKey nextMonth = _MonthPickerSortKey(2.0);
  static const _MonthPickerSortKey calendar = _MonthPickerSortKey(3.0);
}
