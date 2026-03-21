import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart' hide Data;
import 'package:get_storage/get_storage.dart' as storage;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pawlli/core/auth/authservice.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api_logger.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
import 'package:pawlli/data/model/PetStoreCategariesModel.dart' hide Data;
import 'package:pawlli/data/model/TransactionnsModel.dart';
import 'package:pawlli/data/model/WalletBalancemodel.dart'as Balance;
import 'package:pawlli/data/model/adoptioncreation.dart';
import 'package:pawlli/data/model/allpetradiomodel.dart'as All;
import 'package:pawlli/data/model/cartviewmodel.dart';
import 'package:pawlli/data/model/competition_model.dart';
import 'package:pawlli/data/model/createpetmodel.dart' hide Data;
import 'package:pawlli/data/model/descriptionmodel.dart';
import 'package:pawlli/data/model/editadoptionmodel.dart';
import 'package:pawlli/data/model/getpetprofile.dart';
import 'package:pawlli/data/model/getuserprofilemodel.dart';
import 'package:pawlli/data/model/goodbyebuddylistmodel.dart';
import 'package:pawlli/data/model/languagemodel.dart';
import 'package:pawlli/data/model/mysubscriptionmodel.dart';
import 'package:pawlli/data/model/notificationmodel.dart';
import 'package:pawlli/data/model/ordermodel.dart';
import 'package:pawlli/data/model/paymentmodel.dart';
import 'package:pawlli/data/model/paymentverificationmodel.dart';
import 'package:pawlli/data/model/paythroughwallet.dart';
import 'package:pawlli/data/model/petslistmodel.dart' hide Data;
import 'package:pawlli/data/model/petstoresubcategaries.dart';
import 'package:pawlli/data/model/pettheraphymodel.dart';
import 'package:pawlli/data/model/podcastlistmodel.dart' hide Data;
import 'package:pawlli/data/model/productVariantmodel.dart';
import 'package:pawlli/data/model/productpromotionmodel.dart';
import 'package:pawlli/data/model/programlistmodel.dart' hide Data;
import 'package:pawlli/data/model/promotionmodel.dart';
import 'package:pawlli/data/model/recentpetchatmodel.dart';
import 'package:pawlli/data/model/reelUploadmodel.dart';
import 'package:pawlli/data/model/reelitemmodel.dart';
import 'package:pawlli/data/model/singledescriptionmodel.dart';
import 'package:pawlli/data/model/slotcreationmodel.dart'as slot;
import 'package:pawlli/data/model/storeprocductmodel.dart' hide Data;
import 'package:pawlli/data/model/storesearchmodel.dart';
import 'package:pawlli/data/model/subcategarymodel.dart' as sub;
import 'package:pawlli/data/model/therapyslot.dart';
import 'package:pawlli/data/model/topupmodel.dart';
import 'package:pawlli/data/model/typesofcategaries.dart'as typesofcategaries;
import 'package:pawlli/data/model/loginmodel.dart' hide Data;
import 'package:pawlli/data/model/signupmodel.dart' hide Data;
import 'package:pawlli/data/model/otpmodel.dart' hide Data;
import 'package:pawlli/data/model/updatepetmodel.dart';
import 'package:pawlli/data/model/updateprofilemodel.dart';
import 'package:pawlli/data/model/useradoptionmodel.dart';
import 'package:pawlli/data/model/viewadpotionmodel.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';

import 'package:pawlli/data/model/podcastepisodemodel.dart' as podcast;
import 'package:pawlli/data/model/PetStoreCategariesModel.dart' as categoryModel;

import 'package:pawlli/data/model/storeprocductmodel.dart' as productModel;



import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:http_parser/http_parser.dart';


class ApiService {
  
  static Future<http.Response> get(String url) async {
    final ok = await AuthService.refreshTokenIfNeeded();
    if (!ok) throw Exception("Authorization failed");

    return http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${LocalStorage.getAccessToken()}',
        'Content-Type': 'application/json',
      },
    );
  }

  static Future<String?> getAccessToken() async {
    final box = GetStorage();
    final isTestLogin = box.read(LocalStorageConstants.isTestLogin) == true;

    if (isTestLogin) {
      print("🟡 Test login – access token not required.");
      return null;
    }

    var accessToken = box.read(LocalStorageConstants.access);

    if (accessToken == null || isTokenExpired(accessToken)) {
      print("Access token missing or expired, attempting refresh...");
      accessToken = await refreshToken();

      if (accessToken == null) {

  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }

      }
    }

    print("Access Token: $accessToken");
    return accessToken;
  }

  static Future<String?> refreshToken() async {
    final box = GetStorage();
    final isTestLogin = box.read(LocalStorageConstants.isTestLogin) == true;

    if (isTestLogin) {
      print("🛑 Skipping token refresh for test login user.");
      return null;
    }

    var refreshToken = box.read(LocalStorageConstants.refresh);
    if (refreshToken == null) {
      print("No refresh token found. Logging out user.");
  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }


      return null;
    }

    try {
      var response = await http.post(
        Uri.parse(AppUrl.RefershTokenURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refresh": refreshToken}),
      );

      print('Refresh token response status: ${response.statusCode}');
      print('Refresh token response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('access') && jsonResponse.containsKey('refresh')) {
          String newAccessToken = jsonResponse['access'];
          String newRefreshToken = jsonResponse['refresh'];

          box.write(LocalStorageConstants.access, newAccessToken);
          box.write(LocalStorageConstants.refresh, newRefreshToken);

          return newAccessToken;
        }
      } else {
        final jsonResponse = jsonDecode(response.body);
        if ((jsonResponse['error'] == "Invalid token") ||
            response.statusCode == 401 ||
            response.statusCode == 403) {
          print("Refresh token invalid or expired. Logging out.");
          if (response.statusCode == 401) {
  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }
}

        }
      }
    } catch (e) {
      print('Error while refreshing token: $e');
    }

    return null;
  }

  // static void handleTokenExpiration() {
  //   final box = GetStorage();
  //   final isTestLogin = box.read(LocalStorageConstants.isTestLogin) == true;

  //   if (isTestLogin) {
  //     print("🔁 Skipping logout for test login user.");
  //     return;
  //   }

  //   box.remove(LocalStorageConstants.access);
  //   box.remove(LocalStorageConstants.refresh);
  //   box.remove(LocalStorageConstants.sessionManager);
  //   box.remove(LocalStorageConstants.userId);

  //   print("User must re-login. Redirecting to LoginPage...");

  //   // Use delayed navigation to avoid context issues
  //   Future.delayed(Duration.zero, () {
  //     if (Get.context != null) {
  //       Get.offAll(() => LoginPage());
  //     } else {
  //       print("⚠️ No context found. Navigation may not work.");
  //     }
  //   });
  // }

  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return now >= exp;
    } catch (e) {
      print("⚠️ Error decoding token: $e");
      return true;
    }
  }

static Future<OptModel> OtpApi({
  required String email,
  String? username,
  String? mobile,
  required String purpose,
  required bool isResend,
}) async {
  final headers = {'Content-Type': 'application/json'};

  final Map<String, dynamic> bodyMap = {
    "email": email,
    "purpose": purpose,
    "is_resend": isResend,
  };

  if (username != null) bodyMap["username"] = username;
  if (mobile != null) bodyMap["mobile"] = mobile;

  final body = jsonEncode(bodyMap);

  print('📤 Request Body: $body');

  try {
    final response = await http
        .post(Uri.parse(AppUrl.OtpURL), headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    print('📥 Response Status Code: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    final Map<String, dynamic> json = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
        return OptModel.fromJson(json);

      case 400:
      case 401:
      case 403:
      case 404:
        throw Exception(
          '${json['code'] ?? 'UNKNOWN'}: ${json['message'] ?? 'Something went wrong'}',
        );

      case 429:
        throw Exception(
          '${json['code'] ?? 'TOO_MANY_REQUESTS'}: ${json['message'] ?? 'Too many requests. Please try later.'}',
        );

      default:
        throw Exception(
          'UNKNOWN: Failed to get OTP: ${json['message'] ?? 'Unexpected server error'}',
        );
    }
  } on TimeoutException {
    throw Exception('TIMEOUT: Request timed out. Please try again.');
  } on FormatException {
    throw Exception('FORMAT_ERROR: Invalid response format from server.');
  } catch (e) {
    print('❌ Unexpected Error: $e');

    if (e is SocketException || e is http.ClientException) {
      throw Exception('SERVER_ERROR: Server error. Please try again later.');
    }

    if (e is TimeoutException) {
      throw Exception('TIMEOUT: Request timed out. Please try again.');
    }

    // Re-throw specific errors to preserve original messages
    if (e is Exception && e.toString().contains(':')) {
      throw e;
    }

    throw Exception('UNKNOWN_ERROR: Something went wrong. Please try again.');
  }
}
static Future<SignupModel> signupApi({
  required String username,
  required String mobile,
  required String email,
  required String otp,
  required String fcm_token,
  required String apns_token,

}) async {
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    "username": username,
    "mobile": mobile,
    "email": email,
    "otp": otp,
    "fcm_token": fcm_token,
    "apns_token": apns_token,
  });

  print('Request Body: $body');

  try {
    final response = await http.post(
      Uri.parse(AppUrl.SignUpURL),
      body: body,
      headers: headers,
    );

    print('Response Body: ${response.body}');

    final json = jsonDecode(response.body);
    final signupModel = SignupModel.fromJson(json);

    print('Parsed status: ${signupModel.status}');

    // Return the model regardless of status code — your backend seems to always return JSON in response body
    return signupModel;

  } catch (e) {
    print('Signup API error: $e');
    return SignupModel(
      status: false,
      message: 'Something went wrong. Please try again.',
      code: 'NETWORK_ERROR',
      data: null,
    );
  }
}

static Future<LoginModel> loginAPI({
  required String email,
  required String otp,
  required bool through_google,
  required String fcm_token,
  required String apns_token,
}) async {
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    "email": email,
    "otp": otp,
    "through_google": through_google,
    "fcm_token":fcm_token,
    "apns_token": apns_token,
  });

  try {
    print("Request Body: $body");

    final response = await http.post(
      Uri.parse(AppUrl.LoginURL),
      body: body,
      headers: headers,
    );

    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final json = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage = json['message'] ?? 'Unknown error';
      throw ApiException(message: errorMessage, statusCode: response.statusCode);
    }

    return LoginModel.fromJson(json);
  } catch (e) {
    print("Login Exception: $e");

    if (e is ApiException) {
      // Re-throw to handle in controller
      throw e;
    }

    throw ApiException(
      message: "Something went wrong. Please try again.",
      statusCode: 500,
    );
  }
}


  
  static Future<List<typesofcategaries.Data>> fetchAllCategories() async {
  try {
    String? accessToken = await getAccessToken(); // Get or refresh access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.get(
      Uri.parse(AppUrl.allCatagoryURL),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['data'] != null && responseBody['data'] is List) {
        return (responseBody['data'] as List)
            .map((item) => typesofcategaries.Data.fromJson(item))
            .toList();
      } else {
        throw Exception("Invalid response format: 'data' key is missing or not a list");
      }
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        return fetchAllCategories();
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      throw Exception("Failed to load categories. Status code: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error: $e");
  }
}

 static Future<List<sub.Data>> fetchAllSubCategories(int categoryId) async {
  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final url = '${AppUrl.allSubCatagoryURL}$categoryId';
    print(url);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['data'] != null && responseBody['data'] is List) {
        return (responseBody['data'] as List)
            .map((item) => sub.Data.fromJson(item))
            .toList();
      } else {
        throw Exception("Invalid response format: 'data' key is missing or not a list");
      }
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        return fetchAllSubCategories(categoryId);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      throw Exception("Failed to load subcategories. Status code: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error: $e");
  }
}



  static Future<List<SingleCategoryModel>> fetchCategories(int subcategoryId) async {
  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final url = '${AppUrl.SingleCategaryURL}$subcategoryId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print(url);
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final decodedBody = json.decode(response.body);

      if (decodedBody is List) {
        // Response is a JSON list directly
        return decodedBody
            .map<SingleCategoryModel>((item) => SingleCategoryModel.fromJson(item))
            .toList();
      } else if (decodedBody is Map<String, dynamic>) {
        // Response is a JSON object - try to find the list inside
        if (decodedBody['data'] != null && decodedBody['data'] is List) {
          return (decodedBody['data'] as List)
              .map<SingleCategoryModel>((item) => SingleCategoryModel.fromJson(item))
              .toList();
        } else if (decodedBody['categories'] != null && decodedBody['categories'] is List) {
          return (decodedBody['categories'] as List)
              .map<SingleCategoryModel>((item) => SingleCategoryModel.fromJson(item))
              .toList();
        } else {
          throw Exception(
              "Invalid response format: Expected a list in 'data' or 'categories' key");
        }
      } else {
        throw Exception(
            "Invalid response format: Expected a JSON list or object");
      }
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        return fetchCategories(subcategoryId);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print('Error: ${response.body}');
      throw Exception(
          "Failed to load categories. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print('Error fetching categories: $e');
    throw Exception("Error fetching categories: $e");
  }
}

