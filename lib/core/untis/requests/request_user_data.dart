import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis/models/user_data/user_data.dart';

/// Requests the user data for the given user in [authParams].
///
/// The request is send to [apiBaseUrl] and uses the [authParams] to authenticate.
Future<UserData> requestUserData(
  String apiBaseUrl,
  AuthParams authParams,
) async {
  var response = await rpcRequest(
    method: 'getUserData2017',
    params: [
      {
        'elementId': 0,
        'deviceOs': 'AND',
        'deviceOsVersion': '',
        ...authParams.toJson(),
      }
    ],
    serverUrl: Uri.parse(apiBaseUrl),
  );
  return response.map(
    result: (result) {
      return UserData.fromJson(result.result);
    },
    error: (error) {
      throw error.error;
    },
  );
}
