// Modèle de données pour les paramètres pédiatriques
class ParametresPediatriques {
  final List<TranchePediatrique> tranches;

  ParametresPediatriques({required this.tranches});

  factory ParametresPediatriques.fromJson(Map<String, dynamic> json) {
    return ParametresPediatriques(
      tranches: (json['tranches'] as List<dynamic>)
          .map((t) => TranchePediatrique.fromJson(t))
          .toList(),
    );
  }

  // Trouve la tranche applicable à un index d'âge
  TranchePediatrique? getTranchePourAge(int ageIndex) {
    for (var tranche in tranches) {
      if (ageIndex >= tranche.minIndex && ageIndex <= tranche.maxIndex) {
        return tranche;
      }
    }
    return null;
  }
}

class TranchePediatrique {
  final int minIndex;
  final int maxIndex;
  final int fcMin;
  final int fcMax;
  final int pasMin;
  final int pamMin;
  final int frMin;
  final int frMax;
  final double volumeCourantMlPerKg;
  final String tailleSonde;
  final double chocAcr1a3;
  final double chocAcr4Plus;

  TranchePediatrique({
    required this.minIndex,
    required this.maxIndex,
    required this.fcMin,
    required this.fcMax,
    required this.pasMin,
    required this.pamMin,
    required this.frMin,
    required this.frMax,
    required this.volumeCourantMlPerKg,
    required this.tailleSonde,
    required this.chocAcr1a3,
    required this.chocAcr4Plus,
  });

  factory TranchePediatrique.fromJson(Map<String, dynamic> json) {
    return TranchePediatrique(
      minIndex: json['minIndex'] as int,
      maxIndex: json['maxIndex'] as int,
      fcMin: json['fcMin'] as int,
      fcMax: json['fcMax'] as int,
      pasMin: json['pasMin'] as int,
      pamMin: json['pamMin'] as int,
      frMin: json['frMin'] as int,
      frMax: json['frMax'] as int,
      volumeCourantMlPerKg: (json['volumeCourantMlPerKg'] as num).toDouble(),
      tailleSonde: json['tailleSonde']?.toString() ?? '',
      chocAcr1a3: (json['chocAcr1a3'] as num).toDouble(),
      chocAcr4Plus: (json['chocAcr4Plus'] as num).toDouble(),
    );
  }

  // Calcule les valeurs pour un poids donné
  ValeursPediatriques calculer(double poids) {
    return ValeursPediatriques(
      fcMin: fcMin,
      fcMax: fcMax,
      pasMin: pasMin,
      pamMin: pamMin,
      frMin: frMin,
      frMax: frMax,
      volumeCourant: (volumeCourantMlPerKg * poids).round(),
      tailleSonde: tailleSonde,
      chocAcr1a3: (chocAcr1a3 * poids).round(),
      chocAcr4Plus: (chocAcr4Plus * poids).round(),
    );
  }
}

class ValeursPediatriques {
  final int fcMin;
  final int fcMax;
  final int pasMin;
  final int pamMin;
  final int frMin;
  final int frMax;
  final int volumeCourant;
  final String tailleSonde;
  final int chocAcr1a3;
  final int chocAcr4Plus;

  ValeursPediatriques({
    required this.fcMin,
    required this.fcMax,
    required this.pasMin,
    required this.pamMin,
    required this.frMin,
    required this.frMax,
    required this.volumeCourant,
    required this.tailleSonde,
    required this.chocAcr1a3,
    required this.chocAcr4Plus,
  });
}