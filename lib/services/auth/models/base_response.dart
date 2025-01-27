

class BaseResponse {
  late bool result;
  late String message;

  BaseResponse(this.result, this.message);

  bool getResult() {
    return result;
  }

  String getMessage() {
    return message;
  }

  BaseResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("result")) {
      result = json["result"];
    }
    if (json.containsKey("message")) {
      message = json["message"];
    }
  }
}