static Future<PetDescription?> fetchPetDescription(int petId) async {
  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final url = '${AppUrl.DescriptionURL}$petId';
    print("API Request URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return PetDescription.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        return fetchPetDescription(petId);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('API Request Failed: $e');
    return null;
  }
}

static Future<All.AllPetRadioModel?> fetchAllPetRadio() async {
  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.get(
      Uri.parse(AppUrl.AllPetRadioURL),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("API Request URL: ${AppUrl.AllPetRadioURL}");
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return All.AllPetRadioModel.fromJson(responseData);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        return fetchAllPetRadio();
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('API Request Failed: $e');
    return null;
  }
}


static Future<slot.SlotPageModel?> fetchSlots(
  int radioid,
  String day,
  String date,
) async {
  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final uri = Uri.parse('${AppUrl.SlotURL}/$radioid?date=$date');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("API Request URL: $uri");
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    print("Requested Date: $date");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return slot.SlotPageModel.fromJson(responseData);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        return fetchSlots(radioid, day, date);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('API Request Failed: $e');
    return null;
  }
}

 static Future<LanguageCreationModel?> fetchLanguage() async {
  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final uri = Uri.parse(AppUrl.LanguageURL);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("API Request URL: $uri");
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return LanguageCreationModel.fromJson(responseData);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        return fetchLanguage();
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      return null;
    }
  } catch (e) {
    print("API Request Failed: $e");
    return null;
  }
}

 static Future<Balance.WalletBalanceModel?> fetchWalletBalance(
  int? userId, {
  bool retry = true,
}) async {
  final box = storage.GetStorage();
  userId ??= box.read(LocalStorageConstants.userId);

  if (userId == null) {
    print("❌ userId is null. Cannot fetch wallet balance.");
    return null;
  }

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      print("❌ No access token");
      return null;
    }

    final uri = Uri.parse("${AppUrl.walletbalanceURL}/$userId/");
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("API Request URL: $uri");
    print("Response Status Code: ${response.statusCode}");
    print("Wallet API BODY:");
    print(response.body);


    if (response.statusCode == 200) {
      final contentType = response.headers['content-type']?.toLowerCase();

      if (contentType == null || !contentType.contains('application/json')) {
        print("❌ Wallet API returned NON-JSON response");
        print(response.body);
        return null;
      }

      if (response.body.trim().startsWith('<')) {
        print("❌ Wallet API returned HTML");
        return null;
      }
      
if (response.body.trim().startsWith('<')) {
  print("❌ Wallet API returned HTML — skipping parse");
  return null;
}
      final Map<String, dynamic> responseData =
      
          json.decode(response.body);

      if (responseData["data"] == null) {
        print("❌ Wallet API missing 'data'");
        return null;
      }

      return Balance.WalletBalanceModel.fromJson(responseData);
    }

    if (response.statusCode == 401 && retry) {
      print("🔄 Access token expired. Refreshing...");
      final newToken = await refreshToken();

      if (newToken != null) {
        return fetchWalletBalance(userId, retry: false);
      }
    }

    print("❌ Wallet API error: ${response.statusCode}");
    return null;
  } catch (e) {
    print("❌ Wallet API exception: $e");
    return null;
  }
}


static Future<TopUPModel?> topUpWallet({
  required int userId,
  required double amount,
  required String purpose,
}) async {
  try {
    String? accessToken = await getAccessToken(); 
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.post(
      Uri.parse(AppUrl.OrderCreationURL),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",  
      },
      body: jsonEncode({
        "user_id": userId,
        "amount": amount.toInt(), 
        "purpose": purpose,
      }),
    );

    print("🟢 API Request URL: ${AppUrl.OrderCreationURL}");
    print("🟢 Request Body: ${jsonEncode({
      "user_id": userId,
      "amount": amount.toInt(),
      "purpose": purpose,
    })}");
    print("🟢 Response Status Code: ${response.statusCode}");
    print("🟢 Response Body: ${response.body}");

    if (response.statusCode == 200|| response.statusCode == 201) {
      var jsonResponse = jsonDecode(response.body);
      return TopUPModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      // ✅ Token expired, refresh and retry
      print("🔄 Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        return topUpWallet(userId: userId, amount: amount, purpose: purpose);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print("❌ Error: ${response.statusCode}, ${response.body}");
      return null;
    }
  } catch (e) {
    print("❌ Exception in topUpWallet: $e");
    return null;
  }
}

static Future<TransactionsModel?> fetchtransaction({required int userId}) async {
  try {
    String? accessToken = await getAccessToken(); 
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.get(
      Uri.parse("${AppUrl.TranactionURL}/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",  
      },
     
    );

    print(" API Request URL: ${AppUrl.TranactionURL}/$userId");
    print(" Request Body: ${jsonEncode({"user_id": userId})}");
    print(" Response Status Code: ${response.statusCode}");
    print(" Response Body: ${response.body}");

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return TransactionsModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      print("🔄 Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        return fetchtransaction(userId: userId);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print(" Error: ${response.statusCode}, ${response.body}");
      return null;
    }
  } catch (e) {
    print(" Exception in fetchTransaction: $e");
    return null;
  }
}
static Future<ProgramListModel?> fetchProgramList(int userId,int radioid, String date) async {
  final box = storage.GetStorage();
  userId ??= box.read(LocalStorageConstants.userId); 
  try {
    String? accessToken = await getAccessToken();  
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.get(
      Uri.parse("${AppUrl.ProgramListURL}/$radioid/$date/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    print(" API Request kumar: ${AppUrl.ProgramListURL}/$radioid/$date/$userId");
    print(" Response Status Code: ${response.statusCode}");
    print(" Response Body: ${response.body}");
    print("🔍 RAW API Response: ${response.body}");

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return ProgramListModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      print("🔄 Access token expired. Refreshing...");
      String? newAccessToken = await refreshToken();

      if (newAccessToken != null) {
        // Retry the request with the new access token
        return fetchProgramList( userId,radioid, date);
      } else {
        print(" Failed to refresh token. Logging out user...");
       if (response.statusCode == 401) {
  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }
}

        return null;
      }
    } else {
      print(" Error: ${response.statusCode}, ${response.body}");
      return null;
    }
  } catch (e) {
    print("Exception in fetchProgramList: $e");
    return null;
  }
}


