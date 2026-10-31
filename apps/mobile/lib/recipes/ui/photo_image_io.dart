import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider photoImage(String path) => FileImage(File(path));
