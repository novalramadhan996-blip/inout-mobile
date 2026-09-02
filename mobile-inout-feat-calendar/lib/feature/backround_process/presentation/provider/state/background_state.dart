// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:equatable/equatable.dart';
// import 'package:mobile_in_out/feature/home/model/employee_detail_model.dart';

// enum BackgroundConcreteState {
//   initial,
//   loading,
//   loaded,
//   failure,
//   fetchingMore,
//   fetchedAllProducts,
// }

// class BackgroundState extends Equatable {
//   final EmployeeDetailModel employeeDetail;
//   final BackgroundConcreteState state;
//   final String message;
//   final bool isLoading;
//   const BackgroundState({
//     required this.employeeDetail,
//     this.isLoading = false,
//     this.state = BackgroundConcreteState.initial,
//     this.message = '',
//   });

//   const BackgroundState.initial({
//     required this.employeeDetail,
//     this.isLoading = false,
//     this.state = BackgroundConcreteState.initial,
//     this.message = '',
//   });

//   BackgroundState copyWith({
//     required EmployeeDetailModel employeeDetail,
//     BackgroundConcreteState? state,
//     String? message,
//     bool? isLoading,
//   }) {
//     return BackgroundState(
//       isLoading: isLoading ?? this.isLoading,
//       employeeDetail: employeeDetail,
//       state: state ?? this.state,
//       message: message ?? this.message,
//     );
//   }

//   @override
//   String toString() {
//     return 'BackgroundState(isLoading:$isLoading, employeeDetail:$employeeDetail, state: $state, message: $message)';
//   }

//   @override
//   List<Object?> get props => [employeeDetail, state, message];
// }
