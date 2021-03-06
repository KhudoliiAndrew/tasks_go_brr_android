import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tasks_go_brr/resources/colors.dart';
import 'package:tasks_go_brr/resources/constants.dart';
import 'package:tasks_go_brr/resources/dimens.dart';
import 'package:tasks_go_brr/resources/icons/icons.dart';
import 'package:tasks_go_brr/resources/routes.dart';
import 'package:tasks_go_brr/ui/custom/animated_gesture_detector.dart';
import 'package:tasks_go_brr/ui/custom/clippers/app_bar_clipper_3.dart';
import 'package:tasks_go_brr/ui/custom/dialog_parts.dart';
import 'package:tasks_go_brr/ui/main/stat/stats_page_view_model.dart';
import 'package:tasks_go_brr/utils/time.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  GlobalKey<ChartWidgetState> chartKey = GlobalKey();
  StatsPageViewModel _model = StatsPageViewModel();

  DateTime _currentDate = DateTime.now();
  double _progressBarHeight = 280.51948051948057;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.background,
      child: FutureBuilder(
        future: _model.initRepo(_currentDate),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            return Stack(
              children: [
                PreferredSize(
                  preferredSize: Size.fromHeight(Dimens.app_bar_height),
                  child: ClipPath(
                    clipper: AppBarClipper3(),
                    child: Container(
                      color: context.secondary,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: _topPageMargin()),
                  width: double.infinity,
                  child: DayProgress(
                      chartKey: chartKey,
                      currentDate: _currentDate,
                      model: _model),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: _topPageMargin(),
                    ),
                    SizedBox(
                      height: _progressBarHeight.h * .8,
                    ),
                    StreakLayout(
                      model: _model,
                      currentDate: _currentDate,
                    ),
                    SizedBox(
                      height: Margin.middle.h,
                    ),
                    ChartWidget(
                        key: chartKey,
                        currentDate: _currentDate,
                        model: _model),
                    SizedBox(
                      height: Margin.big.h + Margin.middle_smaller.h,
                    ),
                  ],
                )
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  double _topPageMargin() {
    return Dimens.getStatusBarHeight(context) + Margin.middle.h;
  }
}

class DayProgress extends StatefulWidget {
  final DateTime currentDate;
  final StatsPageViewModel model;
  final GlobalKey<ChartWidgetState> chartKey;

  const DayProgress(
      {Key? key,
      required this.currentDate,
      required this.model,
      required this.chartKey})
      : super(key: key);

  @override
  _DayProgressState createState() => _DayProgressState();
}

class _DayProgressState extends State<DayProgress> {
  late double maxValue;
  late double initialValue;

  @override
  void initState() {
    maxValue = widget.model.stats.goalOfTasksInDay.toDouble();
    initialValue =
        widget.model.getAllCompletedTasks(widget.currentDate).toDouble();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('day_progress'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction >= 0.5) {
          var completedTasks =
              widget.model.getAllCompletedTasks(widget.currentDate);
          if (initialValue != completedTasks.toDouble())
            setState(() => initialValue = completedTasks.toDouble());
        }
      },
      child: SleekCircularSlider(
        appearance: CircularSliderAppearance(
            size: MediaQuery.of(context).size.width / 1.4,
            angleRange: 200,
            startAngle: 170,
            customWidths: CustomSliderWidths(
              progressBarWidth: 22,
              trackWidth: 18,
            ),
            customColors: CustomSliderColors(
                trackColor: context.surface.withOpacity(.3),
                progressBarColor: context.surface,
                dotColor: Colors.transparent,
                hideShadow: true)),
        initialValue:
        initialValue > maxValue ? maxValue : initialValue,
        max: maxValue,
        min: 0,
        innerWidget: (_) => _widgetInProgressBar(),
        onChange: null,
      ),
    );
  }

  Widget _widgetInProgressBar() {
    return Center(
      child: Container(
        child: AnimatedGestureDetector(
          onTap: () => _showGoalPickerDialog(),
          child: RichText(
              text: TextSpan(
                  text: widget.model.getAllCompletedTasks(widget.currentDate).toString(),
                  style: TextStyle(
                      color: context.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: Dimens.text_big_bigger),
                  children: <TextSpan>[
                    TextSpan(
                        text: "/" + widget.model.stats.goalOfTasksInDay.toString(),
                        style: TextStyle(
                            color: context.onPrimaryAccent,
                            fontSize: Dimens.text_big))
                  ])),
        ),
      ),
    );
  }

  _showGoalPickerDialog() async {
    var currentValue = widget.model.stats.goalOfTasksInDay;
    await showDialog(
      context: context,
      builder: (BuildContext contextDialog) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: Container(
              decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.all(Radiuss.small_smaller)),
              padding: EdgeInsets.symmetric(
                  horizontal: Paddings.small.w, vertical: Paddings.small.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(text: "dialog.how_many_tasks_complete_in_day".tr()),
                  NumberPicker(
                    selectedTextStyle: TextStyle(
                      color: context.primaryAccent,
                      fontSize: Dimens.text_normal_bigger,
                      fontWeight: FontWeight.bold,
                    ),
                    infiniteLoop: true,
                    itemHeight: 50,
                    minValue: Constants.GOAL_TASKS_DAY_MIN,
                    maxValue: Constants.GOAL_TASKS_DAY_MAX,
                    value: currentValue,
                    onChanged: (value) => setState(() => currentValue = value),
                  ),
                  DialogPositiveButton(onTap: () async {
                    widget.model.stats.goalOfTasksInDay = currentValue;
                    maxValue = currentValue.toDouble();
                    widget.chartKey.currentState!.updateChart();
                    await widget.model.updateStats();

                    Routes.back(contextDialog);
                  }),
                ],
              ),
            ),
          );
        });
      },
    ).then((value) => setState(() {}));
  }
}

