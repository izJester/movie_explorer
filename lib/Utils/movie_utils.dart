extension MovieGenreExtensions on int {
  String get genreName {
    switch (this) {
      case 28: return 'Acción';
      case 12: return 'Aventura';
      case 16: return 'Animación';
      case 35: return 'Comedia';
      case 80: return 'Crimen';
      case 99: return 'Documental';
      case 18: return 'Drama';
      case 10751: return 'Familia';
      case 14: return 'Fantasía';
      case 36: return 'Historia';
      case 27: return 'Terror';
      case 10402: return 'Música';
      case 9648: return 'Misterio';
      case 10749: return 'Romance';
      case 878: return 'Ciencia ficción';
      case 10770: return 'Película de TV';
      case 53: return 'Suspense';
      case 10752: return 'Bélica';
      case 37: return 'Western';
      default: return 'Género $this';
    }
  }
}