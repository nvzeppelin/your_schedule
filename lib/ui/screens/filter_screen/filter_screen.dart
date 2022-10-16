import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/filter/filter.dart';

class FilterScreen extends ConsumerWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter"),
        actions: [
          IconButton(
            onPressed: () => _addFilter(context, ref),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Willst du alle Filter löschen?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Abbrechen"),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(filterItemsProvider.notifier).clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Ok"),
                    ),
                  ],
                ),
              );
            },
            tooltip: "Filter löschen",
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: ListView(
        children: List.generate(
          filters.length,
          (index) => Padding(
            padding: const EdgeInsets.all(4),
            child: Card(
              child: ListTile(
                title: Text(filters[index].longName),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addFilter(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FilterAddPage(),
        fullscreenDialog: true,
      ),
    );

    ///TODO: Push a Page with all the possibleFilters and if selected added to the filter list
  }
}

class FilterAddPage extends ConsumerWidget {
  const FilterAddPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TimeTablePeriodSubjectInformation> currentFilters =
        ref.read(filterItemsProvider);
    List<TimeTablePeriod> possibleFilters = ref
        .read(timeTableProvider)
        .weekData
        .values
        .fold<List<TimeTablePeriod>>(
          [],
          (previous, element) => previous
            ..addAll(
              element.days.values.fold<List<TimeTablePeriod>>(
                [],
                (previousValue, element) =>
                    previousValue..addAll(element.periods),
              ),
            ),
        )
        .where(
          (element) =>
              !currentFilters.any((filter) => element.subject == filter),
        )
        .toList();

    ///I have not yet figured out why the fuck .toSet().toList() is not removing the duplicates. So I am doing it manually.
    List<String> possibleFilterNames = [];
    for (int i = 0; i < possibleFilters.length; i++) {
      TimeTablePeriod period = possibleFilters[i];
      if (!possibleFilterNames.contains(period.subject.longName)) {
        possibleFilterNames.add(period.subject.longName);
      } else {
        possibleFilters.remove(period);
        i--;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wähle einen Kurs"),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: List.generate(
          possibleFilters.length,
          (index) => Padding(
            padding: const EdgeInsets.all(4),
            child: Card(
              child: InkWell(
                onTap: () {
                  ref
                      .read(filterItemsProvider.notifier)
                      .addItem(possibleFilters[index].subject);
                  Navigator.pop(context);
                },
                child: FilterGridTile(
                  subject: possibleFilters[index].subject,
                  teacher: possibleFilters[index].teacher,
                  room: possibleFilters[index].room,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterGridTile extends StatelessWidget {
  const FilterGridTile(
      {required this.subject,
      required this.teacher,
      required this.room,
      super.key});

  final TimeTablePeriodSubjectInformation subject;
  final TimeTablePeriodTeacherInformation teacher;
  final TimeTablePeriodRoomInformation room;

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(subject.name, textAlign: TextAlign.center),
          Text(teacher.longName, textAlign: TextAlign.center),
          Text(room.name, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
