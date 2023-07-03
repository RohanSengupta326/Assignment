import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/employee.dart';
import '/database_helper.dart';

class EmployeeState {
  final List<Employee> employees;

  EmployeeState(this.employees);
}

class EmployeeEvent {}

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final DatabaseHelper databaseHelper;

  EmployeeBloc(this.databaseHelper) : super(EmployeeState([])) {
    on<FetchEmployeesEvent>((event, emit) async {
      final employees = await databaseHelper.getEmployees();
      print('Fetched Employees: $employees');
      emit(EmployeeState(employees));
    });

    on<AddEmployeeEvent>((event, emit) async {
      final employee = event.employee;
      await databaseHelper.insertEmployee(employee);
      final updatedEmployees = [...state.employees, employee];
      emit(EmployeeState(updatedEmployees));
    });

    on<DeleteEmployeeEvent>((event, emit) async {
      final employee = event.employee;
      await databaseHelper.deleteEmployee(
          employee); // Update this according to your implementation
      final updatedEmployees = state.employees
          .where((e) => e.startDate.toString() != employee.startDate.toString())
          .toList();
      emit(EmployeeState(updatedEmployees));
    });
  }

  @override
  Stream<EmployeeState> mapEventToState(EmployeeEvent event) async* {
    if (event is FetchEmployeesEvent) {
      final employees = await databaseHelper.getEmployees();
      yield EmployeeState(employees);
    } else if (event is AddEmployeeEvent) {
      final employee = event.employee;
      await databaseHelper.insertEmployee(employee);
      final updatedEmployees = [...state.employees, employee];
      yield EmployeeState(updatedEmployees);
    }
  }
}

class FetchEmployeesEvent extends EmployeeEvent {}

class AddEmployeeEvent extends EmployeeEvent {
  final Employee employee;

  AddEmployeeEvent(this.employee);
}

class DeleteEmployeeEvent extends EmployeeEvent {
  final Employee employee;

  DeleteEmployeeEvent(this.employee);
}
