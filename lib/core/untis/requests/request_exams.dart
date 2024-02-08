import 'package:intl/intl.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/util/date.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/week.dart';

/// Requests the exams for the given [week].
///
/// The request is send to [apiBaseUrl] and uses the [authParams] to authenticate.
/// Returns a [Future] with a [Map] of [Date]s and [List]s of [Exam]s.
/// All [Date]s are normalized to the start of the day.
Future<Map<Date, List<Exam>>> requestExams(
  String apiBaseUrl,
  UserData userData,
  AuthParams authParams,
  Week week,
) async {
  var response = await rpcRequest(
    method: 'getExams2017',
    params: [
      {
        'id': userData.id,
        'type': userData.type,
        'startDate': week.startDate.format(DateFormat('yyyy-MM-dd')),
        'endDate': week.endDate.format(DateFormat('yyyy-MM-dd')),
        ...authParams.toJson(),
      }
    ],
    serverUrl: Uri.parse(apiBaseUrl),
  );

  return response.map(
    result: (result) {
      var examSet = (result.result['exams'] as List<dynamic>)
          .map((e) => Exam.fromJson(e))
          .toSet();
      var examMap = <Date, List<Exam>>{};
      for (var i = 0; i < 7; i++) {
        examMap[week.startDate.addDays(i)] = [];
      }
      for (var exam in examSet) {
        examMap[exam.startDateTime.normalized()]!.add(exam);
      }
      for (var i = 0; i < 7; i++) {
        examMap[week.startDate.addDays(i)]!.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      }
      return examMap;
    },
    error: (error) {
      throw error.error;
    },
  );
}
