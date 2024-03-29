part of 'filter_cubit.dart';

@freezed
abstract class FilterState with _$FilterState {
  const factory FilterState.succes(
      {FilterDTO filter,
      @Default(false) bool isValid,
      @Default(None()) Option<Failure> failure,
      @Default(false) bool applyFilter}) = _Succes;
}
