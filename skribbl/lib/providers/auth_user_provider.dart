import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:skribbl/models/auth_user.dart';
import 'package:skribbl/services/auth_service.dart';

final authUserProvider = StreamProvider<AuthUser?>(
  ((ref) => GetIt.instance<AuthService>().userChanges()),
);
