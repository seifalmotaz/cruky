part of cruky.request;

/// get the fields from multi form fields
RegExp _matchName = RegExp('name=["|\'](.+)["|\']');
RegExp _matchFileName = RegExp('filename=["|\'](.+)["|\']');

extension ReqConverter on ReqCTX {
  Future json() async {
    String string = await utf8.decodeStream(native);
    var body = string.isEmpty ? {} : jsonDecode(string);
    return body;
  }

  Future<Uint8List> _getBytes(HttpRequest request) {
    return request
        .fold<BytesBuilder>(BytesBuilder(copy: false), (a, b) => a..add(b))
        .then((b) => b.takeBytes());
  }

  Future<FormData> form() async {
    var bytes = await _getBytes(native);
    Map<String, List<String>> body =
        UriCustom.splitQueryStringMulti(String.fromCharCodes(bytes));
    return FormData(body);
  }

  Future<iFormData> iForm() async {
    final Map<String, String> formFields = {};
    final Map<String, List<FilePart>> formFiles = {};
    Stream<Uint8List> stream;

    var bytes = await _getBytes(native);
    var ctrl = StreamController<Uint8List>()
      ..add(bytes)
      ..close();
    stream = ctrl.stream;

    var parts = MimeMultipartTransformer(
            native.headers.contentType!.parameters['boundary']!)
        .bind(stream);

    await for (MimeMultipart part in parts) {
      String headers = part.headers['content-disposition']!;

      /// split headers fields
      List<String> headersFields = headers.split(';');

      /// get the name of form field
      String field = headersFields.firstWhere((e) => _matchName.hasMatch(e));
      RegExpMatch? fieldNameMatch = _matchName.firstMatch(field);

      /// check if the field name exist
      {
        if (fieldNameMatch == null) {
          throw {
            #status: 500,
            "msg": "Cannot find the header name field for the request",
          };
        }

        if (fieldNameMatch[1] == null) {
          throw {
            #status: 500,
            "msg": "the form field name is empty please "
                "try to put a name for the field",
          };
        }
      }

      String name = fieldNameMatch[1]!;

      /// check if this part is field or file
      if (!headers.contains('filename=')) {
        /// handle if if it's a field
        formFields[name] = await utf8.decodeStream(part);
        continue;
      }

      /// handle if it's file
      /// get file name from headers
      field = headersFields.firstWhere((e) => _matchFileName.hasMatch(e));
      RegExpMatch? fileNameMatch = _matchFileName.firstMatch(headers);

      /// check if the file name exist
      {
        if (fileNameMatch == null) {
          throw {
            #status: 500,
            "msg": "Cannot find the header name field for the request",
          };
        }

        if (fileNameMatch[1] == null) {
          throw {
            #status: 500,
            "msg": "the form field name is empty please "
                "try to put a name for the field",
          };
        }
      }

      String filename = fileNameMatch[1]!;

      /// add the file to formFiles as stream
      Stream<List<int>> streamBytes = part.asBroadcastStream();
      if (formFiles.containsKey(name)) {
        formFiles[name]!.add(FilePart(name, filename, streamBytes));
      } else {
        formFiles[name] = [FilePart(name, filename, streamBytes)];
      }
    }
    return iFormData(formFields, formFiles);
  }
}

/// form data
// ignore: camel_case_types
class FormData {
  final Map<String, List<String>> formFields;
  List? operator [](String i) => formFields[i];
  FormData(this.formFields);
}

/// multipart form data
// ignore: camel_case_types
class iFormData extends FormData {
  final Map<String, List<FilePart>> formFiles;

  @override
  List? operator [](String i) => formFields[i] ?? formFiles[i];

  iFormData(formFields, this.formFiles) : super(formFields);
}

extension GetData on FormData {
  /// get value of field as [int]
  int? getInt(String name) => formFields[name]?.first.toInt();

  /// get value of field as [doubel]
  double? getDouble(String name) => formFields[name]?.first.toDouble();

  /// get value of field as [num]
  num? getNum(String name) => formFields[name]?.first.toNum();

  /// get value of field as [Map]
  Map? getMap(String name) => formFields[name]?.first.toMap();

  /// get value of field as [bool]
  bool? getBool(String name) => formFields[name]?.first.toBool();
}