class StreakLayout extends StatefulWidget {
  final StatsPageViewModel model;
  final DateTime currentDate;

  const StreakLayout({Key? key, required this.model, required this.currentDate}) : super(key: key);

  @override
  _StreakLayoutState createState() => _StreakLayoutState();
}

class _StreakLayoutState extends State<StreakLayout> {
  late int daysInRow;

  @override
  void initState() {
    daysInRow = widget.model.getDaysInRow();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Margin.middle),
      child: VisibilityDetector(
        key: Key('streak_layout'),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction >= 0.5) {
            var completedTasks =
            widget.model.getDaysInRow();
            if (daysInRow != completedTasks)
              setState(() => daysInRow = completedTasks);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _streakWidget("stats.current_streak".tr(), daysInRow),
            SizedBox(
              width: Margin.middle,
            ),
            _streakWidget("stats.beast_streak".tr(), widget.model.stats.maxDaysInRow)
          ],
        ),
      ),
    );
  }

  Widget _streakWidget(String title, int value) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.all(Radiuss.small_very),),
        padding: EdgeInsets.only(left: Paddings.small),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Margin.small,
            ),
            Text(
              title,
              style: TextStyle(
                color: context.onSurface,
                fontSize: Dimens.text_normal,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: Margin.small,
            ),
            RichText(
                text: TextSpan(
                    text: value.toString(),
                    style: TextStyle(
                      color: context.primaryAccent,
                      fontSize: Dimens.text_normal,
                      fontWeight: FontWeight.w500,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: " " + "stats.days_in_a_row".tr(),
                          style: TextStyle(
                              color: context.onSurfaceAccent,
                              fontSize: Dimens.text_small_bigger))
                    ])),
            SizedBox(
              height: Margin.small,
            ),
          ],
        ),
      ),
    );
  }
}

class ChartWidget extends StatefulWidget {
  final DateTime currentDate;
  final StatsPageViewModel model;

  const ChartWidget({Key? key, required this.currentDate, required this.model}) : super(key: key);

  @override
  ChartWidgetState createState() => ChartWidgetState();
}

class ChartWidgetState extends State<ChartWidget> {
  int _countChartDays = 0;
  late double currentValue;
  late double maxValue;

  List<BarChartGroupData> _chartData = [];

  updateChart() =>
      setState(() => maxValue = widget.model.getMaxCompletedTasksInWeek().toDouble());