static Future<PaymentVerificationModel?> verifyPayment({
  required String razorpay_order_id,
  String? razorpay_payment_id,
  String? razorpay_signature,
  int? failureErrorCode,
  String? failureErrorMessage,
  bool retryingAfterRefresh = false,
}) async {
  try {
    // 🛡️ Validate order ID
    if (razorpay_order_id.isEmpty) {
      Fluttertoast.showToast(msg: "Order ID is missing.");
      return null;
    }

    // 🔑 Get access token
    String? guestToken = await getAccessToken();
    if (guestToken == null) {
      Fluttertoast.showToast(msg: "Session expired. Please log in again.");
      return null;
    }

    var headers = {
      'Authorization': 'Bearer $guestToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // If razorpay_signature is missing, use a default value or empty string
    if (razorpay_signature == null || razorpay_signature.isEmpty) {
      razorpay_signature = 'default_signature';  // Placeholder value
    }

   var requestBody = {
    'razorpay_order_id': razorpay_order_id,
    'razorpay_signature': (razorpay_signature?.isNotEmpty ?? false) ? razorpay_signature : "N/A", // Send signature
    'razorpay_payment_id': (razorpay_payment_id?.isNotEmpty ?? false) ? razorpay_payment_id : "N/A", // Always include this field
    if (failureErrorCode != null) 'failure_error_code': failureErrorCode,
    if (failureErrorMessage != null) 'failure_error_message': failureErrorMessage,
    };


    // 🧾 Log full request body
    print("📤 Payment verification request body: $requestBody");

    var response = await http.post(
      Uri.parse(AppUrl.PaymentVerifiedURL),
      body: jsonEncode(requestBody),
      headers: headers,
    );

    String rawResponse = response.body;
    print("🔹  Payment API Response (${response.statusCode}): $rawResponse");
    if (!rawResponse.startsWith("{")) {
      print("⚠️ Non-JSON response detected. Cannot parse.");
      Fluttertoast.showToast(msg: "Unexpected response from server.");
      return null;
    }

    dynamic responseBody;
    try {
      responseBody = json.decode(rawResponse);
    } catch (e) {
      print("❌ JSON Parsing Error: $e - Response: $rawResponse");
      Fluttertoast.showToast(msg: "Payment verification failed due to an error.");
      return null;
    }

    // 🔁 Retry on token expiry
    if (response.statusCode == 401 && !retryingAfterRefresh) {
      print("🔄 Guest token expired. Refreshing...");
      String? newToken = await refreshToken();

      if (newToken != null) {
        return verifyPayment(
          razorpay_order_id: razorpay_order_id,
          razorpay_payment_id: razorpay_payment_id,
          razorpay_signature: razorpay_signature,
          failureErrorCode: failureErrorCode,
          failureErrorMessage: failureErrorMessage,
          retryingAfterRefresh: true,
        );
      } else {
        Fluttertoast.showToast(msg: "Session expired. Please log in again.");
        return null;
      }
    }
    print(" Response Status Code: ${response.statusCode}");
    print(" Response Body: ${response.body}");

    // ✅ Success Case
    if (response.statusCode == 200) {
      print("✅  Payment Verified: $responseBody");
      return PaymentVerificationModel.fromJson(responseBody);
    }

    // ❌ Handle Known Failure (400)
    if (response.statusCode == 400) {
      print("❌ Payment Verification Failed: $responseBody");

      String errorMessage = responseBody['message'] ?? "Payment Failed.";
      String paymentMethod = responseBody['payment_method'] ?? "Unknown";
      double amount = responseBody['amount'] is num
          ? (responseBody['amount'] as num).toDouble()
          : double.tryParse(responseBody['amount']?.toString() ?? '0.0') ?? 0.0;
      String currency = responseBody['currency'] ?? "INR";
      String? date = responseBody['date']?.toString();

      var verifiedModel = PaymentVerificationModel(
        message: errorMessage,
        orderId: responseBody['order_id']?.toString() ?? razorpay_order_id,
        paymentId: responseBody['payment_id']?.toString() ?? "N/A",
        status: responseBody['status']?.toString() ?? "Failed",
        paymentMethod: paymentMethod,
        date: date,
        amount: amount,
      );

      print("✅ Final Assigned Values -> Amount: ₹$amount, Order ID: ${verifiedModel.orderId}, "
          "Date: ${verifiedModel.date}, Payment Method: ${verifiedModel.paymentMethod}, "
          "Message: ${verifiedModel.message}");

      return verifiedModel;
    }

    // 🚨 Unhandled errors
    print("⚠️ Unhandled Error: ${response.statusCode} - $responseBody");
    Fluttertoast.showToast(msg: "Payment verification failed.");
    return null;

  } catch (e) {
    print("❌ Error verifying payment: $e");
    Fluttertoast.showToast(msg: "An error occurred while verifying payment.");
    return null;
  }
}

static Future<GetUserProfileModel?> fetchUserProfile(int? userId) async {
   final box = storage.GetStorage();
  userId ??= box.read(LocalStorageConstants.userId); // Retrieve from storage if null

  if (userId == null) {
    print("Error: userId is null. Cannot fetch wallet balance.");
    return null;
  }
  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.get(
     Uri.parse("${AppUrl.GetProfileURL}/$userId"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("API Request URL: ${AppUrl.GetProfileURL}/$userId");
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return GetUserProfileModel.fromJson(responseData);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        return fetchUserProfile( userId);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('API Request Failed: $e');
    return null;
  }
}
static Future<PetsListModel?> fetchUserPets(int? userId) async {
  final box = storage.GetStorage();
  userId ??= box.read(LocalStorageConstants.userId); // Retrieve from storage if null

  if (userId == null) {
    print("Error: userId is null. Cannot fetch pets list.");
    return null;
  }

  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.get(
      Uri.parse("${AppUrl.PetslistURL}/$userId"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("API Request URL: ${AppUrl.PetslistURL}/$userId");
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData.containsKey('data')) {
        return PetsListModel.fromJson(jsonData); // ✅ Return entire object
      } else {
        print("Invalid API response: Missing or incorrect 'data' field.");
        return null;
      }
    } else if (response.statusCode == 401) {
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        return fetchUserPets(userId); // Retry with new token
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('API Request Failed: $e');
    return null;
  }
}
static Future<List<PromotionModel>> fetchPromotions() async {
  final box = GetStorage();
  String? fetchedToken = box.read(LocalStorageConstants.access);

  if (fetchedToken == null) {
    fetchedToken = await refreshToken();
    if (fetchedToken == null) return [];
    box.write(LocalStorageConstants.access, fetchedToken);
  }

  final url = AppUrl.PromotionCardUrl;
  const int maxAttempts = 3;
  const timeoutDuration = Duration(seconds: 30);
  int retryAttempts = 0;

  while (retryAttempts < maxAttempts) {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $fetchedToken",
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
          print("✅ Promotion Response: ${response.body}");
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((e) => PromotionModel.fromJson(e)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Token expired or forbidden. Attempting refresh...');
        fetchedToken = await refreshToken();
        if (fetchedToken != null) {
          box.write(LocalStorageConstants.access, fetchedToken);
          retryAttempts++;
          continue;
        } else {
          print('Token refresh failed.');
          return [];
        }
      } else {
        print('Server error ${response.statusCode}');
        return [];
      }
    } on TimeoutException {
      retryAttempts++;
      print('Timeout attempt $retryAttempts');
      if (retryAttempts >= maxAttempts) return [];
    } catch (e) {
      print('Unexpected error: $e');
      return [];
    }
  }

  return [];
}

static Future<List<StoreProductData>> searchStoreProducts(String query) async {
  try {
    final token = LocalStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("${AppUrl.petStoreSearchURL}?q=$query"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      print("RAW Search JSON: $jsonData");

      final List results = jsonData['results'];

      return results
          .map((e) => StoreProductData.fromJson(e))
          .toList();
    } else {
      return [];
    }
  } catch (e) {
    debugPrint("Search API Error: $e");
    return [];
  }
}


static Future<List<PromotionModel>> StorePromotions() async {
  try {
    String? accessToken = await getAccessToken();
    final url = "https://app.pawdli.com/user/store-promotion1/";

    print("📡 PROMOTION API URL → $url");

    final res = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Accept": "application/json",
      },
    );

    print("📡 PROMOTION STATUS → ${res.statusCode}");
    print("📡 PROMOTION RAW RESPONSE → ${res.body}");

    if (res.statusCode != 200) {
      print("❌ PROMOTION API FAILED");
      return [];
    }

    final decoded = json.decode(res.body);

    /// ✅ FIX: backend uses `data`, not `promotions`
    final List list =
        decoded["data"] ??
        decoded["promotions"] ??
        [];

    print("✅ PROMOTION LIST SIZE → ${list.length}");

    return list
        .map((e) => PromotionModel.fromJson(e))
        .toList();
  } catch (e, st) {
    print("❌ StorePromotions API Error → $e");
    print(st);
    return [];
  }
}


static Future<List<Productpromotionmodel>> fetchProductPromotions() async {
  final box = GetStorage();
  String? fetchedToken = box.read(LocalStorageConstants.access);

  if (fetchedToken == null) {
    fetchedToken = await refreshToken();
    if (fetchedToken == null) return [];
    box.write(LocalStorageConstants.access, fetchedToken);
  }

  final url = "https://app.pawdli.com/user/store-promotion2/";
  const int maxAttempts = 3;
  const timeoutDuration = Duration(seconds: 30);
  int retryAttempts = 0;

  while (retryAttempts < maxAttempts) {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $fetchedToken",
          "Content-Type": "application/json",
        },
      ).timeout(timeoutDuration);

      print("📡 PRODUCT PROMOTION STATUS: ${response.statusCode}");
      print("📡 PRODUCT PROMOTION BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        /// API returns:
        /// { success: true, count: 2, promotions: [...] }
        if (data["promotions"] != null && data["promotions"] is List) {
          final list = data["promotions"] as List;

          print("✅ Parsed ${list.length} PRODUCT promotions");

          return list
              .map((e) => Productpromotionmodel.fromJson(e))
              .toList();
        } else {
          print("⚠️ promotions field missing or empty");
          return [];
        }
      }

      else if (response.statusCode == 401 || response.statusCode == 403) {
        print("🔐 Token expired → Refreshing...");
        fetchedToken = await refreshToken();

        if (fetchedToken != null) {
          box.write(LocalStorageConstants.access, fetchedToken);
          retryAttempts++;
          continue;
        } else {
          print("❌ Token refresh failed");
          return [];
        }
      }

      else {
        print("❌ Server error: ${response.statusCode}");
        return [];
      }
    }

    on TimeoutException {
      retryAttempts++;
      print("⏳ Timeout attempt: $retryAttempts");
      if (retryAttempts >= maxAttempts) return [];
    }

    catch (e) {
      print("❌ Unexpected Product Promotion Error: $e");
      return [];
    }
  }

  return [];
}






