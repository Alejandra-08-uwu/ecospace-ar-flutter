class Product {
  final String nombre;
  final String precio;
  final String material;
  final String reciclado;
  final String sostenibilidad;
  final String co2;
  final String arUrl;
  final String icono; // nombre de icono (usamos Icons.* en la UI)

  const Product({
    required this.nombre,
    required this.precio,
    required this.material,
    required this.reciclado,
    required this.sostenibilidad,
    required this.co2,
    required this.arUrl,
    required this.icono,
  });
}

// Catálogo basado en tus productos ECO SPACE con AR disponible
const List<Product> catalogoProductos = [
  Product(
    nombre: 'Silla Industrial E-100',
    precio: 'S/.890',
    material: 'Plástico PET reciclado + acero',
    reciclado: '15 botellas PET',
    sostenibilidad: '85%',
    co2: '~42%',
    arUrl: 'https://mywebar.com/p/Project_0_tesqtr6gmo',
    icono: 'chair',
  ),
  Product(
    nombre: 'Mesa Orgánica M-200',
    precio: 'S/.1,490',
    material: 'Madera recuperada + resina',
    reciclado: '8 kg de madera',
    sostenibilidad: '80%',
    co2: '~38%',
    arUrl: 'https://mywebar.com/p/Project_1_o217krfu5g',
    icono: 'table_restaurant',
  ),
  Product(
    nombre: 'Estante Modular C-300',
    precio: 'S/.1,200',
    material: 'Cartón reciclado + bambú',
    reciclado: '12 kg de cartón',
    sostenibilidad: '90%',
    co2: '~45%',
    arUrl: 'https://mywebar.com/p/Project_2_n90m9rjemg',
    icono: 'shelves',
  ),
  Product(
    nombre: 'Banco Minimalista B-400',
    precio: 'S/.750',
    material: 'Plástico PET + fibras textiles',
    reciclado: '22 botellas PET + 3 kg textil',
    sostenibilidad: '75%',
    co2: '~30%',
    arUrl: 'https://mywebar.com/p/Project_3_vbplprm9l2',
    icono: 'weekend',
  ),
];
