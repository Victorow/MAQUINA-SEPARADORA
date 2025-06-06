// lib/models/filter_options.dart

// import 'package:equatable/equatable.dart'; // Descomente se quiser usar Equatable

class FilterOption /* extends Equatable */ { // Se usar Equatable, descomente e implemente props
  final int id;
  final String name;

  const FilterOption({
    required this.id,
    required this.name,
  });

  // Se usar Equatable:
  // @override
  // List<Object?> get props => [id, name];

  // Opcional: se você for usar DropdownButtonFormField e quiser que o objeto
  // seja comparado corretamente quando um valor é selecionado, implementar
  // hashCode e operator == é uma boa prática, ou usar o pacote Equatable.
  // Por enquanto, para manter simples, vamos sem Equatable.
}