static Future<UpdateProfileModel?> updateUserProfile(UpdateProfileModel model, String userId) async {
  if (userId.isEmpty) {
    print("❌ Error: userId is empty. Cannot update profile.");
    return null;
  }

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("No valid access token found.");
    }

    // Construct the URL
    final url = Uri.parse("${AppUrl.UpdateProfileURL}/$userId/");
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $accessToken';
  print('Constructed URL: $url');

    // Add fields
    request.fields.addAll({
      'id': userId,
      if (model.password != null) 'password': model.password!,
      if (model.username != null) 'username': model.username!,
      if (model.name != null) 'name': model.name!,
      if (model.gender != null) 'gender': model.gender!,
      if (model.address != null) 'address': model.address!,
      if (model.age != null) 'age': model.age.toString(),
      if (model.dob != null) 'dob': model.dob!,
      if (model.mobile != null) 'mobile': model.mobile!,
      if (model.email != null) 'email': model.email!,
      if (model.pincode != null) 'pincode': model.pincode.toString(),
      if (model.bio != null) 'bio': model.bio!,
      if (model.registeredat != null) 'registeredat': model.registeredat!,
      if (model.city != null) 'city': model.city!,
      if (model.country != null) 'country': model.country!,
      if (model.state != null) 'state': model.state!,
      if (model.throughGoogle != null) 'through_google': model.throughGoogle.toString(),
      if (model.fcmToken != null) 'fcm_token': model.fcmToken!,
      if (model.isActive != null) 'is_active': model.isActive.toString(),
      if (model.updatedAt != null) 'updated_at': model.updatedAt!,
      if (model.currencyPreference != null) 'currency_preference': model.currencyPreference!,
    });

    // Handle profile picture
    if (model.profilePicture != null && model.profilePicture!.isNotEmpty) {
      final imageFile = File(model.profilePicture!);
      if (await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
    }

    print("📤 Sending profile update request...");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("✅ Status: ${response.statusCode}");
    print("📨 Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UpdateProfileModel.fromJson(data);
    } else if (response.statusCode == 401) {
      print("🔁 Token expired, refreshing...");
      final newToken = await refreshToken();
      if (newToken != null) {
        return updateUserProfile(model, userId); // Retry
      } else {
        throw Exception("❌ Token refresh failed. Please login again.");
      }
    } else {
      print("❗ Error ${response.statusCode}: ${response.reasonPhrase}");
      return null;
    }
  } catch (e) {
    print("❌ Exception in updateUserProfile: $e");
    return null;
  }
}
static Future<CreatePetModel> createPet(Map<String, dynamic> petData) async {
  final String url = AppUrl.CreatePetUrl;

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("No valid access token found.");
    }

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $accessToken';

    print("📤 Preparing multipart request...");
    for (var entry in petData.entries) {
      final key = entry.key;
      final value = entry.value;

if (key == 'pet_profile_image' && value != null && value is File) {
        final file = value;
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
      'pet_profile_image',
            file.path,
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      } else if (value != null) {
        request.fields[key] = value.toString();
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("✅ Status: ${response.statusCode}");
    print("📨 Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreatePetModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      print("🔁 Token expired, refreshing...");
      final newToken = await refreshToken();
      if (newToken != null) {
        return await createPet(petData);
      } else {
        throw Exception("Token refresh failed. Please login again.");
      }
    } else {
    
      throw ApiException(
        message: response.body, // you might parse this to get message field
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    print("❌ Exception in createPet: $e");
    rethrow;  // <-- IMPORTANT: rethrow error so controller can catch it
  }
}

static Future<GetPetProfileModel?> fetchPetProfile(int? petId) async {
  if (petId == null) {
    print("Error: userId is null. Cannot fetch wallet balance.");
    return null;
  }
  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.get(
     Uri.parse("${AppUrl.GetPetProfileUrl}/$petId"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("API Request URL: ${AppUrl.GetPetProfileUrl}/$petId/");
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return GetPetProfileModel.fromJson(responseData);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        return fetchPetProfile( petId);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('API Request Failed: $e');
    return null;   
  }
}
static Future<bool> uploadGoodByeBuddy({
  required String location,
  double? latitude,    
  double? longitude,    
  required String landmark,
  required String description,
  required List<File> imageFiles,
  bool isRetry = false,
}) async {
  try {
    print("🟢 ===== GoodByeBuddy API START =====");

    String? accessToken = await getAccessToken();
    print("🔐 Access token exists: ${accessToken != null}");

    if (accessToken == null) {
      throw Exception("No access token");
    }

    final Uri apiUrl = Uri.parse(AppUrl.GoodByeBuddyUrl);
    print("🌐 API URL: $apiUrl");

    final request = http.MultipartRequest('POST', apiUrl);

    // 🔐 HEADERS
    request.headers.addAll({
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });

    print("📦 Headers: ${request.headers}");

    // 📝 FIELDS
    request.fields['location'] = location;
    request.fields['landmark'] = landmark;
    request.fields['description'] = description;
    if (latitude != null) {
      request.fields['latitude'] = latitude.toString();
    }
    if (longitude != null) {
      request.fields['longitude'] = longitude.toString();
    }

    print("📝 Fields:");
    print("   location    = $location");
    print("📍 Latitude  = $latitude");
    print("📍 Longitude = $longitude");
    print("   landmark    = $landmark");
    print("   description = $description");

    // 🖼 FILES
    print("🖼 Image files count: ${imageFiles.length}");

    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];

      print("   ➕ image[$i]");
      print("      path: ${file.path}");
      print("      exists: ${file.existsSync()}");

        request.files.add(
        await http.MultipartFile.fromPath(
          'images', // ✅ SAME KEY AS POSTMAN
          file.path,
          filename: file.path.split('/').last,
        ),
      );
    }

    print("📤 Multipart files attached: ${request.files.length}");
    for (var f in request.files) {
      print("   field=${f.field}, filename=${f.filename}");
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("📥 Status: ${response.statusCode}");
    print("📥 Body: ${response.body}");
    print("🔴 ===== GoodByeBuddy API END =====");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.statusCode == 401 && !isRetry) {
      print("♻️ Token expired, refreshing...");
      final newToken = await refreshToken();
      if (newToken != null) {
        return await uploadGoodByeBuddy(
          location: location,
          latitude: latitude,     
          longitude: longitude,     
          landmark: landmark,
          description: description,
          imageFiles: imageFiles,
          isRetry: true,
        );
      }
    }

    return false;
  } catch (e) {
    print("❌ Upload error: $e");
    return false;
  }
}

static Future<GoodbyeRequestDetailsModel?> getGoodbyeRequestDetails({
  required int requestId,
}) async {
  try {
    final box = GetStorage();

    final response = await http.get(
      Uri.parse("${AppUrl.GoodByeBuddyListUrl}$requestId/"),
      headers: {
        "Authorization":
            "Bearer ${box.read(LocalStorageConstants.access)}",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return GoodbyeRequestDetailsModel.fromJson(data["data"]);
    } else {
      print("API ERROR: ${response.body}");
    }
  } catch (e) {
    print("Fetch request details error: $e");
  }

  return null;
}

 static Future<http.StreamedResponse> completeRequest({
    required int requestId,
    required String description,
    required List<File> images,
    String? token,
  }) async {

    final url = Uri.parse(
      "$baseUrl/goodbye-buddy/$requestId/admin-update/",
    );

    var request = http.MultipartRequest('POST', url);

    /// 🔐 HEADERS
    request.headers.addAll({
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    /// 📦 BODY
    request.fields['status'] = "completed";
    request.fields['admin_description'] = description;

    /// 📸 IMAGES
    for (var img in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images', // ⚠️ confirm if backend expects "images"
          img.path,
        ),
      );
    }

    /// 🚀 SEND REQUEST
    return await request.send();
  }

static Future<Map<String, dynamic>?> startCall({
  required int userId,
  required int bookingId,
  required String callType,
  bool retry = true,
}) async {
  final body = jsonEncode({
    "user_id": userId,
    "booking_id": bookingId,
    "call_type": callType,
  });

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("No access token available");

    final response = await http.post(
      Uri.parse(AppUrl.StartCallUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: body,
    );

    final responseData = json.decode(response.body);
    print("📞 Start Call Response: $responseData");

    if (response.statusCode == 200) {
      return {
        "status_code": 200,
        "response": responseData,
        
      };
    } else if (response.statusCode == 400 &&
    responseData['existing_session_id'] != null) {

  final existingSessionId = responseData['existing_session_id'];

  debugPrint("♻️ Existing live session found: $existingSessionId");

  return {
    "status_code": 200,
    "response": {
      "session_id": existingSessionId,
      "reuse": true,
    },
  };
}
else if (response.statusCode == 401 && retry) {
      print("🔄 Token expired. Refreshing...");
      accessToken = await refreshToken();
      if (accessToken != null) {
        return startCall(
          userId: userId,
          bookingId: bookingId,
          callType: callType,
          retry: false,
        );
      }
    }

    return {
      "status_code": response.statusCode,
      "response": responseData,
    };
  } catch (e) {
    print("🚨 Exception in startCall: $e");
    return null;
  }
}

static Future<Map<String, dynamic>?> restartCall(
  int userId,
  int sessionId, {
  bool retry = true,
}) async {
  final requestBody = jsonEncode({
    "user_id": userId,
    "session_id": sessionId,
  });

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("No access token found");

    final response = await http.post(
      Uri.parse(AppUrl.ReStartCallUrl),
      body: requestBody,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('➡️ Restart API response: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401 && retry) {
      print("🔁 Token expired. Refreshing...");
      accessToken = await refreshToken();
      if (accessToken != null) {
        return restartCall(userId, sessionId, retry: false);
      } else {
        throw Exception("Token refresh failed. Please login again.");
      }
    }

    return {
      "status_code": response.statusCode,
      "response": json.decode(response.body),
    };
  } catch (e) {
    print("❌ Exception in rejoinCall: $e");
    return null;
  }
}


static Future<Map<String, dynamic>?> joinCall({
  required int userId,
  required int sessionId,
  bool retry = true,
}) async {
  final bodyData = {
    "user_id": userId,
    "session_id": sessionId,
  };

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("No access token found");

    final response = await http.post(
      Uri.parse(AppUrl.JoinCallUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(bodyData),
    );

    print('Join Call Request Body: $bodyData');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('✅ Join Call Response: $responseData');

      return {
        "status_code": response.statusCode,
        "response": responseData,
      };
    } else if (response.statusCode == 401 && retry) {
      print("🔁 Token expired. Refreshing...");
      accessToken = await refreshToken();
      if (accessToken != null) {
        return joinCall(userId: userId, sessionId: sessionId, retry: false);
      } else {
        throw Exception("Token refresh failed. Please login again.");
      }
    } else {
      print('❌ Error Response: ${response.statusCode} - ${response.body}');
      return {
        "status_code": response.statusCode,
        "response": jsonDecode(response.body),
      };
    }
  } catch (e) {
    print('🚨 Join Call Exception: $e');
    return null;
  }
}


static Future<Map<String, dynamic>?> rejoinlisternerCall({
  required int userId,
  required int sessionId,
  bool retry = true,
}) async {
  final bodyData = {
    "user_id": userId,
    "session_id": sessionId,
  };

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("No access token available");

    final response = await http.post(
      Uri.parse(AppUrl.ReJoinCallUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(bodyData),
    );

    final responseData = jsonDecode(response.body);
    print('🔄 Rejoin Listener Call Response: $responseData');

    if (response.statusCode == 200) {
      return {
        "status_code": 200,
        "response": responseData,
      };
    } else if (response.statusCode == 401 && retry) {
      print("🔁 Token expired, attempting refresh...");
      accessToken = await refreshToken();
      if (accessToken != null) {
        return rejoinlisternerCall(
          userId: userId,
          sessionId: sessionId,
          retry: false,
        );
      } else {
        throw Exception("Token refresh failed. Please login again.");
      }
    }

    return {
      "status_code": response.statusCode,
      "response": responseData,
    };
  } catch (e) {
    print('❌ Rejoin Listener Call Exception: $e');
    return null;
  }
}
static Future<bool> endCall({
  required int userId,
  required int sessionId,
  bool retry = true,
}) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("No access token found");

    final response = await http.post(
      Uri.parse(AppUrl.EndCallUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode({
        "user_id": userId,
        "session_id": sessionId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401 && retry) {
      print("🔁 Token expired. Refreshing...");

      // Attempt token refresh
      String? refreshedToken = await refreshToken();
      if (refreshedToken != null) {
        return endCall(userId: userId, sessionId: sessionId, retry: false);
      } else {
        print("Token refresh failed. Please login again.");
      }
    } else {
      print('End Call Failed - Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (e) {
    print('End Call Exception: $e');
  }
  return false;
}

static Future<bool> LeaveCall({
  required int userId,
  required int sessionId,
  bool retry = true,
}) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("No access token found");

    final response = await http.post(
      Uri.parse(AppUrl.LeaveCallUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode({
        "user_id": userId,
        "session_id": sessionId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401 && retry) {
      print("🔁 Token expired. Refreshing...");

      // Attempt token refresh
      String? refreshedToken = await refreshToken();
      if (refreshedToken != null) {
        return LeaveCall(userId: userId, sessionId: sessionId, retry: false);
      } else {
        print("Token refresh failed. Please login again.");
      }
    } else {
      print('Leave Call Failed - Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (e) {
    print('Leave Call Exception: $e');
  }
  return false;
}

static Future<UpdatePetModel?> updatePetProfile(UpdatePetModel model, String petId) async {
  if (petId.isEmpty) {
    print("❌ Error: petId is empty. Cannot update pet profile.");
    return null;
  }

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("🔐 No valid access token found.");
    }

    final url = Uri.parse("${AppUrl.UpdatePetUrl}/$petId/update/");
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $accessToken';

    print('🔗 Constructed URL: $url');

    final pet = model.data;

    // Format date_of_birth as yyyy-MM-dd
    String formattedDob = pet.dateOfBirth;
    try {
      formattedDob = DateFormat('yyyy-MM-dd').format(DateTime.parse(pet.dateOfBirth));
    } catch (e) {
      print("⚠️ Warning: Failed to parse/format date_of_birth, sending original value.");
    }

    request.fields.addAll({
      'pet_id': pet.petId.toString(),
      'name': pet.name,
      // 'age': pet.age.toString(),
      'gender': pet.gender,
      'weight': pet.weight.toString(),
      'height': pet.height.toString(),
      'location': pet.location,
      'description': pet.description,
     if (pet.microchipNumber != null && pet.microchipNumber!.isNotEmpty)
      'microchip_number': pet.microchipNumber!,

      'date_of_birth': formattedDob,
      'neutered_or_spayed': pet.neuteredOrSpayed.toString(),
      'category': pet.category.toString(),
      'subcategory': pet.subcategory.toString(),
      'owner': pet.owner.toString(),
    });

    if (pet.petProfileImage != null && pet.petProfileImage!.isNotEmpty) {
  // Only upload if it's a local file path, not a URL
  if (!pet.petProfileImage!.startsWith("http")) {
    final imageFile = File(pet.petProfileImage!);
    if (await imageFile.exists()) {
      request.files.add(await http.MultipartFile.fromPath(
        'pet_profile_image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    } else {
      print("⚠️ Local image file does not exist at: ${imageFile.path}");
    }
  } else {
    print("ℹ️ Skipping image upload, backend URL already provided: ${pet.petProfileImage}");
  }
}

print(request.fields);
    print("📤 Sending pet update request...");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
   print(streamedResponse);
    print("✅ Status: ${response.statusCode}");
    print("📨 Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UpdatePetModel.fromJson(data);
    } else if (response.statusCode == 401) {
      print("🔁 Token expired, attempting refresh...");
      final newToken = await refreshToken();
      if (newToken != null) {
        return updatePetProfile(model, petId); 
      } else {
        throw Exception("❌ Token refresh failed. Please login again.");
      }
    } else {
      print("❗ Error ${response.statusCode}: ${response.reasonPhrase}");

      if (response.statusCode == 400) {
        final errorResponse = json.decode(response.body);

        // Extract first error message
        String errorMessage = "Something went wrong.";
        if (errorResponse is Map<String, dynamic> && errorResponse.isNotEmpty) {
          final firstKey = errorResponse.keys.first;
          final messages = errorResponse[firstKey];
          if (messages is List && messages.isNotEmpty) {
            errorMessage = messages.first.toString();
          }
        }

        // Show error to user via Get.snackbar
        Get.snackbar(
          "Update Failed",
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colours.primarycolour,
          colorText: Colours.secondarycolour,
          duration: Duration(seconds: 4),
        );
      }

      return null;
    }
  } catch (e) {
    print(" Exception in updatePetProfile: $e");
    return null;
  }}
static Future<List<ProgramData>> fetchAllSubscription(int userId) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final url = '${AppUrl.mysusbcriptionsUrl}/$userId/';
    print("Fetching URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      SubscriptionModel model = SubscriptionModel.fromJson(responseBody);
      return model.data; // This is the list of ProgramData
    } else if (response.statusCode == 401) {
      // Handle token refresh if 401 status code is returned
      accessToken = await refreshToken();
      if (accessToken != null) {
        print("Token refreshed, retrying request...");
        return fetchAllSubscription(userId);  // Retry with new token
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      throw Exception("Failed to load subscriptions. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error occurred: $e");
    rethrow;  // Re-throw the error to handle it further up the call stack
  }
}


static Future<String?> getStoredUserId() async {
  final box = GetStorage();
  return box.read('user_id')?.toString() ?? box.read('userid')?.toString();
}

static Future<Map<String, dynamic>?> createOrder({
  required int userId,
  required List<int> cartIds,
  required double walletAmountUsed,
  required double amount,
  required String shippingAddress,
  required String billingAddress,
}) async {
  final token = await getAccessToken();
  final body = {
    "user_id": userId,
    "cart_ids": cartIds,
    "wallet_amount_used": walletAmountUsed,
    "amount": amount.toStringAsFixed(2),
    "currency": "INR",
    "purpose": "PetStore",
    "payment_mode": "Razorpay",
    "shipping_address": shippingAddress,
    "billing_address": billingAddress,
  };

  final res = await http.post(
    Uri.parse(AppUrl.OrderCreationURL),
    headers: {
      if (token != null) "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  if (res.statusCode == 200) return jsonDecode(res.body);
  return null;
}

static Future<bool> payThroughWalletApi({
  required int userId,
  required List<int> cartIds,
  required double walletAmountUsed,
  required String shippingAddress,
  required String billingAddress,
}) async {
  final token = await getAccessToken();
  final body = {
    "user_id": userId,
    "cart_ids": cartIds,
    "wallet_amount_used": walletAmountUsed,
    "currency": "INR",
    "amount": walletAmountUsed.toStringAsFixed(2),
    "purpose": "PetStore",
    "payment_mode": "Wallet",
    "shipping_address": shippingAddress,
    "billing_address": billingAddress,
  };

  final res = await http.post(
    Uri.parse(AppUrl.paythroughwalletUrl),
    headers: {
      if (token != null) "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  if (res.statusCode == 200) {
    final d = jsonDecode(res.body);
    return d["status"] == "success";
  }
  return false;
}


static Future<PayThroughWalletModel> initiatePayment({
  required String amount,
  required String currency,
  required List<int> bookingId,
  required String purpose,
  required String receipt,
  required String programName,
  required String programDescription,
  required List<String> language,
  required String date,
  required String programType,
  required String userId,
}) async {
  final url = Uri.parse('${AppUrl.paythroughwalletUrl}');
  print(url);

  final body = jsonEncode({
    "amount": amount,
    "currency": currency,
    "booking_id": bookingId,
    "purpose": purpose,
    "receipt": receipt,
    "program_name": programName,
    "program_description": programDescription,
    "language": language,
    "date": date,
    "program_type": programType,
    "user_id": userId,
  });
  print(body);

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: body,
    );

    print(response.body);

    if (response.statusCode == 200) {
      return PayThroughWalletModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      // Instead of throwing, parse and return the error
      final data = json.decode(response.body);
      return PayThroughWalletModel(
        status: "failed",
        message: data["message"] ?? "Unknown error",
      );
    } else if (response.statusCode == 401) {
      print('Unauthorized (401) - Refreshing token...');
      accessToken = await refreshToken();

      if (accessToken != null) {
        return await initiatePayment(
          amount: amount,
          currency: currency,
          bookingId: bookingId,
          purpose: purpose,
          receipt: receipt,
          programName: programName,
          programDescription: programDescription,
          language: language,
          date: date,
          programType: programType,
          userId: userId,
        );
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      final data = json.decode(response.body);
      return PayThroughWalletModel(
        status: "failed",
        message: data["message"] ?? "Failed with status: ${response.statusCode}",
      );
    }
  } catch (e) {
    print('Error sending payment details: $e');
    return PayThroughWalletModel(
      status: "failed",
      message: "Network error or unexpected issue",
    );
  }
}

static Future<PayThroughWalletModel> initiatelisternerPayment({
    required String amount,
    required String currency,
    required String bookingId,
    required String purpose,
    required String receipt,
    required String programName,
    required String programDescription,
    required List<String> language,
    required String date,
    required String programType,
    required String userId,
  }) async {
   final url = Uri.parse('${AppUrl.paythroughwalletUrl}');
print(url);

    final body = jsonEncode({
      "amount": amount,
      "currency": currency,
      "booking_id": bookingId,
      "purpose": purpose,
      "receipt": receipt,
      "program_name": programName,
      "program_description": programDescription,
      "language": language,
      "date": date,
      "program_type": programType,
      "user_id": userId,
    });
print(body);

    try {
      // Fetch access token
      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception("Authorization failed: No valid access token");
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );print(response.body);

    
    if (response.statusCode == 200) {
      return PayThroughWalletModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      // Instead of throwing, parse and return the error
      final data = json.decode(response.body);
      return PayThroughWalletModel(
        status: "failed",
        message: data["message"] ?? "Unknown error",
      );
    } else if (response.statusCode == 401) {
      print('Unauthorized (401) - Refreshing token...');
      accessToken = await refreshToken();

        
        if (accessToken != null) {
          // Retry the request with the new token
          return initiatelisternerPayment(
            amount: amount,
            currency: currency,
            bookingId: bookingId,
            purpose: purpose,
            receipt: receipt,
            programName: programName,
            programDescription: programDescription,
            language: language,
            date: date,
            programType: programType,
            userId: userId,
          );
        } else {
          throw Exception("Failed to refresh token. User must re-login.");
        }
      } else {
        throw Exception('Failed to process payment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending payment details: $e');
      throw Exception('Error in network or API');
    }
  }
static Future<List<PaymentModel>?> fetchpayments({required int userId}) async {
  try {
    String? accessToken = await getAccessToken(); 
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    // Build the request URL
    final requestUrl = "${AppUrl.myPaymentsUrl}?user_id=$userId";
    print("API Request URL: $requestUrl");

    // Make the API call
    final response = await http.get(
      Uri.parse(requestUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",  
      },
    );

    // Log response status and body
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    // Handle response status code
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => PaymentModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      print("🔄 Access token expired. Refreshing...");
      accessToken = await refreshToken();
      if (accessToken != null) {
        return fetchpayments(userId: userId);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print("❌ Error: ${response.statusCode}, ${response.body}");
      return null;
    }
  } catch (e) {
    print("❗ Exception in fetchpayments: $e");
    return null;
  }
}
static Future<List<NoticationModel>?> fetchnotifications({required int userId}) async {
  try {
    String? accessToken = await getAccessToken(); 
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    // Build the request URL
    final requestUrl = "${AppUrl.NotificationUrl}/$userId";
    print("API Request URL: $requestUrl");

    // Make the API call
    final response = await http.get(
      Uri.parse(requestUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",  
      },
    );

    // Log response status and body
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    // Handle response status code
   if (response.statusCode == 200) {
  final decodedBody = utf8.decode(response.bodyBytes); // ✅ Proper decoding
  List<dynamic> jsonResponse = jsonDecode(decodedBody);

      return jsonResponse.map((json) => NoticationModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      print("🔄 Access token expired. Refreshing...");
      accessToken = await refreshToken();
      if (accessToken != null) {
        return fetchnotifications(userId: userId);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print("❌ Error: ${response.statusCode}, ${response.body}");
      return null;
    }
  } catch (e) {
    print("❗ Exception in fetchpayments: $e");
    return null;
  }
}
static Future<bool> sendFriendRequest({required int userId}) async {
  try {
    String? accessToken = await getAccessToken(); 
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final requestUrl = "${AppUrl.sendrequestUrl}";
    print("API Request URL: $requestUrl");

    final response = await http.post(
      Uri.parse(requestUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode({"userId": userId}),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      print("✅ Friend request sent successfully");
      return true;
    } else if (response.statusCode == 401) {
      print("🔄 Access token expired. Refreshing...");
      accessToken = await refreshToken();
      if (accessToken != null) {
        return sendFriendRequest(userId: userId);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print("❌ Error: ${response.statusCode}, ${response.body}");
      return false;
    }
  } catch (e) {
    print("❗ Exception in sendFriendRequest: $e");
    return false;
  }
}



 static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      print('📡 Starting POST request to $endpoint');
      print('📦 Request body: $body');

      String? accessToken = await getAccessToken();
      print('🔑 Access token: ${accessToken != null ? "exists" : "null"}');
      
      if (accessToken == null) {
        throw Exception("Authorization failed: No valid access token");
      }

      final uri = Uri.parse('${AppUrl.mainURL}$endpoint');
      print('🔗 Full URL: $uri');

      // First request attempt
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      print('🔄 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      // If token expired, try refreshing
      if (response.statusCode == 401) {
        print("🔄 Access token expired. Attempting refresh...");
        accessToken = await refreshToken();

        if (accessToken == null) {
          throw Exception("Failed to refresh token. User must re-login.");
        }

        // Retry request with new token
        response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(body),
        );

        print('🔄 Retry response status: ${response.statusCode}');
        print('📨 Retry response body: ${response.body}');
      }

   
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print(' Successful response: $responseData');
        return responseData;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception('Client error: ${response.statusCode}. ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('‼️ Critical error: $e');
      print('🔄 Stack trace: $stackTrace');
      throw Exception('API request failed: $e');
    }
  }
static Future<List<RecentPetChat>?> fetchRecentPetChat({
  String? petId,
  int retryCount = 0,
}) async {
  const int _maxRetries = 1;

  if (retryCount > _maxRetries) {
    print("Too many retries. Aborting.");
    return null;
  }

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final requestUrl = petId != null && petId.isNotEmpty
        ? '${AppUrl.recentchatUrl}?pet_id=$petId'
        : AppUrl.recentchatUrl;

    print("API Request URL: $requestUrl");

    final response = await http
        .get(
          Uri.parse(requestUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
        )
        .timeout(const Duration(seconds: 30));

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((json) => RecentPetChat.fromJson(json))
            .toList();
      } catch (e) {
        print("❗ JSON parsing error: $e");
        return null;
      }
    } else if (response.statusCode == 401) {
      print("🔄 Access token expired. Refreshing...");
      accessToken = await refreshToken();
      if (accessToken != null) {
        return fetchRecentPetChat(petId: petId, retryCount: retryCount + 1);
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print("❌ Error: ${response.statusCode}, ${response.body}");
      return null;
    }
  } on TimeoutException catch (e) {
    print("⏱️ Request timed out: $e");
    return null;
  } catch (e) {
    print("❗ Exception in fetchRecentPetChat: $e");
    return null;
  }
}

static Future<Map<String, dynamic>?> getSessionInfo(int sessionId) async {
  try {
    String? accessToken = await getAccessToken(); // Ensure valid access token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final url = '${AppUrl.sessioninfoUrl}$sessionId';
    print("🔗 API Request URL: $url");

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("📨 Response Status Code: ${response.statusCode}");
    print("📨 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh
      print("🔄 Access token expired. Attempting to refresh...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry request with new token
        print("🔁 Retrying request with refreshed token...");
        return await getSessionInfo(sessionId); // Recursive retry
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print('❗ Error: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('‼️ API Request Failed: $e');
    return null;
  }
}
static Future<AdoptionCreationResponse> createAdoptionRequest(Map<String, dynamic> adoptionData) async {
  final String url = AppUrl.adoptionCreationUrl;

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("No valid access token found.");
    }
 adoptionData.removeWhere((k, v) => v == null || v.toString().trim().isEmpty);
    adoptionData.remove('dateOfBirth'); // use only snake_case

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $accessToken';

    print("📤 Preparing adoption multipart request...");

    for (var entry in adoptionData.entries) {
      final key = entry.key;
      final value = entry.value;

      // Handle image file
     if (key == 'pet_profile_image' && value != null && value is File) {
  final file = value;
  if (await file.exists()) {
    print("📸 Adding image file: ${file.path}");
    request.files.add(await http.MultipartFile.fromPath(
      'pet_profile_image',
      file.path,
      contentType: MediaType('image', 'jpeg'),
    ));
  }
}



      // Handle normal form fields
      else if (value != null) {
        request.fields[key] = value.toString();
      }
    }
print("📦 Fields: ${request.fields}");
request.files.forEach((f) {
  print("📁 File: ${f.field} = ${f.filename}, contentType=${f.contentType}");
});

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("✅ Adoption Status: ${response.statusCode}");
    print("📨 Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AdoptionCreationResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      print("🔁 Access token expired, refreshing...");
      final newToken = await refreshToken();
      if (newToken != null) {
        return await createAdoptionRequest(adoptionData); // retry
      } else {
        throw Exception("Token refresh failed. Please login again.");
      }
    } else {
      throw ApiException(
        message: response.body,
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    print("❌ Exception in createAdoptionRequest: $e");
    rethrow;
  }
}

  static Future<List<ViewAdoptionPet>> fetchAdoptionPets() async {
    try {
      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception("Authorization failed: No valid access token.");
      }

      final response = await http.get(
        Uri.parse(AppUrl.ViewAdoptionCreationUrl), 
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
print( AppUrl.ViewAdoptionCreationUrl);
      if (response.statusCode == 200) {
        final List<dynamic> responseBody = json.decode(response.body);
        return responseBody.map((json) => ViewAdoptionPet.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Unauthorized, try refreshing the token
        print("Access token expired. Refreshing...");
        accessToken = await refreshToken();

        if (accessToken != null) {
          return fetchAdoptionPets(); // Retry
        } else {
          throw Exception("Session expired. Please login again.");
        }
      } else {
        throw Exception("Failed to load adoption pets. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error while fetching adoption pets: $e");
    }
  }
static Future<Editadoptionmodel?> updateAdoptionPetProfile(Editadoptionmodel pet, String Id) async {
  if (Id.isEmpty) {
    print("❌ Error: petId is empty. Cannot update adoption pet profile.");
    return null;
  }

  try {
    String? accessToken = await getAccessToken();
    print("🔑 Access token retrieved: ${accessToken != null ? 'Yes' : 'No'}");

    if (accessToken == null) {
      throw Exception("🔐 No valid access token found.");
    }

    final url = Uri.parse("${AppUrl.UpdateAdoptionUrl}/$Id/");
    print('🔗 Constructed URL: $url');

    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $accessToken';

    final data = pet.data;
    if (data == null) {
      print("⚠️ No data available in Editadoptionmodel to update.");
      return null;
    }

    print("📋 Raw data in model:");
    print("   Name: ${data.name}");
    print("   Age: ${data.age}");
    print("   Gender: ${data.gender}");
    print("   Location: ${data.location}");
    print("   DOB: ${data.dateOfBirth}");
    print("   Weight: ${data.weight}");
    print("   Height: ${data.height}");
    print("   Spayed: ${data.isNeuteredOrSpayed}");
    print("   Free: ${data.isFree}, Paid: ${data.isPaid}");
    print("   Mobile: ${data.mobileNumber}");
    print("   Description: ${data.description}");
    print("   Microchip: ${data.microchipNumber}");
    print("   isAvailable: ${data.isAvailable}, isSoldout: ${data.isSoldout}");
    print("   Pet Image Path: ${data.petProfileImage}");

    // Format DOB
    String? formattedDob = data.dateOfBirth;
    if (formattedDob != null && formattedDob.isNotEmpty) {
      try {
        formattedDob = DateFormat('yyyy-MM-dd').format(DateTime.parse(formattedDob));
        print("📆 Formatted DOB: $formattedDob");
      } catch (e) {
        print("⚠️ Failed to parse/format DOB: ${data.dateOfBirth}");
      }
    }

    request.fields.addAll({
      'name': data.name ?? '',
      'age': data.age?.isNotEmpty == true ? data.age! : '',
      'gender': data.gender ?? 'Male',
      'location': data.location ?? 'Bangalore',
      'weight': data.weight ?? '',
      'height': data.height?.toString() ?? '',
      'description': data.description ?? '',
      'neutered_or_spayed': data.isNeuteredOrSpayed.toString(),
      'date_of_birth': formattedDob ?? '',
      'mobile_number': data.mobileNumber ?? '',
      'message': data.message ?? '',
      'microchip_number': data.microchipNumber ?? '',
      'is_available': data.isAvailable.toString(),
      'is_free': data.isFree.toString(),
      'is_paid': data.isPaid.toString(),
      'is_soldout': data.isSoldout.toString(),
    });

    if (data.preferences != null) {
      try {
        request.fields['preferences'] = json.encode(data.preferences);
        print("🧪 Encoded preferences: ${request.fields['preferences']}");
      } catch (e) {
        print("⚠️ Failed to encode preferences: $e");
      }
    }

    // File upload
    if (data.petProfileImage != null &&
        data.petProfileImage!.isNotEmpty &&
        !data.petProfileImage!.startsWith('http')) {
      final imageFile = File(data.petProfileImage!);
      if (await imageFile.exists()) {
        print("🖼️ Attaching pet profile image...");
        request.files.add(await http.MultipartFile.fromPath(
          'pet_profile_image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        print("⚠️ Image file does not exist at: ${imageFile.path}");
      }
    } else {
      print("📷 No new image selected or existing image is a URL.");
    }

    print("📤 Sending adoption pet update request...");
    print("📦 Payload fields: ${jsonEncode(request.fields)}");

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("✅ Status: ${response.statusCode}");
    print("📨 Body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Editadoptionmodel.fromJson(responseData);
    } else if (response.statusCode == 401) {
      print("🔁 Token expired, attempting refresh...");
      final newToken = await refreshToken();
      if (newToken != null) {
        return updateAdoptionPetProfile(pet, Id);
      } else {
        throw Exception("❌ Token refresh failed. Please login again.");
      }
    } else {
      print("❗ Error ${response.statusCode}: ${response.reasonPhrase}");
      try {
        final errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ??
                              errorResponse['detail'] ??
                              errorResponse.toString();

        print("❌ Server returned error message: $errorMessage");

        Get.snackbar(
          "Update Failed",
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } catch (e) {
        print("⚠️ Failed to parse error body: $e");
        Get.snackbar(
          "Error",
          "Something went wrong. Try again later.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }

      return null;
    }
  } catch (e, stackTrace) {
    print("❌ Exception in updateAdoptionPetProfile: $e");
    print("🧾 Stack trace: $stackTrace");
    Get.snackbar(
      "Error",
      "An unexpected error occurred",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
    return null;
  }
}

   static Future<List<UserAdoptionModel>> fetchUserAdoptionPets(int? userId) async {
  final box = storage.GetStorage();
  userId ??= box.read(LocalStorageConstants.userId); // Retrieve from storage if null

  if (userId == null) {
    print("❌ Error: userId is null. Cannot fetch adoption pets.");
    return []; // Return empty list instead of null
  }

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("🔐 Authorization failed: No valid access token.");
    }

    final response = await http.get(
      Uri.parse("${AppUrl.UserAdoptionUrl}/$userId/"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("📡 Status Code: ${response.statusCode}");
    print("📨 Response Body: ${response.body}");
    print("🔗 URL: ${AppUrl.UserAdoptionUrl}/$userId/");

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = json.decode(response.body);
      return responseBody.map((json) => UserAdoptionModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      // Token expired, try refreshing
      print("🔄 Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        return fetchUserAdoptionPets(userId); // Retry with refreshed token
      } else {
        throw Exception("🔒 Session expired. Please login again.");
      }
    } else {
      throw Exception("🚫 Failed to load adoption pets. Status code: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("❗ Error while fetching adoption pets: $e");
  }
   }
   static Future<File?> downloadPdfWithToken(String transactionId) async {
  try {
    String? accessToken = await getAccessToken(); // Ensure valid token
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final url = '${AppUrl.pdfUrl}$transactionId';
    print("📤 Download PDF URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("📥 Response Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      // Save to local file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/receipt_$transactionId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print("✅ PDF saved to: $filePath");
      return file;
    } else if (response.statusCode == 401) {
      // Token expired, try refresh
      print("🔄 Access token expired. Attempting refresh...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        // Retry with new token
        return await downloadPdfWithToken(transactionId);
      } else {
        throw Exception("🔐 Token refresh failed. User must re-login.");
      }
    } else {
      print("❌ PDF download failed: ${response.reasonPhrase}");
      return null;
    }
  } catch (e) {
    print("❌ Exception during PDF download: $e");
    return null;
  }
}
 static Future<PetTherapyModel?> fetchAllPetTherapies({required String date}) async {
  try {
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    // Add date to the URL
    final uri = Uri.parse(AppUrl.allPetTherapyURL).replace(
      queryParameters: {
        "date": date,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("API Request URL: $uri");
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return PetTherapyModel.fromJson(responseData);
    } else if (response.statusCode == 401) {
      print("Access token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        return fetchAllPetTherapies(date: date); // retry with date again
      } else {
        throw Exception("Failed to refresh token. User must re-login.");
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('API Request Failed: $e');
    return null;
  }
}

  static Future<TherapySlotPageModel?> fetchtherapySlots(
    int therapyId,
    String day,
    String date,
  ) async {
    try {
      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception("Authorization failed: No valid access token");
      }

      final uri = Uri.parse('${AppUrl.therapySlotURL}/$therapyId?date=$date');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print("API Request URL: $uri");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("Requested Date: $date");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return TherapySlotPageModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        print("Access token expired. Refreshing...");
        accessToken = await refreshToken();

        if (accessToken != null) {
          return fetchtherapySlots(therapyId, day, date);
        } else {
          throw Exception("Failed to refresh token. User must re-login.");
        }
      } else {
        print("Error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("API Request Failed: $e");
      return null;
    }
  }
  static Future<List<podcast.Data>> fetchPodcastEpisodeList(int podcastId) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("Authorization failed: No valid access token");
    }

    final response = await http.get(
      Uri.parse("${AppUrl.podcastepisodeURL}?podcast_id=$podcastId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    print("📡 API Request URL: ${AppUrl.podcastepisodeURL}?podcast_id=$podcastId");
    print("📡 Response Status Code: ${response.statusCode}");
    print("📡 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // Parse into model
      final model = podcast.PetPodcastEpisodeModel.fromJson(jsonResponse);

      // Return the actual episode list
      return model.data ?? [];
    } else if (response.statusCode == 401) {
      print("🔄 Access token expired. Refreshing...");
      String? newAccessToken = await refreshToken();

      if (newAccessToken != null) {
        return fetchPodcastEpisodeList(podcastId);
      } else {
        print("❌ Failed to refresh token. Logging out user...");
        if (response.statusCode == 401) {
  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }
}

        return [];
      }
    } else {
      print("❌ Error: ${response.statusCode}, ${response.body}");
      return [];
    }
  } catch (e) {
    print("⚠️ Exception in fetchPodcastEpisodeList: $e");
    return [];
  }
}

static Future<List<PodcastData>> fetchPodcastList() async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("Authorization failed");

    final response = await http.get(
      Uri.parse(AppUrl.podcastlistURL),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final wrapper = PodcastListModel.fromJson(jsonResponse);
      return wrapper.data ?? <PodcastData>[];
    } else if (response.statusCode == 401) {
      String? newAccessToken = await refreshToken();
      if (newAccessToken != null) return fetchPodcastList();
      if (response.statusCode == 401) {
  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }
}

      return <PodcastData>[];
    } else {
      return <PodcastData>[];
    }
  } catch (e) {
    print("⚠️ Exception in fetchPodcastList: $e");
    return <PodcastData>[];
  }
}
static Future<List<categoryModel.Data>> fetchPetStoreCategories() async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("Authorization failed");

    final response = await http.get(
      Uri.parse(AppUrl.petstorecategariesURL),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final wrapper = categoryModel.PetStoreCategoriesModel.fromJson(jsonResponse);

      return wrapper.data ?? <categoryModel.Data>[];
    } else if (response.statusCode == 401) {
      String? newAccessToken = await refreshToken();
      if (newAccessToken != null) return fetchPetStoreCategories();
      if (response.statusCode == 401) {
  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }
}

      return <categoryModel.Data>[];
    } else {
      return <categoryModel.Data>[];
    }
  } catch (e) {
    print("⚠️ Exception in fetchPetStoreCategories: $e");
    return <categoryModel.Data>[];
  }
}

 static Future<List<SubCategoryData>> fetchPetStoreSubCategories(int categoryId) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("Authorization failed");

    final url = "${AppUrl.petstoresubcategariesURL}$categoryId";
    print("📡 GET URL: $url"); // ← add this line
    

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final wrapper = PetStoreSubCategoriesModel.fromJson(jsonResponse);
      return wrapper.data ?? <SubCategoryData>[];
    } else if (response.statusCode == 401) {
      // 🔁 Retry with refreshed token
      String? newAccessToken = await refreshToken();
      if (newAccessToken != null) return fetchPetStoreSubCategories(categoryId);
      if (response.statusCode == 401) {
  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }
}

      return <SubCategoryData>[];
    } else {
      print("❌ Failed to fetch subcategories: ${response.statusCode}");
      print("API Response: ${response.body}");

      return <SubCategoryData>[];
    }
  } catch (e) {
    print("⚠️ Exception in fetchPetStoreSubCategories: $e");
    return <SubCategoryData>[];
  }
}

 static Future<List<productModel.StoreProductData>> fetchProducts(int subCategoryId) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("Authorization failed");

    final url = "${AppUrl.petStoreProductCategaryURL}$subCategoryId";
    debugPrint("📡 GET URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    debugPrint("RAW PRODUCT RESPONSE => ${response.body}");


    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      List rawList = [];

      // ✅ CASE 1: data is List
      if (decoded is Map<String, dynamic> &&
          decoded['data'] is List) {
        rawList = decoded['data'];
      }

      // ✅ CASE 2: data is Map → extract results
      else if (decoded is Map<String, dynamic> &&
          decoded['data'] is Map<String, dynamic>) {
        rawList = decoded['data']['results'] ?? [];
      }

      // ✅ FINAL SAFE CONVERSION
      return rawList
          .map((e) => productModel.StoreProductData.fromJson(e))
          .toList();
    }

    return [];
  } catch (e) {
    debugPrint("⚠️ Exception in fetchProducts: $e");
    return [];
  }
}


static Future<List<Data>> fetchCart() async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("Authorization failed");

    final response = await http.get(
      Uri.parse(AppUrl.cartViewURL),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    print("📦 Cart Status: ${response.statusCode}");
    print("📦 Cart Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final cart = CartViewModel.fromJson(jsonResponse);
      return cart.data;
    } else {
      throw Exception("Failed to fetch cart");
    }
  } catch (e) {
    print("⚠️ fetchCart Error: $e");
    throw Exception("Failed: $e");
  }
}



//   static Future<bool> addToCart({
//   required int productId,
//   required int variantId,
//   required int quantity,
//   required double price,
//   double appliedDiscount = 0.0,
// }) async {
//   try {
//     String? accessToken = await getAccessToken();
//     if (accessToken == null) throw Exception("Authorization failed");

//     final url = Uri.parse(AppUrl.addCartURL);
//     print("📡 POST URL: $url");

//     final payload = {
//       "store_product": productId,
//       "store_product_variant": variantId,
//       "quantity": quantity,
//       "price_at_added": price,
//       "applied_discount": appliedDiscount,
//     };

//     print("⬆️ Payload sent: $payload");

//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $accessToken",
//       },
//       body: jsonEncode(payload),
//     );

//     print("📦 Response: ${response.statusCode} - ${response.body}");

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return true;
//     }

//     // 🔥 Handle Duplicate Cart Entry → Switch to Update API
//     if (response.statusCode == 500 &&
//         response.body.contains("Duplicate entry")) {
//       print("🔄 Duplicate detected → Updating existing cart item");

//       final cartController = Get.find<CartController>();
//       await cartController.loadCart();

//       final existingItem = cartController.cartItems.firstWhereOrNull(
//         (item) =>
//             item.storeProduct == productId &&
//             item.storeProductVariant == variantId,
//       );

//       if (existingItem != null) {
//         final newQty = (existingItem.quantity ?? 1) + quantity;
//         return await cartupdateURL(
//           cartId: existingItem.cartId!,
//           quantity: newQty,
//           item: existingItem,
//         );
//       }
//     }

//     if (response.statusCode == 401) {
//       String? newAccessToken = await refreshToken();
//       if (newAccessToken != null) {
//         return await addToCart(
//           productId: productId,
//           variantId: variantId,
//           quantity: quantity,
//           price: price,
//           appliedDiscount: appliedDiscount,
//         );
//       }
//       handleTokenExpiration();
//       return false;
//     }

//     print("❌ Failed to add to cart: ${response.body}");
//     return false;
//   } catch (e) {
//     print("⚠️ Exception in addToCart: $e");
//     return false;
//   }
// }

// --- ApiService.dart (or wherever) ---
// Assumes getAccessToken(), refreshToken(), handleTokenExpiration() exist and work.

static Future<bool> addToCart({
  required int productId,
  required int variantId,
  required int quantity,
  required double price,
  double appliedDiscount = 0.0,
}) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("Authorization failed");

    final url = Uri.parse(AppUrl.addCartURL);
    print("📡 POST URL: $url");

    final payload = {
      "store_product": productId,
      "store_product_variant": variantId,
      "quantity": quantity,
      "price_at_added": price,
      "applied_discount": appliedDiscount,
    };

    print("⬆️ Payload sent: $payload");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(payload),
    );

    print("📦 Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    // Handle duplicate error: attempt to update existing cart item
    if (response.statusCode == 500 &&
        response.body.contains("Duplicate entry")) {
      print("🔄 Duplicate detected → will try to update existing cart item");

      // Ensure we have fresh cart items from server
      final cartController = Get.find<CartController>();
      await cartController.loadCart(); // await network fetch

      final existingItem = cartController.cartItems.firstWhereOrNull(
        (item) =>
            item.storeProduct == productId &&
            item.storeProductVariant == variantId,
      );

      if (existingItem != null && existingItem.cartId != null) {
        final newQty = (existingItem.quantity ?? 1) + quantity;
        return await cartupdateURL(
          cartId: existingItem.cartId!,
          quantity: newQty,
          item: existingItem,
        );
      } else {
        // If we couldn't find item locally, try a fallback: ask server for cart (already done by loadCart).
        print("⚠️ Duplicate reported but couldn't find existing item locally.");
        return false;
      }
    }

    if (response.statusCode == 401) {
      String? newAccessToken = await refreshToken();
      if (newAccessToken != null) {
        return await addToCart(
          productId: productId,
          variantId: variantId,
          quantity: quantity,
          price: price,
          appliedDiscount: appliedDiscount,
        );
      }
      if (response.statusCode == 401) {
  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }
}

      return false;
    }

    print("❌ Failed to add to cart: ${response.body}");
    return false;
  } catch (e) {
    print("⚠️ Exception in addToCart: $e");
    return false;
  }
}

static Future<bool> cartupdateURL({
  required int cartId,
  required int quantity,
  required dynamic item,
  double appliedDiscount = 0.0,
}) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("Authorization failed");

    // Use the cartId in the path explicitly
    final url = Uri.parse("https://app.pawdli.com/user/cart/update/$cartId/");

    print("📡 PUT URL: $url");

    final body = {
      // backend may or may not expect cartId in body but put it for clarity
      "cartId": cartId,
      "quantity": quantity,
      "applied_discount": appliedDiscount,
    };

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(body),
    );

    print("📦 UPDATE Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      print("✅ Cart item updated");
      return true;
    } else if (response.statusCode == 401) {
      String? newToken = await refreshToken();
      if (newToken != null) {
        return await cartupdateURL(
          cartId: cartId,
          quantity: quantity,
          item: item,
          appliedDiscount: appliedDiscount,
        );
      }
      if (response.statusCode == 401) {
  final ok = await AuthService.refreshTokenIfNeeded();
  if (!ok) {
    AuthService.logoutDueToAuthFailure(reason: '401 unauthorized');
  }
}

      return false;
    } else {
      print("❌ Update failed: ${response.body}");
      return false;
    }
  } catch (e) {
    print("⚠️ Exception in cartupdateURL: $e");
    return false;
  }
}

static Future<bool> cartRemove({required int cartId}) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) throw Exception("Authorization failed");

    final url = Uri.parse("https://app.pawdli.com/user/cart/remove/$cartId/");

    Future<http.Response> sendRequest(String token) async {
      return await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    }

    // first attempt
    var response = await sendRequest(accessToken);

    // if unauthorized try refresh once
    if (response.statusCode == 401 || response.statusCode == 403) {
      print("🔄 Access token expired. Trying refresh...");
      final newToken = await refreshToken();
      if (newToken != null) {
        response = await sendRequest(newToken);
      } else {
        print("❌ Refresh token failed");
        return false;
      }
    }

    print("🗑 DELETE Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      print("🗑️ Cart item removed successfully!");
      return true;
    }

    print("❌ Delete failed: ${response.statusCode} - ${response.body}");
    return false;
  } catch (e) {
    print("⚠️ Exception in cartRemove: $e");
    return false;
  }
}

static Future<List<StoreProductVariant>> fetchVariantsList(
    int productId) async {

  final token = await getAccessToken();

  final headers = {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };

  final variantUrl =
      "https://app.pawdli.com/user/storeproductvariants/$productId/";

  final inventoryUrl =
      "https://app.pawdli.com/user/storeproductinventory/$productId/";

  // 🔥 Fetch both APIs together (FASTER)
  final responses = await Future.wait([
    http.get(Uri.parse(variantUrl), headers: headers),
    http.get(Uri.parse(inventoryUrl), headers: headers),
  ]);

  final variantResponse = responses[0];
  final inventoryResponse = responses[1];

  if (variantResponse.statusCode == 200 &&
      inventoryResponse.statusCode == 200) {

    final variantJson = jsonDecode(variantResponse.body);
    final inventoryJson = jsonDecode(inventoryResponse.body);

    final variantsJson = variantJson['data'] ?? [];
    final inventoryList = inventoryJson['data'] ?? [];

    List<StoreProductVariant> variants =
        variantsJson
            .map<StoreProductVariant>(
              (v) => StoreProductVariant.fromJson(v),
            )
            .toList();

    // ⭐ Create map for fast lookup
    final inventoryMap = {
      for (var inv in inventoryList)
        inv['store_product_variant']: inv
    };

    // 🔥 Merge inventory into variant
    for (var variant in variants) {
      final inv = inventoryMap[variant.variantId];

      if (inv != null) {
        variant.quantityInStock =
            int.tryParse(inv['quantity_in_stock'].toString()) ?? 0;

        variant.quantityReserved =
            int.tryParse(inv['quantity_reserved'].toString()) ?? 0;

        variant.lowStockThreshold =
            int.tryParse(inv['low_stock_threshold'].toString()) ?? 0;
      }
    }

    return variants;
  }

  return [];
}


//   static Future<bool> cartupdateURL({
//   required int cartId,
//   required int quantity,
//   required dynamic item,
//   double appliedDiscount = 0.0,
// }) async {
//   try {
//     String? accessToken = await getAccessToken();
//     if (accessToken == null) throw Exception("Authorization failed");

//     // final url = "${AppUrl.mainURL}/user/cart/update/$quantity/";
//     final url = "https://app.pawdli.com/user/cart/update/${item.cartId}/";

//     print("📡 PUT URL: $url");

//     final response = await http.put(
//       Uri.parse(url),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $accessToken",
//       },
//       body: jsonEncode({
//         "cartId": cartId,
//         "quantity": quantity,
//         "applied_discount": appliedDiscount,
//       }),
//     );

//     print("📦 UPDATE Response: ${response.statusCode} - ${response.body}");

//     if (response.statusCode == 200) {
//       print("✅ Cart item updated");
//       return true;
//     } else if (response.statusCode == 401) {
//       String? newToken = await refreshToken();
//       if (newToken != null) {
//         return await cartupdateURL(
//           cartId: cartId,
//           quantity: quantity,
//           item: item
//           // appliedDiscount: appliedDiscount,
//         );
//       }
//       handleTokenExpiration();
//       return false;
//     } else {
//       print("❌ Update failed: ${response.body}");
//       return false;
//     }
//   } catch (e) {
//     print("⚠️ Exception in cartupdateURL: $e");
//     return false;
//   }
// }

// static Future<bool> cartRemove({required int cartId}) async {
//   final box = GetStorage();
//   final url = "https://app.pawdli.com/user/cart/remove/$cartId/";

//   Future<http.Response> sendRequest() async {
//     final token = box.read(LocalStorageConstants.access);
//     return await http.delete(
//       Uri.parse(url),
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//       },
//     );
//   }

//   // 1️⃣ First attempt
//   var response = await sendRequest();

//   // 2️⃣ If unauthorized → refresh token
//   if (response.statusCode == 401 || response.statusCode == 403) {
//     print("🔄 Access token expired. Trying refresh...");

//     final newToken = await refreshToken();

//     // 3️⃣ If refreshed successfully → retry delete once
//     if (newToken != null) {
//       response = await sendRequest();
//     } else {
//       print("❌ Refresh token failed");
//       return false;
//     }
//   }

//   if (response.statusCode == 200) {
//     print("🗑️ Cart item removed successfully!");
//     return true;
//   }

//   print("❌ Delete failed: ${response.body}");
//   return false;
// }

  static const baseUrl = "https://app.pawdli.com";

  static Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> data,
    String token,
  ) async {
    final url = "$baseUrl/$endpoint";

    logRequest(method: "POST", url: url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    }, body: data);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    logResponse(
      statusCode: response.statusCode,
      url: url,
      body: response.body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("✅ Success");
    } else {
      print("❌ Error: ${response.statusCode}");
    }

    return jsonDecode(response.body);
  }

  static Future<http.Response> postJson({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    return await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  static Future<http.StreamedResponse> postMultipart({
    required String url,
    required Map<String, String> fields,
    required File file,
    required String fileFieldName,
  }) async {
    var req = http.MultipartRequest("POST", Uri.parse(url));

    req.fields.addAll(fields);

    req.files.add(
      await http.MultipartFile.fromPath(fileFieldName, file.path),
    );

    return await req.send();
  }

Future<void> uploadFileToDatabase(PlatformFile file) async {
  final request = http.MultipartRequest(
      'POST', Uri.parse(AppUrl.FileuploadUrl));

  request.files.add(
    http.MultipartFile.fromBytes(
      'file', 
      file.bytes!, 
      filename: file.name
    )
  );

  final response = await request.send();
  if (response.statusCode == 200) {
    print("File uploaded successfully");
  } else {
    print("Upload failed");
  }
}

static Future<bool> uploadFile({
    required File file,
    required String type, // Audio or Video
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppUrl.FileuploadUrl),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      request.fields["type"] = type;

      var response = await request.send();

      return response.statusCode == 200;
    } catch (e) {
      print("Upload Error: $e");
      return false;
    }
  }



  static Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

static Future<bool> confirmOrder({
  required int orderId,
  required String razorpayOrderId,
  required String paymentId,
  required String signature,
}) async {
  final token = await getAccessToken();

  final uri = Uri.parse("https://app.pawdli.com/user/orders_details/");

  final body = {
    "order_id": orderId,
    "razorpay_order_id": razorpayOrderId,
    "razorpay_payment_id": paymentId,
    "razorpay_signature": signature,
    "order_status": "paid"
  };

  final res = await http.post(
    uri,
    headers: _headers(token),
    body: jsonEncode(body),
  );

  print("📦 ORDER CONFIRM RESPONSE = ${res.statusCode} → ${res.body}");

  return res.statusCode == 200 || res.statusCode == 201;
}


static Future<List<Order>> getOrders() async {
  final token = await getAccessToken();
  final uri = Uri.parse("${AppUrl.OrdersUrl}/");

  final res = await http.get(uri, headers: _headers(token));

  print("GET ORDERS RESPONSE: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Failed to load orders: ${res.statusCode}");
  }

  final body = json.decode(res.body);

  // CASE 1: Backend returns List directly
  if (body is List) {
    return body
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // CASE 2: Backend wraps data inside {"data": [ ... ]}
  if (body is Map && body['data'] is List) {
    return (body['data'] as List)
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  return [];
}



static Future<Order> getOrderDetails(int orderId) async {
  final token = await getAccessToken();
  final uri = Uri.parse("${AppUrl.OrdersUrl}/$orderId/");

  final res = await http.get(uri, headers: _headers(token));

  if (res.statusCode != 200) {
    throw Exception("Failed to load order details: ${res.statusCode}");
  }

  final body = json.decode(res.body);
  final data = (body is Map && body['data'] != null) ? body['data'] : body;

  return Order.fromJson(Map<String, dynamic>.from(data));
}


static Future<bool> cancelOrder(int orderId) async {
  final token = await getAccessToken();
  final uri = Uri.parse("${AppUrl.OrdersUrl}/$orderId/cancel/");

  final res = await http.post(uri, headers: _headers(token));

  if (res.statusCode == 200 || res.statusCode == 204) return true;

  // Try to parse success
  try {
    final parsed = json.decode(res.body);
    return parsed['success'] == true || parsed['status'] == true;
  } catch (_) {}

  return false;
}


static Future<bool> reorder(int orderId) async {
  final token = await getAccessToken();
  final uri = Uri.parse("${AppUrl.OrdersUrl}/$orderId/reorder/");

  final res = await http.post(uri, headers: _headers(token));

  return res.statusCode == 200 || res.statusCode == 201;
}



static Future<Map<String, dynamic>?> validateSlotAndGetToken() async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    // DIRECT ENDPOINT: No slotId or bookingId needed
    final uri = Uri.parse(AppUrl.radioStreemUrl);

    debugPrint("📡 GET URL: $uri");

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );

    debugPrint("📥 Status: ${response.statusCode}");
    debugPrint("📩 Body: ${response.body}");
    debugPrint("Now: ${DateTime.now()}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return {
        "live": json["live"] == true,
        "type": json["type"],               // "video" or "audio"
        "stream_url": json["url"],          // <--- use backend key
        "message": json["message"],         // optional
      };
    }

    return null;
  } catch (e) {
    debugPrint("🔥 Stream API Error: $e");
    return null;
  }
}



  // ---------------- UPLOAD REEL ----------------
  static Future<UploadReelResponse?> uploadReelWithProgress({
  required File videoFile,
  required String title,
  required String caption,
  required String token,
  required void Function(int sentBytes, int totalBytes) onProgress,
}) async {
  try {
    final dio = Dio();

    dio.options.headers = {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    };

    final formData = FormData.fromMap({
      "title": title,
      "description": caption,
      "video_file": await MultipartFile.fromFile(
        videoFile.path,
        filename: videoFile.path.split('/').last,
        contentType: MediaType("video", "mp4"),
      ),
    });

    final response = await dio.post(
      "https://app.pawdli.com/user/short_video_upload/",
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) {
          onProgress(sent, total); // 🔥 REAL UPLOAD PROGRESS
        }
      },
    );

    debugPrint("✅ API STATUS CODE: ${response.statusCode}");
    debugPrint("📦 API RESPONSE DATA: ${response.data}");


    if (response.statusCode == 200 || response.statusCode == 201) {
      return UploadReelResponse.fromJson(response.data);
    }

    return null;
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      final newToken = await getAccessToken();
      if (newToken == null) return null;

      return uploadReelWithProgress(
        videoFile: videoFile,
        title: title,
        caption: caption,
        token: newToken,
        onProgress: onProgress,
      );
    }

    print("❌ DIO UPLOAD ERROR: ${e.message}");
    return null;
  }
}



  // ---------------- FETCH REELS ----------------
