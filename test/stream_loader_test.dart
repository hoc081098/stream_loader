import 'package:disposebag/disposebag.dart';

import 'loader_bloc_test.dart' as loader_bloc_test;
import 'loader_message_test.dart' as loader_message_test;
import 'loader_state_test.dart' as loader_state_test;
import 'loader_widget_test.dart' as loader_widget_test;
import 'partial_state_change_test.dart' as partial_state_change_test;

void main() {
  DisposeBag.logger = null;
  loader_message_test.main();
  partial_state_change_test.main();
  loader_state_test.main();
  loader_bloc_test.main();
  loader_widget_test.main();
}