  @override
  void initState() {
    maxValue = widget.model.getMaxCompletedTasksInWeek().toDouble();
    currentValue = widget.model.getCompletedDefaultTasks(widget.currentDate).toDouble();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _chartData = _getChartData();

    return Expanded(
      child: VisibilityDetector(
        key: Key('chart_progress'),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction >= 0.5) {
            if (maxValue != widget.model.stats.goalOfTasksInDay.toDouble())
              setState(() => maxValue =
                  widget.model.getMaxCompletedTasksInWeek().toDouble());
            if (currentValue !=
                widget.model
                    .getCompletedDefaultTasks(widget.currentDate)
                    .toDouble()) setState(() {});
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.all(Radiuss.small_very),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: Margin.middle,
          ),
          child: Stack(
            children: [
              _chartWidget(),
              Container(
                margin: EdgeInsets.only(right: Margin.small, top: Margin.small),
                alignment: Alignment.topRight,
                child: AnimatedGestureDetector(
                  onTap: () => _openHelpDialog(),
                  child: Icon(
                    IconsC.help,
                    size: Dimens.quiestion_button_size,
                    color: context.onSurface.withOpacity(.5),
                  ),
                ),
              ),
              _emptyPlaceholderWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartWidget() {
    return _countChartDays != 0 ? Container(
      margin: EdgeInsets.only(
        right: Paddings.middle,
        top: Paddings.middle,
        left: Paddings.small,
        bottom: Paddings.small,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: context.surfaceAccent.withOpacity(0.9),
                tooltipRoundedRadius: 10.0,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  var countTaskDefault =
                  rod.rodStackItems[0].toY.toInt();
                  var countTaskRegular = (rod.rodStackItems[1].toY -
                      rod.rodStackItems[0].toY)
                      .toInt();
                  return BarTooltipItem(
                    DateTime.now()
                        .add(Duration(days: 1 + group.x.toInt()))
                        .weekday
                        .getDayTitle() +
                        '\n',
                    TextStyle(
                      color: context.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: Dimens.text_normal_smaller,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "${"default".tr()}: $countTaskDefault\n"
                            .toLowerCase() +
                            "${"regular".tr()}: $countTaskRegular"
                                .toLowerCase(),
                        style: TextStyle(
                          color: context.onSurfaceAccent,
                          fontSize: Dimens.text_small_bigger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => TextStyle(
                  color: context.onSurfaceAccent, fontSize: 10),
              margin: Margin.small,
              getTitles: (double value) => DateTime.now()
                  .add(Duration(days: 1 + value.toInt()))
                  .weekday
                  .getDayTitleShort(),
            ),
            leftTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => TextStyle(
                  color: context.onSurfaceAccent,
                  fontSize: Dimens.text_small),
              margin: Margin.small.w,
            ),
          ),
          gridData: FlGridData(
            show: true,
            checkToShowHorizontalLine: (value) => true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.onSurface.withOpacity(.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: _chartData,
        ),
      ),
    ) : Container();
  }

  Widget _emptyPlaceholderWidget() {
    return _countChartDays == 0
        ? Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    margin: EdgeInsets.symmetric(horizontal: Margin.big.w),
                    child: Image.asset(
                      ImagePath.CAT_CHART,
                      color: context.onSurface,
                    )),
                SizedBox(
                  height: Margin.middle.h,
                ),
                Text(
                  "error.no_chart_data".tr(),
                  style: TextStyle(
                      color: context.onSurface,
                      fontSize: Dimens.text_big,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        : Container();
  }

  List<BarChartGroupData> _getChartData() {
    List<BarChartGroupData> list = [];
    _countChartDays = 0;

    for (int i = 0; i < 7; i++) {
      var day = DateTime.now().subtract(Duration(days: 6 -  i));

      var completedDefaultTasks = widget.model.getCompletedDefaultTasks(day);
      var completedRegularTasks = widget.model.getCompletedRegularTasks(day);

      if(completedDefaultTasks > 0 || completedRegularTasks > 0)
        _countChartDays++;

      list.add(BarChartGroupData(
        x: i,
        barsSpace: 40,
        barRods: [
          BarChartRodData(
              width: Dimens.chart_bar_width,
              y: (completedDefaultTasks + completedRegularTasks)
                  .toDouble(),
              rodStackItems: [
                BarChartRodStackItem(0, completedDefaultTasks.toDouble(),
                    context.secondaryAccent),
                BarChartRodStackItem(
                    completedDefaultTasks.toDouble(),
                    (completedDefaultTasks + completedRegularTasks)
                        .toDouble(),
                    context.primaryAccent),
              ],
              borderRadius: BorderRadius.all(Radiuss.circle)),
        ],
      ));
    }
    return list;
  }

  _openHelpDialog() {
    showDialog(
        context: context,
        builder: (contextDialog) => AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          content: Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.all(Radiuss.small_smaller),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: Paddings.small, vertical: Paddings.middle),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _colorExplanation(
                    context.primaryAccent, "dialog.expl_default_task".tr()),
                SizedBox(
                  height: Margin.small,
                ),
                _colorExplanation(
                    context.secondaryAccent, "dialog.expl_regular_task".tr())
              ],
            ),
          ),
        ));
  }

  Widget _colorExplanation(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radiuss.circle),
          ),
        ),
        SizedBox(
          width: Margin.small.w,
        ),
        Flexible(
          child: Text(text,
              style: TextStyle(
                  fontSize: Dimens.text_small_bigger,
                  color: context.onSurfaceAccent),
              textAlign: TextAlign.left),
        ),
      ],
    );
  }
}