static Future<List<ReelItem>> fetchReels({int limit = 100, int page = 1,}) async {
  try {
    final box = GetStorage();
    final token = box.read(LocalStorageConstants.access) ?? "";

    // 🔥 DEBUG PRINTS — ADD THESE
    print("=====================================");
    print("FETCH REELS TOKEN DEBUG");
    print("ALL STORAGE KEYS: ${box.getKeys()}");
    print("STORED ACCESS TOKEN: $token");
    print("STORED REFRESH TOKEN: ${box.read(LocalStorageConstants.refresh)}");
    print("=====================================");

    final url = Uri.parse("${AppUrl.reelsUrl}?limit=$limit");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("REELS API RAW: ${response.body}");
    print("🔥 FETCH REELS CALLED");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Backend returns SINGLE OBJECT → convert to list
        if (decoded is Map<String, dynamic>) {
          return [ReelItem.fromJson(decoded)];
        }

        // If backend later switches to array
        if (decoded is List) {
          return decoded.map((e) => ReelItem.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print("FETCH REELS ERROR: $e");
    }

    return [];
  }

static Future<List<ReelItem>> fetchMyReels() async {
  final box = GetStorage();
  final token = box.read("access");

  final res = await http.get(
    Uri.parse(AppUrl.MyreelsUrl),
    headers: {"Authorization": "Bearer $token"},
  );

  if (res.statusCode == 200) {
    final body = jsonDecode(res.body);

    if (body is List) {
      return body.map((e) => ReelItem.fromJson(e)).toList();
    }
  }

  return [];
}


static Future<bool> deleteReel(String videoId) async {
  try {
    final box = GetStorage();
    final token = box.read(LocalStorageConstants.access) ?? "";

    print("=====================================");
    print("DELETE REEL TOKEN DEBUG");
    print("VIDEO ID: $videoId");
    print("ACCESS TOKEN: $token");
    print("=====================================");

    final url = Uri.parse(
      "https://app.pawdli.com/user/short_video/$videoId/delete/",
    );

    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("DELETE REEL STATUS: ${response.statusCode}");
    print("DELETE REEL RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    }
  } catch (e) {
    print("DELETE REEL ERROR: $e");
  }

  return false;
}










// static String? streamToken; // store globally if needed

// static Future<bool> validateBookingAndGetToken(int bookingId) async {
//   try {
//     final accessToken = await ApiService.getAccessToken();
//     if (accessToken == null) {
//       Fluttertoast.showToast(msg: "Authentication failed!");
//       return false;
//     }

//     final response = await http.get(
//       Uri.parse(AppUrl.radioStreemUrl),
//       headers: {"Authorization": "Bearer $accessToken"},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       debugPrint("Booking Validation Success: $data");

//       // ✅ Store only stream token
//       streamToken = data['stream_token']; 
//       debugPrint("Saved Stream Token: $streamToken");

//       return true;
//     } else {
//       debugPrint("Booking Validation Failed: ${response.body}");
//       return false;
//     }
//   } catch (e) {
//     debugPrint("Error validating booking: $e");
//     return false;
//   }
// }





static Future<List<CompetitionModel>> fetchCompetitionButton() async {
  try {
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("❌ No access token found");
      return [];
    }

    final response = await http.get(
      Uri.parse(AppUrl.CompetitionButton),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("📡 CompetitionButton Status: ${response.statusCode}");
    print("📨 CompetitionButton Response: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((e) => CompetitionModel.fromJson(e))
          .toList();
    }

    /// 🔁 TOKEN EXPIRED → REFRESH & RETRY (SAME AS YOUR SAMPLE)
    else if (response.statusCode == 401) {
      print("🔄 Token expired. Refreshing...");
      accessToken = await refreshToken();

      if (accessToken != null) {
        return fetchCompetitionButton();
      } else {
        print("🔒 Session expired");
        return [];
      }
    }

    else {
      print("🚫 API failed: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("❗ CompetitionButton error: $e");
    return [];
  }
}

}





class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
