import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'homepage_state.dart';

class HomepageCubit extends Cubit<HomepageState> {
  HomepageCubit() : super(HomepageInitial());
}
